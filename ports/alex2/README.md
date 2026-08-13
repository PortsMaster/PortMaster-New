## Notes

Thanks to [Johan Peitz](http://allegator.sourceforge.net/) for Alex the Allegator 2, a mouse-driven puzzle game made for the 2001 "Allegro Speedhack".

## Controls

| Button | Action |
|--|--|
| Left Stick | Move cursor |
| DPAD Left/Right | Change page (instructions screen only) |
| A | Click (place token / slide row-column / menu select) |
| X (hold) | Slow cursor for precision |
| Y | Hint (shows a suggested move) |
| Start | Confirm |
| Back | Cancel / Quit |

## Compile

Alex 2's original source ships with an uppercase `data/DATA.H` (matched by a lowercase
`#include "data/data.h"` in `alex2.c` - only worked on DOS/Windows' case-insensitive
filesystem) and calls two functions, `fcos`/`fsin`, that aren't part of modern Allegro 4 (the
real functions are `fixcos`/`fixsin`), plus a Windows-only debug key (`GFX_GDI`) that doesn't
exist on Linux. A few small changes are needed before it builds.

### 1. Get the source and Allegro 4

curl -sSL -o alex2s.zip "https://sourceforge.net/projects/allegator/files/Alex2/source%20and%20data/alex2s.zip/download"
mkdir alex2-src && cd alex2-src
unzip ../alex2s.zip
apt-get install -y liballegro4-dev

### 2. Fix case-sensitivity and modern-Allegro renames

- Rename `data/DATA.H` to `data/data.h` to match the lowercase `#include` used in `alex2.c`.
- Replace every `fcos(...)`/`fsin(...)` call in `alex2.c` with `fixcos(...)`/`fixsin(...)`.
- Remove the debug line `if (key[KEY_W]) set_gfx_mode(GFX_GDI, 320, 240, 0, 0);` in `play()` -
  `GFX_GDI` is a Windows-only driver ID.

### 3. Build

gcc -c alex2.c -o alex2.o
gcc -c hisc.c -o hisc.o
gcc -s -o alex2.aarch64 alex2.o hisc.o $(allegro-config --libs)
