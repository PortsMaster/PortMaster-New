local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- End City.
------------------------------------------------------------------------

local function enchant_20_39 (stack, pr)
	mcl_enchanting.enchant_randomly (stack, pr:next (20, 39), true,
					 false, false, pr)
end

local end_city_loot = {
	{
		stacks_min = 2,
		stacks_max = 6,
		items = {
			{
				itemstring = "mcl_core:diamond",
				amount_min = 2,
				amount_max = 7,
				weight = 5,
			},
			{
				itemstring = "mcl_core:iron_ingot",
				amount_min = 4,
				amount_max = 8,
				weight = 10,
			},
			{
				itemstring = "mcl_core:gold_ingot",
				amount_min = 2,
				amount_max = 7,
				weight = 15,
			},
			{
				itemstring = "mcl_core:emerald",
				amount_max = 6,
				amount_min = 2,
				weight = 2,
			},
			{
				itemstring = "mcl_farming:beetroot_seeds",
				amount_max = 10,
				amount_min = 1,
				weight = 5,
			},
			{
				itemstring = "mcl_mobitems:saddle",
				weight = 3,
			},
			{
				itemstring = "mcl_mobitems:iron_horse_armor",
			},
			{
				itemstring = "mcl_mobitems:gold_horse_armor",
			},
			{
				itemstring = "mcl_mobitems:diamond_horse_armor",
			},
			{
				itemstring = "mcl_tools:sword_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:boots_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:chestplate_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:leggings_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:helmet_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_tools:pick_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_tools:shovel_diamond",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_tools:sword_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:boots_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:chestplate_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:leggings_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_armor:helmet_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_tools:pick_iron",
				weight = 3,
				func = enchant_20_39,
			},
			{
				itemstring = "mcl_tools:shovel_iron",
				weight = 3,
				func = enchant_20_39,
			},
		},
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				weight = 14,
				nothing = true,
			},
			{
				itemstring = "mcl_armor:spire",
			},
		},
	},
}

mcl_levelgen.register_loot_table ("mcl_end:end_city_loot", end_city_loot)
mcl_levelgen.register_loot_table ("mcl_end:end_ship_loot", end_city_loot)

------------------------------------------------------------------------
-- End City registration.
------------------------------------------------------------------------

local is_ersatz = mcl_levelgen.enable_ersatz

local end_city_biomes = is_ersatz and {
	"TheEnd",
} or {
	"EndHighlands",
	"EndMidlands",
}

mcl_levelgen.modify_biome_groups (end_city_biomes, {
	has_end_city = true,
})

-- This file is also registered as a levelgen script, if name is not hardcoded,
-- it will give confusing results when called later by mcl_levelgen.
local modpath = core.get_modpath ("mcl_end")

local function L (template, weight, processors, allow_terrain_adaptation)
	return {
		projection = "rigid",
		template = modpath .. "/templates/" .. template .. ".dat",
		weight = weight,
		ground_level_delta = 1,
		processors = processors or {},
		no_terrain_adaptation
			= is_ersatz and not allow_terrain_adaptation or nil,
	}
end

mcl_levelgen.register_template_pool ("mcl_end:end_city_starts", {
	elements = {
		L ("end_city_base_tower", 1, nil, true),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:end_city_towers", {
	elements = {
		L ("end_city_small_tower_base", 1),
		-- TODO: L ("end_city_fat_tower_base", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:small_tower_middle_pieces", {
	elements = {
		L ("end_city_small_tower_independent", 1),
		L ("end_city_small_tower_1_branch", 2),
		L ("end_city_small_tower_2_branch", 2),
		L ("end_city_small_tower_3_branch", 2),
		L ("end_city_small_tower_4_branch", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:small_tower_top_buildings", {
	elements = {
		L ("end_city_small_tower_building_1", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:small_tower_building_extensions", {
	elements = {
		L ("end_city_small_tower_building_2", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:tower_bridges", {
	elements = {
		L ("end_city_tower_bridge", 2),
		L ("end_city_end_ship_dock_1", 1),
	},
	must_complete = true,
})

mcl_levelgen.register_template_pool ("mcl_end:end_ship_dock_extensions", {
	elements = {
		L ("end_city_end_ship_dock_2", 1),
	},
})


mcl_levelgen.register_template_pool ("mcl_end:bridge_extensions", {
	elements = {
		L ("end_city_tower_bridge_extension", 4),
		L ("end_city_steps_steep", 6),
		L ("end_city_end_ship_dock", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:house_steps", {
	elements = {
		L ("end_city_steps_steep", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:houses", {
	elements = {
		L ("end_city_house_basic", 1),
		L ("end_city_house_2layer", 3),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:house_roof", {
	elements = {
		L ("end_city_house_basic_roof", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:roof_2layer", {
	elements = {
		L ("end_city_house_layer_2", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:roof_3layer", {
	elements = {
		L ("end_city_roof_layer_2", 1),
		L ("end_city_house_loot_floor", 2),
	},
})

mcl_levelgen.register_template_pool ("mcl_end:end_ships", {
	elements = {
		L ("end_city_ship", 1, {
			mcl_levelgen.wall_update_processor (),
		}),
	},
})

local jigsaw_create_start = mcl_levelgen.jigsaw_create_start
local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local height_of_lowest_corner_including_center
	= mcl_levelgen.height_of_lowest_corner_including_center
local ZERO = function (_) return 0 end

local function end_city_create_start (self, level, terrain, rng, cx, cz)
	local rot = random_schematic_rotation (rng)
	local lowest = height_of_lowest_corner_including_center (terrain, cx, cz, rot)
	if lowest < 60 or (is_ersatz and (cx * cx + cz * cz) < 1024) then
		return nil
	else
		return jigsaw_create_start (self, level, terrain, rng, cx, cz)
	end
end

mcl_levelgen.register_structure ("mcl_end:end_city", {
	step = mcl_levelgen.SURFACE_STRUCTURES,
	biomes = mcl_levelgen.build_biome_list ({"#has_end_city",}),
	create_start = end_city_create_start,
	terrain_adaptation = is_ersatz and "beard_thin" or "none",
	max_distance_from_center = 110,
	size = 25,
	start_height = ZERO,
	project_start_to_heightmap = "world_surface_wg",
	start_pool = "mcl_end:end_city_starts",
	test_start_position = true,
})

mcl_levelgen.register_structure_set ("mcl_end:end_cities", {
	structures = {
		"mcl_end:end_city",
	},
	placement = R (1.0, "default", 20, 11, 10387313, "triangular", nil, nil),
})
