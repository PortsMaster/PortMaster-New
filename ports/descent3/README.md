# Descent 3 for PortMaster

## Notes
This fork of Descent 3 is tailored to retro handhelds via gl4es and PortMaster. Build instructions can be found at the [fork repository](https://github.com/JeodC/Descent3). The provided binary was built with debian bullseye to support older GLIBC. You can build your own binary with newer GLIBC using bookworm, if your CFW supports it, but performance gain may be minimal.

The following patches have been applied to this release:

- Revert the framebuffer object render code (deviate from upstream), which was necessary to make the game render with gl4es
- Load GL functions after context creation, which allows the custom libGL library to be loaded
- Adjust viewport and scissor to automatically scale properly among various resolutions and aspect ratios
- Add PortMaster branding to title screen to differentiate between upstream and other forked builds
- Make mouse cursor invisible in menus in Release builds (still visible and usable in Debug builds)
- Change level select menu to a listbox with pretty names for core levels
- Add pregenerated `.Descent3Registry` and `Pilot.plt` files with default controls using analog joysticks if available and gptokeyb to emulate keyboard presses for buttons
- Prefill savegame dialog with current level number if blank slot or different level than existing slot
- Reveal secret levels on campaign completion
- Put core campaign missions at the top of the mission list

## Installation
Unzip to ports folder e.g. `/roms/ports/`. Purchase the full game from GOG or Steam, or use CD game data patched to v1.4. Then, add the following files to `descent3/gamedata`:

Filelist for full versions:  
├── descent3/gamedata  
│   ├── missions/  
│   │ └── any mission files (`.mn3`) and `d3voice1.hog` and `d3voice2.hog` if they came with your game  
│   ├── movies/  
│   │ └── any movie files (`.mve`) that came with your game. If you have the Linux Steam version, use steamcmd to get the windows movie files  
│   └── d3.hog  
│   └── extra.hog (this may be `merc.hog` depending on the platform you used to purchase the game)  
│   └── extra1.hog  
│   └── extra13.hog  
│   └── ppics.hog  

## Configuration
The included pilot file is tailored to retro handhelds with a combination of joystick and gptokeyb controls, since the port does not use `gamecontrollerdb.txt`. The launchscript selects this pilot file by default, 
but you can modify the name by opening the file in a text editor.

You can modify game options in `d3.ini` or ingame using buttons--R1 to scroll options, START to confirm.

If you need to invert joystick axis, open `descent3/config/joy.gptk` and change the line `r1_hk = f8` to `r1_hk = /`. Save the file and open the game, and in the config options you can use `HOTKEY + R1` to open the invert dialog. If you don't care about the ship log, you can keep things this way, otherwise change `joy.gptk` again after you're done.

## Multiplayer
You can play multiplayer via PXO. Go to https://pxo.nottheeye.com and register an account, then validate your email. Then, on the account details page, copy your game credentials and paste into `d3.ini`. When you start Descent 3 and try to connect to PXO, your login detals will be filled automatically and you can just press `Start` to log in. Now you can host or join games!

You can also play multiplayer via Direct TCP-IP. In `d3.ini`, specify an IP address to connect to. Then, load your game, choose the Direct TCP-IP multiplayer protocol, and it will be prefilled for you.

## Default Gameplay Controls
You can use the `D-PAD` buttons in menus to select items and scroll pages.

| Button | Action |
|--|--| 
|A|Rear View|
|B|Use Inventory Item|
|X|Toggle Headlight|
|Y|Fire Flare|
|L1|Fire Secondary Weapon|
|R1|Fire Primary Weapon|
|L2|Scroll Primary Weapon|
|R2|Scroll Secondary Weapon|
|L3|Afterburner|
|R3|Unassigned|
|D-PAD UP|Look Up|
|D-PAD DOWN|Look Down|
|D-PAD LEFT|Turn Left|
|D-PAD RIGHT|Turn Right|
|LEFT ANALOG|Accelerate/Reverse & Slide Left/Right|
|RIGHT ANALOG|Look Around|
|START|Start / Accept / Enter|
|SELECT|Back / Escape|
|SELECT + Y|Previous Inventory Item|
|SELECT + A|Next Inventory Item|
|SELECT + B|Guidebot Menu|
|SELECT + X|Cycle Left Window|
|SELECT + L1|Open Telcom (Briefing and Objectives)|
|SELECT + R1|View Ship Log|
|SELECT + L2|Load Game|
|SELECT + R2|Save Game|

## Thanks
fpasteau  
InsanityBringer  
Descent Developers Team  
Testers and Devs from the PortMaster Discord  
Outrage Entertainment  
