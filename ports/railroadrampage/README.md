## Notes

Thanks to [NeoTron Games](https://github.com/Cebion/railroad-rampage) for Railroad Rampage, a tower-defence/arcade hybrid where you build turrets on a moving train and personally fire, aim and drag them around to fend off 20 waves of bandits.

Runs on [BennuGD64](https://github.com/humbertodias/BennuGD64), a 64-bit fork of the BennuGD engine.

## Controls

| Button | Action |
|--|--|
| Left Analog / D-Pad | Move cursor |
| A | Left click (select / activate) |
| B | Right click (deselect) |
| X | Hold to slow the cursor |
| L1 | Volume down |
| R1 | Volume up |
| Start | Pause |
| Back | Main menu / quit from main menu |

## Compile

Game data and source (`RailroadRampage.prg`) are archived at https://github.com/Cebion/railroad-rampage.

### 1. SDL 3.4

BennuGD64 and SDL3_mixer 3.2 need SDL 3.4 or newer to build against. At runtime the port ships the [sdl3-sdl2-backend](https://github.com/bmdhacks/SDL/tree/sdl2-backend) `libSDL3.so.0` shim instead, which runs on the device's own SDL2.

```bash
git clone --depth 1 -b release-3.4.14 https://github.com/libsdl-org/SDL.git SDL3
cd SDL3 && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/sdl3-prefix \
  -DSDL_SHARED=ON -DSDL_STATIC=OFF -DSDL_TESTS=OFF -DSDL_EXAMPLES=OFF
cmake --build . --parallel $(nproc)
cmake --install .
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

`patches/sdl3-sdl2-backend-fixes.patch` forwards SDL2 mouse motion as absolute coordinates (relative only in relative mouse mode) and stops the shim from unloading SDL2 on video shutdown while SDL2's audio thread is still running, which segfaulted on exit.

```bash
git clone --recursive https://github.com/bmdhacks/SDL.git -b sdl2-backend sdl3-sdl2-backend
git clone https://github.com/KhronosGroup/SPIRV-Cross.git
cd sdl3-sdl2-backend
git checkout 6057d79
git apply ../patches/sdl3-sdl2-backend-fixes.patch
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

### 4. BennuGD64 and the game

`patches/bennugd64-mouse-window-scale.patch` maps mouse coordinates from the fullscreen window back to the game's 320x240 screen, so the cursor stays inside the game area.

```bash
git clone https://github.com/humbertodias/BennuGD64.git
cd BennuGD64
git checkout 7cefa4a
git apply ../patches/bennugd64-mouse-window-scale.patch
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$HOME/sdl3-prefix \
  -DBENNUGD_BUNDLE_DEPS=OFF -DUSE_LIBDES=ON -DSTATIC_MODULES=ON
make -j$(nproc)
cd ../..

git clone https://github.com/Cebion/railroad-rampage.git
cd railroad-rampage
../BennuGD64/build/core/bgdc/src/bgdc RailroadRampage.prg
```

This produces `bgdi` (the interpreter) and `RailroadRampage.dcb` (the compiled game).
