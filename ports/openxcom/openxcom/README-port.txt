Port of OXCE to the rg351p and possibly other rk3326 devices.

Instructions:

WARNING: The latest portmaster is mandatory.  If controls don't work then that means you need to update portmaster.


1.  Copy your UFO Defense/TFDT data files to ports/openxcom/data/UFO and/or /roms/ports/openxcom/data/TFTD.  You will need your own copy of the game data files, they are not included.  Please see https://www.ufopaedia.org/index.php/Installing_(OpenXcom) for known supported versions
2.  IF you haven't already, download the latest data file patches (there is one for UFO and one for TFTD) from here https://openxcom.org/downloads-extras/ and install it.
3.  Copy your saves if any to ports/user/xcom1 or ports/user/xcom2
4.  Copy your mods if any to ports/user/mods

WARNING:  Do not copy your options.cfg file from your computer or elsewhere, it will mess up the key bindings.


Controls

Note: For up to date instructions on how to use interactive text input mode (for naming bases, renaming troops, and so on) see https://github.com/romadu/gptokeyb as they can change fairly often.


Back/Select = 5 second speed (geoscape) or end turn (battlescape)
Start = menu (both)

analog stick = mouse
R1 = left mouse button
L1 = right mouse button
L2 = quicksave
R2 = quickload
X = bases (geoscape) or inventory (battlescape)
Y = 30 min speed (geoscape) personal lighting (battlescape)
B = 5 min speed (geoscape) or next unit (battlescape)
A = intercept menu (geoscape) or use right hand item (battlescape)



Interactive Text Input controls (WARNING: subject to change at any time)

START+D-PAD DOWN to activate
once activated
D-PAD UP = previous letter
D-PAD DOWN = next letter
D-PAD RIGHT = next character
D-PAD LEFT = delete and move back one character
L1 = jump back 13 letters for current character
R1 = jump forward 13 letters for current character
A = send ENTER key and exit mode
SELECT/HOTKEY = cancel and exit mode (deletes all characters)
START = confirm and exit mode (also sends ENTER key)


Compiling/Dev Info

This is a straight port of OpenXcom Extended (https://github.com/MeridianOXC/OpenXcom), only the default keybindings in Options.cpp has been modified.  It was compiled using the premade virtual machine by Christian_Haitian (https://forum.odroid.com/viewtopic.php?p=306185#p306185) and uses sdl12-compat for libSDL-1.2.so.0.  All other libraries were copied as-is from /mnt/data/arm64/usr/lib/aarch64-linux-gnu from the development vm.
