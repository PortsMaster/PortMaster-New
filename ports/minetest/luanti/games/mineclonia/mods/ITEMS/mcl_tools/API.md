# mcl_tools

## Description
This mod is responsible for adding tools to Mineclonia. An API that registers a complete set based on a material or adds a new tool to existing material sets.

## API functions
### `mcl_tools.register_set(setname, materialdefs, tools, overrides)`:
Registers a complete set of tools based on a material.

- `setname`: _string_ with the name of the set (recommended to use the name of the material, for example **iron**).
- `materialdefs`: _table_ that must contain the following fields:

    - craftable: _boolean_ that determines whether tools can be crafted at the crafting table (false for netherite tools).
    - material: _string_ with the name or group of items used as crafting/repair material for tools.
    - uses: _integer_ number of tool uses.
    - level: _integer_ that indicates which levels of the group the tool can harvest.
    - speed: _number_ which acts as a multiplier for the group's digging speed. If omitted, it will receive the value 1, defined by _mcl_autogroup.
    - max_drop_level: _integer_ that contains the tool's tier level. This number determines whether certain blocks will drop items.
    - groups: _table_ containing groups for all tools on the set. Tools typically use the `dig_speed_class` and `enchantability` groups. Other groups can be determined from this table.

- `tools`: _table_ that can contain the following fields (see the Examples section in the tools for register_set subsection):

    - ["pick"]: _table_ containing **pickaxe** definitions;
    - ["shovel"]: _table_ containing **shovel** definitions;
    - ["sword"]: _table_ containing **sword** definitions;
    - ["axe"]: _table_ containing **axe** definitions;
    - ["hoe"]: _table_ containing **hoe** definitions;

- `overrides`(**optional**): _table_ containing optional parameters for all tools in the set (e.g. _mcl_cooking_output, _doc_items_hidden).

### `mcl_tools.add_to_sets(toolname, commondefs, tools, overrides)`:
Adds a new tool to existing material sets.

- `toolname`: _string_ with the name of the tool (for example **shovel**).
- `commondefs`: _table_ that can contain the following fields:

    - `longdesc`: _string_ containing a long description for the tool type (used on _doc_items_longdesc).
    - `usagehelp`: _string_ containing an explanation of how to use the tool (used on _doc_items_usagehelp).
    - `groups`: _table_ containing groups related to the tool type (e.g. hoe, sword, pickaxe) and a group to determine whether it is a tool or a weapon(tool or weapon).
    - `diggroups`: _table_ containing the diggroups for this tool type (e.g hoey, swordy, swordy_cobweb).
    - `craft_shapes`: _table_ containing craft shapes for the tool (see examples in the Examples section).

- `tools`: _table_ that contains values ​​similar to that of `tools` from `register_set` but indexed by material names (see Example section in the tools for add_to_sets subsection).
- `overrides` (**optional**): _table_ that can contain the same fiels as `overrides` from `register_set`.

## Examples

### `groups` on `register_set`:

```lua
-- groups of Netherite Pickaxe. Note the usage of fire_immune group.
groups = { dig_class_speed = 6, enchantability = 10, fire_immune = 1 }
```

### `groups` on `add_to_sets`

```lua
-- groups of a pickaxe.
groups = { pickaxe = 1, tool = 1 }
```

### `tools` on `register_set`:

```lua
-- If any of these fields are omitted, problems may occur using the tool.
-- Note Note that in register_set the tools field contains definitions for tools of a common material.
-- Definitions for Wooden Pickaxe.
["pick"] = {
    description = S("Wooden Pickaxe"),
    inventory_image = "default_tool_woodpick.png",
    tool_capabilities = {
        full_punch_interval = 0.83333333,
        damage_groups = { fleshy = 2 }
    }
},
-- Definitions for Wooden Shovel.
["shovel"] = {
    description = S("Wooden Shovel"),
    inventory_image = "default_tool_woodshovel.png",
    tool_capabilities = {
        full_punch_interval = 1,
        damage_groups = { fleshy = 2 }
    }
}
```

### `tools` on `add_to_sets`:

```lua
-- Hypothetical use case for hammer addition.
-- Definitions for Wooden Hammer.
["wood"] = {
    description = S("Wooden Hammer"),
    inventory_image = "default_tool_woodhammer.png",
    tool_capabilities = {
        full_punch_interval = 0.83333333,
        damage_groups = { fleshy = 4 }
    }
},
-- Definitions for Iron Hammer.
["iron"] = {
    description = S("Iron Hammer"),
    inventory_image = "default_tool_ironhammer.png",
    tool_capabilities = {
        full_punch_interval = 1,
        damage_groups = { fleshy = 6 }
    }
}
```

### `craft_shapes`:

```lua
-- Craft shapes for hoes
-- "material" will be replaced by material from materialdefs.
-- Note that the definition already contains "mcl_core:stick" as another crafting material.
-- The use of "mcl_core:stick" is not mandatory. Other items may be used.
-- A tool can have more than one craft_shape if its crafting recipe can be mirrored on the crafting grid.
craft_shapes = {
	{
		{ "material", "material" },
		{ "mcl_core:stick", "" },
		{ "mcl_core:stick", "" }
	},
	{
		{ "material", "material" },
		{ "", "mcl_core:stick" },
		{ "", "mcl_core:stick" }
	}
}
```

### `longdesc` and `usagehelp`:

```lua
-- longdesc and usagehelp for axes.
longdesc = S("An axe is your tool of choice to cut down trees, wood-based blocks and other blocks. Axes deal a lot of damage as well, but they are rather slow. Axes can be used to strip bark and hyphae from trunks. They can also be used to scrape blocks made of copper, reducing their oxidation stage or removing wax from waxed variants."),
usagehelp = S("To strip bark from trunks and hyphae, use the ax by right-clicking on them. To reduce an oxidation stage from a block made of copper or remove wax from waxed variants, right-click on them. Doors and trapdoors also require you to hold down the sneak key while using the axe.")
```

### `diggroups`

```lua
-- diggroups for swords.
diggroups = { swordy = {}, swordy_cobweb = {} }
```

## Licenses
* `default_shears_cut.ogg` from [Free Sound](https://freesound.org/people/SmartWentCody/sounds/179015/) by SmartWentCody, CC-BY-SA 3.0.
