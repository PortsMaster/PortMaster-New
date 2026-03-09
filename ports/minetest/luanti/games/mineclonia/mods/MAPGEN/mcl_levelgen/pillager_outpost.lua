local R = mcl_levelgen.build_random_spread_placement
local mathabs = math.abs

------------------------------------------------------------------------
-- Pillager outpost callbacks.
------------------------------------------------------------------------

local pillager_outpost_loot = {
	{
		stacks_min = 2,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 3, amount_max=5 },
			{ itemstring = "mcl_farming:carrot_item", weight = 5, amount_min = 3, amount_max=5 },
			{ itemstring = "mcl_farming:potato_item", weight = 5, amount_min = 2, amount_max=5 },
		}
	},
	{
		stacks_min = 1,
		stacks_max = 2,
		items = {
			{ itemstring = "mcl_experience:bottle", weight = 6, amount_min = 0, amount_max=1 },
			{ itemstring = "mcl_bows:arrow", weight = 4, amount_min = 2, amount_max=7 },
			{ itemstring = "mcl_mobitems:string", weight = 4, amount_min = 1, amount_max=6 },
			{ itemstring = "mcl_core:iron_ingot", weight = 3, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_books:book", weight = 1, func = function(stack, pr)
				  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "mcl_armor:sentry"},
		},
	},
	{
		stacks_min = 1,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_trees:tree_dark_oak", amount_min = 2, amount_max=3 },
		},
	},
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_bows:crossbow" },
		},
	},
}

if not mcl_levelgen.is_levelgen_environment
	and mcl_levelgen.register_notification_handler then

	local v = vector.zero ()
	local level_to_minetest_position
		= mcl_levelgen.level_to_minetest_position

	local function handle_outpost_mobs (_, data)
		v.x, v.y, v.z
			= level_to_minetest_position (data.x, data.y, data.z)
		if data.schematic_type == "mcl_levelgen:pillager_outpost_cage_1" then
			v.y = v.y - 0.5
			core.add_entity (v, "mobs_mc:iron_golem")
		else
			local pr = PcgRandom (data.random_seed)
			local n = pr:next (1, 3)

			for i = 1, n do
				core.add_entity (v, "mobs_mc:parrot")
			end
		end
	end

	local function handle_outpost_loot (_, data)
		local pr = PcgRandom (data.loot_seed)
		v.x, v.y, v.z = level_to_minetest_position (data.x, data.y, data.z)
		mcl_structures.construct_nodes (v, v, {
			"mcl_chests:chest_small",
		})
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()
		if core.get_node (v).name == "mcl_chests:chest_small" then
			local items = mcl_loot.get_multi_loot (pillager_outpost_loot, pr)
			mcl_loot.fill_inventory (inv, "main", items, pr)
		end
	end

	local modpath = mcl_levelgen.prefix
	local schematics = {
		"pillager_outpost_tower_short",
		"pillager_outpost_tower_tall",
		"pillager_outpost_tent",
		"pillager_outpost_cage_1",
		"pillager_outpost_cage_2",
		"pillager_outpost_scarecrow",
	}
	for _, schem in ipairs (schematics) do
		local id = "mcl_levelgen:" .. schem
		local name = modpath
			.. "/schematics/mcl_levelgen_"
			.. schem .. ".mts"
		mcl_levelgen.register_portable_schematic (id, name, true)
	end

	mcl_levelgen.register_notification_handler ("mcl_levelgen:pillager_outpost_mobs",
						    handle_outpost_mobs)
	mcl_levelgen.register_notification_handler ("mcl_levelgen:pillager_outpost_loot",
						    handle_outpost_loot)
end

------------------------------------------------------------------------
-- Pillager outpost.
------------------------------------------------------------------------

local cid_chest_small

local function initialize_cids ()
	cid_chest_small = core.get_content_id ("mcl_chests:chest_small")
end

if core.register_on_mods_loaded then
	core.register_on_mods_loaded (initialize_cids)
else
	initialize_cids ()
end

local notify_generated = mcl_levelgen.notify_generated
local bbox_center = mcl_levelgen.bbox_center

local function placement_sentinel (piece, rng, _, _, _, _)
	local schematic = piece.schematic

	if schematic == "mcl_levelgen:pillager_outpost_cage_1"
		or schematic == "mcl_levelgen:pillager_outpost_cage_2" then
		local x, _, z = bbox_center (piece.bbox)
		local y = piece.bbox[2]
		notify_generated ("mcl_levelgen:pillager_outpost_mobs", x, y, z, {
			schematic_type = schematic,
			random_seed = mathabs (rng:next_integer ()),
			x = x,
			y = y,
			z = z,
		})
	end
end

local make_schematic_piece = mcl_levelgen.make_schematic_piece

local function loot_processor (x, y, z, rng, cid_existing,
			       param2_existing, cid, param2)
	if cid == cid_chest_small then
		notify_generated ("mcl_levelgen:pillager_outpost_loot", x, y, z, {
			loot_seed = mathabs (rng:next_integer ()),
			x = x,
			y = y,
			z = z,
		})
	end
	return cid, param2
end

local TOWER_PROCESSORS = {
	mcl_levelgen.wall_update_processor (),
	loot_processor,
}

local function select_tower_piece (terrain, x, y, z, rng)
	local dx = rng:next_within (32) - 16
	local dz = rng:next_within (32) - 16
	local x = dx + x
	local z = dz + z
	local y = terrain:get_one_height (x, z)

	if rng:next_boolean () then
		return make_schematic_piece ("mcl_levelgen:pillager_outpost_tower_short",
					     x, y, z, "random", rng, true, true,
					     TOWER_PROCESSORS, placement_sentinel, nil)
	else
		return make_schematic_piece ("mcl_levelgen:pillager_outpost_tower_tall",
					     x, y, z, "random", rng, true, true,
					     TOWER_PROCESSORS, placement_sentinel, nil)
	end
end

local offsets = {
	{ -12, 12, },
	{ 12, 12, },
	{ 16, -12, },
}

local schematics = {
	"mcl_levelgen:pillager_outpost_tent",
	"mcl_levelgen:pillager_outpost_cage_2",
	"mcl_levelgen:pillager_outpost_cage_1",
}

local function unpack2 (x)
	return x[1], x[2]
end

local any_collisions = mcl_levelgen.any_collisions

local function select_feature_piece (tower, terrain, pieces, rng, heightcache)
	local rotation = tower.rotation
	local idx = 1 + rng:next_within (3)
	local x, z = unpack2 (offsets[idx])

	if rotation == "90" then
		x, z = z, -x
	elseif rotation == "180" then
		x, z = -x, -z
	elseif rotation == "270" then
		x, z = -z, x
	end

	local bbox = tower.bbox
	if x < 0 then
		x = bbox[1] + x
	else
		x = bbox[4] + x
	end
	if z < 0 then
		z = bbox[3] + z
	else
		z = bbox[6] + z
	end

	local height = heightcache[idx]
	if height then
		-- Cage or tent already placed.  Scatter scarecrows
		-- around.
		local dx = rng:next_within (4) - 6
		local dz = rng:next_within (4) - 6
		local piece = make_schematic_piece ("mcl_levelgen:pillager_outpost_scarecrow",
						    x + dx, height, z + dz, rotation,
						    rng, true, true, nil, nil, nil)
		if not any_collisions (pieces, piece.bbox) then
			return piece
		else
			return nil
		end
	else
		local height = terrain:get_one_height (x, z)
		heightcache[idx] = height
		local selector = 1 + rng:next_within (3)
		return make_schematic_piece (schematics[selector], x, height,
					     z, "random", rng, true, true, nil,
					     placement_sentinel, nil)
	end
end

local insert = table.insert

local function assemble_pillager_outpost (terrain, x, y, z, rng)
	local piece = select_tower_piece (terrain, x, y, z, rng)
	local pieces = { piece, }
	-- 8 to 10 features.
	local num_features = 8 + rng:next_within (3)
	local heightcache = {}
	for i = 1, num_features do
		local piece = select_feature_piece (piece, terrain, pieces,
						    rng, heightcache)
		if piece then
			insert (pieces, piece)
		end
	end
	return pieces
end

------------------------------------------------------------------------
-- Pillager outpost registration.
------------------------------------------------------------------------

local pillager_outpost_biomes = {
	"Desert",
	"Plains",
	"Savannah",
	"SnowyPlains",
	"Taiga",
	"#is_mountain",
	"Grove",
}

mcl_levelgen.modify_biome_groups (pillager_outpost_biomes, {
	has_pillager_outpost = true,
})

local structure_biome_test = mcl_levelgen.structure_biome_test
local bbox_from_pieces = mcl_levelgen.bbox_from_pieces

local function spawn_piece_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Nothing here but crickets.
end

mcl_levelgen.register_structure ("mcl_levelgen:pillager_outpost", {
	create_start = function (self, level, terrain, rng, cx, cz)
		local x, z = cx * 16, cz * 16
		local height = terrain:get_one_height (x, z)

		if structure_biome_test (level, self, x, height, z) then
			local pieces = assemble_pillager_outpost (terrain, x, height, z, rng)
			-- Create a piece encompassing a 72x52x72 area
			-- around the center of the structure for
			-- purposes of spawning.
			local bbox = bbox_from_pieces (pieces)
			local cx, _, cz = bbox_center (bbox)
			bbox[1] = cx - 35
			bbox[2] = height - 12
			bbox[3] = cz - 35
			bbox[4] = cx + 36
			bbox[5] = height + 39
			bbox[6] = cz + 36
			insert (pieces, {
				bbox = bbox,
				place = spawn_piece_place,
				no_terrain_adaptation = true,
			})
			return mcl_levelgen.create_structure_start (self, pieces)
		end
		return nil
	end,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_pillager_outpost",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:pillager_outposts", {
	structures = {
		"mcl_levelgen:pillager_outpost",
	},
	placement = R (0.2, "legacy_type_1", 32, 8, 165745296,
		       "linear", nil, { "mcl_villages:villages", 10, }),
})
