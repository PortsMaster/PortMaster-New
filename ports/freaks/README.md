## Notes

Thanks to [Ángel Ortega and the Freaks team](https://triptico.com/software/fr2002.html) for this public domain remake of their 90s MS-DOS maze shooter, where you only heal by feeding on the monsters you've killed.

Save games are stored in `freaks/conf/`.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move forward/back, turn left/right |
| L1 / R1 (hold) | Strafe (with D-Pad left/right) |
| A | Fire |
| B | Menu confirm |
| Start | Menu confirm |
| Back | Game menu |

## Compile

The game's qdgdf framework has no SDL backend upstream, so this port adds SDL2 video and audio
drivers to it (`patches/qdgdf-sdl2.patch`). The same patch adds a `QDGDF_HOME` save-directory
override. A second patch adds a `--without-readline` option to filp
(`patches/filp-without-readline.patch`), since readline is only used by the debug console.

```bash
apt-get install -y libsdl2-dev
wget https://triptico.com/download/fr2002-19.10.29.tar.gz
tar xzf fr2002-19.10.29.tar.gz
cd fr2002-19.10.29
patch -p1 < ../patches/qdgdf-sdl2.patch
patch -p1 < ../patches/filp-without-readline.patch
CFLAGS="-O2 -Wall" ./config.sh --with-sdl2 --without-readline
make
strip -o fr2002.aarch64 fr2002
```

All game data is embedded into the `fr2002` binary at link time.
