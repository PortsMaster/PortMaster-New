## Notes

Thanks to [Johan Peitz](http://allegator.sourceforge.net/) for Alex the Allegator, an unfinished but genuinely playable one-sitting platformer made for the 1999 "Allegro Speedhack" jam.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Jump |
| Y | Pause |
| Start | Confirm (menu) |
| B / Back | Quit |

## Compile

Alex 1's original source ships as uppercase `.C`/`.H` filenames with lowercase `#include`s
(only worked on DOS's case-insensitive filesystem) and a couple of DOS/djgpp-only calls, so a
few small changes are needed before it builds on Linux.

### 1. Get the source and Allegro 4

curl -sSL -o alex1s.zip "https://sourceforge.net/projects/allegator/files/Alex1/source%20and%20data/alex1s.zip/download"
mkdir alex1-src && cd alex1-src
unzip ../alex1s.zip
apt-get install -y liballegro4-dev

### 2. Fix case-sensitivity and DOS-only calls

- Rename every source/header/data filename to lowercase (`ALEX.C` -> `alex.c`, etc.) to match
  the lowercase `#include`s used throughout.
- Drop the two DOS-only `DECLARE_GFX_DRIVER_LIST(GFX_DRIVER_VGA)` / `DECLARE_COLOR_DEPTH_LIST(COLOR_DEPTH_8)`
  "shrink the EXE" lines near the top of `alex.c` and `maped.c` - `GFX_DRIVER_VGA` doesn't exist
  outside DOS builds.
- Replace the DOS conio-style startup/shutdown banners (`clrscr`/`cprintf`/`gotoxy`/`textcolor`/
  `textbackground`/`clreol`) in `alex.c`'s `init()`/`shutdown()` with plain `printf` - cosmetic
  console text only, doesn't touch the actual game screen.
- Replace `biostime(0, 0)` with `time(NULL)` for RNG seeding, and `gets()` with
  `fgets(info.name, sizeof(info.name), stdin)` in `level.c`'s `name_level()`.

### 3. Build

gcc -c alex.c -o alex.o
gcc -s -o alex1.aarch64 alex.o $(allegro-config --libs)

This produces a single binary (`alex.c` `#include`s `level.c` and `player.c` directly) that
needs `gfx.dat`, `sound.dat`, and `test.map` alongside it at runtime.
