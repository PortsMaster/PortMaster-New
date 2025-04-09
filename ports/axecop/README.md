## Notes

Thanks to [Red Triangle Games](https://redtrianglegames.itch.io/) for creating this game, which you can purchase on [itch.io](https://redtrianglegames.itch.io/axecop) or [Steam](https://store.steampowered.com/app/1193300/Axe_Cop/). This hasn't been tested with the GOG version, but that *should* work, too.

The game runs a bit slow on RK3326 devices, better on H700 devices, and best on RK3566 devices. The game takes a while to load initially, so be patient :)


## Controls

| Button | Action                |
| ------ | --------------------- |
| D-PAD  | Movement / navigation |
| A      | Action / axe          |
| B      | Back                  |
| X      | Switch character      |
| Y      | Menu                  |


## Compile OHRRPGCE 

```shell
Install FreeBASIC
git clone https://github.com/ohrrpgce/ohrrpgce.git
cd ohrrpgce
scons gfx=sdl2
```
