local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Igloo.
------------------------------------------------------------------------

mcl_levelgen.register_loot_table ("mcl_levelgen:igloo", {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_core:apple_gold", weight = 1 },
		},
	},
	{
		stacks_min = 2,
		stacks_max = 8,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 15, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_farming:wheat_item", weight = 10, amount_min = 2, amount_max = 3 },
			{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
			{ itemstring = "mcl_tools:axe_stone", weight = 2 },
			{ itemstring = "mcl_core:emerald", weight = 1 },
			{ itemstring = "mcl_core:apple_gold", weight = 1 },
		},
	},
})

------------------------------------------------------------------------
-- Igloo pieces.
------------------------------------------------------------------------

local name_igloo_top
	= mcl_levelgen.prefix .. "/templates/igloo_top.dat"
local name_igloo_middle
	= mcl_levelgen.prefix .. "/templates/igloo_middle.dat"
local name_igloo_bottom
	= mcl_levelgen.prefix .. "/templates/igloo_bottom.dat"

local igloo_top_template
local igloo_middle_template
local igloo_bottom_template
local shaft_height

local function init_templates ()
	local err
	igloo_top_template, err
		= mcl_levelgen.read_structure_template (name_igloo_top)
	if err then
		error (err)
	end
	igloo_middle_template, err
		= mcl_levelgen.read_structure_template (name_igloo_middle)
	if err then
		error (err)
	end
	shaft_height = igloo_middle_template.height
	igloo_bottom_template, err
		= mcl_levelgen.read_structure_template (name_igloo_bottom)
	if err then
		error (err)
	end
end

if mcl_levelgen.is_levelgen_environment then
	init_templates ()
else
	core.register_on_mods_loaded (init_templates)
end

local igloo_top_shaft_x = 3
local igloo_top_shaft_z = 6

local igloo_middle_shaft_x = 1
local igloo_middle_shaft_z = 1

local igloo_bottom_shaft_x = 3
local igloo_bottom_shaft_z = 7

local make_template_piece_with_pivot = mcl_levelgen.make_template_piece_with_pivot
local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local is_not_air = mcl_levelgen.is_not_air
local create_structure_start = mcl_levelgen.create_structure_start
local structure_biome_test = mcl_levelgen.structure_biome_test
local insert = table.insert

local function igloo_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + 8, cz * 16 + 8
	local y = terrain:get_one_height (x, z, is_not_air)
	local rot = random_schematic_rotation (rng)
	local basement = rng:next_double () < 0.5

	if structure_biome_test (level, self, x, y, z) then
		local y = terrain:get_one_height (x - 8, z - 8,
						  is_not_air)
		local igloo_top
			= make_template_piece_with_pivot (igloo_top_template,
							  x - 8, y - 1, z - 8,
							  igloo_top_shaft_x,
							  igloo_top_shaft_z, nil, rot,
							  rng, nil, nil, 1)
		local pieces = {
			igloo_top,
		}
		if basement then
			local segments = rng:next_within (8) + 4
			local lab_y = y - 1 - (segments * shaft_height)
				- igloo_bottom_template.height
			local dz = igloo_bottom_shaft_z - igloo_top_shaft_z
			local dx = igloo_bottom_shaft_x - igloo_top_shaft_x
			local laboratory
				= make_template_piece_with_pivot (igloo_bottom_template,
								  x - 8 - dx, lab_y,
								  z - 8 - dz, igloo_bottom_shaft_x,
								  igloo_bottom_shaft_z, nil,
								  rot, rng, nil, nil, 1)
			insert (pieces, laboratory)

			local dz = igloo_middle_shaft_z - igloo_top_shaft_z
			local dx = igloo_middle_shaft_x - igloo_top_shaft_x
			local base_y = lab_y + igloo_bottom_template.height

			for i = 0, segments - 1 do
				local shaft
					= make_template_piece_with_pivot (igloo_middle_template,
									  x - 8 - dx,
									  base_y + i * shaft_height,
									  z - 8 - dz,
									  igloo_middle_shaft_x,
									  igloo_middle_shaft_z,
									  nil, rot, rng, nil, nil, 1)
				insert (pieces, shaft)
			end
		end
		return create_structure_start (self, pieces)
	end
	return nil
end

------------------------------------------------------------------------
-- Igloo registration.
------------------------------------------------------------------------

local igloo_biomes = {
	"SnowyTaiga",
	"SnowyPlains",
	"SnowySlopes",
}

mcl_levelgen.modify_biome_groups (igloo_biomes, {
	has_igloo = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:igloo", {
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_igloo",}),
	step = mcl_levelgen.SURFACE_STRUCTURES,
	create_start = igloo_create_start,
})

mcl_levelgen.register_structure_set ("mcl_levelgen:igloos", {
	structures = {
		"mcl_levelgen:igloo",
	},
	placement = R (1.0, "default", 32, 8, 14357618, "linear",
		       nil, nil),
})
