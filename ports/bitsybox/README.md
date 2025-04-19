## Notes

~ a little engine for little games, worlds, and stories ~

Bitsy games are little games or worlds where you can walk around and talk to people and be somewhere. Games are composed of several rooms that your avatar can walk between. As your avatar walks around your Bitsy world they may interact with sprites (people, objects etc. that you can talk to) and items. Anything non-interactive in a room is called a tile, which is used for decoration.

## Add new bitsy game

Just put the `.bitsy` game file in the *bitsybox/games* folder.

You can find more games on [itch.io](https://itch.io/games/made-with-bitsy).

## Create your own games

Use the online [game editor](https://make.bitsy.org/). Also [read the doc](https://make.bitsy.org/docs/) is a good start.

## Limitations

You might get some slowdowns in the games, especially on low-end devices, but it should still be playable. Considering how the bitsy engine works in bitsybox it is the best we can do at the moment. Bitsybox is coded in C and uses the [duktap](https://github.com/svaarala/duktape) library, also coded in C, to run the bitsy engine that is coded in javascript. Javascript is known to require lot of computing power.

## Controls

| Button | Action |
|--|--| 
|DPAD-UP|move up|
|DPAD-DOWN|move down|
|DPAD-LEFT|move left|
|DPAD-RIGHT|move right|
|START|return to menu / ok|

## Compile

```
git clone https://github.com/cdeletre/bitsybox-aarch64.git
cd bitsybox-aarch64
docker build --platform=linux/arm64 -t bitsybox-aarch64 .
docker run --rm -v ${PWD}:/bitsybox-aarch64 bitsybox-aarch64 /bitsybox-aarch64/build.sh
```

## Thanks

Thanks to Adam Le Doux for making [bitsy](https://www.bitsy.org/) and giving us the permission to distribute bitsybox with *A night train to the forest zone* and *Mossland*. If you like this game please support the author on [itch.io](https://ledoux.itch.io/bitsybox).

The cover has been made using [EmulationStation-ImageMaker](https://github.com/JeodC/EmulationStation-ImageMaker) from Jeod, thanks to him for making this great tool.

Thanks to my fellow testers from the PortMaster Discord <3

