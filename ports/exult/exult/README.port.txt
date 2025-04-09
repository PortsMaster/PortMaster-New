Port of Exult (Ultima 7 engine) to the rg351p and possibly other rk3326 devices.  The keyring mod for Black Gate and SIfixes mod for Serpent Isle are included, not that the keyring mod requires forge of virtue and sifixes requires the silver seed (if you use the GOG version then all expansions are included).

Instructions:

WARNING: The latest portmaster is mandatory.  If controls don't work then that means you need to update portmaster.  Also due to a limitation in gptokeyb the left analog stick movement will make the party move for a few seconds then stop.  Mouse movement works fine, as does dpad movement if you have an up to date gptokeyb.

NOTE: there is no on screen keyboard so it is not possible to name your avatar.  I highly recommend you start a new game on your PC (Windows/Mac/Linux/etc) and copy your save file over (save files go in either ports/exult/saves/blackgate or ports/exult/serpentisle, if using mods they go in in ports/exult/saves/[gamename]/mods/[modname] just like on a computer).  You can also copy your save files to a computer

WARNING: Save files are not compatible between mods and the vanilla game, thus if you want to use the keyring or sifixes mods you will also need them on your PC install of exult. There is a copy of the keyring and sifixes mods in the extras folder.

1.  Copy your Ultima 7 black gate files to ports/exult/data/blackgate and serpent isle files to  ports/exult/data/serpentisle.  You will need your own copy of the game files, they are not included.
2.  Copy your save files from your computer over to the proper folders
3.  If you are playing vanilla black gate or are playing serpent isle and have not obtained the keyring then run the Exult-nokeyring. If you are playing the keyring mod for black gate and have not obtained the keyring yet then run Exult-nokeyring as well.  If you are playing the keyring mod or serpent isle and have obtained the keyring then you will want to run the Exult-keyring.  The only difference between the two is that Exult-nokeyring maps L3 to "try all keys" while Exult-keyring maps L3 to "use keyring".


Controls

Back/Select = 5 second speed (geoscape) or end turn (battlescape)
Start = menu (both)

Right analog stick (if 2 analog sticks) = mouse
Left analog stick (if 2 analog sticks) = up/down/left/right (same as dpad)
Single analog stick = mouse
R1 = left mouse button
L1 = right mouse button
L2 = quicksave
R2 = quickload
L3 = try all keys or use keyring depending on whether you use the -nokeyring or -keyring startup script.
R3 = pick lock
X = inventory 
Y = sextant/show coords
B = begin/break off combat
A = target mode (pauses game and displays targeting cursor

Extras folder.

In the extras folder you will find several zip files.

optionalscripts.zip - contains optional startup scripts that will automatically boot straight to vanilla Black Gate/Serpent Isle (with expansions) as well as boot directly to the Black Gate with keyring mod and Serpent isle with the sifixes mod.

keyring.zip contains a copy of the keyring mod for black gate for easy instalation on your computer, please refer to the exult documentaton for how to install mods.

sifixes.zip contains a copy of the keyring mod for black gate for easy instalation on your computer, please refer to the exult documentaton for how to install mods.


Compiling/Dev Info

This is a straight port/compile of Exult 1.6.0 (http://exult.sourceforge.net/download.php) compiled with SDL2 (./configure --with-sdl=sdl2 --enable-mt32emu), only the configuration files and keymap files have been modified.  It was compiled using the premade virtual machine by Christian_Haitian (https://forum.odroid.com/viewtopic.php?p=306185#p306185). All other libraries were copied as-is from /mnt/data/arm64/usr/lib/aarch64-linux-gnu from the development vm.