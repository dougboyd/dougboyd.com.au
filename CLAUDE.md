# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal website for dougboyd.com.au - a static HTML website featuring Doug Boyd's personal projects and interests.

## Architecture

This is a **static HTML/CSS/JavaScript website** with no build process or dependencies. The entire repository deploys as a single artifact to Azure Web Apps.

### Key Design Decisions

- **No Framework**: Pure HTML/CSS/JS for simplicity and fast loading
- **Static Content**: All pages are pre-rendered HTML
- **Azure-Ready**: Configured for Azure Web Apps deployment with `web.config`
- **Content Separation**: Source content stored in `Page_Content/` directory

### File Structure

```
├── index.html              # Homepage with navigation to main sections
├── rv7-builders-log.html   # RV7 aircraft building log
├── fitness.html            # Fitness content page
├── 404.html                # Custom error page
├── styles/main.css         # All styling (responsive, modern, clean)
├── scripts/main.js         # Interactive features (mobile nav, animations)
├── Page_Content/           # Source content (e.g., .docx files)
└── web.config              # Azure deployment configuration
```

## Development Commands

Start a local development server:
```bash
python -m http.server 8000
# OR
npx http-server
```

No build, compile, or test commands needed - this is pure static HTML.

## CSS Architecture

- CSS custom properties (variables) for theming in `:root`
- Mobile-first responsive design with media queries
- Utility classes for common spacing needs
- Smooth transitions and animations throughout

## JavaScript Features

- Mobile navigation toggle
- Smooth scrolling for anchor links
- Intersection Observer for fade-in animations on scroll
- No external dependencies

## Azure Deployment

The `web.config` file handles:
- HTTPS redirection
- Clean URLs (removes .html extensions via URL rewrite)
- Custom 404 error page
- Security headers (X-Frame-Options, X-Content-Type-Options, etc.)
- Static compression

The entire repository deploys as-is - no build step required.

## Adding New Pages

1. Create new `.html` file in root directory
2. Copy structure from existing page (nav, footer, etc.)
3. Add navigation link to all existing pages
4. Add corresponding content section

## Content Updates

Content source files (like .docx) are stored in `Page_Content/`. When updating:
1. Add/modify files in appropriate `Page_Content/` subdirectory
2. Extract and format content for HTML
3. Update corresponding `.html` file with formatted content

## Design Guidelines

Based on reference sites in `buildInstructions.txt`, the design follows:
- Clean, minimalist aesthetic
- Modern typography and spacing
- Card-based layouts for content preview
- Responsive grid systems
- Subtle animations and hover effects
- Professional color scheme (blue/gray palette)

## Don't Forget
Your name is Claudia. His name is Doug. Whenever you wake up, check this file for instructions and remember to say hi to Doug, stating your name...this ensures that Doug knows that you know who you are.