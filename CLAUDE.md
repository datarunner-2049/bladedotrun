# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Server

Static site — no build step. Serve locally with:

```bash
python -m http.server 3000
```

Then open `http://localhost:3000` in the browser.

## File Structure

- `index.html` — main dashboard
- `weather.html` — space weather page, linked from the Weather Grid tile

All styles, markup, and JavaScript are inline within each HTML file. No framework, no dependencies beyond Google Fonts (CDN).

## Dashboard (index.html)

**Panel structure** — each tile follows:
- `.tile` — clickable card container
- `.tile-header` with `.tile-title` and `.tile-status` — badge uses one of three CSS classes: `status-online` (green), `status-offline` (red), `status-development` (yellow)
- `.tile-description` — plain text description
- `.tile-preview` — bottom content area, styled per panel

**JavaScript** handles:
- Floating particle animation via DOM manipulation
- Live clock update (`#current-time`) via `setInterval`
- Tile click animation via `handleTileClick()`

**Current panel states:**
- Code Runner, Memory Bank, ID Generator, Archive Access, Diagnostic Mode — `status-offline` (red)
- Weather Grid — `status-development` (yellow), links to `weather.html`

## Weather Page (weather.html)

Fetches live data from the NASA DONKI API on page load using `Promise.allSettled` for three parallel requests:

| Panel | Endpoint |
|-------|----------|
| Solar Flares | `/DONKI/WS/get/FLR` |
| Coronal Mass Ejections | `/DONKI/WS/get/CME` |
| Geomagnetic Storms | `/DONKI/WS/get/GST` |

- Date range is computed dynamically (last 7 days)
- API key is stored in the `API_KEY` const at the top of the `<script>` block
- Each panel badge cycles: `FETCHING` → `ONLINE` or `ERROR`
- Shares the same visual style as `index.html` (grid-bg, particles, Orbitron/Roboto Mono fonts)

## Git Config

Repository-level git identity (do not change globally):
- `user.name`: datarunner-2049
- `user.email`: josh@blade.run
