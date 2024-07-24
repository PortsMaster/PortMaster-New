## Notes

Thanks to Adam Le Doux for making [bitsy](https://www.bitsy.org/) and giving us the permission to distribute bitsybox with *A night train to the forest zone* and *Mossland*.

If you like this game please support the author on [itch.io](https://ledoux.itch.io/bitsybox)

## Tell me more

~ a little engine for little games, worlds, and stories ~

Bitsy games are little games or worlds where you can walk around and talk to people and be somewhere. Games are composed of several rooms that your avatar can walk between. As your avatar walks around your Bitsy world they may interact with sprites (people, objects etc. that you can talk to) and items. Anything non-interactive in a room is called a tile, which is used for decoration.

## Create your own games

Use the online [game editor](https://make.bitsy.org/). Also [read the doc](https://make.bitsy.org/docs/) is a good start.

## Add new bitsy game

Just put the bitsy game file in the *bitsybox/games* folder.

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


