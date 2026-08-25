## Notes

Thanks to PopCap Games for making Insaniquarium, to the
[WinFish](https://github.com/vindirect/winfish) project for the decompilation
this is built from, to [PopLib](https://github.com/teampopwork/poplib) for the
framework that replaces the game's original SexyAppFramework, and to
[SaMeiers](https://github.com/SaMeiers/insaniquarium-port) for the
aarch64/PortMaster port this package is built from.

**This port does not include the game.** It is the executable only; the assets
come from a copy you own.

## Installation

Copy these folders from your copy of Insaniquarium Deluxe (Steam) into
`ports/insaniquarium/`:

```
data  images  music  properties  sounds  fishsongs
```

The game will not start without them; it shows a message saying so.

**Watch the letter case.** Windows ignores it and Linux does not, so a retail
copy usually has a few files whose case does not match what the game asks for.
If it complains about an image that clearly exists, that is why. Renaming the
file to the case the game asks for fixes it.

## Controls

The game is played entirely with the pointer, so the gamepad acts as a mouse.

| Button | Action |
| --- | --- |
| Left stick / D-pad | Move the pointer |
| A | Left click — feed, collect coins, shoot |
| B | Right click — release pet, cancel |
| L1 / R1 | Move the pointer slowly, for coins and small fish |
| Y | Collect every coin at once, if Auto Collect is on |
| Start | Enter |
| Select | Escape |

**Auto Collect** is off, in Options. A tank full of coins is a lot of presses
of the same button, so this sweeps them all in one. It does make the collecting
pets less useful, which is why it asks before switching on and stays off unless
you say yes.

## Saves

Profiles and high scores are kept in `ports/insaniquarium/conf/`, inside the
port folder rather than in the system partition, so deleting the port removes
them and copying the folder to another card keeps them.

## Known issues

- Loading screens run at a reduced frame rate. That is the original engine's own
  behaviour: it deliberately gives two thirds of the CPU to the loading thread.

## Source

<https://github.com/SaMeiers/insaniquarium-port>

Licensed AGPL-3.0, inherited from PopLib. Third-party licences are in
`licenses/`.

## Compile

### 1. Get the source

```
git clone --recurse-submodules https://github.com/SaMeiers/insaniquarium-port.git
cd insaniquarium-port
```

`poplib/external/discordrpc` is a private submodule (Discord RPC support,
unused by this port) and fails to clone with `fatal: could not read Username
for 'https://github.com': No such device or address`, aborting the checkout
of every submodule that hadn't finished yet. Finish the rest explicitly,
skipping it:

```
git submodule update --init poplib/external/SDL poplib/external/SDL_ttf \
  poplib/external/curl poplib/external/ogg poplib/external/vorbis \
  poplib/external/openal poplib/external/zlib poplib/external/tinyxml2 \
  poplib/external/miniaudio
git submodule update --init --recursive poplib/external/SDL_ttf
```

### 2. Install gcc-12 and a shared SDL3

OpenAL-soft's `alc.cpp` uses C++20 `<ranges>` code (constructing a
`std::string_view` from a `std::views::split` subrange) that gcc-11's
libstdc++ doesn't fully support and fails to compile; gcc-12 does.
PopLib's own `external/SDL` submodule is a fork (`SaMeiers/SDL`,
`mali-fbdev` branch) carrying real, unrelated patches, so this builds real
upstream SDL3 instead and points PopLib at that:

```
apt-get install -y gcc-12 g++-12
git clone --branch release-3.2.30 --single-branch https://github.com/libsdl-org/SDL.git
cd SDL
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 \
  -DSDL_SHARED=ON -DSDL_STATIC=ON
cmake --build . --parallel $(nproc)
cmake --install .
/sbin/ldconfig
cd ../..
```

In `poplib/CMakeLists.txt`, change:

```
set(SDL_STATIC OFF CACHE BOOL "" FORCE)
set(SDL_SHARED ON CACHE BOOL "" FORCE)
add_subdirectory(external/SDL EXCLUDE_FROM_ALL)
```

to:

```
find_package(SDL3 REQUIRED CONFIG)
```

and in `poplib/PopLib/CMakeLists.txt`, change `SDL3::SDL3-static` to
`SDL3::SDL3` in the `target_link_libraries(${PROJECT_NAME} PUBLIC ...)` block.

### 3. Regenerate the game source from the decompilation

```
bash port/port.sh
```

Needs `python` on `PATH` (not just `python3`) for the fixup scripts under
`port/fixups/`.

### 4. Build

```
cmake -S port -B port/build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 \
  -DPOPLIB_WITH_BASS=OFF
cmake --build port/build --parallel $(nproc)
strip -o port/bin/Insaniquarium.stripped port/bin/Insaniquarium
```

This produces `port/bin/Insaniquarium.stripped`, which ships in this port's
`insaniquarium/` folder as `Insaniquarium`.

### 5. Build the SDL3-via-SDL2-backend shim

```
git clone --recursive https://github.com/bmdhacks/SDL.git -b sdl2-backend
cd SDL
git clone https://github.com/KhronosGroup/SPIRV-Cross.git ../SPIRV-Cross
mkdir build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="-march=armv8-a" \
  -DSDL_SDL2_BACKEND=ON \
  -DSDL_SPIRV_CROSS_DIR=../../SPIRV-Cross \
  -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_KMSDRM=OFF \
  -DSDL_PIPEWIRE=OFF -DSDL_PULSEAUDIO=OFF -DSDL_ALSA=OFF \
  -DSDL_SNDIO=OFF -DSDL_OSS=OFF -DSDL_JACK=OFF \
  -DSDL_OFFSCREEN=OFF -DSDL_DUMMYVIDEO=OFF \
  -DSDL_DUMMYAUDIO=OFF -DSDL_DISKAUDIO=OFF \
  -DSDL_VULKAN=OFF -DSDL_GPU=ON -DSDL_RENDER_GPU=ON \
  -DSDL_UNIX_CONSOLE_BUILD=ON
make -j$(nproc)
```

This produces `libSDL3.so.0.5.0` at `build/libSDL3.so.0.5.0`, which ships in
this port's `libs.aarch64/` as `libSDL3.so.0`, replacing the one step 4's
build produced.

Before configuring, apply one fix to `src/video/sdl2/SDL_sdl2events.c`. The
backend decides an event is relative motion and then hands
`SDL_SendMouseMotion` the absolute coordinates anyway, so every motion moves
the pointer by its own position on screen rather than by how far it moved:
the pointer travels only right and down, in jumps of hundreds of pixels,
until it reaches the bottom-right corner and stays there.

In the `SDL2_MOUSEMOTION` case, replace

```
                                    (float)e.motion.x, (float)e.motion.y);
```

with

```
                                    relative ? (float)e.motion.xrel : (float)e.motion.x,
                                    relative ? (float)e.motion.yrel : (float)e.motion.y);
```

Whether a device hits this depends on `e.motion.which`, the SDL2 mouse
instance id, being non-zero: gptokeyb2's virtual pointer is, a plain mouse
often is not, so the same build behaves correctly on one handheld and not on
the next.
