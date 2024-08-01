# README

GitHub for this port- https://github.com/EzDzzIt/vsaarch64
 
This port supports v1.1.1 of the Steam version of the game, or v1.1.1 of the itch.io version (itch version is patched to be equivalent to the Steam version).

## Instructions for Running

-Purchase game via https://store.steampowered.com/app/2121980/Void_Stranger/ 

-Place all game .png, .dat, .csv, and .win files in the "/gamedata/" folder. 

-On first run, the game will take a 2-4 minutes to load. The port is running through patching the data.win file via xdelta, zipping audio files and other files into the .apk, and parsing the .csv game data file. Subsequent starts should go faster. 

## Controls

-The game should recongnize an xinput controller natively if you are using one with your device for some reason. 

-From the .gptk file: 

(|controller button| = |keyboard key|)  
back = esc  
start = enter  

up = up  
down = down  
left = left  
right = right  
left_analog_up = up  
left_analog_down = down  
left_analog_left = left  
left_analog_right = right  

a = z  
b = z  
x = z  
y = z  
l1 = z 

l2 = f2  
r2 = f3

r1 = mouse_right  
right_analog_up = mouse_movement_up  
right_analog_down = mouse_movement_down  
right_analog_left = mouse_movement_left  
right_analog_right = mouse_movement_right 

The "X" and "L1" buttons are planned to be "turbo" buttons; currently not fully functional, but holding these buttons will result in multiple inputs if you're trying to skip through dialogue. 

## Credits

-Void Stranger by System Erasure.  

-Testing by Discord User @gooeyPhantasm. 

-gmloader by JohnnyOnFlame. 

-Thanks to the Portmaster Discord for their support.  
-Thanks to the System Erasure Discord group of modding enthusiasts (@gooeyPhantasm for testing, @skirlez & @Malkav0 for gml palette implementation, @skirlez, @AbbyV and @Fayti1703 for coding fixes). 

-Custom palettes that are/will be included from the System Erasure Discord: 
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

-https://github.com/JohnnyonFlame/gmloader-next/blob/master/LICENSE.md 

-https://github.com/XDOneDude/UndertaleModToolCE/blob/master/LICENSE.txt 
