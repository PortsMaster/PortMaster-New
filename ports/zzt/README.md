## Notes
Thanks to the Tim Sweeney for creating this game!
Thanks to the [Adrian "asie" Siekierka](https://github.com/asiekierka) for maintaining and improving project!

## Controls
| Button | Action |
|--|--| 
| D-Pad, Right analog, Left analog | Character movement, menu navigation |
| A | Confirm/Select |
| B | Cancel/Exit/Close/Esc |
| X + D-Pad | Shoot |
| Y | Use torch |
| Start | Start new game |
| Select | Load save file |
| L1 | Select world |
| L2 | Load save file |
| R1 | Open settings screen |
| R2 | Change game speed/Save game |

## Adding worlds
- Download world from https://museumofzzt.com/
- Put downloaded `.ZZT` file in `ports/zzt/` directory

## Compile
```sh
git clone https://github.com/ohol-vitaliy/PortMaster-ZZT.git
cd PortMaster-ZZT
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker build . --platform linux/arm64 --rm -t zzt_build
docker run --rm zzt_build cat /root/zztarm.zip > zztarm.zip
```
Put contents of a `zztarm.zip` archive into the `ports/zzt` folder
