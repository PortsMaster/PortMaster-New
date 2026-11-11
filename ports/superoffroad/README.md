## Notes

Thanks to [Leland](https://en.wikipedia.org/wiki/Leland_Corporation) for the original arcade game and to [Graftgold](https://en.wikipedia.org/wiki/Graftgold) for its 1990 DOS version, a four-truck dirt racer where the Speed Shop upgrades bought between races decide who wins the next one.

This port, SORP by dopaz, rebuilds the DOS version on SDL 3 from the DOS program's own logic. It needs the original DOS game's files in `ports/superoffroad/gamedata/`: `ADLIB.SFX`, `CONTOUR0.XX` to `CONTOUR7.XX`, `EEND.PCG`, `EGA.EXE`, `EGAME.PCG`, `ESHADOW.PCG`, `ESHOP.PCG`, `ETITLE.PCG`, `ETRUCK.PCG`, `GAME.EXE`, `IRONFONT.XX`, `LOADB.XX`, `POLY.BIN`, `QUAD.BIN`, `ROADFONT.XX`, `TITLES.XX` and `TRACK0.XX` to `TRACK7.XX`. SORP checks every file; any that is missing or not the DOS release's own is named in `ports/superoffroad/log.txt`.

Optionally, it can race on the arcade game's tracks. Put your own MAME sets of the arcade game, `offroad.zip` and/or the Track-Pak's `offroadt.zip`, in `ports/superoffroad/gamedata/trackpak/` (its `README.txt` has the details), then turn on "arcade roms" in the options and choose an "arcade mode": original, track-pak or all 16. With the sets' sound chips, the arcade's tracks have the arcade's own music, effects and engine too. With "arcade roms" on, registration's nation list also has a second page: the arcade's other eight nations, with their flags and, with the sound chips, their anthems.

The Ironman Club's high scores are kept in `ports/superoffroad/IRONHI.BIN` (and the Track-Pak's in `IRONHITP.BIN`), and the options you set (Select) in `ports/superoffroad/sorp.cfg`. The last run's log is in `ports/superoffroad/log.txt`; for more detail in it, set the options' "log level" to debug or trace.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Steer, accelerate (up) |
| A / B | Nitro; join the game |
| Select | Options, with "Exit SORP" in the bottom left and "About" in the bottom right |
| Start | Confirm "Exit SORP?" |
| Hotkey + Start | Quit at once |
| Select + Start | Quit at once, for handhelds without a Hotkey button |

To accelerate with a button instead, set the options' "gamepad controls" to "B accel" (B accelerates, A fires nitro) or "A accel" (A accelerates, B fires nitro); up then does nothing in a race.

## Compile

SORP's source is at [github.com/dopazz/SORP](https://github.com/dopazz/SORP), and is also included in the port as `ports/superoffroad/sorp-source.zip`. The aarch64 build runs in Docker on an x86_64 Linux machine; it cross-compiles SDL 3.4.16 and SORP.

1. Install Docker and git:

```bash
sudo apt install docker.io git
```

2. Get the source and build:

```bash
git clone https://github.com/dopazz/SORP.git
cd SORP
docker build -t sorp-aarch64 -f packaging/Dockerfile.aarch64 packaging
docker run --rm --user $(id -u):$(id -g) -e HOME=/tmp -v "$PWD":/src -w /src sorp-aarch64 packaging/build.sh aarch64
```

The binary and `libSDL3.so.0` are written to `dist-aarch64/`.

## License

SORP - Super Off Road Port. Copyright (C) 2026 dopaz.
SPDX-License-Identifier: GPL-3.0-or-later

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. It is distributed WITHOUT ANY WARRANTY; see the GNU General Public License in `licenses/LICENSE-sorp.txt` for details.

Developed with the assistance of Claude Opus 5 and Claude Opus 5.5.
