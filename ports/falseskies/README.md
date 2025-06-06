## Notes

Thanks to [Feenicks](https://feenicks.itch.io/false-skies) for this game, which you can purchase on [itch.io](https://feenicks.itch.io/false-skies) or [Steam](https://store.steampowered.com/app/1830040/False_Skies)

You can also play the demo version using this port.


## Controls

| Button | Action                       |
| ------ | ---------------------------- |
| D-PAD  | Walk around / control menus  |
| A      | Use / talk to NPCs / confirm |
| B      | Open and close the menu      |
| START  | Game menu                    |


## Compile OHRRPGCE 

```shell
Install FreeBASIC
git clone https://github.com/ohrrpgce/ohrrpgce.git
cd ohrrpgce
scons gfx=sdl2
strip ohrrpgce-game
```
