## Notes

Thanks to [Jon Rafkind](https://raptorv2.sourceforge.net/) for Rafkill, a free vertical shooter in the spirit of Raptor: Call of the Shadows, with a between-mission shop for buying weapons and hulls.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move, menu navigation |
| A | Fire, menu select |
| B | Switch accessory weapon |
| Start | Pause |
| Select | Back in menus, leave the level |

## Compile

The game runs on the Allegro 4 API through [Allegro Legacy](https://github.com/NewCreature/Allegro-Legacy) on Allegro 5's SDL2 backend (GLES2), with DUMB 0.9.3 for the music. Run everything from one folder with `patches/` next to the clones.

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

The patch fixes the timer speed when a parameter timer reuses a freed slot (the value was passed in Allegro 4 ticks instead of seconds).

### 3. DUMB 0.9.3 (static, against Allegro Legacy)

```bash
wget https://downloads.sourceforge.net/project/dumb/dumb/0.9.3/dumb-0.9.3.tar.gz
tar xzf dumb-0.9.3.tar.gz
cd dumb-0.9.3
R=$PWD/..; A5=$R/allegro5
INC="-Iinclude -I$R/allegro-legacy/build-pm/include -I$R/allegro-legacy/include -I$A5/build-pm/include -I$A5/include -I$A5/addons/audio -I$A5/addons/image -I$A5/addons/font -I$A5/addons/primitives -I$A5/addons/acodec"
mkdir -p obj/core obj/al lib
for f in src/core/*.c src/helpers/*.c src/it/*.c; do gcc -O2 -fPIC -w -include $R/patches/glibc-compat.h -Iinclude -c $f -o obj/core/$(basename $f .c).o; done
for f in src/allegro/*.c; do gcc -O2 -fPIC -w -include $R/patches/glibc-compat.h $INC -c $f -o obj/al/$(basename $f .c).o; done
ar rcs lib/libdumb.a obj/core/*.o
ar rcs lib/libaldmb.a obj/al/*.o
cd ..
```

### 4. Rafkill

```bash
wget "https://downloads.sourceforge.net/project/raptorv2/raptorv2/rafkill%201.2.3/rafkill-1.2.3.tar.gz"
tar xzf rafkill-1.2.3.tar.gz
cd rafkill-1.2.3
patch -p1 < ../patches/rafkill-portmaster.patch
make -f Makefile.pm -j$(nproc)
```

This produces `rafkill.aarch64`. The libraries to ship are `allegro-legacy/build-pm/lib/liballeg.so.4.4` and `allegro5/build-pm/lib/liballegro.so.5.2` and `liballegro_audio.so.5.2`.
