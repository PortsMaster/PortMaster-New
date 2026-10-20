## Notes

Thanks to [Martin Stransky and AnakreoN](https://anakreon.cz/berusky1.html) for Berusky, a Sokoban-style puzzle game where you steer up to five ladybugs through about 120 levels of boxes, explosives, stones and colour doors.

The menus are mouse-driven, so the left stick moves a cursor and A clicks. The level editor and the desktop display settings are left out of the main menu. Profiles, progress and settings are stored in `conf/.berusky`.

## Controls

| Button | Action |
|--|--|
| Left Analog | Mouse cursor in menus |
| A | Left click |
| X (hold) | Slow cursor |
| D-Pad | Move the ladybug |
| B / Select | Pause menu |
| Y | Next ladybug |
| L1 | Save position |
| R1 | Load position |
| L2 (hold) | Fast move |
| R2 | Restart level |
| R2 (hold) + D-Pad | Move the cursor on devices without an analog stick (restart is then in the pause menu) |
| Start | Help |
| Select + Start | Quit |

## Compile

Built in an Ubuntu 22.04 aarch64 chroot from upstream commit `7d2d4e4` (1.7.2). `patches/berusky-portmaster.patch` removes the unused GTK2 dependency. With `-DPORTMASTER` it also always runs fullscreen at 640x480, hides the editor and settings menu entries (settings only held the desktop fullscreen and high-resolution toggles), and draws its own mouse cursor, because not every CFW's SDL2 shows one. The cursor hides when the D-pad is used. The game is built against the system SDL 1.2. At runtime it uses the bundled [sdl12-compat](https://github.com/libsdl-org/sdl12-compat) on top of the device's SDL2.

### 1. Berusky

```bash
apt-get install -y autoconf automake libtool libsdl1.2-dev libsdl-image1.2-dev
git clone https://github.com/stransky/berusky.git
cd berusky
git checkout 7d2d4e4
git apply ../patches/berusky-portmaster.patch
autoreconf -fi
./configure --prefix=/usr
make -j$(nproc) CXXFLAGS="-O2 -std=gnu++14 -DPORTMASTER"
strip src/berusky
cd ..
```

`-std=gnu++14` is needed because the code's own `byte` type clashes with C++17's `std::byte`.

### 2. sdl12-compat (shipped as `libSDL-1.2.so.0`)

```bash
git clone https://github.com/libsdl-org/sdl12-compat.git
cd sdl12-compat
git checkout 5a0aac8
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
cd ../..
```

### 3. SDL_image 1.2.12 (PNG only)

Berusky only loads `.png` graphics, so every other codec is disabled.

```bash
curl -sL -o SDL_image-1.2.12.tar.gz "https://www.libsdl.org/projects/SDL_image/release/SDL_image-1.2.12.tar.gz"
tar xzf SDL_image-1.2.12.tar.gz
cd SDL_image-1.2.12
cp /usr/share/automake-1.16/config.guess /usr/share/automake-1.16/config.sub .
chmod +x config.guess config.sub
./configure --prefix=/opt/sdl-image-1.2 \
  --disable-bmp --disable-gif --disable-jpg --disable-jpg-shared \
  --disable-lbm --disable-pcx --disable-pnm --disable-tga --disable-tif --disable-tif-shared \
  --disable-xcf --disable-xpm --disable-xv --disable-webp --disable-webp-shared \
  --enable-png --disable-png-shared
make -j$(nproc)
make install
cd ..
```
