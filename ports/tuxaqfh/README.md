## Notes

Thanks to [Steve and Oliver Baker](https://sourceforge.net/projects/tuxaqfh/) for Tuxedo T.
Penguin: A Quest for Herring, a charming late-90s/early-2000s 3D platformer built on Steve
Baker's own PLIB engine, where Tux (or his girlfriend Gown) explores island levels hunting down
hidden herring while dodging killer whales and leopard seals.

## Controls

The game's own in-game help screen describes a real joystick's button layout and does not
reflect this port's controls - use this table instead.

| Button | Action |
|--|--|
| Left Analog | Move Tux |
| D-Pad | Camera zoom / pan |
| A | Jump / Flap |
| B | Fire (dive faster underwater) |
| X | Help |
| L1 | Reset camera |
| L2 | Toggle follow camera |
| R1 (hold) | Look around / zoom with the analog stick instead of moving |
| R2 | Toggle wide field of view |
| Start | Pause |
| Back | Quit |

## Compile

```bash
git clone https://github.com/Cebion/tuxaqfh.git
cd tuxaqfh
mkdir build && cd build
cmake ..
make
```

Requires SDL2 (`libsdl2-dev`) development packages, a patched build of PLIB (see below) rather
than the distro's `libplib-dev` package, and a build of [gl4es](https://github.com/ptitSeb/gl4es)
for the target device (shipped as a runtime-only `libGL.so.1`/`libEGL.so.1` pair, never linked
against at compile time).

### PLIB (patched)

Ubuntu's packaged PLIB 1.8.5 compiles and links fine, but needs two sets of changes for this
port: a GL-context-validity fix (`ssg.cxx`/`pu.cxx`/`fntTXF.cxx`) and a new SDL2 audio backend
for `slDSP` (`slPortability.h`/`sl.h`/`slDSP.cxx`), replacing the OSS-only one that depends on
device-specific ALSA/PulseAudio configuration. Full patch: `patches/plib-1.8.5-sdl2-and-glcontext.patch`.

```bash
apt-get source libplib1
cd plib-1.8.5
patch -p1 < ../../patches/plib-1.8.5-sdl2-and-glcontext.patch
libtoolize --force --copy
autoreconf -fi
./configure --prefix=/usr --libdir=/usr/lib/aarch64-linux-gnu --build=aarch64-unknown-linux-gnu
CXXFLAGS="-g -O2 -Wall -DSL_USING_SDL_AUDIO $(sdl2-config --cflags)" make -j$(nproc)
```

The resulting `src/*/.libs/libplib*.so.1.8.5` files are what's bundled in `libs.aarch64/` here
(renamed to their plain `.so.1` SONAME). `libplibsl.so.1` specifically needs linking against
SDL2 explicitly (`-lSDL2`) since its build doesn't pick that up from `CXXFLAGS` alone.
