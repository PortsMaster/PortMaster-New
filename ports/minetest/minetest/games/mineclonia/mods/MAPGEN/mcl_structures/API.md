# mcl_structures
Structure placement API for MCL2.

## mcl_structures.register_structure(name,structure definition,nospawn)
If nospawn is truthy the structure will not be placed by mapgen and the decoration parameters can be omitted. This is intended for secondary structures the placement of which gets triggered by the placement of other structures. It can also be used to register testing structures so they can be used with /spawnstruct.

### structure definition
{
	fill_ratio = OR noise = {},
	biomes = {},
	y_min =,
	y_max =,
	place_on = {},
	spawn_by = {},
	num_spawn_by =,
	flags = (default: "place_center_x, place_center_z, force_placement")
	(same as decoration def)
	y_offset =, 	--can be a number or a function returning a number
	filenames = {} OR place_func = function(pos,def,pr)
					-- filenames can be a list of any schematics accepted by mcl_structures.place_schematic / minetest.place_schematic
	on_place = function(pos,def,pr) end,
					-- called before placement. denies placement when returning falsy.
	after_place = function(pos,def,pr)
					-- executed after successful placement
	sidelen = int, --length of one side of the structure. used for foundations.
	solid_ground = bool, -- structure requires solid ground
	make_foundation = bool, -- a foundation is automatically built for the structure. needs the sidelen param
	loot = ,
					--a table of loot tables for mcl_loot indexed by node names
					-- e.g. { ["mcl_chests:chest_small"] = {loot},... }
}
## mcl_structures.registered_structures
Table of the registered structure defintions indexed by name.

## mcl_structures.place_structure(pos, def, pr)
Places a structure using the mapgen placement function

## mcl_structures.place_schematic(pos, schematic, rotation, replacements, force_placement, flags, after_placement_callback, pr, callback_param)
