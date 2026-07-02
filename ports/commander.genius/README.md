## Notes

Thank you to [**Gerhard Stein**](https://github.com/gerstrong) for providing the [Commander Genius source code](https://github.com/gerstrong/Commander-Genius) and making it freely available. Thanks to [**Christian Haitian**](https://github.com/christianhaitian) for creating the original version of this port, [PortMaster](https://github.com/christianhaitian/PortMaster) itself, and for passing the torch on to me. Also, thanks to the original developers, [**id Sotware**](https://www.idsoftware.com/), to whom which this game would not be possible without. Finaly, thanks to the [**PortMaster**](https://portmaster.games) team for continuing to keep this community alive through their support, time, and dedication.

## Controls

| Button | Action |
|--|--|
| Start | Exit to main menu |
| Select | Display status |
| D-pad | Move character |
| A | Jump |
| B | Shoot blaster |
| Y | Toggle pogo stick on/off |

Note: Default controls are shown, however, port supports remapping of the controls to your preference. Needs to be done in-game but, once complete, the custom control mappings apply globally.

## Included Content

Includes all of the officially released free content for the Commander Keen series. This includes:

- The shareware episodes:
  - [Episode 1: Marooned on Mars](https://keenwiki.shikadi.net/wiki/Keen_1:_Marooned_on_Mars)
  - [Episode 4: Secret of the Oracle](https://keenwiki.shikadi.net/wiki/Keen_4:_Secret_of_the_Oracle)
- The demo episode:
  - [Episode 6: Aliens Ate My Baby Sitter.](https://keenwiki.shikadi.net/wiki/Keen_6:_Aliens_Ate_My_Baby_Sitter!)
- The lost episode:
  - [Keen Dreams](https://keenwiki.shikadi.net/wiki/Keen_Dreams)

## Additional Content

This port supports the addition of official or community-created episodes/mods and you can add additional content to Commander Genius in one of two ways:

1. **Manually**: You can add load your own game files into the following location, relative to your ports directory: `cgenius/conf/.CommanderGenius/games`. If you opt to load the game files manually, ensure that you update the `games.cfg` within the mentioned directory appropriately.

2. **Automatically**: If you have an internet connection on-device, you can simply download content directly from the launcher (button on bottom-left) to access additional community created content. Downloading content from the launcher will automatically update your `games.cfg` file, mentioned just above.

## Compile

```shell
# binary will be located at 'CGeniusBuild/src/CGeniusExe' when complete
git clone https://gitlab.com/Dringgstein/Commander-Genius.git
mkdir CGeniusBuild && cd CGeniusBuild
cmake ../Commander-Genius/
make -j$(nproc)
```
