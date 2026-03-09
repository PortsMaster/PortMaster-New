# Mob spawners
This mod adds a mob spawner for Mineclonia.
Monsters will appear around the mob spawner in semi-regular intervals.

Players can get a mob spawner by `giveme` and is initially empty after
placing.

## Credits
This mod is originally based on the mob spawner from Mobs Redo by TenPlus1
but has been modified quite a lot to fit the needs of Mineclonia.

## Programmer notes
To set the mob spawned by a mob spawner, first place the mob spawner
(e.g. with `minetest.set_node`), then use the function
`mcl_mobspawners.setup_spawner` to set its attributes. See the comment
in `init.lua` for more info.

## License (code and texture)
MIT License
