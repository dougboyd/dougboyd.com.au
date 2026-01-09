# Webpage Generation Instructions

## Single Build Command

When Doug says **"Build The Site"** or **"Regenerate"**:

1. **Regenerate EVERYTHING** from scratch:
   - New visual design (colors, fonts, layout, theme)
   - New CSS with fresh design system
   - All HTML pages with updated content from Page_Content
   - Process all markdown files according to AI directives below

2. **Deploy to Production**:
   - Deploy to Azure Web App: dougboyd-prod.azurewebsites.net
   - Site will be live at https://www.dougboyd.com.au and https://dougboyd.com.au

3. **Send Email Notifications**:
   - Automatically notify all Buttondown subscribers of the new build

**IMPORTANT**: Every regeneration should produce a completely different look and feel. Change everything: theme, colors, typography, layout patterns, spacing systems. The brutalist design you see now? Next build could be completely different.

## Git Repository
For reference, the GIT repo is located at https://github.com/dougboyd/dougboyd.com.au

## Background Images
There's a directory called `./images/background-images/`. Feel free to use any images for headers/footers/backgrounds. Adjust CSS so images don't interfere with content readability.

## Content Generation

All content is held in the `Page_Content/` directory. Each subdirectory represents a section of the site.

### Markdown File Processing

When processing `.md` files in Page_Content, follow these directives:

- **`***Creative Writing with AI`**: Replace following text/bullet points with AI-generated writing. Use files in `SampleWriting/` directory as style guide for Doug's voice.

- **`***Formal Writing with AI`**: Replace following text/bullet points with formal/technical AI-generated writing.

- **`***No AI`**: Leave the following text completely unchanged. This is Doug's raw writing.

- **`***Instructional`**: Treat as an instruction to you (the AI). Remove from final content.

### Other File Types

- **`.docx` files**: Convert to text, then format for HTML display
- **Coming soon pages**: Generate placeholder pages for sections without content yet

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

The site includes a Buttondown email signup form. When deploying to production, the deploy script automatically sends email notifications to all subscribers about the new build.

## Prerequisites

- Azure CLI installed: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
- Logged into Azure: `az login`
- Buttondown API key in `.env` file (for email notifications)

## Dev Environment (Deprecated)

Dev site (dougboyd-dev.azurewebsites.net) still exists on F1 Free tier but is no longer actively used. All builds go directly to production.
