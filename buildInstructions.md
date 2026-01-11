# Webpage Generation Instructions

## Two-Phase Build Process

### Phase 1: Homepage Preview ("Build The Homepage")

When Doug says **"Build The Homepage"** or **"Preview The Design"**:

1. **Generate ONLY the homepage** (index.html):
   - Create a completely new visual design (colors, fonts, layout, theme)
   - Generate new CSS with fresh design system
   - Process home.md from Page_Content according to AI directives
   - Apply all footer requirements (Ko-fi, timestamp)
   - Include background images as required

2. **Purpose**: Allow Doug to review the design direction before committing to a full site regeneration

3. **No Deployment**: This is preview only - changes stay local for review

4. **Design Preferences**: Doug prefers lighter and more fun looking designs. The brutalist and dark stuff doesn't play well with him. Think bright, playful, energetic, approachable.

### Phase 2: Full Site Build ("Build The Site")

When Doug says **"Build The Site"** or **"Regenerate Everything"** (after Phase 1 approval):

1. **Regenerate EVERYTHING** from scratch:
   - Apply the approved design system to ALL pages
   - Regenerate all CSS (or use the approved CSS from Phase 1)
   - All HTML pages with updated content from Page_Content
   - Process all markdown files according to AI directives
   - Scan all Page_Content subdirectories for the tree structure
   - Create landing pages for sections with multiple pages

2. **Deploy to Production**:
   - Deploy to Azure Web App: dougboyd-prod.azurewebsites.net
   - Site will be live at https://www.dougboyd.com.au and https://dougboyd.com.au

3. **Send Email Notifications**:
   - Automatically notify all Buttondown subscribers of the new build

**IMPORTANT**: Every regeneration should produce a completely different look and feel. Change everything: theme, colors, typography, layout patterns, spacing systems.

## Git Repository
For reference, the GIT repo is located at https://github.com/dougboyd/dougboyd.com.au

## Background Images

**REQUIRED**: Every design MUST incorporate background images from the `./images/background-images/` directory.

- Background images should be used in headers, hero sections, or as subtle page backgrounds
- CSS must ensure images don't interfere with content readability (use overlays, gradients, blur effects as needed)
- Images can be applied to specific sections or as full-page backgrounds
- Consider the design theme when selecting images - they should complement the overall aesthetic
- Use CSS techniques like `background-attachment: fixed`, opacity adjustments, or filters to integrate images seamlessly

The site should never feel bare or purely text-based. Background images add visual interest and personality to each build.

## Content Generation

All content is held in the `Page_Content/` directory. The site follows a **tree structure**:

- Each subdirectory in `Page_Content/` represents a section of the site
- Each `.md` file within a subdirectory becomes a separate page
- Subdirectories can contain multiple pages (multiple `.md` files)
- Subdirectories can contain nested subdirectories for deeper hierarchies
- The main navigation links to section landing pages
- Section landing pages should link to their individual sub-pages

**Example structure:**
```
Page_Content/
├── Tech/
│   ├── About_This_Site.md    → tech-about.html
│   └── To_Do.md              → tech-todo.html
├── RV7_Builders_Log/
│   └── Builders_Log.docx     → rv7-builders-log.html
└── home.md                   → index.html
```

When a section has multiple pages, create an index/landing page for that section that links to all sub-pages.

### Markdown File Processing

When processing `.md` files in Page_Content, follow these directives:

- **`***Creative Writing with AI`**: Replace following text/bullet points with AI-generated writing. Use files in `SampleWriting/` directory as style guide for Doug's voice.

- **`***Formal Writing with AI`**: Replace following text/bullet points with formal/technical AI-generated writing.

- **`***No AI`**: Leave the following text completely unchanged. This is Doug's raw writing.

- **`***Instructional`**: Treat as an instruction to you (the AI). Remove from final content.

### Other File Types

- **`.docx` files**: Convert to text, then format for HTML display
- **Coming soon pages**: Generate placeholder pages for sections without content yet

### Cache Busting

**CRITICAL**: All CSS and JavaScript file references MUST include cache-busting query parameters to ensure browsers load the latest version.

**Implementation**:
- Add `?v=YYYYMMDD` to all stylesheet and script references
- Use the current build date as the version parameter
- Example: `<link rel="stylesheet" href="styles/main.css?v=20260111">`
- Example: `<script src="scripts/main.js?v=20260111"></script>`

**Why This Matters**:
Browsers aggressively cache CSS and JavaScript files. Without cache busting, users will see outdated styles even after deploying a new build. The version parameter forces browsers to fetch the new files.

**Format**: `YYYYMMDD` (e.g., `20260111` for January 11, 2026)

### Timestamp Requirements

**CRITICAL**: Every page MUST include a visible timestamp showing when it was generated.

**Timestamp Format**: "Generated January 10, 2026, 09:15 AEDT"
- Use full month name (January, not Jan)
- Include day, year
- Include time with timezone
- Use actual generation time from build execution

**Timestamp Placement Options**:
1. In the footer (recommended - see Footer Requirements below)
2. As a subtle element in the page header
3. In a metadata section at bottom of content

The timestamp serves as accountability—it proves the content is current and documents when the build occurred.

### Google Analytics Tracking

**REQUIRED**: Every page MUST include Google Analytics 4 tracking code in the `<head>` section:

```html
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-X8VGBX1GHX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-X8VGBX1GHX');
</script>
```

**Placement**: Include this snippet immediately after the opening `<head>` tag in every HTML page.

**Purpose**: Track visitor counts, page views, and site analytics.

### Footer Requirements

At the bottom of every page, include a footer with this exact structure:

```html
<footer class="main-footer">
    <div class="container">
        <div class="footer-content">
            <p>&copy; 2026 Doug Boyd. All Rights Reserved.</p>
            <a href="https://ko-fi.com/dougboyd" class="kofi-button" target="_blank" rel="noopener">
                Support This Work ☕
            </a>
            <p class="footer-date">Generated January 10, 2026, 09:15 AEDT</p>
        </div>
    </div>
</footer>
```

**Required elements:**
- Copyright notice with current year
- Ko-fi support button linking to https://ko-fi.com/dougboyd
- **Full timestamp** in format: "Generated January 10, 2026, 09:15 AEDT"

**IMPORTANT**:
- The Ko-fi button must always be present in the footer
- The timestamp must reflect the actual build time
- Style footer elements to match the current design theme

## Design Guidelines

The site should:

1. Be deployable as a single artifact to Azure Web Apps
2. Use design inspiration from sites like:
   - https://www.arlenmccluskey.com/
   - https://www.mackandpouya.com/
   - https://www.aileen.co/
   - https://www.iamtamara.design/
   - https://colin-moy.webflow.io/
   - https://www.thickandthin.co/
   - https://www.byalicelee.com/
   - https://www.sabanna.online/the-philosophers-diary

3. Structure as a tree: homepage at root, navigation for each Page_Content directory

## Security

At no point should anything be published that creates security risk. Never commit:
- `.env` file (contains API keys)
- `.godaddy-config` file
- Any credentials or secrets

## Newsletter Integration

The site includes a Buttondown email signup form. When deploying to production, the deploy script automatically sends email notifications to all subscribers about the new build. Here's the specific html to embed:

<form
  action="https://buttondown.com/api/emails/embed-subscribe/dougboyd"
  method="post"
  class="embeddable-buttondown-form"
>
  <label for="bd-email">Enter your email</label>
  <input type="email" name="email" id="bd-email" />
  <input type="submit" value="Subscribe" />
  <p>
    <a href="https://buttondown.com/refer/dougboyd" target="_blank">
      Powered by Buttondown.
    </a>
  </p>
</form>

## Prerequisites

- Azure CLI installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Logged into Azure: `az login`
- Buttondown API key in `.env` file (for email notifications)

## Dev Environment (Deprecated)

Dev site (dougboyd-dev.azurewebsites.net) still exists on F1 Free tier but is no longer actively used. All builds go directly to production.
