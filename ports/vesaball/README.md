## Notes

Thanks to [Krzysztof Krzyżanowski](https://github.com/krzyzan/VesaBall) for VesaBall, a classic Arkanoid-style brick breaker packed with over 20 power-ups and its own level editor.

Music: "Funky Chiptune" by Eric Matyas, [www.soundimage.org](https://soundimage.org) (CC BY 3.0).

## Controls

| Button | Action |
|--|--|
| Left Stick / D-Pad | Move paddle / cursor |
| A | Launch ball / Select / Editor: place brick |
| B | Editor: erase brick |
| X | Hold to slow the stick cursor |
| Y | Editor: save level |
| L1 | Editor: previous level |
| R1 | Editor: next level |
| L2 | Editor: reload level |
| R2 | Editor: clear board |
| Start | Pause |
| Select | Back / Quit from main menu |

## Compile

```bash
git clone https://github.com/krzyzan/VesaBall.git
cd VesaBall
git apply /path/to/patches/vesaball-portmaster.patch
```

### Sound effects and music

The three sound effects are the game's own, restored from its v0.91 history. The music is downloaded and re-encoded to 44.1 kHz.

```bash
mkdir -p snd
for f in brick brick_metal paddle; do git show e7ac425:snd/$f.wav > snd/$f.wav; done
wget -O funky_chiptune.ogg https://opengameart.org/sites/default/files/funky_chiptune_0.ogg
ffmpeg -i funky_chiptune.ogg -ar 44100 -c:a libvorbis -q:a 4 snd/music.ogg
```

### Build

```bash
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
strip build/VesaBall
```
