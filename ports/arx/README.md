### Controls

| Button               | Action                          |       |
| :------------------- | :------------------------------ | :---- |
| Left analog stick    | Move                            |       |
| Right analog stick   | Mouse look / move mouse cursor  |       |
| R1                   | Left mouse button               |       |
| R2                   | Toggle mouse look / cursor mode |       |
| A                    | Jump                            | Space |
| B                    | Quick equip item                | F     |
| X                    | Crouch                          | X     |
| Y                    | Toggle crouch                   | C     |
| L1 + right stick     | Strafe                          | A/D   |
| L2 + right stick     | Lean                            | Q/E   |
| D-pad up             | Combat mode                     | Tab   |
| D-pad left           | Magic mode                      | Ctrl  |
| D-pad right          | Stealth mode                    | Shift |
| D-pad down           | Mouse slow                      |       |

### Compatible versions and languages

The simplest way to install the game files is to use the GoG offline installer -- place both files in `arx/gamedata` and they will be extracted on first run.

However, other versions (Steam or Windows CD-ROM) should be compatible, see [here](https://wiki.arx-libertatis.org/Getting_the_game_data) for details of compatible data, including language options. To fetch the Steam version, purchase it and use `download_depot 1700 1701 2788630759839569414` in the Steam console. Once you have the files, copy them so that `data.pak` and surrounding files and folders are in `arx/gamedata`.

### Device compatibility

Performance on ArkOS and/or R36s is poor. On Rocknix, libmali performance is also poor, so please use the system menus to switch to panfrost.

### Acknowledgements

Thanks to [Arkane](https://www.arkane-studios.com/en) for the original game, and to the [Ars Libertatis](https://arx-libertatis.org) team for their excellent port.

### Port information

The port has been slightly modified to fix a problem with fonts on OpenGL ES.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/arx/arx/BUILDING.md) for building instructions.
