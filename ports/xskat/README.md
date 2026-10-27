## Notes

Thanks to [Gunter Gerhardt](http://www.xskat.de) for XSkat, a Skat game played by the official Skat Order whose computer opponents can also suggest your next card or what to put into the Skat.

Options set from the in-game menu are saved in `conf/xskat.opt`, and the game list in `conf/xskat.lst`.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move mouse |
| A | Left click |
| B | Right click |
| X | Slow mouse (hold) |
| D-Pad | Select card or button |
| Y | Confirm selection |
| Start | Open menu |

## Compile

```bash
wget https://web.archive.org/web/2021id_/http://www.xskat.de/xskat-4.0.tar.gz
tar xzf xskat-4.0.tar.gz
cd xskat-4.0
patch -p1 < /path/to/patches/xskat-4.0.1-portmaster.patch
make CFLAGS="-O2" LDFLAGS="-lXcomposite -lXdamage -lXfixes -lXrender -lX11"
strip -o xskat.aarch64 xskat
```

Fallback font for X servers without the misc bitmap fonts (`fonts/`, used through `XSKAT_FONTDIR`):

```bash
pip install fonttools
pyftsubset /usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf --unicodes=U+0020-007E,U+00A0-00FF --output-file=DejaVuSansMono.ttf
```
