## Notes

Thanks to [Bill Kendrick](https://newbreedsoftware.com/madbomber/) for Mad Bomber, a faithful and colourful take on Activision's 1981 Kaboom! where every caught bomb speeds the next wave up.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move the buckets, menu navigation |
| A | Drop bombs (fire), confirm |
| B | Delete a letter (high score name) |
| Start | Pause / resume |
| Select | Quit to title screen (quit game on the title screen) |
| L1 / R1 | Two Player Vs.: move the bomber left / right slowly |
| Right Stick | Two Player Vs.: move the bomber left / right quickly |
| L2 | Open/close on-screen keyboard (high score name) |

On-screen keyboard: D-Pad moves, A picks a letter, B deletes, R2 switches letters/numbers.

## Compile

Mad Bomber 0.2.5 is an SDL 1.2 game; the patch converts it to SDL2 (window, renderer and text input) and adds a `portmaster` Makefile target.

```bash
apt install libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev
wget https://tuxpaint.org/ftp/unix/x/madbomber/src/madbomber-0.2.5.tar.gz
tar xzf madbomber-0.2.5.tar.gz
cd madbomber-0.2.5
patch -p1 < /path/to/patches/madbomber-sdl2-portmaster.patch
python3 /path/to/patches/make-press-select.py data/images/game/press-escape.png data/images/game/press-select.png
make portmaster
strip madbomber.aarch64
```

OmniOSK (on-screen keyboard), plain SDL2 build without the sdl12-compat bridge:

```bash
git clone -b sdl2 https://github.com/Cebion/OmniOSK.git OmniOSK
cd OmniOSK
cmake -S . -B build-sdl2 -DCMAKE_BUILD_TYPE=Release -DOMNI_SDL12_BRIDGE=OFF -DOMNI_BUILD_TESTS=OFF -DOMNI_BUILD_RENDERER_TEST=OFF
cmake --build build-sdl2
strip -o libomni_osk.so build-sdl2/lib/libomni_osk.so
```
