## Notes

Thanks to [Marc Le Douarain](https://sites.google.com/site/mavati56/marryampic2) for
Marryampic2, a memory/pairs card game where pairs are found by sound as much as by sight.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move cursor |
| A | Click / select |
| B | Right-click (decrease value in setup) |
| X (hold) | Slow cursor, for precise clicks |
| Y | Replay sound |
| Back | Quit |

## Compile

### 1. Install build dependencies

```bash
apt-get install -y libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev
```

### 2. Build a trimmed SDL_image 1.2

```bash
apt-get source libsdl-image1.2
cd sdl-image1.2-1.2.12
cp /usr/share/misc/config.guess /usr/share/misc/config.sub .
./configure --disable-tif --disable-webp --disable-static --enable-shared
make
```

### 3. Build a trimmed SDL_mixer 1.2

```bash
curl -sSL -o SDL_mixer-1.2.12.tar.gz https://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-1.2.12.tar.gz
tar xzf SDL_mixer-1.2.12.tar.gz
cd SDL_mixer-1.2.12
./configure --prefix="$(pwd)/../local-sdlmixer" --disable-music-mod --disable-music-midi \
  --disable-music-timidity-midi --disable-music-native-midi \
  --disable-music-fluidsynth-midi --disable-music-ogg --disable-music-ogg-tremor \
  --disable-music-flac --disable-music-mp3 --disable-music-cmd
make
make install
cd ..
```

### 4. Build a patched sdl12-compat

```bash
git clone https://github.com/libsdl-org/sdl12-compat
cd sdl12-compat
```

Edit `src/SDL12_compat.c`'s `ShouldUseOpenGL()` to just `return SDL_FALSE;` - it otherwise forces
every window onto an OpenGL path whenever the default SDL2 render driver is GL-named, even for
this non-GL app, which crashes in `libmali.so.1` on some devices.

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo
make
cd ../..
```

### 5. Build Marryampic2

```bash
git clone git@github.com:Cebion/marryampic2.git
cd marryampic2
make
```
