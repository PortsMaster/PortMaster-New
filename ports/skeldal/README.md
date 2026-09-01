## Notes

Thanks to `Napoleon Games` for developing and to `Ondřej Novák` for updating this game to work on modern systems, and kindly releasing the [source code](https://github.com/ondra-novak/gates_of_skeldal/) under MIT license. Buy the game on [Steam](https://store.steampowered.com/app/3533830/Brany_Skeldalu/).

Also thanks to `BinaryCounter` for his OmniOSK.


## Controls

| Button | Action |
|--|--| 
|DPAD|Movement / OSK Controls|
|Left Stick|Mouse|
|A / B|Mouse Buttons|
|Y|Slow mouse|
|X / X (OSK]|ENTER - Confirm / OSK Key Confirm|
|L1/L2|Side step|
|L1 (OSK)|Change layout|
|L2|Invoke Onscreen Keyboard|
|R2|Hotkey|
|Start|Map|
|Select|Cancel (ESC)|
|Hotkey + A|Sleep|
|Hotkey + B|Inventory|
|Hotkey + X|Magic|
|Hotkey + Y|Journal|

The party management (splitting or rejoining) is controled by respective number key via OSK - for example number key "1" for the first character etc.

## Compile
Required SDL 2.0 Base development platform is Ubuntu 24

```shell

mkdir build
cd build
cmake -DCMAKE_CXX_FLAGS="-Wno-error=sign-compare" ..
make all


```
