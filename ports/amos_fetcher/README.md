<p align="center">
  <img src="/themes/fetcher_1.png" alt="demo" width="320" />
  &nbsp;&nbsp;&nbsp;
  <img src="/themes/fetcher_4.png" alt="demo" width="320" />
  &nbsp;&nbsp;&nbsp;
  <img src="/themes/fetcher_5.png" alt="pico" width="320" />
</p>

# Fetcher

A file downloading and management tool for retro handhelds that run Rocknix system.

## How to Use

1. Edit fetcher.py with your own links in line 15
2. Make sure to add your links in PLATFORM_URLS = {}
3. If a directory doesn't exist it'll be created

### Installation
1. Copy the entire `fetcher` directory to your device's ports folder (usually `/roms/ports/`)
2. Copy `fetcher.sh` to the same location
3. Run Fetcher from ports menu

**Features:**
- Multi-platform file downloading from various sources
- Search files using LÖVE2D-based user interface with on-screen keyboard (press X for search)
- Quickly browse by pressing L1/R1 or press and hold down

**Components:**
- `fetcher.py` - Main file fetching engine with platform support
- `downloaderui/` - LÖVE2D-based graphical interface
- `fetcher.sh` - PortMaster launcher script
- `download.py` & `downloader.py` - Download management modules
- `main.lua` - Change UI to your liking using Font sizes & Color palette

**Troubleshooting:**
- Don't see your list? run this in terminal to clear cache:
  ```
  sshpass -p "rocknix" ssh -o StrictHostKeyChecking=no root@192.168.0.0 "rm -rf /tmp/file_cache /tmp/platforms.json /tmp/file_list.json"
  ```

### Pico-8 Game
A simple Pico-8 game created to showcase Fetcher (Created by me, thank you very much ❤️).

**Location:** `pico-8/`
- `romnix.p8.png` - Pico-8 cartridge file
- `romnix.p8.png.zip` - Compressed cartridge

## Important Disclaimer

This tool is designed for downloading legally obtained files only. Users are solely responsible for ensuring they have the legal right to download and possess any files obtained through this software.

## License

Free to use for personal retro gaming purposes. Use at your own risk and in compliance with applicable laws.
