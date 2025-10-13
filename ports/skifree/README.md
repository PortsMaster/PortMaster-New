## Notes

Thanks to https://github.com/yuv422/skifree_decomp for the repo of the decompiled SkiFree in Assembly with comparison to C
Thanks to https://github.com/jeff-1amstudios/skifree_sdl and https://github.com/brooksytech/skifree_sdl for the initial conversion to SDL2.

Source: https://github.com/Slayer366/skifree_sdl

Ready to run

## Controls

| Button | Action |
|--|--| 
|Select|Quit|
|Start|New Game|
|A|Immediate Down-right|
|B|Jump|
|X|Slight Jump|
|Y|Immediate Down-left|
|L1|Speed Boost|
|L2|Immediate Left-face|
|R2|Immediate Right-face|
|R1|Jump|
|D-Pad|Move (as with keyboard arrow keys)|
|Left Analog|Mouse cursor for control|
|Right Analog|Mouse cursor for control|

## Compile

```shell
sudo apt install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev
git clone https://github.com/Slayer366/skifree_sdl
cd skifree_sdl
curl -Lo /tmp/ski32_resources.zip -k https://archive.org/download/ski32_resources/ski32_resources.zip
unzip -d resources /tmp/ski32_resources.zip
chmod +x ./build.sh
./build.sh

#OR

mkdir build
cd build
cmake ..
make -j4
```