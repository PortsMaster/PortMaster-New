## Notes

Thanks to [Bill Kendrick, Marianne Waage and Melissa Hardenbrook](https://newbreedsoftware.com/bobobot/) (New Breed Software) for BoboBot, a side-scrolling platformer from 2000. Preview 3 is its last, unfinished release, so only some of the stages are playable.

The original draws with X11 (Xlib). This port keeps the game code as it was and runs it on SDL2 through a small built-in Xlib replacement

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move, menu navigation |
| B | Jump, "No" in the quit prompt |
| Y | Fire |
| A | Start, select level, "Yes" in the quit prompt |
| X / Start | Pause / weapon select |
| Select | Title: exit. Level select: quit prompt. In game: abort to game over |

## Compile

```bash
wget https://tuxpaint.org/ftp/unix/x/bobobot/src/bobobot-preview3.tar.gz
tar xzf bobobot-preview3.tar.gz
cd bobobot-preview3
patch -p1 < /path/to/patches/bobobot-preview3-portmaster.patch
mkdir -p obj
make bobobot PORTMASTER=YES SOUND=YES MUSIC=YES DATA=.
strip -o bobobot.aarch64 bobobot
```

The patch adds `src/xsdl.c`, which implements the Xlib calls the game uses (pixmaps, GCs with clip masks, lines, arcs, polygons, image text, key events) on SDL2. It also adds `src/font6x13.h`, generated from xorg's public-domain `6x13.bdf` with `patches/bdf2c.py`. The patch builds against SDL2/SDL2_mixer instead of X11 and SDL 1.2, and changes the "Press SPACE" and quit-prompt texts to the gamepad buttons. Native joystick support (`/dev/js0`) stays off; gptokeyb2 drives all input.

Game data (`gamedata.tar.gz`): `images/` (without `.xvpics`), `levels/`, `mods/` (without `unused/`) and `sounds/` (`.wav` only).
