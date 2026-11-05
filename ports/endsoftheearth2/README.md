## Notes

Thanks to [Valkayree Productions](https://rpg.hamsterrepublic.com/ohrrpgce/Game:Ends_of_the_Earth_2) for creating Ends of the Earth 2, an OHRRPGCE RPG with over 40 playable characters and a return to the city of Concorde.

This port uses the same OHRRPGCE engine binary as Vikings of Midgard, pointed at `EOTE2.RPG`.

## You need to provide EOTE2.RPG yourself

This port ships the OHRRPGCE engine (GPL-licensed and freely redistributable) but **not** the game data. `EOTE2.RPG` is Ends of the Earth 2's actual game content, copyright Valkayree Productions, All Rights Reserved, so it cannot be bundled here.

1. Download it from Castle Paradox's mirror: https://mirror.motherhamster.org/cp/castleparadox.com/gamelist-display-247.html?game=493
2. Unzip it and place `EOTE2.RPG` directly in this port's folder, next to `ohrrpgce-game`.
3. Launch the port normally.

Without the file present, the port will show a message on-screen telling you where to put it and exit, rather than crash.

## Controls

| Button | Action                                   |
| ------ | ---------------------------------------- |
| D-PAD  | Directional movement                     |
| A      | Investigate / advance / confirm          |
| B      | Raise menu / cancel choice / flee battle |
| X      | Sprint on the *field* when held down     |
| Y      | Pause during battle                      |

## Compile OHRRPGCE

Install FreeBASIC, then build the engine:

```bash
git clone --recurse-submodules https://github.com/ohrrpgce/ohrrpgce.git
cd ohrrpgce
scons gfx=sdl2
```

## Special Thanks
Thanks to tabreturn for releasing the Vikings of Midgard PortMaster port first, which provided the OHRRPGCE packaging reference.

Thanks also to [Original Hamster Republic](https://hamsterrepublic.com/ohrrpgce/) for releasing the OHRRPGCE engine.
