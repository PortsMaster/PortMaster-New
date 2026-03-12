local R = mcl_levelgen.build_random_spread_placement
local mcl_levelgen = mcl_levelgen

------------------------------------------------------------------------
-- Ocean Ruins.
------------------------------------------------------------------------

mcl_levelgen.register_loot_table ("mcl_levelgen:ocean_ruins", {
	{
		stacks_min = 2,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 25, amount_min = 1, amount_max=4 },
			{ itemstring = "mcl_farming:wheat_item", weight = 25, amount_min = 2, amount_max=3 },
			{ itemstring = "mcl_core:gold_nugget", weight = 25, amount_min = 1, amount_max=3 },
			--{ itemstring = "mcl_maps:treasure_map", weight = 20, }, --FIXME Treasure map
			{ itemstring = "mcl_books:book", weight = 10, func = function(stack, pr)
				  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "mcl_fishing:fishing_rod_enchanted", weight = 20, func = function(stack, pr)
				  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end  },
			{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_armor:chestplate_leather", weight = 15, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:apple_gold", weight = 20, },
			{ itemstring = "mcl_armor:helmet_gold", weight = 15, amount_min = 1, amount_max = 1 },
			{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
			{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
		},
	},
})

local drowned_staticdata = core.serialize ({
	persistent = true,
	_structure_generation_spawn = true,
})

local function handle_drowned (rng, data, mirroring, rotation, x, y, z, item)
	mcl_levelgen.create_entity (x, y, z, "mobs_mc:drowned", drowned_staticdata)
end

mcl_levelgen.register_data_block_processor ("mcl_levelgen:drowned", handle_drowned)

------------------------------------------------------------------------
-- Ocean Ruin pieces.
------------------------------------------------------------------------

local function L (name)
	local file = mcl_levelgen.prefix
		.. "/templates/" .. name .. ".dat"
	local template, err
		= mcl_levelgen.read_structure_template (file)
	assert (template, err)
	return template
end

local big_cold_ruins
local small_cold_ruins
local big_warm_ruins
local small_warm_ruins

local function init_templates ()
	big_cold_ruins = {
		L ("ocean_ruins_big_cold_1"),
		L ("ocean_ruins_big_cold_2"),
		L ("ocean_ruins_big_cold_3"),
	}
	small_cold_ruins = {
		L ("ocean_ruins_small_cold_1"),
		L ("ocean_ruins_small_cold_2"),
		L ("ocean_ruins_small_cold_3"),
		L ("ocean_ruins_small_cold_4"),
		L ("ocean_ruins_small_cold_5"),
		L ("ocean_ruins_small_cold_5"),
	}
	big_warm_ruins = {
		L ("ocean_ruins_big_warm_1"),
		L ("ocean_ruins_big_warm_2"),
		L ("ocean_ruins_big_warm_3"),
	}
	small_warm_ruins = {
		L ("ocean_ruins_small_warm_1"),
		L ("ocean_ruins_small_warm_2"),
		L ("ocean_ruins_small_warm_3"),
	}
end

if mcl_levelgen.is_levelgen_environment then
	init_templates ()
else
	core.register_on_mods_loaded (init_templates)
end

local function getcid (name)
	if core and mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		-- Content IDs are not required outside level
		-- generation environments.
		return nil
	end
end

local cid_gravel = getcid ("mcl_core:gravel")
local cid_sand = getcid ("mcl_core:sand")
local cid_suspicious_gravel
	= getcid ("mcl_sus_nodes:gravel")
local cid_suspicious_sand
	= getcid ("mcl_sus_nodes:sand")

local is_position_walkable = mcl_levelgen.is_position_walkable
local walkable_p = mcl_levelgen.walkable_p
local set_block = mcl_levelgen.set_block
local post_meta

local function build_gravel_sand_gravity_processor (loot_type)
	return function (x, y, z, rng, cid_existing,
			 param2_existing, cid, param2)
		local level_min = mcl_levelgen.placement_level_min
		if cid == cid_gravel
			or cid == cid_suspicious_gravel
			or cid == cid_sand
			or cid == cid_suspicious_sand
			and not walkable_p (cid_existing) then
			repeat
				y = y - 1
			until y < level_min or is_position_walkable (x, y, z)
			set_block (x, y + 1, z, cid, param2)

			if cid == cid_suspicious_gravel
				or cid == cid_suspicious_sand then
				post_meta (x, y + 1, z, loot_type, rng)
			end
			return nil, nil
		end
		if cid == cid_suspicious_gravel
			or cid == cid_suspicious_sand then
			post_meta (x, y, z, loot_type, rng)
		end
		return cid, param2
	end
end

local cid_mossy_stone_bricks
	= getcid ("mcl_core:stonebrickmossy")
local cid_cracked_stone_bricks
	= getcid ("mcl_core:stonebrickcracked")
local cid_stone_bricks
	= getcid ("mcl_core:stonebrick")
local cid_chiseled_stone_bricks
	= getcid ("mcl_core:stonebrickcarved")

local function decay_processor (x, y, z, rng, cid_existing,
				param2_existing, cid, param2)
	if cid == cid_stone_bricks or cid == cid_chiseled_stone_bricks then
		if rng:next_float () < 0.5 then
			return cid_mossy_stone_bricks, 0
		elseif rng:next_float () < 0.7 then
			return cid_cracked_stone_bricks, 0
		end
	end
	return cid, param2
end

local mathabs = math.abs
local notify_generated = mcl_levelgen.notify_generated

function post_meta (x, y, z, loot_type, rng)
	local loot_seed = mathabs (rng:next_integer ())
	notify_generated ("mcl_sus_nodes:suspicious_sand_structure_meta",
			  x, y, z, { x, y, z, loot_seed, loot_type, },
			  true)
end

local get_preprocessor_metadata = mcl_levelgen.get_preprocessor_metadata
local current_template_index = mcl_levelgen.current_template_index

local function process_ocean_ruins_archaeology (self, x, y, z, rng, cid_existing,
						param2_existing, cid, param2)
	local idx = current_template_index ()
	local meta = get_preprocessor_metadata ("ocean_ruins_archaeology")

	for i = 1, #meta do
		if idx == meta[i] then
			-- Metadata is posted within
			-- `gravel_sand_gravity_processor' so as to
			-- account for gravity.
			return self.replacement, 0
		end
	end

	return cid, param2
end

local archeology_processor_meta = {
	__call = process_ocean_ruins_archaeology,
}

local decode_node = mcl_levelgen.decode_node
local fisher_yates = mcl_levelgen.fisher_yates
local insert = table.insert
local mathmin = math.min
local mathmax = math.max

local function build_archeology_processor (cid_in, replacement, loot_type, n_to_convert)
	local function structure_preprocess (rng, template_or_sid)
		if type (template_or_sid) == "string" then
			return nil, nil
		end

		local template = template_or_sid
		local data = template.nodes
		local nodes = {}

		for i = 1, #data do
			local cid, _ = decode_node (data[i])
			if cid == cid_in then
				insert (nodes, i)
			end
		end

		fisher_yates (nodes, rng)
		local n_to_convert = mathmin (n_to_convert, #nodes)
		for i = n_to_convert + 1, #nodes do
			nodes[i] = nil
		end
		return "ocean_ruins_archaeology", nodes
	end
	local tbl = {
		structure_preprocess = structure_preprocess,
		replacement = replacement,
		loot_type = loot_type,
	}
	setmetatable (tbl, archeology_processor_meta)
	return tbl
end

local ocean_ruin_cold_processors = {
	build_archeology_processor (cid_gravel, cid_suspicious_gravel,
				    "ocean_ruins_cold", 5),
	decay_processor,
	build_gravel_sand_gravity_processor ("ocean_ruins_warm"),
}

local ocean_ruin_warm_processors = {
	build_archeology_processor (cid_sand, cid_suspicious_sand,
				    "ocean_ruins_warm", 5),
	build_gravel_sand_gravity_processor ("ocean_ruins_warm"),
}

local make_template_piece = mcl_levelgen.make_template_piece
local template_transform = mcl_levelgen.template_transform

local function get_one_piece (rng, temp, large, rot, x, z)
	local list, processors
	if temp == "warm" then
		list = large and big_warm_ruins or small_warm_ruins
		processors = ocean_ruin_warm_processors
	else
		list = large and big_cold_ruins or small_cold_ruins
		processors = ocean_ruin_cold_processors
	end
	local template = list[1 + rng:next_within (#list)]
	return make_template_piece (template, x, 90, z, nil, rot, rng,
				    nil, processors, 0, nil)
end

local posns = {}

local function randomize_cluster_poses (cx, cz, rng)
	posns[1] = rng:next_within (7) + 1 - 16 + cx
	posns[2] = rng:next_within (7) + 1 - 16 + cz

	posns[3] = rng:next_within (7) + 1 - 16 + cx
	posns[4] = rng:next_within (7) + 1 + cz

	posns[5] = rng:next_within (7) + 1 - 16 + cx
	posns[6] = rng:next_within (4) + 4 - 16 + cz

	posns[7] = rng:next_within (7) + 1 + cx
	posns[8] = rng:next_within (7) + 1 + 16 + cz

	posns[9] = rng:next_within (7) + 1 + cx
	posns[10] = rng:next_within (2) + 4 - 16 + cz

	posns[11] = rng:next_within (7) + 1 + cx + 16
	posns[12] = rng:next_within (5) + 3 + 16 + cz

	posns[13] = rng:next_within (7) + 1 + cx + 16
	posns[14] = rng:next_within (7) + 1 + cz

	posns[15] = rng:next_within (7) + 1 + cx + 16
	posns[16] = rng:next_within (4) + 4 + cz - 16
end

local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local intersect_2d_p = mcl_levelgen.intersect_2d_p
local arshift = bit.arshift

local function fisher_yates_pairs (tbl, rng)
	local n = arshift (#tbl, 1)
	for i = n - 1, 1, -1 do
		local j = rng:next_within (i + 1)
		tbl[1 + i * 2], tbl[1 + j * 2]
			= tbl[1 + j * 2], tbl[1 + i * 2]
		tbl[2 + i * 2], tbl[2 + j * 2]
			= tbl[2 + j * 2], tbl[2 + i * 2]
	end
	return tbl
end

local function get_ocean_ruin_pieces (self, x, z, rot, rng)
	local large = rng:next_float () <= self.large_probability
	local temp = self.biome_temp
	local pieces = {
		get_one_piece (rng, temp, large, rot, x, z),
	}
	if large and rng:next_float () <= self.cluster_probability then
		local cx, _, cz = template_transform (nil, 15, 0, 15, 0, 0, nil, rot)
		cx = mathmin (cx + x, x)
		cz = mathmin (cz + z, z)

		local parent_bbox = {
			cx, 0, cz, mathmax (cx + x), 1, mathmax (cz + z),
		}

		-- Spawn smaller ruins in up to 9 positions around the
		-- center of this ruin.
		randomize_cluster_poses (cx, cz, rng)
		fisher_yates_pairs (posns, rng)

		local max = 4 + rng:next_within (4)
		for i = 1, 1 + max * 2, 2 do
			local x, z = posns[i], posns[i + 1]
			local rot = random_schematic_rotation (rng)
			local x1, _, z1
				= template_transform (nil, 5, 0, 6, 0, 0, nil, rot)
			if not intersect_2d_p (parent_bbox, mathmin (x1, x),
					       mathmin (z1, z),
					       mathmax (x1, x), mathmin (z1, z)) then
				local real_template
					= get_one_piece (rng, temp, false, rot, x, z)
				insert (pieces, real_template)
			end
		end
	end
	return pieces
end

------------------------------------------------------------------------
-- Ocean Ruins structure.
------------------------------------------------------------------------

local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start
local bbox_center = mcl_levelgen.bbox_center

local function ocean_ruin_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + 8, cz * 16 + 8
	local y = terrain:get_one_height (x, z)

	if structure_biome_test (level, self, x, y, z) then
		local x = x - 8
		local z = z - 8
		local rot = random_schematic_rotation (rng)
		local pieces = get_ocean_ruin_pieces (self, x, z, rot, rng)

		for _, piece in ipairs (pieces) do
			local bbox = piece.bbox
			local height = bbox[5] - bbox[2] + 1
			local x, _, z = bbox_center (bbox)
			local y = terrain:get_one_height (x, z) - 1
			bbox[2] = y
			bbox[5] = y + height - 1
			piece.y = y
		end

		return create_structure_start (self, pieces)
	end
	return nil
end

------------------------------------------------------------------------
-- Ocean Ruins registration.
------------------------------------------------------------------------

local ocean_ruin_cold_biomes = {
	"FrozenOcean",
	"ColdOcean",
	"Ocean",
	"DeepFrozenOcean",
	"DeepColdOcean",
	"DeepOcean",
}

mcl_levelgen.modify_biome_groups (ocean_ruin_cold_biomes, {
	has_ocean_ruin_cold = true,
})

local ocean_ruin_warm_biomes = {
	"LukewarmOcean",
	"WarmOcean",
	"DeepLukewarmOcean",
}

mcl_levelgen.modify_biome_groups (ocean_ruin_warm_biomes, {
	has_ocean_ruin_warm = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:ocean_ruin_cold", {
	biome_temp = "cold",
	biomes = mcl_levelgen.build_biome_list ({"#has_ocean_ruin_cold",}),
	cluster_probability = 0.9,
	create_start = ocean_ruin_create_start,
	large_probability = 0.3,
	step = mcl_levelgen.SURFACE_STRUCTURES,
})

mcl_levelgen.register_structure ("mcl_levelgen:ocean_ruin_warm", {
	biome_temp = "warm",
	biomes = mcl_levelgen.build_biome_list ({"#has_ocean_ruin_warm",}),
	cluster_probability = 0.9,
	create_start = ocean_ruin_create_start,
	large_probability = 0.3,
	step = mcl_levelgen.SURFACE_STRUCTURES,
})

mcl_levelgen.register_structure_set ("mcl_levelgen:ocean_ruins", {
	structures = {
		"mcl_levelgen:ocean_ruin_cold",
		"mcl_levelgen:ocean_ruin_warm",
	},
	placement = R (1.0, "default", 20, 8, 14357621, "linear", nil, nil),
})
