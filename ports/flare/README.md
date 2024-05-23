## Notes

# Flare Engine Portmaster Release
Original version by:
	https://github.com/flareteam/flare-engine

Portmaster Version: 	

- Cebion https://github.com/Cebion
- Black_Hand https://github.com/Blackerererer
	
Special thanks to: kloptops for helping me test it

# Compatible Mods:
Flare: Empyrean Campaign (Default Preinstalled Game)

Flare: Alpha Demo (Original Game that came with the Flare Engine)

HERESY: Community mod with the goal of more closely resembling Diablo I & II. https://flarerpg.org/mods/heresy/

Noname Mod: Community Mod built upon Alpha Demo Mod https://flarerpg.org/mods/noname-mod/

Polymorphable: A total conversion, orthographic game https://flarerpg.org/mods/polymorphable/

OpenValley: Open Source version of Stardew Valley https://gitea.it/rixty/OpenValley

# Instructions:

To run the game start Flare Engine.sh from your ports folder.
To add Mods copy them to the flare/mods folder and select the mod in the confiuration/mod menu ingame.


## Controls

| Button | Action |
|--|--| 
|Start|Enter|
|Select|Back|
|A|Attack 1|
|B|Attack 2|
|X|Belt 3|
|Y|Belt 4|
|L1|Belt 1|
|R1|Belt 2|
|L2|Page Forward|
|R2|Page Back|
|L3|Access Menu|
|DPAD Up|Character|
|DPAD Down|Log|
|DPAD Left|Powers|
|DPAD Right|Inventory|
|Joystick|Move|

Alternative scheme probably more suited for horizontal handhelds.
Enable be swapping flare/conf/.config/flare/keybindings.txt for flare/conf/.config/flare/keybindings.txt_alt.
The keybindings.txt file is the one with the active controls.

| Button | Action |
|--|--| 
|Start|Enter|
|Select|Back|
|L1|Attack 1|
|R1|Attack 2|
|A|Belt 1|
|B|Belt 2|
|X|Belt 3|
|Y|Belt 4|
|L2|Page Forward|
|R2|Page Back|
|L3|Access Menu|
|DPAD Up|Character|
|DPAD Down|Log|
|DPAD Left|Powers|
|DPAD Right|Inventory|
|Joystick|Move|


## Compile

```shell
git clone https://github.com/flareteam/flare-engine.git # clone the latest source code
git clone https://github.com/flareteam/flare-game.git # and game data
cd flare-engine 
mkdir build && cd build
cmake ..
make -j8
```
