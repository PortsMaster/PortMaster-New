## Notes

Thanks to [Wladimir J. van der Laan](https://github.com/laanwj/sundog) for writing a p-system interpreter that runs FTL's original Atari ST SunDog code, one of the first real-time space trading games.

Copy your SunDog: Frozen Legacy v3.0 Atari ST disk image to `ports/sundog/`. Both a raw `.st` and a Pasti `.stx` image work; an `.stx` is converted to `sundog.st` on first launch. Use an image of the original disk, the re-packed version has a different layout and will not work.

## Controls

| Button | Action |
|--|--|
| Left Stick / D-Pad | Move mouse cursor |
| A | Left click |
| B | Right click (popup menu) |
| X (hold) | Slow cursor |
| Start | Pause / unpause |
| L1 | Save state (sundog.sav) |
| R1 | Load state (sundog.sav) |
| Select + Start | Quit |

## Compile

```bash
apt-get install libsdl2-dev meson ninja-build
git clone https://github.com/laanwj/sundog.git
cd sundog
git apply ../patches/sundog-software-cursor.patch
meson setup --buildtype release build
ninja -C build
strip -o sundog.aarch64 build/src/sundog
```

STX to ST converter used by the launch script (`patches/stx2st.c`):

```bash
gcc -O2 -Wall -o stx2st.aarch64 patches/stx2st.c
strip stx2st.aarch64
```
