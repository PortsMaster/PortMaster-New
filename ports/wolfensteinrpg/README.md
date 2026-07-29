## Notes

Thanks to [Erick194](https://github.com/Erick194/WolfensteinRPG-RE) for reverse-engineering this game and porting it to SDL2/OpenGL.

## Controls

| Button | Action |
|--|--|
| D-Pad Up/Down | Move Forward/Backward |
| D-Pad Left/Right | Turn Left/Right |
| Left Stick Up/Down | Move Forward/Backward |
| Left Stick Left/Right | Strafe Left/Right |
| A | Attack/Talk/Use |
| B | Pass Turn |
| X | Prev Weapon |
| Y | Next Weapon |
| L1 | Items/Info |
| L2 | Syringes |
| R2 | Journal |
| Select | Automap |
| Start | Menu Open/Back |

## Compile

git clone https://github.com/Cebion/WolfensteinRPG_pm.git
cd WolfensteinRPG-RE
mkdir build && cd build
cmake ..
make -j$(nproc)
