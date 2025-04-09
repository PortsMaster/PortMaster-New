## Notes
Thanks to [Ultimate Stunts Team](https://www.ultimatestunts.nl/index.php?page=0&lang=en) for creating the game and making it available for free.
 

## Controls

| Button | Action |
|--|--| 
|A|Accelerate|
|B|Break|
|X|Shift UP|
|Y|Shift Down|
|R1|Next Song|
|DPAD| Steer |


## Compile

```shell
wget http://prdownloads.sourceforge.net/ultimatestunts/ultimatestunts-srcdata-0771.tar.gz
tar xf ultimatestunts-srcdata-0771.tar.gz
cd ultimatestunts-srcdata-0771
./configure --build=aarch64-unknown-linux-gnu --with-openal
make
```