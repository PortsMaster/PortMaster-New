## Notes

**Chromium B.S.U.** is a fast-paced, top-down, arcade-style action shooter game. You progress through the game by destroying everything that you see on screen. There are a variety of 'power-ups' to assist you on the way. There is a big boss to destroy at the end of each level and there are various ships to destroy before you reach each boss.

You will lose a life for every ship that gets past you. You can gain extra lives by letting the Super Shield pass through the bottom of the screen.

With the exception of the (very weak) standard weapon, all other weapons lose ammo, so it's best to fire only when necessary.

If you self-destruct, you eject your weapons to be picked up by your next ship, and the ship's detonation kills every enemy on-screen.

## Acknowledgements

Thanks to [Mark B. Allan and community contributors](https://sourceforge.net/projects/chromium-bsu/) for making this game and making it open source!

Big thanks to the testers in the PortMaster discord for working through the kinks and making sure it's playable on supported devices, CFWs, and resolutions.

## Controls

| Button | Action |
|--|--| 
|D-pad|Movement / Menu navigation|
|Left analog stick|Movement|
|A|Fire / Menu OK|
|Y|Self-destruct (press twice)|
|R1|Fire|
|Start|Pause / Unpause|
|Start + Select|Exit game|

## Compile

```shell
# From stock ubuntu 24.04 aarch64 image
# Install prereqs
sudo apt-get update && sudo apt-get install git autoconf automake gettext pkg-config autoconf-archive binutils libglc-dev libgl1-mesa-dev libsdl1.2-dev libsdl-image1.2-dev libglu1-mesa-dev autopoint build-essential libglc0 zlib1g libpng-dev libsdl2-image-dev libsdl2-mixer-dev

# Build GLU from source
git clone https://github.com/ptitSeb/GLU.git && cd GLU
./configure && make && sudo make install && cd ..

# Build game
git clone https://github.com/BenJuan26/chromium-bsu.git && cd chromium-bsu
./autogen.sh && ./configure --disable-openal --disable-sdlmixer --enable-gamepad && make && cd ..

# In my case I had to build gl4es and package libGL.so.1 with the game.
# That might not be necessary if the device has a reliable gl4es binary already.
git clone https://github.com/ptitSeb/gl4es.git && cd gl4es
mkdir build && cd build
cmake .. -DNOX11=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_C_FLAGS="-march=armv8-a+crc -mtune=cortex-a53 -O2 -pipe" && make && cd ../..

# I also had to package libGLC, libGLEW, and libGLU with the game.
```
