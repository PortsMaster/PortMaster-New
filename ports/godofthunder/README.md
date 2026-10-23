## Notes

Thanks to [Ron Davis](https://www.adeptsoftware.com/got/) for God of Thunder's returning-hammer combat and puzzles, and to [darvell](https://github.com/darvell/GodOfThunder-Port) for the native source port.

Music and sound effects are by Roy Davis. The original source is preserved at [joncloud/got](https://github.com/joncloud/got).

Download [gotfree.zip from Adept Software](https://www.adeptsoftware.com/got/gotfree.zip) manually and extract all its contents into `ports/godofthunder/gamedata`. Do not put them in an extra nested folder. `GOTRES.DAT` and `GOT.EXE` must be directly inside `gamedata`.

The port does not download assets. Once you have supplied the files, no internet connection is needed to play. All three episodes run in the native engine. `GOT.EXE` is read only for its embedded menu and graphics data; no DOS executable or CPU emulation is used.

Each episode has its own save file, `GOTSAVE1.SAV`, `GOTSAVE2.SAV`, or `GOTSAVE3.SAV`, in `ports/godofthunder`. Use the in-game menu to save and load. Start+Select exits immediately, so save first.

In Settings, press L2 to switch between Audio, Display, Keys, and Gamepad. Press X to save changes and close Settings, or Start to cancel. Physical controller bindings are managed by PortMaster's `godofthunder.ini`, not the native Gamepad settings.

Fullscreen preserves the game's proportions and fits the available screen height. On widescreen devices, side bars are expected. To fill the entire screen instead, open Settings, press L2 for Display, turn Stretch on, and press X to save. Stretch changes the game's proportions. R2 toggles window fullscreen without changing the scaling mode.

Display > Scaling offers Nearest, EPX 2x, EPX 4x, and EPX Auto. Nearest is the default. EPX smooths pixel-art edges without introducing new colors. The 4x mode applies EPX twice; Auto chooses 2x for 640x480 and 4x for a 1080p output. Filtering is independent of Stretch and Fullscreen, and also applies to opening menus. Press X to save your selection. A saved value for a removed scaling mode falls back to Nearest.

The EPX/Scale2x implementation is part of the public-domain native renderer and needs no additional filter library. Algorithm credit goes to Eric Johnston and Andrea Mazzoleni.

## Controls

| Key | Action |
|--|--|
| D-Pad / Left Stick | Move / Navigate menus |
| A | Confirm / Advance dialogue |
| B | Throw hammer / Confirm in-game menus |
| Y | Use selected magic item |
| X | Select item |
| L1 | Previous item |
| R1 | Next item |
| L2 | Next Settings tab (Tab) |
| R2 | Toggle fullscreen (F11) |
| X in Settings | Save changes and close |
| Start | Options menu / Back / Skip story |
| Select | In-game help |
| Start + Select | Exit immediately |

## Compile

Build on an ARM64 Linux machine with Debian/Ubuntu packages. Run from this document's directory. The commands locate the supplied patches in either the installed game directory or the submission directory.

### 1. Build tools and patches

```sh
sudo apt-get update
sudo apt-get install -y build-essential cmake git pkg-config libsdl2-dev
PATCH_DIR="$PWD/patches"
if [ ! -d "$PATCH_DIR" ]; then
  PATCH_DIR="$PWD/godofthunder/patches"
fi

```

### 2. raylib with SDL2 and GLES2

```sh
git clone https://github.com/raysan5/raylib.git raylib
git -C raylib checkout c1ab645ca298a2801097931d1079b10ff7eb9df8
git -C raylib apply "$PATCH_DIR/raylib.patch"
```

### 3. Native game and EPX renderer

```sh
git clone https://github.com/darvell/GodOfThunder-Port.git got-source
git -C got-source checkout 2070f075b1e830cc7f8702837bf2a6fe1781b158
git -C got-source apply "$PATCH_DIR/godofthunder.patch"
cmake -S got-source -B build -DCMAKE_BUILD_TYPE=Release \
  -DGOT_RAYLIB_SOURCE_DIR="$PWD/raylib" \
  -DGOT_PORTMASTER=ON \
  -DPLATFORM=SDL -DOPENGL_VERSION="ES 2.0" -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_C_FLAGS="-march=armv8-a" \
  -DCMAKE_CXX_FLAGS="-march=armv8-a"
cmake --build build --target got -j2
```

The output is `build/got`. SDL2 uses the operating system's library. Raylib, EPX, and the FM synthesizer are linked into the executable; no extra scaling library is required.
