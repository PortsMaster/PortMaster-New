## Notes

Everything is included and ready to run.

Thanks to the [Upperland](https://rockbot.upperland.net/?page_id=301) team for Rockbot and RockDroid!
Thanks to Slayer366 for porting this game to PortMaster!

Versions downloaded from Upperland:
1.2.74   for RockBot   (Version Number is 2.0.0b70 in file/version.h and 1.20.074 in archive name)
2.01.067 for RockDroid (Version Number is 2.01.065 in file/version.h and 2.01.067 in archive name)

</br>

## Controls

| Button | Action |
|--|--| 
|D-pad/L-Stick/R-Stick|Move|
|Select|Escape/Quit|
|Start|Enter/Make selection|
|A|Jump|
|B|Attack|
|X|Dash|
|Y|Shield|
|L1|Jump|
|R1|Attack|
|L2|Previous Weapon|
|R2|Next Weapon|
|L3/R3|Dash|

</br>

## Compile
### Rockbot
```shell
sudo apt install -y qt5-qmake gcc-7 g++-7
git clone https://github.com/slayer366/rockbot
cd rockbot
make -j4
```

### RockDroid
```shell
sudo apt install -y qt5-qmake gcc-7 g++-7
git clone https://github.com/slayer366/rockdroid
cd rockdroid
make -j4
```
