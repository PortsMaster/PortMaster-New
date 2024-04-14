# Mineclonia

[![ContentDB](https://content.minetest.net/packages/ryvnf/mineclonia/shields/downloads/)](https://content.minetest.net/packages/ryvnf/mineclonia/)

An unofficial Minecraft-like game for Minetest. Fork of MineClone 2 with focus
on stability, multiplayer performance and features. For information about
migrating from MineClone 2 to Mineclonia, see [MIGRATING.md](../../../src/branch/main/MIGRATING.md).

Version: 0.98.0

### Differences from MineClone 2
* Overworld depth increased from 64 to 128 nodes
* Improved nether portals
* Improved leaf decay
* Improved villages
* Suspicious nodes, pottery shreds and decorated pots
* Deep Dark biome and Ancient hermitage (structure corresponding to Minecraft's ancient city)
* Functional Loom to apply banner patterns
* Lush Caves biome
* Cherry Grove biome
* No in-game music, twice as small compared to MineClone 2
* No hamburgers
* More features but almost 10k lines of code less

### Gameplay
You start in a randomly-generated world made entirely of cubes. You can explore
the world and dig and build almost every block in the world to create new
structures. You can choose to play in a “survival mode” in which you have to
fight monsters and hunger for survival and slowly progress through the various
other aspects of the game, such as mining, farming, building machines, and so on
Or you can play in “creative mode” in which you can build almost anything
instantly.

#### Gameplay summary
* Sandbox-style gameplay, no goals
* Survive: Fight against hostile monsters and hunger
* Mine for ores and other treasures
* Magic: Gain experience and enchant your tools
* Use the collected blocks to create great buildings, your imagination is the
  limit
* Collect flowers (and other dye sources) and colorize your world
* Find some seeds and start farming
* Find or craft one of hundreds of items
* Build a railway system and have fun with minecarts
* Build complex machines with redstone circuits
* In creative mode you can build almost anything for free and without limits

## How to play (quick start)
### Getting started
* **Punch a tree** trunk until it breaks and collect wood
* Place the **wood into the 2×2 grid** (your “crafting grid” in your inventory
  menu) and craft 4 wood planks
* Place the 4 wood planks in a 2×2 shape in the crafting grid to **make a
  crafting table**
* **Rightclick the crafting table** for a 3×3 crafting grid to craft more
  complex things
* Use the **crafting guide** (book icon) to learn all the possible crafting
  recipes
* **Craft a wooden pickaxe** so you can dig stone
* Different tools break different kinds of blocks. Try them out!
* Continue playing as you wish. Have fun!

### Farming
* Find seeds
* Craft a hoe
* Rightclick dirt or a similar block with a hoe to create farmland
* Place seeds on farmland and watch them grow
* Collect plants when fully grown
* If near water, farmland becomes wet and speeds up growth

### Furnace
* Craft a furnace
* The furnace allows you to obtain more items
* Upper slot must contain a smeltable item (example: iron ore)
* Lower slot must contain a fuel item (example: coal)
* See tooltips in crafting guide to learn about fuels and smeltable items

### Additional help
More help about the gameplay, blocks items and much more can be found from
inside the game. You can access the help from your inventory menu.

### Special items
The following items are interesting for Creative Mode and for adventure
map builders. They can not be obtained in-game or in the creative inventory.

* Barrier: `mcl_core:barrier`

Use the `/giveme` chat command to obtain them. See the in-game help for
an explanation.

## Installation
This game requires [Minetest](http://minetest.net) to run (version 5.5.1 or
later). So you need to install Minetest first. Only stable versions of Minetest
are officially supported. There is no support for running Mineclonia in
development versions of Minetest.

To install Mineclonia (if you haven't already), move this directory into the
“games” directory of your Minetest data directory. Consult the help of
Minetest to learn more.

## Useful links
The Mineclonia repository is hosted at [Codeberg](https://codeberg.org).
To contribute or report issues, head there.

* Codeberg: <https://codeberg.org/mineclonia/mineclonia>
* ContentDB: <https://content.minetest.net/packages/ryvnf/mineclonia/>

## Project description
The main goal of **Mineclonia** is to be a stable and performant clone of
Minecraft released as free software.

* Minecraft is aimed to be cloned as well as Minetest currently permits without
  resorting to hacks which are too heavyweight or complicated to maintain
* Cloning the gameplay has highest priority
* Cloning the interface has low priority. It will only be roughly imitated
* Mineclonia will use different graphics and sounds, but with a similar style

## Completion status
This game is currently in **beta** stage.
It is playable, but not yet feature-complete.
Backwards-compatibility is not guaranteed, updating your world might cause bugs
and things to behave differently.

The following main features are available:

* Tools, weapons
* Armor
* Crafting system: 2×2 grid, crafting table (3×3 grid), furnace, including a
  crafting guide
* Chests, large chests, ender chests, shulker boxes
* Furnaces, hoppers
* Hunger
* Most monsters and animals
* All ores from Minecraft
* Most blocks in the overworld
* Water and lava
* Weather
* 28 biomes + 5 Nether Biomes
* The Nether, a fiery underworld in another dimension
* Redstone circuits (partially)
* Minecarts (partial)
* Status effects (partial)
* Experience
* Enchanting
* Brewing, potions, tipped arrow (partial)
* Boats
* Fire
* Buidling blocks: Stairs, slabs, doors, trapdoors, fences, fence gates, walls
* Clock
* Compass
* Sponge
* Slime block
* Small plants and saplings
* Dyes
* Banners
* Deco blocks: Glass, stained glass, glass panes, iron bars, hardened clay (and
  colors), heads and more
* Item frames
* Jukeboxes
* Beds
* Inventory menu
* Creative inventory
* Farming
* Writable books
* Commands
* Villages
* The End
* And more!

The following features are incomplete and might change in the future:

* Some monsters and animals
* Redstone-related things
* Special minecarts
* A couple of non-trivial blocks and items

Bonus features (not found in Minecraft):

* Built-in crafting guide which shows you crafting and smelting recipes
* In-game help system containing extensive help about gameplay basics, blocks,
  items and more
* Fully moddable (thanks to Minetest's powerful Lua API)
* Bookshelves can be used to store books
* Nether portals can be created with custom shapes
* New blocks and items:
    * Lookup tool, shows you the help for whatever it touches
    * More slabs and stairs
    * Nether Brick Fence Gate
    * Red Nether Brick Fence
    * Red Nether Brick Fence Gate

Technical differences from Minecraft:

* Height limit of ca. 31000 blocks (much higher than in Minecraft)
* Horizontal world size is ca. 62000×62000 blocks (much smaller than in
  Minecraft, but it is still very large)
* Still incomplete and buggy
* Blocks, items, enemies and other features are missing
* Structure replacements - these small variants of Minecraft structures serve as
  replacements until we can get large structures working:
    * Woodland Cabin (Mansions)
    * Nether Outpost (Fortress)
    * Ocean Temple (Monument)
    * Nether Bulwark (Bastion)
    * End Shipwreck & End Boat (End city)
* A few items have slightly different names to make them easier to distinguish
* Different music for jukebox
* Different textures (Pixel Perfection)
* Different sounds (various sources)
* Different engine (Minetest)
* Different easter eggs

… and finally, Mineclonia is free software (“free” as in “freedom”)!

## Other readme files
* [LICENSE.txt](../../../src/branch/main/LICENSE.txt): The GPLv3 license text
* [CONTRIBUTING.md](../../../src/branch/main/CONTRIBUTING.md): Information for those who want to contribute
* [API.md](../../../src/branch/main/API.md): For Minetest modders who want to mod this game
* [LEGAL.md](../../../src/branch/main/LEGAL.md): Legal information
* [CREDITS.md](../../../src/branch/main/CREDITS.md): List of everyone who contributed
