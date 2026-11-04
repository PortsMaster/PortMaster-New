## Notes

Thanks to [insertdisc5](https://www.insertdisc5.com/) for creating In Stars and Time.

Get the game from [Steam](https://store.steampowered.com/app/1677310/In_Stars_And_Time/), [GOG](https://www.gog.com/en/game/in_stars_and_time), or [itch.io](https://armor-games-studios.itch.io/in-stars-and-time).

Create `ports/isat/gamedata/` if needed, then copy your game folder (the one that contains the `index.html` or `Game.exe`) into it.
Ex. `ports/isat/gamedata/In Stars and Time`

For a more minimal install, copy just the `In Stars and Time/www` folder to the `gamedata folder`.
Ex. `ports/isat/gamedata/www` or `ports/isat/gamedata/index.html` (along with everything else in the www folder)

The first boot prepares assets and can take a few minutes.
Saves are stored in `ports/isat/saves/`.

## Controls

| Key | Action |
|--|--|
| D-Pad / Left Stick | Movement |
| A | Confirm / Action |
| B | Cancel / Back |
| X | Dash |
| Y | Menu |
| L1 / R1 | Previous / Next page |
| Start | Menu / Pause |
| Select + Start | Exit |
| Home + A | Runtime settings |

## Compile

```bash
git clone https://github.com/bbbreaddd/pmjs.git
cd pmjs
python3 tools/dependencies.py
./build.sh --target arm64
```
