## Notes
<br/>

Thanks to [icculus](https://icculus.org/rott/) for the source port of this game.  
Also thanks to romadu for the porting work for portmaster
Additional thanks to Slayer366 for the MIDI music fix.
<br/>

## Controls

| Button | Action |
|--|--|
|Select|Menu/Esc|
|Start|Enter|
|A|Special weapon|
|B|MP40|
|Y|Dual Pistols|
|X|Activate switches/Open doors|
|L1/R3|Run|
|L2|Look down/Fly down|
|R2|Look up/Fly up|
|R1|Attack|
|D-Pad|Navigate Menus/Move+Turn|
|Left Analog|Move+Strafe|
|Right Analog|Turn+Aim|
|L3|Map|

## Compile

To build the executable for The Hunt Begins shareware:
```shell
git clone https://github.com/LTCHIPS/rottexpr
cd rottexpr/src
#edit Makefile
# Change '-std=c17' on line 19 to correct version if necessary
# Change 'SHAREWARE   ?= 0' on line 5 to 'SHAREWARE   ?= 1'
#save and exit
cd audiolib
#edit Makefile
# Change '-std=c17' on line 9 to correct version if necessary
# save and exit
cd ..
# From the rottexpr/src directory:
make -j$(nproc)
mv rott rott_sw
```

To build the executable for Dark War (registered version - does not contain shareware levels):
Repeat the steps for 'The Hunt Begins' above except for one minor change:
```shell
cd rottexpr/src
#edit Makefile
# Make sure to set both SHAREWARE and SUPERROTT to 0 
# 'SHAREWARE   ?= 0' on line 5
# 'SUPERROTT   ?= 0' on line 6
#save and exit
make -j$(nproc)
mv rott rott_dw
```
