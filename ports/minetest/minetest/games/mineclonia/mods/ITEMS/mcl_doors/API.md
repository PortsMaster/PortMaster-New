# mcl_doors
Mineclonia API for registering doors and trapdoors.

## mcl_doors:register_door(name, def)
Function used to register a new door

* `name`: the name of the door (itemstring, modname:door_name)
* `defs`: A table with the following fields:
    * `_mcl_blast_resistance`: blast resistance
    * `_mcl_hardness`: hardness
    * `description`: door description
    * `groups`: door groups
    * `inventory_image`: door item inventory image
    * `sounds`: table of sounds (e.g. mcl_sounds.node_sound_wood_defaults())
    * `tiles_bottom`: the tiles of the bottom part of the door {front, side}
    * `tiles_top`: the tiles of the bottom part of the door {front, side}

If the following fields are not defined the default values are used:

* `node_box_bottom`: box, default value is {-0.5, -0.5, -0.5, 0.5. 0.5, -0.3125}
* `node_box_top`: box, default value is {-0.5, -0.5, -0.5, 0.5. 0.5, -0.3125}
* `only_placer_can_open`: if true only the player who placed the door can open it
* `only_redstone_can_open`: if true, the door can only be opened by redstone, not by rightclicking it
* `selection_box_bottom`: box, default value is {-0.5, -0.5, -0.5, 0.5. 0.5, -0.3125}
* `selection_box_top`: box, default value is {-0.5, -0.5, -0.5, 0.5. 0.5, -0.3125}
* `sound_close`: sound that will be played when closing the door (default: "doors_door_close")
* `sound_open`: sound that will be played when opening the door (default: "doors_door_open")

## mcl_doors:register_trapdoor(name, def)
Function used to register a new trapdoor

* `name`: the name of the trapdoor (itemstring, modname:trapdoor_name)
* `defs`: A table with the following fields:
    * `_mcl_blast_resistance`: blast resistance
    * `_mcl_hardness`: hardness
    * `description`: trapdoor description
    * `groups`: trapdoor groups
    * `inventory_image`: trapdoor item inventory image
    * `sounds`: table of sounds (e.g. mcl_sounds.node_sound_wood_defaults())
    * `tiles_front`: the tiles of the front part of the trapdoor
    * `tiles_top`: the tiles of the sides of the trapdoor
    * `wield_image`: trapdoor item wield image

If the following fields are not defined the default values are used:

* `only_redstone_can_open`: if true, the door can only be opened by redstone, not by rightclicking it
* `sound_close`: sound that will be played when closing the door (default: "doors_door_close")
* `sound_open`: sound that will be played when opening the door (default: "doors_door_open")
