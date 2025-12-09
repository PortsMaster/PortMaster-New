## Notes

Everything is included and ready to run.

If the mouse speed needs adjusting, edit OpenTTD.sh and adjust it in the "# Set mouse speed based on screen resolution" section.

Thanks to [OpenTTD](https://github.com/OpenTTD/OpenTTD) for this open source version that decently mimics Transport Tycoon Deluxe!

Originally ported by Cebion and Romadu.  OpenTTD had/has a bug that broke the port with newer versions of SDL2.
Ported again from scratch with v13.4 by Slayer366.  Commented out a line in the code that caused SDL2 breakage.

NOTE: v14.0 and v14.1 won't work (even on a Raspberry Pi) as the code has undergone several changes which cause the game to crash at launch or even generate a display at all.  It is unknown if newer versions of OpenTTD will address this issue.

</br>

## Controls

| Button | Action |
|--|--| 
|D-Pad|Move screen|
|L-stick/R-stick|Move mouse|
|B|Slow mouse down|
|A/L1/R1/L2/R2|Mouse click|

</br>

## Stickless devices

| Button | Action |
|--|--| 
|D-Pad|Move mouse|
|B|Slow mouse down|
|A/L1/R1|Mouse click|
|L2/R2|Zoom|
|X|Close window|

</br>

## Compile

Extract the contents of OpenTTD-13.4-src.7z to openttd-13.4/
Edit openttd-13.4/src/video/sdl2_v.cpp
Find the line SDL_SetHint(SDL_HINT_FRAMEBUFFER_ACCELERATION, "0"); and comment it out with // if it isn't already.
Save changes.

```shell
cd openttd-13.4
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j4
```