## Notes

Thanks to [Daedalic Entertainment](https://www.daedalic.com/) for Deponia, a hand-drawn point-and-click comedy about Rufus trying to get off a planet made of junk, and for shipping an official Linux build. 
The game runs through [box64](https://github.com/ptitSeb/box64) and [gl4es](https://github.com/ptitSeb/gl4es) by ptitSeb.

Requires the GOG or Steam Linux version of the game, see the instructions in PortMaster. 

On devices with 1 GB of RAM, textures are loaded at half size and a compressed swap in RAM (zram) is set up while the game runs, if the system has no swap of its own.

On a new game, Deponia asks which inventory style to use. Both work:
- **Mouse wheel:** R1 opens the inventory, L1 closes it.
- **Classic:** move the pointer to the inventory icon in the top right corner and press A, move the pointer off the inventory to close it.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move the pointer |
| A | Left click (walk, use, talk) |
| B | Right click (look at) |
| X | Slow pointer (hold) |
| Y | Show hotspots |
| R1 | Mouse wheel down (open the inventory) |
| L1 | Mouse wheel up (close the inventory) |
| Start / Select | Menu, skip videos |

## Compile

The game binary is Daedalic's x86_64 build, run through box64. Everything below is built in an aarch64 Ubuntu 22.04 environment.

### 1. box64

`BAD_SIGNAL` is needed on dArkOS: its 5.10 kernel reports box64's write-protect faults as `SEGV_MAPERR`, which crashed the game's LuaJIT.

```bash
git clone https://github.com/ptitSeb/box64.git
cd box64
git checkout c305b57c6f56405dbb816db861862dbd3b826af7
mkdir build && cd build
cmake .. -DARM64=1 -DBAD_SIGNAL=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
strip box64
cd ../..
```

The x86_64 `libstdc++.so.6` and `libgcc_s.so.1` in `box64/x64/` are the ones box64 ships in its `x64lib/` folder.

### 2. gl4es

`patches/gl4es-streamed-texture-unshrink.patch` keeps textures that are re-uploaded every frame (the game's video planes) at full size when texture shrinking is on.

```bash
git clone https://github.com/ptitSeb/gl4es.git
cd gl4es
git checkout 17f0894e19d1553e4176276c759915dab44c08e2
git apply ../deponia/patches/gl4es-streamed-texture-unshrink.patch
mkdir build && cd build
cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
strip --strip-unneeded ../lib/libGL.so.1 ../lib/libEGL.so.1
cd ../..
```

### 3. libopus

The game's emulated Opus decoder is too slow, so the binary is patched to call the native `libopus.so.0` instead (Ubuntu 22.04's libopus 1.3.1).

```bash
sudo apt install libopus0
cp /usr/lib/aarch64-linux-gnu/libopus.so.0.8.0 libs.aarch64/libopus.so.0
```

### 4. Opus patch for the game binary

`deponia_opus.patch` is applied by the launch script to the GOG/Steam `Deponia` binary (md5 `f432c959baa8bdbf225f54ceb19623e7`, identical in both stores). It redirects the game's `opus_multistream_*` calls to the native libopus through box64 and disables the opusfile dither path. Regenerate it from an unpatched binary:

```bash
python3 patches/gen_opus_patch.py /path/to/Deponia > deponia_opus.patch
```
