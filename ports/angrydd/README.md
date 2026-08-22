## Notes

Thanks to [Joe Wreschnig](https://salsa.debian.org/games-team/angrydd) for the original 2004 release of Angry, Drunken Dwarves, a fast, gamepad-friendly falling-block puzzler in the Puzzle Fighter mold.

## Controls

Two players can play a versus match on one device: Player 1 uses the D-Pad
and left shoulder buttons, Player 2 uses the face buttons and right
shoulder buttons.

| Button | Action |
|--|--|
| D-Pad | Player 1: Move (Up also Rotates Clockwise) |
| Left Stick | Player 1: Move (Up also Rotates Clockwise) |
| L1 | Player 1: Rotate Counter-Clockwise |
| Start | Player 1: Confirm / Special Move |
| X | Player 2: Move Up (also Rotates Clockwise) |
| Y | Player 2: Move Left |
| A | Player 2: Move Right |
| B | Player 2: Move Down |
| R1 | Player 2: Rotate Counter-Clockwise |
| Back | Player 2: Confirm / Special Move |
| Start + Back (hold) | Quit |

Up doubles as Rotate Clockwise by default (the game's own `rotate_on_up`
setting), so there's no separate dedicated Rotate Clockwise button for
either player. There is no Pause button in this control scheme.

## Build

This port vendors CPython's `pygame` package, built from source against
the system SDL2/SDL2_mixer/SDL2_image/SDL2_ttf so that no private copy of
those libraries ships with the port.

### 1. Fetch and patch the game source

```
curl -sL "https://salsa.debian.org/games-team/angrydd/-/archive/debian/1.0.1-14/angrydd-debian-1.0.1-14.tar.gz" -o angrydd-src.tar.gz
tar xzf angrydd-src.tar.gz --strip-components=1
for p in 01_prefix_usr.patch 02_unixbros.patch 03_bug405368.patch 04_bug406548.patch 05_bug402333.patch windowed-mode.patch python3.patch; do
  patch -p1 --forward < "debian/patches/$p"
done
```

### 2. Build pygame against the system SDL2 stack

Requires a Python 3.11 install (matching PortMaster's `python_3.11`
runtime's ABI) with its development headers, plus SDL2/SDL2_mixer/
SDL2_image/SDL2_ttf/freetype/libpng/libjpeg development packages.

```
curl -sL "https://files.pythonhosted.org/packages/49/cc/08bba60f00541f62aaa252ce0cfbd60aebd04616c0b9574f755b583e45ae/pygame-2.6.1.tar.gz" -o pygame-2.6.1.tar.gz
tar xzf pygame-2.6.1.tar.gz
cd pygame-2.6.1
python3.11 setup.py build
```

The resulting `build/lib.linux-aarch64-3.11/pygame/` directory contains
the pure-Python modules and the compiled `.cpython-311-aarch64-linux-gnu.so`
extension modules, dynamically linked against the system SDL2 libraries
by SONAME only (no bundled copies).
