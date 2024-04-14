# API for MineClone 2 walls

This API allows you to add more walls (like the cobblestone wall) to MineClone 2.

## `mcl_walls.register_wall(nodename, description, craft_material, tiles, invtex, groups, sounds)`

Adds a new wall type. This is optimized for stone-based walls, but other materials are theoretically possible, too.

The current implementation registers a couple of nodes for the different nodeboxes.
All walls connect to solid nodes and all other wall nodes.

If `craft_material` is not `nil` it also adds a crafting recipe of the following form:

    CCC
    CCC
    
    Yields 6 walls
    C = craft_material (can be group)

### Parameters
* `nodename`: Full itemstring of the new wall node (base node only). ***Must not have an underscore!***
* `description`: Item description of item (tooltip), visible to user
* `source`: Node on which the wall is based off, use for texture and crafting recipe (optional)
* `tiles`: Wall textures table, same syntax as for `minetest.register_node` (optional if `source` is set)
* `inventory_image`: Inventory image (optional if `source` is set)
* `groups`: Base group memberships (optional, default is `{pickaxey=1}`)
* `sounds`: Sound table (optional, by default default uses stone sounds)

The following groups will automatically be added to the nodes (where applicable), you do not need to add them
to the `groups` table:

* `deco_block=1`
* `not_in_creative_inventory=1` (except for the base node which the player can take)
* `wall=1`

### Example

    mcl_walls.register_wall("mymod:granitewall", "Granite Wall", {"mymod_granite.png"}, "mymod_granite_wall_inv.png")

## `mcl_walls.update_wall(pos)`

When loading schemas with walls you will need to trigger this to make the walls rotate and join properly.

### Parameters

* `pos`: Position of the wall to update.
