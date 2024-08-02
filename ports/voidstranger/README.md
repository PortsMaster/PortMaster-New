# README

GitHub for this port- https://github.com/EzDzzIt/vsaarch64
 
This port supports v1.1.1 of the Steam version of the game, or v1.1.1 of the itch.io version (itch version is patched to be equivalent to the Steam version).

## Instructions for Running

-Purchase game via https://store.steampowered.com/app/2121980/Void_Stranger/ 

-Place all game .png, .dat, .csv, and .win files in the "/gamedata/" folder. 

-On first run, the game will take a 2-4 minutes to load. The port is running through patching the data.win file via xdelta, zipping audio files and other files into the .apk, and parsing the .csv game data file. Subsequent starts should go faster. 

## Controls

| Button | Action |
|--|--| 
|A|ACTION|
|B|ACTION|
|X|ACTION|
|Y|ACTION|
|L1|ACTION|
|DPAD|MOVEMENT|
|L STICK|MOVEMENT|
|R1|RIGHT CLICK (ACTIVATE CURSOR SHORTCUT)|
|R STICK|MOUSE MOVEMENT|
|L2|TOGGLE TIMER|
|R2|TOGGLE STEPS|
|START|MENU|
|SELECT|EXIT GAME|


The "X" and "L1" buttons will enter multiple actions if held down, mainly for skipping dialogue. 

## Credits

-Void Stranger by System Erasure.  

-Testing by Discord User @gooeyPhantasm. 

-gmloader by JohnnyOnFlame. 

-Thanks to the Portmaster Discord for their support.  
-Thanks to the System Erasure Discord group of modding enthusiasts (@gooeyPhantasm for testing, @skirlez & @Malkav0 for gml palette implementation, @skirlez, @AbbyV and @Fayti1703 for coding fixes). 

-Custom palettes that are included from the System Erasure Discord: 
    "ZERORANGER (FAMILIORANGE)" by gooeyPhantasm  
    "GB GREEN" by gooeyPhantasm  
    "GB POCKET" by gooeyPhantasm  
    "VOID TRANSGER" by Moonie  
    "GREY" by Moonie  
    "S U N S E T" by Moonie 
    "PACHINKO" by Moonie 
    "PORTMASTER" by Moonie 
    "P***" by Ayre223 
    "ICEEY" by Rafl 
    "MAMMON" by Rafl 

-Custom loading splash screen by gooeyPhantasm. Font is Alkhemikal by Jeti. 

## *Built With*

[gmloader-next](https://github.com/JohnnyonFlame/gmloader-next/blob/master/LICENSE.md)

[UTMT-CE](https://github.com/XDOneDude/UndertaleModToolCE/blob/master/LICENSE.txt) 
