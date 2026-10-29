## Notes

Thanks to [the Adonthell team](https://adonthell.nongnu.org/) for Waste's Edge, a hand-drawn SNES-style RPG where you solve a theft at a remote trading post purely by talking to and questioning the inn's guests.

To type your character's name or a save description, press L2 to open the on-screen keyboard. Letters you pick with A appear in the game's field right away and B deletes. Close the keyboard with L2, then press A to accept.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move, menu and dialogue navigation |
| A | Talk, examine, select |
| B | Game menu, skip cutscene, close window |
| X | Save game |
| Y | Load game |
| L1 / R1 | Scroll up / down in dialogues and windows |
| L2 | Open/close on-screen keyboard |
| Start | Game menu |

On-screen keyboard: D-Pad moves, A picks a letter, B deletes, L1 switches lower/upper case, R2 switches letters/numbers/symbols.

## Compile

### 1. Python 3.10 (linked statically into the engine, glibc 2.34 compatible)

`glibc-compat.h` pins `hypot`/`hypotf` to `GLIBC_2.17` so the library doesn't need glibc 2.35. It is in `patches/`.

```bash
wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tar.xz
tar xJf Python-3.10.12.tar.xz
cd Python-3.10.12
./configure --prefix=$PWD/../pyprefix --enable-shared --without-ensurepip --disable-test-modules \
    CFLAGS="-O2 -include /path/to/patches/glibc-compat.h"
make -j$(nproc)
make install
cd ..
```

### 2. Adonthell engine

```bash
wget https://download.savannah.gnu.org/releases/adonthell/adonthell-src-0.3.8.tar.gz
tar xzf adonthell-src-0.3.8.tar.gz
cd adonthell-0.3.8
patch -p1 < /path/to/patches/adonthell-portmaster.patch
touch src/py_adonthell_wrap.cc src/modules/adonthell.py
PATH=$PWD/../pyprefix/bin:$PATH ./configure --prefix=$PWD/../stage --disable-unix-install \
    --disable-py-debug --disable-pyc --with-python=python3.10
make -j$(nproc)
make install
cd ..
```

### 3. Waste's Edge

```bash
wget https://download.savannah.gnu.org/releases/adonthell/wastesedge-src-0.3.8.tar.gz
tar xzf wastesedge-src-0.3.8.tar.gz
cd wastesedge-0.3.8
./configure --disable-pyc --with-adonthell-binary=$PWD/../stage/bin/adonthell-0.3
make -j$(nproc)
make install
cd ..
strip -o adonthell.aarch64 stage/bin/adonthell-0.3
```

### 4. OmniOSK (on-screen keyboard), plain SDL2 build

```bash
git clone -b sdl2 https://github.com/Cebion/OmniOSK.git OmniOSK
cd OmniOSK
git checkout 623739f
cmake -S . -B build-sdl2 -DCMAKE_BUILD_TYPE=Release -DOMNI_SDL12_BRIDGE=OFF -DOMNI_BUILD_TESTS=OFF -DOMNI_BUILD_RENDERER_TEST=OFF
cmake --build build-sdl2
strip -o libomni_osk.so build-sdl2/lib/libomni_osk.so
```
