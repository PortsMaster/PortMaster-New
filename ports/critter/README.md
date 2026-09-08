## Notes

Thanks to [Frank Becker / mooflu.com](https://github.com/mooflu/critter) for creating Critter (aka Critical Mass), a fast-paced arena shoot-'em-up in the vein of Galaxian.

## Controls

| Button | Action |
|--|--|
| Left Analog | Move |
| D-Pad | Move (digital) |
| A | Primary Fire |
| B | Confirm |
| X | Secondary Fire |
| Y | Tertiary Fire (Expert/Insane skill only) |
| L1 | Critter Board |
| L2 | Open On-Screen Keyboard (high-score name entry) |
| R1 | Change Context |
| Start | Pause |
| Back | Escape / Menu |

## Compile

sudo apt install zlib1g-dev libpng-dev libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libphysfs-dev libgles2-mesa-dev
git clone https://github.com/Cebion/critter.git
cd critter
touch resource.dat
mkdir build && cd build
cmake -DUSE_GLES=ON -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --parallel

`touch resource.dat` is needed because CMake lists it as a source file
unconditionally (for macOS bundling), even though the game itself falls back
to loading the raw `data/` directory at runtime when `resource.dat` is
missing.
