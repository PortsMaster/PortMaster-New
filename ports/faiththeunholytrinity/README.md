# FAITH The Unholy  - PortMaster Modification & Wrapper
This is a wrapper and xdelta modification for vanilla FAITH: The Unholy Trinity that makes the game more manageable on retro handheld systems running linux arm64.

## Installation
Purchase the game on Steam or GOG and copy all the data to `ports/faiththeunholytrinity/assets`, important files are data.win, audiogroup1.dat through audiogroup18.dat, and UTconfigs.cvs files. On first run the game will be patched.

## Controls
| Button | Action |
|--|--|
|START|Menu|
|D-PAD|Move|
|A|Action|

## Performance Notes
This port features audio compression in an attempt to reduce memory usage. This is necessary in order for the port to run on the linux arm handhelds targeted. These handhelds are equipped with low-end rockchip or allwinner processors and usually 1-2GB of memory, alongside Mali blob drivers. Low processing power, low memory, and low VRAM are all major things to watch for when running ports on these devices.

## xDelta Patch Notes
For the more technically inclined, here are specific modifications made in order to make FAITH: The Unholy Trinity run smoothly on the targeted devices:

- [GMTools](https://github.com/cdeletre/gmtools) by Cyril Deletre to resample audio at a lower bitrate
- [UndertaleModTool](https://github.com/UnderminersTeam/UndertaleModTool) to make some specific changes to the game
    - Compress Textures to save memory.
    - (Steam Version Only) About 50% of steam api function calls did not check if steam was initialized, leading to some math with undefined values which would cause segfaults. Steam API functions are now wrapped in an if statement to verifed that steam is initialized.

## Thanks
Airdorf -- For the amazing game
- https://store.steampowered.com/app/1179080/FAITH_The_Unholy_Trinity/
- https://www.gog.com/en/game/faith_the_unholy_trinity
JohnnyOnFlame -- For GMLoader-Next 
Cyril aka kotzebuedog -- For GMTools audio patcher
Jeod -- For the UFO 50 port, which was used as reference for this port
Testers & Devs from the PortMaster Discord