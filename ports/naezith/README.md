## Installation

Buy the game on [Steam](https://store.steampowered.com/app/590590/Remnants_of_Naezith/). In the [Steam console](https://steamcommunity.com/sharedfiles/filedetails/?id=873543244) run:

```
download_depot 590590 590591 271869356780381257
download_depot 590590 590593 1978461534159709910
```

Merge both downloads and copy everything (the `naezith` binary, `lib` and `data` folders) into `ports/naezith/gamedata/`. Tested with the 22.03.2024 Linux build.

## Controls

| Button | Action |
|--|--|
| D-pad / Left stick | Move |
| A | Jump |
| L1 | Dash |
| R1 | Hook (hold to swing) |
| B | Reset |
| X | Recall |
| Start | Pause |

Bindings can be changed in Settings, Controls. Select + Start exits.

## Notes

* On 1 GB devices turn on zram (or swap) in your firmware's settings, so the game does not run out of memory.
* On 480 line screens the port sets View Height (Settings, Graphics) to 720 on first start, so the level and its text are larger. Raise it to see more of the level.
* Runs through box64 and Westonpack with gl4es. Saves are in `gamedata/data/user`.
* Online rankings are unavailable, the game runs in offline mode.
* ROCKNIX: works with libmali and Panfrost. If the game locks up entering a level on a device without swap, turn on swap or zram.
* On pads whose D-pad sends buttons instead of a hat (the RG552 on AmberELEC), the port maps the D-pad to the arrow keys and Start to Escape (Pause).
* On 4:3 screens a few menu labels overlap.
* `steamstub/` only reports Steam as running and does no license checks.

## Reporting problems

Please send `ports/naezith/log.txt` (rewritten on every start).

## Thanks

Tolga Ay for the game, ptitSeb for [box64](https://github.com/ptitSeb/box64) and [gl4es](https://github.com/ptitSeb/gl4es), binarycounter for [Westonpack](https://github.com/binarycounter/Westonpack/wiki) and the Steam stub this port's stub is based on (from Papers, Please), and the PortMaster team.
