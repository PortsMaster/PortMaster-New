# Migrating from MineClone 2 to Mineclonia
This document contains instructions for migrating a world from MineClone 2 to
Mineclonia and things to be aware of when doing it. Migrating from MineClone 2
to Mineclonia is fully supported but not the other way around. If you want to
try Mineclonia and have the option of going back, then we recommend taking a
backup of your world first.

## How to migrate
Go to the _About_ tab in the main menu and click on the _Open User Data
Directory_ button. This opens a file browser. In the file browser, enter the
`worlds` directory and then the directory which has the same name as the world
you want to migrate. Open the `world.mt` file in a text editor. The file should
look like this:

```
enable_damage = true
creative_mode = false
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = mineclone2
world_name = world1
server_announce = false
```

Update `gameid` to `mineclonia` so the file looks like this:

```
enable_damage = true
creative_mode = false
mod_storage_backend = sqlite3
auth_backend = sqlite3
player_backend = sqlite3
backend = sqlite3
gameid = mineclonia
world_name = world1
server_announce = false
```

Then save the file and restart Minetest. Now the world should be playable when
you select Mineclonia as the game.

## Overworld depth increase
In Mineclonia 0.83.0 the overworld depth was increased from 64 to 128 nodes to
match Minecraft 1.18. Mineclonia will automatically update worlds from
MineClone 2 and older Mineclonia versions by replacing the bedrock layer and
void underneath with newly generated mapchunks. Note that this will trigger
regeneration of ores, caves, and structures up to y level -32, but that will
only replace ground content nodes and not affect player-made structures. It can
cause some oddities though, like duplicate end portals and other structures.

### MineClone 2 features not in Mineclonia
Mineclonia does not have the following items in MineClone 2:

- Hamburgers

Such items will become unknown items when a MineClone 2 world is migrated to
Mineclonia.
