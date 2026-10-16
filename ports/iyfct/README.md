## Notes

Thanks to [Simon Larsen](https://github.com/SimonLarsen/iyfct) for In Your Face City Trains. This port runs the game's source on PortMaster's LÖVE 11.5 runtime, with the 300x100 view scaled to fit the screen (the original resized its window in zoom steps).

The code is licensed under GPL 3; the graphics and sounds under CC BY 3.0; the music, "The rb Sequence" by Fighter X, under CC BY 3.0 (see `licenses/LICENSE.iyfct.txt`).

## Controls

| Button | Action |
|--|--|
| B | Jump (hold to jump higher) |
| A | Start / confirm |
| D-Pad Up / Down | Pick the difficulty |
| X | Restart |
| Y | Back |
| Start | Pause |
| L1 | Mute |
| Select + Start | Quit |

## Build

Nothing is compiled: `git archive` of https://github.com/Knifethrower/iyfct (branch `portmaster`) into `iyfct/gamedata`.
