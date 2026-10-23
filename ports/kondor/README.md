## Notes

Thanks to [QSoft](http://www.ragestorm.net/projects/kondor/) (Gil Dabah and Oren Becker) for Kondor, a fast top-down tank game with a rotating turret you aim separately from your hull, and to [Nicholas Honeth](https://github.com/nicholas-honeth/kondor-SDL2) for reconstructing it as a native SDL2 port.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Drive and turn, menu navigation |
| A | Fire (hold for auto-fire) |
| B | Brake, toggle options |
| X / Y | Use inventory item, confirm |
| L1 | Turn cannon left |
| R1 | Turn cannon right |
| L2 | Open/close on-screen keyboard (high score name) |
| R2 | Next inventory slot |
| Start | Confirm |
| Select | Back to menu |

On-screen keyboard: D-Pad moves, A picks a letter, B deletes, R2 switches letters/numbers.

## Compile

```bash
git clone https://github.com/nicholas-honeth/kondor-SDL2.git
cd kondor-SDL2
git apply /path/to/patches/kondor-portmaster.patch
cmake -S . -B build-pm -DCMAKE_BUILD_TYPE=Release -DKONDOR_PORTMASTER=ON
cmake --build build-pm
strip -o kondor.aarch64 build-pm/kondor
```

OmniOSK (on-screen keyboard), plain SDL2 build without the sdl12-compat bridge:

```bash
git clone -b sdl12-compat-bridge https://github.com/Cebion/OmniOSK_sdl3.git OmniOSK
cd OmniOSK
cmake -S . -B build-sdl2 -DCMAKE_BUILD_TYPE=Release -DOMNI_SDL12_BRIDGE=OFF -DOMNI_BUILD_TESTS=OFF -DOMNI_BUILD_RENDERER_TEST=OFF
cmake --build build-sdl2
strip -o libomni_osk.so build-sdl2/lib/libomni_osk.so
```
