## Notes
Thanks to the [Karl Bartel](https://www.linux-games.com/penguin-command/) for creating this game and making it available for free!

## Controls

| Button | Action |
|--|--| 
|Analogue Sticks| Move Mouse|
|Start | Start Game / Left mouse button|
|A| Right Cannon|
|B| Middle Cannon|
|X| Left Cannon|

## Compile

```shell
wget http://prdownloads.sourceforge.net/penguin-command/penguin-command-1.6.11.tar.gz
./configure --build=aarch64-unknown-linux-gnu
In Makefile replace autoconf-1.09 with autoconf
Make
```