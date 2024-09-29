## Notes
Thanks to the [mechakotik](https://github.com/mechakotik/tails-adventure) for creating this game and making it available for free!

## Controls

The following instructions are for a right-facing character. 

| Button | Action |
|--|--| 
|DPAD| Move |
|A| Jump |
|B| Fire |
|L1| Switch Weapons|
|R1| Switch Weapons|

## Compile ## 

```bash
git clone https://github.com/mechakotik/tails-adventure.git
replace files in src/ game.cpp & sound.cpp
meson setup build && cd build
meson compile
```