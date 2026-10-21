## Notes

Thanks to [a327ex](https://github.com/a327ex/SNKRX) for the game and its open source release. Buy it on [Steam](https://store.steampowered.com/app/915310/SNKRX/).

Game code modified by mxmgorin for performance on low-powered devices.

## Controls

| Button | Action |
|--|--|
| DPAD/LSTICK/RSTICK | Move, navigate menus |
| L1/R1 | Turn left/right |
| A | Turn left, select |
| B | Turn right, sell unit |
| A (hold) + DPAD | Reorder party |
| X | Reroll shop |
| Y | Start round |
| START/SELECT | Menu |

## Build

```sh
git clone -b portmaster https://github.com/mxmgorin/SNKRX.git
cd SNKRX
rm -rf engine/love builds assets/media assets/maps devlog.md todo build.sh run.sh README.md
for f in assets/sounds/*.ogg; do
  ffmpeg -i "$f" -c:a libvorbis -q:a 0 -ar 22050 -y "$f.tmp.ogg" && mv "$f.tmp.ogg" "$f"
done
zip -9 -r ../snkrx.love . -x '.git/*'
```
