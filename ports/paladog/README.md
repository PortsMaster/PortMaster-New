## Notes

Thanks to [FazeCat](https://paladog.fandom.com) for creating Paladog, an engaging and charming side-scrolling defense game.
Native C++ / SDL2 port by [hoangnq07](https://github.com/hoangnq07/Paladog).

## Installation

1. Obtain a copy of `Paladog.swf` (approx. 19.5MB).
2. Place `Paladog.swf` into the `paladog/gamedata/` directory.
3. Launch Paladog. The port will automatically extract and configure game assets on first launch.

## Controls

| Button | Action |
|--|--|
| D-Pad Left / Right | Move Paladog / Select unit in War Road |
| D-Pad Up / Down | Change summoning lane in War Road |
| Left Analog Stick | Move Paladog / Virtual cursor in menus |
| A | Summon unit / Confirm in menus |
| B | Magic skill 3 (Mace 3) / Cancel / Back |
| X | Magic skill 1 (Mace 1) / Select in menus |
| Y | Magic skill 2 (Mace 2) |
| L1 / R1 | Cycle through available unit types |
| Start | Pause game |
| Select + Start | Exit game |

## Compile

```bash
git clone https://github.com/hoangnq07/Paladog.git
cd Paladog/native_port
make aarch64 LANG_EN=1
```
