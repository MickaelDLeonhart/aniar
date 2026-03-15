# aniar — Arabic Anime Streaming Tool

![Version](https://img.shields.io/badge/version-1.0.2-green)
![License](https://img.shields.io/badge/license-MIT-orange)
![Platform](https://img.shields.io/badge/platform-Linux%20|%20macOS-lightgrey)
![Shell](https://img.shields.io/badge/shell-bash-blue)

A terminal tool for streaming and downloading Arabic-dubbed anime directly from [Anime4Up](https://w1.anime4up.rest). No browser, no GUI, no Electron — just bash, curl, and mpv.

---

## Features

- Search anime by Arabic or English name
- Full episode list with multi-page support (1000+ episodes)
- Arrow key navigation between episode pages
- Auto-play next episode after current one ends
- Download single episodes or full series
- Smart caching — episode lists load once, then instantly
- Watch history tracking
- OVA and special episode detection
- Debug mode for troubleshooting
- Prioritizes fast and reliable sources (upload.is first)

---

## Dependencies

| Tool | Purpose |
|------|---------|
| `curl` | HTTP requests and scraping |
| `yt-dlp` | Video URL extraction and downloading |
| `mpv` | Video playback |
| `fzf` | Interactive fuzzy selection UI (optional but recommended) |

---

## Installation

```bash
# Clone and install
git clone https://github.com/MickaelDLeonhart/aniar.git
cd aniar
chmod +x aniar
sudo cp aniar /usr/local/bin/aniar
```

Or via install script:

```bash
curl -sL https://raw.githubusercontent.com/MickaelDLeonhart/aniar/main/install.sh | bash
```

---

## Usage

```bash
aniar                        # Interactive mode
aniar "detective conan"      # Search directly
```

### Episode Navigation (fzf)

| Key | Action |
|-----|--------|
| Type | Filter episodes by number |
| Right arrow | Next page |
| Left arrow | Previous page |
| Enter | Play selected episode |
| Esc | Cancel |

---

## Commands

```bash
aniar [QUERY]               # Search and play
aniar search QUERY          # Search only, no playback
aniar direct URL [TITLE]    # Play a direct episode URL
aniar continue "SERIES"     # Continue from last watched episode
aniar download QUERY        # Download full series
aniar download URL          # Download single episode
aniar history               # Show watch history
aniar config                # Open config file
aniar update                # Check for updates
aniar clean                 # Clear cache
aniar debug QUERY           # Run with debug output
aniar help                  # Show help
```

---

## Configuration

Config file is created automatically at `~/.config/aniar/config`.

```bash
aniar config   # opens in $EDITOR
```

Available options:

```bash
# Preferred video sources (tried in order)
# PREFERRED_SOURCES=("videa.hu" "drive.google.com" "ok.ru" "solidfiles.com")

# Video player
# DEFAULT_PLAYER="mpv"
# MPV_OPTIONS="--force-window=yes --keep-open=yes"

# Auto-play next episode after current one ends
# AUTO_NEXT=false

# Download directory
# DOWNLOAD_DIR="$HOME/Anime"

# Enable watch history
# TRACK_HISTORY=true
```

---

## How It Works

aniar scrapes Anime4Up for episode lists and video embed sources. Episodes are paginated at 48 per page and cached locally after the first fetch. Video sources are tried in priority order — upload.is first, then others, skipping known broken hosts. The resolved URL is passed directly to mpv with the correct Referer header so CDN servers accept the request.

---

## Maintenance

Anime4Up occasionally changes its HTML structure, especially after site redesigns. If something breaks, check the [Wiki](../../wiki) for a diagnosis guide and which functions to update.

---

## License

MIT
