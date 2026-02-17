# ROM Playtime Viewer

Dedicated playtime tool for ROCKNIX. It scans local ROMs in `/storage/roms`, lists them by platform, and shows playtime estimates for the selected game using open datasets.

## Features
- Local ROM indexing with cache (`/tmp/file_cache/rom_index.json`)
- Playtime lookup from PlayMyData + HLTB scraped dataset (no API key)
- LÖVE (Love2D) UI with search and on-demand playtime screen

## Project Layout
```
playtime/
  rom_index.py        # Local ROM scanner + cache
  playtime.py         # Playtime lookup (streamed, cached results)
  downloaderui/       # LÖVE UI
  conf/               # Configs
  libs/               # LÖVE libs
playtime.sh           # PortMaster/ROCKNIX launcher
```

## Key Files
- `playtime/rom_index.py`: Scans `/storage/roms/*` and builds a cached index
- `playtime/playtime.py`: Playtime lookup for a given platform + ROM filename
- `playtime/downloaderui/`: UI screens, themes, and input handling
- `playtime.sh`: PortMaster/ROCKNIX launcher script

## UI Usage (ROCKNIX)
Run the PortMaster launcher:
```bash
./playtime.sh
```

**Controls**
- Platform list: `A` open ROMs, `Y` refresh index, `Start` exit
- ROM list: `A` playtime, `X` search, `Y` clear search, `B` back, `Start` exit
- Playtime screen: `B` back, `Start` exit

## CLI Usage
Build or refresh ROM index:
```bash
python3 playtime/rom_index.py --refresh
```

Get platform list:
```bash
python3 playtime/rom_index.py --platforms
```

Get ROMs for a platform:
```bash
python3 playtime/rom_index.py --files "Game Boy"
```

Lookup playtime:
```bash
python3 playtime/playtime.py --playtime "Game Boy" "Tetris.zip"
```

## Cache
- ROM index: `/tmp/file_cache/rom_index.json`
- Playtime lookup results: `/tmp/file_cache/playtime_lookup_cache.json`

## Notes
- Only ROMs already on the device are shown.
- Playtime lookups stream open datasets and cache per-title results.
