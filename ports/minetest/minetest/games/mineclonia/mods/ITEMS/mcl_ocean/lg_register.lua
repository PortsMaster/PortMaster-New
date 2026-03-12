------------------------------------------------------------------------
-- Kelp.
------------------------------------------------------------------------

local MAX_AGE = 25
local cid_water_source = core.get_content_id ("mcl_core:water_source")
local kelp_surfaces = core.ipc_get ("mcl_ocean:registered_kelp_surfaces")
local kelp_surface_cids = {}
local is_cid_seagrass_or_kelp = {}

for _, surface in ipairs (kelp_surfaces) do
	local node = surface.nodename
	local kelp = "mcl_ocean:kelp_" .. surface.name
	local cid_node = core.get_content_id (node)
	local cid_kelp = core.get_content_id (kelp)
	kelp_surface_cids[cid_node] = cid_kelp
	is_cid_seagrass_or_kelp[cid_kelp] = true
end

local index_heightmap = mcl_levelgen.index_heightmap
local run_minp = mcl_levelgen.placement_run_minp
local run_maxp = mcl_levelgen.placement_run_maxp
local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block
local notify_generated = mcl_levelgen.notify_generated
local convert_level_position = mcl_levelgen.convert_level_position

local function kelp_place (_, x, y, z, cfg, rng)
	local _, ocean = index_heightmap (x, z, false)
	local height = 1 + rng:next_within (10)
	local age = rng:next_within (MAX_AGE + 1)

	if ocean < run_minp.y or ocean > run_maxp.y then
		return false
	else
		local supporting_node, _ = get_block (x, ocean - 1, z)
		local kelp_cid = kelp_surface_cids[supporting_node]

		if kelp_cid then
			for i = 0, height do
				local cid, _ = get_block (x, ocean + i, z)
				height = i
				if cid ~= cid_water_source then
					break
				end
			end

			if height > 0 then
				local param2 = height * 16
				set_block (x, ocean - 1, z, kelp_cid, param2)
				local x, y, z = convert_level_position (x, ocean - 1, z)
				notify_generated ("mcl_ocean:kelp_age", {
					x, y, z, age,
				}, true)
			end
		end
	end
end

mcl_levelgen.register_feature ("mcl_ocean:kelp", {
	place = kelp_place,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:kelp", {
	feature = "mcl_ocean:kelp",
})

mcl_levelgen.register_placed_feature ("mcl_ocean:kelp_warm", {
	configured_feature = "mcl_ocean:kelp",
	placement_modifiers = {
		mcl_levelgen.build_noise_based_count (80, 80.0, 0),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:kelp_cold", {
	configured_feature = "mcl_ocean:kelp",
	placement_modifiers = {
		mcl_levelgen.build_noise_based_count (120, 80.0, 0),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Seagrass.
------------------------------------------------------------------------

local THIRTY_TWO = function (_) return 32 end
local FOURTY = function (_) return 40 end
local FOURTY_EIGHT = function (_) return 48 end
local EIGHTY = function (_) return 80 end
local SIXTY_FOUR = function (_) return 64 end

local seagrass_surfaces = core.ipc_get ("mcl_ocean:seagrass_surfaces")
local seagrass_surface_cids = {}

for _, surface in ipairs (seagrass_surfaces) do
	local node = surface[2]
	local kelp = "mcl_ocean:seagrass_" .. surface[1]
	local cid_node = core.get_content_id (node)
	local cid_kelp = core.get_content_id (kelp)
	seagrass_surface_cids[cid_node] = cid_kelp
	is_cid_seagrass_or_kelp[cid_kelp] = true
end

local function seagrass_place (self, x, y, z, cfg, rng)
	local _, ocean = index_heightmap (x, z, false)
	local is_tall = rng:next_float ()
	local simple = self.simple
	local dx = simple and 0 or (rng:next_within (8) - rng:next_within (8))
	local dz = simple and 0 or (rng:next_within (8) - rng:next_within (8))

	if ocean < run_minp.y or ocean > run_maxp.y then
		return false
	else
		local x, z = x + dx, z + dz
		local supporting_node, _ = get_block (x, ocean - 1, z)
		local seagrass_cid = seagrass_surface_cids[supporting_node]

		if seagrass_cid then
			local cid, _ = get_block (x, ocean, z)
			if cid == cid_water_source then
				-- TODO: tall seagrass.
				if false and is_tall < cfg.probability then
					local cid_above, _ = get_block (x, ocean + 1, z)
					if cid_above == cid_water_source then
						set_block (x, ocean - 1, seagrass_cid, 0)
						return true
					end
				else
					set_block (x, ocean - 1, z, seagrass_cid, 3)
					return true
				end
			end
		end
	end
	return false
end

mcl_levelgen.register_feature ("mcl_ocean:seagrass", {
	place = seagrass_place,
	simple = false,
})

mcl_levelgen.register_feature ("mcl_ocean:seagrass_simple", {
	place = seagrass_place,
	simple = true,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:seagrass_tall", {
	feature = "mcl_ocean:seagrass",
	probability = 1.0,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:seagrass_mid", {
	feature = "mcl_ocean:seagrass",
	probability = 0.6,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:seagrass_slightly_less_short", {
	feature = "mcl_ocean:seagrass",
	probability = 0.4,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:seagrass_short", {
	feature = "mcl_ocean:seagrass",
	probability = 0.3,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:seagrass_simple", {
	feature = "mcl_ocean:seagrass_simple",
	probability = 0.0,
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_cold", {
	configured_feature = "mcl_ocean:seagrass_short",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (THIRTY_TWO),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_deep_cold", {
	configured_feature = "mcl_ocean:seagrass_tall",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (FOURTY),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_deep", {
	configured_feature = "mcl_ocean:seagrass_tall",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (FOURTY_EIGHT),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_deep_warm", {
	configured_feature = "mcl_ocean:seagrass_tall",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (EIGHTY),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_normal", {
	configured_feature = "mcl_ocean:seagrass_short",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (FOURTY_EIGHT),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_river", {
	configured_feature = "mcl_ocean:seagrass_slightly_less_short",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (FOURTY_EIGHT),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_simple", {
	configured_feature = "mcl_ocean:seagrass_slightly_less_short",
	placement_modifiers = {
		-- minecraft:seagrass_simple is never placed as it
		-- specifies a liquid carving mask, but liquid carvers
		-- are no longer utilized.
		--
		-- See: https://bugs.mojang.com/browse/MC-262498
		function (_, _, _, _)
			return nil
		end,
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_swamp", {
	configured_feature = "mcl_ocean:seagrass_mid",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (SIXTY_FOUR),
		mcl_levelgen.build_in_biome (),
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:seagrass_warm", {
	configured_feature = "mcl_ocean:seagrass_short",
	placement_modifiers = {
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_count (EIGHTY),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Abstract coral feature.
------------------------------------------------------------------------

local coral_types = {}
local cid_coral_blocks = {}
local cid_coral_fans = {}
local cid_corals = {}
local is_cid_coral_attached = {}
local is_cid_coral_block = {}

local overworld = mcl_levelgen.overworld_preset
local factory = overworld.factory ("mcl_ocean:coral_placement"):fork_positional ()
local coral_rng = factory:create_reseedable ()
local types = core.ipc_get ("mcl_ocean:coral_types")

for _, coraltype in pairs (types) do
	local name = coraltype[1]
	local name_coral_block = table.concat ({"mcl_ocean:", name, "_coral_block"})
	local name_coral_fan = table.concat ({"mcl_ocean:", name, "_coral_fan"})
	local name_coral = table.concat ({"mcl_ocean:", name, "_coral"})
	local name_sea_pickle_1
		= table.concat ({"mcl_ocean:sea_pickle_1_", name, "_coral_block"})
	local name_sea_pickle_2
		= table.concat ({"mcl_ocean:sea_pickle_2_", name, "_coral_block"})
	local name_sea_pickle_3
		= table.concat ({"mcl_ocean:sea_pickle_3_", name, "_coral_block"})
	local name_sea_pickle_4
		= table.concat ({"mcl_ocean:sea_pickle_4_", name, "_coral_block"})
	local typedesc = {
		cid_coral_block = core.get_content_id (name_coral_block),
		cid_coral_fan = core.get_content_id (name_coral_fan),
		cid_coral = core.get_content_id (name_coral),
		cid_sea_pickles = {
			core.get_content_id (name_sea_pickle_1),
			core.get_content_id (name_sea_pickle_2),
			core.get_content_id (name_sea_pickle_3),
			core.get_content_id (name_sea_pickle_4),
		},
	}
	table.insert (coral_types, typedesc)
	table.insert (cid_coral_blocks, typedesc.cid_coral_block)
	table.insert (cid_coral_fans, typedesc.cid_coral_fan)
	table.insert (cid_corals, typedesc.cid_coral)
	is_cid_coral_attached[typedesc.cid_coral_fan] = true
	is_cid_coral_attached[typedesc.cid_coral] = true
	is_cid_coral_block[typedesc.cid_coral_block] = true
	for i = 1, 4 do
		is_cid_coral_attached[typedesc.cid_sea_pickles[i]] = true
	end
end

local function coral_place (self, x, y, z, cfg, rng)
	coral_rng:reseed_positional (x, y, z)
	if y < run_minp.y or y > run_maxp.y or #coral_types == 0 then
		return false
	else
		local cid_below, _ = get_block (x, y - 1, z)
		if is_cid_coral_attached[cid_below]
			or is_cid_coral_block[cid_below] then
			return false
		end
		local idx = 1 + coral_rng:next_within (#coral_types)
		return self:place_coral_decoration (x, y, z, coral_rng,
						    coral_types[idx])
	end
end

local function coral_block_place (x, y, z, rng, desc)
	local cid_above, _ = get_block (x, y + 1, z)
	local cid_below, _ = get_block (x, y - 1, z)
	if cid_above == cid_water_source
		and not is_cid_seagrass_or_kelp[cid_below]
		and not is_cid_coral_attached[cid_below] then
		-- There is generally a 25% chance that a coral will
		-- generate with a coral and a 3.75% chance of
		-- generating with a sea pickle above.  The engine
		-- isn't sophisticated enough properly to support wall
		-- coral blocks, so instead they are assigned a 10%
		-- chance of replacing any coral that is generated.

		if rng:next_float () < 0.25 then
			if rng:next_float () < 0.10 then
				set_block (x, y, z, desc.cid_coral_fan, 0)
			else
				set_block (x, y, z, desc.cid_coral, 0)
			end
		elseif rng:next_float () < 0.05 then
			local cids = desc.cid_sea_pickles
			local cid_pickle = cids[1 + rng:next_within (#cids)]
			set_block (x, y, z, cid_pickle, 0)
		else
			set_block (x, y, z, desc.cid_coral_block, 0)
		end

		return true
	end
	return false
end

------------------------------------------------------------------------
-- Coral "claws".
------------------------------------------------------------------------

local fix_lighting = mcl_levelgen.fix_lighting

local function dir (x, y, z, cw, ccw)
	return { x, y, z, cw, ccw, }
end

local dirs = {
	dir (0, 0, 1, 4, 3, 2), -- 1 South
	dir (0, 0, -1, 3, 4, 1), -- 2 North
	dir (1, 0, 0, 1, 2, 4), -- 3 East
	dir (-1, 0, 0, 2, 1, 3), -- 4 West
	dir (0, 1, 0, nil, nil, 6), -- 5 Up
	dir (0, -1, 0, nil, nil, 5), -- 6 Down
}

local permutations = {
	{ 1, 2, 3, },
	{ 1, 3, 2, },
	{ 2, 1, 3, },
	{ 2, 3, 1, },
	{ 3, 1, 2, },
	{ 3, 2, 1, },
}
local nperms = #permutations

local function add_dir (x, y, z, dir)
	return x + dir[1], y + dir[2], z + dir[3]
end

local function build_coral_digit (x, y, z, dir_id, local_dirs, rng, desc)
	local length = 2 + rng:next_within (2)
	local dir = local_dirs[dir_id]
	local dir1, len1 = dir

	x, y, z = add_dir (x, y, z, dir)
	if dir_id == 1 then
		-- This is the main trunk.
		len1 = 2 + rng:next_within (3)
	else
		-- Other trunks should be assigned a chance of
		-- branching upwards.
		y = y + 1
		dir1 = rng:next_boolean () and dirs[5] or dir
		len1 = 3 + rng:next_within (3)
	end

	for i = 1, length do
		if not coral_block_place (x, y, z, rng, desc) then
			break
		end
		if i ~= length then
			x, y, z = add_dir (x, y, z, dir1)
		end
	end

	-- Branch upwards.
	y = y + 1

	-- Move in the original direction.
	for i = 1, len1 do
		x, y, z = add_dir (x, y, z, local_dirs[1])
		if not coral_block_place (x, y, z, rng, desc) then
			break
		end
		if rng:next_float () < 0.25 then
			y = y + 1
		end
	end
end

local function place_claw_coral_decoration (self, x, y, z, rng, desc)
	if not coral_block_place (x, y, z, rng, desc) then
		return false
	else
		-- Select a random direction and two additional
		-- perpendicular directions in which to create coral
		-- branches.

		local dir_1 = dirs[1 + rng:next_within (4)]
		local dir_2 = dirs[dir_1[4]]
		local dir_3 = dirs[dir_1[5]]
		local dirs = { dir_1, dir_2, dir_3, }
		local permutation
			= permutations[1 + rng:next_within (nperms)]

		build_coral_digit (x, y, z, permutation[1], dirs, rng, desc)
		build_coral_digit (x, y, z, permutation[2], dirs, rng, desc)
		if rng:next_boolean () then
			build_coral_digit (x, y, z, permutation[3], dirs, rng, desc)
		end
		fix_lighting (x - 9, y, z - 9, x + 8, y + 9, z + 9)
		return true
	end
end

mcl_levelgen.register_feature ("mcl_ocean:coral_claw", {
	place = coral_place,
	place_coral_decoration = place_claw_coral_decoration,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:coral_claw", {
	feature = "mcl_ocean:coral_claw",
})

------------------------------------------------------------------------
-- Coral "trees".
------------------------------------------------------------------------

local fisher_yates = mcl_levelgen.fisher_yates

local function place_tree_coral_decoration (self, x, y, z, rng, desc)
	local trunkheight = 1 + rng:next_within (3)
	for i = 1, trunkheight do
		if not coral_block_place (x, y, z, rng, desc) then
			break
		end
		y = y + 1
	end

	local sx, sy, sz = x, y, z
	local directions = {
		dirs[1],
		dirs[2],
		dirs[3],
		dirs[4],
	}
	fisher_yates (directions, rng)

	for i = 1, 2 + rng:next_within (2) do
		local branchdir = dirs[i]
		local branchsize = 2 + rng:next_within (5)
		x, y, z = add_dir (sx, sy, sz, branchdir)
		local last_moved = 1
		for i = 1, branchsize do
			if not coral_block_place (x, y, z, rng, desc) then
				break
			end
			y = y + 1
			if i == 1 or (i - last_moved >= 2 and rng:next_float () < 0.25) then
				x, y, z = add_dir (x, y, z, branchdir)
				last_moved = i
			end
		end
	end
	fix_lighting (x - 9, y, z - 9, x + 9, y, z + 9)
	return true
end

mcl_levelgen.register_feature ("mcl_ocean:coral_tree", {
	place = coral_place,
	place_coral_decoration = place_tree_coral_decoration,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:coral_tree", {
	feature = "mcl_ocean:coral_tree",
})

------------------------------------------------------------------------
-- Coral "mushroom".
------------------------------------------------------------------------

local function place_mushroom_coral_decoration (self, x, y, z, rng, desc)
	local rx = 3 + rng:next_within (3)
	local ry = 3 + rng:next_within (3)
	local rz = 3 + rng:next_within (3)
	local yoff = 1 + rng:next_within (1)

	for dx = 0, rx do
		local dx_at_edge = dx == 0 or dx == rx
		for dy = 0, ry do
			local dy_at_edge = dy == 0 or dy == ry
			for dz = 0, rz do
				local dz_at_edge = dz == 0 or dz == rz

				if (not dx_at_edge or not dy_at_edge)
					and (not dz_at_edge or not dy_at_edge)
					and (not dx_at_edge or not dz_at_edge)
					and (dx_at_edge or dz_at_edge or dy_at_edge) then
					if rng:next_float () < 0.9 then
						coral_block_place (x + dx, y + dy + yoff, z + dz,
								   rng, desc)
					end
				end
			end
		end
	end
end

mcl_levelgen.register_feature ("mcl_ocean:coral_mushroom", {
	place = coral_place,
	place_coral_decoration = place_mushroom_coral_decoration,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:coral_mushroom", {
	feature = "mcl_ocean:coral_mushroom",
})

mcl_levelgen.register_configured_feature ("mcl_ocean:warm_ocean_vegetation", {
	feature = "mcl_levelgen:simple_random_selector",
	features = {
		{
			configured_feature = "mcl_ocean:coral_claw",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_ocean:coral_tree",
			placement_modifiers = {},
		},
		{
			configured_feature = "mcl_ocean:coral_mushroom",
			placement_modifiers = {},
		},
	},
})

mcl_levelgen.register_placed_feature ("mcl_ocean:warm_ocean_vegetation", {
	configured_feature = "mcl_ocean:warm_ocean_vegetation",
	placement_modifiers = {
		mcl_levelgen.build_noise_based_count (20, 400.0, 0),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})

------------------------------------------------------------------------
-- Sea Pickles.
------------------------------------------------------------------------

local TWENTY = function (_) return 20 end

local sea_pickles = core.ipc_get ("mcl_ocean:sea_pickles")
local sea_pickle_cids = {}

for base, pickle in pairs (sea_pickles) do
	local base = core.get_content_id (base)
	local pickles = {}
	local def = core.registered_nodes[pickle]
	while def do
		local cid = core.get_content_id (pickle)
		is_cid_seagrass_or_kelp[cid] = true
		table.insert (pickles, cid)
		pickle = def._mcl_sea_pickle_next
		def = pickle and core.registered_nodes[pickle] or nil
	end
	assert (#pickles >= 4)
	sea_pickle_cids[base] = pickles
end

local mathmin = math.min
local mathmax = math.max
local huge = math.huge

local function sea_pickle_place (_, x, y, z, cfg, rng)
	if y < run_minp.y or y > run_maxp.y then
		return false
	else
		local ymin = huge
		local ymax = -huge
		local count = cfg.count (rng)
		for i = 1, count do
			local dx = rng:next_within (8) - rng:next_within (8)
			local dz = rng:next_within (8) - rng:next_within (8)
			local x, z = x + dx, z + dz
			local _, y = index_heightmap (x, z, false)
			local cid_below, _ = get_block (x, y - 1, z)
			local pickles = sea_pickle_cids[cid_below]
			if pickles then
				local cid, _ = get_block (x, y, z)
				if cid == cid_water_source then
					local pickle = 1 + rng:next_within (4)
					set_block (x, y - 1, z, pickles[pickle], 0)
				end
				ymin = mathmin (ymin, y - 1)
				ymax = mathmax (ymax, y + 1)
			end
		end
		fix_lighting (x - 8, ymin, z - 8, x + 8, ymax, z + 8)
	end
end

mcl_levelgen.register_feature ("mcl_ocean:sea_pickle", {
	place = sea_pickle_place,
})

mcl_levelgen.register_configured_feature ("mcl_ocean:sea_pickle", {
	feature = "mcl_ocean:sea_pickle",
	count = TWENTY,
})

mcl_levelgen.register_placed_feature ("mcl_ocean:sea_pickle", {
	configured_feature = "mcl_ocean:sea_pickle",
	placement_modifiers = {
		mcl_levelgen.build_rarity_filter (16),
		mcl_levelgen.build_in_square (),
		mcl_levelgen.build_heightmap ("motion_blocking"),
		mcl_levelgen.build_in_biome (),
	},
})
