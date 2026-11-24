## Notes

Thanks to Electronic Arts and EA Black Box for the original game, to [Octoblimp](https://github.com/Octoblimp) and the contributors to the decompilation and New 3DS port it is built from, and to manuelpllull for the Linux handheld port. Source (GPL-3.0): https://github.com/manuelpllull/NFSHP2-R36S

You need your own copy of the game: a PAL PS2 disc (SLES-50731). Make an `.iso` image of it and copy the image to `ports/nfshp2/gamedata/`. The package holds no game data.

1. Launch the port. The first launch installs the game from the image: about 10 minutes, with 3 GB free beside it. Progress is in `ports/nfshp2/patchlog.txt`. If it stops, launch again and it carries on.
2. When the game runs, you can delete the `.iso`.

No `python3` on your device? Install from a computer with Python 3.8 or newer, from the source repository's top folder, after copying `ZDIR.BIN` and `ZZDATA.BIN` from the disc's `NFSHP2` folder into `PS2 Files/Full Game/` (and `PAL.TAG` as well, if your extraction shows it):

```
python tools/zdir_extract.py --retail --decompress
python tools/audio_pack.py extracted-retail/SOUND extracted-retail/SOUND
python tools/make_card.py card
```

Copy the `card/NFSHP2` folder into `ports/nfshp2/gamedata/`.

Needs PortMaster on an armhf device (32-bit ARM with SDL2 and OpenGL ES). The game can't run in 64-bit. Tested on an R36S with dArkOS.

Logs: `ports/nfshp2/log.txt`, and after a crash `ports/nfshp2/gamedata/nfshp2_stderr.txt` too.

## Controls

| Button | Action |
| --- | --- |
| Left stick, D-pad Left / Right | steer |
| Bottom button (B) | accelerate |
| Left button (Y) | brake and reverse |
| Right button (A) | horn (cop: change target) |
| Top button (X) | change camera |
| L1 / R1 | look back / handbrake |
| L2 / R2 | shift down / up (manual gearbox) |
| Right stick up / down | gas / brake |
| D-pad Up | change HUD |
| Start | pause |
| Select + Start, held a second | quit |
| Select + L1 (or L3 / R3) | toggle FPS & performance overlay |
| Select + R1 | swap D-pad and left stick |

Two picture settings are in Options, Display, at the bottom of the list, and they're kept for the next start:

- **Graphics** (Full, Fast or Fastest): Full draws the game as the PS2 does; Fast redraws the cars' reflections and the mirror less often; Fastest also draws the 3D at 75% size. Fast is the default.
- **Smoke** (Full, Less or Least): Full draws every smoke and dust puff; Less and Least draw fewer of them and thin a dense cloud, which costs the GPU less. Less is the default.

The face buttons are in Options, Controller, under the controller line: **Face buttons: Standard** or **Face buttons: Swap A/B & X/Y**. For a device whose buttons come out crossed (some muOS handhelds), Swap A/B & X/Y makes the bottom and right buttons trade jobs, and the left and top ones too, in races and menus; the letters on screen stay as they are. It changes at once and is kept for the next start.

## Settings

`ports/nfshp2/nfshp2.cfg`, one `NAME=value` per line, is for what the menus don't cover. The package ships it with every line off (a `#` in front); a reinstall replaces it, so keep a copy of your edits. Every line is optional:

- `NFSHP2_SHOW_FPS=1`: frame counter on from the start.
- `NFSHP2_QUALITY=0`, `1` or `2`: a graphics choice that overrides the Graphics row at start. Leave it unset.
- `NFSHP2_ASPECT=0`: the PS2's 4:3 picture with bars, instead of filling the screen.
- `NFSHP2_DPAD_STICK=1`: start with D-pad and left stick swapped.
- `NFSHP2_FACE_FIX=0`: on muOS, keep the face buttons as muOS maps them, by their letters. By default the game reads them by position, as on every other system, so the controls and the button letters on screen match the table above. Face buttons in Options, Controller, then swaps them again on top of that.

## Compile

The source is the repository at https://github.com/manuelpllull/NFSHP2-R36S. The game's decompiled code is in its `3DS Files/source` folder, and the handheld layer is in `r36s/`.

With Docker installed, from the repository's top folder:

```bash
docker build -t nfshp2-r36s-build-armhf -f r36s/Dockerfile.armhf r36s
sh r36s/build.sh
sh r36s/package.sh
```

The first command makes the build image: Debian 10 with the armhf toolchain and SDL 2.28.5. `build.sh` writes the binary to `r36s/build/armhf/nfshp2.armhf`, and `package.sh` makes the PortMaster package in `r36s/build/portmaster/`.
