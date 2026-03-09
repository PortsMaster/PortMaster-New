local R = mcl_levelgen.build_random_spread_placement
local insert = table.insert
local mathabs = math.abs
local floor = math.floor
local ceil = math.ceil
local mathmax = math.max
local mathmin = math.min
local band = bit.band

------------------------------------------------------------------------
-- Mineshaft callbacks.
------------------------------------------------------------------------

if not mcl_levelgen.is_levelgen_environment
	and mcl_levelgen.register_notification_handler then

local minecart_loot = {
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_mobitems:nametag", weight = 30 },
			{ itemstring = "mcl_core:apple_gold", weight = 20 },
			{ itemstring = "mcl_books:book", weight = 10, func = function(stack, pr)
				  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
			end },
			{ itemstring = "", weight = 5},
			{ itemstring = "mcl_core:pick_iron", weight = 5 },
			{ itemstring = "mcl_core:apple_gold_enchanted", weight = 1 },
		}
	},
	{
		stacks_min = 2,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:coal_lump", weight = 10, amount_min = 3, amount_max = 8 },
			{ itemstring = "mcl_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_core:lapis", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mcl_redstone:redstone", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_minecarts:rail", weight = 20, amount_min = 4, amount_max = 8 },
			{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 1, amount_max = 16 },
			{ itemstring = "mcl_minecarts:activator_rail", weight = 5, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_minecarts:detector_rail", weight = 5, amount_min = 1, amount_max = 4 },
			{ itemstring = "mcl_minecarts:golden_rail", weight = 5, amount_min = 1, amount_max = 4 },
		}
	},
}

local function minecart_chest_constructor (_, data)
	local x, y, z
		= mcl_levelgen.level_to_minetest_position (data.x, data.y, data.z)
	local v = vector.new (x, y, z)
	core.load_area (v)
	local node = core.get_node (v)

	if node.name == "mcl_minecarts:rail" then
		local object = core.add_entity (v, "mcl_minecarts:chest_minecart")
		if object then
			local luaentity = object:get_luaentity ()
			local inv = mcl_entity_invs.load_inv (luaentity, 27)
			local pr = PcgRandom (data.loot_seed)
			local items = mcl_loot.get_multi_loot (minecart_loot, pr)
			mcl_loot.fill_inventory (inv, "main", items, pr)
			mcl_entity_invs.save_inv (luaentity)
		end
	end
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:minecart_chest_constructor",
					    minecart_chest_constructor)

local function mob_spawner_constructor (_, data)
	local x, y, z
		= mcl_levelgen.level_to_minetest_position (data.x, data.y, data.z)
	local v = vector.new (x, y, z)
	core.load_area (v)
	local node = core.get_node (v)

	if node.name == "mcl_mobspawners:spawner" then
		mcl_mobspawners.setup_spawner (v, data.mob)
	end
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:mob_spawner_constructor",
					    mob_spawner_constructor)
end

------------------------------------------------------------------------
-- Mineshaft pieces.
------------------------------------------------------------------------

local cid_air
local cid_water_source
local cid_lava_source
local cid_chain
local cid_wood_oak
local cid_tree_oak
local cid_fence_oak
local cid_wood_dark_oak
local cid_tree_dark_oak
local cid_fence_dark_oak
local cid_cobweb
local cid_torch
local cid_rail
local cid_mob_spawner

local function initialize_cids ()
	cid_air = core.CONTENT_AIR
	cid_water_source = core.get_content_id ("mcl_core:water_source")
	cid_lava_source = core.get_content_id ("mcl_core:lava_source")
	cid_chain = core.get_content_id ("mcl_lanterns:chain")
	cid_wood_oak = core.get_content_id ("mcl_trees:wood_oak")
	cid_tree_oak = core.get_content_id ("mcl_trees:tree_oak")
	cid_fence_oak = core.get_content_id ("mcl_fences:oak_fence")
	cid_wood_dark_oak = core.get_content_id ("mcl_trees:wood_dark_oak")
	cid_tree_dark_oak = core.get_content_id ("mcl_trees:tree_dark_oak")
	cid_fence_dark_oak = core.get_content_id ("mcl_fences:dark_oak_fence")
	cid_cobweb = core.get_content_id ("mcl_core:cobweb")
	cid_torch = core.get_content_id ("mcl_torches:torch_wall")
	cid_rail = core.get_content_id ("mcl_minecarts:rail")
	cid_mob_spawner = core.get_content_id ("mcl_mobspawners:spawner")
end

if core then
	if core.register_on_mods_loaded then
		core.register_on_mods_loaded (initialize_cids)
	else
		initialize_cids ()
	end
else
	cid_air = 0
	cid_water_source = 1
	cid_lava_source = 4
	cid_chain = 180
	cid_wood_oak = 181
	cid_tree_oak = 182
	cid_fence_oak = 183
	cid_wood_dark_oak = 184
	cid_tree_dark_oak = 185
	cid_fence_dark_oak = 186
	cid_cobweb = 187
	cid_torch = 188
	cid_rail = 189
	cid_mob_spawner = 190
end

local function bbox_height (bbox)
	return bbox[5] - bbox[2] + 1
end

local function bbox_width_x (bbox)
	return bbox[4] - bbox[1] + 1
end

local function bbox_width_z (bbox)
	return bbox[6] - bbox[3] + 1
end

local function dir_x_axis_p (dir)
	return dir == "west" or dir == "east"
end

local function rtz (x)
	if x < 0 then
		return ceil (x)
	else
		return floor (x)
	end
end

local level_min, level_max
local index_biome = mcl_levelgen.index_biome
local registered_biomes = mcl_levelgen.registered_biomes
local get_block = mcl_levelgen.get_block

local count_sturdy_neighbors = mcl_levelgen.count_sturdy_neighbors
local get_sturdy_faces = mcl_levelgen.get_sturdy_faces
local FACE_UP = mcl_levelgen.FACE_UP
local FACE_DOWN = mcl_levelgen.FACE_DOWN

local function is_invalid_wall_material (cid)
	return cid == cid_water_source
		or cid == cid_lava_source
end

local function extents_valid_p (bbox, x1, z1, x2, z2)
	local xmin = mathmax (x1, bbox[1] - 1)
	local ymin = mathmax (level_min, bbox[2] - 1)
	local zmin = mathmax (z1, bbox[3] - 1)
	local xmax = mathmin (x2, bbox[4] + 1)
	local ymax = mathmin (level_max, bbox[5] + 1)
	local zmax = mathmin (z2, bbox[6] + 1)

	do
		local cx = rtz ((xmin + xmax) / 2)
		local cy = rtz ((ymin + ymax) / 2)
		local cz = rtz ((zmin + zmax) / 2)
		local biome = index_biome (cx, cy, cz)
		if registered_biomes[biome].groups.mineshaft_blocking then
			return false
		end
	end

	-- Test that no liquid exists in the walls, floors, and
	-- ceilings.
	for x = xmin, xmax do
		for z = zmin, zmax do
			local cid, _ = get_block (x, ymin, z)
			local cid_1, _ = get_block (x, ymax, z)
			if is_invalid_wall_material (cid)
				or is_invalid_wall_material (cid_1) then
				return false
			end
		end
	end
	for x = xmin, xmax do
		for y = ymin, ymax do
			local cid, _ = get_block (x, y, zmin)
			local cid_1, _ = get_block (x, y, zmax)
			if is_invalid_wall_material (cid)
				or is_invalid_wall_material (cid_1) then
				return false
			end
		end
	end
	for z = zmin, zmax do
		for y = ymin, ymax do
			local cid, _ = get_block (xmin, y, z)
			local cid_1, _ = get_block (xmax, y, z)
			if is_invalid_wall_material (cid)
				or is_invalid_wall_material (cid_1) then
				return false
			end
		end
	end
	return true
end

local mineshaft_planks_cid
local mineshaft_wood_cid
local mineshaft_fence_cid

local function mineshaft_setup (self)
	level_min = mcl_levelgen.placement_level_min
	level_max = level_min + mcl_levelgen.placement_level_height - 1
	if not self.is_mesa then
		mineshaft_planks_cid = cid_wood_oak
		mineshaft_wood_cid = cid_tree_oak
		mineshaft_fence_cid = cid_fence_oak
	else
		mineshaft_planks_cid = cid_wood_dark_oak
		mineshaft_wood_cid = cid_tree_dark_oak
		mineshaft_fence_cid = cid_fence_dark_oak
	end
end

local function mineshaft_writable_p (cid, param2)
	return cid ~= mineshaft_planks_cid
		and cid ~= mineshaft_wood_cid
		and cid ~= mineshaft_fence_cid
		and cid ~= cid_chain
end

local function mineshaft_air_p (cid, param2)
	return cid == cid_air
end

local set_block_checked = mcl_levelgen.set_block_checked
local function mineshaft_set_block (x, y, z, cid, param2)
	set_block_checked (x, y, z, cid, param2, mineshaft_writable_p)
end

local reorientate_coords = mcl_levelgen.reorientate_coords
local ipos3 = mcl_levelgen.ipos3

local function fill_box_rotated (piece, x1, y1, z1, x2, y2, z2,
				 cid, param2, chance, rng)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if chance == 1.0 or (rng:next_float () <= chance) then
			mineshaft_set_block (x, y, z, cid, param2)
		end
	end
end

local index_heightmap = mcl_levelgen.index_heightmap

local function fill_buried_air_in_box (piece, x1, y1, z1, x2, y2, z2,
				       cid, param2, chance, rng)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if chance == 1.0 or (rng:next_float () <= chance) then
			local _, motion_blocking = index_heightmap (x, z, false)
			if y < motion_blocking then
				if x == x1
					or x == x2
					or y == y1
					or y == y2
					or z == z1
					or z == z2 then
					set_block_checked (x, y, z, cid, param2,
							   mineshaft_air_p)
				end
			end
		end
	end
end

local function get_block_reorientated (piece, x, y, z)
	local x, y, z = reorientate_coords (piece, x, y, z)
	return get_block (x, y, z)
end

local function set_block_reorientated (piece, x, y, z, cid, param2)
	local x, y, z = reorientate_coords (piece, x, y, z)
	mineshaft_set_block (x, y, z, cid, param2)
end

local any_collisions = mcl_levelgen.any_collisions

local generate_random_piece

-- Junctions.

local function create_junction_bbox (rng, dir, x, y, z)
	local height = rng:next_within (4) == 0 and 6 or 2
	local bbox

	if dir == "north" then
		bbox = {
			x - 1, y, z - 4,
			x + 3, y + height, z,
		}
	elseif dir == "south" then
		bbox = {
			x - 1, y, z,
			x + 3, y + height, z + 4,
		}
	elseif dir == "west" then
		bbox = {
			x - 4, y, z - 1,
			x, y + height, z + 3,
		}
	elseif dir == "east" then
		bbox = {
			x, y, z - 1,
			x + 4, y + height, z + 3,
		}
	end
	return bbox
end

local function junction_aerate (x1, y1, z1, x2, y2, z2,
				x_min, z_min, x_max, z_max)
	for x, y, z in ipos3 (mathmax (x1, x_min), y1,
			      mathmax (z1, z_min),
			      mathmin (x2, x_max), y2,
			      mathmin (z2, z_max)) do
		mineshaft_set_block (x, y, z, cid_air, 0)
	end
end

local function essay_junction_pillar (x, y, z, ceiling)
	local cid, _ = get_block (x, ceiling + 1, z)
	if cid and cid ~= cid_air then
		local cid = mineshaft_planks_cid
		for y = y, ceiling do
			mineshaft_set_block (x, y, z, cid, 0)
		end
	end
end

local function patch_up_floor (x, y, z)
	if get_sturdy_faces then
		local _, motion_blocking = index_heightmap (x, z, false)
		if y < motion_blocking then
			local sturdy = get_sturdy_faces (x, y, z)
			if band (sturdy, FACE_UP) == 0 then
				local cid_planks = mineshaft_planks_cid
				mineshaft_set_block (x, y, z, cid_planks, 0)
			end
		end
	end
end

local function junction_place (self, level, terrain, rng, x1, z1, x2, z2)
	mineshaft_setup (self)
	if extents_valid_p (self.bbox, x1, z1, x2, z2) then
		local bbox = self.bbox

		if self.multistory then
			-- East/west.
			junction_aerate (bbox[1] + 1,
					 bbox[2],
					 bbox[3],
					 bbox[4] - 1,
					 bbox[2] + 3 - 1,
					 bbox[6],
					 x1, z1, x2, z2)
			-- South/north.
			junction_aerate (bbox[1],
					 bbox[2],
					 bbox[3] + 1,
					 bbox[4],
					 bbox[2] + 3 - 1,
					 bbox[6] - 1,
					 x1, z1, x2, z2)

			-- Second storey east.
			junction_aerate (bbox[1] + 1,
					 bbox[5] - 2,
					 bbox[3],
					 bbox[4] - 1,
					 bbox[5],
					 bbox[6],
					 x1, z1, x2, z2)
			-- Second story south.
			junction_aerate (bbox[1],
					 bbox[5] - 2,
					 bbox[3] + 1,
					 bbox[4],
					 bbox[5],
					 bbox[6] - 1,
					 x1, z1, x2, z2)

			-- Floor of the second storey.
			junction_aerate (bbox[1] + 1,
					 bbox[2] + 3,
					 bbox[3] + 1,
					 bbox[4] - 1,
					 bbox[2] + 3,
					 bbox[6] - 1,
					 x1, z1, x2, z2)
		else
			-- East/west.
			junction_aerate (bbox[1] + 1,
					 bbox[2],
					 bbox[3],
					 bbox[4] - 1,
					 bbox[5],
					 bbox[6],
					 x1, z1, x2, z2)
			-- South/north.
			junction_aerate (bbox[1],
					 bbox[2],
					 bbox[3] + 1,
					 bbox[4],
					 bbox[5],
					 bbox[6] - 1,
					 x1, z1, x2, z2)
		end

		-- Place pillars at the four corners.
		essay_junction_pillar (bbox[1] + 1, bbox[2], bbox[3] + 1,
				       bbox[5])
		essay_junction_pillar (bbox[1] + 1, bbox[2], bbox[6] - 1,
				       bbox[5])
		essay_junction_pillar (bbox[4] - 1, bbox[2], bbox[3] + 1,
				       bbox[5])
		essay_junction_pillar (bbox[4] - 1, bbox[2], bbox[6] - 1,
				       bbox[5])

		-- Build the platform.
		for x, y, z in ipos3 (bbox[1], bbox[2] - 1, bbox[3],
				      bbox[4], bbox[2] - 1, bbox[6]) do
			patch_up_floor (x, y, z)
		end
	end
end

local function junction_insert_children (self, parlor, rng, pieces)
	local bbox = self.bbox
	local dir = self.dir
	local depth = self.depth

	-- if parlor.bbox[1] == 720 + 2 and parlor.bbox[3] == 8176 + 2 then
	-- 	-- print ("----> Junction start: " .. dir)
	-- end

	if dir == "north" then
		-- print ("-----> Junction A: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[3] - 1,
				       "north", depth)
		-- print ("-----> Junction B: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] - 1, bbox[2], bbox[3] + 1,
				       "west", depth)
		-- print ("-----> Junction C: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[4] + 1, bbox[2], bbox[3] + 1,
				       "east", depth)
	elseif dir == "south" then
		-- print ("-----> Junction A: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[6] + 1,
				       "south", depth)
		-- print ("-----> Junction B: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] - 1, bbox[2], bbox[3] + 1,
				       "west", depth)
		-- print ("-----> Junction C: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[4] + 1, bbox[2], bbox[3] + 1,
				       "east", depth)
	elseif dir == "west" then
		-- print ("-----> Junction A: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[3] - 1,
				       "north", depth)
		-- print ("-----> Junction B: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[6] + 1,
				       "south", depth)
		-- print ("-----> Junction C: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] - 1, bbox[2], bbox[3] + 1,
				       "west", depth)
	elseif dir == "east" then
		-- print ("-----> Junction A: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[3] - 1,
				       "north", depth)
		-- print ("-----> Junction B: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] + 1, bbox[2], bbox[6] + 1,
				       "south", depth)
		-- print ("-----> Junction C: " .. dir)
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[4] + 1, bbox[2], bbox[3] + 1,
				       "east", depth)
	end

	-- Generate the second storey.

	if self.multistory then
		if rng:next_boolean () then
			-- print ("-----> Two storey north: " .. dir)
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] + 1, bbox[2] + 4, bbox[3] - 1,
					       "north", depth)
			-- print ("<----- Two storey north: " .. dir)
		end
		if rng:next_boolean () then
			-- print ("-----> Two storey west: " .. dir)
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] - 1, bbox[2] + 4, bbox[3] + 1,
					       "west", depth)
			-- print ("<----- Two storey west: " .. dir)
		end
		if rng:next_boolean () then
			-- print ("-----> Two storey east: " .. dir)
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] + 1, bbox[2] + 4, bbox[3] + 1,
					       "east", depth)
			-- print ("<----- Two storey east: " .. dir)
		end
		if rng:next_boolean () then
			-- print ("-----> Two storey south: " .. dir)
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] + 1, bbox[2] + 4, bbox[6] + 1,
					       "south", depth)
			-- print ("<----- Two storey south: " .. dir)
		end
	end

	-- if parlor.bbox[1] == 720 + 2 and parlor.bbox[3] == 8176 + 2 then
	-- 	-- print ("----> Junction end")
	-- end
end

local function create_junction_piece (rng, parlor, depth, bbox, dir)
	return {
		depth = depth,
		bbox = bbox,
		dir = dir,
		multistory = bbox_height (bbox) > 3,
		insert_children = junction_insert_children,
		place = junction_place,
		is_mesa = parlor.is_mesa,
	}
end

-- Staircases.

local function create_staircase_bbox (rng, dir, x, y, z)
	local bbox
	if dir == "north" then
		bbox = {
			x, y - 5, z - 8,
			x + 2, y + 2, z,
		}
	elseif dir == "south" then
		bbox = {
			x, y - 5, z,
			x + 2, y + 2, z + 8,
		}
	elseif dir == "west" then
		bbox = {
			x - 8, y - 5, z,
			x, y + 2, z + 2,
		}
	elseif dir == "east" then
		bbox = {
			x, y - 5, z,
			x + 8, y + 2, z + 2,
		}
	end
	return bbox
end

local function staircase_insert_children (self, parlor, rng, pieces)
	local dir = self.dir
	local bbox = self.bbox
	local depth = self.depth
	if dir == "north" then
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1], bbox[2], bbox[3] - 1,
				       "north", depth)
	elseif dir == "south" then
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1], bbox[2], bbox[6] + 1,
				       "south", depth)
	elseif dir == "west" then
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[1] - 1, bbox[2], bbox[3],
				       "west", depth)
	else
		generate_random_piece (parlor, self, rng, pieces,
				       bbox[4] + 1, bbox[2], bbox[3],
				       "east", depth)
	end
end

local function staircase_place (self, level, terrain, rng, x1, z1, x2, z2)
	mineshaft_setup (self)
	if extents_valid_p (self.bbox, x1, z1, x2, z2) then
		fill_box_rotated (self, 0, 5, 0, 2, 7, 1, cid_air, 0, 1.0, nil)
		fill_box_rotated (self, 0, 0, 7, 2, 2, 8, cid_air, 0, 1.0, nil)
		for i = 1, 5 do
			fill_box_rotated (self, 0, mathmax (1, 5 - i),
					  2 + i - 1, 2, 7 - i + 1, 2 + i - 1,
					  cid_air, 0, 1.0, nil)
		end
	end
end

local function create_staircase_piece (rng, parlor, depth, bbox, dir)
	return {
		depth = depth,
		bbox = bbox,
		dir = dir,
		insert_children = staircase_insert_children,
		place = staircase_place,
		is_mesa = parlor.is_mesa,
	}
end

-- Corridors.

local function corridor_insert_children (self, parlor, rng, pieces)
	local depth = self.depth
	local rotate = rng:next_within (4)
	local dir = self.dir
	local yoff = rng:next_within (3) - 1
	local bbox = self.bbox

	if dir == "north" then
		if rotate == 0 or rotate == 1 then
			-- No rotation.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1], bbox[2] + yoff,
					       bbox[3] - 1, "north", depth)
		elseif rotate == 2 then
			-- Turn left.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] - 1, bbox[2] + yoff,
					       bbox[3], "west", depth)
		else
			-- Turn right.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] + 1, bbox[2] + yoff,
					       bbox[3], "east", depth)
		end
	elseif dir == "south" then
		if rotate == 0 or rotate == 1 then
			-- No rotation.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1], bbox[2] + yoff,
					       bbox[6] + 1, "south", depth)
		elseif rotate == 2 then
			-- Turn right.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] - 1, bbox[2] + yoff,
					       bbox[6] - 3, "west", depth)
		else
			-- Turn left.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] + 1, bbox[2] + yoff,
					       bbox[6] - 3, "east", depth)
		end
	elseif dir == "west" then
		if rotate == 0 or rotate == 1 then
			-- No rotation.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1] - 1, bbox[2] + yoff,
					       bbox[3], "west", depth)
		elseif rotate == 2 then
			-- Turn right.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1], bbox[2] + yoff,
					       bbox[3] - 1, "north", depth)
		elseif rotate == 3 then
			-- Turn south.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[1], bbox[2] + yoff,
					       bbox[6] + 1, "south", depth)
		end
	elseif dir == "east" then
		if rotate == 0 or rotate == 1 then
			-- No rotation.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] + 1, bbox[2] + yoff,
					       bbox[3], "east", depth)
		elseif rotate == 2 then
			-- Turn left.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] - 3, bbox[2] + yoff,
					       bbox[3] - 1, "north", depth)
		elseif rotate == 3 then
			-- Turn right.
			generate_random_piece (parlor, self, rng, pieces,
					       bbox[4] - 3, bbox[2] + yoff,
					       bbox[6] + 1, "south", depth)
		end
	else
		assert (false)
	end

	-- If within eight pieces of the origin, possibly generate
	-- additional branches with fewer children.

	if depth < 8 then
		if dir_x_axis_p (dir) then
			local x = bbox[1] + 3
			local x_max = bbox[4]

			for x1 = x, x_max, 5 do
				if x1 + 3 > x_max then
					break
				end
				local selector = rng:next_within (5)
				if selector == 0 then
					-- Level branch north.
					generate_random_piece (parlor, self, rng, pieces,
							       x1, bbox[2], bbox[3] - 1,
							       "north", depth + 1)
				elseif selector == 1 then
					-- Level branch south.
					generate_random_piece (parlor, self, rng, pieces,
							       x1, bbox[2], bbox[6] + 1,
							       "south", depth + 1)
				end
				-- print ("---> selector: " .. selector .. " X:" .. x1)
			end
		else
			local z = bbox[3] + 3
			local z_max = bbox[6]

			for z1 = z, z_max, 5 do
				if z1 + 3 > z_max then
					break
				end
				local selector = rng:next_within (5)
				if selector == 0 then
					-- Level branch west.
					generate_random_piece (parlor, self, rng, pieces,
							       bbox[1] - 1, bbox[2], z1,
							       "west", depth + 1)
				elseif selector == 1 then
					-- Level branch east.
					generate_random_piece (parlor, self, rng, pieces,
							       bbox[4] + 1, bbox[2], z1,
							       "east", depth + 1)
				end
				-- print ("---> selector: " .. selector .. " Z:" .. z1)
			end
		end
	end
end

local wallmounted = {
	north = 4,
	south = 5,
	west = 3,
	east = 2,
}

local reverse_wallmounted = {
	north = 5,
	south = 4,
	west = 2,
	east = 3,
}

local function get_torch_param2 (piece, reverse)
	if reverse then
		return reverse_wallmounted[piece.dir]
	else
		return wallmounted[piece.dir]
	end
end

local function generate_supports (piece, rng, min_x, min_y, z, max_y, max_x)
	-- Test whether the ceiling is solid.
	for x = min_x, max_x do
		local cid, _ = get_block_reorientated (piece, x, max_y + 1, z)
		if not cid or cid == cid_air then
			return
		end
	end

	-- Generate arches.
	local cid_planks = mineshaft_planks_cid
	if rng:next_within (4) == 0 then
		-- Broken arches.
		set_block_reorientated (piece, min_x, max_y, z, cid_planks, 0)
		set_block_reorientated (piece, max_x, max_y, z, cid_planks, 0)
	else
		for x = min_x, max_x do
			set_block_reorientated (piece, x, max_y, z, cid_planks, 0)
		end
		if rng:next_float () <= 0.05 then
			set_block_reorientated (piece, min_x + 1, max_y, z + 1,
						cid_torch, get_torch_param2 (piece, true))
		end
		if rng:next_float () <= 0.05 then
			set_block_reorientated (piece, min_x + 1, max_y, z - 1,
						cid_torch, get_torch_param2 (piece, false))
		end
	end

	-- Fences.
	local cid_fence = mineshaft_fence_cid
	for y = min_y, max_y - 1 do
		set_block_reorientated (piece, min_x, y, z, cid_fence, 0)
		set_block_reorientated (piece, max_x, y, z, cid_fence, 0)
	end
end

local function essay_cobweb (piece, rng, chance, x, y, z)
	local x, y, z = reorientate_coords (piece, x, y, z)
	local _, motion_blocking = index_heightmap (x, z, false)
	if y < motion_blocking
		and rng:next_float () < chance
	-- N.B. that this will not enumerate any faces outside the
	-- current chunk.
		and (not count_sturdy_neighbors
		     or count_sturdy_neighbors (x, y, z) >= 2) then
		mineshaft_set_block (x, y, z, cid_cobweb, 0)
	end
end

local function build_chains_or_pillars (x, y, z)
	local continue_chains, continue_pillars = true, true
	local progress = 1
	while continue_chains or continue_chains do
		if continue_pillars then
			local y1 = y - progress
			local cid, _ = get_block (x, y1, z)
			if (cid == cid_air or cid == cid_water_source)
				and get_sturdy_faces then
				local below = get_sturdy_faces (x, y1 - 1, z)
				if band (below, FACE_UP) ~= 0 then
					local wood_cid = mineshaft_wood_cid
					-- Construct pillar.
					for y = y1, y - 1 do
						mineshaft_set_block (x, y, z, wood_cid, 0)
					end
					break
				end
				continue_pillars = progress < 20
			else
				continue_pillars = false
			end
		end
		if continue_chains then
			local y1 = y + progress
			local cid, _ = get_block (x, y1, z)
			if (cid == cid_air or cid == cid_water_source)
				and get_sturdy_faces then
				local above = get_sturdy_faces (x, y1 + 1, z)
				if band (above, FACE_DOWN) ~= 0 then
					-- Construct chains.
					mineshaft_set_block (x, y + 1, z, mineshaft_fence_cid, 0)
					for y = y + 2, y1 do
						mineshaft_set_block (x, y, z, cid_chain, 0)
					end
					break
				end
				continue_chains = progress < 50
			else
				continue_chains = false
			end
		end

		progress = progress + 1
	end
end

local function essay_chains_and_pillars (piece, lx, ly, lz)
	local x, y, z = reorientate_coords (piece, lx, ly, lz)
	local cid, _ = get_block (x, y, z)
	if cid == mineshaft_planks_cid then
		build_chains_or_pillars (x, y, z)
	end

	local x, y, z = reorientate_coords (piece, lx + 2, ly, lz)
	local cid, _ = get_block (x, y, z)
	if cid == mineshaft_planks_cid then
		build_chains_or_pillars (x, y, z)
	end
end

local opaque_p = mcl_levelgen.opaque_p
local notify_generated = mcl_levelgen.notify_generated

local function create_chest (self, rng, x, y, z)
	local loot_seed = mathabs (rng:next_integer ())
	local x, y, z = reorientate_coords (self, x, y, z)
	local cid, _ = get_block (x, y, z)
	if cid ~= cid_air then
		return nil
	end
	local cid_below, _ = get_block (x, y - 1, z)
	if cid_below == cid_air then
		return nil
	end
	mineshaft_set_block (x, y, z, cid_rail, 0)
	notify_generated ("mcl_levelgen:minecart_chest_constructor", x, y, z, {
		x = x,
		y = y,
		z = z,
		loot_seed = loot_seed,
	})
end

local is_walkable = mcl_levelgen.is_walkable

local function create_spider (self, rng, start_z, terrain, x1, z1, x2, z2)
	local z = start_z + rng:next_within (3)
	local x, y, z = reorientate_coords (self, 1, 0, z)
	local _, motion_blocking = index_heightmap (x, z, true)

	if motion_blocking == level_min then
		motion_blocking = terrain:get_one_height (x, z, is_walkable)
	end

	if y < motion_blocking then
		if x >= x1 and x <= x2 and z >= z1 and z <= z2 then
			mineshaft_set_block (x, y, z, cid_mob_spawner, 0)
			notify_generated ("mcl_levelgen:mob_spawner_constructor", x, y, z, {
				x = x,
				y = y,
				z = z,
				mob = "mobs_mc:cave_spider",
			})
		end

		return true
	end
	return false
end

local function corridor_place (self, level, terrain, rng, x1, z1, x2, z2)
	mineshaft_setup (self)
	if extents_valid_p (self.bbox, x1, z1, x2, z2) then
		local num = self.num
		local length = num * 5 - 1
		fill_box_rotated (self, 0, 0, 0, 2, 1, length, cid_air, 0,
				  1.0, rng)
		fill_box_rotated (self, 0, 2, 0, 2, 2, length, cid_air, 0,
				  0.8, rng)
		local place_spiders = self.place_spiders
		if place_spiders then
			fill_buried_air_in_box (self, 0, 0, 0, 2, 1, length,
						cid_cobweb, 0, 0.6, rng)
		end
		local spider_created_p = false

		for section = 0, num - 1 do
			local start_z = section * 5 + 2
			generate_supports (self, rng, 0, 0, start_z, 2, 2, rng)

			-- Place cobwebs beside the arches.
			essay_cobweb (self, rng, 0.1, 0, 2, start_z - 1)
			essay_cobweb (self, rng, 0.1, 2, 2, start_z - 1)
			essay_cobweb (self, rng, 0.1, 0, 2, start_z + 1)
			essay_cobweb (self, rng, 0.1, 2, 2, start_z + 1)
			essay_cobweb (self, rng, 0.05, 0, 2, start_z - 2)
			essay_cobweb (self, rng, 0.05, 2, 2, start_z - 2)
			essay_cobweb (self, rng, 0.05, 0, 2, start_z + 2)
			essay_cobweb (self, rng, 0.05, 2, 2, start_z + 2)

			if rng:next_within (100) == 0 then
				create_chest (self, rng, 2, 0, start_z - 1)
			end
			if rng:next_within (100) == 0 then
				create_chest (self, rng, 0, 0, start_z + 1)
			end
			if place_spiders and not spider_created_p then
				spider_created_p = create_spider (self, rng, start_z,
								  terrain, x1, z1, x2, z2)
			end
		end

		-- Patch up the floor.
		for x, y, z in ipos3 (0, -1, 0, 2, -1, length) do
			local x, y, z = reorientate_coords (self, x, y, z)
			patch_up_floor (x, y, z)
		end

		-- Generate chain supports two blocks inset.
		essay_chains_and_pillars (self, 0, -1, 2)
		if num > 1 then
			essay_chains_and_pillars (self, 0, -1, length - 2)
		end

		if self.place_rails then
			for z = 0, length do
				local x, y, z = reorientate_coords (self, 1, -1, z)
				local cid, _ = get_block (x, y, z)
				if cid ~= cid_air and (not opaque_p or opaque_p (cid)) then
					local _, motion_blocking = index_heightmap (x, z, false)
					local chance = 0.9
					if y < motion_blocking then
						chance = 0.7
					end
					if rng:next_float () < chance then
						mineshaft_set_block (x, y + 1, z, cid_rail, 0)
					end
				end
			end
		end
	end
end

local function create_corridor_piece (rng, parlor, depth, bbox, dir)
	local place_rails = rng:next_within (3) == 0
	local place_spiders = not place_rails
		and rng:next_within (23) == 0
	local length = dir_x_axis_p (dir)
		and bbox_width_x (bbox)
		or  bbox_width_z (bbox)

	return {
		dir = dir,
		depth = depth,
		bbox = bbox,
		place_rails = place_rails,
		place_spiders = place_spiders,
		num = floor (length / 5),
		insert_children = corridor_insert_children,
		place = corridor_place,
		is_mesa = parlor.is_mesa,
	}
end

local function create_corridor_bbox (pieces, rng, dir, x, y, z)
	local bbox = {}
	for i = rng:next_within (3) + 2, 1, -1 do
		local length = i * 5

		if dir == "north" then
			bbox[1] = x
			bbox[2] = y
			bbox[3] = z - length + 1
			bbox[4] = x + 2
			bbox[5] = y + 2
			bbox[6] = z
		elseif dir == "south" then
			bbox[1] = x
			bbox[2] = y
			bbox[3] = z
			bbox[4] = x + 2
			bbox[5] = y + 2
			bbox[6] = z + length - 1
		elseif dir == "west" then
			bbox[1] = x - length + 1
			bbox[2] = y
			bbox[3] = z
			bbox[4] = x
			bbox[5] = y + 2
			bbox[6] = z + 2
		elseif dir == "east" then
			bbox[1] = x
			bbox[2] = y
			bbox[3] = z
			bbox[4] = x + length - 1
			bbox[5] = y + 2
			bbox[6] = z + 2
		end

		if not any_collisions (pieces, bbox) then
			return bbox
		end
	end
	return nil
end

-- Piece selection.

local function create_random_piece (parlor, parent, rng, pieces, x, y, z,
				    dir, depth)
	local selector = rng:next_within (100)
	-- if parlor.bbox[1] == 720 + 2 and parlor.bbox[3] == 8176 + 2 then
	-- 	-- print (string.format ("X, Y, Z, value, dir: %d,%d,%d: %d %s", x, y, z,
	-- 	--			 selector, dir))
	-- end
	if selector >= 80 then
		local bbox = create_junction_bbox (rng, dir, x, y, z)
		if not any_collisions (pieces, bbox) then
			return create_junction_piece (rng, parlor, depth, bbox, dir)
		end
	elseif selector >= 70 then
		local bbox = create_staircase_bbox (rng, dir, x, y, z)
		if not any_collisions (pieces, bbox) then
			return create_staircase_piece (rng, parlor, depth, bbox, dir)
		end
	else
		local bbox = create_corridor_bbox (pieces, rng, dir, x, y, z)
		if bbox then
			return create_corridor_piece (rng, parlor, depth, bbox, dir)
		end
	end
	return nil
end

function generate_random_piece (parlor, parent, rng, pieces, x, y, z,
				dir, depth)
	if depth > 8 then
		return nil
	elseif mathabs (x - parlor.bbox[1]) <= 80
		and mathabs (z - parlor.bbox[3]) <= 80 then
		local piece = create_random_piece (parlor, parent, rng, pieces, x, y, z,
						   dir, depth + 1)
		-- if piece and parlor.bbox[1] == 720 + 2 and parlor.bbox[3] == 8176 + 2 then
		-- 	-- print ("  Created piece successfully with depth: "
		-- 	--        .. string.format ("%d (%d,%d,%d) - (%d,%d,%d)",
		-- 	-- 			 piece.depth, unpack (piece.bbox)))
		-- end
		if piece then
			insert (pieces, piece)
			piece:insert_children (parlor, rng, pieces)
		end
		return piece
	else
		-- print (string.format ("Rejected: %d,%d,%d: %d/%d",
		-- 		      x, y, z, mathabs (x - parlor.bbox[1]),
		-- 		      mathabs (z - parlor.bbox[3])))
		return nil
	end
end

------------------------------------------------------------------------
-- Mineshaft parlor.
------------------------------------------------------------------------

local function generate_rounded_ceiling (x1, y1, z1, x2, y2, z2,
					 min_x, max_x, min_z, max_z)
	local xtotal = x2 - x1 + 1
	local ztotal = z2 - z1 + 1
	local ytotal = y2 - y1 + 1
	local xcenter = x1 + xtotal / 2
	local zcenter = z1 + ztotal / 2

	for x, y, z in ipos3 (mathmax (min_x, x1),
			      y1,
			      mathmax (min_z, z1),
			      mathmin (max_x, x2),
			      y2,
			      mathmin (max_z, z2)) do
		local dy = (y - y1) / ytotal
		local dx = (x - xcenter) / (xtotal * 0.5)
		local dz = (z - zcenter) / (ztotal * 0.5)
		local d = dx * dx + dy * dy + dz * dz
		if d <= 1.05 then
			mineshaft_set_block (x, y, z, cid_air, 0)
		end
	end
end

local function clear_entrance (bbox, min_x, max_x, min_z, max_z)
	for x, y, z in ipos3 (mathmax (bbox[1], min_x),
			      bbox[5] - 2,
			      mathmax (bbox[3], min_z),
			      mathmin (bbox[4], max_x),
			      bbox[5],
			      mathmin (bbox[6], max_z)) do
		mineshaft_set_block (x, y, z, cid_air, 0)
	end
end

local function parlor_place (self, level, terrain, rng, x1, z1, x2, z2)
	mineshaft_setup (self)
	if extents_valid_p (self.bbox, x1, z1, x2, z2) then
		local bbox = self.bbox
		for x, y, z in ipos3 (mathmax (x1, bbox[1]),
				      bbox[2] + 1,
				      mathmax (z1, bbox[3]),
				      mathmin (x2, bbox[4]),
				      bbox[2] + 3,
				      mathmin (z2, bbox[6])) do
			mineshaft_set_block (x, y, z, cid_air, 0)
		end

		generate_rounded_ceiling (bbox[1], bbox[2] + 4, bbox[3],
					  bbox[4], bbox[5], bbox[6],
					  x1, x2, z1, z2)
		for _, bbox in ipairs (self.entrances) do
			clear_entrance (bbox, x1, x2, z1, z2)
		end
	end
end

local function create_parlor (depth, rng, x, z, is_mesa)
	local bbox = {
		x, 50, z,
		x + 7 + rng:next_within (6),
		54 + rng:next_within (6),
		z + 7 + rng:next_within (6),
	}
	return {
		depth = depth,
		bbox = bbox,
		entrances = {},
		is_mesa = is_mesa,
		place = parlor_place,
	}
end

local function insert_parlor_children (rng, pieces, parlor)
	local depth = parlor.depth
	local bbox = parlor.bbox
	local room_height = bbox_height (bbox) - 3 - 1
	if room_height <= 0 then
		room_height = 1
	end

	local width_x = bbox_width_x (bbox)

	-- Create exits along each cardinal direction. at random
	-- intervals.

	-- North.
	local exits_spanned = 0
	while exits_spanned < width_x do
		exits_spanned = exits_spanned + rng:next_within (width_x)
		if exits_spanned + 3 > width_x then
			break
		end

		local piece
			= generate_random_piece (parlor, parlor, rng, pieces,
						 bbox[1] + exits_spanned,
						 bbox[2] + rng:next_within (room_height) + 1,
						 bbox[3] - 1, "north", depth)
		if piece then
			-- Vacate the section of the wall between this
			-- room and the generated piece.
			local piece_bbox = piece.bbox
			insert (parlor.entrances, {
				piece_bbox[1],
				piece_bbox[2],
				bbox[3],
				piece_bbox[4],
				piece_bbox[5],
				bbox[3] + 1,
			})
		end

		exits_spanned = exits_spanned + 4
	end

	-- South.
	local exits_spanned = 0
	while exits_spanned < width_x do
		exits_spanned = exits_spanned + rng:next_within (width_x)
		if exits_spanned + 3 > width_x then
			break
		end
		local value = rng:next_within (room_height) + 1
		-- print ("K: " .. value .. " " .. width_x)
		local piece
			= generate_random_piece (parlor, parlor, rng, pieces,
						 bbox[1] + exits_spanned,
						 bbox[2] + value,
						 bbox[6] + 1, "south", depth)
		if piece then
			-- Vacate the section of the wall between this
			-- room and the generated piece.
			local piece_bbox = piece.bbox
			insert (parlor.entrances, {
				piece_bbox[1],
				piece_bbox[2],
				bbox[6] - 1,
				piece_bbox[4],
				piece_bbox[5],
				bbox[6],
			})
		end
		exits_spanned = exits_spanned + 4
	end

	local width_z = bbox_width_z (bbox)

	-- West.
	local exits_spanned = 0
	while exits_spanned < width_z do
		exits_spanned = exits_spanned + rng:next_within (width_z)
		if exits_spanned + 3 > width_z then
			break
		end
		local piece
			= generate_random_piece (parlor, parlor, rng, pieces,
						 bbox[1] - 1,
						 bbox[2] + rng:next_within (room_height) + 1,
						 bbox[3] + exits_spanned, "west", depth)
		if piece then
			-- Vacate the section of the wall between this
			-- room and the generated piece.
			local piece_bbox = piece.bbox
			insert (parlor.entrances, {
				bbox[1],
				piece_bbox[2],
				piece_bbox[3],
				bbox[1] + 1,
				piece_bbox[5],
				piece_bbox[6],
			})
		end
		exits_spanned = exits_spanned + 4
	end

	-- East.
	local exits_spanned = 0
	while exits_spanned < width_z do
		exits_spanned = exits_spanned + rng:next_within (width_z)
		if exits_spanned + 3 > width_z then
			break
		end
		local piece
			= generate_random_piece (parlor, parlor, rng, pieces,
						 bbox[4] + 1,
						 bbox[2] + rng:next_within (room_height) + 1,
						 bbox[3] + exits_spanned, "east", depth)
		if piece then
			-- Vacate the section of the wall between this
			-- room and the generated piece.
			local piece_bbox = piece.bbox
			insert (parlor.entrances, {
				bbox[4] - 1,
				piece_bbox[2],
				piece_bbox[3],
				bbox[4],
				piece_bbox[5],
				piece_bbox[6],
			})
		end
		exits_spanned = exits_spanned + 4
	end
end

------------------------------------------------------------------------
-- Mineshaft structure.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/structure/MineshaftStructure.html
------------------------------------------------------------------------

local bbox_from_pieces = mcl_levelgen.bbox_from_pieces
local bbox_center = mcl_levelgen.bbox_center

local function mineshaft_create_pieces (self, pieces, level, terrain, rng, x, z)
	rng:next_double ()
	local parlor = create_parlor (0, rng, x + 2, z + 2, self.is_mesa)
	insert (pieces, parlor)
	insert_parlor_children (rng, pieces, parlor)

	local preset = level.preset
	local sea_level = preset.sea_level
	local dy
	if self.is_mesa then
		local bbox = bbox_from_pieces (pieces)
		local x, y, z = bbox_center (bbox)
		local surface = terrain:get_one_height (x, z, nil)
		local target_center = sea_level
		if surface > sea_level then
			local diff = (surface - sea_level) + 1
			target_center = rng:next_within (diff) + sea_level
		end
		dy = target_center - y
		mcl_levelgen.translate_vertically (pieces, dy)
	else
		-- print ("Unified bb: " .. string.format ("(%d,%d,%d) - (%d,%d,%d)",
		-- 					unpack (bbox_from_pieces (pieces))))
		dy = mcl_levelgen.shift_into (pieces, sea_level, preset.min_y,
					      rng, 10)
		-- print (" Mineshaft dy: " .. dy)
	end
	for _, entrance in ipairs (parlor.entrances) do
		entrance[2] = entrance[2] + dy
		entrance[5] = entrance[5] + dy
	end
	return dy
end

local function mineshaft_create_start (self, level, terrain, rng, cx, cz)
	local x = cx * 16
	local z = cz * 16
	local center_x = x + 8
	local center_z = z + 8
	local center_y = 50
	local pieces = {}
	local dy = mineshaft_create_pieces (self, pieces, level, terrain, rng, x, z)
	if mcl_levelgen.structure_biome_test (level, self, center_x,
					      center_y + dy,
					      center_z) then
		return mcl_levelgen.create_structure_start (self, pieces)
	end
	return nil
end

------------------------------------------------------------------------
-- Mineshaft structure registration.
------------------------------------------------------------------------

local mineshaft_biomes = {
	"#is_beach",
	"#is_forest",
	"#is_hill",
	"#is_jungle",
	"#is_mountain",
	"#is_ocean",
	"#is_river",
	"#is_taiga",
	"Desert",
	"DripstoneCaves",
	"IceSpikes",
	"LushCaves",
	"MangroveSwamp",
	"MushroomIslands",
	"Plains",
	"Savannah",
	"SavannahPlateau",
	"SnowyPlains",
	"StonyShore",
	"SunflowerPlains",
	"Swamp",
	"WindsweptSavannah",
}

local mineshaft_mesa_biomes = {
	"#is_badlands",
}

mcl_levelgen.modify_biome_groups (mineshaft_biomes, {
	has_mineshaft = true,
})

mcl_levelgen.modify_biome_groups (mineshaft_mesa_biomes, {
	has_mineshaft_mesa = true,
})

mcl_levelgen.modify_biome_groups ({"DeepDark",}, {
	mineshaft_blocking = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:mineshaft", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = mineshaft_create_start,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_mineshaft",}),
	is_mesa = false,
})

mcl_levelgen.register_structure ("mcl_levelgen:mineshaft_mesa", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = mineshaft_create_start,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_mineshaft_mesa",}),
	is_mesa = true,
})

mcl_levelgen.register_structure_set ("mcl_levelgen:mineshafts", {
	structures = {
		"mcl_levelgen:mineshaft",
		"mcl_levelgen:mineshaft_mesa",
	},
	placement = R (0.004, "legacy_type_3", 1, 0, 0, "linear", nil, nil),
})
