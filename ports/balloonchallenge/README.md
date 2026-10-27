## Notes

Balloon Challenge v2.0 by William Soleau / Soleau Software (1993-1995). The port runs the original shareware `BALLOONC.EXE`, statically recompiled to native aarch64 code.

Owners of the registered version can copy their registered files over the included ones in `ports/balloonchallenge/gamedata/`; the port then runs in registered mode (two human players).

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick Left, Right | Move the marker to pick a balloon |
| A | Spacebar: launch balloon, continue |
| B | C: Continue (closing screens), Computer opponent (registered version) |
| X | D: Directions |
| Y | N: New game |
| L1 | Y: answer Yes |
| R1 | N: answer No |
| L2 | H: Human opponent (registered version) |
| R2 | G: Games by Soleau Software (in Options) |
| Start | Q: Quit (asks Y/N) |
| Select | O: Options |
| D-Pad Up | T: Toggle sound (in Options) |
| D-Pad Down | E: Exit to DOS (last closing screen) |
| Select + Start | Force quit |

To leave the game normally: Start, L1, then B and D-Pad Down on the closing screens.

## Compile

```bash
apt-get install cmake g++ libsdl2-dev python3-pip
pip install --user unicorn
pip download --only-binary :all: --no-deps iced-x86   # 1.17.0 is the newest aarch64 wheel
pip install --user iced_x86-1.17.0-cp37-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl
git clone https://github.com/jsummers/deark.git && make -C deark && export PATH=$PWD/deark:$PATH
git clone https://github.com/Cebion/balloonchallenge-decomp
cd balloonchallenge-decomp
scripts/prepare.sh /path/to/ballon20.zip
cmake -S recomp -B recomp/build-o3 -DCMAKE_BUILD_TYPE=Release
cmake --build recomp/build-o3 --target rc_play
strip -o balloonc.aarch64 recomp/build-o3/rc_play
```
