# wiliwili for ROCKNIX

A gamepad-friendly Bilibili client for handheld gaming devices.

* **Application**: [wiliwili](https://github.com/xfangfang/wiliwili) by
  [xfangfang](https://github.com/xfangfang), licensed under GPL-3.0.
* **ROCKNIX port, packaging and library set**: 南宫镜.

## Controls

| Button | Action |
|---|---|
| D-Pad / Left stick | Navigate |
| A | Confirm / Play |
| B | Back / Cancel |
| X | Search / secondary action |
| Y | Filter / options |
| Select + Start | Quit (PortMaster / gptokeyb hotkey) |

## Requirements

* aarch64 (arm64) ROCKNIX build, glibc >= 2.38
* active Wi-Fi connection
* a Bilibili account for video playback (log in inside the app)

## UI scale

The port ships a **480p (640x480)** UI preset.  The interface is laid out on a
640x480 canvas and then scaled to the panel, so it is pixel perfect at 1x on a
640x480 screen and stays crisp at any integer multiple of it (2x on 1280x960,
3x on 1920x1440, ...).  The preset can be changed in
*Settings → App → UI Scale*; the other presets are 720p, 900p and 1080p.

## Files

| Path | Content |
|---|---|
| `Wiliwili.sh` | launch script (started by EmulationStation) |
| `wiliwili/wiliwili.aarch64` | the application binary |
| `wiliwili/libs.aarch64/` | bundled `libmpv.so.2` and its FFmpeg 6 dependency closure |
| `wiliwili/resources/` | themes, fonts, translations, gamepad database |
| `wiliwili/conf/` | user data: login cookies, settings, cache, `log.txt` |
| `wiliwili/conf/videodriver` | optional: pin the SDL video driver (`wayland` / `kmsdrm`) |

The compositor, graphics, audio and system libraries are intentionally *not*
bundled, so the port uses the device versions that match the driver stack.

## Log / troubleshooting

The launcher writes its output to `wiliwili/log.txt` (environment, glibc,
`/dev/dri`, Wayland sockets, per-driver results) and tries
`wayland -> kmsdrm -> offscreen`.  On a failed Wayland attempt it captures a
Wayland protocol trace to `wiliwili/log-wayland-trace.txt` and quotes the head
and tail of it in `log.txt`.

See `使用说明.md` for the full notes (in Chinese).
