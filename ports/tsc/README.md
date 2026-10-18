## Notes

Thanks to [the Secret Chronicles team](https://github.com/Secretchronicles/TSC) for The Secret Chronicles of Dr. M., a colourful Secret Maryo Chronicles fork that grew its own art, music, overworld and a scriptable level editor.

## Controls

| Button | Action |
|--|--|
| D-Pad | Move, navigate menus |
| Left Stick | Move mouse cursor |
| A | Shoot, confirm in menus |
| B | Jump |
| Y | Action (run, carry, use) |
| X | Use reserve item |
| R1 | Left click |
| L1 | Right click |
| Start | Confirm in menus |
| Select | Back, pause menu |
| Start + Select | Quit |

## Compile

### 1. Dependencies

```bash
apt-get install -y build-essential cmake pkg-config bison ruby rake gettext \
  libxml++2.6-dev libglew-dev libpng-dev libfreetype-dev libboost-filesystem-dev \
  libboost-chrono-dev libboost-thread-dev libgl-dev libx11-dev libxrandr-dev \
  libxcursor-dev libxi-dev libudev-dev libopenal-dev libvorbis-dev libflac-dev
```

### 2. SFML 3.0.2 (X11 backend)

`patches/sfml-joystick-no-retry.patch` stops SFML from retrying a joystick it could not open on every event poll. Westonpack refuses SFML access to the real controllers, and each refused open and close costs a kernel wait, which made the game choppy on ROCKNIX. `patches/sfml-miniaudio-pulse-format.patch` lets PulseAudio convert miniaudio's float output when the sink's own format (`s24-32le` on PipeWire) is one miniaudio cannot use, instead of failing with no sound. `patches/sfml-glx-default-visual.patch` uses the screen's default visual when the GLX layer reports no double-buffered visual (released Westonpack's Crusty 0.4), instead of creating the window with a null visual that X rejects.

```bash
wget -O sfml-3.0.2.tar.gz https://github.com/SFML/SFML/archive/refs/tags/3.0.2.tar.gz
tar xzf sfml-3.0.2.tar.gz
patch -d SFML-3.0.2 -p1 < patches/sfml-joystick-no-retry.patch
patch -d SFML-3.0.2 -p1 < patches/sfml-miniaudio-pulse-format.patch
patch -d SFML-3.0.2 -p1 < patches/sfml-glx-default-visual.patch
cmake -S SFML-3.0.2 -B SFML-3.0.2/build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PWD/sfml3 -DBUILD_SHARED_LIBS=ON \
  -DSFML_BUILD_EXAMPLES=OFF -DSFML_BUILD_DOC=OFF -DSFML_BUILD_NETWORK=OFF \
  -DSFML_USE_DRM=OFF -DSFML_USE_SYSTEM_DEPS=ON
cmake --build SFML-3.0.2/build -j$(nproc)
cmake --install SFML-3.0.2/build
```

### 3. TSC

`SFML_INCLUDE_DIRS` is set by hand because TSC's `FindSFML.cmake` finds the `include/SFML` folder, which only works when SFML is on a default include path. `patches/hypot_compat.c` binds `hypot` to its older symbol version, so the binary needs glibc 2.34 instead of 2.35. `patches/tsc-gui-and-memory.patch` loads the editors' background previews and item palettes when they are first shown instead of at startup (several hundred MB of textures a 1 GB device cannot hold), and turns off depth testing for CEGUI so menus and text boxes are visible when the context has a depth buffer.

```bash
git clone --recurse-submodules https://github.com/Secretchronicles/TSC.git
git -C TSC apply ../patches/tsc-gui-and-memory.patch
mkdir tsc-build && cd tsc-build
gcc -O2 -c ../patches/hypot_compat.c -o hypot_compat.o
PKG_CONFIG_PATH=$PWD/../sfml3/lib/pkgconfig cmake ../TSC/tsc \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PWD/../sfml3 \
  -DSFML_INCLUDE_DIRS=$PWD/../sfml3/include \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,--wrap=hypot $PWD/hypot_compat.o" \
  -DCMAKE_INSTALL_PREFIX=$PWD/stage
make -j$(nproc)
make install
```
