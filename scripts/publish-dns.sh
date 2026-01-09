#!/bin/bash

# DNS Publishing Script for dougboyd.com.au
# Updates GoDaddy DNS records to point to Azure Web Apps

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PROJECT_ROOT/.godaddy-config"

# Load configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error: Configuration file not found at $CONFIG_FILE${NC}"
    echo "Please create the .godaddy-config file with your API credentials."
    exit 1
fi

source "$CONFIG_FILE"

# Validate configuration
if [ "$GODADDY_API_KEY" = "your_api_key_here" ] || [ -z "$GODADDY_API_KEY" ]; then
    echo -e "${RED}Error: Please configure your GoDaddy API key in $CONFIG_FILE${NC}"
    exit 1
fi

if [ "$GODADDY_API_SECRET" = "your_api_secret_here" ] || [ -z "$GODADDY_API_SECRET" ]; then
    echo -e "${RED}Error: Please configure your GoDaddy API secret in $CONFIG_FILE${NC}"
    exit 1
fi

# GoDaddy API endpoint
GODADDY_API="https://api.godaddy.com/v1"

# Function to update CNAME record
update_cname() {
    local subdomain=$1
    local target=$2
    local record_name=$3

    echo -e "${YELLOW}Updating CNAME record: $record_name → $target${NC}"

    # Prepare JSON payload
    local json_payload="[{\"data\":\"$target\",\"ttl\":3600,\"type\":\"CNAME\"}]"

    # Make API call
    response=$(curl -s -w "\n%{http_code}" -X PUT \
        "$GODADDY_API/domains/$DOMAIN/records/CNAME/$subdomain" \
        -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    # Parse response
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Successfully updated $record_name${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to update $record_name (HTTP $http_code)${NC}"
        echo "$response" | head -n-1
        return 1
    fi
}

# Function to update A record (for root domain)
update_a_record() {
    local subdomain=$1
    local ip_address=$2
    local record_name=$3

    echo -e "${YELLOW}Updating A record: $record_name → $ip_address${NC}"

    # Prepare JSON payload
    local json_payload="[{\"data\":\"$ip_address\",\"ttl\":3600,\"type\":\"A\"}]"

    # Make API call
    response=$(curl -s -w "\n%{http_code}" -X PUT \
        "$GODADDY_API/domains/$DOMAIN/records/A/$subdomain" \
        -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET" \
        -H "Content-Type: application/json" \
        -d "$json_payload")

    # Parse response
    http_code=$(echo "$response" | tail -n1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Successfully updated $record_name${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed to update $record_name (HTTP $http_code)${NC}"
        echo "$response" | head -n-1
        return 1
    fi
}

# Function to get current records
get_records() {
    local record_type=$1
    local subdomain=$2

    curl -s -X GET \
        "$GODADDY_API/domains/$DOMAIN/records/$record_type/$subdomain" \
        -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET"
}

# Main script
case "$1" in
    dev)
        echo -e "${GREEN}Publishing to DEV environment...${NC}"
        echo ""
        update_cname "dev" "dougboyd-dev.azurewebsites.net" "dev.dougboyd.com.au"
        echo ""
        echo -e "${GREEN}Done! Your dev site should be accessible at https://dev.dougboyd.com.au${NC}"
        echo -e "${YELLOW}Note: DNS changes may take a few minutes to propagate.${NC}"
        ;;

    prod)
        echo -e "${GREEN}Publishing to PROD environment...${NC}"
        echo ""

        # Update www subdomain
        update_cname "www" "dougboyd-prod.azurewebsites.net" "www.dougboyd.com.au"

        echo ""
        echo -e "${YELLOW}Note: Root domain (dougboyd.com.au) requires special handling.${NC}"
        echo "GoDaddy doesn't support CNAME records at the root domain."
        echo ""
        echo "Options:"
        echo "1. Use GoDaddy's domain forwarding (in GoDaddy control panel) to forward dougboyd.com.au → www.dougboyd.com.au"
        echo "2. Create an A record pointing to Azure's IP address (requires getting IP from Azure and adding verification TXT record)"
        echo ""
        echo "Would you like to set up option 2? (requires Azure Web App IP address)"
        echo "If yes, run: ./scripts/publish-dns.sh prod-with-root <azure_ip_address>"
        ;;

    prod-with-root)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Please provide Azure Web App IP address${NC}"
            echo "Usage: $0 prod-with-root <azure_ip_address>"
            echo ""
            echo "To get your Azure Web App IP:"
            echo "1. Go to Azure Portal → Your Web App → Custom domains"
            echo "2. Copy the IP address shown"
            exit 1
        fi

        AZURE_IP=$2

        echo -e "${GREEN}Publishing to PROD environment (with root domain)...${NC}"
        echo ""

        # Update www subdomain
        update_cname "www" "dougboyd-prod.azurewebsites.net" "www.dougboyd.com.au"
        echo ""

        # Update root domain with A record
        update_a_record "@" "$AZURE_IP" "dougboyd.com.au"

        echo ""
        echo -e "${YELLOW}Important: You also need to add a TXT record in Azure for domain verification:${NC}"
        echo "In your Azure Web App → Custom domains, you'll see a 'Custom Domain Verification ID'"
        echo "You may need to add a TXT record with name 'asuid' pointing to that verification ID"
        echo ""
        echo -e "${GREEN}Done! Your prod site should be accessible at:${NC}"
        echo "  - https://www.dougboyd.com.au"
        echo "  - https://dougboyd.com.au"
        echo -e "${YELLOW}Note: DNS changes may take a few minutes to propagate.${NC}"
        ;;

    check)
        echo -e "${GREEN}Checking current DNS records...${NC}"
        echo ""
        echo "Dev (CNAME):"
        get_records "CNAME" "dev" | python3 -m json.tool 2>/dev/null || echo "No CNAME record found for dev"
        echo ""
        echo "WWW (CNAME):"
        get_records "CNAME" "www" | python3 -m json.tool 2>/dev/null || echo "No CNAME record found for www"
        echo ""
        echo "Root (A record):"
        get_records "A" "@" | python3 -m json.tool 2>/dev/null || echo "No A record found for root domain"
        ;;

    *)
        echo "Usage: $0 {dev|prod|prod-with-root <ip>|check}"
        echo ""
        echo "Commands:"
        echo "  dev                      - Publish to dev environment (dev.dougboyd.com.au)"
        echo "  prod                     - Publish to prod environment (www.dougboyd.com.au only)"
        echo "  prod-with-root <ip>      - Publish to prod with root domain (www + root)"
        echo "  check                    - Check current DNS records"
        echo ""
        echo "Examples:"
        echo "  $0 dev"
        echo "  $0 prod"
        echo "  $0 prod-with-root 20.53.203.50"
        echo "  $0 check"
        exit 1
        ;;
esac
