# Super Blood Hockey

Relive the golden age of arcade sports gaming with Super Blood Hockey.

Create and manage your team in a violent, dystopic world of no-rules, fast-paced, 
arcade-style, ice hockey action. Adjust training regimens, control diets, 
administer black market pharmaceuticals, and provide healthcare (or not) to a 
ragtag team of convicts at the mercy of your underhanded tactics.

## Instructions

You must provide the Steam data files for Super Blood Hockey.
https://store.steampowered.com/app/532190

Supports both Windows and Linux versions.
Place all game files into the `superbloodhockey/gamedata` folder.

On first launch, the port automatically patches the game's last two
resolution slots: slot 13 (2560x1440) → 640x480, slot 14 (3840x2160) → 720x720. 
Patcher works with version 1.5.4 only. Otherwise, the unpatched 
game has a minimum supported resolution of 1024x768.

## Notes

Thanks to the MonoGame project for the framework.
Thanks to JohnnyonFlame for the original Stardew Valley port which this is based on.
Thanks to Big Pickle for the screen resolution patching and port config.
