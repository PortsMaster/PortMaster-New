## Notes

MiceAmaze is a free video game that features a maze with mice and snakes.  Place your arrows to guide mice to your house, but watch out for snakes and sick mice.  The Eagle can be obtained with a Gold Mouse which will protect your house from those pesky snakes.

Source: [Slayer366](https://github.com/Slayer366/miceamaze)

Forked from: [River Champeimont](https://github.com/rchampeimont/miceamaze)

Transitioned Micamaze to SDL2/SDL2_mixer/SDL2_ttf/stb_image (from SDL1/SDL_mixer/GLC/SOIL (SOIL called libX11)).
Removed X11 requirement.
Added numeric keys for mouse player as an alternative for the mouse wheel.
Reduced images from 439x439 (NPOT) to 64x64 (the maze squares are still smaller than this).
Reducing the sprite images reduced file size and improved sprite scaling (downscaling, that is).
Re-worked the code and Makefile for building on Linux and font rendering to be GL4ES compatible.

## Controls (2 thumbstick devices)

| Button | Action |
|--|--|
|Select/L2|Esc/Quit|
|D-Pad|Move keyboard player's cursor|
|A, B, X, Y|Place keyboard player's arrows|
|Left Analog|Move mouse cursor (+Mouse player)|
|R1|Invoke menu buttons/Place mouse player's arrows while moving cursor|
|Right Analog|Place mouse player's arrows|

## Controls (1 thumbstick devices)

| Button | Action |
|--|--|
|Select/L2|Esc/Quit|
|D-Pad|Move mouse cursor (+Mouse player)|
|A, B, X, Y|Place mouse player's arrows|
|Left Analog|Move mouse cursor (+Mouse player)|
|R1|Invoke menu buttons/Place mouse player's arrows while moving cursor|

## Controls (stick-less devices)

| Button | Action |
|--|--|
|Select/L2|Esc/Quit|
|D-Pad|Move mouse cursor (+Mouse player)|
|A, B, X, Y|Place mouse player's arrows|
|R1|Invoke menu buttons/Place mouse player's arrows while moving cursor|

## Compile

```shell
git clone https://github.com/Slayer366/miceamaze
cd miceamaze
make -j$(nproc)
```
