## Notes

Thanks to [Martin Stransky, Michal Simonik and AnakreoN](https://anakreon.cz/berusky2.html) for Berusky 2 (Bugs Escape 3D), the 3D sequel to Berusky that turns its ladybug Sokoban puzzles into multi-floor levels with lifts, teleports and a free camera.

The game data (from Debian's `berusky2-data` 0.12) is unpacked on the first launch, which takes a few minutes. 
The menus are mouse-driven, so the left stick moves a cursor and A clicks. The loading-screen tips name the gamepad buttons below instead of keyboard keys. 
Profiles, saves and settings are stored in `conf/.berusky2`. Player names are typed with the on-screen keyboard on L2.

## Controls

| Button | Action |
|--|--|
| Left Analog | Mouse cursor |
| A | Left click (select a bug, menus) |
| B | Right click (show what an element is) |
| X (hold) | Slow cursor |
| D-Pad | Move the selected bug |
| Y | Next bug |
| L1 (hold) + Left Analog | Move the camera |
| R1 (hold) + Left Analog | Rotate the camera |
| Right Analog Left / Right | Rotate the camera |
| Right Analog Up / Down | Tilt the camera |
| L2 | On-screen keyboard |
| L3 | Transparency of elements |
| R3 | Diagram of teleports and lifts |
| Start | Menu |
| Select | Help |
| R2 (hold) + Up / Down | Zoom in / out |
| R2 (hold) + Left / Right | Turn the camera 90° |
| R2 (hold) + Y | Center the camera |
| R2 (hold) + A / B | Save / load position |
| R2 (hold) + X | Restart level |
| R2 (hold) + L1 | Illuminate dynamic elements |
| R2 (hold) + R1 | Next music track |
| R2 (hold) + L3 / R3 | Toggle the navigation bars |
| R2 (hold) + Start | Block / unblock automatic hack use |
| R2 (hold) + Select | Screenshot |
| R2 (hold) + D-Pad | Move the cursor on devices without an analog stick (the R2 camera layer is then not available) |
| Select + Start | Quit |

On-screen keyboard: D-Pad moves, A (or R1) types the letter or presses Close, B (or L1) deletes, Y switches letters/numbers, L2 closes it.

## Compile

Built in an Ubuntu 22.04 aarch64 chroot from upstream commit `7f3614a` (0.12). `patches/berusky2-portmaster.patch` drops the X11 and GLU link dependencies. With `-DPORTMASTER` it always runs fullscreen at the screen's resolution, skips the X11 bitmap font (only used by the debug console), and replaces the one GLU call (`gluBuild1DMipmaps`) with a small inline version, because Ubuntu's GLU needs GLVND's `libOpenGL.so.0`, which gl4es doesn't provide. It also hides the system cursor with a blank cursor shape instead of `SDL_ShowCursor(0)`: sdl12-compat switches a fullscreen window with a hidden cursor into relative mouse mode, and under sway (ROCKNIX) the deltas stop at wherever the real pointer meets the screen edge, so parts of the screen couldn't be clicked. Home/End/Page Up/Page Down (the right stick) rotate and tilt the camera with the game's own screen-edge rotation code. The game is built against the system SDL 1.2 and desktop OpenGL headers. At runtime it uses the bundled [sdl12-compat](https://github.com/libsdl-org/sdl12-compat) on top of the device's SDL2, and [gl4es](https://github.com/ptitSeb/gl4es) for OpenGL.

### 1. Berusky 2

```bash
apt-get install -y autoconf automake libtool gettext libglib2.0-dev libsdl1.2-dev libsdl-image1.2-dev \
  libgl-dev libglu1-mesa-dev zlib1g-dev libopenal-dev libalut-dev libvorbis-dev
git clone https://github.com/stransky/berusky2.git
cd berusky2
git checkout 7f3614a
git apply ../patches/berusky2-portmaster.patch
autoreconf -fi
./configure CFLAGS="-O2 -DPORTMASTER" CXXFLAGS="-O2 -DPORTMASTER"
make -j$(nproc)
strip -o berusky2.aarch64 src/berusky2
cd ..
```

### 2. sdl12-compat (shipped as `libSDL-1.2.so.0`)

```bash
git clone https://github.com/Cebion/sdl12-compat.git
cd sdl12-compat
git checkout 9cb008f
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
cd ..
```

### 3. SDL_image 1.2.12 (PNG and BMP only, shipped as `libSDL_image-1.2.so.0`)

The textures are PNG files and the lightmaps inside each level's `.b2l` are BMP images, so every other codec is disabled.

```bash
curl -sL -o SDL_image-1.2.12.tar.gz "https://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz"
tar xzf SDL_image-1.2.12.tar.gz
cd SDL_image-1.2.12
cp /usr/share/automake-1.16/config.guess /usr/share/automake-1.16/config.sub .
chmod +x config.guess config.sub
./configure --prefix=/opt/sdl-image-1.2 \
  --enable-bmp --disable-gif --disable-jpg --disable-jpg-shared \
  --disable-lbm --disable-pcx --disable-pnm --disable-tga --disable-tif --disable-tif-shared \
  --disable-xcf --disable-xpm --disable-xv --disable-webp --disable-webp-shared \
  --enable-png --disable-png-shared
make -j$(nproc)
make install
cd ..
```

### 4. gl4es (shipped in `gl4es.aarch64/`)

```bash
apt-get install -y libdrm-dev libgbm-dev libegl-dev
git clone https://github.com/ptitSeb/gl4es.git
cd gl4es
git checkout 17f0894
mkdir build && cd build
cmake .. -DNOX11=ON -DGLX_STUBS=ON -DEGL_WRAPPER=ON -DGBM=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo
make -j$(nproc)
cd ../..
```

### 5. OmniOSK (shipped as `libomni_osk.so`)

`patches/omniosk-sdl12-gl.patch` adds what an `SDL_OPENGL` game reached through sdl12-compat needs: the overlay draws into the game's GL context from an `SDL_GL_SwapBuffers` hook instead of creating an SDL renderer on its window, and typed letters are written into the game's SDL 1.2 event buffer with `keysym.unicode` set, each press held for 60 ms like a real key, because Berusky 2 reads text from key events rather than `SDL_GetKeyState()`. While the keyboard is open, a left click (A) presses the focused key and a right click (B) deletes, since the overlay otherwise swallows the clicks that A and B send. ImGui's `imgui.ini` is turned off so nothing is written into the game's folders. The patch also includes the `OMNI_PAD` changes made for another port.

```bash
apt-get install -y cmake libsdl2-dev libgles-dev
git clone -b sdl2 https://github.com/Cebion/OmniOSK.git
cd OmniOSK
git checkout 623739f
git apply ../patches/omniosk-sdl12-gl.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DOMNI_SDL12_BRIDGE=ON -DOMNI_SDL12_INCLUDE_DIR=/usr/include
cmake --build build -j$(nproc)
cd ..
```

### 6. Game data

`patches/berusky2-data-gamepad-texts.patch` rewrites the loading-screen tips that name keyboard keys or the mouse. The same file exists in five font folders. The unused intro video is left out. The archive is split into 95MB pieces to stay under GitHub's 100MB limit; the launch script joins them with `cat` before extracting.

```bash
curl -sLO http://deb.debian.org/debian/pool/main/b/berusky2-data/berusky2-data_0.12.orig.tar.xz
tar xJf berusky2-data_0.12.orig.tar.xz
mkdir gamedata
cd berusky2-data-0.12
cp -a bitmap data game game_data items materials music out sound textures ../gamedata/
cd ..
rm gamedata/bitmap/AnakreoN.mpg
for d in font_en font3d_en font_system_en font_system2_en font_system3d_en; do
  patch "gamedata/bitmap/$d/texts.txt" patches/berusky2-data-gamepad-texts.patch
done
tar czf - --owner=0 --group=0 --numeric-owner gamedata | split -b 95M -d -a 2 - gamedata.tar.gz.part
```
