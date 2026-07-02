## Notes

A super huge thanks to those who put awesome effort into this amazing game!
Game by: [Locomalito](https://locomalito.com/)
port based on version found here [Github](https://github.com/nevat/abbayedesmorts-gpl)


## Controls

| Button | Action |
|--|--| 
|start|start|
|A|jump|
|B|start|
|X|info|
|Y|down|
|l1|up|
|r1|up|
|r2|gfx change|
|dpad|movement|
|left analog|movement|
|right analog|movement|

## Compile

Extract the contents of abbayedesmorts-src.7z or use the github repo
The following is for building on a Debian/Ubuntu based distro:

```shell
git clone https://github.com/slayer366/abbayedesmorts-portmaster
cd abbayedesmorts-portmaster
sudo apt install libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev
make -j4
```