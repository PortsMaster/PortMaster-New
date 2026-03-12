------------------------------------------------------------------------
-- Procedurally generated mangroves.
------------------------------------------------------------------------

local TWO = function (_) return 2 end
local THREE = function (_) return 3 end
local TWENTY_FIVE = function (_) return 25 end

local cid_tree_mangrove
	= core.get_content_id ("mcl_trees:tree_mangrove")
local cid_leaves_mangrove
	= core.get_content_id ("mcl_trees:leaves_mangrove")
local cid_mangrove_mud_roots
	= core.get_content_id ("mcl_mangrove:mangrove_mud_roots")
local cid_moss_carpet
	= core.get_content_id ("mcl_lush_caves:moss_carpet")
local cid_mangrove_roots
	= core.get_content_id ("mcl_mangrove:mangrove_roots")
local cid_mangrove_propagule
	= core.get_content_id ("mcl_mangrove:propagule")
local cid_hanging_mangrove_propagule_1
	= core.get_content_id ("mcl_mangrove:propagule_hanging_1")
local cid_hanging_mangrove_propagule_2
	= core.get_content_id ("mcl_mangrove:propagule_hanging_2")
local cid_hanging_mangrove_propagule_3
	= core.get_content_id ("mcl_mangrove:propagule_hanging_3")
local cid_hanging_mangrove_propagule_4
	= core.get_content_id ("mcl_mangrove:propagule_hanging_4")
local cid_hanging_mangrove_propagule_5
	= core.get_content_id ("mcl_mangrove:propagule_hanging_5")
local cid_water_source
	= core.get_content_id ("mcl_core:water_source")
local cid_water_logged_roots
	= core.get_content_id ("mcl_mangrove:water_logged_roots")

local hanging_propagules_by_age = {
	cid_hanging_mangrove_propagule_1,
	cid_hanging_mangrove_propagule_2,
	cid_hanging_mangrove_propagule_3,
	cid_hanging_mangrove_propagule_4,
	cid_hanging_mangrove_propagule_5,
}

local mangrove_can_grow_through = mcl_levelgen.construct_cid_list ({
	"group:hanging_propagule",
	"mcl_core:vine",
	"mcl_lush_caves:moss_carpet",
	"mcl_mangrove:mangrove_mud_roots",
	"mcl_mangrove:mangrove_roots",
	"mcl_mangrove:propagule",
	"mcl_mangrove:water_logged_roots",
	"mcl_mud:mud",
	"mcl_trees:leaves_mangrove",
})

local mangrove_roots_can_grow_through = mcl_levelgen.construct_cid_list ({
	"group:hanging_propagule",
	"group:snow_layer",
	"mcl_lush_caves:moss_carpet",
	"mcl_mangrove:mangrove_mud_roots",
	"mcl_mangrove:mangrove_roots",
	"mcl_mangrove:propagule",
	"mcl_mangrove:water_logged_roots",
	"mcl_mud:mud",
})

local get_biome_color = mcl_trees.get_biome_color
local get_block = mcl_levelgen.get_block

local function maybe_waterlog_mangrove_roots (x, y, z, rng)
	local existing, _ = get_block (x, y, z)
	if existing == cid_water_source
		or existing == cid_water_logged_roots then
		return cid_water_logged_roots, 0
	else
		return cid_mangrove_roots, 0
	end
end

mcl_levelgen.register_configured_feature ("mcl_mangrove:mangrove", {
	feature = "mcl_trees:tree",
	trunk_content = function (x, y, z, rng)
		return cid_tree_mangrove, 0
	end,
	trunk_placer = mcl_trees.create_upwards_branching_trunk_placer ({
		base_height = 2,
		height_rand_a = 1,
		height_rand_b = 2,
		can_grow_through = mangrove_can_grow_through,
		extra_branch_length = mcl_levelgen.uniform_height (0, 1),
		extra_branch_steps = mcl_levelgen.uniform_height (1, 4),
		place_branch_per_log_probability = 0.5,
	}),
	foliage_content = function (x, y, z, rng)
		return cid_leaves_mangrove, get_biome_color (x, y, z)
	end,
	foliage_placer = mcl_trees.create_random_spread_foliage_placer ({
		radius = THREE,
		leaf_placement_attempts = 70,
		foliage_height = TWO,
	}),
	ignore_vines = true,
	minimum_size = mcl_trees.create_two_layers_feature_size ({
		limit = 2,
		lower_size = 0,
		upper_size = 2,
	}),
	root_placer = mcl_trees.create_mangrove_root_placement ({
		can_grow_through = mangrove_roots_can_grow_through,
		max_root_length = 15,
		max_root_width = 8,
		muddy_roots_in = mcl_levelgen.construct_cid_list ({
			"mcl_mud:mud",
			"mcl_mangrove:mangrove_mud_roots",
		}),
		muddy_roots_content = function (x, y, z, rng)
			return cid_mangrove_mud_roots, 0
		end,
		random_skew_chance = 0.2,
		above_root_placement_chance = 0.5,
		above_root_content = function (x, y, z, rng)
			return cid_moss_carpet, 0
		end,
		root_content = maybe_waterlog_mangrove_roots,
		trunk_offset_y = mcl_levelgen.uniform_height (1, 3),
	}),
	decorators = {
		mcl_levelgen.build_leave_vine_decoration (0.125),
		mcl_levelgen.build_attach_to_leaves_decoration ({
			content = function (x, y, z, rng)
				return hanging_propagules_by_age[rng:next_within (5) + 1], 0
			end,
			directions = {
				{ 0, -1, 0, },
			},
			exclusion_radius_xz = 1,
			exclusion_radius_y = 0,
			probability = 0.14,
			required_empty_blocks = 2,
		}),
		mcl_levelgen.build_beehive_decoration (0.01),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mangrove:mangrove", {
	configured_feature = "mcl_mangrove:mangrove",
	placement_modifiers = {},
})

mcl_levelgen.register_configured_feature ("mcl_mangrove:tall_mangrove", {
	feature = "mcl_trees:tree",
	trunk_content = function (x, y, z, rng)
		return cid_tree_mangrove, 0
	end,
	trunk_placer = mcl_trees.create_upwards_branching_trunk_placer ({
		base_height = 4,
		height_rand_a = 1,
		height_rand_b = 9,
		can_grow_through = mangrove_can_grow_through,
		extra_branch_length = mcl_levelgen.uniform_height (0, 1),
		extra_branch_steps = mcl_levelgen.uniform_height (1, 6),
		place_branch_per_log_probability = 0.5,
	}),
	foliage_content = function (x, y, z, rng)
		return cid_leaves_mangrove, get_biome_color (x, y, z)
	end,
	foliage_placer = mcl_trees.create_random_spread_foliage_placer ({
		radius = THREE,
		leaf_placement_attempts = 70,
		foliage_height = TWO,
	}),
	ignore_vines = true,
	minimum_size = mcl_trees.create_two_layers_feature_size ({
		limit = 3,
		lower_size = 0,
		upper_size = 2,
	}),
	root_placer = mcl_trees.create_mangrove_root_placement ({
		can_grow_through = mangrove_roots_can_grow_through,
		max_root_length = 15,
		max_root_width = 8,
		muddy_roots_in = mcl_levelgen.construct_cid_list ({
			"mcl_mud:mud",
			"mcl_mangrove:mangrove_mud_roots",
		}),
		muddy_roots_content = function (x, y, z, rng)
			return cid_mangrove_mud_roots, 0
		end,
		random_skew_chance = 0.2,
		above_root_placement_chance = 0.5,
		above_root_content = function (x, y, z, rng)
			return cid_moss_carpet, 0
		end,
		root_content = maybe_waterlog_mangrove_roots,
		trunk_offset_y = mcl_levelgen.uniform_height (3, 7),
	}),
	decorators = {
		mcl_levelgen.build_leave_vine_decoration (0.125),
		mcl_levelgen.build_attach_to_leaves_decoration ({
			content = function (x, y, z, rng)
				return hanging_propagules_by_age[rng:next_within (5) + 1], 0
			end,
			directions = {
				{ 0, -1, 0, },
			},
			exclusion_radius_xz = 1,
			exclusion_radius_y = 0,
			probability = 0.14,
			required_empty_blocks = 2,
		}),
		mcl_levelgen.build_beehive_decoration (0.01),
	},
})

mcl_levelgen.register_placed_feature ("mcl_mangrove:tall_mangrove", {
	configured_feature = "mcl_mangrove:tall_mangrove",
	placement_modifiers = {},
})

mcl_levelgen.register_configured_feature ("mcl_mangrove:mangrove_vegetation", {
	feature = "mcl_levelgen:random_selector",
	default = "mcl_mangrove:mangrove",
	features = {
		{
			chance = 0.85,
			feature = "mcl_mangrove:tall_mangrove",
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_mangrove:trees_mangrove", {
	configured_feature = "mcl_mangrove:mangrove_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_surface_water_depth_filter (5),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
		mcl_trees.build_hospitability_check (cid_mangrove_propagule),
	},
})
