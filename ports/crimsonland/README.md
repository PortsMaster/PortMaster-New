## Notes

Crimsonland is a top-down arena shooter. This PortMaster package runs the
native Zig rewrite with controller-first handheld controls, compact 640x480 UI
fixes, and twin-stick aim/fire for small Linux handhelds.

The current release package is `aarch64` only and has been tested on RG35XX-H
with muOS. It uses raylib's SDL2 backend with GLES2 and packages the required
ARM64 `libraylib.so`.

This package does not include Crimsonland game data. Copy your own files into
`crimsonland/assets/`:

- `crimson.paq`
- `sfx.paq`
- `music.paq` or loose `music/*.ogg` files, optional

The game can run without music. Sound effects still work when `sfx.paq` is
present.

Thanks to [banteg](https://github.com/banteg/crimson) for this faithful rewrite of Crimsonland.
Modded for handhelds: [jckhng](https://github.com/jckhng/crimson/tree/portmaster-rg35xxh)
Thanks to NotYerAvgPorter, Old Pixel for testing.

## Controls

| Button | Action |
|--|--|
| D-pad / Left stick | Move menu selection / move player |
| A | Confirm / fire with current aim |
| B | Cancel / back |
| X | Backspace on high-score name entry |
| Y | Open perk picker when perks are available |
| L1 / L2 | Reload |
| Right stick | Aim; fire while pushed |
| R1 / R2 | Pointer click fallback |
| Start | Confirm / start |
| Select / Back | Cancel / back |

## Music Files

GOG installs may not include `music.paq`. If your copy has loose OGG music,
place it under:

```text
crimsonland/assets/music/
```

For example:

```text
crimsonland/assets/music/intro.ogg
crimsonland/assets/music/crimson_theme.ogg
crimsonland/assets/music/gt1_ingame.ogg
crimsonland/assets/music/gt2_harppen.ogg
```

## Compile

This release package is built from the native Zig window target:

```sh
cd path/to/crimson/crimson-zig
PKG_CONFIG_LIBDIR=/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig \
C_INCLUDE_PATH=/usr/include:/usr/include/aarch64-linux-gnu:/usr/include/SDL2 \
zig build --prefix zig-out-aarch64 window \
  -Dtarget=aarch64-linux-gnu.2.36 \
  -Dplatform=sdl2 \
  -Dopengl_version=gles_2 \
  -Dlinkage=dynamic \
  -Doptimize=ReleaseFast
```
