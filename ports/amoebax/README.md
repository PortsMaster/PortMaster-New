# Thanks
Thanks to the [Emma Software Team](https://www.emma-soft.com/games/amoebax/) for creating this game and making it available for free.

## Controls

| Button | Action |
|--|--| 
|DPAD| Player 1 Move |
|R1| Player 1 Rotate |
|L1| Player 2 Rotate |
|A | Shoot Gun|
|B | Drop Bomb| 

## Building

```
wget https://www.emma-soft.com/games/amoebax/download/amoebax-0.2.1.tar.bz2
cd amoebax/
wget -O config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
wget -O config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
./configure
make
```