## Notes

Thanks to [snej55](https://github.com/snej55) for making Defblade, a precision pixel-art platformer with tight parkour and sword-combat challenges.

## Controls

| Button | Action |
|--|--|
| D-Pad Up / A | Jump |
| D-Pad Down | Down |
| D-Pad Left | Left |
| D-Pad Right | Right |
| B | Attack |
| Start | Confirm |

## Compile

git clone https://github.com/Cebion/paper-world.git
cd paper-world
cmake -S . -B build -G Ninja -DPORTMASTER_BUILD=ON -DCMAKE_BUILD_TYPE=Release
cmake --build build
