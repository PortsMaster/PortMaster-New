## Notes

This is a native AArch64 Linux port of the Android GTA: San Andreas game
library. The port runtime is included, but the proprietary game library and
assets are not.

Copy the matching official **arm64-v8a GSG Android v2.11.264** package's
`libGame.so` and complete `assets/` tree into:

```text
/roms/ports/gtasa/gtasa/
```

Keep the extracted asset paths and case unchanged. `libc++_shared.so` is the
vendored Android NDK runtime used by the loader. `Adjustable.cfg` is included
for the console-style HUD layout. The package is AArch64-only.

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
