local mcl_levelgen = mcl_levelgen
local R = mcl_levelgen.build_random_spread_placement
local ipairs = ipairs
local pairs = pairs

------------------------------------------------------------------------
-- Village templates.
------------------------------------------------------------------------

local schematic_meta

local function load_schematic (id)
	assert (schematic_meta[id])
	local meta = schematic_meta[id]
	return {
		schematic = id,
		connecting = meta.connecting,
		exits = meta.exits,
		beds = meta.beds,
		pois = meta.pois,
		bell = meta.bell,
		bell_spawn = meta.bell_spawn,
	}
end

local village_template = {
	meeting_points = {},
	job_buildings = {},
	house_buildings = {},
	street_decor = {},
	farms = {},
	well = {},
	piles = {},
}

local plains_village_template = table.copy (village_template)
local desert_village_template = table.copy (village_template)
local snowy_village_template = table.copy (village_template)
local savannah_village_template = table.copy (village_template)
local taiga_village_template = table.copy (village_template)

-- Each component in a template should identify a portable schematic,
-- a "connecting" position and orientation, and possibly a list of
-- exit positions to which other types of components may attach with
-- their "connecting" positions rotated to contact the source's exit.

local function initialize_village_template (template, src)
	for _, schematic in ipairs (src.meeting_points) do
		table.insert (template.meeting_points,
			      load_schematic (schematic))
	end

	for _, schematic in ipairs (src.job_buildings) do
		table.insert (template.job_buildings,
			      load_schematic (schematic))
	end

	for _, schematic in ipairs (src.house_buildings) do
		table.insert (template.house_buildings,
			      load_schematic (schematic))
	end

	for _, schematic in ipairs (src.street_decor) do
		table.insert (template.street_decor,
			      load_schematic (schematic))
	end

	for _, schematic in ipairs (src.farms) do
		table.insert (template.farms,
			      load_schematic (schematic))
	end

	for _, schematic in ipairs (src.well) do
		table.insert (template.well,
			      load_schematic (schematic))
	end

	for _, pile in ipairs (src.piles) do
		assert (type (pile) == "string")
		table.insert (template.piles, pile)
	end
end

local function initialize_village_templates ()
	local village_templates
		= core.ipc_get ("mcl_villages:village_templates")
	schematic_meta = core.ipc_get ("mcl_villages:schematic_meta")
	local variants = {
		{"plains", plains_village_template,},
		{"desert", desert_village_template,},
		{"snowy", snowy_village_template,},
		{"savannah", savannah_village_template,},
		{"taiga", taiga_village_template,},
	}
	for _, variant in ipairs (variants) do
		local name = variant[1]
		initialize_village_template (variant[2], village_templates[name])
	end
end

if mcl_levelgen.is_levelgen_environment then
	initialize_village_templates ()
else
	core.register_on_mods_loaded (initialize_village_templates)
end

------------------------------------------------------------------------
-- Village path piece.
------------------------------------------------------------------------

local floor = math.floor
local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs
-- local mathsqrt = math.sqrt

local index_heightmap = mcl_levelgen.index_heightmap
local village_type = nil
local village_processors = nil

local ipos3 = mcl_levelgen.ipos3
local set_block = mcl_levelgen.set_block
local get_block = mcl_levelgen.get_block

local cid_wood_oak = core.get_content_id ("mcl_trees:wood_oak")
local cid_dirt_path = core.get_content_id ("mcl_core:grass_path")
local cid_water_source = core.get_content_id ("mcl_core:water_source")
local cid_smooth_sandstone = core.get_content_id ("mcl_core:sandstonesmooth2")

local function village_path_place (self, level, terrain, rng,
				   x1, z1, x2, z2)
	local bbox = self.bbox
	local village_type = self.village_type
	for x, _, z in ipos3 (mathmax (bbox[1], x1),
			      0,
			      mathmax (bbox[3], z1),
			      mathmin (bbox[4], x2),
			      0,
			      mathmin (bbox[6], z2)) do
		local surface, _ = index_heightmap (x, z, true)
		local cid, _ = get_block (x, surface - 1, z)

		if cid == cid_water_source then
			set_block (x, surface - 1, z, cid_wood_oak, 0)
		elseif village_type ~= "desert" then
			if rng:next_float () < 0.86 then
				set_block (x, surface - 1, z, cid_dirt_path, 0)
			end
		else
			set_block (x, surface - 1, z, cid_smooth_sandstone, 0)
		end
	end
end

------------------------------------------------------------------------
-- Village processors and callbacks.
------------------------------------------------------------------------

local cid_dirt = core.get_content_id ("mcl_core:dirt")
local cid_grass = core.get_content_id ("mcl_core:dirt_with_grass")

local is_cid_dirt = mcl_levelgen.is_cid_dirt
local registered_biomes = mcl_levelgen.registered_biomes
local index_biome = mcl_levelgen.index_biome

local function preserve_grass (x, y, z, rng, cid_existing, param2_existing,
			       cid, param2)
	if cid == cid_dirt and is_cid_dirt[cid_existing] then
		return nil, nil
	elseif cid == cid_grass then
		local biome = index_biome (x, y, z)
		local def = registered_biomes[biome]
		return cid, def.grass_palette_index
	end
	return cid, param2
end

local weighted_crops = core.ipc_get ("mcl_villages:crop_types") or {}

local cid_processed = {}
local cid_crops = {}
local crop_cids = {}

for biome, list in pairs (weighted_crops) do
	for crop_type, weights in pairs (list) do
		local new_weights = {}
		local total_weight = 0
		for _, value in ipairs (weights) do
			local key = value.node
			local weight = value.total
			local cid = core.get_content_id (key)
			local def = core.registered_nodes[key]
			local param2 = def.place_param2 or 0
			table.insert (new_weights, {
				cid, param2, weight,
			})
			total_weight = total_weight + weight
		end
		list[crop_type] = {
			total_weight,
			unpack (new_weights)
		}
		for group = 1, 8 do
			local name = string.format ("mcl_villages:crop_%s_%d",
						    crop_type, group)
			local cid = core.get_content_id (name)
			if not cid_processed[name] then
				cid_crops[cid] = {
					type = crop_type,
					group = group,
					crops = list[crop_type],
					by_biome = {
						[biome] = list[crop_type],
					},
				}
				cid_processed[name] = true
				table.insert (crop_cids, cid)
			else
				cid_crops[cid].by_biome[biome] = list[crop_type]
			end
		end
	end
end

table.sort (crop_cids)

local current_structure_start = mcl_levelgen.current_structure_start
local current_structure_piece = mcl_levelgen.current_structure_piece

local cid_chest_small = core.get_content_id ("mcl_chests:chest_small")

local notify_generated = mcl_levelgen.notify_generated
local notify_generated_unchecked = mcl_levelgen.notify_generated_unchecked

local function instantiate_crops_and_chests (x, y, z, rng, cid_existing,
					     param2_existing, cid, param2)
	if cid_crops[cid] then
		local start = current_structure_start ()
		local content = start.crops[cid]
		assert (content)
		return content[1], content[2]
	elseif cid == cid_chest_small then
		local piece = current_structure_piece ()
		local start = current_structure_start ()
		notify_generated ("mcl_villages:village_chest", x, y, z, {
			x = x,
			y = y,
			z = z,
			schematic = piece.schematic,
			type = start.type,
			loot_seed = mathabs (rng:next_integer ()),
		})
	end
	return cid, param2
end

local nodes_to_construct

if mcl_levelgen.is_levelgen_environment then
	nodes_to_construct = mcl_levelgen.construct_cid_list ({
		"group:brewing_stand",
		"group:furnace",
		"group:anvil",
		"mcl_grindstone:grindstone",
		"mcl_smithing_table:table",
		"mcl_stonecutter:stonecutter",
		"group:jigsaw_construct",
		"group:bell",
	})
else
	nodes_to_construct = {}
end

local indexof = table.indexof
local construct_block = mcl_levelgen.construct_block

local function construct_pois_with_formspecs (x, y, z, rng, cid_existing,
					 param2_existing, cid, param2)
	if indexof (nodes_to_construct, cid) ~= -1 then
		construct_block (x, y, z)
	end
	return cid, param2
end

local function assemble_crops (village_type, rng)
	local biome = "plains"
	if village_type == "desert" then
		biome = "desert"
	elseif village_type == "snowy" or village_type == "taiga" then
		biome = "spruce"
	end

	local crops = {}
	for _, cid in ipairs (crop_cids) do
		local data = cid_crops[cid]
		local weights = data.by_biome[biome]
		local val = rng:next_within (weights[1])
		local crops_set = true

		for i = 2, #weights do
			local content = weights[i]
			local weight = content[3]

			val = val - weight
			if val < 0 then
				crops_set = true
				crops[cid] = content
				break
			end
		end
		assert (crops_set)
	end
	return crops
end

local default_village_processor_list = {
	preserve_grass,
	instantiate_crops_and_chests,
	construct_pois_with_formspecs,
}

local function place_villagers (piece, rng, x1, z1, x2, z2)
	local start = current_structure_start ()
	if not start.villager_assignments then
		return
	end
	local bell = start.bell
	for _, assignment in ipairs (start.villager_assignments) do
		local bed, poi = assignment[1], assignment[2]
		if bed[4] == piece
			and bed[1] >= x1 and bed[1] <= x2
			and bed[3] >= z1 and bed[3] <= z2 then
			notify_generated ("mcl_villages:villager", bed[1], bed[2], bed[3], {
				bed = {
					bed[1], bed[2], bed[3],
				},
				poi = poi,
				bell = bell,
				is_zombie = start.is_zombie,
			})
		end
	end
end

local function place_belltower (piece, rng, x1, z1, x2, z2)
	local start = current_structure_start ()
	local spawn = start.bell_spawn
	if spawn then
		local x = floor (spawn[1] + 0.5)
		local z = floor (spawn[3] + 0.5)
		if piece == spawn[4]
			and x >= x1 and x <= x2	and z >= z1 and z <= z2 then
			notify_generated ("mcl_villages:spawn_iron_golem",
					  x, floor (spawn[2] + 0.5), z, {
				spawn[1], spawn[2], spawn[3],
			})
			return
		end
	end
end

local function build_node_property_table (list)
	local tbl = {}
	for _, cid in ipairs (mcl_levelgen.construct_cid_list (list)) do
		tbl[cid] = true
	end
	return tbl
end

local is_cid_door = build_node_property_table ({"group:door",})
local cid_torch_wall = core.get_content_id ("mcl_torches:torch_wall")
local cid_torch = core.get_content_id ("mcl_torches:torch")
local cid_lantern_floor = core.get_content_id ("mcl_lanterns:lantern_floor")
local cid_lantern_ceiling = core.get_content_id ("mcl_lanterns:lantern_ceiling")
local cid_sea_lantern = core.get_content_id ("mcl_ocean:sea_lantern")
local cid_prismarine = core.get_content_id ("mcl_ocean:prismarine")
local cid_air = core.CONTENT_AIR

local function remove_doors_and_lights (x, y, z, rng, cid_existing,
					param2_existing, cid, param2)
	if is_cid_door[cid] or cid == cid_torch_wall
		or cid == cid_torch or cid == cid_lantern_floor
		or cid == cid_lantern_ceiling then
		return cid_air, 0
	elseif cid == cid_sea_lantern then
		return cid_prismarine, 0
	end
	return cid, param2
end

local cobweb_007_nodes = build_node_property_table ({
	"mcl_core:cobble",
	"group:wood",
	"group:tree",
	"group:building_block",
	"group:glass",
	"group:pane",
})

local cobweb_008_nodes = build_node_property_table ({
	"mcl_core:sandstonesmooth2",
	"group:hardened_clay",
})

local cobweb_010_nodes = build_node_property_table ({
	"group:stair",
	"group:slab",
})

local cid_glass_pane = core.get_content_id ("mcl_panes:pane_natural_flat")
local cid_brown_stained_glass_pane
	= core.get_content_id ("mcl_panes:pane_brown_flat")
local cid_glass = core.get_content_id ("mcl_core:glass")
local cid_brown_stained_glass = core.get_content_id ("mcl_core:glass_brown")

local cid_cobweb = core.get_content_id ("mcl_core:cobweb")
local cid_cobblestone = core.get_content_id ("mcl_core:cobble")
local cid_mossy_cobblestone = core.get_content_id ("mcl_core:mossycobble")

local function replace_nodes (x, y, z, rng, cid_existing,
			      param2_existing, cid, param2)
	if cobweb_010_nodes[cid] then
		if rng:next_float () < 0.10 then
			return cid_cobweb, 0
		end
	elseif cobweb_008_nodes[cid] then
		if rng:next_float () < 0.08 then
			return cid_cobweb, 0
		end
	elseif cobweb_007_nodes[cid] then
		if rng:next_float () < 0.07 then
			return cid_cobweb, 0
		end
	end
	if cid == cid_glass_pane then
		return cid_brown_stained_glass_pane, param2
	elseif cid == cid_glass then
		return cid_brown_stained_glass, param2
	elseif cid == cid_cobblestone and rng:next_float () < 0.8 then
		return cid_mossy_cobblestone, param2
	end
	return cid, param2
end

local zombie_village_processor_list = {
	preserve_grass,
	instantiate_crops_and_chests,
	construct_pois_with_formspecs,
	remove_doors_and_lights,
	replace_nodes,
}

local function load_material_substitution_list (name)
	local substitutions
		= core.ipc_get ("mcl_villages:material_substitutions")
	local cid_substitutions = {}
	for _, substitution in ipairs (substitutions[name]) do
		local src, dst = substitution[1], substitution[2]
		for name, def in pairs (core.registered_nodes) do
			if src:sub (1, 1) == "\"" then
				src = src:sub (2, #src - 1)
			end
			if dst:sub (1, 1) == "\"" then
				dst = dst:sub (2, #dst - 1)
			end
			if name:gmatch (src) () then
				local dst_name = name:gsub (src, dst)
				if core.registered_nodes[dst_name] then
					local cid_a = core.get_content_id (name)
					local cid_b = core.get_content_id (dst_name)
					cid_substitutions[cid_a] = cid_b
				end
			end
		end
	end
	return function (x, y, z, rng, cid_existing,
			 param2_existing, cid, param2)
		if cid_substitutions[cid] then
			return cid_substitutions[cid], param2
		end
		return cid, param2
	end
end

------------------------------------------------------------------------
-- Asynchronous village generation.
------------------------------------------------------------------------

local is_not_air = mcl_levelgen.is_not_air
local insert = table.insert
local make_schematic_piece = mcl_levelgen.make_schematic_piece

local beds_to_assign = {}
local pois_to_assign = {}

local rotations = {
	"0",		-- Facing north.
	"90",		-- Facing east.
	"180",		-- Facing south.
	"270",		-- Facing west.
}

local rotation_transforms = {
	["0"] = {
		1, 0, 0,
		0, 1, 0,
		0, 0, 1,
	},
	["90"] = {
		0, -1, 0,
		1, 0, 0,
		0, 0, 1,
	},
	["180"] = {
		-1, 0, 0,
		0, -1, 0,
		0, 0, 1,
	},
	["270"] = {
		0, 1, 0,
		-1, 0, 0,
		0, 0, 1,
	},
}

local function rotate (rot, x, z)
	local transform = rotation_transforms[rot]
	local x1 = x * transform[1] + z * transform[2] + transform[3]
	local z1 = x * transform[4] + z * transform[5] + transform[6]
	-- local u = x * transform[7] + z * transform[8] + transform[9]
	return x1, z1
end

local function rotate_exit (rot, bbox, x, z)
	if rot == "0" then
		return bbox[1] + x, bbox[3] + z
	elseif rot == "90" then
		return bbox[4] - z, bbox[3] + x
	elseif rot == "180" then
		return bbox[4] - x, bbox[6] - z
	elseif rot == "270" then
		return bbox[1] + z, bbox[6] - x
	end
	assert (false)
end

local compositions = {
	["0"] = {
		["0"] = "0",
		["90"] = "90",
		["180"] = "180",
		["270"] = "270",
	},
	["90"] = {
		["0"] = "90",
		["90"] = "180",
		["180"] = "270",
		["270"] = "0",
	},
	["180"] = {
		["0"] = "180",
		["90"] = "270",
		["180"] = "0",
		["270"] = "90",
	},
	["270"] = {
		["0"] = "270",
		["90"] = "0",
		["180"] = "90",
		["270"] = "180",
	},
}

local differences = {
	["0"] = {
		["0"] = "0",
		["90"] = "270",
		["180"] = "180",
		["270"] = "90",
	},
	["90"] = {
		["0"] = "90",
		["90"] = "0",
		["180"] = "270",
		["270"] = "180",
	},
	["180"] = {
		["0"] = "180",
		["90"] = "90",
		["180"] = "0",
		["270"] = "270",
	},
	["270"] = {
		["0"] = "270",
		["90"] = "180",
		["180"] = "90",
		["270"] = "0",
	},
}

local function compose_rotation (a, b)
	return compositions[a][b]
end

local function rotation_difference (a, b)
	return differences[a][b]
end

local function select_standalone_piece (rng, templates, kind, x, y, z,
					rotation)
	local list = templates[kind]
	local idx = 1 + rng:next_within (#list)
	local component = list[idx]
	local piece = make_schematic_piece (component.schematic, x, y, z, rotation,
					    rng, false, true, village_processors,
					    place_belltower, nil)
	local exits = component
	return piece, exits
end

local function make_bbox_sorted (x1, y1, z1, x2, y2, z2)
	return {
		mathmin (x1, x2),
		mathmin (y1, y2),
		mathmin (z1, z2),
		mathmax (x1, x2),
		mathmax (y1, y2),
		mathmax (z1, z2),
	}
end

local any_collisions_2d = mcl_levelgen.any_collisions_2d

local function get_pool_type (rng)
	local value = rng:next_float ()
	if value >= 0.9 then
		return "well"
	elseif value >= 0.8 then
		return "farms"
	elseif value >= 0.4 then
		return "job_buildings"
	else
		return "house_buildings"
	end
end

local function select_connecting (rng, component)
	if component.connecting == "random_exit" then
		local exits = component.exits
		return exits[1 + rng:next_within (#exits)]
	else
		return component.connecting
	end
end

local get_schematic_size = mcl_levelgen.get_schematic_size
local lerp1d = mcl_levelgen.lerp1d

local function is_terrain_suitable (terrain, bbox, y_dst)
	local h1 = terrain:get_one_height (bbox[1], bbox[3], is_not_air)
	local h2 = terrain:get_one_height (bbox[4], bbox[3], is_not_air)
	local h3 = terrain:get_one_height (bbox[1], bbox[6], is_not_air)
	local h4 = terrain:get_one_height (bbox[4], bbox[6], is_not_air)

	if mathmax (h1, h2, h3, h4) - mathmin (h1, h2, h3, h4) > 4
		or mathmax (h1, h2, h3, h4) - y_dst > 4
		or y_dst - mathmin (h1, h2, h3, h4) > 4 then
		return false
	end
	return true
end

local function fit_building_to_position (templates, terrain, pool_type, pieces, rng,
					 x, y_min, z, target, parent)
	local list = templates[pool_type]
	local idx = 1 + rng:next_within (#list)
	local component = list[idx]

	-- Select an entrance.
	local entrance = select_connecting (rng, component)
	if not entrance then
		return
	end

	-- First orient the piece so that it faces the direction
	-- opposite TARGET.

	local diff = rotation_difference (compose_rotation (target, "180"),
					  entrance.orientation)

	-- Next, position the schematic so that the position appointed
	-- is located at X, Z.
	local sid = component.schematic
	local sx, sy, sz = get_schematic_size (sid, diff)
	local bbox = {
		0, 0, 0,
		sx - 1, sy - 1, sz - 1,
	}
	local x_target, z_target = rotate_exit (diff, bbox, entrance.x, entrance.z)

	local x_dst, z_dst = x - x_target, z - z_target
	local y_dst = terrain:get_one_height (x_dst, z_dst, is_not_air)
	local y_diff = y_dst - y_min
	if y_diff < -4 then
		y_dst = y_min - 4
	elseif y_diff > 2 then
		y_dst = y_min + 4
	end
	-- (schematic_id, x, y, z, rotation, rng, center, force_place,
	--  processors, placement_sentinel, ground_offset)
	bbox[1] = bbox[1] + x_dst
	bbox[3] = bbox[3] + z_dst
	bbox[4] = bbox[4] + x_dst
	bbox[6] = bbox[6] + z_dst
	if not any_collisions_2d (pieces, bbox, parent)
		-- Verify that the surface on which this building is
		-- to be positioned is not too unstable to be
		-- suitable.
		and is_terrain_suitable (terrain, bbox, y_dst) then
		local base_y = y_dst - entrance.y
		local piece = make_schematic_piece (sid, x_dst, base_y,
						    z_dst, diff, rng, false, true,
						    village_processors,
						    place_villagers, entrance.y)
		piece.village_pool = pool_type
		insert (pieces, piece)

		for _, bed in ipairs (component.beds) do
			local x, z = rotate_exit (diff, bbox, bed[1], bed[3])
			local y = bed[2] + base_y
			insert (beds_to_assign, {x, y, z, piece,})
		end
		for _, poi in ipairs (component.pois) do
			local x, z = rotate_exit (diff, bbox, poi[1], poi[3])
			local y = poi[2] + base_y
			insert (pois_to_assign, {x, y, z, poi[4],})
		end
	end
	return
end

local PATH_EXITS = {
	{
		orientation = "0",
		z = 0,
		x = 1,
	},
	-- Left turn.
	{
		orientation = "270",
		z = 1,
		x = -1,
	},
	-- Right turn.
	{
		orientation = "90",
		z = 1,
		x = 2,
	},
}

local random_schematic_rotation = mcl_levelgen.random_schematic_rotation
local make_feature_structure_piece = mcl_levelgen.make_feature_structure_piece

local function fit_decor_to_position (templates, terrain, rotation,
				      pieces, rng, x, z, path, pile)
	local piece
	if not pile then
		local list = templates.street_decor
		local idx = 1 + rng:next_within (#list)
		local component = list[idx]
		local sid = component.schematic
		local y = terrain:get_one_height (x, z, is_not_air)
		piece = make_schematic_piece (sid, x, y, z, rotation, rng, true,
					      true, village_processors, nil, nil)
	else
		local list = templates.piles
		local idx = 1 + rng:next_within (#list)
		local feature = list[idx]
		piece = make_feature_structure_piece (feature, x, 0, z, 3, 3, 3,
						      "world_surface_wg")
	end
	if pile or not any_collisions_2d (pieces, piece.bbox, path) then
		piece.decor_parent = path
		insert (pieces, piece)
	end
end

local village_center_x
local village_center_z

local function dist_max_2d (bbox, x, z)
	local dx = mathmax (0, bbox[1] - x, x - bbox[4])
	local dz = mathmax (0, bbox[3] - z, z - bbox[6])
	return mathmax (dx, dz)
end

local any_collisions_matching_2d = mcl_levelgen.any_collisions_matching_2d

local function is_not_parent_or_parent_decor (piece, parent)
	return piece ~= parent and piece.decor_parent ~= parent
end

local function build_path (templates, terrain, parent, pieces, exit, rotation,
			   rng, depth)
	-- Position and orientation of the exit.
	local length = 10
	local x, z = rotate_exit (rotation, parent.bbox, exit.x, exit.z)
	local rotation = compose_rotation (rotation, exit.orientation)
	local is_ersatz_level = terrain.is_ersatz

	-- Create a dirt path extending from the exit in the direction
	-- appointed.
	local x1, z1 = rotate (rotation, -1, 0)
	local x2, z2 = rotate (rotation, 1, -(length - 1))
	local y1 = terrain:get_one_height (x + x1, z + z1, is_not_air)
	local y2 = terrain:get_one_height (x + x2, z + z2, is_not_air)
	local height = floor (lerp1d (0.5, y1 - 1, mathmax (y1 - 2, y2 - 1)))
	local path = {
		bbox = make_bbox_sorted (x + x1, height, z + z1,
					 x + x2, height, z + z2),
		reduced_terrain_adaptation = {
			x + x1, y1 - 1, z + z1, 0.4,
		},
		place = village_path_place,
		village_type = village_type,
	}

	if any_collisions_matching_2d (pieces, path.bbox,
				       is_not_parent_or_parent_decor,
				       parent)
		or dist_max_2d (path.bbox, village_center_x,
				village_center_z) > 140 then
		return false
	end
	insert (pieces, path)

	-- Place village buildings to the left and right at five block
	-- intervals.

	local left = rng:next_float () < 0.6
	local right = rng:next_float () < 0.6

	-- Add buildings to either side.
	if left then
		local pool_type = get_pool_type (rng)
		local target = compose_rotation (rotation, "270")
		local dx, dz = rotate (rotation, -2, -4)
		local x1, z1 = x + dx, z + dz
		fit_building_to_position (templates, terrain, pool_type, pieces,
					  rng, x1, height, z1, target, path)
	end

	if right then
		local pool_type = get_pool_type (rng)
		local target = compose_rotation (rotation, "90")
		local dx, dz = rotate (rotation, 2, -7)
		local x1, z1 = x + dx, z + dz
		fit_building_to_position (templates, terrain, pool_type, pieces,
					  rng, x1, height, z1, target, path)
	end

	-- Try to insert street decorations along the sides or in the
	-- center.
	for z1 = -2, -(length - 1), -5 do
		if rng:next_float () < 0.25 then
			local value = rng:next_float ()
			local dx, dz
			local pile = false

			if value < 0.6 then
				dx, dz = rotate (rotation, 0, z1)
				rotation = random_schematic_rotation (rng)
			else
				pile = not is_ersatz_level and rng:next_boolean ()
				local dx_mag = pile and 3 or 2
				if value < 0.9 then
					dx, dz = rotate (rotation, -1 * dx_mag, z1)
					rotation = compose_rotation (rotation, "90")
				else
					dx, dz = rotate (rotation, 1 * dx_mag, z1)
					rotation = compose_rotation (rotation, "270")
				end
			end
			fit_decor_to_position (templates, terrain, rotation,
					       pieces, rng, dx + x, dz + z,
					       path, pile)
		end
	end

	-- Extend the path forward or make a turn.
	if depth <= 9 then
		local path_idx = 0
		if rng:next_integer () < 0.9 then
			-- Attempt to turn left or right.
			path_idx = rng:next_boolean () and 1 or 2
		end

		for i = 0, 2 do
			local idx = (path_idx + i) % 3 + 1
			local exit = PATH_EXITS[idx]
			if idx == 0 then
				exit.x = 0
				if rng:next_float () < 0.15 then
					exit.x = -1
				elseif rng:next_float () < 0.25 then
					exit.x = 1
				end
			end
			local success = build_path (templates, terrain, path,
						    pieces, exit, rotation,
						    rng, depth + 1)
			if success then
				return
			end
		end
	else
		local pool_type = get_pool_type (rng)
		local dx, dz = rotate (rotation, 0, -length)
		local x1, z1 = x + dx, z + dz
		-- Terminate the village with another building.
		fit_building_to_position (templates, terrain, pool_type, pieces,
					  rng, x1, height, z1, rotation, path)
	end

	return true
end

local function village_start (templates, terrain, x, z, pieces, rotation,
			      zombie, rng)
	local y = terrain:get_one_height (x, z, is_not_air)
	local belltower, component
		= select_standalone_piece (rng, templates,
					   "meeting_points",
					   x, y, z, rotation)
	assert (component.bell)
	insert (pieces, belltower)

	for _, exit in ipairs (component.exits) do
		build_path (templates, terrain, belltower, pieces, exit,
			    rotation, rng, 0)
	end
	return component, belltower
end

local fisher_yates = mcl_levelgen.fisher_yates

local function assign_villagers (rng, bell, belltower_piece, beds, pois)
	fisher_yates (beds, rng)
	fisher_yates (pois, rng)

	local bbox = belltower_piece.bbox
	local bell_x, bell_z = rotate_exit (belltower_piece.rotation,
					    bbox, bell[1], bell[3])
	local bell_y = bbox[2] + bell[2]

	local assignments = {}
	local assigned_pois = {}
	local n_pois = #pois
	-- No village can support more than 32 villagers.
	for i = 1, mathmin (32, #beds) do
		if i < n_pois then
			insert (assignments, { beds[i], pois[i], })
			insert (assigned_pois, pois[i])
		else
			insert (assignments, { beds[i], nil, })
		end
		insert (assigned_pois, {
			beds[i][1],
			beds[i][2],
			beds[i][3],
		})
	end
	return assignments, { bell_x, bell_y, bell_z, }, assigned_pois
end

local function assign_golem (belltower, belltower_piece)
	local bell_spawn = belltower.bell_spawn
	local bbox = belltower_piece.bbox
	local bell_x, bell_z = rotate_exit (belltower_piece.rotation,
					    bbox, bell_spawn[1],
					    bell_spawn[3])
	local bell_y = bbox[2] + bell_spawn[2]
	return { bell_x, bell_y, bell_z, belltower_piece, }
end

local ull = mcl_levelgen.ull
local village_rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))
local is_levelgen_environment = mcl_levelgen.is_levelgen_environment

local function assemble_village (self, level, terrain, rng, x, z)
	-- Note: rotation only affects the village meeting point
	-- structure.

	local rotation = rotations[1 + rng:next_within (4)]
	local zombie
	village_type = self.village_type
	if village_type == "savannah" then
		local i = rng:next_within (459)
		zombie = i >= 450
	elseif village_type == "desert" then
		local i = rng:next_within (250)
		zombie = i >= 245
	elseif village_type == "taiga" then
		local i = rng:next_within (100)
		zombie = i >= 98
	elseif village_type == "snowy" then
		local i = rng:next_within (306)
		zombie = i >= 300
	elseif village_type == "plains" then
		local i = rng:next_within (204)
		zombie = i >= 200
	else
		zombie = false
	end
	village_center_x = x
	village_center_z = z
	local pieces = {}
	local dx = rng:next_within (16) - 8
	local dz = rng:next_within (16) - 8
	local templates = self.village_template
	village_processors = zombie
		and self.zombie_processors
		or self.processors
	beds_to_assign = {}
	pois_to_assign = {}
	village_rng:reseed (rng:next_long ())
	local belltower, belltower_piece
		= village_start (templates, terrain, x + dx, z + dz,
				 pieces, rotation, zombie, village_rng)
	local start = mcl_levelgen.create_structure_start (self, pieces)
	start.crops = assemble_crops (village_type, village_rng)
	start.type = village_type
	start.is_zombie = zombie
	local assigned_pois
	start.villager_assignments, start.bell, assigned_pois
		= assign_villagers (village_rng, belltower.bell,
				    belltower_piece,
				    beds_to_assign,
				    pois_to_assign)
	-- The village generator is liable to be invoked by `/locate'
	-- within the main environment when ersatz generation is
	-- enabled.
	if not zombie and is_levelgen_environment then
		start.bell_spawn = assign_golem (belltower, belltower_piece)
		notify_generated_unchecked ("mcl_villages:village_start_available",
					    assigned_pois, false)
	end
	return start
end

local structure_biome_test = mcl_levelgen.structure_biome_test

local function village_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16, cz * 16
	local height = terrain:get_one_height (x, z, is_not_air)

	if structure_biome_test (level, self, x, height, z) then
		return assemble_village (self, level, terrain, rng, x, z)
	else
		return false
	end
end

------------------------------------------------------------------------
-- Village registration.
------------------------------------------------------------------------

local village_desert_biomes = {
	"Desert",
}

local village_plains_biomes = {
	"Plains",
	"Meadow",
}

local village_savannah_biomes = {
	"Savannah",
}

local village_snowy_biomes = {
	"SnowyPlains",
}

local village_taiga_biomes = {
	"Taiga",
}

mcl_levelgen.modify_biome_groups (village_desert_biomes, {
	has_village_desert = true,
})

mcl_levelgen.modify_biome_groups (village_plains_biomes, {
	has_village_plains = true,
})

mcl_levelgen.modify_biome_groups (village_savannah_biomes, {
	has_village_savannah = true,
})

mcl_levelgen.modify_biome_groups (village_snowy_biomes, {
	has_village_snowy = true,
})

mcl_levelgen.modify_biome_groups (village_taiga_biomes, {
	has_village_taiga = true,
})

mcl_levelgen.register_structure ("mcl_villages:village_plains", {
	create_start = village_create_start,
	village_template = plains_village_template,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_village_plains",}),
	village_type = "plains",
	processors = {
		unpack (default_village_processor_list)
	},
	zombie_processors = {
		unpack (zombie_village_processor_list)
	},
})

mcl_levelgen.register_structure ("mcl_villages:village_desert", {
	create_start = village_create_start,
	village_template = desert_village_template,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_village_desert",}),
	village_type = "desert",
	processors = {
		load_material_substitution_list ("desert"),
		unpack (default_village_processor_list)
	},
	zombie_processors = {
		load_material_substitution_list ("desert"),
		unpack (zombie_village_processor_list)
	},
})

mcl_levelgen.register_structure ("mcl_villages:village_savannah", {
	create_start = village_create_start,
	village_template = savannah_village_template,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_village_savannah",}),
	village_type = "savannah",
	processors = {
		load_material_substitution_list ("acacia"),
		unpack (default_village_processor_list)
	},
	zombie_processors = {
		load_material_substitution_list ("acacia"),
		unpack (zombie_village_processor_list)
	},
})

mcl_levelgen.register_structure ("mcl_villages:village_snowy", {
	create_start = village_create_start,
	village_template = snowy_village_template,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_village_snowy",}),
	village_type = "snowy",
	processors = {
		load_material_substitution_list ("spruce"),
		unpack (default_village_processor_list)
	},
	zombie_processors = {
		load_material_substitution_list ("spruce"),
		unpack (zombie_village_processor_list)
	},
})

mcl_levelgen.register_structure ("mcl_villages:village_taiga", {
	create_start = village_create_start,
	village_template = taiga_village_template,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#has_village_taiga",}),
	village_type = "taiga",
	processors = {
		load_material_substitution_list ("spruce"),
		unpack (default_village_processor_list)
	},
	zombie_processors = {
		load_material_substitution_list ("spruce"),
		unpack (zombie_village_processor_list)
	},
})

mcl_levelgen.register_structure_set ("mcl_villages:villages", {
	structures = {
		"mcl_villages:village_plains",
		"mcl_villages:village_desert",
		"mcl_villages:village_savannah",
		"mcl_villages:village_snowy",
		"mcl_villages:village_taiga",
	},
	placement = R (1.0, "default", 34, 8, 10387312, "linear", nil, nil),
})

------------------------------------------------------------------------
-- Village features.
------------------------------------------------------------------------

if not mcl_levelgen.enable_ersatz then

local cid_hay_block = core.get_content_id ("mcl_farming:hay_block")
local cid_packed_ice = core.get_content_id ("mcl_core:packed_ice")
local cid_melon = core.get_content_id ("mcl_farming:melon")
local cid_pumpkin = core.get_content_id ("mcl_farming:pumpkin")
local cid_snow = core.get_content_id ("mcl_core:snow")

mcl_levelgen.register_configured_feature ("mcl_villages:pile_hay", {
	feature = "mcl_levelgen:block_pile",
	content = function (_, _, _, _)
		return cid_hay_block, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_villages:pile_ice", {
	feature = "mcl_levelgen:block_pile",
	content = function (_, _, _, _)
		return cid_packed_ice, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_villages:pile_melon", {
	feature = "mcl_levelgen:block_pile",
	content = function (_, _, _, _)
		return cid_melon, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_villages:pile_pumpkin", {
	feature = "mcl_levelgen:block_pile",
	content = function (_, _, _, _)
		return cid_pumpkin, 0
	end,
})

mcl_levelgen.register_configured_feature ("mcl_villages:pile_snow", {
	feature = "mcl_levelgen:block_pile",
	content = function (_, _, _, _)
		return cid_snow, 0
	end,
})

end
