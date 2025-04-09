# 1.3.0.bricks
This is a sample mod for Block Attack - Rise of the Blocks.  
It changes the bricks to use the graphic from 1.3.0. Not that way are good but it shows how it works.

## Enabling mods
At the moment it is possible to start mod in two ways. Command line argument or mod file.

### Command line
```bash
./blockattack --mod MODNAME
# Example:
./blockattack --mod 1.3.0.bricks
```
Mods loaded from command line are loaded last. They take priority over the mod file.

### Mod file
It is possible using a "mod_list.txt"-file in config directory.
* Windows: `%APPDATA%/blockattack/mod_list.txt`
* Linux: `$HOME/.local/share/blockattack/mod_list.txt`

The file is a csv-file without header and a line for each mod.
```csv
1.3.0.bricks,1
```
The fist column is the modname, the second column is "1" if enabled. A 0 means disabled. It is possible preserve the order while remembering the mod order.

## Mod structure
Mods override files from blockattack.data, so any file in blockattack.data can be modified and made into a mod.
New sprite files can also be created. See "Modinfo file".

## Modinfo file
The game contains a file modinfo/1.3.0.bricks.json which contains metadata about the mod.
Note that the filename MUST be "MODNAME.json". The game will only search for the modinfo file if a given mod has been loaded.

The file contains a "sprites" section. Sprite files mentioned in this value will be loaded in mod order, so the last loaded mod will take priority.

This allows you to override individual sprites from blockattack.data without replicating the entire file.

## Sprites
As mentioned sprites can be overridden. The documentation for Saland Adventures https://salandgame.github.io/development_info/sprites/ also applies to Block Attack - Rise of the Blocks.

## Example
The example example mod features the following:
textures/ball_*.png just overwrites files in blockattack.data

The example mod add one new texture "textures/bricks130.png" or just "bricks130".

The sprite file "sprites/bricks1.3.0.sprite" uses the "bricks130" texture.

The mod file "modinfo/1.3.0.bricks.json" refers the sprite file so that it takes priority.

## Tips
Use lowercase letters for all filenames. This prevents surprises when developing on case insensitive file systems.

Create new sprite files rather than overwriting an existing one. Failure to do so might result in mod conflicts.
