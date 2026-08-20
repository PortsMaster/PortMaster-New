## Notes

Thanks to [ExiguusEntertainment](https://github.com/ExiguusEntertainment/AmuletsArmor) for open-sourcing this 1997 first-person dungeon-crawler RPG.

## Controls

| Key | Action |
|--|--|
| D-Pad | Move forward/back, turn left/right (dungeon view) |
| Left Stick | Move mouse cursor (menus/inventory) |
| A | Left mouse button |
| B | Right mouse button |
| X | Slow cursor (hold for precise aiming) |
| Y | Attack / use item in hand |
| L1 | Run (hold) |
| L2 | Toggle on-screen keyboard (for character name / text entry) |
| R2 | Activate / open / interact |
| Start | Enter |
| Back | Esc |

## Compile

```sh
git clone https://github.com/ExiguusEntertainment/AmuletsArmor.git
cd AmuletsArmor
cmake -S . -B out/linux -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build out/linux --target amulets-armor -j
```
