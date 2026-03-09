# mcl_villages

When creating buildings or farms for use with this mod, you can prevent paths
from crossing areas by using the `mcl_villages:no_paths` block. You may need to
stack them 2 high to prevent all paths. After the village paths have be laid
this block will be replaced by air.

## Legacy Building Interfaces

These functions are obsolete and inert when the new village generator
is enabled.  Refer to the documentation in `schemgen.lua` and
`mcl_levelgen.register_building_v2` for their replacement.

### Parameter

All of the following functions take a table with the following keys.

#### Mandatory

name

: The name to use for the object.

mts

: The path to the mts format schema file.

#### Optional

yadjust

: Y axis adjustment when placing the schema. This can be positive to raise the
placement, or negative to lower it.

	If your schema does not contain a ground layer then set this to 1.

no_ground_turnip

: If you don't want the foundation under the building modified, you can disable
the ground turnip by setting this to true.

	Mainly useful for small thing such as lamps, planters, etc.

no_clearance

: If you don't want the area around and above the building modified, you can
disable the overground clearance by setting this to true.

	Mainly useful for small thing such as lamps, planters, etc.

### mcl_villages.register_lamp(table)

Register a structure to use as a lamp. These will be added to the table used when
adding lamps to paths during village creation.

### mcl_villages.register_bell(table)

Register a structure to use as a bell. These will be added to the table used when
adding the bell during village creation.

There is 1 bell per village.

### mcl_villages.register_well(table)

Register a structure to use as a well. These will be added to the table used when
adding the wells during village creation.

The number of wells is calculated randomly based on the number of beds in the
village. Every 10 beds add 1 to the maximum number.

e.g. 8 beds == 1 well, 15 beds == 1 or 2 wells, 22 beds == 1 to 3 wells, etc.

### mcl_villages.register_building(table)

Register a building used for jobs, houses, or other uses.

The schema is parsed to work out how many jobs and beds are in it.

If you are adding a job site for a custom profession then ensure you call
```mobs_mc.register_villager_profession``` before you register a building using it.

If a building doesn't have any job sites or beds then it may get added during
the house placement phase. This will simply add another building to
the village and will not affect the number of jobs or beds.

#### Additional options

The ```mcl_villages.register_building``` call accepts the following optional
parameters in the table.

min_jobs

: A village will need at least this many jobs to have one of these buildings.

  This is used to restrict buildings to bigger villages.

max_jobs

: A village will need less that or equal to (<=) this many jobs to have one of
these buildings.

  This is used to restrict buildings to smaller villages.

num_others

: A village will need this many other job sites before you can have another of
these jobs sites.

  This is used to influence the ratio of buildings in a village.

group

: If a group is set, the num_others restriction is applied to the entire group.

is_mandatory

: This ensures that each village will have at least one of these buildings.

### mobs_mc.register_villager_profession(title, table)

**TODO** this should be somewhere else.

This API call allows you to register professions for villagers.

It takes 2 arguments.

1. title - The title to use for the profession.

  This mus be unique; the profession will be rejected if this title is already
  used.

1. Record - a table containing the details of the profession, it contains the
   following fields.

	1. name: The name displayed for the profession in the UI.
	1. texture: The texture to use for the profession
	1. jobsite: the node or group name sued to flag blocks as job sites for this
       profession
	1. trades: a table containing trades with 1 entry for each trade level.

You can access the current profession and job site data in
```mobs_mc.professions``` and ```mobs_mc.jobsites```.

### mcl_villages.register_on_village_placed(func)

This function allows registering functions to be called after a
village is laid out by the old village generator.  This function is
obsolete on Luanti 5.14 or later without replacement, as villages are
now incrementally generated in emerge threads in a procedural manner
that village placement callbacks cannot accommodate.

Note that the village may not be completed as the building post processing is
non-deterministic to avoid overloading the server.

`settlement_info` is a table containing data for all the buildings in the
village. The bell is always the first entry in the table.

`blockseed` is the block seed for the chunk the village was generated for.
Villages can extend outside of this chunk.

```lua
local function my_village_hook(settlement_info, blockseed)
	minetest.log("The village has " .. #settlement_info .. " buildings in it!")
end

mcl_villages.register_on_village_placed(my_village_hook)
```

### mcl_villages.register_on_villager_spawned(func)

This function allows registering functions to be called after a villager is
placed as part of village generation.

`villager_ent` is the entity created by `minetest.add_entity`.

`blockseed` is the block seed for the chunk the village was generated
for.  Villages can extend outside of this chunk; or, under the new
village generator, a ull value (see mcl_levelgen's API documentation)
unique to this villager; this value is reused across calls and mustn't
be cached or stored.

```lua
local function my_villager_hook(villager_ent, blockseed)
	local l = villager_ent:get_luaentity()
	minetest.log("The villager's id is " .. l._id)
end

mcl_villages.register_on_villager_spawned(my_villager_hook)
```

## Farm Interface

These functions aid creating crops for use use in farms placed during village
generation.

### mcl_villages.get_crop_types()

This allows checking what crop types are supported.

Currently they are: grain, root, gourd, flower, bush, tree.

Placement of gourds should take in to consideration the way they fruit.

### mcl_villages.get_crops()

Returns a table containing all registered crops.

### mcl_villages.get_weighted_crop(biome, crop_type, pr)

Gets a random crop for the biome and crop type.

### mcl_villages.register_crop(crop_def)

Registers a crop for use on farms.

crop_def is a table with the following fields:

* `node` the name of the crop node to place. e.g. `mcl_farming:wheat_1`.
* `crop_type` the type crop. e.g. `grain`
* `biomes` a table containing the weighting to give the crop.
  * Supported biome values are:
    * acacia
    * bamboo
    * desert
    * jungle
    * plains
    * savanna
    * spruce
  * If you leave a biome out ot he definition then the crop will not be available in that biome.
e.g.

```lua
mcl_villages.register_crop({
	type = "grain",
	node = "mcl_farming:wheat_1",
	biomes = {
		acacia = 10,
		bamboo = 10,
		desert = 10,
		jungle = 10,
		plains = 10,
		savanna = 10,
		spruce = 10,
	},
})
```

### Creating farms with replaceable crops

To create a farm that will utilize registered crops you follow the basic process
for creating a farm, but you leave out the crops.

Once you have your farm constructed then instead of placing crops you place blocks named `mcl_villages:crop_*` over the dirt in the farm.

Each crop type has 8 blocks that can be used for it. This allows, but does not
guarantee, variety of crops in a farm.

Each of the crop tiles has an image of a entity that it represents. This image
is representative, not explicit.

i.e. The root crop tiles have an image of a carrot on them, but they will be
swapped for a random root crop, not always carrots.

Each specific node will be replaced by a single item.

e.g. if you use `mcl_villages:crop_root_1` and `mcl_villages:crop_root_2` in your farm then all there will be at most 2 types of root crops on the farm.

It is random, so both types may get replaced by the same crop.

Remember that gourds affect 5 nodes when they crop; a good farmer won't plant
anything on the 4 nodes a fruit wil form and your farm should not do that
either.

Once you have saved the schema for your farm you register it with the building interface.

e.g.

```lua
mcl_villages.register_building({
	name = "my_farm",
	mts = schem_path .. "/my_farm.mts",
	num_others = 3,
})
```

When a village is generated there will be a chance your farm will be placed, any
crop blocks will be replaced by biome appropriate crops.

If a crop cannot be found for a crop type in a biome, then a default will be
used. This ensure all farming blocks are full, ven if it's al the same crop.

The default is wheat.

## Village Layout

There are two methods for layout out villages, circle layout is more likely to be
used for small villages and grid for large villages.

The circle layout uses circles (surprise) to calculate if buildings overlap. It
creates fairly widely spaced layouts.

The grid layout uses a predetermined grid layout to positions buildings and uses
AreaStore to adjust building position if there are collisions.

The predetermined grid is below, position 0 is the bell, the other numbers are the order of placement.

||||||||
| -- | -- | -- | -- | -- | -- | -- |
|48|41|33|25|29|37|45|
|40|17|13| 9|11|15|43|
|32|19| 5| 1| 3|22|35|
|28|23| 7| 0| 8|24|27|
|36|21| 4| 2| 6|20|31|
|44|16|12|10|14|18|39|
|46|38|30|26|34|42|47|
