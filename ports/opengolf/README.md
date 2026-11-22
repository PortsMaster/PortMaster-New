# Open Golf

## Notes

A 3D minigolf game with 20 holes. Thanks to [Michael Gerdes](https://github.com/mgerdes/Open-Golf) for creating the game (MIT). Models are from [Kenney](https://kenney.nl/assets) (CC0).

This port builds the `portmaster` branch of [monkeyx-net/Open-Golf](https://github.com/monkeyx-net/Open-Golf/tree/portmaster), which runs the game on SDL2 with OpenGL ES 3.0 and adds gamepad controls. Move between menu buttons with the D-pad or left stick and press A or Start. To putt, hold A, pull back with the D-pad or left stick to set the direction and power, and release A.

Progress is saved in `storage.json` in the port folder.

## Controls

| Button | Action |
|--|--|
| A | Aim/OK |
| B | Back |
| L1 | Cam ← |
| R1 | Cam → |
| L2 | Zoom in |
| R2 | Zoom out |
| Start | Start / pause |
| Select | Exit (+Start) |
| D-pad | Menus / aim |
| Left stick | Menus / aim |
| Right stick | Camera |

Hold A to grab the ball, pull back with the D-pad or left stick, and release A to putt.

## Compile

`cmake -S . -B cmake-build -DGOLF_PORTMASTER=ON -DCMAKE_BUILD_TYPE=Release && cmake --build cmake-build`


Built with [PortMaster-Build-Templates](https://github.com/monkeyx-net/PortMaster-Build-Templates) from [monkeyx-net/Open-Golf](https://github.com/monkeyx-net/Open-Golf). The recipe folder [recipes/ports/opengolf](https://github.com/monkeyx-net/PortMaster-Build-Templates/tree/main/recipes/ports/opengolf) holds `build.sh`, which reads `recipe.json` and applies the patches and files in that folder before running the build command:

```sh
cmake -S . -B cmake-build -DGOLF_PORTMASTER=ON -DCMAKE_BUILD_TYPE=Release
```
