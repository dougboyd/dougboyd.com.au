# dougboyd.com.au
Personal Website

## Project Structure

```
dougboyd.com.au/
├── index.html              # Homepage
├── rv7-builders-log.html   # RV7 Builder's Log page
├── fitness.html            # Fitness page
├── 404.html                # Custom 404 error page
├── styles/
│   └── main.css           # Main stylesheet
├── scripts/
│   └── main.js            # Main JavaScript file
├── Page_Content/          # Source content for pages
│   ├── RV7_Builders_Log/
│   └── Fitness/
├── web.config             # Azure Web App configuration
├── .deployment            # Azure deployment config
└── deploy.cmd             # Azure deployment script
```

## Development

This is a static HTML website. To develop locally:

1. Open `index.html` in a web browser, or
2. Use a local web server:
   ```bash
   # Python 3
   python -m http.server 8000

   # Node.js (if you have http-server installed)
   npx http-server
   ```

## Deployment to Azure

This site is configured for deployment to Azure Web Apps as a static website.

### Initial Setup

#### 1. Create Azure Resources

Run the setup script to create the resource group, app service plan, and web app:

```bash
./scripts/webAppCreate.sh
```

This creates:
- Resource group: `dougboyd-com-au-rg`
- App service plan: `dev-plan` (F1 Free tier)
- Web app: `dougboyd-dev` (Python 3.11 runtime)

**Note**: The F1 Free tier does NOT support custom domains or SSL certificates. The dev site will only be accessible at `dougboyd-dev.azurewebsites.net`.

#### 2. Deploy the Site

Deploy the site to Azure:

```bash
./scripts/deploy-azure.sh dev
```

The site will be accessible at: `https://dougboyd-dev.azurewebsites.net`

---

## Production Setup (Custom Domain with SSL)

When ready to deploy to production with a custom domain, you'll need to create a production environment on the Basic (B1) tier (~$13/month), which supports custom domains and SSL certificates.

### Step 1: Create Production Resources

Uncomment the PROD section in `scripts/webAppCreate.sh` and run:

```bash
./scripts/webAppCreate.sh
```

This creates:
- App service plan: `prod-plan` (B1 Basic tier)
- Web app: `dougboyd-prod` (Python 3.11 runtime)

**Cost**: ~$13/month for B1 tier

### Step 2: Deploy to Production

```bash
./scripts/deploy-azure.sh prod
```

The site will be accessible at: `https://dougboyd-prod.azurewebsites.net`

### Step 3: Set Up Custom Domain (One-Time Configuration)

#### Step 3a: Configure DNS in GoDaddy

Log into GoDaddy and add a CNAME record:
- **Type**: CNAME
- **Host**: `www`
- **Points to**: `dougboyd-prod.azurewebsites.net`
- **TTL**: 600 seconds (or default)

Wait 5-10 minutes for DNS propagation.

#### Step 3b: Add Custom Domain to Azure

```bash
az webapp config hostname add \
    --webapp-name dougboyd-prod \
    --resource-group dougboyd-com-au-rg \
    --hostname www.dougboyd.com.au
```

#### Step 3c: Create Managed SSL Certificate

```bash
az webapp config ssl create \
    --resource-group dougboyd-com-au-rg \
    --name dougboyd-prod \
    --hostname www.dougboyd.com.au
```

**Note**: Certificate provisioning can take 5-10 minutes. Check status with:
```bash
az webapp config ssl list \
    --resource-group dougboyd-com-au-rg \
    --query "[?name=='www.dougboyd.com.au']"
```

#### Step 3d: Bind SSL Certificate

```bash
az webapp config ssl bind \
    --resource-group dougboyd-com-au-rg \
    --name dougboyd-prod \
    --certificate-thumbprint auto \
    --ssl-type SNI \
    --hostname www.dougboyd.com.au
```

#### Step 3e: Enforce HTTPS

```bash
az webapp update \
    --resource-group dougboyd-com-au-rg \
    --name dougboyd-prod \
    --https-only true
```

The site is now accessible at: `https://www.dougboyd.com.au`

### Future Deployments

After initial setup, just deploy code changes:

**For dev (free tier, no custom domain):**
```bash
./scripts/deploy-azure.sh dev
```

**For production (B1 tier, with custom domain):**
```bash
./scripts/deploy-azure.sh prod
```

No need to reconfigure domains or SSL - those settings persist.

---

## What Gets Deployed

The entire repository is deployed as a single artifact. The `web.config` file configures:
- HTTPS redirection
- Clean URLs (removes .html extensions)
- Custom 404 page
- Security headers
- Compression

## Testing Locally

Test the site structure before deploying:
```bash
python -m http.server 8000
```

Visit http://localhost:8000

## Adding Content

Content for pages is stored in the `Page_Content/` directory. To add content:

1. Add your content files to the appropriate subdirectory
2. Update the corresponding HTML file
3. Commit and push changes

## Features

- Responsive design (mobile, tablet, desktop)
- Clean, modern aesthetic
- Smooth animations and transitions
- Mobile-friendly navigation
- SEO-friendly structure
- Fast loading times

---

## Email Notifications (Buttondown Integration)

This site uses [Buttondown](https://buttondown.email) for email newsletter subscriptions to notify visitors when new builds are published.

### Setup

#### 1. Create Buttondown Account

1. Sign up at https://buttondown.email
2. Get your API key from Settings → API
3. Store the API key securely (add to `.env` or similar - DO NOT commit to git)

My Buttondown username is dougboyd. I've logged in with my Google account to utilise SSO 

#### 2. Add Signup Form to Site

Buttondown provides an embeddable form. Add it to your HTML pages where you want visitors to subscribe:

```html
<form
  action="https://buttondown.email/api/emails/embed-subscribe/YOUR_USERNAME"
  method="post"
  target="popupwindow"
  onsubmit="window.open('https://buttondown.email/YOUR_USERNAME', 'popupwindow')"
  class="embeddable-buttondown-form"
>
  <label for="bd-email">Email</label>
  <input type="email" name="email" id="bd-email" required />
  <input type="submit" value="Subscribe" />
</form>
```

Replace `YOUR_USERNAME` with your Buttondown username.

#### 3. Configure Automated Notifications

The deployment script can automatically send email notifications to all subscribers when a new build is published.

**Add to `.gitignore`:**
```
.env
```

**Create `.env` file in project root:**
```bash
BUTTONDOWN_API_KEY=your_api_key_here
```

**Modify `scripts/deploy-azure.sh`** to add this function after successful deployment:

```bash
# Function to send Buttondown notification
send_build_notification() {
    local env=$1

    # Load API key from .env file
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi

    if [ -z "$BUTTONDOWN_API_KEY" ]; then
        echo -e "${YELLOW}⚠️  Buttondown API key not found. Skipping email notification.${NC}"
        echo "To enable notifications, add BUTTONDOWN_API_KEY to .env file"
        return
    fi

    echo -e "${BLUE}Sending email notification to subscribers...${NC}"

    local subject="New Build: dougboyd.com.au Updated"
    local body="The site has been regenerated with new content and/or design. Check it out at https://www.dougboyd.com.au"

    curl -X POST https://api.buttondown.email/v1/emails \
        -H "Authorization: Token $BUTTONDOWN_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"subject\": \"$subject\", \"body\": \"$body\"}" \
        --silent --show-error

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Email notification sent successfully${NC}"
    else
        echo -e "${RED}✗ Failed to send email notification${NC}"
    fi
}
```

Then call it after successful deployment:
```bash
# At the end of deploy_to_azure function, after deployment succeeds
send_build_notification $env
```

### Manual Notification

To manually send a notification without deploying:

```bash
source .env
curl -X POST https://api.buttondown.email/v1/emails \
    -H "Authorization: Token $BUTTONDOWN_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"subject": "Update from dougboyd.com.au", "body": "Your message here"}'
```

### API Documentation

Full Buttondown API docs: https://api.buttondown.email/v1/schema

**Key endpoints:**
- `POST /v1/emails` - Send email to all subscribers
- `GET /v1/subscribers` - List all subscribers
- `POST /v1/subscribers` - Add subscriber programmatically

---

## Ko-fi Support Integration

This site uses [Ko-fi](https://ko-fi.com) to allow visitors to support the work with one-time tips or donations.

### Why Ko-fi?

- **No platform fees** - Ko-fi doesn't take a cut (only PayPal/Stripe fees apply)
- **Simple integration** - Just a button/link, no complex API or widgets required
- **No account required** - Supporters can donate without creating an account
- **Clean design** - Easy to style the button to match the site's brutalist aesthetic

### Setup

#### 1. Create Ko-fi Account

1. Sign up at https://ko-fi.com
2. Complete your profile (username, description, profile image)
3. Set up your payment method (PayPal or Stripe)
4. Your Ko-fi page URL will be: `https://ko-fi.com/your_username`

My Ko-fi username is **dougboyd**. Ko-fi page: https://ko-fi.com/dougboyd

**Payment Methods Configured:**
- PayPal (default Ko-fi integration)
- Stripe (for direct credit/debit card payments)

Both payment processors are managed entirely by Ko-fi. Supporters can choose their preferred payment method when they visit the Ko-fi page.

**Stripe Recovery Code:** Stored securely in `.env` file (never commit to git)

#### 2. Add Ko-fi Button to Footer

Add the Ko-fi support button to the footer of all HTML pages:

```html
<footer class="main-footer">
    <div class="container">
        <div class="footer-content">
            <p>&copy; 2026 DOUG BOYD. ALL RIGHTS RESERVED.</p>
            <a href="https://ko-fi.com/dougboyd" class="kofi-button" target="_blank" rel="noopener">
                SUPPORT THIS WORK ☕
            </a>
            <p class="footer-date">GENERATED JANUARY 10, 2026</p>
        </div>
    </div>
</footer>
```

#### 3. Style the Button

Add CSS to match the brutalist design:

```css
/* Ko-fi button styling */
.footer-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--spacing-sm);
}

.kofi-button {
    display: inline-block;
    font-family: var(--font-primary);
    font-size: 0.9rem;
    padding: var(--spacing-sm) var(--spacing-md);
    border: var(--border-width) solid var(--color-border-heavy);
    background-color: var(--color-primary);
    color: var(--color-accent);
    text-decoration: none;
    text-transform: uppercase;
    font-weight: bold;
    transition: all 0.2s ease;
}

.kofi-button:hover {
    background-color: var(--color-accent);
    color: var(--color-background);
    transform: translateY(-2px);
}

.footer-date {
    font-size: 0.85rem;
    color: var(--color-text-muted);
    margin: 0;
}

@media (max-width: 768px) {
    .footer-content {
        text-align: center;
    }
}
```

### Pages to Update

Add the Ko-fi button to the footer of all site pages:
- `index.html`
- `rv7-builders-log.html`
- `fitness.html`
- `tech.html`
- `writings.html`
- `everything-else.html`
- `404.html`

### Ko-fi Features

Ko-fi provides additional features you can enable later:
- **Memberships** - Monthly recurring support tiers
- **Shop** - Sell digital products or commissions
- **Goal tracking** - Show progress toward funding goals
- **Supporter messages** - Let supporters leave messages with donations

### Security Note

Ko-fi is entirely link-based - no API keys or credentials needed in your codebase. The button simply links to your public Ko-fi page where supporters complete transactions securely on Ko-fi's platform.
