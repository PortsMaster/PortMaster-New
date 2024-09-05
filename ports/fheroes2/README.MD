## WHAT IS FHEROES 2 ?

fheroes2 is a recreation of the Heroes of Might and Magic II game engine.

This open source multiplatform project, written from scratch, is designed to reproduce the original game with significant improvements in gameplay, graphics and logic (including support for high-resolution graphics, improved AI, numerous fixes and user interface improvements), breathing new life into one of the most addictive turn-based strategy games.

Thanks to fheroes2 devs and Portmaster community for this opportunity to play Heroes 2 on our portable devices.

## HOW TO BUILD

For better compatibility fheroes2 was build in Ubuntu 20.04 arm64 chroot.

```
git clone https://github.com/ihhub/fheroes2
cd ./fheroes2
export LDLIBS=-lstdc++fs
make
```

## HOW TO RUN

Package contains only open source engine, for gaming you need original game files.
Add your own data, maps, music, sound folders from HOMM2 GOG version to ports/fheroes2 folder. 
Folder names are case sensitive and should be lower case. Files inside folders should not be renamed.

## CONTROLS

Controls according to gptk file:  
LEFT ANALOG mouse control  
RIGHT ANALOG map scrolling  
A   - mouse left  
B   - mouse right  
X   - end turn (E)  
Y   - cast battle spell (C)  
L1  -  next hero (H)  
L2 - save game (S)  
L3 - view world (V)  
R1  - next town (T)  
R2 - load game (L)  
R3 - default action (SPACE)  
DPAD UP - 1  
DPAD RIGHT - 2  
DPAD DOWN - 3  
DPAD LEFT - 4  
START - ENTER  
SELECT -  ESC  
