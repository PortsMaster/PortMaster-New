## Notes

DaytonaArm is a native ARM64 port of [daytona-arcade-recomp](https://github.com/alphanu1/daytona-arcade-recomp), a static recompilation of the Sega Model 2 arcade hardware, with an OpenGL ES 2.0 renderer and dynamic game modules built from your own ROM set. It supports Daytona USA Revision A (1994, with LAN link play) and Deluxe '93.

**No ROMs or ROM-derived code are distributed with this port.** Before the first launch you have to add two things to `daytonaarm/`:

1. `roms/daytona.zip` (Revision A) and/or `roms/daytona93.zip` (Deluxe '93), from your own legally dumped MAME set. `.7z` archives must be repacked as `.zip`.
2. `cache/daytona-aarch64.so` and/or `cache/daytona93-aarch64.so`, compiled on a PC from the same ROM set with `tools/build-arm64-cache.sh` (see [the project README](https://github.com/DanimanX/DaytonaArm#quick-start-anbernic-rg34xx--portmaster)).

Arcade factory defaults expect a linked twin cabinet and the game waits on "CHECKING NETWORK". Once: open Options, tick **Hold Test button**, then Start; in the test menu open GAME SYSTEM and set LINK ID to SINGLE. The choice is saved.

## Controls

D-Pad steering is emulated through the arcade drive board (centring spring that firms up with speed), so the D-pad steers and also moves the game's own menus.

| Button | Action |
|--|--|
| D-Pad Left / Right | Steer |
| R1 | Accelerate |
| L1 | Brake |
| D-Pad Up / Down | Shift up / down |
| A / B / X / Y | View 1 / 2 / 3 / 4 |
| Start | Start |
| Select | Insert coin |
| Start+Select, or Menu | Pause menu (game options, controls, hold test button, exit) |

Bindings can be changed in the pause menu under Controls.

## Thanks

Thanks to [alphanu1](https://github.com/alphanu1/daytona-arcade-recomp) for the static recompilation this port is built on, and to [DaytonaArm](https://github.com/DanimanX/DaytonaArm) for the ARM64 packaging for portmaster.

*"Daytona USA"* and *"Sega Model 2"* are trademarks of SEGA. This port is independent and not affiliated with SEGA.
