## Notes

Thanks to the [DreamChess developers](https://github.com/dreamchess/dreamchess) for DreamChess, an open source 3D chess game with its own xboard-compatible engine, Dreamer, and a freely rotatable board.

On lower-powered devices the default 3D piece sets (Classic Wooden, Opposing Elements) can run slow; switch to the Sketch or Figurine theme in Settings for full speed.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move cursor |
| A | Confirm / Select |
| B | Menu / Back |
| X | View next move in game history |
| Y | View previous move in game history |
| L1 | Retract move |

## Compile

### 1. Fetch and patch the game source

DreamChess's Linux data-directory lookup (`ch_datadir()` in `dreamchess/src/dir.c`) hardcodes
an absolute path baked in at compile time, with no runtime override. `dreamchess/patches/relocatable-datadir.patch`
(in this port) patches it to resolve the data directory relative to the running executable
instead, so the built binary works from any install location:

```
git clone https://github.com/dreamchess/dreamchess.git
cd dreamchess
patch -p1 < /path/to/dreamchess/patches/relocatable-datadir.patch
```

### 2. Build DreamChess and Dreamer

Requires CMake, bison, flex, gettext, and the system SDL2/SDL2_image/SDL2_mixer/freetype/expat
development packages:

```
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DDREAMCHESS_RELEASE=TRUE
cmake --build build -j$(nproc)
```