## Notes

Thanks to [sulix](https://github.com/sulix/omnispeak) for this open-source re-implementation of "Commander Keen in Goodbye Galaxy".  

Get Commander Keen from:  
[Steam](https://store.steampowered.com/app/9180/Commander_Keen/)  
OR  
[GOG](https://www.gog.com/en/game/commander_keen_complete_pack)  

#### Game files needed:

**Keen 4 v1.4 EGA (Secret of the Oracle)**:
Commander Keen 4: Secret of the Oracle is shareware and is included and ready to play.

**Keen 5 v1.4 EGA (The Armageddon Machine)**:
- omnispeak/data/keen5/GAMEMAPS.CK5
- omnispeak/data/keen5/EGAGRAPH.CK5
- omnispeak/data/keen5/AUDIO.CK5

**--Only one version of Keen 6 (Aliens Ate My Babysitter!) is required--**

**Keen 6 v1.4 EGA**:
- omnispeak/data/keen6e14/GAMEMAPS.CK6
- omnispeak/data/keen6e14/EGAGRAPH.CK6
- omnispeak/data/keen6e14/AUDIO.CK6

**--OR--**

**Keen 6 v1.5 EGA**:
- omnispeak/data/keen6e15/GAMEMAPS.CK6
- omnispeak/data/keen6e15/EGAGRAPH.CK6
- omnispeak/data/keen6e15/AUDIO.CK6

**Keen 7 (The Keys of Krodacia)**:
Commander Keen 7: The Keys of Krodacia is an unofficial mod / fan-made episode developed by a fan team led by Ceilick and the bundled version modded to work with omnispeak is included.

</br>

#### Other Keen Mods:
- Drop a mod folder into /ports/omnispeak/data/ with its contents.
- Make a copy of 'OmniSpeak - Keen 7.sh'
- Rename it to match the name of the mod
- Modify the new shell script to enter the mod's directory (line 21) and load its mod.ck# if applicable.

</br>

## Controls

| Button | Action |
|--|--| 
|Select/L1|Menu/Esc|
|Start/R1|Enter|
|A|Jump|
|B|Fire|
|X|Pogo Stick|
|Y|Answer 'Yes'|
|L2|Quick Save|
|R2|Quick Load|
|Up|Move Up/Look up/Climb|
|Down|Move Down/Look down/Descend|
|Left|Move Left|
|Right|Move Right|
|Left Analog/Right Analog|Move/Same as D-Pad|
|L3/R3|Toggle Score Box|


</br>

## Compile
```shell
git clone https://github.com/sulix/omnispeak
cd omnispeak
mkdir build
cd build
cmake .. -DRENDERER=sdl2
make -j$(nproc)
```
