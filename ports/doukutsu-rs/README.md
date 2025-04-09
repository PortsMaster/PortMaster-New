## Installation details

### Freeware version
If you don't provide any files, the bundled English translation will be installed automatically the first time you run the game.

Alternatively, any of the translations [here](https://www.cavestory.org/download/cave-story.php) should work. Some translations are pre-patched, in which case you simply need to unzip the downloaded files. Other translations require you to patch the original version using a Windows computer. Once you have the unzipped, patched files, copy them so that `data`, `Doukutsu.exe` and surrounding files are in `doukutsu-rs/`.

### Cave Story+ (purchase required)
Any version of Cave Story+ from Steam, GOG or elsewhere should work. From your download, put the `data` folder in `doukutsu-rs`. For example, if you own the game on Steam, you can download the necessary files from the [Steam console](https://steamcommunity.com/sharedfiles/filedetails/?id=873543244) using `download_depot 200900 200905 6949702094591263227`.

## Controls
| Button  | Action             |
| :------ | :----------------- |
| D-pad   | Movement           |
| A       | Menu select, shoot |
| B       | Menu cancel, jump  |
| L1      | Previous weapon    |
| R1      | Next weapon        |
| X       | Inventory          |
| Y       | Map system         |
| Hold X  | Skip cut-scenes    |
| R2      | Strafe             |

## Acknowledgements
Thanks to [Studio Pixel](https://studiopixel.jp) and [Nicalis](https://www.nicalis.com) for the wonderful original game and Cave Story+. Thanks to the [doukutsu-rs](https://github.com/doukutsu-rs/doukutsu-rs) team for the amazing reimplementation.

Thanks to ptitSeb for the [gl4es](https://github.com/ptitSeb/gl4es) library.

## Port details
The original code has been modified to use OpenGLES if OpenGL cannot be used, and the controller (rather than keyboard) has been enabled by default.

See [BUILDING.md](https://github.com/PortsMaster/PortMaster-New/blob/main/ports/doukutsu-rs/doukutsu-rs/BUILDING.md) for building instructions.
