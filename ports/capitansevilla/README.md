## Notes

Thanks to [Computeremuzone Games Studio](https://computeremuzone.com/ficha/754/capitan-sevilla---el-remake?l=en) (code by Luis I. García Ventura, graphics by Daniel Celemín) for this loving remake of Dinamic's 1988 Spanish superhero platformer, with a blood-sausage-powered hero who switches between Mariano and Captain 'S'.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move, crouch, menus |
| A | Fire / confirm in menus |
| B | Jump |
| X / Y | Transform (eat a sausage) / confirm |
| Start | Confirm |
| Select | Abort game / back |
| L2 | On-screen keyboard (password) |
| R1 | Delete letter (password) |

## Compile

The game runs on the Allegro 4 API through [Allegro Legacy](https://github.com/NewCreature/Allegro-Legacy) on Allegro 5's SDL2 backend (GLES2). Run from this port's folder, so `patches/` sits next to the clones.

### 1. Allegro 5 (SDL2 + GLES2, audio addon only)

```bash
git clone --branch 5.2.11.3 --depth 1 https://github.com/liballeg/allegro5.git
cd allegro5
patch -p1 < ../patches/allegro5-portmaster.patch
cmake -S . -B build-pm -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DALLEGRO_SDL=ON -DGL_BUILD_TYPE=gles2+ \
  -DWANT_X11=OFF -DWANT_OPENAL=OFF -DWANT_PULSEAUDIO=OFF -DWANT_ALSA=OFF -DWANT_OSS=OFF \
  -DWANT_FONT=OFF -DWANT_IMAGE=OFF -DWANT_TTF=OFF -DWANT_COLOR=OFF -DWANT_MEMFILE=OFF \
  -DWANT_PHYSFS=OFF -DWANT_PRIMITIVES=OFF -DWANT_NATIVE_DIALOG=OFF -DWANT_VIDEO=OFF \
  -DWANT_FLAC=OFF -DWANT_VORBIS=OFF -DWANT_OPUS=OFF -DWANT_MP3=OFF -DWANT_DUMB=OFF -DWANT_OPENMPT=OFF \
  -DWANT_DOCS=OFF -DWANT_DEMO=OFF -DWANT_EXAMPLES=OFF -DWANT_TESTS=OFF \
  "-DCMAKE_C_FLAGS=-include $PWD/../patches/glibc-compat.h"
ninja -C build-pm
cd ..
```

The patch reads `[sdl] buffer_size` from `allegro5.cfg`, keeps bitmaps intact across a display resize, and ignores SDL pad events while the joystick driver isn't installed (the game leaves input to gptokeyb2).

### 2. Allegro Legacy

```bash
git clone https://github.com/NewCreature/Allegro-Legacy.git allegro-legacy
git -C allegro-legacy checkout 01512019f083919f0d6e66c53fd068f1bd455f39
git -C allegro-legacy apply ../patches/allegro-legacy-portmaster.patch
A5=$PWD/allegro5
INC="-I$A5/include -I$A5/build-pm/include -I$A5/addons/audio -I$A5/addons/image -I$A5/addons/font -I$A5/addons/primitives -I$A5/addons/acodec"
cmake -S allegro-legacy -B allegro-legacy/build-pm -G Ninja -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_BUILD_TYPE=Release -DWANT_MODULES=OFF -DCMAKE_SKIP_RPATH=ON \
  -DALLEGRO_5_LIBRARY=$A5/build-pm/lib/liballegro.so -DALLEGRO_5_AUDIO_LIBRARY=$A5/build-pm/lib/liballegro_audio.so \
  -DALLEGRO_5_MAIN_LIBRARY= "-DCMAKE_C_FLAGS=$INC" "-DCMAKE_CXX_FLAGS=$INC"
ninja -C allegro-legacy/build-pm allegro
```

The patch fixes the timer speed when a parameter timer reuses a freed slot (the value was passed in Allegro 4 ticks instead of seconds), which left every music track after the first one silent.

### 3. Capitán Sevilla

```bash
wget https://computeremuzone.com/pc/Capitan.tar.bz2
tar xjf Capitan.tar.bz2
cp patches/allegro-flags.mk .
sed -i "s#^SEV = .*#SEV = $PWD#" allegro-flags.mk
cd capitan-1.0.3
patch -p1 < ../patches/capitan-portmaster.patch
A5=$PWD/../allegro5; AL=$PWD/../allegro-legacy
AL_INC="-I$AL/build-pm/include -I$AL/include -I$A5/build-pm/include -I$A5/include -I$A5/addons/audio -I$A5/addons/image -I$A5/addons/font -I$A5/addons/primitives -I$A5/addons/acodec"
(cd dependencies/alfont && mkdir -p obj/linux/static lib/linux && make CFLAGS="-O2 -fPIC -Ifreetype/include -Iinclude $AL_INC")
(cd dependencies/alogg && mkdir -p obj/linux/static lib/linux && make CFLAGS="-O2 -fPIC -Idecoder -Iinclude -Idecoder/libvorbis/include -Idecoder/libogg/include $AL_INC")
cp dependencies/alfont/lib/linux/libalfont.a dependencies/alogg/lib/linux/libalogg.a lib/
cp dependencies/alfont/include/*.h dependencies/alogg/include/*.h include/
mkdir -p src/obj
make
```

This produces `capitan.aarch64`. The libraries to ship are `allegro-legacy/build-pm/lib/liballeg.so.4.4` and `allegro5/build-pm/lib/liballegro.so.5.2` and `liballegro_audio.so.5.2`.
