local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Desert Pyramid structure.
------------------------------------------------------------------------

local WIDTH = 21
local HEIGHT = 15
local LENGTH = 21

local function getcid (name)
	if mcl_levelgen.is_levelgen_environment then
		return core.get_content_id (name)
	else
		return nil
	end
end

local cid_air = core.CONTENT_AIR
-- local cid_magenta_glass
-- 	= getcid ("mcl_core:glass_magenta")

if not mcl_levelgen.is_levelgen_environment then

local desert_pyramid_loot = {
		{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 25, amount_min = 4, amount_max=6 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 25, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_mobitems:spider_eye", weight = 25, amount_min = 1, amount_max=3 },
				{ itemstring = "mcl_books:book", weight = 20, func = function(stack, pr)
					  mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_mobitems:saddle", weight = 20, },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 3 },
				{ itemstring = "", weight = 15, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 15, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 10, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 5, },
				{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
				{ itemstring = "mcl_armor:dune", weight = 20, amount_min = 2, amount_max = 2},
			},
		},
		{
			stacks_min = 4,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:gunpowder", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:sand", weight = 10, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_mobitems:string", weight = 10, amount_min = 1, amount_max = 8 },
			},
		},
}

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local v = vector.zero ()

local function handle_desert_pyramid_loot (_, data)
	local x, y, z = level_to_minetest_position (data[1], data[2], data[3])
	v.x = x
	v.y = y
	v.z = z
	core.load_area (v)
	local node = core.get_node (v)
	if node.name == "mcl_chests:chest_small" then
		mcl_structures.init_node_construct (v)
		local meta = core.get_meta (v)
		local inv = meta:get_inventory ()
		local pr = PcgRandom (data[4])
		local loot = mcl_loot.get_multi_loot (desert_pyramid_loot, pr)
		mcl_loot.fill_inventory (inv, "main", loot, pr)
	end
end

mcl_levelgen.register_notification_handler ("mcl_levelgen:desert_pyramid_loot",
					    handle_desert_pyramid_loot)

end

------------------------------------------------------------------------
-- Desert Pyramid structure piece.
-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/structure/DesertTempleGenerator.html
------------------------------------------------------------------------

local mathmin = math.min
local mathmax = math.max
local mathabs = math.abs
local floor = math.floor

local random_orientation = mcl_levelgen.random_orientation
local make_rotated_bbox = mcl_levelgen.make_rotated_bbox

local reorientate_coords = mcl_levelgen.reorientate_coords
local set_block = mcl_levelgen.set_block
local set_block_checked = mcl_levelgen.set_block_checked
local ipos3 = mcl_levelgen.ipos3

local function fill_box_rotated (piece, x1, y1, z1, x2, y2, z2, cid, param2)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		set_block (x, y, z, cid, param2)
	end
end

local function not_air_p (cid, param2)
	return cid ~= cid_air
end

local function fill_area_preserving_air (piece, x1, y1, z1, x2, y2, z2, cid, param2)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		set_block_checked (x, y, z, cid, param2, not_air_p)
	end
end

local function generate_box (piece, x1, y1, z1, x2, y2, z2,
			     cid, param2)
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
			set_block (x, y, z, cid, param2)
		else
			set_block (x, y, z, cid_air, 0)
		end
	end
end

local is_water_air_or_lava = mcl_levelgen.is_water_air_or_lava
local cid_sandstone = getcid ("mcl_core:sandstone")

local function build_foundation_column (x, y, z, level_min)
	while y > level_min + 1 do
		if not is_water_air_or_lava (x, y, z) then
			break
		end
		set_block (x, y, z, cid_sandstone, 0)
		y = y - 1
	end
end

local function build_pyramid_foundation (self, level)
	local x1, _, z1 = reorientate_coords (self, 0, 0, 0)
	local x2, _, z2 = reorientate_coords (self, WIDTH, 0, LENGTH)
	local y = self.bbox[2] - 5
	local level_min = level.preset.min_y

	for x, _, z in ipos3 (mathmin (x1, x2), 0, mathmin (z1, z2),
			      mathmax (x1, x2), 0, mathmax (z1, z2)) do
		build_foundation_column (x, y, z, level_min)
	end
end

local function set_block_reorientated (piece, x, y, z, cid, param2)
	local x, y, z = reorientate_coords (piece, x, y, z)
	set_block (x, y, z, cid, param2)
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
	south = 3,
	west = 0,
	east = 0,
}

local right_facedirs = {
	north = 1,
	south = 1,
	west = 2,
	east = 2,
}

local cid_sandstone_stairs = getcid ("mcl_stairs:stair_sandstone")
local cid_sandstone_slab = getcid ("mcl_stairs:slab_sandstone")
local cid_cut_sandstone = getcid ("mcl_core:sandstonesmooth")
local cid_chiseled_sandstone = getcid ("mcl_core:sandstonecarved")
local cid_orange_terracotta
	= getcid ("mcl_colorblocks:hardened_clay_orange")
local cid_blue_terracotta
	= getcid ("mcl_colorblocks:hardened_clay_blue")
local cid_stone_pressure_plate
	= getcid ("mcl_pressureplates:pressure_plate_stone_off")
local cid_tnt = getcid ("mcl_tnt:tnt")
local cid_chest_small = getcid ("mcl_chests:chest_small")
local cid_sand = getcid ("mcl_core:sand")

local notify_generated = mcl_levelgen.notify_generated
local gen_sand = {}

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local band = bit.band

local function unhash (pos)
	return floor (pos / (65536 * 65536)) - 32768,
		band (floor (pos / 65536), 0xffff) - 32768,
		pos % 65536 - 32768
end

local insert = table.insert

local function generate_basement_stairs (self, sx, sy, sz, rng)
	local dir = self.dir
	set_block_reorientated (self, 13, -1, 17, cid_sandstone_stairs,
				left_facedirs[dir])
	set_block_reorientated (self, 14, -2, 17, cid_sandstone_stairs,
				left_facedirs[dir])
	set_block_reorientated (self, 15, -3, 17, cid_sandstone_stairs,
				left_facedirs[dir])
	local selector = rng:next_boolean ()
	set_block_reorientated (self, sx - 4, sy + 4, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 3, sy + 4, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 2, sy + 4, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 1, sy + 4, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 0, sy + 4, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 2, sy + 3, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 1, sy + 3, sz + 4,
				selector and cid_sand or cid_sandstone, 0)
	set_block_reorientated (self, sx - 0, sy + 3, sz + 4,
				selector and cid_sandstone or cid_sand, 0)
	set_block_reorientated (self, sx - 1, sy + 2, sz + 4, cid_sand, 0)
	set_block_reorientated (self, sx - 0, sy + 2, sz + 4, cid_sandstone, 0)
	set_block_reorientated (self, sx - 0, sy + 1, sz + 4, cid_sand, 0)
end

local function mark_sand_in_area (self, x1, y1, z1, x2, y2, z2)
	local x1, y1, z1 = reorientate_coords (self, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (self, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		insert (gen_sand, longhash (x, y, z))
	end
end

local function mark_sand (self, x, y, z)
	local x, y, z = reorientate_coords (self, x, y, z)
	insert (gen_sand, longhash (x, y, z))
end

local function generate_basement_roof (self, rng, rng_chunk, x1, y, z1, x2, z2)
	local x1, y1, z1 = reorientate_coords (self, x1, y, z1)
	local x2, y2, z2 = reorientate_coords (self, x2, y, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if rng_chunk:next_float () < 0.33 then
			set_block (x, y, z, cid_sandstone, 0)
		else
			set_block (x, y, z, cid_sand, 0)
		end
	end

	local sus_x = mathmin (x1, x2)
		+ rng:next_within (mathabs (x2 - x1) + 1)
	local sus_z = mathmin (z1, z2)
		+ rng:next_within (mathabs (z2 - z1) + 1)
	return sus_x, y1, sus_z
end

local factory
	= mcl_levelgen.overworld_preset.factory
local suspicious_sand_rng
	= factory ("mcl_levelgen:desert_pyramid_sus_nodes")
		:fork_positional ():create_reseedable ()
local cid_suspicious_sand = getcid ("mcl_sus_nodes:sand")

local function generate_suspicious_sand (x, y, z, rng)
	local loot_seed = mathabs (rng:next_integer ())
	local loot_type = "desert_pyramid_archeology"
	set_block (x, y, z, cid_suspicious_sand, 0)
	notify_generated ("mcl_sus_nodes:suspicious_sand_structure_meta",
			  x, y, z, { x, y, z, loot_seed, loot_type, },
			  true)
end

local fisher_yates = mcl_levelgen.fisher_yates
local bbox_center = mcl_levelgen.bbox_center

local function generate_suspicious_sand_room (self, x, y, z, rng)
	-- Walls.
	fill_area_preserving_air (self, x - 3, y + 1, z - 3, x - 3, y + 1, z + 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x + 3, y + 1, z - 3, x + 3, y + 1, z + 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x - 3, y + 1, z - 3, x + 3, y + 1, z - 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x - 3, y + 1, z + 3, x + 3, y + 1, z + 3,
				  cid_cut_sandstone, 0)

	fill_area_preserving_air (self, x - 3, y + 2, z - 3, x - 3, y + 1, z + 2,
				  cid_chiseled_sandstone, 0)
	fill_area_preserving_air (self, x + 3, y + 2, z - 3, x + 3, y + 1, z + 2,
				  cid_chiseled_sandstone, 0)
	fill_area_preserving_air (self, x - 3, y + 2, z - 3, x + 3, y + 1, z - 2,
				  cid_chiseled_sandstone, 0)
	fill_area_preserving_air (self, x - 3, y + 2, z + 3, x + 3, y + 1, z + 3,
				  cid_chiseled_sandstone, 0)

	fill_area_preserving_air (self, x - 3, -1, z - 3, x - 3, -1, z + 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x + 3, -1, z - 3, x + 3, -1, z + 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x - 3, -1, z - 3, x + 3, -1, z - 2,
				  cid_cut_sandstone, 0)
	fill_area_preserving_air (self, x - 3, -1, z + 3, x + 3, -1, z + 3,
				  cid_cut_sandstone, 0)

	-- Sand room.
	mark_sand_in_area (self, x - 2, y + 1, z - 2, x + 2, y + 3, z + 2)
	do
		-- Suspicious nodes are selected with an independent
		-- PRNG to provide for situations where the room intersects
		-- multiple chunks.
		local x, y, z = bbox_center (self.bbox)
		suspicious_sand_rng:reseed_positional (x, y, z)
	end
	local sus_x, sus_y, sus_z
		= generate_basement_roof (self, suspicious_sand_rng, rng,
					  x - 2, y + 4, z - 2, x + 2, z + 2)

	-- Floor.
	set_block_reorientated (self, x, y, z, cid_blue_terracotta, 0)
	set_block_reorientated (self, x + 1, y, z - 1, cid_orange_terracotta, 0)
	set_block_reorientated (self, x + 1, y, z + 1, cid_orange_terracotta, 0)
	set_block_reorientated (self, x - 1, y, z - 1, cid_orange_terracotta, 0)
	set_block_reorientated (self, x - 1, y, z + 1, cid_orange_terracotta, 0)
	set_block_reorientated (self, x + 2, y, z, cid_orange_terracotta, 0)
	set_block_reorientated (self, x - 2, y, z, cid_orange_terracotta, 0)
	set_block_reorientated (self, x, y, z + 2, cid_orange_terracotta, 0)
	set_block_reorientated (self, x, y, z - 2, cid_orange_terracotta, 0)

	-- Entrances.
	set_block_reorientated (self, x + 3, y, z, cid_orange_terracotta, 0)
	mark_sand (self, x + 3, y + 1, z)
	mark_sand (self, x + 3, y + 2, z)
	set_block_reorientated (self, x + 4, y + 1, z, cid_cut_sandstone, 0)
	set_block_reorientated (self, x + 4, y + 2, z, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, x - 3, y, z, cid_orange_terracotta, 0)
	mark_sand (self, x - 3, y + 1, z)
	mark_sand (self, x - 3, y + 2, z)
	set_block_reorientated (self, x + 4, y + 1, z, cid_cut_sandstone, 0)
	set_block_reorientated (self, x + 4, y + 2, z, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, x, y, z + 3, cid_orange_terracotta, 0)
	mark_sand (self, x, y + 1, z + 3)
	mark_sand (self, x, y + 2, z + 3)
	set_block_reorientated (self, x, y, z - 3, cid_orange_terracotta, 0)
	mark_sand (self, x, y + 1, z - 3)
	mark_sand (self, x, y + 2, z - 3)
	set_block_reorientated (self, x, y + 1, z - 4, cid_cut_sandstone, 0)
	set_block_reorientated (self, x, -2, z - 4, cid_chiseled_sandstone, 0)

	-- Process suspicious nodes.
	fisher_yates (gen_sand, suspicious_sand_rng)
	local n_max = suspicious_sand_rng:next_within (3) + 5
	local n = mathmin (#gen_sand, n_max)

	for i = 1, n do
		local x, y, z = unhash (gen_sand[i])
		generate_suspicious_sand (x, y, z, rng)
	end

	-- Clear this array.
	for i = 1, #gen_sand do
		gen_sand[i] = nil
	end

	-- Generate one node randomly selected from within the ceiling
	-- also.
	generate_suspicious_sand (sus_x, sus_y, sus_z, rng)
end

local function generate_basement (self, rng)
	generate_basement_stairs (self, 16, -4, 13, rng)
	generate_suspicious_sand_room (self, 16, -4, 13, rng)
end

local function generate_chest (self, x, y, z, param2, rng)
	local x, y, z = reorientate_coords (self, x, y, z)
	set_block (x, y, z, cid_chest_small, param2)
	notify_generated ("mcl_levelgen:desert_pyramid_loot", x, y, z, {
		x, y, z, mathabs (rng:next_integer ()),
	})
end

local function desert_pyramid_piece_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Floor.
	fill_box_rotated (self, 0, -4, 0, WIDTH - 1, 0,
			  LENGTH - 1, cid_sandstone, 0)

	-- Steps.
	for i = 1, 9 do
		fill_box_rotated (self, i, i, i,
				  WIDTH - 1 - i, i, LENGTH - 1 - i,
				  cid_sandstone, 0)
		fill_box_rotated (self, i + 1, i, i + 1,
				  WIDTH - 2 - i, i, LENGTH - 2 - i,
				  cid_air, 0)
	end

	-- Foundation.
	build_pyramid_foundation (self, level)

	-- Left tower.
	generate_box (self, 0, 0, 0, 4, 9, 4, cid_sandstone, 0)
	generate_box (self, 1, 10, 1, 3, 10, 3, cid_sandstone, 0)
	local dir = self.dir
	set_block_reorientated (self, 2, 10, 0, cid_sandstone_stairs,
				facedirs[dir])
	set_block_reorientated (self, 2, 10, 4, cid_sandstone_stairs,
				reverse_facedirs[dir])
	set_block_reorientated (self, 0, 10, 2, cid_sandstone_stairs,
				right_facedirs[dir])
	set_block_reorientated (self, 4, 10, 2, cid_sandstone_stairs,
				left_facedirs[dir])

	-- Right tower.
	generate_box (self, WIDTH - 5, 0, 0, WIDTH - 1, 9, 4,
		      cid_sandstone, 0)
	generate_box (self, WIDTH - 4, 10, 1, WIDTH - 2, 10, 3,
		      cid_sandstone, 0)
	set_block_reorientated (self, WIDTH - 3, 10, 0, cid_sandstone_stairs,
				facedirs[dir])
	set_block_reorientated (self, WIDTH - 3, 10, 4, cid_sandstone_stairs,
				reverse_facedirs[dir])
	set_block_reorientated (self, WIDTH - 5, 10, 2, cid_sandstone_stairs,
				right_facedirs[dir])
	set_block_reorientated (self, WIDTH - 1, 10, 2, cid_sandstone_stairs,
				left_facedirs[dir])

	-- Entrance.
	generate_box (self, 8, 0, 0, 12, 4, 4, cid_sandstone, 0)
	fill_box_rotated (self, 9, 1, 0, 11, 3, 4, cid_air, 0)
	set_block_reorientated (self, 9, 1, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 9, 2, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 9, 3, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 10, 3, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 11, 3, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 11, 2, 1, cid_cut_sandstone, 0)
	set_block_reorientated (self, 11, 1, 1, cid_cut_sandstone, 0)

	-- Supporting rooms connecting to the towers.
	generate_box (self, 4, 1, 1, 8, 3, 3, cid_sandstone, 0)
	fill_box_rotated (self, 4, 1, 2, 8, 2, 2, cid_air, 0)
	generate_box (self, 12, 1, 1, 16, 3, 3, cid_sandstone, 0)
	fill_box_rotated (self, 12, 1, 2, 16, 2, 2, cid_air, 0)

	-- First story ceiling.
	fill_box_rotated (self, 5, 4, 5, WIDTH - 6,
			  4, LENGTH - 6, cid_sandstone, 0)
	fill_box_rotated (self, 9, 4, 9, 11, 4, 11, cid_air, 0)

	-- Supporters.
	fill_box_rotated (self, 8, 1, 8, 8, 3, 8, cid_cut_sandstone, 0)
	fill_box_rotated (self, 12, 1, 8, 12, 3, 8, cid_cut_sandstone, 0)
	fill_box_rotated (self, 8, 1, 12, 8, 3, 12, cid_cut_sandstone, 0)
	fill_box_rotated (self, 12, 1, 12, 12, 3, 12, cid_cut_sandstone, 0)

	-- Sidings.
	fill_box_rotated (self, 1, 1, 5, 4, 4, 11, cid_sandstone, 0)
	fill_box_rotated (self, WIDTH - 5, 1, 5, WIDTH - 2, 4, 11,
			  cid_sandstone, 0)

	-- Second storey exits.
	fill_box_rotated (self, 6, 7, 9, 6, 7, 11, cid_sandstone, 0)
	fill_box_rotated (self, WIDTH - 7, 7, 9, WIDTH - 7, 7, 11,
			  cid_sandstone, 0)
	fill_box_rotated (self, 5, 5, 9, 5, 7, 11, cid_cut_sandstone, 0)
	fill_box_rotated (self, WIDTH - 6, 5, 9, WIDTH - 6, 7, 11,
			  cid_cut_sandstone, 0)
	set_block_reorientated (self, 5, 5, 10, cid_air, 0)
	set_block_reorientated (self, 5, 6, 10, cid_air, 0)
	set_block_reorientated (self, 6, 6, 10, cid_air, 0)
	set_block_reorientated (self, WIDTH - 6, 5, 10, cid_air, 0)
	set_block_reorientated (self, WIDTH - 6, 6, 10, cid_air, 0)
	set_block_reorientated (self, WIDTH - 7, 6, 10, cid_air, 0)

	-- Tower windows.
	fill_box_rotated (self, 2, 4, 4, 2, 6, 4, cid_air, 0)
	fill_box_rotated (self, WIDTH - 3, 4, 4, WIDTH - 3, 6, 4, cid_air, 0)

	-- Tower staircases.
	set_block_reorientated (self, 2, 4, 5, cid_sandstone_stairs,
				facedirs[dir])
	set_block_reorientated (self, 2, 3, 4, cid_sandstone_stairs,
				facedirs[dir])
	set_block_reorientated (self, WIDTH - 3, 4, 5, cid_sandstone_stairs,
				facedirs[dir])
	set_block_reorientated (self, WIDTH - 3, 3, 4, cid_sandstone_stairs,
				facedirs[dir])
	fill_box_rotated (self, 1, 1, 3, 2, 2, 3, cid_sandstone, 0)
	fill_box_rotated (self, WIDTH - 3, 1, 3, WIDTH - 2, 2, 3,
			  cid_sandstone, 0)
	set_block_reorientated (self, 1, 1, 2, cid_sandstone, 0)
	set_block_reorientated (self, WIDTH - 2, 1, 2, cid_sandstone, 0)
	set_block_reorientated (self, 1, 2, 2, cid_sandstone_slab, 0)
	set_block_reorientated (self, WIDTH - 2, 2, 2, cid_sandstone_slab, 0)
	set_block_reorientated (self, 2, 1, 2, cid_sandstone_stairs,
				left_facedirs[dir])
	set_block_reorientated (self, WIDTH - 3, 1, 2, cid_sandstone_stairs,
				right_facedirs[dir])

	-- Sidings (continued).
	fill_box_rotated (self, 3, 1, 5, 4, 2, 16, cid_air, 0)
	fill_box_rotated (self, WIDTH - 6, 1, 5, WIDTH - 5, 2, 16, cid_air, 0)

	for dz = 5, 17, 2 do
		local x, y, z = reorientate_coords (self, 4, 0, dz)
		set_block (x, y + 1, z, cid_cut_sandstone, 0)
		set_block (x, y + 2, z, cid_chiseled_sandstone, 0)
		x, y, z = reorientate_coords (self, WIDTH - 5, 0, dz)
		set_block (x, y + 1, z, cid_cut_sandstone, 0)
		set_block (x, y + 2, z, cid_chiseled_sandstone, 0)
	end

	-- Shaft cover.
	set_block_reorientated (self, 10, 0, 7, cid_orange_terracotta, 0)
	set_block_reorientated (self, 10, 0, 8, cid_orange_terracotta, 0)
	set_block_reorientated (self, 9, 0, 9, cid_orange_terracotta, 0)
	set_block_reorientated (self, 11, 0, 9, cid_orange_terracotta, 0)
	set_block_reorientated (self, 8, 0, 10, cid_orange_terracotta, 0)
	set_block_reorientated (self, 12, 0, 10, cid_orange_terracotta, 0)
	set_block_reorientated (self, 7, 0, 10, cid_orange_terracotta, 0)
	set_block_reorientated (self, 13, 0, 10, cid_orange_terracotta, 0)
	set_block_reorientated (self, 9, 0, 11, cid_orange_terracotta, 0)
	set_block_reorientated (self, 11, 0, 11, cid_orange_terracotta, 0)
	set_block_reorientated (self, 10, 0, 12, cid_orange_terracotta, 0)
	set_block_reorientated (self, 10, 0, 13, cid_orange_terracotta, 0)
	set_block_reorientated (self, 10, 0, 10, cid_blue_terracotta, 0)

	-- Keys of life.
	for dx = 0, WIDTH - 1, WIDTH - 1 do
		set_block_reorientated (self, dx, 2, 1, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 2, 2, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 2, 3, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 3, 1, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 3, 2, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 3, 3, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 4, 1, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 4, 2, cid_chiseled_sandstone, 0)
		set_block_reorientated (self, dx, 4, 3, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 5, 1, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 5, 2, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 5, 3, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 6, 1, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 6, 2, cid_chiseled_sandstone, 0)
		set_block_reorientated (self, dx, 6, 3, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 7, 1, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 7, 2, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 7, 3, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 8, 1, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 8, 2, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 8, 3, cid_cut_sandstone, 0)
	end

	for dx = 2, WIDTH - 3, WIDTH - 5 do
		set_block_reorientated (self, dx - 1, 2, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 2, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx + 1, 2, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx - 1, 3, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 3, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx + 1, 3, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx - 1, 4, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 4, 0, cid_chiseled_sandstone, 0)
		set_block_reorientated (self, dx + 1, 4, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx - 1, 5, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 5, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx + 1, 5, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx - 1, 6, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 6, 0, cid_chiseled_sandstone, 0)
		set_block_reorientated (self, dx + 1, 6, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx - 1, 7, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx, 7, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx + 1, 7, 0, cid_orange_terracotta, 0)
		set_block_reorientated (self, dx - 1, 8, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx, 8, 0, cid_cut_sandstone, 0)
		set_block_reorientated (self, dx + 1, 8, 0, cid_cut_sandstone, 0)
	end

	-- Entrance decoration.
	fill_box_rotated (self, 8, 4, 0, 12, 6, 0, cid_cut_sandstone, 0)
	set_block_reorientated (self, 8, 6, 0, cid_air, 0)
	set_block_reorientated (self, 12, 6, 0, cid_air, 0)
	set_block_reorientated (self, 9, 5, 0, cid_orange_terracotta, 0)
	set_block_reorientated (self, 10, 5, 0, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, 11, 5, 0, cid_orange_terracotta, 0)

	-- Shaft floor.
	fill_box_rotated (self, 8, -14, 8, 12, -11, 12, cid_cut_sandstone, 0)
	fill_box_rotated (self, 8, -10, 8, 12, -10, 12, cid_chiseled_sandstone, 0)
	fill_box_rotated (self, 8, -9, 8, 12, -9, 12, cid_cut_sandstone, 0)
	fill_box_rotated (self, 8, -8, 8, 12, -1, 12, cid_sandstone, 0)

	-- Shaft.
	fill_box_rotated (self, 9, -11, 9, 11, -1, 11, cid_air, 0)
	set_block_reorientated (self, 10, -11, 10, cid_stone_pressure_plate, 0)
	fill_box_rotated (self, 9, -13, 9, 11, -13, 11, cid_tnt, 0)

	-- Prepare space for chests.
	set_block_reorientated (self, 8, -11, 10, cid_air, 0)
	set_block_reorientated (self, 8, -10, 10, cid_air, 0)
	set_block_reorientated (self, 7, -10, 10, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, 7, -11, 10, cid_cut_sandstone, 0)

	set_block_reorientated (self, 12, -11, 10, cid_air, 0)
	set_block_reorientated (self, 12, -10, 10, cid_air, 0)
	set_block_reorientated (self, 13, -10, 10, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, 13, -11, 10, cid_cut_sandstone, 0)

	set_block_reorientated (self, 10, -11, 8, cid_air, 0)
	set_block_reorientated (self, 10, -10, 8, cid_air, 0)
	set_block_reorientated (self, 10, -10, 7, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, 10, -11, 7, cid_cut_sandstone, 0)

	set_block_reorientated (self, 10, -11, 12, cid_air, 0)
	set_block_reorientated (self, 10, -10, 12, cid_air, 0)
	set_block_reorientated (self, 10, -10, 13, cid_chiseled_sandstone, 0)
	set_block_reorientated (self, 10, -11, 13, cid_cut_sandstone, 0)

	-- Place chests.
	generate_chest (self, 8, -11, 10, left_facedirs[dir], rng)
	generate_chest (self, 12, -11, 10, right_facedirs[dir], rng)
	generate_chest (self, 10, -11, 8, reverse_facedirs[dir], rng)
	generate_chest (self, 10, -11, 12, facedirs[dir], rng)

	-- Place basement.
	generate_basement (self, rng)
end

local function create_desert_pyramid_piece (rng, x, y, z)
	local dir = random_orientation (rng)
	local bbox = make_rotated_bbox (x, y, z, dir, WIDTH, HEIGHT, LENGTH)

	return {
		bbox = bbox,
		dir = dir,
		place = desert_pyramid_piece_place,
	}
end

------------------------------------------------------------------------
-- Desert Pyramid generation.
-- https://maven.fabricmc.net/docs/yarn-1.20.4+build.1/net/minecraft/world/gen/structure/DesertPyramidStructure.html
------------------------------------------------------------------------

local lowest_corner_from_chunk_origin
	= mcl_levelgen.lowest_corner_from_chunk_origin
local is_not_air = mcl_levelgen.is_not_air
local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start

local function desert_pyramid_create_start (self, level, terrain, rng, cx, cz)
	local sea_level = level.preset.sea_level
	local y = lowest_corner_from_chunk_origin (terrain, cx, cz, WIDTH, LENGTH)
	if y < sea_level then
		return nil
	else
		local x = cx * 16 + 8
		local z = cz * 16 + 8
		local y = terrain:get_one_height (x, z, is_not_air)

		if structure_biome_test (level, self, x, y, z) then
			local pieces = {
				create_desert_pyramid_piece (rng, x - 8,
							     y, z - 8),
			}
			-- Adjust the bbox's vertical position to the
			-- bottommost height in the area it occupies.
			local sink = -rng:next_within (3)
			local bbox = pieces[1].bbox
			local hmin = terrain:area_min_height (bbox[1], bbox[3],
							      bbox[4], bbox[6],
							      is_not_air)
			bbox[5] = hmin + sink + (bbox[5] - bbox[2])
			bbox[2] = hmin + sink
			return create_structure_start (self, pieces)
		end

		return nil
	end
end

------------------------------------------------------------------------
-- Desert Pyramid registration.
------------------------------------------------------------------------

local desert_pyramid_biomes = {
	"Desert",
}

mcl_levelgen.modify_biome_groups (desert_pyramid_biomes, {
	has_desert_pyramid = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:desert_pyramid", {
	create_start = desert_pyramid_create_start,
	step = mcl_levelgen.SURFACE_STRUCTURES,
	terrain_adaptation = "none",
	biomes = mcl_levelgen.build_biome_list ({"#has_desert_pyramid",}),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:desert_pyramids", {
	structures = {
		"mcl_levelgen:desert_pyramid",
	},
	placement = R (1.0, "default", 32, 8, 14357617, "linear",
		       nil, nil),
})

-- 3228473
