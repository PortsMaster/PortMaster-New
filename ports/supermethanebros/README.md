## Notes

Thanks to [szymor](https://github.com/szymor/methane-sdl) for this SDL version of Super Methane Brothers!
The port is based on Spot's SDL1 source codes (see OS4Depot.net).

Tap the fire button to shoot gas from the gun and trap a baddie in a gas bubble.
Press and hold the fire button to suck a trapped (gassed) baddie into the gun.
Release the fire button to release the trapped baddie from the gun.
Shoot baddies at the wall to destroy them.

## Controls

| Button | Action |
|--|--| 
|dpad|movement|
|left analog|movement|
|A|Jump|
|B|Fire|
|Select|Quit|

## Compile

```shell
git clone https://github.com/szymor/methane-sdl
# edit methane-sdl/source/gp2x/SDL_framerate.h
# change #define FPS_DEFAULT from 50 to 31 (the sweet spot)
# save and exit
cd methane-sdl/source/amigaos4
make -j4
```
