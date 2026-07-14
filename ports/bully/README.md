# Bully: Anniversary Edition - NextOS Final

This is an AArch64 PortMaster compatibility package for the Android release of
Bully: Anniversary Edition. It contains the NextOS loader, launcher, metadata
and setup helpers. It does **not** contain Rockstar runtime game code or runtime
game data; the frontend metadata includes the documented preview images.

Required game version: **1.4.311, arm64-v8a**. Other versions are not supported.

## Notes and credits

This port requires a complete, legally owned ARM64 Android copy of Bully:
Anniversary Edition. Rockstar game code and runtime data are not included.

Thanks to Rockstar Games, Rockstar New England and War Drum Studios for
creating Bully: Anniversary Edition. Thanks to the PortMaster team, mtojek and
givethesourceplox for the projects and code that made this compatibility port
possible. Port and packaging work by NextOS.

## PortMaster autoinstall

Copy the complete ZIP without extracting it to `roms/ports/autoinstall/`, then
open PortMaster. HarbourMaster automatically installs `Bully.sh` and the
`bully/` directory just like an official port. The same flow can update an
existing installation: extracted game data, `bully.conf`, `bully.gptk` and
saves are not shipped in the ZIP and remain untouched.

After autoinstall, place your legal source in `roms/ports/bully/gamedata/` as
described below. Autoinstall installs only the port; it does not download or
include Rockstar files.

## First setup

Put one complete, legally owned source in `roms/ports/bully/gamedata/`:

- a complete merged APK containing `lib/arm64-v8a` and `data_0` through `data_4`;
- every APK path returned for a fully purchased Play Store installation,
  including the base, arm64 and all `split_data_*` APKs; or
- one complete `.apks`, `.apkm` or `.xapk` export of that installation.

For Play Store splits, list and copy **every** returned APK, not only
`split_data_1.apk`:

```text
adb shell pm path com.rockstargames.bully
adb pull "<each path printed by the command>"
```

An export made from the limited trial is incomplete because it lacks later data
archives. Use a fully purchased copy. Keep at least 6 GB free during first
setup; replacing an invalid old payload can require additional rollback space.

Launch Bully from Ports. The setup screen appears before the full source CRC
pass and shows separate validation and extraction progress. It then extracts
the required library and `data_0` through `data_4`, creates the local menu patch
and starts the game. The package itself never supplies those files.

The screen is optional feedback, not part of the transaction. If SDL or the
display backend is unavailable, setup continues headless and records the same
work in `roms/ports/bully/setup.log`.

Only after every check and the final commit succeed does setup remove each
copied APK, split or bundle that actually supplied selected libraries or data.
Unused source archives, installed data, profiles and saves are not removed.

## Updating from V11

Install the Final build over the existing `bully/` directory. Do not delete the
directory: the release archive contains no extracted game data, profiles or
saves and does not overwrite them. A complete V11 installation should start
without another extraction. If only `assets/` was copied from an older
installation, setup still needs the legal source to recover `libGame.so` and
`libc++_shared.so`.

A fresh installation is not required. The Final build validates a complete V11
payload, generates the menu patch and writes its marker without asking for the
APK again. The legal source is requested only when the old payload is
incomplete, modified or damaged.

## Controls

| Control | Action |
|---|---|
| D-pad / Left stick | Move and navigate |
| Right stick | Camera |
| A | Attack / confirm |
| B | Jump / cancel |
| L1 / R1 | Aim / fire or throw |
| L2 / R2 | Previous / next item |
| L3 / R3 | Stick-click actions |
| Start | Pause / confirm |
| Select | Menu / back |
| Select + Start | Exit to the frontend |

The normal path is the game's native SDL controller input. `use_gptk` is the
only fallback switch: `off` uses native SDL and `on` starts PortMaster's
gptokeyb with `roms/ports/bully/bully.gptk`. That user file controls buttons,
D-pad and keyboard/mouse-backed analogs. The package ships
`bully.gptk.default`; first launch creates the active file and later ZIP updates
do not overwrite user remaps. Delete only `bully.gptk` to restore the packaged
default on the next launch.

The current template uses `BULLY_GPTK_VERSION=3`. A V1 map and the stock V2 map
from the previous RC are migrated once and backed up as
`bully.gptk.pre-v3-backup`; a customized V2 map is detected and preserved.

The editable key contract uses `x/c/q/t` for the final A/B/X/Y game slots,
`u/i` for L1/R1, `k/l` for the native L2/R2 axes and `h/j` for L3/R3. The
default face map is neutral. `face_buttons` applies only to native SDL, so
gptokey mode never adds a hidden second remap.

L2/R2 use the engine's native previous/next-item trigger path by default. It
does not synthesize a touch and therefore does not reveal the touchscreen HUD.
If a firmware cannot expose usable triggers, `weapon_switch=touch` explicitly
restores the old coordinate-tap fallback.

## Graphics and compatibility

The Final build controls 3D scene resolution and source-texture quality
separately. The original mobile profile forces a 0.5 internal scale on several
Mali GPU families regardless of RAM, which produces a sharp HUD over a blurry
world. In automatic mode, systems below 1700 MB of Linux `MemTotal` retain the
V11.2 low-memory behavior. The nominal 2 GB tier selects 1.0 internal scale,
High textures, native streaming distance and RendererES3 when a real ES3
context is available. The complete context ladder falls back to ES2 when
necessary.

Streaming and memory safeguards are shared by both renderers. Native cubemap
mips are preserved. `trilinear=on` forces trilinear filtering only on complete,
safe mip chains; UI, render targets, cutout textures and incomplete chains stay
bilinear to prevent black textures. The 1 GB path remains the compatibility
baseline.

The opening cutscene also protects its visual clock from the one-time loading
stall seen on slower devices. This preserves the complete car arrival and keeps
the animation aligned with its streamed audio without changing gameplay timing
or normally paced later cutscenes.

Shadows from the deferred mobile renderer are not available on the supported
non-Adreno paths. This is an engine limitation, not missing package data.

## Configuration

Edit `roms/ports/bully/bully.conf` with one value from each documented list:

| Key | Values |
|---|---|
| `renderer` | `auto`, `es2`, `es3` |
| `render_scale` | `auto`, `profile`, `0.5`, `0.75`, `1.0` |
| `textures` | `auto`, `low`, `medium`, `high` |
| `trilinear` | `auto`, `on`, `off` |
| `stream_distance` | `auto`, `50`, `60`, `70`, `75`, `80`, `100` |
| `face_buttons` | `auto`, `normal`, `swap_xy`, `swap_ab`, `swap_both` |
| `input_debug` | `off`, `on` |
| `use_gptk` | `off`, `on` |
| `weapon_switch` | `native`, `touch` |

For `stream_distance`, a numeric value maps directly to
`BULLY2_STREAM_DISTANCE_PCT`; `auto` leaves that override unset. Keep automatic
values unless a controlled test shows a device-specific reason to override
them. `input_debug=on` is for short controller diagnostics, not normal play.
See `TESTING-pt-BR.md` for the private Final device checklist.

`textures=auto` ignores stale V11 Low/Medium preferences and recalculates the
RAM tier on every launch. Set `textures=low`, `medium` or `high` here to keep a
manual choice across launches.

On first launch, the launcher creates `bully.conf` from the packaged defaults.
Future ZIP updates do not overwrite that file.

With `face_buttons=auto`, the Final build converts label-style face mappings
only when the evdev semantics provide reliable positional evidence. The tested ArkOS
`R36T/K36S` device-tree profile swaps both pairs; other reported R36S/GO-Super
profiles preserve the already-correct CFW mapping. The GTA-style ordinal
correction activates only for an external USB/Bluetooth HID with the complete
old evdev signature. No branch is selected merely by kernel version; manual
face overrides remain.

Auto mode prioritizes the functional Bully/PS2 button positions. On clones
whose printed labels use another order, a B prompt may correspond to the
physical A button in the same position. Enable `use_gptk=on` and edit
`bully.gptk` to follow printed labels; the active map remains user-owned.

The Rockstar logos and the Jimmy/car/city opening movie are not restored in
this release. Their original calls remain in the engine, but the port still needs a
Linux H.264/AAC decoder and movie JNI implementation. A future implementation
must source the videos from the user's legal copy; release ZIPs will not carry
them.

## Troubleshooting

- `APK SET INCOMPLETE OR MIXED`: a split is missing, or a `data_N.zip` did not
  come from the same source as its `.idx`; copy every APK from the full install.
- `DATA VALIDATION FAILED`: the source is damaged or is not v1.4.311 arm64. See
  `roms/ports/bully/setup.log` for the exact file that failed.
- Missing `libGame.so` or `libc++_shared.so`: provide the arm64 source again;
  copying only the old `assets/` directory is insufficient.
- `MISSING REQUIRED TOOL: python3`: the firmware must provide Python 3 to
  validate the data and generate the local menu patch.
- Setup does not require the standalone GNU `stat` executable. On systems such
  as muOS it automatically selects a BusyBox, Python or POSIX-compatible size
  backend and records the selected backend in `setup.log`.
- Include `setup.log` for extraction reports and `roms/ports/bully/log.txt` for
  launch or controller reports.

See `README-pt-BR.md` for Portuguese instructions and `licenses/` for notices.
