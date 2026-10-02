## Notes

Thanks to the [Taisei Project](https://taisei-project.org/) team for this free and open-source Touhou Project fan game. The game code is MIT licensed; the soundtrack by Tuck V and the character portraits by afensorm are CC-BY 4.0.

Built from [taisei v1.4.6](https://github.com/taisei-project/taisei/releases/tag/v1.4.6) with the OpenGL ES 3.0 renderer. SDL3 is provided by the [sdl3-sdl2-backend](https://github.com/bmdhacks/SDL/tree/sdl2-backend) `libSDL3.so.0` shim, which runs on the device's own SDL2. The shim is built from commit `6057d79` with the same fixes patch as railroadrampage.

The game data ships as `data-part*.tar.gz` and is extracted on first launch. Saves, settings and replays are stored in `taisei/conf/`. The shader cache is stored in `taisei/cache/`; the first launch takes longer while it is built.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move |
| A | Shoot / confirm |
| X | Focus (slow movement) |
| L2 | Bomb |
| R2 | Special |
| B | Skip dialogue / back (in menus) |
| Start | Pause |
| Select + Start | Quit |

Buttons can be remapped in Options → Gamepad & Joystick options.

## Compile

See https://github.com/elderica/taisei-portmaster for the build script.
