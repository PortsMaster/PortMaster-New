## Notes

Thank you to [**Gerhard Stein**](https://github.com/gerstrong/Commander-Genius) and others related for the development of this port that makes this possible. Thanks to [**Christian Haitian**](https://github.com/christianhaitian) for his work on creating the [original PortMaster](https://github.com/christianhaitian/PortMaster), the previous versions of this port, and for passing the torch on to me. Also, thanks to the original developers, [**id Sotware**](https://www.idsoftware.com/), to whom which this game would not be possible without. Finaly, thanks to the [**PortMaster**](https://portmaster.games) team for continuing to keep this community alive, their time and dedication, and their willingness to share knowledge.

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

## Compile

```shell
# binary will be located at 'CGeniusBuild/src/CGeniusExe' when complete
git clone https://gitlab.com/Dringgstein/Commander-Genius.git
mkdir CGeniusBuild && cd CGeniusBuild
cmake ../Commander-Genius/
make
```