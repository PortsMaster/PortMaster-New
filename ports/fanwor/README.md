## Notes

Thanks to [Thomas Huth](https://fanwor.tuxfamily.org/) for Fanwor, a small top-down action-adventure originally written for a 1999 Atari programming contest, still actively maintained and playable in the style of the classic 2D Zelda games.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move |
| A | Sword / Confirm |
| Back | Quit |

Space (mapped to A) also dismisses the title, game-over, and victory screens.

## Compile

Fanwor needs a trimmed SDL_mixer 1.2 built from source first, since the distro-packaged one
pulls in FluidSynth/FLAC/libmad for codecs this game never plays.

### 1. Install build dependencies

apt-get install -y libsdl1.2-dev libpng-dev zlib1g-dev libvorbis-dev libogg-dev libmikmod-dev

### 2. Build a trimmed SDL_mixer 1.2

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

### 3. Build Fanwor

curl -sSL -o fanwor-1.17.tar.gz https://fanwor.tuxfamily.org/files/fanwor-1.17.tar.gz
tar xzf fanwor-1.17.tar.gz
cd fanwor-1.17

Edit `src/Makefile`'s `CFL_sdl`/`LIBS_sdl` to add `-I../local-sdlmixer/include/SDL` and
`-L../local-sdlmixer/lib` for `SDL_mixer.h`/`libSDL_mixer` (SDL 1.2 itself is already picked up
via the system `sdl-config`), then:

make
