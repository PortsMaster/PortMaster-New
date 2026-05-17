## Installation

Purchase *Rising Dusk* on [Steam (App 848930)](https://store.steampowered.com/app/848930/Rising_Dusk/) and install it on your PC.

### Automatic (recommended)

The port includes a preparation script that finds your Steam installation and copies the right files automatically.

**Windows** — double-click `prepare_port.bat` (requires [Python 3](https://www.python.org/downloads/), tick *Add to PATH* during install).

**macOS / Linux** — run in a terminal:
```
python3 prepare_port.py
```

The script creates a `risingdusk_ready/` folder. Copy its **contents** (not the folder itself) into `ports/risingdusk/` on your device, merging with the existing files.

### Manual

Copy these files from your Steam installation folder into `ports/risingdusk/`:

```
Rising Dusk.exe
assets/
lime.ndll
steamwrap.ndll
```

> **Do not copy `steam_api.dll` or `steam_api64.dll`.** The port provides offline-compatible replacements for those files (Goldberg Steam Emulator, MIT licence).

---

## System requirements

This port runs the original Windows executable through Wine + Box64 and requires a CFW that ships these tools. Tested on **ROCKNIX**; should also work on **JELOS / KNULLI** builds that include Wine.

Will **not** work on muOS, ArkOS, MinUI, or other CFWs that do not provide Wine and Gamescope.

---

## Controls

| Button | Action |
|---|---|
| Left Stick | Move (dead-zone filtered) |
| D-Pad | Move |
| A / B / X / Y | In-game actions |
| Start | Menu / Escape |
| Select | Menu / Escape |

The left stick is mapped to arrow keys via `gptokeyb` with a 15 % dead zone, which prevents stick drift on the Retroid Pocket Flip 2 and similar devices.

---

## Technical notes

| Component | Details |
|---|---|
| Runtime | Wine via Box64 (ships with ROCKNIX) |
| Display | Gamescope fullscreen at native resolution |
| Audio | PipeWire (preferred) or ALSA fallback, 4096-frame buffer at 44100 Hz |
| Input | gptokeyb dead-zone + InputPlumber button remaps (ROCKNIX only, skipped automatically on other CFWs) |
| Steam API | Goldberg Steam Emulator — offline play, no Steam required |
| Wine prefix | `$HOME/risingdusk_wine/` — always on an ext4 partition |

On first launch, Wine initialises its prefix (~30 s). Subsequent launches are immediate.  
The game log is written to `ports/risingdusk/log.txt`.

---

## Known issues

- **Menu launch:** On some ROCKNIX builds the game must be launched from a terminal rather than EmulationStation. Run `/roms/ports/RisingDusk.sh` directly if the menu entry does not work.
- **Audio at very low volume:** Faint artefacts may be audible due to the Wine/Box64 audio pipeline. This is normal at very low volume levels.

---

## Credits

Port by [Clara Ogalla Moreno (Crazyx98)](https://github.com/clarax98).  
[Box64](https://github.com/ptitSeb/box64) by ptitSeb.  
[Wine](https://www.winehq.org/) — the Wine project.  
[Gamescope](https://github.com/ValveSoftware/gamescope) — Valve.  
[Goldberg Steam Emulator](https://gitlab.com/Mr_Goldberg/goldberg_steam_emu) — Mr_Goldberg (MIT licence).  
[PortMaster](https://portmaster.games) — the PortMaster team.
