local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Trail Ruins processors.
------------------------------------------------------------------------

local cid_suspicious_gravel = 0
local cid_gravel = 0
local cid_dirt = 0
local cid_mud_bricks = 0
local cid_packed_mud = 0
local cid_coarse_dirt = 0

if not mcl_levelgen.is_levelgen_environment then
	core.register_on_mods_loaded (function ()
		cid_suspicious_gravel = core.get_content_id ("mcl_sus_nodes:gravel")
		cid_gravel = core.get_content_id ("mcl_core:gravel")
		cid_dirt = core.get_content_id ("mcl_core:dirt")
		cid_mud_bricks = core.get_content_id ("mcl_mud:mud_bricks")
		cid_packed_mud = core.get_content_id ("mcl_mud:packed_mud")
		cid_coarse_dirt = core.get_content_id ("mcl_core:coarse_dirt")
	end)
else
	cid_suspicious_gravel = core.get_content_id ("mcl_sus_nodes:gravel")
	cid_gravel = core.get_content_id ("mcl_core:gravel")
	cid_dirt = core.get_content_id ("mcl_core:dirt")
	cid_mud_bricks = core.get_content_id ("mcl_mud:mud_bricks")
	cid_packed_mud = core.get_content_id ("mcl_mud:packed_mud")
	cid_coarse_dirt = core.get_content_id ("mcl_core:coarse_dirt")
end

local function degrade_gravel_and_mud_bricks (x, y, z, rng, cid_existing,
					      param2_existing, cid, param2)
	if cid == cid_gravel and rng:next_float () < 0.2 then
		return cid_dirt, 0
	elseif cid == cid_gravel and rng:next_float () < 0.1 then
		return cid_coarse_dirt, 0
	elseif cid == cid_mud_bricks and rng:next_float () < 0.1 then
		return cid_packed_mud, 0
	else
		return cid, param2
	end
end

local decode_node = mcl_levelgen.decode_node
local fisher_yates = mcl_levelgen.fisher_yates
local insert = table.insert
local mathmin = math.min
local mathabs = math.abs
local RARE = 0x100000000

local get_preprocessor_metadata = mcl_levelgen.get_preprocessor_metadata
local current_template_index = mcl_levelgen.current_template_index
local notify_generated = mcl_levelgen.notify_generated

local function post_meta (x, y, z, loot_type, rng)
	local loot_seed = mathabs (rng:next_integer ())
	notify_generated ("mcl_sus_nodes:suspicious_sand_structure_meta",
			  x, y, z, { x, y, z, loot_seed, loot_type, },
			  true)
end

local function process_trail_ruins_archaeology (_, x, y, z, rng, cid_existing,
						param2_existing, cid, param2)
	local idx = current_template_index ()
	local meta = get_preprocessor_metadata ("trail_ruins_archaeology")

	for i = 1, #meta do
		if idx == meta[i] then
			post_meta (x, y, z, "trail_ruins_common", rng)
			return cid_suspicious_gravel, 0
		elseif idx == meta[i] - RARE then
			post_meta (x, y, z, "trail_ruins_rare", rng)
			return cid_suspicious_gravel, 0
		end
	end

	return cid, param2
end

local archeology_processor_meta = {
	__call = process_trail_ruins_archaeology,
}

local function trail_ruins_archaeology_processor (common, rare)
	if mcl_levelgen.is_levelgen_environment then
		local function structure_preprocess (rng, template_or_sid)
			if type (template_or_sid) == "string" then
				return nil, nil
			end

			local template = template_or_sid
			local data = template.nodes
			local gravel = {}

			for i = 1, #data do
				local cid, _ = decode_node (data[i])
				if cid == cid_gravel then
					insert (gravel, i)
				end
			end

			fisher_yates (gravel, rng)
			local n_to_convert = mathmin (common + rare, #gravel)
			if rare > 0 and common < n_to_convert then
				for i = common + 1, n_to_convert do
					gravel[i] = gravel[i] + RARE
				end
			end
			for i = n_to_convert + 1, #gravel do
				gravel[i] = nil
			end
			return "trail_ruins_archaeology", gravel
		end

		local tbl = {
			structure_preprocess = structure_preprocess,
		}
		setmetatable (tbl, archeology_processor_meta)
		return tbl
	else
		return nil
	end
end

local trail_ruins_houses_archaeology = {
	degrade_gravel_and_mud_bricks,
	trail_ruins_archaeology_processor (6, 3),
}

local trail_ruins_roads_archaeology = {
	degrade_gravel_and_mud_bricks,
	trail_ruins_archaeology_processor (2, 0),
}

local trail_ruins_tower_top_archaeology = {
	trail_ruins_archaeology_processor (2, 0),
}

------------------------------------------------------------------------
-- Trail Ruins templates.
------------------------------------------------------------------------

-- Tower structure:

--     SOUTH (+Z)
--
--        [1]     [5]
-- [2]            [4]
--        [3]
--
-- Where:
--
--        [1] = Pool: mcl_levelgen:trail_ruins_roads
--		Name: mcl_levelgen:road_connector
--		Target: mcl_levelgen:long_road_end
--	  [2] = Pool: mcl_levelgen:trail_ruins_tower_additions
--	  	Name: mcl_levelgen:road_anchor
--		Target: mcl_levelgen:road_hall_anchor
--	  [3] = Pool: mcl_levelgen:trail_ruins_roads
--		Name: mcl_levelgen:hall_road
--		Target: minecraft:road_spacer
--	  [4] = Pool: mcl_levelgen:trail_ruins_tower_additions
--		Name: mcl_levelgen:road_anchor
--		Target: minecraft:large_hall_anchor
--	  [5] = Pool: mcl_levelgen:trail_ruins_tower_tower_top
--		Name: mcl_levelgen:tower_bottom_1
--		Target: mcl_levelgen:tower_top_1
--
-- Road structure:
--
--   EAST [1] [4] WEST
--        [2] [5] WEST
--        [3] [6] WEST
--
-- Where:
--
--  [1, 2, 3] = Pool: mcl_levelgen:trail_ruins_buildings
--		Name: mcl_levelgen:road_anchor
--		Target: mcl_levelgen:building_anchor
--  [4, 5, 6] = Pool: mcl_levelgen:trail_ruins_decor
--		Name: mcl_levelgen:road_anchor
--		Target: mcl_levelgen:decor_anchor
--
-- Hall structure:
--
--       SOUTH
--
--         [1]
--   [2]
--         [3]
--
-- Where:
--
-- [1, 2] = Pool: mcl_levelgen:trail_ruins_tower_additions
--	    Name: mcl_levelgen:hall_room_anchor
--	    Target: mcl_levelgen:room_anchor
-- [3]    = Pool: mcl_levelgen:trail_ruins_tower
--	    Name: mcl_levelgen:road_hall_anchor
--	    Target: mcl_levelgen:road_anchor
--
-- Room structure:
--
--       NORTH
--
--        [1]
--
-- Where:
--
--  [1] = Pool: mcl_levelgen:trail_ruins_tower_additions
--	  Name: mcl_levelgen:room_anchor
--	  Target: mcl_levelgen:hall_room_anchor
--
-- Large hall structure:
--
--	[1]
--
--     EAST
--
-- Where:
--
--  [1] = Pool: mcl_levelgen:trail_ruins_tower
--	  Name: mcl_levelgen:large_hall_connector
--	  Anchor: mcl_levelgen:road_anchor
--
-- Group hall structure:
--
--        EAST
--         [1]
--  [2]            [3]
--  [4]            [5]
--
-- Where:
--
-- [1] =           Pool: mcl_levelgen:trail_ruins_roads
--                 Name: mcl_levelgen:building_anchor
--		   Target: mcl_levelgen:road_anchor
-- [2, 3, 4, 5] =  Pool: mcl_levelgen:trail_ruins_buildings_grouped
--		   Name: mcl_levelgen:hall
--		   Target: mcl_levelgen:room
--
-- Room structure:
--
--        EAST
--         [1]
--
-- Where:
--
-- [1] =           Pool: mcl_levelgen:trail_ruins_roads
--                 Name: mcl_levelgen:building_anchor
--		   Target: mcl_levelgen:road_anchor
--
-- Decor structure:
--
--     WEST
--      [1]
--
-- Where:
--
-- [1] =	Pool: mcl_levelgen:trail_ruins_roads
-- 		Name: mcl_levelgen:decor_anchor
-- 		Target: mcl_levelgen:road_anchor

local processors = nil

local function L (template, weight, no_terrain_adaptation)
	return {
		projection = "rigid",
		template = mcl_levelgen.prefix .. "/templates/" .. template .. ".dat",
		weight = weight,
		ground_level_delta = 0,
		no_terrain_adaptation = no_terrain_adaptation,
		processors = processors or {},
	}
end

processors = trail_ruins_houses_archaeology

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_tower", {
	elements = {
		L ("trail_ruins_tower_1", 1),
	},
})

processors = trail_ruins_tower_top_archaeology

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_tower_tower_top", {
	elements = {
		L ("trail_ruins_tower_top_1", 1, true),
	},
})

processors = trail_ruins_houses_archaeology

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_tower_additions", {
	elements = {
		L ("trail_ruins_tower_hall_1", 1),
		L ("trail_ruins_tower_large_hall_1", 1),
		L ("trail_ruins_tower_one_room_1", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_buildings", {
	elements = {
		L ("trail_ruins_buildings_group_hall_1", 1),
		L ("trail_ruins_buildings_large_room_1", 1),
		L ("trail_ruins_buildings_one_room_1", 1),
	},
})

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_buildings_grouped", {
	elements = {
	},
})

processors = trail_ruins_roads_archaeology

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_roads", {
	elements = {
		L ("trail_ruins_roads_long_road_end", 1),
		L ("trail_ruins_roads_road_spacer_1", 1),
		L ("trail_ruins_roads_road_section_1", 1),
		L ("trail_ruins_roads_road_section_2", 1),
		L ("trail_ruins_roads_road_section_3", 1),
	},
})

processors = trail_ruins_houses_archaeology

mcl_levelgen.register_template_pool ("mcl_levelgen:trail_ruins_decor", {
	elements = {
		L ("trail_ruins_decor_decor_1", 1),
	},
})

------------------------------------------------------------------------
-- Trail Ruins structure registration.
------------------------------------------------------------------------

local trail_ruins_biomes = {
	"Jungle",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"SnowyTaiga",
	"Taiga",
}

mcl_levelgen.modify_biome_groups (trail_ruins_biomes, {
	has_trail_ruins = true,
})

local MINUS_FIFTEEN = function (_) return -15 end

mcl_levelgen.register_structure ("mcl_levelgen:trail_ruins", {
	create_start = mcl_levelgen.jigsaw_create_start,
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	terrain_adaptation = "bury",
	start_pool = "mcl_levelgen:trail_ruins_tower",
	max_distance_from_center = 80,
	size = 7,
	start_height = MINUS_FIFTEEN,
	project_start_to_heightmap = "world_surface_wg",
	biomes = mcl_levelgen.build_biome_list ({"#has_trail_ruins",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:trail_ruins", {
	structures = {
		"mcl_levelgen:trail_ruins",
	},
	placement = R (1.0, "default", 34, 8, 83469867, "linear", nil, nil),
})
