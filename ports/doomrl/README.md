## Notes
Thanks to the [Kornel Kisielewicz](https://github.com/epyon) for creating this amazing roguelike and making it available for free!

## Controls
| Button | Action |
|--|--| 
| D-Pad | Character movement, menu navigation |
| A | Confirm/Select |
| B | Cancel/Exit/Close/Esc |
| X | Run |
| Y | Wait turn |
| Start | Open inventory |
| Select | Open/Close door, Toggle lever, Use stairs |
| L1 | Fire weapon |
| L2 | Reload weapon |
| R1 | Pick-up item |
| R2 + Start | Drop item from inventory |
| R2 + Select | Unload weapon |
| R2 + L1 | Alternative fire weapon |
| R2 + L2 | Alternative reload weapon |
| R2 + R1 | Swap weapon |
| R2 + Up | y (used in prompts) |
| R2 + Down | n (used in prompts) |
| R2 + Left | Check tile info |
| R2 + Right | Show messages log |
| R2 + X | Choose weapon (in mod pack prompt) |
| R2 + Y | Choose weapon (in mod pack prompt) |
| R2 + A | Choose armor (in mod pack prompt) |
| R2 + B | Choose boots (in mod pack prompt) |

## Adding music files
The game is not bundled with music files but you can add them manually.
Here are the steps you need to take:
- Go to the [DoomRL downloads page](https://drl.chaosforge.org/downloads)
- Download Windows or Linux archive 
- Copy `mp3` directory from archive into `ports/doomrl/`

## Version
0.9.9.8

## Compile
```sh
git clone https://github.com/ohol-vitaliy/PortMaster-DoomRL.git
cd PortMaster-DoomRL
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker build . --platform linux/arm64 --rm -t drl_build
docker run --rm drl_build cat /root/drl.zip > drl.zip
```
Put contents of a `drl.zip` archive into the `ports/doomrl` folder
