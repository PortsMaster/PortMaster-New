## Notes

Thanks to [ReflectionHLE](https://github.com/ReflectionHLE/ReflectionHLE) for this capable source port covering the Catacomb 3D games with incredible support for mobile devices.

When using the on-screen quick-controls the buttons are swapped.  A is B, B is A, X is Y, Y is X.  This is an issue in the code as this also occurs on the Windows release, too.

## Controls

| Button | Action |
|--|--| 
|D-Pad|Move|
|Left Analog|Move|
|A|Use Health Potion|
|B|Strafe|
|X|Fire Missile/Bolt|
|Y|Fire Nuke|
|L1|Turn faster|
|R1|Fire Primary|
|L2+R2|Quick Menus|
|L3|OSK|


## Compile

Extract the contents of reflectionhle-sauce.7z

```shell
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j3
```