## Notes

Thanks to [Team Cherry](https://www.teamcherry.com.au/) for creating Hollow Knight and its hand-drawn kingdom of Hallownest.

This port does not include the game: you need Hollow Knight for Linux (Unity 6000.0.61f1): GOG's installer as downloaded (hollow_knight_*.sh, no renaming), or the game folder from GOG or Steam. Copy it into
`ports/hollowknight/gamedata/`, then start Hollow Knight from the Ports menu. The first launch builds the
game on the handheld from your copy (one to three hours, once). Unity's Android player comes with the port (`donor/`: small games built with Unity for it, whose APKs carry the player; the setup removes them once the game is built); nothing is downloaded, no Wi-Fi. It needs a handheld with a 64-bit ARM system and GLES 3: with 32-bit (armhf) libraries beside it the port runs its 32-bit build (e.g. Knulli on Allwinner H700 devices), without them its 64-bit build (no compile, nothing downloaded).

The game runs on Unity's own Android player, through
[portmaster-unity](https://github.com/wild1walker/portmaster-unity)'s `ua_host` (its android
route). Saves and settings are in `ports/hollowknight/data/`; the game's options are in
`ports/hollowknight/port.env`. Tested on AmberELEC, dArkOS, muOS, Knulli and
ROCKNIX.

The picture fills 4:3 and 3:2 screens (the game's own rule for 16:10 carried down to them); the setup
asks, and `bars` in `aspect.txt` keeps the game's 16:9 with bars. On every handheld the picture gives a
little for speed, the game play never ([what and why](https://github.com/wild1walker/portmaster-hollowknight)).

A few more frames in big rooms, for less scenery: with this line at the top of `port.env` the far
background (what the game shows blurred: far walls, waterfalls, far vines) is not drawn and the fog
stands before black. The game play is the same (Greenpath: 53 -> 56 fps on an RG34XX-SP, 33 -> 35 on
a G350).

```bash
export ASMPATCH_HK_BLUR=off,hide
```

## Controls

The buttons work by position (the bottom one jumps and confirms); the prompts show the letters
printed on the handheld (B at the bottom, A on the right); the setup asks, and `xbox` in `buttons.txt`
shows the game's Xbox buttons instead, for handhelds printed like an Xbox pad. On muOS this holds
with both of its button layouts, Retro and Modern.

| Button | Action |
|--|--|
| D-pad | Move; with up or down, the nail and spells go that way |
| B (bottom) | Jump; confirm in menus |
| Y (left) | Attack with the nail |
| A (right) | Focus (hold) and cast spells; back in menus |
| X (top) | Dream Nail |
| R2 | Dash |
| L2 | Crystal Dash |
| L1 | Quick map |
| R1 | Quick cast |
| Select | Inventory |
| Start | Pause |
| Select + Start | Quit |

## Compile

The port folder is made by portmaster-unity's `pmunity port new` from the port's settings,
`port.toml`. On Linux or macOS with git, Docker and Python 3.11 or newer:

```sh
git clone --recurse-submodules https://github.com/wild1walker/portmaster-unity.git
cd portmaster-unity
runtime/build.sh                                            # ua_host, the 32-bit runtime (Docker)
setup-rs/tools/build_pmu.sh tools/port/out/pmu               # the setup's tools, pmu, aarch64 (Docker)
tools/asmpatch/build.sh                                     # asmpatch (.NET 8 SDK)
python3 -m pip install -r convert/requirements.txt
cd convert
python3 -m pmunity port new hollowknight --out <port folder>   # reads <port folder>/port.toml
DONORS=<donor folder> python3 -m pmunity port package <port folder>   # -> <port folder>/out/hollowknight.zip
```
