# Wolfenstein 3D -- A PortMaster implementation of LZWolf and ECWolf to play Wolfenstein 3D and friends
<div align="center">
  <img src="https://github.com/user-attachments/assets/7c94dfb7-b86a-421a-bd26-142900204663" alt="lzwolf-menu" width="480" height="320"/>
</div>

## Installation
This port comes with the shareware and demo for Wolfenstein 3D and Spear of Destiny. LZWolf and ECWolf can run the following games:

- [Wolfenstein 3D / Spear of Destiny](https://www.gog.com/en/game/wolfenstein_3d)
- [Spear of Destiny Mission Packs]()
- [Super Noah's Ark 3D](https://wisdomtree.itch.io/s3dna)

To use them, place your game data (`.WL6`, `.SOD`, `.SD2`, `.SD3`, `.N3D`, etc) in `ports/wolf3d/data`.

## Play
To use addon mods, place `.pk3` files in `ports/wolf3d` and list the `.pk3` files to load in `.load.txt` for the relevant game. use the Left Shoulder and Right Shoulder buttons in the launcher to select which engine to use.

## Config
The launchscript is set up to use one of two `.cfg` files based on the presence of joysticks. You can freely modify button assignments ingame by going to `Options -> Control Setup -> Customize controls` and selecting the `JOY` column.

## Mod
The launcher lists folders as games and looks for `.load.txt` files inside them. It uses their information to construct arguments passed to lzwolf or ecwolf, and will not display menu options for any games that are missing data. To create a `.load.txt` file, open a text editor and add the following:

- `PATH` - This is always `./data`
- `DATA` - File extension of the data files
- `PK3_#` - Any `.pk3` files to load after the data, can use up to four

Follow this example `Wolfenstein 3D/.load.txt` which launches vanilla Wolfenstein 3D:

```
PATH=./data
DATA=WL6
PK3_1=breathing_fix.pk3
-- end --
```

This example `Operation Wasserstein II/.load.txt` launches the mod Operation Wasserstein II:

```
PATH=./data
DATA=WL6
PK3_1=breathing_fix.pk3
PK3_2=Wasserstein2.pk3
-- end --
```

Since we gave the mod its own subfolder and `.load.txt` file, it appears in the launcher as its own option despite using shared data files.

## Building
See [PM-LZWolf](https://github.com/JeodC/pm-lzwolf) GitHub fork for compile instructions and change information.

## Thanks
id Software -- Original game  
Linuxwolf -- LZWolf  
Richard Douglas -- The free [music](https://richdouglasmusic.bandcamp.com/album/wolfenstein-symphony-music-inspired-by-wolfenstein-3d) used for the launcher  
Slayer366 -- ECWolf build and port assistance  
PortMaster Discord -- Testers
