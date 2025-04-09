## Notes

Apricots has nothing to do with apricots. It's a game where you fly a little plane around the screen and shoot things and drop bombs on enemy targets, and it's meant to be quick and fun.

Big thanks to [Moggers87](https://github.com/moggers87/apricots) for producing this game. 

The [source](https://github.com/moggers87/apricots)

At present there is no option screen. Options can be changed by editing the configuration file apricots.cfg. This is first searched for in ~/.config/apricots/, then the system configuration directory (usually /usr/local/etc or /etc) and finally the default configuration in the data directory.

The number and type of planes can be varied, along with the airbases, as can 1/2 player game be chosen. The number of anti aircraft guns and scenery can be selected. Draks can be turned on or off, and a different condition for winning the game can be chosen.

## Controls

| Button | Action |
|--|--| 
|B|Fire|
|A|Bomb|
|UP|Accelerate|
|DOWN|Bomb|


## Compile

```shell
 ./configure --prefix=./

apricots/apricots.h

changed game height from 240 
const int GAME_HEIGHT = 400;

```
