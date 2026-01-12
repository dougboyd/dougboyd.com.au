#!/bin/bash

# Email notification script for dougboyd.com.au
# Sends Buttondown email notifications to subscribers about site updates

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the project root directory (parent of scripts directory)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Load API key from .env file
if [ -f "$PROJECT_ROOT/.env" ]; then
    source "$PROJECT_ROOT/.env"
fi

if [ -z "$BUTTONDOWN_API_KEY" ]; then
    echo -e "${RED}✗ Buttondown API key not found${NC}"
    echo "   To enable notifications, add BUTTONDOWN_API_KEY to .env file"
    exit 1
fi

echo -e "${BLUE}Sending email notification to subscribers...${NC}"

# Generate a random variation of the email message each time
random_variant=$((RANDOM % 8))
build_date=$(date '+%B %d, %Y at %H:%M %Z')

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
response=$(jq -n \
    --arg subject "$subject" \
    --arg body "$body" \
    '{subject: $subject, body: $body}' | \
    curl -X POST https://api.buttondown.email/v1/emails \
        -H "Authorization: Token $BUTTONDOWN_API_KEY" \
        -H "Content-Type: application/json" \
        -d @- \
        --silent --show-error --write-out "\n%{http_code}")

http_code=$(echo "$response" | grep -o '[0-9]\{3\}$')

if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Email notification sent successfully${NC}"
    exit 0
else
    echo -e "${RED}✗ Email notification failed (HTTP $http_code)${NC}"
    echo "   Response: $(echo "$response" | head -n -1)"
    exit 1
fi
