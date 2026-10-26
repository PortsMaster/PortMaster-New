## Notes

Thanks to [Michael Speck](https://lgames.sourceforge.io/LTris/) (LGames) for LTris2, a polished falling-block puzzle game with Normal, Figures and Vs CPU modes, classic or modern rules, hold and hard drop.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick Left/Right | Move piece, change menu value |
| D-Pad / Left Stick Down | Soft drop |
| D-Pad / Left Stick Up | Hard drop |
| D-Pad / Left Stick Up/Down | Menu navigation |
| A | Rotate clockwise, menu select |
| B | Rotate counter-clockwise |
| X | Hold piece |
| Y | Confirm "Yes" in dialogs |
| Start | Menu / pause, back, "No" in dialogs |

## Compile

```bash
wget https://downloads.sourceforge.net/project/lgames/ltris/ltris2-2.0.4.tar.gz
tar xzf ltris2-2.0.4.tar.gz
cd ltris2-2.0.4
patch -p1 < /path/to/patches/ltris2-portmaster.patch
./configure --disable-install --disable-nls
make -j$(nproc)
strip -o ltris2.aarch64 src/ltris2
```

The patch disables the game's native joystick handling (raw `SDL_JoystickOpen` with fixed button numbers) so gptokeyb2 drives all input, and sets player 1's default keys to Return for rotate clockwise and Up for hard drop.

Game data (`gamedata.tar.gz`): `src/figures` and `src/themes/Standard/` without the `Makefile*` files.
