# Fetcher Project Documentation

## Overview
File downloader for ROCKNIX that fetches ROM files from various sources (Myrient, Redump, GitHub) and downloads them to `/storage/roms/[platform]/`.

## Project Structure

```
fetcher/
├── fetcher.py           # Main file fetcher - lists files from URLs
├── downloader.py        # Downloads files from URLs
├── download.py          # ROM collection viewer (CLI tool)
├── get_platforms.py     # Exports platform list for Lua UI
├── port.json           # Port configuration
├── fetcher.sh          # Shell wrapper script
├── conf/               # Configuration files
├── downloaderui/       # LÖVE (Love2D) UI
│   ├── main.lua        # Main UI screen
│   ├── main_light_theme.lua  # Light theme
│   ├── main_dmg_theme.lua   # DMG (Game Boy) theme
│   ├── osk.lua         # On-screen keyboard
│   ├── conf.lua        # LÖVE config
│   ├── push.lua        # Screen scaling library
│   ├── timer.lua       # Timer utilities
│   ├── input.lua       # Input handling
│   ├── push.lua        # Display library
│   └── assets/
│       └── fonts/
│           └── pixely.ttf
└── libs/              # LÖVE libraries
```

## Key Files

### fetcher.py
- Lists files from platform URLs
- Supports Myrient, Redump, and GitHub sources
- Uses caching in `/tmp/file_cache/`
- Parses HTML and GitHub JSON embedded data

**PLATFORM_URLS format:**
```python
PLATFORM_URLS = {
    "Platform Name": "https://source.com/path/"
}
```

### downloader.py
- Downloads files from URLs
- Supports parallel chunk downloads for speed
- Handles GitHub raw URL conversion
- Saves to `/storage/roms/[folder]/`

**URL Handling:**
- GitHub tree URLs: `https://github.com/user/repo/tree/main/folder/` → `https://raw.githubusercontent.com/user/repo/main/folder/filename`
- GitHub blob URLs: `https://github.com/user/repo/blob/main/folder/file.png` → `https://raw.githubusercontent.com/user/repo/main/folder/file.png`

### UI (downloaderui/)
- LÖVE framework UI for ROCKNIX
- Screens: Platform list, File list, Download progress
- Themes: Light theme, DMG (Game Boy) theme
- OSK: On-screen keyboard for search

## GitHub Integration

### Adding GitHub Folders
Add to `fetcher.py` PLATFORM_URLS:
```python
PLATFORM_URLS = {
    "pico-8": "https://github.com/amosjerbi/fetcher/tree/main/pico-8",
    "my-roms": "https://github.com/username/repo/tree/main/roms",
}
```

### How It Works
1. Fetcher parses GitHub folder page HTML
2. Extracts file list from embedded JSON (`<script type="application/json" data-target="react-app.embeddedData">`)
3. Downloader converts tree URL to raw URL for downloading

## Testing

### Local Testing
```bash
cd fetcher
python3 fetcher.py pico-8          # List files
python3 downloader.py pico-8 "file" # Download file
```

### Remote Testing (ROCKNIX)
```bash
sshpass -p "rocknix" ssh -o StrictHostKeyChecking=no root@YOUR_IP_ADDRESS
cd /storage/roms/ports/amos_fetcher
python3 fetcher.py pico-8
```

### Syncing Changes
```bash
sshpass -p "rocknix" scp fetcher.py downloader.py root@YOUR_IP_ADDRESS:/storage/roms/ports/amos_fetcher/
```

## Cache
- Location: `/tmp/file_cache/`
- Expiry: 1 hour (3600 seconds)
- Clear cache: `rm -f /tmp/file_cache/*.json`

## Troubleshooting

### HTTP 404 Errors
- Check if GitHub repo/branch exists
- Verify URL format (use `/tree/` for folders, not `/blob/`)

### Empty File Lists
- Clear cache: `rm -f /tmp/file_cache/[platform].json`
- Check network connectivity
- Verify URL is accessible

### Download Failures
- Check `/storage` is writable
- Verify file path format
- Check retry logic (3 retries with backoff)

## Lua Color Picker
Located at `lua-color-picker.html` - useful for editing UI colors.

**Colors in UI files:**
- `main_light_theme.lua`: Main theme colors
- `osk.lua`: Keyboard colors
- `main_dmg_theme.lua`: DMG theme colors

**Format:** `{R, G, B}` values from 0.0 to 1.0

## Screen Dimensions
- Default: 640x480
- Configured in `main.lua` lines 6-7
- Also set in `conf.lua` for window size
