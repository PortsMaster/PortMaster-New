## Notes

asteroludi and its underlying Javascript runtime [arcajs](https://github.com/eludi/arcajs)
has been created and published by [eludi](https://eludi.net).

## Controls

asteroludi uses the SDL2 GameController API to obtain a button/axis mapping localized for the device and controller.
The in-game menu allows you to choose between modern twin-stick and classic asteroids-like input modes.
Additionally, you can switch there between a Nintendo (BAYX) and an XBox-like (ABXY) face button layout.

### Menu Screens

| Button | Action |
| ------ | ------ |
| D-PAD | Navigate menu |
| A | Select menu item |
| START+SELECT | Exit immediately |

### In-Game — Twin-Stick Input Mode

| Button | Action |
| ------ | ------ |
| Left Stick / D-PAD | Spacecraft movement direction |
| Right Stick / Face Buttons | Spacecraft fire direction |
| R1 | Activate shield |
| START | Open in-game menu |
| START+SELECT | Exit immediately |

### In-Game — Classic Input Mode

| Button | Action |
| ------ | ------ |
| D-PAD Left | Rotate spacecraft counterclockwise |
| D-PAD Right | Rotate spacecraft clockwise |
| D-PAD Up | Thrust |
| D-PAD Down | Shield / Brakes |
| A | Fire |
| START | Open in-game menu |
| START+SELECT | Exit immediately |

## Compile

- obtain a recent (2025.11+) binary or the source code of the arcajs runtime from its [Releases](https://github.com/eludi/arcajs/releases/) page
- several bootstrap scripts for compiling the runtime can be found in the [doc](https://github.com/eludi/arcajs/tree/master/doc) folder
- add the asteroludi.ajs game logic and assets archive to the same folder

## License

see LICENSE.md for details.

- asteroludi game logic and assets are released as shareware. Anyone is allowed and encouraged to freely create and distribute unaltered copies of the game.
- the arcajs runtime License is MIT style
