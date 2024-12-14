## Notes

Everything is included and ready to run.

Thanks to the [Upperland](https://rockbot.upperland.net/?page_id=301) team for Rockbot and RockDroid!
Thanks to Slayer366 for porting this game to PortMaster!

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

Download Source Code
Extract contents of Rockbot_Source_X.XX.XXX.tar.gz
Edit inputlib.cpp
Comment out the following lines as follows:
```shell
line 66    //SDL_JoystickEventState(SDL_ENABLE);
line 67    //joystick1 = SDL_JoystickOpen(game_config.selected_input_device);
line 73    //joystick1 = SDL_JoystickOpen(game_config.selected_input_device);
```
Save changes
Edit Rockbot.pro or RockDroid.pro (depending on downloaded source)
Comment out all platforms using a '#' except for 'Linux
```shell
CONFIG += linux
#CONFIG += android
#CONFIG += win32
#CONFIG += playstation2
#CONFIG += dingux
#CONFIG += open_pandora
#CONFIG += wii
#CONFIG += dreamcast
#CONFIG += macosx
```
Install qmake and older compilers for ensured compatibility:
```shell
sudo apt install -y qt5-qmake gcc-7 g++-7
```
Generate Makefile by running:
```shell
qmake
```
Edit Makefile
Change 'CC = gcc' to 'CC = gcc-7'
Change 'CXX = g++' to 'CXX = g++-7'
Add '-Wno-deprecated -Wno-unused-parameter -Wno-sign-compare' to CXXFLAGS =
Remove '-lX11' from LIBS =
Save changes
Build with:
```shell
make -j4
```
