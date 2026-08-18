## Notes

Thanks to [Lukas Loehrer](https://web.archive.org/web/20091229214210/http://homepage.hispeed.ch/loehrer/amph/amph.html) for the original Unix/SDL port of Jonas Spillmann's Amphetamine, a colorful little platformer whose dynamic lighting, fogging and corona effects were genuinely striking for a 2002 open-source game.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move |
| A | Jump |
| B | Shoot |
| X | Run (hold) |
| Y | Activate / Interact |
| L1 | Previous Weapon |
| R1 | Next Weapon |
| Start | Confirm |
| Back | Menu |

The keyboard version also has direct hotkeys for each of the 8 weapon slots (`1`-`8`). There
aren't enough spare buttons to bind those individually, so use L1/R1 to cycle to a specific slot
instead - some level hints (e.g. early on, "3 4 5 open the path") refer to weapon slots by
number and expect you to select them in that order.

## Compile

wget http://deb.debian.org/debian/pool/main/a/amphetamine/amphetamine_0.8.10.orig.tar.gz
wget http://deb.debian.org/debian/pool/main/a/amphetamine-data/amphetamine-data_0.8.7.orig.tar.gz
tar xzf amphetamine_0.8.10.orig.tar.gz
cd amphetamine-0.8.10
make

### aarch64 / 64-bit portability fix

The original code assumes `unsigned long` is 32 bits when packing shape data into a compact
token stream, which corrupts on any 64-bit target. Apply Debian's fix before building:

wget http://deb.debian.org/debian/pool/main/a/amphetamine/amphetamine_0.8.10-22.debian.tar.xz
tar xf amphetamine_0.8.10-22.debian.tar.xz
patch -p1 < debian/patches/020_assumed_sizeof_long.diff