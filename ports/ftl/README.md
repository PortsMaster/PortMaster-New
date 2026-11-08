## Notes

Thanks to [Subset Games](https://subsetgames.com/) for [FTL: Faster Than Light](https://subsetgames.com/ftl.html), a roguelike spaceship sim where every jump is a gamble on where to send your ship's last bit of power.

## Game files

The port runs the Linux version of the game, from Steam or GOG.

### Steam

To get the Linux version on any OS, open `steam://open/console` in a browser and enter:

```
download_depot 212680 221002
```

When Steam prints "Depot download complete", copy the contents of the `data` folder in `Steam/steamapps/content/app_212680/depot_221002/` into `ports/ftl/gamedata/`.

### GOG

Download the Linux installer (`ftl_advanced_edition_*.sh`) from the game's page in your GOG library and copy it into `ports/ftl/gamedata/`. The port unpacks it at the first launch and deletes it.

## Memory

The game needs 750 MB of free memory. On devices with 1 GB of RAM, turn on swap or zram in the system settings.

## Controls

Gamepad and touch support is provided by [FTLHELM](https://github.com/mxmgorin/ftlhelm), a custom control layer. See the in-game help for controls.

| Button | Tap | Hold |
|--|--|--|
| D-pad, sticks | Move to the next room, button, event choice or beacon that way | |
| A | Click; on a room, send the selected crew there or select its crew | Drag |
| B | Cancel or back; pause when there is nothing to cancel | Abilities wheel |
| X | Arm the next weapon | Weapons wheel |
| Y | Next crew member | Crew wheel |
| L1 | Previous tab | Systems wheel |
| R1 | Next tab | Ship orders wheel |
| L2 | Open or close the room's doors | Move between doors |
| R2 | Beacon map | Fast forward |
| L3, R3 | Other ship | |
| Start | Pause | Zoom out while zoomed |
| Select | Settings wheel | |
| Select + Start | | Quit |

A wheel stays open after the button is released and pauses the game:

| Button | In a wheel |
|--|--|
| Stick | Point at a plate |
| A | Act on the plate |
| D-pad up, down | Add, take power |
| B | Close |

On a touchscreen:

| Touch | Effect |
|--|--|
| Tap | Click |
| Hold, release | Right click |
| Swipe up or down from a system icon or its power bars, or a weapon box | Add, take power |
| Drag | Drag |
| Two-finger tap | Pause or resume |
| Pinch on the ship view | Zoom |

Bindings and settings: `ports/ftl/ftlhelm.ini`.

## Credits

- FTL: Faster Than Light by [Subset Games](https://subsetgames.com/)
- Gamepad and touch controls by mxmgorin's [FTLHELM](https://github.com/mxmgorin/ftlhelm)
- x86-64 emulation by ptitSeb's [box64](https://github.com/ptitSeb/box64)
