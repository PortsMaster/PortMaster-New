## Notes

Thanks to [Michael Welsh](https://github.com/Herschel) for porting Hypercycles to SDL2, and to
[Bob Hays](http://bobhays.com) for the original 1995 DOS game and for releasing its source under
GPLv3 in 2017.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick Up/Down | Accelerate / Decelerate |
| D-Pad / Left Stick Left/Right | Turn Left/Right |
| A | Confirm / Menu / Cycle Weapon Selection (in-game) |
| Back | Escape / Menu |
| L1 | Look Around |
| R1 | Fire |
| X | Wall Projector On/Off |
| Y | Select Radar Scope |
| Start + D-Pad Down | Open on-screen keyboard (save name entry) |

## Compile

git clone https://github.com/Herschel/hypercycles-sdl.git
cd hypercycles-sdl
premake5 gmake2
make
