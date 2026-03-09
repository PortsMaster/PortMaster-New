if not mcl_levelgen.is_levelgen_environment then
	local modpath = core.get_modpath (core.get_current_modname ())
	mcl_levelgen.register_portable_schematic ("mcl_lush_caves:azalea_tree_1",
						  modpath .. "/schematics/azalea1.mts")
	return
end

local W = mcl_levelgen.build_weighted_list
local C = mcl_levelgen.build_weighted_cid_provider
local E = mcl_levelgen.build_environment_scan
local overworld = mcl_levelgen.overworld_preset
local OVERWORLD_MIN = overworld.min_y
local ull = mcl_levelgen.ull

local uniform_height = mcl_levelgen.uniform_height
local ONE = function (_) return 1 end
local ONE_HUNDRED_AND_TWENTY_FIVE = function (_) return 125 end
local ONE_HUNDRED_AND_EIGHTY_EIGHT = function (_) return 188 end
local SIXTY_TWO = function (_) return 62 end
local THREE = function (_) return 3 end
local TWENTY_FIVE = function (_) return 25 end
local TWO_HUNDRED_AND_FIFTY_SIX = function (_) return 256 end

local mathmax = math.max

------------------------------------------------------------------------
-- Async lush caves.
------------------------------------------------------------------------

-- "mcl_lush_caves:lush_caves_ceiling_vegetation",

local cid_cave_vines = core.get_content_id ("mcl_lush_caves:cave_vines")
local cid_cave_vines_lit = core.get_content_id ("mcl_lush_caves:cave_vines_lit")
local cid_moss_block = core.get_content_id ("mcl_lush_caves:moss")
local cid_clay_block = core.get_content_id ("mcl_core:clay")

mcl_levelgen.register_configured_feature ("mcl_lush_caves:cave_vine_in_moss", {
	feature = "mcl_levelgen:block_column",
	allowed_placement = mcl_levelgen.is_air,
	direction = -1,
	layers = {
		{
			height = W ({
				{
					weight = 5,
					data = uniform_height (1, 4),
				},
				{
					weight = 1,
					data = uniform_height (2, 8),
				},
			}),
			content = C ({
				{
					weight = 4,
					cid = cid_cave_vines,
					param2 = 5,
				},
				{
					weight = 1,
					cid = cid_cave_vines_lit,
					param2 = 0,
				},
			}),
		},
	},
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:moss_patch_ceiling", {
	feature = "mcl_levelgen:vegetation_patch",
	replaceable = mcl_levelgen.construct_cid_list ({
		"mcl_lush_caves:cave_vines_lit",
		"mcl_lush_caves:cave_vines",
		"group:dirt",
		"group:deepslate_ore_target",
		"group:stone_ore_target",
	}),
	ground = function (_, _, _, rng)
		return cid_moss_block, 0
	end,
	surface = "ceiling",
	extra_bottom_block_chance = 0.0,
	extra_edge_column_chance = 0.3,
	vegetation_chance = 0.08,
	vegetation_feature = {
		configured_feature = "mcl_lush_caves:cave_vine_in_moss",
		placement_modifiers = {},
	},
	vertical_range = 5,
	xz_radius = uniform_height (4, 7),
	depth = uniform_height (1, 2),
	update_light = true,
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:lush_caves_ceiling_vegetation", {
	configured_feature = "mcl_lush_caves:moss_patch_ceiling",
	placement_modifiers = {
		mcl_levelgen.build_count (ONE_HUNDRED_AND_TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = 1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_position_walkable,
		}),
		mcl_levelgen.build_constant_height_offset (-1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:cave_vines",

mcl_levelgen.register_configured_feature ("mcl_lush_caves:cave_vine", {
	feature = "mcl_levelgen:block_column",
	allowed_placement = mcl_levelgen.is_air,
	direction = -1,
	layers = {
		{
			height = W ({
				{
					weight = 5,
					data = uniform_height (1, 20),
				},
				{
					weight = 3,
					data = uniform_height (1, 3),
				},
				{
					weight = 10,
					data = uniform_height (1, 7),
				},
			}),
			content = C ({
				{
					weight = 4,
					cid = cid_cave_vines,
					param2 = 5,
				},
				{
					weight = 1,
					cid = cid_cave_vines_lit,
					param2 = 0,
				},
			}),
		},
	},
	prioritize_tip = true,
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:cave_vines", {
	configured_feature = "mcl_lush_caves:cave_vine",
	placement_modifiers = {
		mcl_levelgen.build_count (ONE_HUNDRED_AND_EIGHTY_EIGHT),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = 1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_bottom_face_sturdy,
		}),
		mcl_levelgen.build_constant_height_offset (-1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:lush_caves_clay",

local param2_rng = overworld.factory ("mcl_lush_caves:dripleaf_param2")
local dripleaf_param2_rng = param2_rng:fork_positional ():create_reseedable ()

local cid_small_dripleaf = core.get_content_id ("mcl_lush_caves:dripleaf_small")
local cid_small_dripleaf_stem = core.get_content_id ("mcl_lush_caves:dripleaf_small_stem")
local cid_big_dripleaf = core.get_content_id ("mcl_lush_caves:dripleaf_big")
local cid_big_dripleaf_stem = core.get_content_id ("mcl_lush_caves:dripleaf_big_stem")

local function dripleaf_param2_at_pos (x, z)
	dripleaf_param2_rng:reseed_positional (x, 0, z)
	return dripleaf_param2_rng:next_within (4)
end

local function small_dripleaf_content (x, y, z, rng)
	return cid_small_dripleaf, dripleaf_param2_at_pos (x, z)
end

local function small_dripleaf_stem (x, y, z, rng)
	return cid_small_dripleaf_stem, dripleaf_param2_at_pos (x, z)
end

local function big_dripleaf_content (x, y, z, rng)
	return cid_big_dripleaf, dripleaf_param2_at_pos (x, z)
end

local function big_dripleaf_stem (x, y, z, rng)
	return cid_big_dripleaf_stem, dripleaf_param2_at_pos (x, z)
end

mcl_levelgen.register_configured_feature ("mcl_lush_caves:solitary_small_dripleaf", {
	feature = "mcl_levelgen:block_column",
	allowed_placement = mcl_levelgen.is_water_or_air,
	layers = {
		{
			height = ONE,
			content = small_dripleaf_stem,
		},
		{
			height = ONE,
			content = small_dripleaf_content,
		},
	},
	direction = 1,
	prioritize_tip = true,
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:big_dripleaf_column", {
	feature = "mcl_levelgen:block_column",
	allowed_placement = mcl_levelgen.is_water_or_air,
	direction = 1,
	layers = {
		{
			height = W ({
				{
					weight = 2,
					data = uniform_height (0, 4),
				},
				{
					weight = 1,
					data = 0,
				},
			}),
			content = big_dripleaf_stem,
		},
		{
			height = ONE,
			content = big_dripleaf_content,
		},
	},
	prioritize_tip = true,
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:dripleaf", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_lush_caves:solitary_small_dripleaf",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_lush_caves:big_dripleaf_column",
			placement_modifiers = {},
		},
	},
})

local function provide_clay ()
	return cid_clay_block, 0
end

mcl_levelgen.register_configured_feature ("mcl_lush_caves:clay_with_dripleaves", {
	feature = "mcl_levelgen:vegetation_patch",
	depth = THREE,
	extra_bottom_block_chance = 0.4,
	extra_edge_column_chance = 0.7,
	ground = provide_clay,
	replaceable = mcl_levelgen.construct_cid_list ({
		"mcl_lush_caves:cave_vines_lit",
		"mcl_lush_caves:cave_vines",
		"mcl_core:clay",
		"mcl_core:sand",
		"mcl_core:gravel",
		"group:dirt",
		"group:deepslate_ore_target",
		"group:stone_ore_target",
	}),
	surface = "floor",
	vegetation_chance = 0.05,
	vegetation_feature = {
		configured_feature = "mcl_lush_caves:dripleaf",
		placement_modifiers = {},
	},
	vertical_range = 2,
	xz_radius = uniform_height (4, 7),
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:clay_pool_with_dripleaves", {
	feature = "mcl_levelgen:waterlogged_vegetation_patch",
	depth = THREE,
	extra_bottom_block_chance = 0.4,
	extra_edge_column_chance = 0.7,
	ground = provide_clay,
	replaceable = mcl_levelgen.construct_cid_list ({
		"mcl_lush_caves:cave_vines_lit",
		"mcl_lush_caves:cave_vines",
		"mcl_core:clay",
		"mcl_core:sand",
		"mcl_core:gravel",
		"group:dirt",
		"group:deepslate_ore_target",
		"group:stone_ore_target",
	}),
	surface = "floor",
	vegetation_chance = 0.1,
	vegetation_feature = {
		configured_feature = "mcl_lush_caves:dripleaf",
		placement_modifiers = {},
	},
	vertical_range = 5,
	xz_radius = uniform_height (4, 7),
	update_light = true,
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:lush_caves_clay", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_lush_caves:clay_with_dripleaves",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_lush_caves:clay_pool_with_dripleaves",
			placement_modifiers = {},
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:lush_caves_clay", {
	configured_feature = "mcl_lush_caves:lush_caves_clay",
	placement_modifiers = {
		mcl_levelgen.build_count (SIXTY_TWO),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = -1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_position_walkable,
		}),
		mcl_levelgen.build_constant_height_offset (1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:lush_caves_vegetation",

local cid_flowering_azalea
	= core.get_content_id ("mcl_lush_caves:azalea_flowering")
local cid_azalea
	= core.get_content_id ("mcl_lush_caves:azalea")
local cid_moss_carpet
	= core.get_content_id ("mcl_lush_caves:moss_carpet")
local cid_short_grass
	= core.get_content_id ("mcl_flowers:tallgrass")
local cid_double_grass
	= core.get_content_id ("mcl_flowers:double_grass")

mcl_levelgen.register_configured_feature ("mcl_lush_caves:moss_vegetation", {
	feature = "mcl_levelgen:simple_block",
	content = C ({
		{
			weight = 4,
			cid = cid_flowering_azalea,
			param2 = 0,
		},
		{
			weight = 7,
			cid = cid_azalea,
			param2 = 0,
		},
		{
			weight = 25,
			cid = cid_moss_carpet,
			param2 = 0,
		},
		{
			weight = 50,
			cid = cid_short_grass,
			param2 = 0,
		},
		{
			weight = 10,
			cid = cid_double_grass,
			param2 = 0,
		},
	}),
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:moss_patch", {
	feature = "mcl_levelgen:vegetation_patch",
	depth = ONE,
	extra_bottom_block_chance = 0.0,
	extra_edge_column_chance = 0.3,
	ground = function (_, _, _, rng)
		return cid_moss_block, 0
	end,
	replaceable = mcl_levelgen.construct_cid_list ({
		"mcl_lush_caves:cave_vines_lit",
		"mcl_lush_caves:cave_vines",
		"group:dirt",
		"group:deepslate_ore_target",
		"group:stone_ore_target",
	}),
	surface = "floor",
	vegetation_chance = 0.8,
	vegetation_feature = {
		configured_feature = "mcl_lush_caves:moss_vegetation",
		placement_modifiers = {},
	},
	vertical_range = 5,
	xz_radius = uniform_height (4, 7),
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:lush_caves_vegetation", {
	configured_feature = "mcl_lush_caves:moss_patch",
	placement_modifiers = {
		mcl_levelgen.build_count (ONE_HUNDRED_AND_TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = -1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_position_walkable,
		}),
		mcl_levelgen.build_constant_height_offset (1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:rooted_azalea_tree",
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/feature/RootSystemFeature.html

local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_water_flowing = core.get_content_id ("mcl_core:water_flowing")
local cid_hanging_roots = core.get_content_id ("mcl_lush_caves:hanging_roots")
local cid_rooted_dirt = core.get_content_id ("mcl_lush_caves:rooted_dirt")
local cid_air = core.CONTENT_AIR

-- Important:

-- Successful generation of this feature is often contingent on the
-- vertical size of the accessible region, which is generally (not
-- always) decided by chunksize.  Pity this caveat is unavoidable.

-- local root_system_cfg = {
-- 	allowed_tree_position = nil,
-- 	allowed_vertical_water_for_tree = nil,
-- 	tree_feature = nil,
-- 	hanging_root_placement_attempts = nil,
-- 	hanging_root_radius = nil,
-- 	hanging_root_content = nil,
-- 	hanging_roots_vertical_span = nil,
-- 	required_vertical_space_for_tree = nil,
-- 	root_column_max_height = nil,
-- 	root_placement_attempts = nil,
-- 	root_radius = nil,
-- 	root_replaceable = nil,
-- 	root_content = nil,
-- 	rng = nil,
-- }

local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local ACCESSIBLE_CONTEXT_SIZE = (mcl_levelgen.REQUIRED_CONTEXT_Y * 16) - 8
local blurb = "[mcl_lush_caves] Generation of azalea tree at %d,%d,%d exhausted vertical context: %d - %d (%d iterations)"
local registered_placed_features = mcl_levelgen.registered_placed_features
local place_one_feature = mcl_levelgen.place_one_feature
local set_block = mcl_levelgen.set_block
local get_block = mcl_levelgen.get_block

local function generate_roots (x, y, y1, z, cfg)
	local rng = cfg.rng
	local attempts = cfg.root_placement_attempts
	local radius = cfg.root_radius
	local replaceable = cfg.root_replaceable
	local content = cfg.root_content

	for y = y, y1 do
		for i = 1, attempts do
			local dx = rng:next_within (radius)
				- rng:next_within (radius)
			local dz = rng:next_within (radius)
				- rng:next_within (radius)
			local x, z = dx + x, dz + z
			if replaceable (x, y, z) then
				local cid, param2 = content (x, y, z)
				set_block (x, y, z, cid, param2)
			end
		end
	end
end

local leaf_air_or_non_walkable_p = mcl_levelgen.leaf_air_or_non_walkable_p
local blurb1 = "Azalea tree generation space tests failed: %d,%d,%d: %s"

local function has_space_for_tree (x, y, z, cfg)
	local required_space = cfg.required_vertical_space_for_tree
	local allowed_water = cfg.allowed_vertical_water_for_tree
	for i = 0, required_space - 1 do
		local cid, _ = get_block (x, y + i, z)
		local is_water = false
		if cid == cid_water_source
			or cid == cid_water_flowing then
			is_water = true
		end
		if (not leaf_air_or_non_walkable_p (cid) or is_water)
		-- Permit the first ALLOWED_WATER blocks to be water
		-- and permit azalea trees to replace leaves.
			and (i >= allowed_water or not is_water) then
			local str = string.format (blurb1, x, y + i, z,
						   core.get_name_from_content_id (cid))
			core.log ("info", str)
			return false
		end
	end
	return true
end

local function generate_tree_and_roots (x, y, z, cfg)
	local tree_pred = cfg.allowed_tree_position
	for dy = 0, cfg.root_column_max_height - 1 do
		local d = (y + dy) - run_maxp.y
		if d > ACCESSIBLE_CONTEXT_SIZE then
			core.log ("info", string.format (blurb, x, y, z, run_minp.y, run_maxp.y, dy))
			-- At least 32 blocks above sea level.
			local requisition = mathmax (64 - y, 0) + 32
			mcl_levelgen.request_additional_context (requisition, 0)
			return false
		end

		if tree_pred (x, y + dy, z)
			and has_space_for_tree (x, y + dy, z, cfg) then
			local tree_feature
				= registered_placed_features[cfg.tree_feature]
			assert (tree_feature)
			place_one_feature (tree_feature, x, y + dy, z)
			generate_roots (x, y, y + dy - 1, z, cfg)
			return true
		end
	end
	return false
end

local is_air = mcl_levelgen.is_air
local face_sturdy_p = mcl_levelgen.face_sturdy_p

local function generate_hanging_roots (x, y, z, cfg, rng)
	local radius = cfg.hanging_root_radius
	local vertical_radius = cfg.hanging_roots_vertical_span
	local content = cfg.hanging_root_content

	for i = 1, cfg.hanging_root_placement_attempts do
		local dx = rng:next_within (radius)
			- rng:next_within (radius)
		local dz = rng:next_within (radius)
			- rng:next_within (radius)
		local dy = rng:next_within (vertical_radius)
			- rng:next_within (vertical_radius)
		local x, y, z = x + dx, y + dy, z + dz

		if is_air (x, y, z) then
			if face_sturdy_p (x, y + 1, z, "y", -1) then
				local cid, param2 = content (x, y, z)
				set_block (x, y, z, cid, param2)
			end
		end
	end
end

local function root_system_place (_, x, y, z, cfg, rng)
	cfg.rng:reseed (rng:next_long ())
	if y <= run_minp.y or y >= run_maxp.y then
		return false
	else
		core.log ("info", string.format ("[mcl_lush_caves]: Azalea tree generating at %d,%d,%d", x, y, z))
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_air then
			return false
		end

		if generate_tree_and_roots (x, y, z, cfg, rng) then
			generate_hanging_roots (x, y, z, cfg, rng)
			core.log ("info", string.format ("[mcl_lush_caves]: Azalea tree generated at %d,%d,%d", x, y, z))
		end
		return true
	end
end

mcl_levelgen.register_feature ("mcl_lush_caves:root_system", {
	place = root_system_place,
})

local tree_placement_flags = {
	place_center_x = true,
	place_center_z = true,
}

local function azalea_tree_place (_, x, y, z, cfg, rng)
	-- This feature purposefully omits the customary vertical
	-- confinement test.
	local schematic = "mcl_lush_caves:azalea_tree_1"
	local aabb = mcl_levelgen.place_schematic (x, y, z, schematic, "random",
						   true, tree_placement_flags,
						   rng)
	mcl_trees.apply_biome_coloration (aabb)
	return true
end

mcl_levelgen.register_feature ("mcl_lush_caves:azalea_tree", {
	place = azalea_tree_place,
})

mcl_levelgen.register_configured_feature ("mcl_lush_caves:azalea_tree", {
	feature = "mcl_lush_caves:azalea_tree",
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:azalea_tree", {
	configured_feature = "mcl_lush_caves:azalea_tree",
	placement_modifiers = {},
})

local replaceable_by_trees = mcl_trees.replaceable_by_trees

local azalea_tree_grows_on = {
	"group:dirt",
	"group:hardened_clay",
	"mcl_core:redsand",
	"mcl_core:sand",
	"mcl_core:snowblock",
	"mcl_powder_snow:powder_snow",
}

local azalea_root_replaceable = {
	"group:deepslate_ore_target",
	"group:hardened_clay",
	"group:stone_ore_target",
	"mcl_core:clay",
	"mcl_core:gravel",
	"mcl_core:redsand",
	"mcl_core:sand",
	"mcl_core:snowblock",
	"mcl_powder_snow:powder_snow",
}

local can_replace = {}
local can_root_replace = {}
local can_grow = {}

for _, cid in ipairs (mcl_levelgen.construct_cid_list (replaceable_by_trees)) do
	can_replace[cid] = true
end
for _, cid in ipairs (mcl_levelgen.construct_cid_list (azalea_tree_grows_on)) do
	can_grow[cid] = true
end
for _, cid in ipairs (mcl_levelgen.construct_cid_list (azalea_root_replaceable)) do
	can_root_replace[cid] = true
end

mcl_levelgen.register_configured_feature ("mcl_lush_caves:rooted_azalea_tree", {
	feature = "mcl_lush_caves:root_system",
	allowed_tree_position = function (x, y, z)
		local cid_here, _ = get_block (x, y, z)
		local cid_below, _ = get_block (x, y - 1, z)
		return can_replace[cid_here] and can_grow[cid_below]
	end,
	allowed_vertical_water_for_tree = 2,
	hanging_root_placement_attempts = 20,
	hanging_root_radius = 3,
	hanging_root_content = function (_, _, _)
		return cid_hanging_roots, 0
	end,
	hanging_roots_vertical_span = 2,
	required_vertical_space_for_tree = 3,
	root_column_max_height = 100,
	root_placement_attempts = 20,
	root_radius = 3,
	root_replaceable = function (x, y, z)
		local cid, _ = get_block (x, y, z)
		return can_root_replace[cid]
	end,
	root_content = function (x, y, z)
		return cid_rooted_dirt, 0
	end,
	tree_feature = "mcl_lush_caves:azalea_tree",
	rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0)),
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:rooted_azalea_tree", {
	configured_feature = "mcl_lush_caves:rooted_azalea_tree",
	placement_modifiers = {
		mcl_levelgen.build_count (uniform_height (1, 2)),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = 1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_position_walkable,
		}),
		mcl_levelgen.build_constant_height_offset (-1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:spore_blossom",

local cid_spore_blossom = core.get_content_id ("mcl_lush_caves:spore_blossom")

mcl_levelgen.register_configured_feature ("mcl_lush_caves:spore_blossom", {
	feature = "mcl_levelgen:simple_block",
	content = function (_, _, _, _)
		return cid_spore_blossom, 0
	end,
})

mcl_levelgen.register_placed_feature ("mcl_lush_caves:spore_blossom", {
	configured_feature = "mcl_lush_caves:spore_blossom",
	placement_modifiers = {
		mcl_levelgen.build_count (TWENTY_FIVE),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		E ({
			allowed_search_condition = mcl_levelgen.is_air,
			direction = 1,
			max_steps = 12,
			target_condition = mcl_levelgen.is_position_walkable,
		}),
		mcl_levelgen.build_constant_height_offset (-1),
		mcl_levelgen.build_in_biome (),
	},
})

-- "mcl_lush_caves:classic_vines_cave_feature",

mcl_levelgen.register_placed_feature ("mcl_lush_caves:classic_vines_cave_feature", {
	configured_feature = "mcl_levelgen:vines",
	placement_modifiers = {
		mcl_levelgen.build_count (TWO_HUNDRED_AND_FIFTY_SIX),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_height_range (uniform_height (OVERWORLD_MIN, 256)),
		mcl_levelgen.build_in_biome (),
	},
})
