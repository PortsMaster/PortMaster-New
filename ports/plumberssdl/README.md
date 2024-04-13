## Notes

Thanks to [MaikelChan](https://github.com/MaikelChan/PlumbersDontWearTies-SDL) for this re-implementation of this cult classic and [Daniel Marschall](https://misc.daniel-marschall.de/spiele/plumbers/?page=pc_gamebin) for reverse engineering the original GAME.BIN file.

***This port requires the pc version.***

Copy GAME.BIN and folders SC00 - SC32 and SC99 to the DATA folder.

## Controls

| Button | Action |
|--|--| 
|Start|Enter|
|ABXY|Enter|
|Select|Esc|
|DPAD|Up/Down|
|Left/Right Joystick|Up/Down|


## Compile

```shell 
git clone https://github.com/christopher-roelofs/PlumbersDontWearTies-SDL.git
cd PlumbersDontWearTies-SD
mkdir build && cd build
cmake ..
make
```
