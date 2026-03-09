local R = mcl_levelgen.build_random_spread_placement

local floor = math.floor

------------------------------------------------------------------------
-- Shipwreck.
------------------------------------------------------------------------

mcl_levelgen.register_loot_table ("mcl_levelgen:shipwreck_map", {
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:paper", weight = 20, amount_min = 1, amount_max = 10 },
			{ itemstring = "mcl_mobitems:feather", weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_books:book", weight = 5, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
		},
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				nothing = true,
				weight = 5,
			},
			{
				itemstring = "mcl_armor:coast",
				amount_min = 2,
				amount_max = 2,
			},
		},
	},
})

mcl_levelgen.register_loot_table ("mcl_levelgen:shipwreck_treasure", {
	{
		stacks_min = 2,
		stacks_max = 6,
		items = {
			{ itemstring = "mcl_core:iron_ingot", weight = 90, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:iron_nugget", weight = 50, amount_min = 1, amount_max = 10 },
			{ itemstring = "mcl_core:emerald", weight = 40, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:lapis", weight = 20, amount_min = 1, amount_max = 10 },
			{ itemstring = "mcl_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 10 },
			{ itemstring = "mcl_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_armor:coast", weight = 1, amount_min = 2, amount_max = 2},
		},
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				nothing = true,
				weight = 5,
			},
			{
				itemstring = "mcl_armor:coast",
				amount_min = 2,
				amount_max = 2,
			},
		},
	},
})

mcl_levelgen.register_loot_table ("mcl_levelgen:shipwreck_supply", {
	{
		stacks_min = 3,
		stacks_max = 10,
		items = {
			{ itemstring = "mcl_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
			{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 8, amount_max = 21 },
			{ itemstring = "mcl_farming:carrot_item", weight = 7, amount_min = 4, amount_max = 8 },
			{ itemstring = "mcl_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
			{ itemstring = "mcl_farming:potato_item", weight = 7, amount_min = 2, amount_max = 6 },
			{ itemstring = "mcl_lush_caves:moss", weight = 7, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_core:coal_lump", weight = 6, amount_min = 2, amount_max = 8 },
			{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
			{ itemstring = "mcl_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_armor:helmet_leather_enchanted", weight = 3, func = function(stack, _)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
			{ itemstring = "mcl_armor:chestplate_leather_enchanted", weight = 3, func = function(stack, _)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
			{ itemstring = "mcl_armor:leggings_leather_enchanted", weight = 3, func = function(stack, _)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
			{ itemstring = "mcl_armor:boots_leather_enchanted", weight = 3, func = function(stack, _)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
			{ itemstring = "mcl_bamboo:bamboo", weight = 2, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_farming:pumpkin", weight = 2, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
		},
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				nothing = true,
				weight = 5,
			},
			{
				itemstring = "mcl_armor:coast",
				amount_min = 2,
				amount_max = 2,
			},
		},
	},
})

local function L (name)
	local file = mcl_levelgen.prefix
		.. "/templates/" .. name .. ".dat"
	local template, err
		= mcl_levelgen.read_structure_template (file)
	assert (template, err)
	return template
end

local shipwreck_templates = {}

local function init_templates ()
	shipwreck_templates = {
		L ("shipwreck_full_back_damaged"),
		L ("shipwreck_full_damaged"),
		L ("shipwreck_full_normal"),
		L ("shipwreck_half_back"),
		L ("shipwreck_half_front"),
	}
end

if not mcl_levelgen.is_levelgen_environment then
	core.register_on_mods_loaded (init_templates)
else
	init_templates ()
end

local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local structure_biome_test = mcl_levelgen.structure_biome_test
local is_not_air = mcl_levelgen.is_not_air
local make_template_piece_with_pivot = mcl_levelgen.make_template_piece_with_pivot

local function get_offset_beached (y, template, rng)
	return y - floor (template.height / 4) - rng:next_within (3)
end

local create_structure_start = mcl_levelgen.create_structure_start
local lowest_corner_from_point
	= mcl_levelgen.lowest_corner_from_point

local PIVOT_X = 0
local PIVOT_Z = 5

local function shipwreck_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + 8, cz * 16 + 8
	local is_beached = self.is_beached
	local y = terrain:get_one_height (x, z, is_beached and is_not_air or nil)
	if structure_biome_test (level, self, x, y, z) then
		local rotation = random_schematic_rotation (rng)
		local idx = rng:next_within (#shipwreck_templates)
		local template = shipwreck_templates[1 + idx]
		local piece = make_template_piece_with_pivot (template, x - 8, 90, z - 8,
							      PIVOT_X, PIVOT_Z,
							      nil, rotation, rng, nil, nil,
							      nil)
		local bbox = piece.bbox

		if is_beached then
			local min_y = lowest_corner_from_point (terrain,
								bbox[1], bbox[3],
								bbox[4] - bbox[1],
								bbox[6] - bbox[3],
								is_not_air)
			y = get_offset_beached (min_y, template, rng)
		else
			y = terrain:area_average_height (bbox[1], bbox[3],
							 bbox[4], bbox[6]) - 1
		end

		piece.y = y
		bbox[5] = y + (bbox[5] - bbox[2])
		bbox[2] = y
		return create_structure_start (self, { piece, })
	end
end

------------------------------------------------------------------------
-- Shipwreck registration.
------------------------------------------------------------------------

local shipwreck_beached_biomes = {
	"#is_beach",
}

local shipwreck_biomes = {
	"#is_ocean",
}

mcl_levelgen.modify_biome_groups (shipwreck_beached_biomes, {
	has_shipwreck_beached = true,
})

mcl_levelgen.modify_biome_groups (shipwreck_biomes, {
	has_shipwreck = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:shipwreck", {
	biomes = mcl_levelgen.build_biome_list ({"#has_shipwreck",}),
	create_start = shipwreck_create_start,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	is_beached = false,
})

mcl_levelgen.register_structure ("mcl_levelgen:shipwreck_beached", {
	biomes = mcl_levelgen.build_biome_list ({"#has_shipwreck_beached",}),
	create_start = shipwreck_create_start,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	is_beached = true,
})

mcl_levelgen.register_structure_set ("mcl_levelgen:shipwrecks", {
	structures = {
		"mcl_levelgen:shipwreck",
		"mcl_levelgen:shipwreck_beached",
	},
	placement = R (1.0, "default", 24, 4, 165745295, "linear", nil, nil),
})
