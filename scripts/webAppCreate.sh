#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file with timestamp
LOG_FILE="../logs/webAppCreate-$(date +%Y%m%d-%H%M%S).log"

# Redirect all output to both terminal and log
exec > >(tee -a "$LOG_FILE")
exec 2>&1

echo -e "${GREEN}Deployment started at $(date)${NC}"
echo -e "${BLUE}Log file: $LOG_FILE${NC}"

echo ""
echo -e "${BLUE}Creating Resource Group...${NC}"
az group create --name dougboyd-com-au-rg \
    --location australiaeast

echo ""
echo -e "${BLUE}Creating DEV App Service Plan (Free F1)...${NC}"
az appservice plan create \
  --name dev-plan \
  --resource-group dougboyd-com-au-rg \
  --sku F1 \
  --is-linux

echo ""
echo -e "${BLUE}Creating DEV Web App...${NC}"
az webapp create \
  --name dougboyd-dev \
  --resource-group dougboyd-com-au-rg \
  --plan dev-plan \
  --runtime "NODE|20-lts"

# Removed config set - not needed for static sites with Node.js runtime
# echo ""
# echo -e "${BLUE}Configuring for static HTML site (disabling Python startup)...${NC}"
# az webapp config set \
  # --resource-group dougboyd-com-au-rg \
  # --name dougboyd-dev \
  # --startup-file "" \
  # --linux-fx-version "PYTHON|3.11"

echo -e "${GREEN}✓ DEV Web App created successfully${NC}"
echo -e "${YELLOW}Note: DEV uses Free tier (F1) - no SSL for custom domains${NC}"

## PROD - Create production environment
echo ""
echo -e "${BLUE}Creating PROD App Service Plan (Basic B1 - ~\$13 USD/month)...${NC}"
az appservice plan create \
  --name prod-plan \
  --resource-group dougboyd-com-au-rg \
  --sku B1 \
  --is-linux

echo ""
echo -e "${BLUE}Creating PROD Web App...${NC}"
az webapp create \
  --name dougboyd-prod \
  --resource-group dougboyd-com-au-rg \
  --plan prod-plan \
  --runtime "NODE|20-lts"

echo -e "${GREEN}✓ PROD Web App created successfully${NC}"
echo -e "${YELLOW}PROD uses Basic B1 tier - supports custom domains with SSL${NC}"

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Created Resources:${NC}"
echo "  • Resource Group: dougboyd-com-au-rg (Australia East)"
echo "  • DEV App Plan: dev-plan (Free F1 - \$0/month)"
echo "  • DEV Web App: dougboyd-dev"
echo "    → https://dougboyd-dev.azurewebsites.net"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Configure custom domain in Azure Portal for dev.dougboyd.com.au"
echo "  2. When ready for PROD, uncomment PROD section and re-run"
echo "  3. PROD will cost ~\$13 USD/month (Basic B1 tier)"
echo ""
echo -e "${YELLOW}Cost Summary:${NC}"
echo "  • Current: \$0/month (DEV only)"
echo "  • With PROD: ~\$13 USD/month"