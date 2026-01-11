#!/bin/bash

# Azure Deployment Script for dougboyd.com.au
# Deploys static site to Azure Web Apps

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Log file with timestamp
LOG_FILE="$PROJECT_ROOT/logs/deploy-azure-$(date +%Y%m%d-%H%M%S).log"

# Create logs directory if it doesn't exist
mkdir -p "$PROJECT_ROOT/logs"

# Redirect all output to both terminal and log
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${GREEN}Deployment started at $(date)${NC}"
echo -e "${BLUE}Log file: $LOG_FILE${NC}"
echo ""

# Azure Web App names
DEV_APP_NAME="dougboyd-dev"
PROD_APP_NAME="dougboyd-prod"

# Resource group (update this if different)
RESOURCE_GROUP="dougboyd-com-au-rg"

# Files to exclude from deployment
EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "node_modules"
    "scripts"
    "Page_Content"
    "buildInstructions.md"
    "buildInstructions.txt"
    "CLAUDE.md"
    ".godaddy-config"
    ".DS_Store"
    "*.zip"
)

# Function to check if Azure CLI is installed
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        echo -e "${RED}Error: Azure CLI is not installed${NC}"
        echo ""
        echo "Please install Azure CLI:"
        echo "  macOS:   brew install azure-cli"
        echo "  Windows: https://aka.ms/installazurecliwindows"
        echo "  Linux:   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
        echo ""
        echo "After installation, login with: az login"
        exit 1
    fi
}

# Function to check if logged into Azure
check_azure_login() {
    echo -e "${BLUE}Checking Azure login status...${NC}"
    if ! az account show &> /dev/null; then
        echo -e "${RED}Error: Not logged into Azure${NC}"
        echo "Please run: az login"
        exit 1
    fi

    local account=$(az account show --query name -o tsv)
    echo -e "${GREEN}✓ Logged into Azure account: $account${NC}"
}

# Function to create deployment artifact
create_artifact() {
    local env=$1
    local artifact_dir="$PROJECT_ROOT/.deploy-$env"

    echo -e "${BLUE}Creating deployment artifact for $env...${NC}"

    # Clean previous artifact
    if [ -d "$artifact_dir" ]; then
        rm -rf "$artifact_dir"
    fi

    # Create artifact directory
    mkdir -p "$artifact_dir"

    # Copy all files except excluded patterns
    echo "Copying files..."
    rsync -av \
        --exclude='.git/' \
        --exclude='node_modules/' \
        --exclude='scripts/' \
        --exclude='Page_Content/' \
        --exclude='buildInstructions.md' \
        --exclude='buildInstructions.txt' \
        --exclude='CLAUDE.md' \
        --exclude='.godaddy-config' \
        --exclude='.env' \
        --exclude='.DS_Store' \
        --exclude='.deploy-*' \
        --exclude='*.zip' \
        --exclude='logs/' \
        "$PROJECT_ROOT/" "$artifact_dir/"

    echo -e "${GREEN}✓ Artifact created${NC}"
    # Return the path via a variable instead of echo
    ARTIFACT_DIR="$artifact_dir"
}

# Function to deploy to Azure Web App
deploy_to_azure() {
    local app_name=$1

    echo -e "${BLUE}Deploying to Azure Web App: $app_name${NC}"

    # Create zip file for deployment
    local zip_file="$PROJECT_ROOT/.deploy-temp.zip"
    echo "Creating deployment package..."
    (cd "$ARTIFACT_DIR" && zip -r "$zip_file" . -q)

    echo "Uploading to Azure..."
    az webapp deployment source config-zip \
        --resource-group "$RESOURCE_GROUP" \
        --name "$app_name" \
        --src "$zip_file" \
        --timeout 300

    # Clean up
    rm -f "$zip_file"
    rm -rf "$ARTIFACT_DIR"

    echo -e "${GREEN}✓ Successfully deployed to $app_name${NC}"
}

# Function to send Buttondown notification
send_build_notification() {
    local env=$1

    # Load API key from .env file
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi

    if [ -z "$BUTTONDOWN_API_KEY" ]; then
        echo -e "${YELLOW}⚠️  Buttondown API key not found. Skipping email notification.${NC}"
        echo "   To enable notifications, add BUTTONDOWN_API_KEY to .env file"
        return
    fi

    echo ""
    echo -e "${BLUE}Sending email notification to subscribers...${NC}"

    # Generate a random variation of the email message each time
    local random_variant=$((RANDOM % 8))
    local subject
    local body
    local build_date=$(date '+%B %d, %Y at %H:%M %Z')

    case $random_variant in
        0)
            subject="Fresh Build: Something Changed at dougboyd.com.au"
            body="The site just regenerated. New content, possibly a new design, definitely a new timestamp.

What might be different this time? Build log updates? Design tweaks? New writing? Only one way to find out.

→ https://www.dougboyd.com.au

Built: $build_date"
            ;;
        1)
            subject="Site Update: dougboyd.com.au Regenerated"
            body="Another build just deployed. The AI regenerated everything from scratch—layout, content, the whole stack.

Could be new rudder build progress. Could be a complete visual redesign. Could be both. The site doesn't stay static for long.

→ https://www.dougboyd.com.au

Deployed: $build_date"
            ;;
        2)
            subject="New Build Deployed: dougboyd.com.au"
            body="Site's been regenerated. Content updated, design possibly refreshed, timestamp definitely current.

Check out what's new—might be aircraft build progress, might be fitness updates, might be technical deep-dives. Always something.

→ https://www.dougboyd.com.au

Build timestamp: $build_date"
            ;;
        3)
            subject="dougboyd.com.au: Fresh Deploy"
            body="Just pushed a new build. The site regenerates completely each time—no incremental updates, just full reconstruction from markdown sources.

New content is live. Possibly new design too. The AI doesn't repeat itself.

→ https://www.dougboyd.com.au

Generated: $build_date"
            ;;
        4)
            subject="Update: New Content at dougboyd.com.au"
            body="The build system just ran. Everything regenerated from source—HTML, CSS, content, the works.

Something changed. Could be build log entries, could be new writing, could be the entire visual theme. Only way to know is to look.

→ https://www.dougboyd.com.au

Build date: $build_date"
            ;;
        5)
            subject="Site Regenerated: dougboyd.com.au"
            body="Fresh build deployed. The whole site reconstructs from scratch each time—different design possible, new content likely, timestamp guaranteed.

Worth checking what's new. RV-7 progress? Fitness updates? Technical documentation? All of the above?

→ https://www.dougboyd.com.au

Timestamp: $build_date"
            ;;
        6)
            subject="New Build: dougboyd.com.au Updated"
            body="Site just regenerated. Complete rebuild from markdown sources—could be new content, could be new design, could be both.

The AI handles the generation, so expect variation. Nothing stays the same for long around here.

→ https://www.dougboyd.com.au

Built: $build_date"
            ;;
        7)
            subject="Fresh Content: dougboyd.com.au Rebuilt"
            body="Another deployment cycle complete. The site regenerates entirely each build—new timestamp, updated content, possibly refreshed design.

Check it out. Build log updates? New technical articles? Different color scheme? Could be any of those.

→ https://www.dougboyd.com.au

Deployed: $build_date"
            ;;
    esac

    # Use jq to properly construct JSON with multiline body text
    local response=$(jq -n \
        --arg subject "$subject" \
        --arg body "$body" \
        '{subject: $subject, body: $body}' | \
        curl -X POST https://api.buttondown.email/v1/emails \
            -H "Authorization: Token $BUTTONDOWN_API_KEY" \
            -H "Content-Type: application/json" \
            -d @- \
            --silent --show-error --write-out "\n%{http_code}")

    local http_code=$(echo "$response" | grep -o '[0-9]\{3\}$')

    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Email notification sent successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Email notification failed (HTTP $http_code)${NC}"
        echo -e "${YELLOW}   This is non-critical - deployment was successful${NC}"
        echo -e "${YELLOW}   Check Buttondown API configuration if notifications are needed${NC}"
        # Note: Common issues:
        # - HTTP 400: Invalid request format or missing required fields
        # - Check Buttondown API docs for correct endpoint and payload format
        # - May need to use /v1/emails/draft or different endpoint
    fi
}

# Function to commit and push to git
commit_and_push() {
    local env=$1

    echo ""
    echo -e "${BLUE}Committing changes to git repository...${NC}"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Not a git repository. Skipping git commit.${NC}"
        return
    fi

    # Check if there are any changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        echo -e "${YELLOW}⚠️  No changes to commit.${NC}"
        return
    fi

    # Get current timestamp for commit message
    local timestamp=$(date '+%B %d, %Y at %H:%M %Z')
    local commit_msg="Site build and deployment - $env

Generated: $timestamp
Deployed to: $env environment

🤖 Generated with Claude Code (https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

    # Stage all changes
    echo "Staging all changes..."
    git add -A

    # Commit with message
    echo "Creating commit..."
    git commit -m "$(cat <<EOF
$commit_msg
EOF
)" || {
        echo -e "${YELLOW}⚠️  Git commit failed. This is non-critical.${NC}"
        return
    }

    # Push to remote
    echo "Pushing to remote repository..."
    git push || {
        echo -e "${YELLOW}⚠️  Git push failed. You may need to push manually.${NC}"
        return
    }

    echo -e "${GREEN}✓ Changes committed and pushed to git repository${NC}"
}

# Function to show deployment info
show_deployment_info() {
    local env=$1
    local url=$2

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${GREEN}  Deployment Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo ""
    echo -e "Environment: ${BLUE}$env${NC}"
    echo -e "Site URL:    ${BLUE}$url${NC}"
    echo ""
    echo -e "${YELLOW}Note: It may take a few moments for changes to appear.${NC}"
    echo ""
}

# Main script
main() {
    case "$1" in
        dev)
            echo -e "${GREEN}Starting DEV deployment...${NC}"
            echo ""

            check_azure_cli
            check_azure_login

            create_artifact "dev"
            deploy_to_azure "$DEV_APP_NAME"

            # Commit and push changes to git
            commit_and_push "DEV"

            show_deployment_info "DEV" "https://dev.dougboyd.com.au"
            ;;

        prod)
            echo -e "${GREEN}Starting PROD deployment...${NC}"
            echo ""

            # Confirmation for prod deployment
            echo -e "${YELLOW}⚠️  You are about to deploy to PRODUCTION${NC}"
            read -p "Are you sure? (yes/no): " -r
            echo
            if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                echo "Deployment cancelled."
                exit 0
            fi

            check_azure_cli
            check_azure_login

            create_artifact "prod"
            deploy_to_azure "$PROD_APP_NAME"

            # Send email notification to subscribers
            send_build_notification "PROD"

            # Commit and push changes to git
            commit_and_push "PROD"

            show_deployment_info "PROD" "https://www.dougboyd.com.au"
            ;;

        status)
            check_azure_cli
            check_azure_login

            echo -e "${BLUE}Getting deployment status...${NC}"
            echo ""
            echo "DEV Environment:"
            az webapp show --name "$DEV_APP_NAME" --resource-group "$RESOURCE_GROUP" \
                --query "{name:name,state:state,defaultHostName:defaultHostName}" -o table
            echo ""
            echo "PROD Environment:"
            az webapp show --name "$PROD_APP_NAME" --resource-group "$RESOURCE_GROUP" \
                --query "{name:name,state:state,defaultHostName:defaultHostName}" -o table
            ;;

        *)
            echo "Usage: $0 {dev|prod|status}"
            echo ""
            echo "Commands:"
            echo "  dev      - Deploy to DEV environment (dev.dougboyd.com.au)"
            echo "  prod     - Deploy to PROD environment (www.dougboyd.com.au)"
            echo "  status   - Check status of Azure Web Apps"
            echo ""
            echo "Examples:"
            echo "  $0 dev"
            echo "  $0 prod"
            echo "  $0 status"
            echo ""
            echo "Prerequisites:"
            echo "  - Azure CLI installed (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)"
            echo "  - Logged into Azure (az login)"
            exit 1
            ;;
    esac
}

main "$@"
