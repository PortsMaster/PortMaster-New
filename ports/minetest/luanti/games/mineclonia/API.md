# API
This file contains general documentation about APIs in Mineclonia. For
documentation about APIs of specific mods, check the `API.md` files in their
mod directories.

## Note about undocumented APIs
In Mineclonia there are many API functions which are used internally between
mods. These functions are usually exposed globally. They are however not meant
to be used externally unless they are part of a documented modding API
(documented in `API.md` files). There are no guarantees that Mineclonia will
stay compatible with such undocumented API functions in the future.

If one wants to use such an API for an external mod, then one should first make
an issue on the Mineclonia repo about recognizing it as an external API and
documenting it as such. Everything that is undocumented should be avoided when
creating third party mods.

## Groups
Mineclonia makes very extensive use of groups. Making sure your items and
objects have the correct group memberships is very important. Groups are
explained in `GROUPS.md`.

## Mod naming convention
Mods mods in Mineclonia follow a simple naming convention: Mods with the prefix
“`mcl_`” are specific to Mineclonia, although they may be based on an existing
standalone. Mods which lack this prefix are *usually* verbatim copies of a
standalone mod. Some modifications may still have been applied, but the APIs are
held compatible.

## Adding items
### Item Definitions
#### Special fields
Items can have these fields:

* `_mcl_generate_description(itemstack)`: Required for any items which
  manipulate their description in any way. This function takes an itemstack of
  its own type and must set the proper advanced description for this itemstack.
  If you don't do this, anvils will fail at properly restoring the description
  when their custom name gets cleared at an anvil. See `mcl_banners` for an
  example.
* `_mcl_armor_trim_color`: _colorstring_ used to determine the color that will be
  applied during armor trimming when used in the smithing table.
* `_mcl_armor_trim_desc`: _string_ used to describe the material used when trimming
  armor pieces. This string must be translated in the field definition so that it
  can be displayed translated in the final item. Examples of this definition can be
  found in `mcl_amethyst/init.lua` or `_mcl_core/craftitems.lua`.
* `_mcl_burntime`: _number_ that determines, in ticks, the amount of time an item
  burns when used in furnaces, blast furnaces and smokers. Examples can be found
  in `mcl_core/craftitems.lua`.
* `_mcl_cooking_output`: _string_ that determines the burning result of an item
  when used in furnaces, blast furnaces and smokers. Examples can be found in
  `mcl_mobitems`.
* `_mcl_fuel_replacements`: _table_ containing replacements for items used as fuel.
  The only example in MCLA is the lava bucket, which when used as fuel leaves an empty
  bucket in its place. See `mcl_buckets/register.lua`.
* `_mcl_cooking_replacements`: _table_ containing replacements for items used in burning.
  The only example in MCLA is the wet sponge. When an empty bucket is left in the
  furnace's fuel slot while drying a wet sponge, it will be replaced by a bucket of water.
  See `mcl_sponges`.
* `_mcl_crafting_output`: _table_ used to eliminate the need to record recipes in simple shapes.
  The supported shapes are:
  * `single`: Used when the item is used alone in any slot on the crafting grid (shapeless);
  * `square2`: Used for recipes with the square shape of two by two grid slots;
  * `square3`: Used for recipes with the square shape of three by three grid slots;
  * `line_wide2`: Used for line-shaped recipes with width of two grid slots;
  * `line_wide3`: Used for line-shaped recipes with width of three grid slots;
  * `line_tall2`: Used for line-shaped recipes with heigth of two grid slots;
  * `line_tall3`: Used for line-shaped recipes with heigth of three grid slots;

  Each of these shapes is a key in the `_mcl_crafting_output` table. The values of these keys
  are tables which must contain the `output` key, a string with the crafting result depending on the
  format used. Each shape key can also contain a special key called `replacements`, a table which
  determines which items will be replaced after crafting. The most complete example of
  `_mcl_crafting_output` is the honey bottle, which has two simple shape recipes, both with
  replacements. See `mcl_honey`. Other usage examples can be found in `mcl_copper`, `mcl_core`,
  `mcl_farming`, and `mcl_wool`. Some simple recipes are no longer covered by this field due to the
  implementation of their APIs, as in the case of buttons, slabs and iron trapdoors.

#### Item callbacks
* `_on_set_item_entity` callback that is called when an item is set converted to an item entity: function(itemstack, luaentity).
	Shall return the changed itemstack and optionally as second return value a table of object properties to be applied to the object when the object/entity is activated.

### Tool definitions
#### Special fields
Tools can have these fields:
* `_mcl_diggroups`: Specifies the digging groups that a tool can dig and how
  efficiently. See `_mcl_autogroup` for more information.

### Node definitions
#### Special fields
All nodes can have these fields:
* `_mcl_hardness`: Hardness of the block, ranges from 0 to infinity (represented
  by -1). Determines digging times. Default: 0
* `_mcl_blast_resistance`: How well this block blocks and resists explosions.
  Default: The value of `_mcl_hardness`
* `_mcl_falling_node_alternative`: If set to an itemstring, the node will turn
  into this node before it starts to fall.
* `_mcl_baseitem` this used to determine the item corresponding to the placed node. Can either be an itemstring or a function(pos) returning an itemstack.

#### Node callbacks
These can be applied to all node registrations.
* `_mcl_after_falling` called after a falling node finished falling and turned into a node: function(pos)
* `_on_object_in` called every step when a player, mob or item entity is inside the node: function(entity_pos, node, obj)
* `_on_object_over` called every step when a player, mob or item entity is on top of the node: function(object_pos, node, object)
* `_on_arrow_hit` called when node is hit by an arrow: function(pos, arrow_luaentity)
* `_on_dye_place` called when node is rightclicked with a dye item: function(pos, color_name)
* `_on_bone_meal` called when node is righclicked with a bone meal item: function(itemstack, placer, pointed_thing, pos, node)
* `_on_hopper_in` called when an item is about to be pushed to the node from a hopper: function(hopper_pos, node_pos)
* `_on_hopper_out` called when an item is about to be sucked into a hopper under the node: function(node_pos, hopper_pos)
* `_after_hopper_in` called when an item is pushed into the node from a hopper: function(node_pos)
* `_after_hopper_out` called when an item is sucked from the node by a hopper: function(node_pos)
* `_on_lightning_strike` called when a node is hit by lightning: function(node_pos, lightning_pos1, lightning_pos2)

#### Node tool callbacks
Nodes can have "tool callbacks" modifying the on_place function of certain tools.
The first return value should be the itemstack and the second an option bool
indicating if no wear should be added to the tool e.g. because the mod does it
itsself.
* `_on_axe_place`: function(itemstack,placer,pointed_thing)
* `_on_shovel_place`: function(itemstack,placer,pointed_thing)
* `_on_sword_place`: function(itemstack,placer,pointed_thing)
* `_on_pickaxe_place`: function(itemstack,placer,pointed_thing)
* `_on_shears_place`: function(itemstack,placer,pointed_thing)
* `_on_hoe_place`: function(itemstack,placer,pointed_thing)

## APIs
A lot of things are possible by using one of the APIs in the mods. Note that not
all APIs are documented yet, but it is planned. The following APIs should be
more or less stable but keep in mind that Mineclonia is still unfinished. All
directory names are relative to `mods/`

### Items
* Doors: `ITEMS/mcl_doors`
* Fences and fence gates: `ITEMS/mcl_fences`
* Stairs and slabs: `ITEM/mcl_stairs`
* Walls: `ITEMS/mcl_walls`
* Beds: `ITEMS/mcl_beds`
* Buckets: `ITEMS/mcl_buckets`
* Dispenser support: `ITEMS/REDSTONE/mcl_dispensers`
* Campfires: `ITEMS/mcl_campfires`
* Trees and wood related nodes: `ITEMS/mcl_trees`

### Map Generation

Mineclonia can alternate between using a bespoke Lua level generator
which produces terrain and structures identical to Minecraft's, and
generating terrain with existing Luanti-provided map generators and
their attendant biome and decoration generation facilities.

Decorations are implemented separately for each of the two classes of
map generators; the terrain feature system for the former is
documented in `MAPGEN/mcl_levelgen/API.txt`.

Biomes should be accessed by means of the mod
`MAPGEN/mcl_biome_dispatch`, which serves as an abstraction layer
above their respective biome systems.

Structures are generated by the mod `mcl_structures` (which should be
considered deprecated) under the built-in map generators by default,
but are generated by a deterministic and asynchronous generator also
documented in `MAPGEN/mcl_levelgen/API.txt` when the custom Lua-based
map generator is enabled, and also upon user request.  We anticipate
that Luanti 5.14 will provide the facilities that are necessary for
this structure generator to be enabled by default, at which time
`mcl_structures` will be relegated to supporting older releases of
Luanti till support for them is discontinued altogether.

### Mobs
* Mobs: `ENTITIES/mcl_mobs`

Mineclonia uses its own mobs framework, called “mcl_mobs”.
This was conceived as a fork of [mobs redo](https://codeberg.org/tenplus1/mobs_redo) by TenPlus1.

You can add your own mobs, spawn eggs and spawning rules with this
mod.  The API documentation supplied with this mod is currently out of
date and of no value whatever, but this is subject to change.

This version of mcl_mobs has been extensively re-engineered and is
neither compatible with the mcl_mobs framework in VoxeLibre nor with
the original mobs_redo API.

### Help
* Item help texts: `HELP/doc/doc_items`
* Low-level help entry and category framework: `HELP/doc/doc`
* Support for lookup tool (required for all entities): `HELP/doc/doc_identifier`

### HUD
* Statbars: `HUD/hudbars`

### Utility APIs
* Play sounds:  `CORE/mcl_sounds`
* Change player physics: `PLAYER/playerphysics`
* Select random treasures: `CORE/mcl_loot`
* Get flowing direction of liquids: `CORE/flowlib`
* Get node names close to player (to reduce constant querying): `PLAYER/mcl_playerinfo`
* Colors and dyes API: `ITEMS/mcl_dyes`
* Explosion API
* Music discs API
* Flowers and flower pots
* Add job sites: `ENTITIES/mobs_mc`
* Add villager professions: `MAGPGEN/mcl_villages`
* `placement_prevented(table)` callback to see if a node will accept an attachment on the face being attached to. The table takes the following keys:

	```lua
	{
		itemstack = itemstack,
		placer = placer,
		pointed_thing = pointed_thing,
	}
	```

### Unstable APIs
The following APIs may be subject to change in future. You could already use
these APIs but there will probably be breaking changes in the future, or the API
is not as fleshed out as it should be. Use at your own risk!

* `mcl_potions`
* Panes (like glass panes and iron bars): `ITEMS/xpanes`
* `_on_ignite` callback: `ITEMS/mcl_fire`
* Farming: `ITEMS/mcl_farming`
* Any other mod not explicitly mentioned above
