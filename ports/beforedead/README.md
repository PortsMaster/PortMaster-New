## Notes

Thanks to [NeoTron Games](https://neotron-games.blogspot.com/2010/09/before-we-were-dead.html) (Daniel Eriksson and Marcus Fredriksson) for Before We Were Dead, an underwater role-playing game where your choice of fish, its powers and the companions you make shape how you get through a dark, story-rich sea.

Runs on [BennuGD64](https://github.com/humbertodias/BennuGD64), a 64-bit fork of the BennuGD engine. The source code is GPL-2.0-or-later, the graphics and music are CC BY-SA 3.0.

## Controls

| Button | Action |
|--|--|
| Left Analog / D-Pad | Swim (Up) / turn (Left, Right) |
| A | Talk / confirm |
| B | Use power |
| X | Item selection |
| Y | Use item |
| L1 | Power selection |
| R1 | Companion orders |
| L2 | Volume down |
| R2 | Volume up |
| Start | Options / save menu, skip intro |
| Select | Log |

Name entry: Up/Down picks a letter, Right adds it, Left clears the name, A confirms.

## Compile

The game's source (`Before.prg`) and data ship in the official GNU/Linux release, `Before_Linux_1.1.zip`, linked from the [NeoTron Games page](https://neotron-games.blogspot.com/2010/09/before-we-were-dead.html) (MediaFire mirror). The patches below are in this folder's `patches/`.

### 1. SDL 3.4

BennuGD64 and SDL3_mixer 3.2 need SDL 3.4 or newer to build against. At runtime the port ships the [sdl3-sdl2-backend](https://github.com/bmdhacks/SDL/tree/sdl2-backend) `libSDL3.so.0` shim instead, which runs on the device's own SDL2.

```bash
git clone --depth 1 -b release-3.4.14 https://github.com/libsdl-org/SDL.git SDL3
cd SDL3 && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/sdl3-prefix \
  -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF
make -j$(nproc) && make install
cd ../..
```

### 2. SDL3_mixer (WAV + Ogg Vorbis only)

```bash
git clone --depth 1 -b release-3.2.4 https://github.com/libsdl-org/SDL_mixer.git SDL3_mixer
cd SDL3_mixer && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/sdl3-prefix \
  -DCMAKE_INSTALL_PREFIX=$HOME/sdl3-prefix -DBUILD_SHARED_LIBS=ON \
  -DSDLMIXER_VENDORED=OFF -DSDLMIXER_TESTS=OFF -DSDLMIXER_EXAMPLES=OFF \
  -DSDLMIXER_AIFF=OFF -DSDLMIXER_VOC=OFF -DSDLMIXER_AU=OFF -DSDLMIXER_FLAC=OFF \
  -DSDLMIXER_GME=OFF -DSDLMIXER_MOD=OFF -DSDLMIXER_MP3=OFF -DSDLMIXER_MIDI=OFF \
  -DSDLMIXER_OPUS=OFF -DSDLMIXER_VORBIS_VORBISFILE=OFF -DSDLMIXER_VORBIS_TREMOR=OFF \
  -DSDLMIXER_WAVPACK=OFF -DSDLMIXER_VORBIS_STB=ON -DSDLMIXER_WAVE=ON
make -j$(nproc) && make install
cd ../..
```

### 3. sdl3-sdl2-backend shim (shipped as `libSDL3.so.0`)

`sdl3-sdl2-backend-keep-sdl2-loaded.patch` stops the shim from unloading SDL2 on video shutdown while SDL2's audio thread is still running, which segfaults on exit.

```bash
git clone --recursive https://github.com/bmdhacks/SDL.git -b sdl2-backend sdl3-sdl2-backend
git clone https://github.com/KhronosGroup/SPIRV-Cross.git
cd sdl3-sdl2-backend
git checkout 6057d79
git apply ../patches/sdl3-sdl2-backend-keep-sdl2-loaded.patch
mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-march=armv8-a" \
  -DSDL_SDL2_BACKEND=ON \
  -DSDL_SPIRV_CROSS_DIR=$PWD/../../SPIRV-Cross \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=OFF \
  -DSDL_PIPEWIRE=OFF -DSDL_PULSEAUDIO=OFF -DSDL_ALSA=OFF \
  -DSDL_SNDIO=OFF -DSDL_OSS=OFF -DSDL_JACK=OFF \
  -DSDL_OFFSCREEN=OFF -DSDL_DUMMYVIDEO=OFF \
  -DSDL_DUMMYAUDIO=OFF -DSDL_DISKAUDIO=OFF \
  -DSDL_VULKAN=OFF -DSDL_GPU=ON -DSDL_RENDER_GPU=ON \
  -DSDL_UNIX_CONSOLE_BUILD=ON
make -j$(nproc)
cd ../..
```

### 4. BennuGD64

```bash
git clone https://github.com/humbertodias/BennuGD64.git
cd BennuGD64
git checkout 7cefa4a
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/sdl3-prefix \
  -DBENNUGD_BUNDLE_DEPS=OFF -DUSE_LIBDES=ON -DSTATIC_MODULES=ON
make -j$(nproc)
cd ../..
```

### 5. The game

`before-portmaster.patch` changes the tutorial text from keyboard keys to gamepad buttons and loads `controls.png` in place of the keyboard controls picture (graph 421). `make_controls.py` builds `controls.png` from the original picture's companion-orders diagram plus a button legend drawn in Bennu's built-in font.

```bash
unzip Before_Linux_1.1.zip
cd Before_Linux
tr -d '\r' < Before.prg > Before.prg.lf && mv Before.prg.lf Before.prg
patch -p1 < ../patches/before-portmaster.patch
python3 ../patches/make_controls.py Graphics.fpg ../BennuGD64/modules/libfont/libfont.c controls.png
../BennuGD64/build/core/bgdc/src/bgdc Before.prg
```

This produces `Before.dcb` (the compiled game) and `controls.png`. The interpreter is `BennuGD64/build/core/bgdi/src/bgdi`.
