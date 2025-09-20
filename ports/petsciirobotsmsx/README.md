## Notes

[openMSX](https://github.com/openMSX/openMSX)
[MSXdev23](https://www.msxdev.org/2023/09/19/msxdev23-18-attack-of-the-petscii-robots/)

Thanks to Robosoft and the MSXdev Team for making this free version of Attack of the PETSCII Robots!
Thanks to David Murray for the original game!

Place the following BIOS files in the 'petsciirobotsmsx/share/systemroms' directory:
fs-a1gt_firmware.rom
fs-a1gt_kanjifont.rom
yrw801.rom

## Controls

| Button | Action |
|--|--| 
|D-Pad/Left Analog|Move|
|A, B, X, Y/Right Analog|Shoot|
|L1|Search|
|R1|Move Object|
|L2|Change Weapon|
|R2|Change Inventory Item|
|Start/L3/R3|Enter/Make selection/Use item|
|Select|Toggle Map|

## Compile

Download https://github.com/openMSX/openMSX/archive/refs/tags/RELEASE_19_1.tar.gz
Extract the contents of RELEASE_19_1.tar.gz
edit openMSX-RELEASE_19_1/build/libraries.py and replace  header = '<SDL_ttf.h>'  with  header = '<SDL2/SDL_ttf.h>'
save and exit
You may need to install a newer g++ compiler and set it as the default before building.  GLEW also needs to be v2.1.0.

```shell
sudo apt install libsdl2-dev libsdl2-ttf-dev libpng-dev zlib1g-dev tcl-dev libglew-dev libogg-dev libvorbis-dev libtheora-dev g++-10
cd openMSX-RELEASE_19_1
./configure
make -j4
```