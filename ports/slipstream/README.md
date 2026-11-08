## Notes

Thanks to [ansdor](https://www.ansdor.com/) for Slipstream, an early-90s style arcade racer where tucking in behind a rival slingshots you past them.

## Linux version

To get the Linux version on any OS, open `steam://open/console` in a browser and enter:

```
download_depot 732810 732812
```

When Steam prints "Depot download complete", the files are in `Steam/steamapps/content/app_732810/depot_732812/`.

## DLC

To install the free Blue Hour DLC, download it on Steam before copying the game, or copy the `assets/content/blue-hour/` folder from the game's folder into `ports/slipstream/gamedata/assets/content/` later. The folder from the Windows version works too.

## Controls

| Button | Action |
|--|--|
| D-pad, left stick | Steer; move in menus |
| A | Confirm |
| B | Back |
| R2 | Accelerate |
| L2 | Brake |
| Y | Rewind |
| Start | Pause |
| Select | Photo mode |
| Select + Start | Quit |

Saves and settings: `ports/slipstream/conf/`.

## Screen

Screen patch by [slipstream-handheld](https://github.com/mxmgorin/slipstream-handheld). Settings in `ports/slipstream/screen.cfg`:

| Line | Effect |
|--|--|
| `SLIPSTREAM_HORIZON=60` | Horizon and car height in races, 0 to 100: higher is lower, 0 centres the horizon; default 60 |
| `SLIPSTREAM_ASPECT=16:9` | Original 16:9 picture with black bars |

## Compile

`libs/libFAudio.so.0` is FAudio 23.10 with the patches in `patches/`, cross-built for aarch64 on Ubuntu 22.04 with `gcc-aarch64-linux-gnu`, `cmake` and `libsdl2-dev:arm64` installed:

```bash
git clone --depth 1 --branch 23.10 https://github.com/FNA-XNA/FAudio
cd FAudio
git apply ../patches/faudio-sdl-2.0.patch ../patches/faudio-1024-quantum.patch ../patches/faudio-song-no-device.patch
cmake -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
  -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
  "-DSDL2_INCLUDE_DIRS=/usr/include/SDL2;/usr/include/aarch64-linux-gnu" \
  -DSDL2_LIBRARIES=/usr/lib/aarch64-linux-gnu/libSDL2.so
cmake --build build
aarch64-linux-gnu-strip --strip-unneeded -o libFAudio.so.0 build/libFAudio.so.0
```

`libs/libFNA3D.so.0` is FNA3D 23.10 from the Mute Crimson DX port with `patches/fna3d-highp.py` applied:

```bash
python3 patches/fna3d-highp.py libs/libFNA3D.so.0
```

`patches/aspect/` is built from [slipstream-handheld](https://github.com/mxmgorin/slipstream-handheld) at commit `bb7820e`, as its README describes.
