## Notes

Source: [Slayer366](https://github.com/slayer366/Halloween3D)
Forked from: [brizzly](https://github.com/brizzly/Halloween3D)

NOTE: Play on EASY difficulty.
      The second arena is missing the second 'L' to finish spelling 'HALLOWEEN'.
      Higher difficulties require completing spelling 'HALLOWEEN' to win the stage.
      This currently makes it impossible to complete this stage on NORMAL or HARD.

## Controls

| Button | Action |
|--|--| 
|Select/L2|Menu/Esc|
|Start|Enter|
|A/L1|Jump|
|B|Back|
|X|Action/Special|
|Y|Crouch|
|R2|Mace|
|R1|Attack|
|D-Pad|Weapon Selection|
|Left Analog|Move|
|Right Analog|Look/Mouse|
|L3/R3|Run|

## Compile

Git clone into the repo below and based on your architecture
copy libbass.so.aarch64/x86_64/armhf over libbass.so in HalloweenSrc/
prior to compiling so that the correct libbass.so gets linked

```shell
git clone https://github.com/slayer366/halloween3d
cd halloween3d/HalloweenSrc
mkdir build
cd build
cmake ..
make -j4
```
