## Notes

Thanks to [Render96](https://linktr.ee/Render96) team for developping this port and to [Retro Aesthetics](https://retroaesthetics.net/) team for the huge work on the 3D models.

Sources: https://github.com/Render96/Render96ex

## Disclaimer

You must own a legal copy of the Super Mario 64 rom.

**Don't ask Portmaster for help on how to obtain this copy.**

## Game data files needed:

Copy your Super Mario 64 rom as *baserom.us.z64* to the root of the *render96ex* folder. A wizard will then guide you during the first launch of the game to install the assets from the rom and the optional packages. During this installation process if it seems that you can not validate a choice (Yes/No/OK) when a message popups try to press **A**/**B** then **DPAD up/down**.

**Only the US version of the ROM is supported in this port.**

The SHA1 sum of *baserom.us.z64* is *9bef1128717f958171a4afac3ed78ee2bb4e86ce*.

## Optional packages

This port comes with 3 optional packages:
* HD gfx textures pack, a lowmem resize version of [RENDER96-HD-TEXTURE-PACK](https://github.com/pokeheadroom/RENDER96-HD-TEXTURE-PACK/).
* Dynos audio pack, a lowmem resampled version (22.05 kHz) from the [Rendex96ex](https://github.com/Render96/Render96ex) project.
* Dynos 3D model pack, a lowmem resized version of [Render96 Alpha v3.1 modelpack](https://github.com/Render96/ModelPack). 

## Important notes

**If you are using muOS** (2405.1 refried beans or older version) you shall not install the dynos audio pack otherwise the game will crash. Without this pack the game will then be missing musics and sfx sounds. This is the only option until the support of multiple audio stream is added in muOS.

If you have chosen to install the Dynos 3D model pack, it is not enabled by default because on most handheld the game will be choppy when combined with the 60 fps feature. You have to enable it in the dynos menu.

The 60 fps feature is enabled by default. If your device can not handle it and the game is running choppy you can try to disable it in the display options in the option menu. Then wait few seconds to let the framerate stabilize.

You may need to adjust your gamepad configuration in the option menu depending on your CFW and the handheld model.

## Menus

The option menu can be accessed during the game by pressing **Start** then **R1** (this is R on N64 gamepad).

The Dynos menu can be accessed during the game by pressing **Start** then **L2** (this is Z on N64 gamepad).

## How to reset configuration

If you did something wrong in the configuration (option menu) and the game won't start anymore you can reset to default by deleting/renaming *render96ex/conf/sm64config.txt*.

If you did something wrong in the dynos configuration (dynos menu) and the game won't start anymore you can reset to default by deleting/renaming *render96ex/conf/DynOS.1.1.alpha.config.txt*.

## Controls

| Button | Action |
|--|--| 
|LSTICK|Movement|
|RSTICK|Camera|
|R1|Change camera mode|
|L1|Change camera mode|
|L2|Duck|
|A|Jump|
|B|Action|
|Start|Start/Pause|


