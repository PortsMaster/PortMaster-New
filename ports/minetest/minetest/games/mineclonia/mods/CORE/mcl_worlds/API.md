# mcl_worlds
This mod provides utility functions about positions and dimensions.

## mcl_worlds.is_in_void(pos)
This function returns:

* true, true: if pos is in deep void (deadly)
* true, false: if the pos is in void (non deadly)
* false, false: owerwise

Params:

* pos: position

## mcl_worlds.y_to_layer(y)
This function is used to calculate the minetest y layer and dimension of the given <y> minecraft layer.
Mainly used for ore generation.
Takes an Y coordinate as input and returns:

* The corresponding Minecraft layer (can be nil if void)
* The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if <y> is in the void
If the Y coordinate is not located in any dimension, it will return: nil, "void"

Params:

* y: int

## mcl_worlds.pos_to_dimension(pos)
This function return the Minecraft dimension of <pos> ("overworld", "nether" or "end") or "void" if <y> is in the void.

* pos: position

## mcl_worlds.layer_to_y(layer, mc_dimension)
Takes a Minecraft layer and a “dimension” name and returns the corresponding Y coordinate for MineClone 2.
mc_dimension can be "overworld", "nether", "end" (default: "overworld").

* layer: int
* mc_dimension: string

## mcl_worlds.has_weather(pos)
Returns true if <pos> can have weather, false owerwise.
Weather can be only in the overworld.

* pos: position

## mcl_worlds.has_dust(pos)
Returns true if <pos> can have nether dust, false owerwise.
Nether dust can be only in the nether.

* pos: position

## mcl_worlds.compass_works(pos)
Returns true if compasses are working at <pos>, false owerwise.
In mc, you cant use compass in the nether and the end.

* pos: position

## mcl_worlds.compass_works(pos)
Returns true if clock are working at <pos>, false owerwise.
In mc, you cant use clock in the nether and the end.

* pos: position

## mcl_worlds.register_on_dimension_change(function(player, dimension, last_dimension))
Register a callback function func(player, dimension).
It will be called whenever a player changes between dimensions.
The void counts as dimension.

* player: player, the player who changed of dimension
* dimension: string, The new dimension of the player ("overworld", "nether", "end", "void").
* last_dimension: string, The dimension where the player was ("overworld", "nether", "end", "void").


## mcl_worlds.registered_on_dimension_change
Table containing all function registered with mcl_worlds.register_on_dimension_change()

## mcl_worlds.dimension_change(player, dimension)
Notify this mod of a dimension change of <player> to <dimension>

* player: player, player who changed the dimension
* dimension: string, new dimension ("overworld", "nether", "end", "void")
