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
- `archive.html` — setup scripts download page, linked from the Archive Access tile
- `scripts/setup.ps1` — Windows setup script (winget-based)
- `scripts/setup.sh` — Linux setup script (multi-distro bash)

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
- Code Runner, Memory Bank, ID Generator — `status-offline` (red)
- Weather Grid — `status-online` (green), links to `weather.html`
- Archive Access — `status-online` (green), links to `archive.html`
- Diagnostic Mode — `status-online` (green), links to `diagnostic.html`

## Weather Page (weather.html)

Fetches live data from the NASA DONKI API on page load using `Promise.allSettled` for three parallel requests:

| Panel | Endpoint |
|-------|----------|
| Solar Flares | `/FLR` |
| Coronal Mass Ejections | `/CME` |
| Geomagnetic Storms | `/GST` |

- Base URL: `https://api.nasa.gov/DONKI`
- Date range is computed dynamically (last 7 days)
- API key is stored in the `API_KEY` const at the top of the `<script>` block
- Each panel badge cycles: `FETCHING` → `ONLINE` or `ERROR`
- Shares the same visual style as `index.html` (grid-bg, particles, Orbitron/Roboto Mono fonts)
- Header has a `← DASHBOARD` back-link

## Archive Page (archive.html)

Download page for system setup scripts. Two cards:

| Card | Script | Package Manager |
|------|--------|-----------------|
| Windows Setup | `scripts/setup.ps1` | winget |
| Linux Setup | `scripts/setup.sh` | apt / dnf / pacman (auto-detected) |

Both scripts install: Chrome, Steam, Claude, Discord.
- Each card has an `.app-list` of `.app-chip` tags showing included apps
- Download links use the `download` attribute to trigger file download
- Usage instructions shown in a `.usage-block` beneath the download button
- Shares the same visual style as other pages (grid-bg, particles, back-link)

## Diagnostic Page (diagnostic.html)

IT sysadmin network intelligence tool. Single shared query input triggers all 5 panels in parallel via `Promise.allSettled`. No backend — all APIs are CORS-friendly public endpoints.

| Panel | API | Notes |
|-------|-----|-------|
| Domain/IP Lookup | `rdap.org/domain/{d}` or `rdap.arin.net/registry/ip/{ip}` + `ipapi.co/{ip}/json/` | RDAP for registration data, ipapi.co for ASN/ISP |
| SSL Certificate | `crt.sh/?q={domain}&output=json` | Certificate transparency logs — not live cert |
| Geolocation | `ipapi.co/{ip}/json/` | Shared fetch with Lookup panel to avoid duplicate calls |
| HTTP Headers | `api.allorigins.win/get?url={url}` | CORS proxy — confirms reachability + HTTP status only; security header state is UNKNOWN |
| DNS Propagation | `dns.google/resolve`, `cloudflare-dns.com/dns-query`, `doh.opendns.com/dns-query` | DoH queries for A records across 3 resolvers |

**Key JS functions:**
- `runAll()` — orchestrates all 5 panels, resolves IP + fetches ipapi.co once and passes result to `runLookup()` and `runGeo()`
- `setBadge(id, state)` — states: `ready` / `fetching` / `online` / `error`
- `resolveARecord(domain)` — Cloudflare DoH helper, shared by Lookup + Geo
- `addToHistory(query)` / `rerunQuery(index)` — session-only command history sidebar (max 50 entries)

**Layout:** Two-column — 260px sticky history sidebar + responsive 2-col panels grid. Panels 4 & 5 span full width (`.panel-wide`). Collapses to single column below 1100px.

## Background Effects

All pages share the same animated grid + particle system:
- `html` carries the gradient background (`background-attachment: fixed`); `body` is `background: transparent`
- `.grid-bg` — fixed position, `z-index: -1`, CSS grid lines at `rgba(0,212,255,0.25)` opacity, animated via `gridMove` keyframes
- `.particles` — JS-created `.particle` divs (3px, glowing teal dots) float upward via `float` keyframe animation
- `createParticles()` creates 20 particles on load, repeats every 20s

## Git Config

Repository-level git identity (do not change globally):
- `user.name`: datarunner-2049
- `user.email`: josh@blade.run
