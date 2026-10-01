## Notes

Thanks to [Michael Speck](https://lgames.sourceforge.io/LGeneral/) for LGeneral, a faithful open-source take on Panzer General's hex-based operational warfare, complete with entrenchment, supply lines and weather.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move mouse pointer |
| X (hold) | Slow mouse pointer |
| A | Left click |
| B | Right click |
| Y | Undo move |
| D-Pad | Scroll map |
| L1 | Previous unit |
| R1 | Next unit |
| L2 | Strategic map |
| R2 | Toggle air/ground layer |
| Start | Enter / Confirm |
| Back | Escape / Cancel |

## Compile

### 1. Install build dependencies

```bash
apt-get install -y build-essential libsdl1.2-dev
```

### 2. Build a trimmed SDL_mixer 1.2

This is the `libSDL_mixer-1.2.so.0` shipped in `libs.aarch64`. LGeneral only plays WAV sounds, so the distro SDL_mixer's codec dependencies aren't needed.

```bash
curl -sSL -o SDL_mixer-1.2.12.tar.gz https://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-1.2.12.tar.gz
tar xzf SDL_mixer-1.2.12.tar.gz
cd SDL_mixer-1.2.12
./configure --prefix="$(pwd)/../local-sdlmixer" --enable-music-wave \
  --enable-music-mod --disable-music-mod-modplug --disable-music-midi \
  --disable-music-timidity-midi --disable-music-native-midi \
  --disable-music-fluidsynth-midi --enable-music-ogg \
  --disable-music-ogg-tremor --disable-music-flac --disable-music-mp3 \
  --disable-music-cmd
make
make install
cd ..
```

### 3. Build LGeneral and the lgc-pg converter

The `sed` keeps the fullscreen flag on the 800x600 fallback video mode.

```bash
apt-get install -y libsdl-mixer1.2-dev
curl -sSL -o lgeneral-1.4.4.tar.gz https://downloads.sourceforge.net/project/lgeneral/lgeneral/lgeneral-1.4.4.tar.gz
tar xzf lgeneral-1.4.4.tar.gz
cd lgeneral-1.4.4
sed -i 's/SDL_SetVideoMode( 800, 600, 16, SDL_SWSURFACE );/SDL_SetVideoMode( 800, 600, 16, SDL_SWSURFACE | ( flags \& SDL_FULLSCREEN ) );/' src/lg-sdl.c
./configure --build=aarch64-unknown-linux-gnu --disable-install --disable-nls
make
```

This produces `src/lgeneral` and the `lgc-pg` data converter.

### 4. Convert the Panzer General data

`lgc-pg` writes into an LGeneral data tree, here the `src` folder of the build.

```bash
curl -sSL -o pg-data.tar.gz https://downloads.sourceforge.net/project/lgeneral/lgeneral-data/pg-data.tar.gz
tar xzf pg-data.tar.gz
cd lgc-pg
SDL_VIDEODRIVER=dummy ./lgc-pg -s ../pg-data -d ../src
```
