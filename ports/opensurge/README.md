## Notes

Thanks to [Alexandre Martins](https://github.com/alemart/opensurge) for Open Surge, a fast-paced retro platformer in the spirit of the classic 16-bit Sonic games that doubles as a full game creation system.

Open Surge also runs games other people have made with it. Drop a game's `.zip`/`.7z` file or folder into `opensurge/games/`, and a menu appears on launch to choose between Surge the Rabbit and your added games (A to start, B to quit).

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Analog | Move / navigate menus |
| A / X / Y | Jump / confirm |
| B | Cancel |
| Start | Pause / confirm |
| Select | Back |
| Start + Select | Quit |

## Compile

Patches and helper files are in `patches/`. Run the steps below from the folder containing it.

### 1. PhysicsFS 3.2.0

Needed to open game `.zip` files that keep the game inside a subfolder (`PHYSFS_setRoot`, added in 3.2.0).

```bash
git clone --branch release-3.2.0 --depth 1 https://github.com/icculus/physfs.git
cmake -S physfs -B physfs/build -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/deps \
  -DPHYSFS_BUILD_STATIC=OFF -DPHYSFS_BUILD_TEST=OFF -DPHYSFS_BUILD_DOCS=OFF \
  "-DCMAKE_C_FLAGS=-include $PWD/patches/glibc-compat.h"
cmake --build physfs/build -j$(nproc)
cmake --install physfs/build
```

### 2. Allegro 5.2.11.3 (SDL2 backend, GLES2)

The patch fixes textures going blank after a display resize on the SDL backend (the backend restores every texture from its memory copy, which is only refreshed on flip, so images loaded since the last flip were replaced with empty data), and makes the SDL audio buffer size configurable (`[sdl] buffer_size` in `allegro5.cfg`), because the hardcoded 4096-sample buffer matches Open Surge's whole music stream buffer and leaves no headroom. `glibc-compat.h` pins `hypotf` to its pre-2.35 symbol version.

```bash
git clone --branch 5.2.11.3 --depth 1 https://github.com/liballeg/allegro5.git
cd allegro5
git apply ../patches/allegro5-portmaster.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/../deps \
  -DALLEGRO_SDL=ON -DGL_BUILD_TYPE=gles2+ -DWANT_X11=OFF \
  -DWANT_OPENAL=OFF -DWANT_ALSA=OFF -DWANT_PULSEAUDIO=OFF -DWANT_OSS=OFF \
  -DWANT_NATIVE_DIALOG=OFF -DWANT_VIDEO=OFF -DWANT_FLAC=OFF -DWANT_OPUS=OFF \
  -DWANT_DUMB=OFF -DWANT_OPENMPT=OFF -DWANT_MP3=OFF \
  -DWANT_IMAGE_JPG=OFF -DWANT_IMAGE_WEBP=OFF -DWANT_IMAGE_FREEIMAGE=OFF \
  -DWANT_DEMO=OFF -DWANT_EXAMPLES=OFF -DWANT_TESTS=OFF -DWANT_DOCS=OFF \
  -DPHYSFS_INCLUDE_DIR=$PWD/../deps/include -DPHYSFS_LIBRARY=$PWD/../deps/lib/libphysfs.so \
  "-DCMAKE_C_FLAGS=-include $PWD/../patches/glibc-compat.h"
cmake --build build -j$(nproc)
cmake --install build
cd ..
```

### 3. SurgeScript 0.6.1 (static)

```bash
git clone --branch v0.6.1 --depth 1 https://github.com/alemart/surgescript.git
cmake -S surgescript -B surgescript/build -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PWD/deps \
  -DWANT_SHARED=OFF -DWANT_EXECUTABLE=OFF
cmake --build surgescript/build -j$(nproc)
cmake --install surgescript/build
```

### 4. Open Surge

The patch adds a `WANT_NATIVE_DIALOG` option. Allegro's native dialog addon needs GTK and isn't available on the SDL backend, so with the option off its message boxes and file choosers become no-ops; errors are still written to `logfile.txt`.

```bash
git clone https://github.com/alemart/opensurge.git
cd opensurge
git checkout bcb3466e
git apply ../patches/opensurge-portmaster.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
  -DGAME_RUNINPLACE=ON -DWANT_GLES=ON -DWANT_NATIVE_DIALOG=OFF -DWANT_PLAYMOD=OFF \
  -DWANT_BUILD_DATE=OFF -DGAME_BUILD_VERSION=portmaster -DSURGESCRIPT_STATIC=ON \
  -DALLEGRO_INCLUDE_PATH=$PWD/../deps/include -DALLEGRO_LIBRARY_PATH=$PWD/../deps/lib \
  -DSURGESCRIPT_INCLUDE_PATH=$PWD/../deps/include -DSURGESCRIPT_LIBRARY_PATH=$PWD/../deps/lib \
  -DPHYSFS_INCDIR=$PWD/../deps/include -DLPHYSFS=$PWD/../deps/lib/libphysfs.so \
  -DCMAKE_SKIP_RPATH=ON
cmake --build build -j$(nproc)
```

Requires SDL2, GLES2/EGL, libpng, freetype and libvorbis development packages. The `opensurge` executable is written to the source folder.
