## Notes

Thanks to [Alexander Batalov](https://github.com/alexbatalov/arcanum-ce) for Arcanum Community Edition, a clean-room reimplementation of the engine behind Troika Games' Arcanum: Of Steamworks and Magick Obscura, a genre-defining 2001 steampunk isometric RPG letting you mix magic and technology freely.

## Required data files

This port contains no game data. You must own Arcanum (GOG or Steam) and copy its data files into this port's `arcanumce/gamedata` folder on the device before launching:

```
arcanumce/gamedata/
├── tig.dat
├── arcanum1.dat
├── arcanum2.dat
├── arcanum3.dat
├── arcanum4.dat
└── modules/
    ├── Arcanum.dat
    ├── Arcanum.PATCH0
    ├── Vormantown.dat
    └── Arcanum/
        ├── movies/
        └── sound/music/
```

On a PC, either copy the `Arcanum` folder from an existing Windows install, or extract it from the GOG installer with `innoextract`


Then copy the contents of that `Arcanum` folder into `arcanumce/gamedata` on the device.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move mouse cursor |
| X (hold) | Precision mouse movement |
| A | Mouse left click (move / interact / attack) |
| B | Mouse right click |
| L1 | Toggle D-pad between navigation and hotbar slots 1-4 |
| Y | Character sheet |
| R1 | World map |
| L2 | Toggle on-screen keyboard |
| R2 | Skills |
| D-Pad | Camera scroll / menu navigation (hotbar slots 1-4 while L1 toggled) |
| Start | Confirm / party message |
| Back | Escape / menu |

While the on-screen keyboard is open:

| Button | Action |
|--|--|
| D-Pad | Move selection |
| Start | Confirm / type selected key |
| R1 | Backspace |
| R2 | Switch keyboard page (lower/upper/number/special) |

## Compile

### 1. Get the source

git clone https://github.com/alexbatalov/arcanum-ce.git
cd arcanum-ce

### 2. Build arcanum-ce

In `third_party/sdl3/CMakeLists.txt`, change:

set(SDL_SHARED OFF)
set(SDL_STATIC ON)

to:

set(SDL_SHARED ON)
set(SDL_STATIC OFF)

In `CMakeLists.txt`, after the existing `target_link_libraries(arcanum-ce PUBLIC ${TIG_LIBRARY})` block, add:

if(UNIX)
    target_link_libraries(arcanum-ce PUBLIC m)
endif()

Then configure and build:

cmake --preset linux-arm64-release
cmake --build --preset linux-arm64-release --parallel $(nproc)

This produces `arcanum-ce` at `out/build/linux-arm64-release/arcanum-ce`.

### 3. Build the SDL3-via-SDL2-backend shim

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

This produces `libSDL3.so.0.5.0` at `build/libSDL3.so.0.5.0`, which ships in this port's `libs.aarch64/` as `libSDL3.so.0`.

### 4. Build OmniOSK

git clone https://github.com/Cebion/OmniOSK_sdl3.git
cd OmniOSK_sdl3

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DOMNI_BUILD_TESTS=OFF \
  -DOMNI_SDL3_INCLUDE_DIR=/path/to/sdl3-sdl2-backend/include \
  -DOMNI_SDL3_LIBRARY=/path/to/sdl3-sdl2-backend/build/libSDL3.so
cmake --build build --parallel $(nproc)

This produces `build/lib/libomni_osk.so`, which ships in this port's `libs.aarch64/` alongside the shim.
