## Notes

This is a native AArch64 Linux port of the Android GTA: San Andreas game
library. The port runtime is included, but the proprietary game library and
assets are not.

Copy the matching official **arm64-v8a GSG Android v2.11.311** package's
`libGame.so` and complete merged `assets/` tree into:

```text
/roms/ports/gtasa/gtasa/
```

Keep the extracted asset paths and case unchanged. `libc++_shared.so` is the
vendored Android NDK runtime used by the loader. `Adjustable.cfg` is included
for the console-style HUD layout. The package is AArch64-only.

## Getting the game files

The port does not include Rockstar's game library or assets. You need an
existing, purchased Google Play installation of GTA: San Andreas and ADB.
Google Play normally installs it as split APKs and may download additional
Play Asset Delivery packs.

1. Install the game and wait until its additional data has finished downloading.

2. Select the Android device and verify the required version and ABI:

   ```sh
   adb devices
   SERIAL=<serial-from-adb-devices>
   PACKAGE=com.rockstargames.gtasa
   adb -s "$SERIAL" shell dumpsys package "$PACKAGE" | tr -d '\r' | grep -E 'versionName=|primaryCpuAbi=|dataDir='
   ```

   The installation must report `versionName=2.11.311` and
   `primaryCpuAbi=arm64-v8a`. Do not mix files from another version or ABI.

3. Create a staging directory and list the installed APK split paths:

   ```sh
   STAGE="$PWD/gtasa-311-staging"
   mkdir -p "$STAGE/apks" "$STAGE/assetpacks"
   adb -s "$SERIAL" shell pm path "$PACKAGE"
   ```

4. Pull every APK path printed by `pm path` into `$STAGE/apks/`. Remove the
   `package:` prefix from each reported path before passing it to `adb pull`:

   ```sh
   adb -s "$SERIAL" pull <path-without-package-prefix> "$STAGE/apks/"
   ```

   Repeat this for `base.apk`, `split_data_main.apk`,
   `split_config.arm64_v8a.apk`, and the other configuration/language splits
   that belong to the same installation. Keep the APKs intact; do not merge
   them into one APK.

5. Find the downloaded Play Asset Delivery packs:

   ```sh
   adb -s "$SERIAL" shell find /data/user/0/com.rockstargames.gtasa/files/assetpacks -type d -name assets -print
   ```

   Pull the parent directories for `data_sfx1`, `data_sfx2`, and `data_streams`
   into `$STAGE/assetpacks/` using the paths reported by that command. The packs
   contain additional audio data and are required for complete audio playback.

6. Extract the relevant files from the staging archives:

   - `split_config.arm64_v8a.apk` → `lib/arm64-v8a/libGame.so` and
     `lib/arm64-v8a/libc++_shared.so`
   - `base.apk` and `split_data_main.apk` → their `assets/` directories
   - `data_sfx1` and `data_sfx2` → their inner `assets/audio/sfx/` files
   - `data_streams` → its inner `assets/audio/streams/` files

   Merge only the contents of those inner `assets/` directories. Do not keep
   the APK, pack name, pack version, or `assets/` container directory in the
   final game tree. Preserve case and keep every `.osw` beside its matching
   `.osw.idx`; the indexes are required.

The resulting PortMaster tree should look like this:

```text
/roms/ports/
├── Grand Theft Auto San Andreas.sh
└── gtasa/
    ├── gtasa_linux
    ├── libs.aarch64/
    │   └── libSDL3.so.0
    ├── libGame.so
    ├── libc++_shared.so
    ├── assetfile.txt
    ├── Adjustable.cfg
    ├── audio/
    │   ├── config/
    │   ├── sfx/
    │   └── streams/
    ├── data/
    ├── models/
    ├── texdb/
    ├── text/
    └── ...
```

The source repository contains the longer reference guide in
[`ASSET_PREPARATION.md`](https://github.com/korewaChino/gtasa_linux/blob/main/ASSET_PREPARATION.md).

`libSDL3.so.0` is intentionally bundled in `gtasa/libs.aarch64/`: standard
PortMaster runtimes provide SDL2, but this port requires SDL3 and cannot use an
SDL2 ABI. Only SDL3 itself is bundled. EGL/GLES, DRM/GBM, PipeWire/ALSA,
OpenAL, and GPU drivers remain platform-provided so each CFW can supply its own
patched stack.

`libc++_shared.so` is a separate Android NDK runtime loaded by the port's
custom ELF loader and is also included in the port directory.

## Controls

The port uses native SDL3 gamepad input; it does not emulate a keyboard.

| Button | Action |
|---|---|
| A / B / X / Y | Game buttons |
| D-pad | Directional input |
| L1 / R1 | Shoulder buttons |
| L3 / R3 | Stick clicks |
| Start | Native Start button |
| Back / Select / Minus | Native Back button |
| Guide/Home + Start | Exit the port |
| Back/Select/Minus + Start | Exit the port |

The quit chord is part of the default AArch64 build. `Adjustable.cfg` controls
the console-style HUD layout; remove it if the stock mobile layout is desired.

## Testing

Currently verified on Knulli at 1280x720 with native SDL3 gamepad input, audio,
rendering, and the Guide/Start quit chord.

| Distribution | Status |
|---|---|
| Knulli | Tested on TRIMUI Smart Pro S |
| Rocknix | Not yet tested |
| MuOS | Not yet tested |
| dArkOS | Not yet tested |
| AmberELEC | Not yet tested |
| ArkOS | Not yet tested |

## Build

The source port and its reproducible AArch64 build/package workflow are at:

<https://github.com/korewaChino/gtasa_linux>

```sh
cmake -S . -B build-linux -DBUILD_TESTING=ON \
  -DGTASA_DEBUG_LOG=OFF -DGTASA_QUIT_CHORD=ON
cmake --build build-linux -j2
ctest --test-dir build-linux --output-on-failure
```

Thanks to **Rockstar Games and Grove Street Games** for creating and
publishing Grand Theft Auto: San Andreas; to **NaGaa95** for the Android ARM64
loader foundation; to **TheOfficialFloW**, **fgsfds**, and the AndroidModLoader /
JPatch contributors for the porting work this project builds on; and to the
PortMaster maintainers for the packaging system.
