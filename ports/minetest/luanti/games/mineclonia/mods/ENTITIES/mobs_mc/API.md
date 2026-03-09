## Public API

This sections covers functions for use in external mods.

### mobs_mc.register_villager

This function enables mods to add villager mobs.

**Signature:** `mobs_mc.register_villager (profession, poi, trades, gifts)`

PROFESSION is a table with the following fields:

```lua
{
    -- A user-visible string identifying this profession.
	description = S ("Profession"),
	
	-- An internal identifier for this profession.  This must not
    -- coincide with any other existing profession.
	name = "profession",
	
	-- An identifier that will be assigned to the point of
	-- interest definition encompassing this villager's job site
	-- block(s).
	--
	-- The chat command `/locate poi' will also locate instances of
	-- such job sites when provided with this identifier.
	poi = "my_mod:profession",
	
	-- The name of a texture that will be overlaid upon villagers of
	-- this profession.
	texture = "my_mod_villager_profession.png",
	
	-- A list of item names that this villager should collect from
	-- dropped items and save into its internal inventory.
	extra_pick_up = {
		"my_mod:profession_fuel",
	},
}
```

POI is a table with the following fields and callbacks, defining a
class of job site and the criteria for its existence:

```lua
{
	-- Return whether the node at NODEPOS is valid for an instance of
	-- this POI, or is `ignore'.  A villager cannot acquire a job site
	-- and will forfeit its job site if this callback in the POI by
	-- which it is represented should return false when invoked with
	-- its position.
	is_valid = function (nodepos) ... end,
	
	-- Must always be defined to true in job site POI definitions.
	village_center = true,
}
```

TRADES is a list of trades, and GIFTS is a loot table of loot that
will be offered to players afflicted with the Hero of the Village
status effect, as below.

Mods that invoke this function must declare a dependency on
mcl_villages as well as mobs_mc.

#### Example of adding a villager that trades honey and related items.

```lua
	local profession = {
		description = S("Beeologist"),
		name = "beeologist",
		poi = "my_mod:beeologist",
		group = "group:beehive",
		texture = "beeologist.png",
		extra_pick_up = {},
	}

	local poi = {
		is_valid = function(nodepos)
			local node = core.get_node(nodepos)
			return (node.name == "ignore" or core.get_item_group(node.name, "beehive") > 0)
		end,
		village_center = true,
	}

	local trades = {
		{
			{{"mcl_core:emerald", 1, 1}, {"mcl_potions:glass_bottle", 3, 3}},
			-- Plus a bunch of trades for flowers
		},

		{
			{{"mcl_honey:honey_bottle", 2, 2}, {"mcl_core:emerald", 1, 1}},
			{{"mcl_campfires:campfire_lit", 1, 1}, {"mcl_core:emerald", 1, 1}},
			{{"mcl_core:emerald", 1, 1}, {"mcl_honey:honeycomb", 3, 3}},
		},

		{
			{{"mcl_core:emerald", 5, 5}, {"mcl_honey:honey_bottle", 2, 2}},
			{{"mcl_beehives:beehive", 1, 1}, {"mcl_core:emerald", 5, 5}},
		},

		{
			{{"mcl_core:emerald", 5, 5}, {"mcl_honey:honeycomb_block", 1, 1}}
		},

		{
			{{"mcl_core:emerald", 2, 2}, {"mcl_honey:honey_block", 1, 1}},
			{{"mcl_core:emerald", 6, 6}, {"mcl_beehives:beehive", 1, 1}},
		},
	}

	local gifts = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{itemstring = "mcl_honey:honey_bottle"},
		},
	}

	mobs_mc.register_villager(profession, poi, trades, gifts)
```
