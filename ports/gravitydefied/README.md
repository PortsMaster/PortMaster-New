## Notes
Thanks to the [Codebrew Software](codebrew.se) for creating this game

Thanks to the [rgimad](https://github.com/rgimad), [AntonEvmenenko](https://github.com/AntonEvmenenko), [turbocat2001](https://github.com/turbocat2001) for creating a C++/SDL2 port

Thanks to the [ohol-vitaliy](https://github.com/ohol-vitaliy) for fixing bugs with saving progress and incorrect scaling

## Controls
### Menu
| Button | Action |
|--|--| 
| D-Pad | Menu navigation |
| A | Confirm/Select |
| B | Cancel/Exit |

### Game
| Button | Action |
|--|--| 
| D-Pad Left | Lean backward |
| D-Pad Right | Lean forward |
| D-Pad Up | Accelerate |
| D-Pad Down | Brake |
| A | Accelerate |
| B | Brake |
| Select | Open menu |
| Start | Open menu |

## How to add custom levels
- Go to this page https://gdtr.net/levels/
- Download any levels set you like
- Replace the default `ports/gravitydefied/levels.mrg` file with the downloaded one

**Note: custom levels not officially supported. There is slight possibility that custom levels could crash the game**

## Compile
```shell
git clone https://github.com/ohol-vitaliy/gravity_defied_cpp
cd gravity_defied_cpp
cmake -DCMAKE_BUILD_TYPE=Release .
make -j2
```
