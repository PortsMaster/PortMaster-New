## Notes
<br/>

Thanks to the [Yamagi Quake II team](https://github.com/yquake2/yquake2) for developing this client and [romadu](https://github.com/romadu/yquake2) for the porting work for portmaster.  Thanks to Habbening and Slayer366 for the port updates to support expansion packs and GLES3 support (also provided by the Yamagi Quake II team via their latest yq2 source port updates).
<br/>

## Controls

| Button | Action |
|--|--| 
|Select|Menu/Esc|
|Start|Pause|
|A|Next Weapon|
|B|Previous Weapon|
|X|Use item|
|Y|Crouch|
|L1|Jump|
|L2|Drop item|
|R1|Fire|
|R2|Objectives/Stats/Q2 'puter|
|D-Pad|Item Selection|
|Left Analog|Move|
|Right Analog|Look/Mouse|
|L3|Run|
|R3|Center View|

## Compile

All binaries will be located in their 'release' folder after compiling.

```shell
https://github.com/yquake2/yquake2
cd yquake2
make -j$(nproc)

https://github.com/yquake2/ctf
cd ctf
make -j$(nproc)

https://github.com/yquake2/rogue
cd rogue
make -j$(nproc)

https://github.com/yquake2/xatrix
cd xatrix
make -j$(nproc)

https://github.com/yquake2/zaero
cd zaero
make -j$(nproc)
```
