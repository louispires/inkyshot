# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Inkyshot is a Raspberry Pi IoT application that displays daily quotes and weather forecasts on an e-ink display (Pimoroni Inky pHAT or Waveshare 2.13"). Runs on Balena Cloud for fleet management and OTA updates.

## Running & Testing

No automated test suite. Test by running the Python script directly:

```bash
# Local simulation (no hardware)
cd inkyshot
python update-display.py

# Build and push to Balena fleet
balena push <fleet-name>

# Deploy to specific device
balena push <device-uuid>
```

Cron execution flow: `start.sh` → sets up cron → cron calls `run-update.sh` → calls `update-display.py`.

## Architecture

Two Docker services in `docker-compose.yml`:
- **inkyshot** — main app (Python 3.7, Debian, Balena base image)
- **wifi-connect** — captive portal for WiFi provisioning (runs as root with dbus)

### Core Logic (`inkyshot/update-display.py`)

Single-file app. Key flow:
1. Reads env vars for mode, font, location config
2. If `MODE=weather` or `MODE=alternate` (and timer elapsed): fetches weather from `api.met.no`, renders weather icon + temp
3. Otherwise: fetches quote from `theysaidso.com` API
4. Renders text with auto-sizing font selection using Pillow
5. Writes to display via `inky` lib (or Waveshare driver from `lib/` if `WAVESHARE=1`)
6. If `MODE=alternate`: stores last mode timestamp to disk (`/data/last_shown`)

Display drivers:
- Default: `inky` library (Pimoroni Inky pHAT)
- `WAVESHARE=1`: uses `lib/epd2in13_V2.py` + `lib/epdconfig.py`

### Key Environment Variables

| Var | Values | Notes |
|-----|--------|-------|
| `MODE` | `quote`, `weather`, `alternate` | `alternate` switches between modes |
| `FONT` | `AmaticSC`, `FredokaOne`, `HankenGrotesk`, `Intuitive`, `SourceSerifPro`, `SourceSansPro`, `Caladea`, `Roboto`, `Grand9KPixel` | Font files in `inkyshot/fonts/` |
| `UPDATE_HOUR` | 0–23 | Hour for daily cron update |
| `TZ` | IANA timezone | e.g., `Africa/Johannesburg` |
| `WEATHER_LOCATION` | string or `LATLONG` | Falls back to IP geo |
| `SCALE` | `C`, `F` | Temperature unit |
| `ROTATE` | any value | Rotates display 180° |
| `WAVESHARE` | `1` | Switches display driver |
| `ALTERNATE_FREQUENCY` | minutes | How often alternate mode switches |
| `FONT_SIZE` | integer | Override max font size |
| `TheySaidSo_Api_Secret` | string | Optional paid API key |

### Fonts & Icons

- Fonts: `inkyshot/fonts/*.ttf` — one TTF per font variant
- Weather icons: `inkyshot/weather-icons/` — PNG files named by weather symbol code from met.no API

## Deployment

Balena Cloud manages deployment. `balena.yml` defines app metadata and default env vars. CI/CD uses `.github/workflows/flowzone.yml` (product-os/flowzone action) — triggers on PRs and pushes to master.

Version tracked in `VERSION` file at repo root.
