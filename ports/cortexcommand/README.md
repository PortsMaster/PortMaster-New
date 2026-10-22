## Notes

Thanks to [Data Realms](https://datarealms.com/) and the [Cortex Command Community Project](https://github.com/cortex-command-community/Cortex-Command-Community-Project) for Cortex Command, a side-scrolling action-strategy sandbox where every pixel of terrain and every soldier is physically simulated and can be blown apart.

The port renders with OpenGL ES 3 and runs on the [sdl3-sdl2-backend](https://github.com/bmdhacks/SDL/tree/sdl2-backend) `libSDL3.so.0` shim, which uses the device's own SDL2.

## Controls

| Button | Action |
|--|--|
| Left Analog | Move, up to jump, down to crouch, cursor in menus |
| Right Analog | Aim |
| D-Pad | Actor and weapon hotkeys, fine aim while holding X |
| A | Fire, select in menus |
| B | Pie menu, cancel the buy menu |
| X | Hold to aim |
| Y | Jump |
| L1 | Previous actor |
| R1 | Next actor |
| L2 | Pie menu |
| R2 | Fire |
| L3 | Toggle sprint |
| R3 | Prone |
| Start | Pause menu |
| Select | Back |
| Select + Start | Quit |

## Compile

Built in an Ubuntu 22.04 aarch64 chroot from upstream commit `ba5d0f2` with `gcc-12`. `patches/cortexcommand-portmaster.patch` adds a `gles` meson option (OpenGL ES 3 renderer, system SDL3 instead of the vendored static copy, compressed in-memory audio) and a few gcc-12/aarch64 build fixes. `patches/glibc-compat.h` pins two symbols to older versions so the binary needs only glibc 2.34 and GLIBCXX 3.4.29.

### 1. SDL 3.2 (build-time only)

```bash
git clone --depth 1 -b release-3.2.30 https://github.com/libsdl-org/SDL.git SDL3
cd SDL3 && mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 \
  -DSDL_SHARED=ON -DSDL_STATIC=ON
cmake --build . --parallel $(nproc)
cmake --install .
cd ../..
```

### 2. Cortex Command

```bash
apt install meson ninja-build gcc-12 g++-12 libgles-dev libflac-dev libminizip-dev liblz4-dev libpng-dev libtbb-dev
git clone https://github.com/cortex-command-community/Cortex-Command-Community-Project.git
cd Cortex-Command-Community-Project
git checkout ba5d0f2
git apply ../patches/cortexcommand-portmaster.patch
CC=gcc-12 CXX=g++-12 meson setup build-pm -Dgles=true -Dtracy_enable=false -Dtracy:tracy_enable=false \
  -Dinstall_data=false -Dinstall_runner=false -Db_lto=false -Db_ndebug=true \
  -DSDL3_image-3.2.4:jpg=disabled -DSDL3_image-3.2.4:tif=disabled -DSDL3_image-3.2.4:webp=disabled \
  -DSDL3_image-3.2.4:avif=disabled -DSDL3_image-3.2.4:jxl=disabled \
  -Dcpp_args="-include $PWD/../patches/glibc-compat.h" -Dc_args="-include $PWD/../patches/glibc-compat.h"
ninja -C build-pm
strip build-pm/CortexCommand
cd ..
```

### 3. sdl3-sdl2-backend shim (shipped as `libSDL3.so.0`)

`patches/sdl3-sdl2-backend-fixes.patch` forwards SDL2 mouse motion as absolute coordinates (relative only in relative mouse mode) and stops the shim from unloading SDL2 on video shutdown while SDL2's audio thread is still running.

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

### 4. Game data archives

The game decodes every sound fully into RAM, which needs well over 1GB with the original FLAC/OGG audio. `patches/convert-audio.sh` converts all audio to 96 kbps MP3, which the `gles` build keeps compressed in memory, and rewrites the `.ini`/`.lua` references. Needs `ffmpeg` with `libmp3lame`.

```bash
mkdir stage
rsync -a --exclude='*.xcf' --exclude='*.reapeaks' --exclude=Base.rte/Settings.ini Cortex-Command-Community-Project/Data stage/
patches/convert-audio.sh stage/Data
cd stage
tar czf data-part1.tar.gz --owner=0 --group=0 --numeric-owner Data/Base.rte
tar czf data-part2.tar.gz --owner=0 --group=0 --numeric-owner --exclude=Data/Base.rte Data
```
