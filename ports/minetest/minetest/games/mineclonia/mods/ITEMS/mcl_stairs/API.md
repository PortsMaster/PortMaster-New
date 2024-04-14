# API for `mcl_stairs`
Register your own stairs and slabs!

This mod has both a new simplified API and an old one kept for backwards
compatibility.  The primary difference is that the new API takes a definition
table rather than multiple arguments and that the description of registered
stair/slabs are generated from a base description which is either specified or
derived from the node they are based on.

## Example
Register stair and slab based on the node `example:platinumblock`:

```lua
mcl_stairs.register_stair_and_slab("platinum", {
    baseitem = "example:platinumblock",
    base_description = S("Platinum"),
})
```

This will register the nodes `mcl_stairs:stair_platinum` and
`mcl_stairs:slab_platinum`.

## `mcl_stairs.register_stair(subname, stair definition)`
Registers stair from the stair definition.  The subname has to be unique and
not used by any other stair registration.  Properties like groups, hardness and
blast resistance for the registered nodes are derived from the node they are
based on.

This function will register the node `mcl_stairs:stair_<subname>`.  The nodes
`mcl_stairs:stair_<subname>_inner` and `mcl_stairs:stair_<subname>_outer` which
are only used for placed nodes will also be registered.

## `mcl_stairs.register_slab(subname, stair definition)`
Same as `register_stair` but registers slab instead.

This function will register the node `mcl_stairs:slab_<subname>`.  The nodes
`mcl_stairs:slab_<subname>_top` and `mcl_stairs:slab_<subname>_double` which
are only used for placed nodes will also be registered.

## `mcl_stairs.register_stair_and_slab(subname, stair definition)`
Shorthand for calling `register_stair` and `register_slab` at the same time.

For the second argument `description_stair` get passed as `description` to
`register_stair` and `description_slab` get passed as `description` to
`register_slab`.

## Stair definition
Used by `mcl_stairs.register_stair`, `mcl_stairs.register_slab` and
`mcl_stairs.register_stair_and_slab`.

```lua
{
    baseitem = "",
    -- Node the stair/slab is based on.

    description = "",
    -- Description for the stair/slab.

    recipeitem = "",
    -- Item or group used for the crafting recipe.  Defaults to `baseitem` if
    -- unspecified.  Set to empty string to make uncraftable.

    groups = {},
    -- Groups added to the registered node.

    tiles = {},
    -- Custom tiles for the node.

    overrides = {},
    -- Fields added to the registered node.
}
```

## Special node definition fields
### Slabs
* `_mcl_stairs_double_slab` -- This optionally references the node name of the double slab variant for placement
* `_mcl_other_slab_half` -- This references the node name of the other slab half for upper and lower slabs - automatically set in normal operation.

## Backwards compatible API
This section describes old `mcl_stairs` API which has been deprecated.

### `mcl_stairs.register_stair_and_slab_simple(subname, sourcenode, desc_stair, desc_slab, double_description, corner_stair_texture_override)`
Register a simple stair and a slab. The stair and slab will inherit all attributes from `sourcenode`. The `sourcenode` is also used as the item for crafting recipes.

This function is meant for simple nodes; if you need more flexibility, use one of the other functions instead.

See `register_stair` and `register_slab` for the itemstrings of the registered nodes.

#### Parameters
* `subname`: Name fragment for node itemstrings (see `register_stair` and `register_slab`)
* `sourcenode`: The node on which this stair is based on
* `desc_stair`: Description of stair node
* `desc_slab`: Description of slab node
* `double_description`: Description of double slab node
* `corner_stair_texture_override`: Optional, see `register_stair`

### `mcl_stairs.register_stair_and_slab(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds, hardness, double_description, corner_stair_texture_override)`
Register a simple stair and a slab, plus crafting recipes. In this function, you need to specify most things explicitly.

#### Parameters
* `desc_stair`: Description of stair node
* `desc_slab`: Description of slab node
* Other parameters: Same as for `register_stair` and `register_slab`

### `mcl_stairs.register_stair(subname, recipeitem, groups, images, description, sounds, hardness, corner_stair_texture_override)`
Registers a stair. This also includes the inner and outer corner stairs, they are added automatically. Also adds crafting recipes.

The itemstrings for the registered nodes will be of the form:

* `mcl_stairs:stair_<subname>`: Normal stair
* `mcl_stairs:stair_<subname>_inner`: Inner stair
* `mcl_stairs:stair_<subname>_outer`: Outer stair

#### Parameters
* `subname`: Name fragment for node itemstrings (see above)
* `recipeitem`: Item for crafting recipe. Use `group:` prefix to use a group instead
* `groups`: Groups used for stair
* `images`: Textures
* `description`: Stair description/tooltip
* `sounds`: Sounds table
* `hardness`: MCL2 block hardness value
* `corner_stair_texture_override`: Optional. Custom textures for corner stairs, see below

`groups`, `images`, `sounds` or `hardness` can be `nil`, in which case the value is inhereted from the `recipeitem`.

##### `corner_stair_texture_override`
This optional parameter specifies the textures to be used for corner stairs. 

It can be one of the following data types:

* string: one of:
    * "default": Use same textures as original node
    * "woodlike": Take first frame of the original tiles, then take a triangle piece
                  of the texture, rotate it by 90° and overlay it over the original texture
* table: Specify textures explicitly. Table of tiles to override textures for
         inner and outer stairs. Table format:
             { tiles_def_for_outer_stair, tiles_def_for_inner_stair }
* nil: Equivalent to "default"

### `mcl_stairs.register_slab(subname, recipeitem, groups, images, description, sounds, hardness, double_description)`
Registers a slab and a corresponding double slab. Also adds crafting recipe.

The itemstrings for the registered nodes will be of the form:

* `mcl_stairs:slab_<subname>`: Slab
* `mcl_stairs:slab_<subname>_top`: Upper slab, used internally
* `mcl_stairs:slab_<subname>_double`: Double slab

#### Parameters
* `double_description`: Node description/tooltip for double slab
* Other parameters: Same as for `register_stair`
