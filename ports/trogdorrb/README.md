## Notes

Thanks to [Mode8fx](https://github.com/Mode8fx/Trogdor-Reburninated) for making this recreation of a classic game.


## Controls

| Button | Action |
|--|--| 
|Dpad and Joysticks|Move|
|Start|Start|
|A|Confirm|
|B|Back|
|Y|Change resolution|
|X|Change overlay|
|Select|Quit while paused|
|Start + Select|Force quit|


## Compile
All previous custom steps have been merged into the main repo so below steps are all that are needed.

```shell
git clone https://github.com/Mode8fx/Trogdor-Reburninated.git
cd Trogdor-Reburninated/Trogdor-Reburninated
mkdir build
cd build
cmake ../ -DLINUX=ON
make
```
