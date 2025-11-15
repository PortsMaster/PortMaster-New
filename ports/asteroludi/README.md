# asteroludi README

## Notes

asteroludi and its underlying Javascript runtime [arcajs](https://github.com/eludi/arcajs)
has been created and pusblished by [eludi](https://eludi.net).

## Compile

- obtain a recent (2025.11+) binary or the source code of the arcajs runtime from its [Releases](https://github.com/eludi/arcajs/releases/) page
- several bootstrap scripts for compiling the runtime can be found in the [doc](https://github.com/eludi/arcajs/tree/master/doc) folder 

## Controls

asteroludi uses the SDL2 GameController API to obtain a button/axis mapping localized for the device and controller.
The in-game menu allows you to choose between a modern twin-stick and a classic asteroids-like input modes.
Additionally, you can switch there between a Nintendo (BAYX) and an XBox-like (ABXY) face button layout.

### Menu screens
A = select menu item
DPad = navigate in menu 
START + SELECT = exit immediately

### in-game twin-stick input mode
Left stick / DPad = spacecraft movement direction
Right stick / face buttons = spacecraft fire direction
R1 = activate shield
START = open in-game menu
START + SELECT = exit immediately

### in-game classic input mode
DPad left = spacecraft rotate counterclockwise
DPad right = spacecraft rotate clockwise
DPad up = spacecraft thrust
DPad down = spacecraft shield / breaks
A = spacecraft fire
START = open in-game menu
START + SELECT = exit immediately

## License

see LICENSE.md for details.

- asteroludi game logic and assets are released as shareware. Anyone is allowed and encouraged to freely create and distribute unaltered copies of the game.
- the arcajs runtime License is MIT style
