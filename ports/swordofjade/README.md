## Notes

All files included and ready to run. Thanks to [FyreWulff Software](https://fyrewulff.itch.io/) for releasing this fantastic game and giving Portmaster permission to distribute the original version. If you want to support the creator's work, please consider purchasing the remake on Steam [https://store.steampowered.com/app/1885860/Sword_of_Jade_Parallel_Dreams/]

## Controls

| Button | Action                                   |
| ------ | ---------------------------------------- |
| D-PAD  | Directional movement                     |
| A      | Investigate / advance / confirm          |
| B      | Raise menu / cancel choice / flee battle |
| X      | Sprint on the *field* when held down     |
| Y      | Pause during battle                      |

## Compile OHRRPGCE 

```shell
Install FreeBASIC
git clone https://github.com/ohrrpgce/ohrrpgce.git
cd ohrrpgce
scons gfx=sdl2
strip ohrrpgce-game
```
