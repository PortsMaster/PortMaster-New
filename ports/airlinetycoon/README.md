## Notes

Thanks to [Runesoft](https://www.rune-soft.com/) for the official Linux build of Airline Tycoon Deluxe, Spellbound's airline management game full of slapstick sabotage between rival tycoons.

The language (English, German or French) is picked by clicking a flag on the first launch. Delete `conf/.AirlineTycoonDeluxe/language.ini` to pick again.

## Controls

| Button | Action |
|--|--|
| Left stick | Move cursor |
| A | Left click |
| B | Right click |
| X | Slow cursor |
| Y | Middle click (pan while zoomed) |
| L1 | Zoom out (mouse wheel) |
| R1 | Zoom in (mouse wheel) |
| Back | Esc |

## Compile

The game is the unmodified x86 binary from Steam/GOG, run through box86 (armhf build).

```bash
git clone https://github.com/ptitSeb/box86.git
cd box86
mkdir build && cd build
cat > armhf-toolchain.cmake <<'TC'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR armv7l)
set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)
set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabihf)
TC
cmake .. -DARM64=1 -DCMAKE_TOOLCHAIN_FILE=armhf-toolchain.cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
```

`x86lib/libstdc++.so.6` and `x86lib/libgcc_s.so.1` are the x86 copies from box86's own `x86lib/` folder.
