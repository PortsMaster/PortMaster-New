# Bully: Anniversary Edition

AArch64 PortMaster port of the Android release using the NextOS native
`libGame.so` loader. Rockstar game files are not included.

## Installation

Install `bully.zip` with PortMaster. Then copy one complete, legally owned
Bully: Anniversary Edition **1.4.311 ARM64** source to:

```text
roms/ports/bully/gamedata/
```

Supported inputs are a complete merged APK, all APK splits from the same full
installation, or an APKS/APKM/XAPK bundle. Launch the game once to extract the
required files. The source archive is kept so the user can delete or archive it
after a successful launch.

Existing extracted game data and saves are not part of the port ZIP, so a
PortMaster update does not remove them.

## Controls

Native SDL is the default and follows the standard Xbox/SDL positions:

| Button | Position / action |
|---|---|
| A | Bottom; attack / confirm |
| B | Right; jump / cancel |
| X | Left |
| Y | Top |
| L1 / R1 | Aim / fire or throw |
| L2 / R2 | Previous / next item |
| Left stick | Analog movement and running |
| Right stick | Camera |
| Start | Pause |
| Select + Start | Exit |

Printed A/B/X/Y labels vary between handheld shells even when SDL reports the
same physical positions. Users who prefer their printed labels can set
`use_gptk=on` in `bully.conf` and edit `bully.gptk`.

## Configuration

Edit `roms/ports/bully/bully.conf`:

| Key | Values |
|---|---|
| `renderer` | `auto`, `es2`, `es3` |
| `render_scale` | `auto`, `profile`, `0.5`, `0.75`, `1.0` |
| `textures` | `auto`, `low`, `medium`, `high` |
| `trilinear` | `auto`, `on`, `off` |
| `stream_distance` | `auto`, `50`, `60`, `70`, `75`, `80`, `100` |
| `face_buttons` | `auto`, `normal`, `swap_xy`, `swap_ab`, `swap_both` |
| `shadows` | `off`, `on` |
| `use_gptk` | `off`, `on` |

Native deferred shadows are available only when RendererES3 is active. The
in-game Shadows row is intentionally limited to Off/On. RendererES2 keeps the
original no-shadow compatibility path and safely ignores `shadows=on`.

Automatic profiles select GLES2/GLES3, render scale, textures and streaming
according to available memory. The GLES2 low-memory profile remains the default
compatibility path for 1 GB devices.

## Tested systems

- ArkOS / dArkOS
- AmberELEC / EmuELEC / NextOS
- Knulli
- muOS
- ROCKNIX
- CrossMix OS

Community testing covered RK3326, H700, RK3566, Amlogic Mali-450 and Mali-G310
devices at 640x480, 720x720, 1280x720 and 1920x1080. AArch64 and OpenGL ES
2.0 are required.

## Legal notice

This is a BYO-data compatibility port. It does not distribute the APK,
`libGame.so` or Rockstar assets. See `bully/licenses/` for the loader and
bundled-library notices.

## Thanks

Thanks to Rockstar Games for creating Bully and to the PortMaster community
members who tested the port across many handhelds and custom firmwares.
