local C = mcl_levelgen.build_concentric_ring_placement

------------------------------------------------------------------------
-- Stronghold loot tables.
------------------------------------------------------------------------

local stronghold_loot_pools = {
	corridor = {
		{
			stacks_min = 2,
			stacks_max = 3,
			items = {
				{ itemstring = "mcl_core:apple", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_throwing:ender_pearl", weight = 10, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_redstone:redstone", weight = 5, amount_min = 4, amount_max = 9 },
				{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_tools:pick_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_tools:sword_iron", weight = 5, amount_min = 1, amount_max=3 },

				{ itemstring = "mcl_armor:helmet_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:chestplate_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:leggings_iron", weight = 5, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_armor:boots_iron", weight = 5, amount_min = 1, amount_max=3 },

				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },

				{ itemstring = "mcl_jukebox:record_7", weight = 1, },
				{
					itemstring = "mcl_books:book", weight = 1,
					func = function (stack, pr)
						mcl_enchanting.enchant_randomly (stack, 30, true, false, false, pr)
					end,
				},
				{ itemstring = "mcl_mobitems:saddle", weight = 1, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold", weight = 1, },
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_armor:eye", weight = 1, amount_min = 1, amount_max = 1 },
			}
		},
	},
	crossing = {
		{
			stacks_min = 1,
			stacks_max = 4,
			items = {
				{
					itemstring = "mcl_core:iron_ingot",
					weight = 10,
					amount_min = 1,
					amount_max = 5,
				},
				{
					itemstring = "mcl_core:gold_ingot",
					weight = 5,
					amount_min = 1,
					amount_max = 3,
				},
				{
					itemstring = "mcl_redstone:redstone",
					weight = 5,
					amount_min = 4,
					amount_max = 9,
				},
				{
					itemstring = "mcl_core:coal_lump",
					weight = 10,
					amount_min = 3,
					amount_max = 8,
				},
				{
					itemstring = "mcl_farming:bread",
					weight = 15,
					amount_min = 1,
					amount_max = 3,
				},
				{
					itemstring = "mcl_core:apple",
					weight = 15,
					amount_min = 1,
					amount_max = 3,
				},
				{
					itemstring = "mcl_tools:pick_iron",
				},
				{
					itemstring = "mcl_books:book",
					func = function (stack, pr)
						mcl_enchanting.enchant_randomly (stack, 30, true, false, false, pr)
					end,
				},
			},
		},
	},
	library = {
		{
			stacks_min = 2,
			stacks_max = 10,
			items = {
				{
					itemstring = "mcl_books:book",
					weight = 20,
					amount_min = 1,
					amount_max = 3,
				},
				{
					itemstring = "mcl_core:paper",
					weight = 20,
					amount_min = 2,
					amount_max = 7,
				},
				{
					itemstring = "mcl_maps:empty_map",
				},
				{
					itemstring = "mcl_compass:compass",
				},
				{
					itemstring = "mcl_books:book",
					func = function (stack, pr)
						mcl_enchanting.enchant_randomly (stack, 30, true, false, false, pr)
					end,
					weight = 10,
				},
			},
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{
					itemstring = "mcl_armor:eye",
					weight = 1,
				},
			},
		},
	},
}

------------------------------------------------------------------------
-- Stronghold placement.
------------------------------------------------------------------------

local stronghold_biased_to_biomes = {
	"BambooJungle",
	"BirchForest",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenPeaks",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LushCaves",
	"Meadow",
	"Mesa",
	"MushroomIslands",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"Savannah",
	"SavannahPlateau",
	"SnowyPlains",
	"SnowySlopes",
	"SnowyTaiga",
	"SparseJungle",
	"StonyPeaks",
	"SunflowerPlains",
	"Taiga",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

mcl_levelgen.modify_biome_groups (stronghold_biased_to_biomes, {
	stronghold_biased_to = true,
})

mcl_levelgen.modify_biome_groups ({"#is_overworld",}, {
	has_stronghold = true,
})

mcl_levelgen.register_concentric_ring_configuration ("mcl_levelgen:strongholds", {
	count = 128,
	distance = 32,
	spread = 3,
	preferred_biomes = mcl_levelgen.build_biome_list ({"#stronghold_biased_to",}),
})

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local v = vector.zero ()

local function handle_stronghold_chest (_, data)
	local x, y, z = level_to_minetest_position (data.x, data.y, data.z)
	v.x = x
	v.y = y
	v.z = z
	core.load_area (v)
	local node = core.get_node (v)
	if node.name == "mcl_chests:chest_small" then
		mcl_structures.init_node_construct (v)
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()

		local pool = stronghold_loot_pools[data.loot_type]
		assert (pool)
		local pr = PcgRandom (data.loot_seed)
		local loot = mcl_loot.get_multi_loot (pool, pr)
		mcl_loot.fill_inventory (inv, "main", loot, pr)
	end
end

local function handle_check_end_portal_frame (_, data)
	for _, pos in ipairs (data) do
		local x, y, z
			= level_to_minetest_position (pos[1], pos[2], pos[3])
		v.x = x
		v.y = y
		v.z = z
		core.load_area (v)
		mcl_portals.maybe_activate_end_portal (v, true)
	end
end

if not mcl_levelgen.is_levelgen_environment then
	core.register_on_mods_loaded (function ()
		mcl_levelgen.prime_concentric_placement (mcl_levelgen.overworld_preset,
							 "mcl_levelgen:strongholds")
	end)

	mcl_levelgen.register_notification_handler ("mcl_levelgen:stronghold_chest",
						    handle_stronghold_chest)
	mcl_levelgen.register_notification_handler ("mcl_levelgen:check_end_portal_frame",
						    handle_check_end_portal_frame)
end

------------------------------------------------------------------------
-- Stronghold structure.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/world/gen/structure/StrongholdStructure.html
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/structure/StrongholdGenerator.html
------------------------------------------------------------------------

local mathabs = math.abs
local mathmax = math.max
local mathmin = math.min

-- Block-filling utilities.

local notify_generated = mcl_levelgen.notify_generated
local reorientate_coords = mcl_levelgen.reorientate_coords
local ipos3 = mcl_levelgen.ipos3

local function getcid (name)
	if mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		return nil
	end
end

local cid_cracked_stone_bricks
	= getcid ("mcl_core:stonebrickcracked")
local cid_mossy_stone_bricks
	= getcid ("mcl_core:stonebrickmossy")
local cid_infested_stone_bricks
	= getcid ("mcl_monster_eggs:monster_egg_stonebrickcracked")
local cid_stone_bricks
	= getcid ("mcl_core:stonebrick")
local cid_air = core.CONTENT_AIR

local get_block = mcl_levelgen.get_block
local set_block = mcl_levelgen.set_block

local function select_infested (rng)
	local value = rng:next_float ()
	local cid
	if value < 0.2 then
		cid = cid_cracked_stone_bricks
	elseif value < 0.5 then
		cid = cid_mossy_stone_bricks
	elseif value < 0.55 then
		cid = cid_infested_stone_bricks
	else
		cid = cid_stone_bricks
	end
	return cid
end

local function generate_tunnel (piece, x1, y1, z1, x2, y2, z2, rng)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		local cid, _ = get_block (x, y, z)
		if cid ~= cid_air then
			if x == x1 or x == x2 or z == z1
				or z == z2 or y == y1 or y == y2 then
				local cid = select_infested (rng)
				set_block (x, y, z, cid, 0)
			else
				set_block (x, y, z, cid_air, 0)
			end
		end
	end
end

local function generate_lined_void (piece, x1, y1, z1, x2, y2, z2, rng)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if x == x1 or x == x2 or z == z1
			or z == z2 or y == y1 or y == y2 then
			local cid = select_infested (rng)
			set_block (x, y, z, cid, 0)
		else
			set_block (x, y, z, cid_air, 0)
		end
	end
end

local function fill_area (piece, chance, x1, y1, z1, x2, y2, z2,
			  cid, param2, rng)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if chance == 1.0 or rng:next_float () < chance then
			set_block (x, y, z, cid, param2)
		end
	end
end

local cid_chest_small = getcid ("mcl_chests:chest_small")

local function generate_stronghold_chest (self, dx, dy, dz, param2, rng, loot_type)
	local x, y, z = reorientate_coords (self, dx, dy, dz)
	set_block (x, y, z, cid_chest_small, param2)
	notify_generated ("mcl_levelgen:stronghold_chest", x, y, z, {
		x = x,
		y = y,
		z = z,
		loot_type = loot_type,
		loot_seed = mathabs (rng:next_integer ()),
	})
end

local facedirs = {
	north = 0,
	east = 1,
	south = 2,
	west = 3,
}

local reverse_facedirs = {
	north = 2,
	east = 3,
	south = 0,
	west = 1,
}

local left_facedirs = {
	north = 3,
	south = 1,
	west = 2,
	east = 0,
}

local right_facedirs = {
	north = 1,
	south = 3,
	west = 0,
	east = 2,
}

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

local left_wallmounted = {
	north = 3,
	south = 3,
	west = 4,
	east = 4,
}

local right_wallmounted = {
	north = 2,
	south = 2,
	west = 5,
	east = 5,
}

-- Return a facedir value facing that direction which increases along
-- the X axis of a corridor whose orientation is DIR prior to
-- reorientation and mirroring.

local function local_facedir_right (dir)
	if dir == "south" or dir == "west" then
		-- In these directions +X (or +Z) stands towards the
		-- left.
		return left_facedirs[dir]
	else
		return right_facedirs[dir]
	end
end

local function local_facedir_left (dir)
	if dir == "south" or dir == "west" then
		-- In these directions -X (or -Z) stands towards the
		-- right.
		return right_facedirs[dir]
	else
		return left_facedirs[dir]
	end
end

local function set_block_reorientated (piece, x, y, z, cid, param2)
	local x, y, z = reorientate_coords (piece, x, y, z)
	set_block (x, y, z, cid, param2)
end

local cid_oak_door_lower
	= getcid ("mcl_doors:door_oak_b_1")
local cid_oak_door_upper
	= getcid ("mcl_doors:door_oak_t_1")
local cid_iron_door_lower
	= getcid ("mcl_doors:iron_door_b_1")
local cid_iron_door_upper
	= getcid ("mcl_doors:iron_door_t_1")
local cid_iron_bars
	= getcid ("mcl_panes:bar_flat")
local cid_iron_bars_junction
	= getcid ("mcl_panes:bar")
local cid_stone_button
	= getcid ("mcl_buttons:button_stone_off")

local function generate_door (piece, kind, dx, dy, dz)
	if kind == "void" then
		fill_area (piece, 1.0, dx, dy, dz, dx + 2, dy + 2, dz,
			   cid_air, 0, nil)
	elseif kind == "wood" then
		for i = 0, 2 do
			set_block_reorientated (piece, dx, dy + i, dz, cid_stone_bricks, 0)
			set_block_reorientated (piece, dx + 2, dy + i, dz, cid_stone_bricks, 0)
		end
		set_block_reorientated (piece, dx + 1, dy + 2, dz, cid_stone_bricks, 0)
		local param2 = facedirs[piece.dir]
		set_block_reorientated (piece, dx + 1, dy + 1, dz, cid_oak_door_upper, param2)
		set_block_reorientated (piece, dx + 1, dy, dz, cid_oak_door_lower, param2)
	elseif kind == "bars" then
		local param2 = facedirs[piece.dir]
		fill_area (piece, 1.0, dx, dy + 2, dz, dx + 2, dy + 2, dz, cid_iron_bars,
			   param2, nil)
		fill_area (piece, 1.0, dx, dy, dz, dx + 2, dy + 1, dz, cid_iron_bars_junction,
			   param2, nil)
		set_block_reorientated (piece, dx + 1, dy, dz, cid_air, 0)
		set_block_reorientated (piece, dx + 1, dy + 1, dz, cid_air, 0)
	elseif kind == "iron" then
		for i = 0, 2 do
			set_block_reorientated (piece, dx, dy + i, dz, cid_stone_bricks, 0)
			set_block_reorientated (piece, dx + 2, dy + i, dz, cid_stone_bricks, 0)
		end
		set_block_reorientated (piece, dx + 1, dy + 2, dz, cid_stone_bricks, 0)
		local dir = piece.dir
		local param2 = facedirs[piece.dir]
		set_block_reorientated (piece, dx + 1, dy + 1, dz, cid_iron_door_upper, param2)
		set_block_reorientated (piece, dx + 1, dy, dz, cid_iron_door_lower, param2)
		set_block_reorientated (piece, dx + 2, dy + 1, dz + 1, cid_stone_button,
					reverse_wallmounted[dir])
		set_block_reorientated (piece, dx + 2, dy + 1, dz - 1, cid_stone_button,
					wallmounted[dir])
	else
		assert (false)
	end
end

local insert = table.insert

local random_orientation = mcl_levelgen.random_orientation
local make_rotated_bbox = mcl_levelgen.make_rotated_bbox

local huge = math.huge

local ALL_PIECES = {
	{"corridor", 40, huge,},
	{"prison_hall", 5, 5,},
	{"left", 20, huge,},
	{"right", 20, huge,},
	{"square_room", 10, 6,},
	{"stairs", 5, 5,},
	{"stairs_down", 5, 5,},
	{"five_way_crossing", 5, 4,},
	{"chest_corridor", 5, 4,},
	{"library", 10, 2, 4,},
	{"portal_room", 20, 1, 5},
}

-- local DOOR_TYPES = {
-- 	"void",
-- 	"wood",
-- 	"bars",
-- 	"iron",
-- }

local function random_door_type (rng)
	local k = rng:next_within (5)
	if k <= 1 then
		return "void"
	elseif k == 2 then
		return "wood"
	elseif k == 3 then
		return "bars"
	else
		return "iron"
	end
end

local function get_pos_after_door (self, dx, dy)
	local dir = self.dir
	local bbox = self.bbox

	if dir == "north" then
		return bbox[1] + dx, bbox[2] + dy, bbox[3] - 1
	elseif dir == "south" then
		return bbox[1] + dx, bbox[2] + dy, bbox[6] + 1
	elseif dir == "west" then
		return bbox[1] - 1, bbox[2] + dy, bbox[3] + dx
	elseif dir == "east" then
		return bbox[4] + 1, bbox[2] + dy, bbox[3] + dx
	end
	assert (false)
end

local function get_dir_and_pos_to_left (self, dy, dz)
	local dir = self.dir
	local bbox = self.bbox

	if dir == "north" or dir == "south" then
		return "west", bbox[1] - 1, bbox[2] + dy, bbox[3] + dz
	elseif dir == "east" or dir == "west" then
		return "north", bbox[1] + dz, bbox[2] + dy, bbox[3] - 1
	end
	assert (false)
end

local function get_dir_and_pos_to_right (self, dy, dz)
	local dir = self.dir
	local bbox = self.bbox

	if dir == "north" or dir == "south" then
		return "east", bbox[4] + 1, bbox[2] + dy, bbox[3] + dz
	elseif dir == "east" or dir == "west" then
		return "south", bbox[1] + dz, bbox[2] + dy, bbox[6] + 1
	end
	assert (false)
end

local portal_room_piece = nil
local child_queue = {}
local count_placed = {}
local previous_piece_type = nil

local function piece_available_p (piece)
	return count_placed[piece[1]] < piece[3]
end

local function produce_pieces ()
	local total_weight = 0
	local have_limited = false

	for _, piece in ipairs (ALL_PIECES) do
		if piece_available_p (piece) then
			if piece[3] ~= huge then
				have_limited = true
			end
			total_weight = total_weight + piece[2]
		end
	end
	return total_weight, have_limited
end

local essay_corridor
local essay_prison_hall
local essay_left_turn
local essay_right_turn
local essay_square_room
local essay_stairs
local essay_stairs_down
local essay_five_way_crossing
local essay_chest_corridor
local essay_library
local make_portal_room

local function instantiate_piece (piecetype, start, pieces, rng, x, y, z, dir, depth)
	if piecetype == "corridor" then
		return essay_corridor (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "prison_hall" then
		return essay_prison_hall (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "left" then
		return essay_left_turn (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "right" then
		return essay_right_turn (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "square_room" then
		return essay_square_room (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "stairs" then
		return essay_stairs (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "stairs_down" then
		return essay_stairs_down (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "five_way_crossing" then
		return essay_five_way_crossing (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "chest_corridor" then
		return essay_chest_corridor (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "library" then
		return essay_library (start, pieces, rng, x, y, z, dir, depth)
	elseif piecetype == "portal_room" then
		return make_portal_room (start, pieces, x, y, z, dir, depth)
	end

	assert (false)
end

local create_blind_alley

local function generate_child_piece (start, parent, pieces, rng, x, y, z, dir,
				     depth, override)
	local total, have_limited = produce_pieces ()

	if not have_limited then
		return nil
	end

	if override then
		-- print ("Stronghold override: " .. override)
		local piece_new = instantiate_piece (override, start, pieces, rng,
						     x, y, z, dir, depth)
		if piece_new then
			piece_new.type = override
			return piece_new
		end
	end

	for i = 1, 5 do
		local weight = rng:next_within (total)
		-- print ("Stronghold attempt: " .. i .. ": " .. weight .. " (of total " .. total .. ")")
		-- print ("  Parent: " .. (parent.type or "unknown") .. "; depth = " .. depth)

		for _, piece in ipairs (ALL_PIECES) do
			if piece_available_p (piece) then
				weight = weight - piece[2]
				if weight < 0 then
					if not ((not piece[4] or depth > piece[4])
							and piece[1] ~= previous_piece_type) then
						break
					end
					local piecetype = piece[1]
					local piece_new
						= instantiate_piece (piecetype, start,
								     pieces, rng, x, y,
								     z, dir, depth)
					-- print ("Stronghold attempt " .. i .. " yielded "
					--        .. piecetype .. " -> " .. tostring (piece_new))
					if piece_new then
						previous_piece_type = piecetype
						piece_new.type = piecetype
						local cnt = count_placed[piecetype]
						count_placed[piecetype] = cnt + 1
						return piece_new
					end
				end
			end
		end
	end

	return create_blind_alley (pieces, rng, x, y, z, dir, depth)
end

local function select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
					      dir, depth, override)
	if depth > 50 then
		return nil
	else
		-- print (start, x, y, z, (start.bbox[1] - x), (start.bbox[3] - z))
		local dmax = mathmax (mathabs (start.bbox[1] - x),
				      mathabs (start.bbox[3] - z))
		if dmax <= 112 then
			local piece = generate_child_piece (start, self, pieces, rng, x, y, z,
							    dir, depth + 1, override)
			if piece then
				insert (pieces, piece)
				insert (child_queue, piece)
			end
		end
		return nil
	end
end

local rotated_block_box = mcl_levelgen.rotated_block_box
local any_collisions = mcl_levelgen.any_collisions
local first_collision = mcl_levelgen.first_collision
local AABB_intersect_p = mcl_levelgen.AABB_intersect_p

-- Blind alley corridor piece.

-- https://minecraft.wiki/w/Stronghold/Structure#Dead-end_corridors
local function place_blind_alley (pieces, rng, x, y, z, dir)
	local base_box = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, 4, dir)

	-- Locate a piece to which to connect.
	local colliding = first_collision (pieces, base_box)
	if not colliding then
		return nil
	end

	local bbox_1 = colliding.bbox
	-- Must be aligned vertically.
	if bbox_1[2] ~= base_box[2] then
		return nil
	end

	-- Retract the corridor till it is no longer in contact with
	-- this portion of the stronghold.
	for dx = 2, 1, -1 do
		local box_1 = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, dx, dir)
		if not AABB_intersect_p (box_1, bbox_1) then
			-- Return a bounding box in contact with its wall
			return rotated_block_box (x, y, z, -1, -1, 0, 5, 5, dx + 1, dir)
		end
	end
	return nil
end

local bbox_width_x = mcl_levelgen.bbox_width_x
local bbox_width_z = mcl_levelgen.bbox_width_z

local function blind_alley_place (self, level, terrain, rng, x1, z1, x2, z2)
	local dir = self.dir
	local steps
	if dir == "south" or dir == "north" then
		steps = bbox_width_z (self.bbox)
	else
		steps = bbox_width_x (self.bbox)
	end

	for z = 0, steps - 1 do
		-- Build the floor and ceiling.
		for x = 0, 4 do
			set_block_reorientated (self, x, 0, z, cid_stone_bricks, 0)
			set_block_reorientated (self, x, 4, z, cid_stone_bricks, 0)

			-- Build the center.
			for y = 1, 3 do
				if x >= 1 and x <= 3 then
					set_block_reorientated (self, x, y, z, cid_air, 0)
				else
					set_block_reorientated (self, x, y, z, cid_stone_bricks, 0)
				end
			end
		end
	end
end

function create_blind_alley (pieces, rng, x, y, z, dir, depth)
	local bbox = place_blind_alley (pieces, rng, x, y, z, dir)
	if bbox and bbox[2] > 1 then
		return {
			depth = depth,
			bbox = bbox,
			place = blind_alley_place,
			dir = dir,
		}
	end
	return nil
end

-- Corridor piece.

local cid_wall_torch = getcid ("mcl_torches:torch_wall")

local function corridor_insert_children (self, start, pieces, rng)
	local dir = self.dir
	local x, y, z = get_pos_after_door (self, 1, 1)
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng,
				       x, y, z, dir, depth, nil)

	if self.exit_on_left then
		local dir, x, y, z = get_dir_and_pos_to_left (self, 1, 2)
		select_and_insert_child_piece (self, start, pieces, rng,
					       x, y, z, dir, depth, nil)
	end

	if self.exit_on_right then
		local dir, x, y, z = get_dir_and_pos_to_right (self, 1, 2)
		select_and_insert_child_piece (self, start, pieces, rng,
					       x, y, z, dir, depth, nil)
	end
end

local function corridor_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 4, 6, rng)
	generate_door (self, self.entry_door, 1, 1, 0)
	generate_door (self, "void", 1, 1, 6)
	local dir = self.dir
	local left = left_wallmounted[dir]
	local right = right_wallmounted[dir]
	if rng:next_float () < 0.1 then
		set_block_reorientated (self, 1, 2, 1, cid_wall_torch, left)
	end
	if rng:next_float () < 0.1 then
		set_block_reorientated (self, 3, 2, 1, cid_wall_torch, right)
	end
	if rng:next_float () < 0.1 then
		set_block_reorientated (self, 1, 2, 5, cid_wall_torch, left)
	end
	if rng:next_float () < 0.1 then
		set_block_reorientated (self, 3, 2, 5, cid_wall_torch, right)
	end
	if self.exit_on_left then
		fill_area (self, 1.0, 0, 1, 2, 0, 3, 4, cid_air, 0, nil)
	end
	if self.exit_on_right then
		fill_area (self, 1.0, 4, 1, 2, 4, 3, 4, cid_air, 0, nil)
	end
end

function essay_corridor (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, 7, dir)
	-- print (string.format ("corridor bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = corridor_place,
			insert_children = corridor_insert_children,
			bbox = bbox,
			dir = dir,
			depth = depth,
			entry_door = random_door_type (rng),
			exit_on_left = rng:next_within (2) == 0,
			exit_on_right = rng:next_within (2) == 0,
		}
	end
	return nil
end

-- Prison hall piece.

local function prison_hall_insert_children (self, start, pieces, rng)
	local x, y, z = get_pos_after_door (self, 1, 1)
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng,
				       x, y, z, self.dir, depth, nil)
end

local function prison_hall_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Corridor, gaol cell volume & entrance.
	generate_tunnel (self, 0, 0, 0, 8, 4, 10, rng)
	generate_door (self, self.entry_door, 1, 1, 0)

	-- Exit.
	fill_area (self, 1.0, 1, 1, 10, 3, 3, 10, cid_air, 0, nil)

	-- Gaol cell pillars.
	generate_lined_void (self, 4, 1, 1, 4, 3, 1, rng)
	generate_lined_void (self, 4, 1, 3, 4, 3, 3, rng)
	generate_lined_void (self, 4, 1, 7, 4, 3, 7, rng)
	generate_lined_void (self, 4, 1, 9, 4, 3, 9, rng)

	-- Cell doors.
	local param2 = local_facedir_left (self.dir)
	set_block_reorientated (self, 4, 1, 2, cid_iron_door_lower, param2)
	set_block_reorientated (self, 4, 2, 2, cid_iron_door_upper, param2)
	set_block_reorientated (self, 4, 3, 2, cid_iron_bars, param2)
	set_block_reorientated (self, 4, 1, 8, cid_iron_door_lower, param2)
	set_block_reorientated (self, 4, 2, 8, cid_iron_door_upper, param2)
	set_block_reorientated (self, 4, 3, 8, cid_iron_bars, param2)

	-- Cell bars.
	for y = 1, 3 do
		set_block_reorientated (self, 4, y, 4, cid_iron_bars, param2)
		set_block_reorientated (self, 4, y, 5, cid_iron_bars_junction, 0)
		set_block_reorientated (self, 5, y, 5, cid_iron_bars_junction, 0)
		set_block_reorientated (self, 6, y, 5, cid_iron_bars_junction, 0)
		set_block_reorientated (self, 7, y, 5, cid_iron_bars_junction, 0)
		set_block_reorientated (self, 4, y, 6, cid_iron_bars, param2)
	end
end

function essay_prison_hall (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -1, 0, 9, 5, 11, dir)
	-- print (string.format ("prison_hall bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = prison_hall_place,
			insert_children = prison_hall_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Left piece.

local function left_turn_insert_children (self, start, pieces, rng)
	local dir = self.dir
	local x, y, z
	if dir ~= "north" and dir ~= "east" then
		dir, x, y, z = get_dir_and_pos_to_right (self, 1, 1)
	else
		dir, x, y, z = get_dir_and_pos_to_left (self, 1, 1)
	end
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)
end

local function left_turn_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 4, 4, rng)
	generate_door (self, self.entry_door, 1, 1, 0)

	local dir = self.dir
	if dir ~= "north" and dir ~= "east" then
		fill_area (self, 1.0, 4, 1, 1, 4, 3, 3, cid_air, 0, nil)
	else
		fill_area (self, 1.0, 0, 1, 1, 0, 3, 3, cid_air, 0, nil)
	end
end

function essay_left_turn (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, 5, dir)
	-- print (string.format ("left bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = left_turn_place,
			insert_children = left_turn_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Right piece.

local function right_turn_insert_children (self, start, pieces, rng)
	local dir = self.dir
	local x, y, z
	if dir ~= "north" and dir ~= "east" then
		dir, x, y, z = get_dir_and_pos_to_left (self, 1, 1)
	else
		dir, x, y, z = get_dir_and_pos_to_right (self, 1, 1)
	end
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)
end

local function right_turn_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 4, 4, rng)
	generate_door (self, self.entry_door, 1, 1, 0)

	local dir = self.dir
	if dir ~= "north" and dir ~= "east" then
		fill_area (self, 1.0, 0, 1, 1, 0, 3, 3, cid_air, 0, nil)
	else
		fill_area (self, 1.0, 4, 1, 1, 4, 3, 3, cid_air, 0, nil)
	end
end

function essay_right_turn (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, 5, dir)
	-- print (string.format ("right bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = right_turn_place,
			insert_children = right_turn_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Square room piece.

local function square_room_insert_children (self, start, pieces, rng)
	local depth = self.depth
	local x, y, z = get_pos_after_door (self, 4, 1)
	local dir = self.dir
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)
	dir, x, y, z = get_dir_and_pos_to_left (self, 1, 4)
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)
	dir, x, y, z = get_dir_and_pos_to_right (self, 1, 4)
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)
end

local cid_smooth_stone_slab = getcid ("mcl_stairs:slab_stone")
local cid_water_source = getcid ("mcl_core:water_source")
local cid_cobblestone = getcid ("mcl_core:cobble")
local cid_wood_oak = getcid ("mcl_trees:wood_oak")
local cid_ladder = getcid ("mcl_core:ladder")

local function square_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 10, 6, 10, rng)
	generate_door (self, self.entry_door, 4, 1, 0)
	fill_area (self, 1.0, 4, 1, 10, 6, 3, 10, cid_air, 0, nil)
	fill_area (self, 1.0, 0, 1, 4, 0, 3, 6, cid_air, 0, nil)
	fill_area (self, 1.0, 10, 1, 4, 10, 3, 6, cid_air, 0, nil)

	local decor = self.decor

	if decor == "pillar" then
		-- Pillars.
		set_block_reorientated (self, 5, 1, 5, cid_stone_bricks, 0)
		set_block_reorientated (self, 5, 2, 5, cid_stone_bricks, 0)
		set_block_reorientated (self, 5, 3, 5, cid_stone_bricks, 0)

		-- Torches.
		local dir = self.dir
		set_block_reorientated (self, 4, 3, 5, cid_wall_torch,
					right_wallmounted[dir])
		set_block_reorientated (self, 6, 3, 5, cid_wall_torch,
					left_wallmounted[dir])
		set_block_reorientated (self, 5, 3, 4, cid_wall_torch,
					wallmounted[dir])
		set_block_reorientated (self, 5, 3, 6, cid_wall_torch,
					reverse_wallmounted[dir])

		-- Slabs.
		set_block_reorientated (self, 4, 1, 4, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 4, 1, 5, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 4, 1, 6, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 5, 1, 4, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 5, 1, 6, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 6, 1, 4, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 6, 1, 5, cid_smooth_stone_slab, 0)
		set_block_reorientated (self, 6, 1, 6, cid_smooth_stone_slab, 0)
	elseif decor == "fountain" then
		-- Basin.
		for i = 0, 4 do
			set_block_reorientated (self, 3, 1, 3 + i, cid_stone_bricks, 0)
			set_block_reorientated (self, 7, 1, 3 + i, cid_stone_bricks, 0)
			set_block_reorientated (self, 3 + i, 1, 3, cid_stone_bricks, 0)
			set_block_reorientated (self, 3 + i, 1, 7, cid_stone_bricks, 0)
		end

		-- Pillar.
		set_block_reorientated (self, 5, 1, 5, cid_stone_bricks, 0)
		set_block_reorientated (self, 5, 2, 5, cid_stone_bricks, 0)
		set_block_reorientated (self, 5, 3, 5, cid_stone_bricks, 0)

		-- Fountainhead.
		set_block_reorientated (self, 5, 4, 5, cid_water_source, 0)
	elseif decor == "store" then
		for i = 1, 9 do
			-- Rim.
			set_block_reorientated (self, 1, 3, i, cid_cobblestone, 0)
			set_block_reorientated (self, 9, 3, i, cid_cobblestone, 0)
			set_block_reorientated (self, i, 3, 1, cid_cobblestone, 0)
			set_block_reorientated (self, i, 3, 9, cid_cobblestone, 0)
		end

		-- Pillbox.
		set_block_reorientated (self, 4, 1, 5, cid_cobblestone, 0)
		set_block_reorientated (self, 4, 3, 5, cid_cobblestone, 0)
		set_block_reorientated (self, 5, 1, 4, cid_cobblestone, 0)
		set_block_reorientated (self, 5, 1, 6, cid_cobblestone, 0)
		set_block_reorientated (self, 5, 3, 4, cid_cobblestone, 0)
		set_block_reorientated (self, 5, 3, 6, cid_cobblestone, 0)
		set_block_reorientated (self, 6, 1, 5, cid_cobblestone, 0)
		set_block_reorientated (self, 6, 3, 5, cid_cobblestone, 0)
		for i = 1, 3 do
			set_block_reorientated (self, 4, i, 4, cid_cobblestone, 0)
			set_block_reorientated (self, 6, i, 4, cid_cobblestone, 0)
			set_block_reorientated (self, 4, i, 6, cid_cobblestone, 0)
			set_block_reorientated (self, 6, i, 6, cid_cobblestone, 0)
		end
		-- Pillbox torch.
		local dir = self.dir
		set_block_reorientated (self, 5, 3, 5, cid_wall_torch,
					reverse_wallmounted[dir])

		-- Second storey floor.
		for i = 2, 8 do
			set_block_reorientated (self, 2, 3, i, cid_wood_oak, 0)
			set_block_reorientated (self, 3, 3, i, cid_wood_oak, 0)
			set_block_reorientated (self, 7, 3, i, cid_wood_oak, 0)
			set_block_reorientated (self, 8, 3, i, cid_wood_oak, 0)
			-- Don't overwrite the pillbox.
			if i < 4 or i > 6 then
				set_block_reorientated (self, 4, 3, i, cid_wood_oak, 0)
				set_block_reorientated (self, 5, 3, i, cid_wood_oak, 0)
				set_block_reorientated (self, 6, 3, i, cid_wood_oak, 0)
			end
		end

		-- Ladder.
		local param2 = right_wallmounted[dir]
		for i = 1, 3 do
			set_block_reorientated (self, 9, i, 3, cid_ladder, param2)
		end

		-- Loot chest.
		-- Yes, it faces left despite being on the left itself.
		local param2 = local_facedir_right (dir)
		generate_stronghold_chest (self, 3, 4, 8, param2, rng, "crossing")
	end
end

local SQUARE_ROOM_DECORS = {
	"pillar",
	"fountain",
	"store",
	"empty",
	"empty",
}

function essay_square_room (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -4, -1, 0, 11, 7, 11, dir)
	-- print (string.format ("square_room bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = square_room_place,
			insert_children = square_room_insert_children,
			entry_door = random_door_type (rng),
			decor = SQUARE_ROOM_DECORS[1 + rng:next_within (5)],
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Stair piece.

local cid_cobblestone_stairs = getcid ("mcl_stairs:stair_cobble")

local function stairs_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 10, 7, rng)
	generate_door (self, self.entry_door, 1, 7, 0)
	generate_door (self, "void", 1, 1, 7)

	local param2 = reverse_facedirs[self.dir]
	for i = 1, 6 do
		set_block_reorientated (self, 1, 7 - i, i, cid_cobblestone_stairs, param2)
		set_block_reorientated (self, 2, 7 - i, i, cid_cobblestone_stairs, param2)
		set_block_reorientated (self, 3, 7 - i, i, cid_cobblestone_stairs, param2)

		-- Place supports for these stairs.
		if i <= 5 then
			set_block_reorientated (self, 1, 6 - i, i, cid_stone_bricks, 0)
			set_block_reorientated (self, 2, 6 - i, i, cid_stone_bricks, 0)
			set_block_reorientated (self, 3, 6 - i, i, cid_stone_bricks, 0)
		end
	end
end

local function stairs_insert_children (self, start, pieces, rng)
	local x, y, z = get_pos_after_door (self, 1, 1)
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng,
				       x, y, z, self.dir, depth, nil)
end

function essay_stairs (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -7, 0, 5, 11, 8, dir)
	-- print (string.format ("stairs bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = stairs_place,
			insert_children = stairs_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Stairwell piece.

local function stairwell_insert_children (self, start, pieces, rng)
	local x, y, z = get_pos_after_door (self, 1, 1)
	local depth = self.depth
	local override = nil
	if self.is_start then
		override = "five_way_crossing"
	end
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       self.dir, depth, override)
end

local function stairwell_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 10, 4, rng)
	generate_door (self, self.entry_door, 1, 7, 0)
	generate_door (self, "void", 1, 1, 4)
	set_block_reorientated (self, 2, 6, 1, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 5, 1, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 6, 1, cid_smooth_stone_slab, 0)

	set_block_reorientated (self, 1, 5, 2, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 4, 3, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 5, 3, cid_smooth_stone_slab, 0)

	set_block_reorientated (self, 2, 4, 3, cid_stone_bricks, 0)
	set_block_reorientated (self, 3, 3, 3, cid_stone_bricks, 0)
	set_block_reorientated (self, 3, 4, 3, cid_smooth_stone_slab, 0)

	set_block_reorientated (self, 3, 3, 2, cid_stone_bricks, 0)
	set_block_reorientated (self, 3, 2, 1, cid_stone_bricks, 0)
	set_block_reorientated (self, 3, 3, 1, cid_smooth_stone_slab, 0)

	set_block_reorientated (self, 2, 2, 1, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 1, 1, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 2, 1, cid_smooth_stone_slab, 0)

	set_block_reorientated (self, 1, 1, 2, cid_stone_bricks, 0)
	set_block_reorientated (self, 1, 1, 3, cid_smooth_stone_slab, 0)
end

function essay_stairs_down (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -7, 0, 5, 11, 5, dir)
	-- print (string.format ("stairs_down bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			depth = depth,
			bbox = bbox,
			dir = dir,
			place = stairwell_place,
			entry_door = random_door_type (rng),
			insert_children = stairwell_insert_children,
		}
	end
	return nil
end

-- 5-way crossing piece.

local cid_slab_stone_double = getcid ("mcl_stairs:slab_stone_double")
local fix_MC_188358 = true

local function five_way_crossing_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 9, 8, 10, rng)
	generate_door (self, self.entry_door, 4, 3, 0)

	-- Exits.  Resist the temptation to account for bbox mirroring
	-- in generating these exits, as it is an intentional
	-- Minecraft bug, as much as that is a contradiction in
	-- terms...  https://bugs.mojang.com/browse/MC-188358

	local left_low = self.left_low
	local right_low = self.right_low
	local left_high = self.left_high
	local right_high = self.right_high

	if fix_MC_188358 and (self.dir == "north" or self.dir == "west") then
		left_low, left_high = left_high, left_low
		right_low, right_high = right_high, right_low
	end

	if left_low then
		fill_area (self, 1.0, 0, 3, 1, 0, 5, 3, cid_air, 0, nil)
	end
	if right_low then
		fill_area (self, 1.0, 9, 3, 1, 9, 5, 3, cid_air, 0, nil)
	end
	if left_high then
		fill_area (self, 1.0, 0, 5, 7, 0, 7, 9, cid_air, 0, nil)
	end
	if right_high then
		fill_area (self, 1.0, 9, 5, 7, 9, 7, 9, cid_air, 0, nil)
	end

	-- Main exit.
	fill_area (self, 1.0, 5, 1, 10, 7, 3, 10, cid_air, 0, nil)

	-- Bottom floor and arches.
	generate_lined_void (self, 1, 2, 1, 8, 2, 6, rng)
	generate_lined_void (self, 4, 1, 5, 4, 4, 9, rng)
	generate_lined_void (self, 8, 1, 5, 8, 4, 9, rng)

	-- Right staircase.
	generate_lined_void (self, 1, 4, 7, 3, 4, 9, rng)
	generate_lined_void (self, 1, 3, 5, 3, 3, 6, rng)
	fill_area (self, 1.0, 1, 3, 4, 3, 3, 4, cid_smooth_stone_slab, 0, nil)
	fill_area (self, 1.0, 1, 4, 6, 3, 4, 6, cid_smooth_stone_slab, 0, nil)

	-- Arch & center staircase.
	generate_lined_void (self, 5, 1, 7, 7, 1, 8, rng)
	fill_area (self, 1.0, 5, 1, 9, 7, 1, 9, cid_smooth_stone_slab, 0, nil)
	fill_area (self, 1.0, 5, 2, 7, 7, 2, 7, cid_smooth_stone_slab, 0, nil)
	fill_area (self, 1.0, 4, 5, 7, 4, 5, 9, cid_smooth_stone_slab, 0, nil)
	fill_area (self, 1.0, 8, 5, 7, 8, 5, 9, cid_smooth_stone_slab, 0, nil)
	fill_area (self, 1.0, 5, 5, 7, 7, 5, 9, cid_slab_stone_double, 0, nil)

	-- Torches.
	local param2 = wallmounted[self.dir]
	set_block_reorientated (self, 6, 5, 6, cid_wall_torch, param2)
end

local function five_way_crossing_insert_children (self, start, pieces, rng)
	local dy1 = 3
	local dy2 = 5
	local dir = self.dir

	-- Swap DY1 and DY2 to account for inconsistencies between
	-- reorientate_coord's conception of mirroring and those of
	-- get_dir_and_pos_to_{left,right}.  This ought to have been
	-- combined with fix_MC_188358, but Mojang has neglected to do
	-- so.
	if dir == "west" or dir == "north" then
		dy1, dy2 = dy2, dy1
	end

	local depth = self.depth
	local x, y, z = get_pos_after_door (self, 5, 1)
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       dir, depth, nil)

	if self.left_low then
		dir, x, y, z = get_dir_and_pos_to_left (self, dy1, 1)
		select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
					       dir, depth, nil)
	end

	if self.left_high then
		dir, x, y, z = get_dir_and_pos_to_left (self, dy2, 7)
		select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
					       dir, depth, nil)
	end

	if self.right_low then
		dir, x, y, z = get_dir_and_pos_to_right (self, dy1, 1)
		select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
					       dir, depth, nil)
	end

	if self.right_high then
		dir, x, y, z = get_dir_and_pos_to_right (self, dy2, 7)
		select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
					       dir, depth, nil)
	end
end

function essay_five_way_crossing (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -4, -3, 0, 10, 9, 11, dir)
	-- print (string.format ("five_way_crossing bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		local crossing = {
			depth = depth,
			bbox = bbox,
			dir = dir,
			place = five_way_crossing_place,
			insert_children = five_way_crossing_insert_children,
			entry_door = random_door_type (rng),
			left_low = rng:next_boolean (),
			left_high = rng:next_boolean (),
			right_low = rng:next_boolean (),
			right_high = rng:next_within (3) > 0,
		}
		-- print (string.format ("five_way_crossing: %s,%s,%s,%s",
		-- 		      tostring (crossing.left_low),
		-- 		      tostring (crossing.left_high),
		-- 		      tostring (crossing.right_low),
		-- 		      tostring (crossing.right_high)))
		return crossing
	end
	return nil
end

-- Chest corridor piece.

local cid_stone_brick_slab = getcid ("mcl_stairs:slab_stonebrick")

local function chest_corridor_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_tunnel (self, 0, 0, 0, 4, 4, 6, rng)
	generate_door (self, self.entry_door, 1, 1, 0)
	generate_door (self, "void", 1, 1, 6)

	-- Pedestal.
	fill_area (self, 1.0, 3, 1, 2, 3, 1, 4, cid_stone_bricks, 0, nil)
	set_block_reorientated (self, 3, 1, 1, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 3, 2, 2, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 3, 2, 4, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 3, 1, 5, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 2, 1, 2, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 2, 1, 3, cid_stone_brick_slab, 0)
	set_block_reorientated (self, 2, 1, 4, cid_stone_brick_slab, 0)

	-- Chest.
	local param2 = local_facedir_right (self.dir)
	generate_stronghold_chest (self, 3, 2, 3, param2, rng, "corridor")
end

local function chest_corridor_insert_children (self, start, pieces, rng)
	local x, y, z = get_pos_after_door (self, 1, 1)
	local depth = self.depth
	select_and_insert_child_piece (self, start, pieces, rng, x, y, z,
				       self.dir, depth, nil)
end

function essay_chest_corridor (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -1, -1, 0, 5, 5, 7, dir)
	-- print (string.format ("chest_corridor bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = chest_corridor_place,
			insert_children = chest_corridor_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
end

-- Library piece.

local cid_cobweb = getcid ("mcl_core:cobweb")
local cid_bookshelf = getcid ("mcl_books:bookshelf")
local cid_fence_oak = getcid ("mcl_fences:oak_fence")
local cid_torch = getcid ("mcl_torches:torch")

local function library_place (self, level, terrain, rng, x1, z1, x2, z2)
	local tall = self.tall
	local height = tall and 11 or 6

	generate_tunnel (self, 0, 0, 0, 13, height - 1, 14, rng)
	generate_door (self, self.entry_door, 4, 1, 0)
	fill_area (self, 0.07, 2, 1, 1, 11, 4, 13, cid_cobweb, 0, rng)

	-- Generate two walls of bookshelves interleaved with oaken
	-- supports.

	local dir = self.dir
	local param2_left = left_wallmounted[dir]
	local param2_right = right_wallmounted[dir]

	for dz = 1, 13 do
		local cid = cid_bookshelf
		local place_torches = false
		if (dz - 1) % 4 == 0 then
			cid = cid_wood_oak
			place_torches = true
		end

		fill_area (self, 1.0, 1, 1, dz, 1, 4, dz, cid, 0, nil)
		fill_area (self, 1.0, 12, 1, dz, 12, 4, dz, cid, 0, nil)

		if tall then
			fill_area (self, 1.0, 1, 6, dz, 1, 9, dz, cid, 0, nil)
			fill_area (self, 1.0, 12, 6, dz, 12, 9, dz, cid, 0, nil)
		end

		if place_torches then
			set_block_reorientated (self, 2, 3, dz, cid_wall_torch,
						param2_left)
			set_block_reorientated (self, 11, 3, dz, cid_wall_torch,
						param2_right)
		end
	end

	-- Generate aisles.

	for dz = 3, 11, 2 do -- 3, 5, 7, 9, 11...
		fill_area (self, 1.0, 3, 1, dz, 4, 3, dz, cid_bookshelf, 0, nil)
		fill_area (self, 1.0, 6, 1, dz, 7, 3, dz, cid_bookshelf, 0, nil)
		fill_area (self, 1.0, 9, 1, dz, 10, 3, dz, cid_bookshelf, 0, nil)
	end

	-- Generate the upper floor if necessary.

	if tall then
		fill_area (self, 1.0, 1, 5, 1, 3, 5, 13, cid_wood_oak, 0)
		fill_area (self, 1.0, 10, 5, 1, 12, 5, 13, cid_wood_oak, 0)
		fill_area (self, 1.0, 4, 5, 1, 9, 5, 2, cid_wood_oak, 0)
		fill_area (self, 1.0, 4, 5, 1, 9, 5, 2, cid_wood_oak, 0)
		fill_area (self, 1.0, 4, 5, 12, 9, 5, 13, cid_wood_oak, 0)

		-- Corner into which the ladder debouches.
		set_block_reorientated (self, 8, 5, 11, cid_wood_oak, 0)
		set_block_reorientated (self, 9, 5, 11, cid_wood_oak, 0)
		set_block_reorientated (self, 9, 5, 10, cid_wood_oak, 0)

		-- Fences.
		set_block_reorientated (self, 3, 6, 2, cid_fence_oak, 0)
		set_block_reorientated (self, 3, 6, 12, cid_fence_oak, 0)
		set_block_reorientated (self, 10, 6, 2, cid_fence_oak, 0)
		fill_area (self, 1.0, 3, 6, 3, 3, 6, 11, cid_fence_oak, 0, nil)
		fill_area (self, 1.0, 10, 6, 3, 10, 6, 9, cid_fence_oak, 0, nil)
		fill_area (self, 1.0, 4, 6, 2, 9, 6, 2, cid_fence_oak, 0, nil)
		fill_area (self, 1.0, 4, 6, 12, 7, 6, 12, cid_fence_oak, 0, nil)

		-- Those at the said corner.
		set_block_reorientated (self, 8, 6, 12, cid_fence_oak, 0)
		set_block_reorientated (self, 9, 6, 11, cid_fence_oak, 0)
		set_block_reorientated (self, 10, 6, 10, cid_fence_oak, 0)
		set_block_reorientated (self, 8, 6, 11, cid_fence_oak, 0)
		set_block_reorientated (self, 9, 6, 10, cid_fence_oak, 0)

		-- Chandelier.
		fill_area (self, 1.0, 5, 7, 7, 8, 7, 7, cid_fence_oak, 0, nil)
		fill_area (self, 1.0, 6, 8, 7, 7, 9, 7, cid_fence_oak, 0, nil)
		set_block_reorientated (self, 6, 7, 6, cid_fence_oak, 0)
		set_block_reorientated (self, 6, 7, 8, cid_fence_oak, 0)
		set_block_reorientated (self, 7, 7, 6, cid_fence_oak, 0)
		set_block_reorientated (self, 7, 7, 8, cid_fence_oak, 0)
		set_block_reorientated (self, 5, 8, 7, cid_torch, 1)
		set_block_reorientated (self, 8, 8, 7, cid_torch, 1)
		set_block_reorientated (self, 6, 8, 6, cid_torch, 1)
		set_block_reorientated (self, 6, 8, 8, cid_torch, 1)
		set_block_reorientated (self, 7, 8, 6, cid_torch, 1)
		set_block_reorientated (self, 7, 8, 8, cid_torch, 1)

		-- Ladder and chests.
		local param2 = wallmounted[dir]
		fill_area (self, 1.0, 10, 1, 13, 10, 7, 13, cid_ladder, param2, nil)

		set_block_reorientated (self, 12, 9, 1, cid_air, 0)
		param2 = local_facedir_right (dir)
		generate_stronghold_chest (self, 12, 8, 1, param2, rng, "library")
	end

	-- Lodged in one of the bookshelves.
	local param2 = local_facedir_right (dir)
	generate_stronghold_chest (self, 3, 3, 5, param2, rng, "library")
end

local function library_insert_children (self, start, pieces, rng)
	-- Nothing here but crickets.
end

function essay_library (start, pieces, rng, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -4, -1, 0, 14, 11, 15, dir)
	-- print (string.format ("library bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = library_place,
			insert_children = library_insert_children,
			entry_door = random_door_type (rng),
			bbox = bbox,
			dir = dir,
			depth = depth,
			tall = true,
		}
	else
		local bbox = rotated_block_box (x, y, z, -4, -1, 0, 14, 6, 15, dir)
		if bbox[2] > 10 and not any_collisions (pieces, bbox) then
			return {
				place = library_place,
				insert_children = library_insert_children,
				entry_door = random_door_type (rng),
				bbox = bbox,
				dir = dir,
				depth = depth,
				tall = false,
			}
		end
	end
	return nil
end

-- Portal piece.

local cid_lava_source = getcid ("mcl_core:lava_source")
local cid_stone_brick_stairs = getcid ("mcl_stairs:stair_stonebrick")
local cid_end_portal_frame = getcid ("mcl_portals:end_portal_frame")
local cid_end_portal_frame_eye = getcid ("mcl_portals:end_portal_frame_eye")
local cid_mob_spawner = getcid ("mcl_mobspawners:spawner")

local function portal_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	generate_lined_void (self, 0, 0, 0, 10, 7, 15, rng)
	generate_door (self, "bars", 4, 1, 0)

	-- Ceiling ridges.
	generate_lined_void (self, 1, 6, 1, 1, 6, 14, rng)
	generate_lined_void (self, 9, 6, 1, 9, 6, 14, rng)
	generate_lined_void (self, 2, 6, 1, 8, 6, 2, rng)
	generate_lined_void (self, 2, 6, 14, 8, 6, 14, rng)

	-- Lava pools.
	generate_lined_void (self, 1, 1, 1, 2, 1, 4, rng)
	generate_lined_void (self, 8, 1, 1, 9, 1, 4, rng)
	generate_lined_void (self, 3, 1, 8, 7, 1, 12, rng)
	fill_area (self, 1.0, 1, 1, 1, 1, 1, 3, cid_lava_source, 0, nil)
	fill_area (self, 1.0, 9, 1, 1, 9, 1, 3, cid_lava_source, 0, nil)
	fill_area (self, 1.0, 4, 1, 9, 6, 1, 11, cid_lava_source, 0, nil)

	-- Iron bars.
	local dir = self.dir

	do
		local param2_left = local_facedir_left (dir)
		local param2_right = local_facedir_right (dir)

		fill_area (self, 1.0, 0, 3, 3, 0, 4, 3, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 3, 10, 4, 3, cid_iron_bars, param2_right)
		fill_area (self, 1.0, 0, 3, 5, 0, 4, 5, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 5, 10, 4, 5, cid_iron_bars, param2_right)
		fill_area (self, 1.0, 0, 3, 7, 0, 4, 7, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 7, 10, 4, 7, cid_iron_bars, param2_right)
		fill_area (self, 1.0, 0, 3, 9, 0, 4, 9, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 9, 10, 4, 9, cid_iron_bars, param2_right)
		fill_area (self, 1.0, 0, 3, 11, 0, 4, 11, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 11, 10, 4, 11, cid_iron_bars, param2_right)
		fill_area (self, 1.0, 0, 3, 13, 0, 4, 13, cid_iron_bars, param2_left)
		fill_area (self, 1.0, 10, 3, 13, 10, 4, 13, cid_iron_bars, param2_right)

		local param2_south = reverse_facedirs[dir]
		fill_area (self, 1.0, 2, 3, 15, 2, 4, 15, cid_iron_bars, param2_south)
		fill_area (self, 1.0, 4, 3, 15, 4, 4, 15, cid_iron_bars, param2_south)
		fill_area (self, 1.0, 6, 3, 15, 6, 4, 15, cid_iron_bars, param2_south)
		fill_area (self, 1.0, 8, 3, 15, 8, 4, 15, cid_iron_bars, param2_south)
	end

	-- Steps and supports.
	local param2 = facedirs[dir]
	fill_area (self, 1.0, 4, 1, 4, 6, 1, 4, cid_stone_brick_stairs, param2)
	fill_area (self, 1.0, 4, 2, 5, 6, 2, 5, cid_stone_brick_stairs, param2)
	fill_area (self, 1.0, 4, 3, 6, 6, 3, 6, cid_stone_brick_stairs, param2)

	generate_lined_void (self, 4, 1, 5, 6, 1, 5, rng)
	generate_lined_void (self, 4, 1, 6, 6, 2, 6, rng)
	generate_lined_void (self, 4, 1, 7, 6, 3, 7, rng)

	local cids = {}
	for i = 1, 12 do
		cids[i] = rng:next_float () > 0.9
			and cid_end_portal_frame_eye
			or cid_end_portal_frame
	end

	local param2_1 = reverse_facedirs[dir]
	local param2_2 = local_facedir_right (dir)
	local param2_3 = local_facedir_left (dir)

	for dx = 4, 6 do
		local cid = cids[1 + dx - 4]
		local x, y, z = reorientate_coords (self, dx, 3, 8)
		set_block (x, y, z, cid, param2)

		-- This must be repeated for every block as structure
		-- pieces may intersect multiple chunks, and each such
		-- intersection is randomized separately.
		if cid == cid_end_portal_frame_eye then
			notify_generated ("mcl_levelgen:check_end_portal_frame", x, y, z, {
				x, y, z,
			}, true)
		end
	end

	for dx = 4, 6 do
		local cid = cids[4 + dx - 4]
		local x, y, z = reorientate_coords (self, dx, 3, 12)
		set_block (x, y, z, cid, param2_1)

		-- This must be repeated for every block as structure
		-- pieces may intersect multiple chunks, and each such
		-- intersection is randomized separately.
		if cid == cid_end_portal_frame_eye then
			notify_generated ("mcl_levelgen:check_end_portal_frame", x, y, z, {
				x, y, z,
			}, true)
		end
	end

	for dz = 9, 11 do
		local cid = cids[7 + dz - 9]
		local x, y, z = reorientate_coords (self, 3, 3, dz)
		set_block (x, y, z, cid, param2_2)

		-- This must be repeated for every block as structure
		-- pieces may intersect multiple chunks, and each such
		-- intersection is randomized separately.
		if cid == cid_end_portal_frame_eye then
			notify_generated ("mcl_levelgen:check_end_portal_frame", x, y, z, {
				x, y, z,
			}, true)
		end
	end

	for dz = 9, 11 do
		local cid = cids[10 + dz - 9]
		local x, y, z = reorientate_coords (self, 7, 3, dz)
		set_block (x, y, z, cid, param2_3)

		-- This must be repeated for every block as structure
		-- pieces may intersect multiple chunks, and each such
		-- intersection is randomized separately.
		if cid == cid_end_portal_frame_eye then
			notify_generated ("mcl_levelgen:check_end_portal_frame", x, y, z, {
				x, y, z,
			}, true)
		end
	end

	-- Spawner.
	local x, y, z = reorientate_coords (self, 5, 3, 6)
	set_block (x, y, z, cid_mob_spawner, 0)
	notify_generated ("mcl_levelgen:mob_spawner_constructor", x, y, z, {
		x = x,
		y = y,
		z = z,
		mob = "mobs_mc:silverfish",
	})
end

local function portal_room_insert_children (self, start, pieces, rng)
	portal_room_piece = self
end

function make_portal_room (start, pieces, x, y, z, dir, depth)
	local bbox = rotated_block_box (x, y, z, -4, -1, 0, 11, 8, 16, dir)
	-- print (string.format ("portal_room bbox: (%d,%d,%d) - (%d,%d,%d)",
	-- 		      unpack (bbox)) .. " " .. dir)
	if bbox[2] > 10 and not any_collisions (pieces, bbox) then
		return {
			place = portal_room_place,
			insert_children = portal_room_insert_children,
			bbox = bbox,
			dir = dir,
			depth = depth,
		}
	end
	return nil
end

-- Entrance stairwell.

local function insert_start_piece (pieces, rng, x, z)
	local dir = random_orientation (rng)
	local bbox = make_rotated_bbox (x, 64, z, dir, 5, 11, 5)
	local piece = {
		is_start = true,
		depth = 0,
		dir = dir,
		entry_door = "void",
		bbox = bbox,
		place = stairwell_place,
		insert_children = stairwell_insert_children,
	}
	insert (pieces, piece)
	return piece
end

-- Structure start generation.

local set_carver_seed = mcl_levelgen.set_carver_seed
local ull = mcl_levelgen.ull
local addkull = mcl_levelgen.addkull
local stronghold_rng = mcl_levelgen.jvm_random (ull (0, 0))

local function copyull (ull)
	return { ull[1], ull[2], }
end

local function stronghold_create_pieces (self, level, terrain, rng, cx, cz)
	local pieces
	local seed = copyull (level.level_seed)
	local rng = stronghold_rng

	repeat
		pieces = {}
		child_queue = {}
		count_placed = {}
		previous_piece_type = nil

		for _, desc in ipairs (ALL_PIECES) do
			local piecetype = desc[1]
			count_placed[piecetype] = 0
		end

		set_carver_seed (rng, seed, cx, cz)
		addkull (seed, 1)

		local x, z = cx * 16 + 2, cz * 16 + 2
		-- print ("Stronghold @ " .. x .. "," .. z)

		local start = insert_start_piece (pieces, rng, x, z)
		-- print ("Stronghold initial orientation " .. start.dir)
		start:insert_children (start, pieces, rng)
		while #child_queue >= 1 do
			local idx = 1 + rng:next_within (#child_queue)
			local child = child_queue[idx]
			for i = idx, #child_queue do
				child_queue[i] = child_queue[i + 1]
			end

			-- So-called "filler" corridors have no children.
			if child.insert_children then
				child:insert_children (start, pieces, rng)
			end
		end

		local preset = level.preset
		mcl_levelgen.shift_into (pieces, preset.sea_level, preset.min_y, rng, 10)
	until portal_room_piece ~= nil
	return pieces
end

local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start

local function stronghold_create_start (self, level, terrain, rng, cx, cz)
	local tx, tz = cx * 16, cz * 16
	if structure_biome_test (level, self, tx, 0, tz) then
		local pieces = stronghold_create_pieces (self, level, terrain,
							 rng, cx, cz)
		if pieces then
			return create_structure_start (self, pieces)
		end
	end
	return nil
end

------------------------------------------------------------------------
-- Stronghold registration.
------------------------------------------------------------------------

mcl_levelgen.register_structure ("mcl_levelgen:stronghold", {
	create_start = stronghold_create_start,
	-- The STRONGHOLD step is unused; see:
	-- https://minecraft.wiki/w/World_generation
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "bury",
	biomes = mcl_levelgen.build_biome_list ({"#has_stronghold",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:strongholds", {
	structures = {
		"mcl_levelgen:stronghold",
	},
	placement = C ("mcl_levelgen:strongholds", 1.0, "default", 0, nil, nil),
})
