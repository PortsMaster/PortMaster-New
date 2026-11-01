## Notes

Thanks to [sp00nz](https://github.com/sp00nznet) for the [Hover! static recompilation](https://github.com/sp00nznet/hover) and the [pcrecomp](https://github.com/sp00nznet/pcrecomp) toolchain behind it, which turn Microsoft's 1995 capture-the-flag maze racer from the Windows 95 CD into native code, no emulator involved.

Copy the files from your own Hover! folder (`FUNSTUFF\HOVER` on the Windows 95 CD) into `ports/hover/gamedata`: `HOVER.EXE`, `DASHRES.DLL`, `WAVEMIX.INF`, `MAZES` and `SOUNDS`.

Settings and high scores are kept in `ports/hover/conf/hover.reg`. Music plays through the TimGM6mb SoundFont.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Steer, forward and reverse |
| R2 | Forward |
| L2 | Reverse |
| A | Jump |
| X | Drop a wall |
| B | Cloak |
| Start | Pause |
| Select | New game |

## Compile

The game code is lifted from your own `HOVER.EXE`, so the build needs a copy of the game. The steps below run in an aarch64 Ubuntu 22.04 environment with `cmake`, `ninja-build`, `python3-pip`, `libsdl2-dev` and `libsdl2-ttf-dev` installed.

### 1. Sources

```bash
git clone https://github.com/sp00nznet/hover.git
git clone https://github.com/sp00nznet/pcrecomp.git
git clone https://github.com/schellingb/TinySoundFont.git
cd pcrecomp && git apply ../hover/patches/pcrecomp-win32hle.patch && cd ..
cd hover && patch -p1 < patches/hover-linux-host.patch
```

### 2. Lift HOVER.EXE to C

```bash
pip3 install --target .venv/site capstone
export PYTHONPATH=$PWD/.venv/site
python3 tools/gamefiles.py /path/to/hover.zip
python3 tools/catalog.py
python3 run_lift.py
```

### 3. Build

```bash
cmake -S src/linux -B build-linux -G Ninja -DTSF_DIR=$PWD/../TinySoundFont
cmake --build build-linux
strip -o hover.aarch64 build-linux/hover
```
