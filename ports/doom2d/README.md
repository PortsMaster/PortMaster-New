## Notes

Thanks to [Doom2D](https://github.com/Doom2D/doom2d-rembo) for the SDL conversion of the original Doom 2D.

## Controls

| Button | Action |
|--|--| 
|D-Pad|Move|
|Left Analog|Move|
|A|Jump|
|B|Fire|
|X|Use|
|Y|Answer Yes|
|L2+R2|Change Weapon|
|Right Analog|Player 2 Move|
|L1|Player 2 Jump|
|R1|Player 2 Fire|
|L3|Player 2 Use|
|R3|Player 2 Change Weapon|

## Compile

Extract the contents of doom2d-sauce.7z

```shell
mkdir build
cd build
cmake ../src -DCMAKE_BUILD_TYPE=Release
make -j3
```