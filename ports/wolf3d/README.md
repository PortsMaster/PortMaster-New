# Wolfenstein 3D -- A PortMaster implementation of LZWolf and ECWolf to play Wolfenstein 3D and friends

## Installation
This port comes with the shareware and demo for Wolfenstein 3D and Spear of Destiny. LZWolf and ECWolf can run the following games:

- [Wolfenstein 3D / Spear of Destiny](https://www.gog.com/en/game/wolfenstein_3d)
- [Spear of Destiny Mission Packs]()
- [Super Noah's Ark 3D](https://wisdomtree.itch.io/s3dna)

To use them, place your game data (`.WL6`, `.SOD`, `.SD2`, `.SD3`, `.N3D`, etc) in `ports/wolf3d/data`.

## Play
To use addon mods, place `.pk3` files in `ports/wolf3d/mods` and list the `.pk3` files to load in `wolffiles/*.wolf` for the relevant game. The launcher will search `wolffiles` and list its subfolders as well as any `.wolf` files. Selecting a folder within the launcher will move into that subfolder, and pressing B will move backwards in the hierarchy.

Use the Left Shoulder and Right Shoulder buttons in the launcher to select which engine to use.

## Config
The launchscript is set up to use one of two `.cfg` files based on the presence of joysticks. You can freely modify button assignments ingame by going to `Options -> Control Setup -> Customize controls` and selecting the `JOY` column.

## Mod
The launcher lists `*.wolf` files in `wolf3d/wolffiles` and uses their information to construct arguments passed to the engines. It performs file validation and will not display menu options for any games that are missing data. To create a `*.wolf` file, open a text editor and add the following:

- `ENGINE` - The engine to use (crispydoom or gzdoom). This line can be used to enforce a specific engine regardless of the engine selected in the launcher.
- `DATA` - File extension to use (`WL6`, `SOD`, `SD2`, `SD3`, `N3D`, etc).
- `MOD` - Any `.pk3` files to load after the data. You can load any number of files this way.

Follow this example `Wolfenstein 3D.wolf` which launches vanilla Wolfenstein 3D:

```
DATA=WL6
MOD=mods/breathing_fix.pk3
-- end --
```

This example `Operation Wasserstein II.wolf` launches the mod Operation Wasserstein II:

```
DATA=WL6
MOD=mods/breathing_fix.pk3
MOD=mods/Wasserstein2.pk3
-- end --
```

## Building
See [PM-LZWolf](https://github.com/JeodC/pm-lzwolf) GitHub fork for compile instructions and change information.

## Thanks
id Software -- Original game  
Linuxwolf -- LZWolf  
Richard Douglas -- The free [music](https://richdouglasmusic.bandcamp.com/album/wolfenstein-symphony-music-inspired-by-wolfenstein-3d) used for the launcher  
Slayer366 -- ECWolf build and port assistance  
PortMaster Discord -- Testers
