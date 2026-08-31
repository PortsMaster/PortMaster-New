## Notes

Thanks to the [Globulation 2 Team](https://github.com/Globulation2/glob2) for this real-time strategy game, whose "set goals instead of micromanaging units" design makes it stand out from the usual click-heavy RTS crowd.

## Controls

| Button | Action |
|--|--|
| Left Analog | Move cursor |
| A | Left click |
| B | Right click |
| X (hold) | Slow cursor (precise placement) |
| Y | Go to event |
| D-Pad | Scroll map |
| L1 | Iterate selection |
| L2 | Pause |
| R1 | View history |
| R2 | Mark map |
| Back | Main menu |

## Compile

```
git clone https://github.com/Cebion/glob2_pm.git
cd glob2_pm
```

### Dependencies

```
apt-get install -y libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libsdl2-net-dev \
  libboost-all-dev fribidi libfribidi-dev libspeex-dev libvorbis-dev libogg-dev zlib1g-dev
```

### Build

Globulation 2 uses SCons rather than CMake/autotools:

```
scons -j$(nproc)
```

If the build fails with `SDL_ttf.h: No such file or directory`, your SDL2_ttf headers are
installed under a different prefix than SDL2 itself is; point the compiler at them directly:

```
scons -j$(nproc) CXXFLAGS="-g -I/usr/local/include/SDL2"
```

The resulting binary is `build/src/glob2`.
