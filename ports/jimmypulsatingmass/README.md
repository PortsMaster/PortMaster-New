# Jimmy and the Pulsating Mass

## Thanks

Thanks to Kasey Ozymy for creating Jimmy and the Pulsating Mass and providing an mkxp build.

## Installation

1. Purchase Jimmy and the Pulsating Mass from [Steam](https://store.steampowered.com/app/706560/Jimmy_and_the_Pulsating_Mass/) or [itch.io](https://housekeepinggames.itch.io/jimmy-and-the-pulsating-mass)
2. Download the **mkxp version** (not the Legacy version)
3. Copy the contents of the `Jimmy and the Pulsating Mass mkxp` folder into `ports/jimmypulsatingmass/gamedata/`
4. Required files: `Game.rgss3a`, `Game.ini`, `my_win32_wrapper.rb`, `Audio/` folder, `Fonts/` folder

## Controls

| Button | Action |
|--------|--------|
| D-Pad / Left Stick | Move / Navigate menus |
| A (South) | Confirm / Interact |
| B (East) | Cancel |
| X (West) | Transformation menu |
| Y (North) | Special action |
| L1 | Previous page |
| R1 | Next page |
| L2 | Menu / Back |
| R2 | Run |

## Technical Notes

- Uses falcon_mkxp (mkxp-freebird) runtime for RPG Maker VX Ace
- Native resolution: 544x416, scaled to device display
- RGSS version 3
- Preloads my_win32_wrapper.rb for Win32API compatibility on Linux
