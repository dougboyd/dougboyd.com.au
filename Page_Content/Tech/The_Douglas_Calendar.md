***Creative Writing With AI

We run lots of different calendars in our house. ICloud, Google, some strange things from an old school that Chloe went to, some outlook. It's ugly and I'm continually be harassed for not having something in the right calendar. 

I'm an engineer. I fix things. Or make them if there's nothing to fix. 

And so the Douglas Calendar was born. We've already got a google home - clunky, but it works. Bunch of speakers and a small, annoying Hub screen which is pretty useless. But I've got a couple of old Samsung tablets which were looking for something to do.

![Alt text](../../images/tech/dcbCalendar.JPG "A Thousand Ways to skin this cat and took the most difficult")

Here's the technical info:

# DCB Calendar - Technical Overview

## Technology Stack

### Frontend
- Angular 21 with standalone components
- NgRx for state management (Store, Effects, Entity)
- TypeScript
- CSS with dark theme styling
- PWA manifest for standalone app mode
- Google Cast SDK integration

### Backend
- Node.js with Express
- PostgreSQL database
- Google Calendar API (service account authentication)
- Apple iCloud CalDAV sync
- node-cron for scheduled sync jobs

### Infrastructure
- macOS LaunchAgents for auto-start services
- Cloudflare Tunnel for external access
- `serve` package for static file serving

### Display
- Samsung tablet with Fully Kiosk Browser
- Fullscreen kiosk mode display

## Production Setup Steps

### 1. System Prerequisites
- Installed Homebrew package manager
- Installed Node.js (v25.x)
- Installed PostgreSQL via Homebrew
- Installed cloudflared CLI tool

### 2. Database Setup
- Created `dcb_calendar` database
- Ran DDL scripts from `./postgres/` directory
- Created tables: calendars, events, voice_commands
- Configured connection with local `sysadmin` user

### 3. Calendar Sync Configuration
- Created Google Cloud service account for Calendar API access
- Generated app-specific password for iCloud CalDAV
- Configured `.env` file with credentials
- Synced unlimited calendars across all known major calendar services (currently 5 calendars syncing) 
- Total: ~3,700 events synced

### 4. Auto-Start Services (LaunchAgents)
- `com.dcbcalendar.server.plist` - Node.js API server (port 3000)
- `com.dcbcalendar.angular.plist` - Angular static server (port 4200)
- `com.dcbcalendar.tunnel.plist` - Cloudflare tunnel

### 5. Cloudflare Tunnel Setup
- Added dougboyd.com.au domain to Cloudflare
- Created tunnel `xxxxxxxxx` with DNS route to `xxxxx.xxxxx.com.au`
- Configured path-based routing: `/api/*` → port 3000, everything else → port 4200

### 6. Angular Production Build
- Configured fileReplacements in angular.json for production environment
- Set apiUrl to `http://192.168.1.110:3000/api` for LAN access
- Added PWA manifest with standalone display mode
- Added meta tags for mobile web app capability

### 7. Tablet Display Setup
- Installed Fully Kiosk Browser on Samsung tablet
- Configured start URL: `http://192.168.1.110:4200`
- Enabled fullscreen kiosk mode

### 8. MacBook Air Server Configuration
- Dedicated MacBook Air as home server in internet cupboard
- Configured power management to prevent sleep (`pmset` settings)
- All services auto-start on boot via LaunchAgents

## Voice Command Infrastructure (Ready for Future Use)
- Webhook endpoints implemented in server.js
- `voice_commands` table for command queue
- Angular polling service for command processing
- Supports: show_calendar, show_date, hide_calendar commands

Syncs automatically every couple of minutes with a screen content refresh every 30 seconds.