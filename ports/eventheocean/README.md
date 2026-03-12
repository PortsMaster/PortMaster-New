# Even the Ocean

## Thanks

Thanks to [Analgesic Productions](https://twitter.com/han_tani) (Melos Han-Tani & Marina Kittaka) for creating Even the Ocean and open-sourcing the game code.

- Game repository: https://github.com/analgesicproductions/Even-The-Ocean-Open-Source

## Installation

1. Purchase Even the Ocean from [GOG](https://www.gog.com/game/even_the_ocean) or [Steam](https://store.steampowered.com/app/265470/Even_the_Ocean/)
2. Install the **Linux** version of the game
3. Copy the entire `gamedata` folder from the installation into `ports/eventheocean/` on your device
4. The port will automatically apply necessary patches on first launch

### GOG Linux

After downloading the GOG installer, extract it:
```
unzip even_the_ocean_*.sh -d eto_extracted/
```
The `gamedata` folder is inside `data/noarch/game/`.

### Steam Linux

Right-click the game in Steam > Properties > Local Files > Browse Local Files.
Copy the `gamedata` folder.

## What the port does

This port provides:
- A custom-compiled `lime-legacy.ndll` (the NME/Lime rendering engine) cross-compiled for aarch64 with:
  - KMSDRM video backend support
  - Software renderer scaled to device display (640x480)
  - Fullscreen and input fixes for handheld devices
- SDL2 shared library built with KMSDRM support
- Patched cutscene scripts to fix camera offset rendering on handheld displays
- A half-size storyteller image for the intro cutscene (optimized for 416x256 internal resolution)
- Button-to-keyboard mapping via gptokeyb

## Controls

| Button | Action |
|--------|--------|
| D-Pad  | Move / Navigate menus |
| A      | Confirm / Jump |
| B      | Cancel / Back |
| X      | Action |
| Y      | Map |
| L1     | Prev |
| R1     | Next |
| Start  | Enter / Pause |
| Select | Escape / Menu |

## Technical Notes

- Internal resolution: 416x256 (half of PC's 832x512), rendered via software renderer
- Display output: SDL_RenderSetScale to device resolution via KMSDRM
- The game uses HaxeFlixel + OpenFL + Lime Legacy (NME) runtime
- The `lime-legacy.ndll` is compiled from the Lime 2.9.0 legacy C++ source with aarch64 cross-compilation

## Known Issues

- Mayor cutscene map panning may not scroll correctly (map markers visible but camera pan disabled)
- Performance is adequate but not perfectly smooth on all devices

## Build Information

Built and tested on RG35XX H running muOS.

Cross-compiled on Ubuntu (WSL2) using `aarch64-linux-gnu-g++`.
