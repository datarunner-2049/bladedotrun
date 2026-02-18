# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Server

This is a single-file static site. Serve it locally with:

```bash
python -m http.server 3000
```

Then open `http://localhost:3000` in the browser.

## Architecture

Everything lives in `index.html` — styles, markup, and JavaScript are all inline in a single file. There is no build step, no framework, and no dependencies beyond Google Fonts (loaded via CDN).

**Dashboard panels** each follow the same structure:
- `.tile` — clickable card container
- `.tile-header` with `.tile-title` and `.tile-status` — status badge uses one of three CSS classes: `status-online` (green), `status-offline` (red), `status-development` (yellow)
- `.tile-description` — plain text description
- `.tile-preview` — bottom content area, styled per panel

**JavaScript** (inline `<script>` at bottom of body) handles:
- Floating particle animation via DOM manipulation
- Live clock update (`#current-time`) via `setInterval`
- Weather temperature randomisation (`#temp`) via `setInterval`
- Tile click animation via `handleTileClick()`
- Occasional screen flicker effect

## Git Config

Repository-level git identity is set (do not change globally):
- `user.name`: datarunner-2049
- `user.email`: josh@blade.run
