# Evoland Legendary Edition
Travel through the history of gaming as gameplay and graphics evolve
from 2D to 3D across multiple genres including action-adventure, RPG,
platformer, and more. Contains both Evoland 1 and 2.

## Installation
The Steam, GOG, and Epic Games Store versions are all supported:
https://store.steampowered.com/app/1020470/Evoland_Legendary_Edition/
https://www.gog.com/en/game/evoland_legendary_edition
https://store.epicgames.com/en-US/p/evoland-legendary-edition
The patcher will automatically patch the bytecode and compress
textures on first launch. It takes about 10-30 minutes.

### Steam Instructions
* Open Steam console: `steam://open/console`
* Copy and paste command: `download_depot 1020470 1020471`
* Open the folder where this depot was downloaded and copy `sdlboot.dat`
  and all `.pak` files into the port's `gamedata` folder. On Windows
  this folder will be `C:\Program Files (x86)\Steam\steamapps\content\app_1020470\depot_1020471`

### GOG (recommended)
Place the GOG offline installer files into `evoland/gamedata/`:
```
evoland/
    gamedata/
        setup_evoland_legendary_edition_1.0_(57388).exe
        setup_evoland_legendary_edition_1.0_(57388)-1.bin
```
The patcher will automatically extract the game files, patch the bytecode, and compile for your device on first launch.

### Epic Games Store
From your Epic Games installation folder, copy `sdlboot.dat` and all
`.pak` files into the port's `gamedata` folder:
```
evoland/
    gamedata/
        sdlboot.dat
        evo1.pak
        evo1-extra.pak
        evo2.pak
        evo2-extra.pak
```
On Windows the installation folder is typically
`C:\Program Files\Epic Games\EvolandLegendaryEdition`.

## Building
The source code for building this port can be obtained by
contacting bmdhacks, but most of the tooling that went into it can be
found on his [Github Page](https://github.com/bmdhacks?tab=repositories)
- hashlink
- heaps
- hlbc

## Thanks
Shiro Games -- The game
Haxe Foundation -- HashLink VM and Haxe compiler
