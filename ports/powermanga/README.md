## Notes

Thanks to [TLK Games](https://github.com/brunonymous/Powermanga) for Powermanga, a fast, colorful arcade shoot-em-up packed with power-up gems and over 200 hand-made sprites.
Also thanks to wark91 for trying to port this game in the first place.

## Controls

| Button | Action |
|--|--|
| D-Pad / Left Stick | Move / Navigate menus |
| A | Fire / Confirm |
| B | Activate selected power-up |
| X | Confirm high score name |
| Start | Menu |
| Select | Pause |
| Start + Select | Quit |

## Compile

```bash
git clone https://github.com/brunonymous/Powermanga.git
cd Powermanga
git apply /path/to/patches/powermanga.patch
mkdir build && cd build
cmake .. -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release -DPOWERMANGA_SDL=on -DPOWERMANGA_SDL2=on -DUSE_SDLMIXER=on
make
```
