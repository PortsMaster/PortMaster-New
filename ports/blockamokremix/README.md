## Notes

Thanks to [Mode8fx](https://github.com/Mode8fx/blockamok/) for this remix of Blockamok and [Carl Riis](https://github.com/carltheperson/blockamok) for the original.

**Background**

Blockamok Remix is a significant update to Blockamok, a game originally made by Carl Riis to challenge himself to create a 3D game without any pre-made 3D engine or utilities.

This version adds many improvements including:

* Customizable gameplay settings
* Controller support + a new control scheme
* New visual settings
* Music and sound effects
* A full menu, title screen, instructions, etc.
* Scoring system polish
* High score saving
* Console ports
* Performance improvements for weaker hardware

## Controls

|Button|Action|
|--|--|
|Enter/Start|Fly|
|Back/Select|Options|
|Dpad/Joysticks|Move|

## Compile

```shell
git clone https://github.com/Mode8fx/blockamok.git
cd blockamok
mkdir build_linux && cd build_linux
export LDFLAGS=" -lm "
cmake ../ -DLINUX=ON -DFORCE_DRAW_OVERLAY=ON -DLOW_SPEC_BG=ON
    or
cmake ../ -DLINUX=ON -DFORCE_DRAW_OVERLAY=ON -DFORCE_DRAW_BG=ON 
make
```
