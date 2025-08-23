## Notes

Thanks to [Mark B. Allan and community contributors](https://sourceforge.net/projects/chromium-bsu/) for making this game and making it open source!

## Controls

| Button | Action |
|--|--| 
|D-pad|Movement / Menu navigation|
|Left analog stick|Movement|
|Start|Enter|
|Select|ESC / Pause|
|A|Fire|
|Y|Self-destruct (press twice)|

## Compile

```shell
# From stock ubuntu 24.04 aarch64 image
# Install prereqs
apt-get update && apt-get install git autoconf automake gettext pkg-config autoconf-archive binutils libglc-dev libgl1-mesa-dev libsdl1.2-dev libsdl-image1.2-dev libglu1-mesa-dev autopoint build-essential libglc0 zlib1g libpng-dev libsdl2-image-dev libsdl2-mixer-dev

# Build GLU from source
git clone https://github.com/ptitSeb/GLU.git && cd GLU
./configure && make && cd ..

# Build game
git clone https://git.code.sf.net/p/chromium-bsu/code chromium-bsu && cd chromium-bsu
./autogen.sh && ./configure && make && cd ..

# In my case I had to build gl4es and package libGL.so.1 with the game.
# That might not be necessary if the device has a reliable gl4es binary already.
git clone https://github.com/ptitSeb/gl4es.git && cd gl4es
mkdir build && cd build
cmake .. -DNOX11=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="-march=armv8-a+crc -mtune=cortex-a53 -O2 -pipe" && make && cd ../..

# I also had to package libGLC, libGLEW, and libGLU with the game.
# I still don't know why the non-installed version of the game expects the png/wav data at
#  ../data relative to the active directory, but for now I've got around this by
#  moving to $GAMEDIR/bin prior to running the game, and putting the data dir parallel with
#  the bin dir.
```
