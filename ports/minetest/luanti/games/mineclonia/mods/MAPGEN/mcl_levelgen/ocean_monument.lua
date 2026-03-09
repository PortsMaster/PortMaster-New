local ipairs = ipairs
local R = mcl_levelgen.build_random_spread_placement

------------------------------------------------------------------------
-- Ocean Monument.
------------------------------------------------------------------------

local level_to_minetest_position = mcl_levelgen.level_to_minetest_position
local v = vector.zero ()
local staticdata = core.serialize ({
	_structure_generation_spawn = true,
	persistent = true,
})

local function handle_monument_elder_guardian (_, data)
	local x, y, z = level_to_minetest_position (data.x, data.y, data.z)
	v.x = x
	v.y = y - 0.5
	v.z = z
	core.add_entity (v, "mobs_mc:guardian_elder", staticdata)
end

if not mcl_levelgen.is_levelgen_environment then
	mcl_levelgen.register_notification_handler ("mcl_levelgen:monument_elder_guardian",
						    handle_monument_elder_guardian)
end

-- local cid_magenta_glass
-- 	= core.get_content_id ("mcl_core:glass_magenta")

local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local lshift = bit.lshift
local rshift = bit.rshift

local insert = table.insert
local floor = math.floor
local mathmax = math.max
local mathmin = math.min

local ipos3 = mcl_levelgen.ipos3
local ipos4 = mcl_levelgen.make_ipos_iterator ()

------------------------------------------------------------------------
-- Ocean Monument pieces.
-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/net/minecraft/structure/OceanMonumentGenerator.html
------------------------------------------------------------------------

local random_orientation = mcl_levelgen.random_orientation
local make_rotated_bbox = mcl_levelgen.make_rotated_bbox

-- https://maven.fabricmc.net/docs/yarn-1.21.5+build.1/constant-values.html#net.minecraft.structure.OceanMonumentGenerator.Piece
local GRID_WIDTH = 5
local GRID_LENGTH = 5
local GRID_HEIGHT = 3
local GRID_STOREY_MULTIPLIER = 25
local GRID_SIZE_TOTAL = 75

local SPECIAL_LEFTWING = 1002
local SPECIAL_RIGHTWING = 1003
local SPECIAL_PENTHOUSE = 1004

local function ordinary_index (x, y, z)
	return y * GRID_STOREY_MULTIPLIER + z * GRID_LENGTH + x + 1
end

local function decode_ordinary_index (idx)
	local x = (idx - 1) % 5
	local z = floor ((idx - 1) / 5) % 5
	local y = floor ((idx - 1) / 25)
	return x, y, z
end

local SOURCE = ordinary_index (2, 0, 0)
local TOP_GANGWAY = ordinary_index (2, 2, 0)
local LEFT_WING_GANGWAY = ordinary_index (0, 1, 0)
local RIGHT_WING_GANGWAY = ordinary_index (4, 1, 0)
local ORDINARY_GRID_MAX = ordinary_index (4, 4, 2)

local FLAG_SOURCE = 0x80
local FLAG_ALLOCATED = 0x40
-- local FLAG_NEIGHBOR_5_CONNECTED = 0x20
-- local FLAG_NEIGHBOR_4_CONNECTED = 0x10
local FLAG_NEIGHBOR_3_CONNECTED = 0x08
-- local FLAG_NEIGHBOR_2_CONNECTED = 0x04
local FLAG_NEIGHBOR_1_CONNECTED = 0x02
-- local FLAG_NEIGHBOR_0_CONNECTED = 0x01
local ALL_NEIGHBORS		= 0x3f
local OPENING_DOWN		= 0x100
local OPENING_UP		= 0x200
local OPENING_NORTH		= 0x400
local OPENING_SOUTH		= 0x800
local OPENING_WEST		= 0x1000
local OPENING_EAST		= 0x2000
local OPENING_SHIFT		= 8
local OPENING_MASK		= bnot (0x3f00)

local function make_grid_pos_data (idx, flags)
	return {
		index = idx,
		neighbors = {},
		flags = flags or 0,
	}
end

local ROOM_DIRS = {
	0, -1, 0, 0,
	0, 1, 0, 1,
	0, 0, -1, 2,
	0, 0, 1, 3,
	-1, 0, 0, 4,
	1, 0, 0, 5,
}

-- local DOWN = 0
local UP = 1
local NORTH = 2
-- local SOUTH = 3
-- local WEST = 4
local EAST = 5

local opposites = {
	[0] = 1,
	0,
	3,
	2,
	5,
	4,
}

local function alter_grid_data (tem, flag)
	tem.flags = bor (tem.flags, flag)
end

local function alter_neighbor (tem, id, flag)
	local neighbor = tem.neighbors[id]
	neighbor.flags = bor (neighbor.flags, flag)
end

local function update_openings_from_neighbors (tem)
	local neighbors = band (tem.flags, ALL_NEIGHBORS)
	tem.flags = bor (band (tem.flags, OPENING_MASK),
			 lshift (neighbors, OPENING_SHIFT))
end

local function is_source_accessible (data, ticket)
	if band (data.flags, FLAG_SOURCE) ~= 0 then
		return true
	else
		data.search_ticket = ticket

		for i = 0, 5 do
			local opening_flag = lshift (1, i + OPENING_SHIFT)
			local neighbor = data.neighbors[i]

			if neighbor
			-- Prevent recursion.
				and neighbor.search_ticket ~= ticket
				and band (data.flags, opening_flag) ~= 0
				and is_source_accessible (neighbor, ticket) then
				return true
			end
		end

		return false
	end
end

local fisher_yates = mcl_levelgen.fisher_yates

-- https://minecraft.wiki/w/Ocean_Monument/Structure#Structure_generation
local function create_monument_blueprint (piece, rng)
	local grid = {}

	for gx, gy, gz in ipos3 (0, 0, 0, 4, 1, 3) do
		local index = ordinary_index (gx, gy, gz)
		grid[index] = make_grid_pos_data (index)
	end

	for gx, gy, gz in ipos3 (1, 2, 0, 3, 2, 1) do
		local index = ordinary_index (gx, gy, gz)
		grid[index] = make_grid_pos_data (index)
	end

	piece.source_room = grid[SOURCE]
	assert (piece.source_room)
	piece.source_room.flags = bor (piece.source_room.flags, FLAG_SOURCE,
				       FLAG_ALLOCATED)

	-- Connect each allocated room to its neighbors.
	for x, z, y in ipos3 (0, 0, 0, 4, 4, 2) do
		local index = ordinary_index (x, y, z)
		local room = grid[index]

		if room then
			for i = 1, 24, 4 do
				local xadj, yadj, zadj = x + ROOM_DIRS[i],
					y + ROOM_DIRS[i + 1],
					z + ROOM_DIRS[i + 2]

				if xadj >= 0 and xadj < GRID_WIDTH
					and zadj >= 0 and zadj < GRID_LENGTH
					and yadj >= 0 and yadj < GRID_HEIGHT then
					local dirid = ROOM_DIRS[i + 3]
					local opposite = opposites[dirid]
					local neighbor = grid[ordinary_index (xadj, yadj, zadj)]
					if neighbor then
						if zadj == z then
							local flag = lshift (1, dirid)
							local opposite_flag = lshift (1, opposite)
							room.flags = bor (room.flags, flag)
							room.neighbors[dirid] = neighbor
							neighbor.flags = bor (neighbor.flags, opposite_flag)
							neighbor.neighbors[opposite] = room
						else
							-- The grid's Z axis is inverted
							-- by comparison with the level's.
							local flag = lshift (1, opposite)
							local opposite_flag = lshift (1, dirid)
							room.flags = bor (room.flags, flag)
							room.neighbors[opposite] = neighbor
							neighbor.flags = bor (neighbor.flags, opposite_flag)
							neighbor.neighbors[dirid] = room
						end
					end
				end
			end
		end
	end

	local tem = grid[TOP_GANGWAY]
	tem.flags = bor (tem.flags, FLAG_NEIGHBOR_1_CONNECTED)
	local penthouse = make_grid_pos_data (SPECIAL_PENTHOUSE, FLAG_ALLOCATED)
	tem.neighbors[1] = penthouse

	tem = grid[LEFT_WING_GANGWAY]
	tem.flags = bor (tem.flags, FLAG_NEIGHBOR_3_CONNECTED) -- south
	local wing_left = make_grid_pos_data (SPECIAL_LEFTWING, FLAG_ALLOCATED)
	tem.neighbors[3] = wing_left

	tem = grid[RIGHT_WING_GANGWAY]
	tem.flags = bor (tem.flags, FLAG_NEIGHBOR_3_CONNECTED) -- south
	local wing_right = make_grid_pos_data (SPECIAL_RIGHTWING, FLAG_ALLOCATED)
	tem.neighbors[3] = wing_right

	-- Select a central room at random.
	local x = rng:next_within (4)
	tem = grid[ordinary_index (x, 0, 2)]
	tem.flags = bor (tem.flags, FLAG_ALLOCATED)

	-- Allocate neighbors of the central room.
	alter_neighbor (tem, EAST, FLAG_ALLOCATED)
	alter_neighbor (tem, NORTH, FLAG_ALLOCATED)
	alter_neighbor (tem, UP, FLAG_ALLOCATED)

	alter_neighbor (tem.neighbors[EAST], NORTH, FLAG_ALLOCATED)
	alter_neighbor (tem.neighbors[EAST], UP, FLAG_ALLOCATED)
	alter_neighbor (tem.neighbors[NORTH], UP, FLAG_ALLOCATED)
	alter_neighbor (tem.neighbors[EAST].neighbors[NORTH], UP, FLAG_ALLOCATED)
	piece.central_room = tem

	-- Create a list of (possibly allocated) grid positions
	-- awaiting room assignment.
	local nodes = {}
	update_openings_from_neighbors (penthouse)
	for i = 1, ORDINARY_GRID_MAX do
		local value = grid[i]
		if value then
			update_openings_from_neighbors (value)
			insert (nodes, value)
		end
	end
	fisher_yates (nodes, rng)

	local ticket = 0
	for _, data in ipairs (nodes) do
		local cnt_sealed = 0

		for i = 1, 5 do
			if cnt_sealed >= 2 then
				break
			end

			local dir = rng:next_within (6)
			if band (data.flags, lshift (1, OPENING_SHIFT + dir)) ~= 0 then
				local opposite = opposites[dir]

				-- Temporarily interrupt this connection and
				-- leave it sealed if the source remains
				-- accessible from both sides.
				local dir_flag = lshift (1, dir + OPENING_SHIFT)
				local opposite_flag = lshift (1, opposite + OPENING_SHIFT)
				local neighbor = data.neighbors[dir]

				data.flags = band (data.flags, bnot (dir_flag))
				neighbor.flags = band (neighbor.flags, bnot (opposite_flag))
				local ticket_a = ticket + 1
				local ticket_b = ticket + 2
				ticket = ticket_b
				if is_source_accessible (data, ticket_a)
					and is_source_accessible (neighbor, ticket_b) then
					cnt_sealed = cnt_sealed + 1
				else
					data.flags = bor (data.flags, dir_flag)
					neighbor.flags = bor (neighbor.flags, opposite_flag)
				end
			end
		end
	end
	insert (nodes, penthouse)
	insert (nodes, wing_left)
	insert (nodes, wing_right)
	return nodes
end

local function bbox_in_grid (dir, data, width, height, length)
	local x, y, z = decode_ordinary_index (data.index)
	local bbox = make_rotated_bbox (0, 0, 0, dir, width * 8,
					height * 4, length * 8)
	local dx, dy, dz

	if dir == "north" then
		dx = x * 8
		dy = y * 4
		dz = -(z + length) * 8 + 1
	elseif dir == "west" then
		dx = -(z + length) * 8 + 1
		dy = y * 4
		dz = x * 8
	elseif dir == "south" then
		dx = x * 8
		dy = y * 4
		dz = z * 8
	else --if dir == "east" then
		dx = z * 8
		dy = y * 4
		dz = x * 8
	end

	bbox[1] = bbox[1] + dx
	bbox[4] = bbox[4] + dx
	bbox[2] = bbox[2] + dy
	bbox[5] = bbox[5] + dy
	bbox[3] = bbox[3] + dz
	bbox[6] = bbox[6] + dz
	return bbox
end

local create_central_room
local create_source_room
local meta_piece_place

-- Monument superstructure.
local reorientate_coords = mcl_levelgen.reorientate_coords
local translate_pieces = mcl_levelgen.translate_pieces
local room_types

local function block_box_from_corners (self, x1, y1, z1, x2, y2, z2)
	local x1, y1, z1 = reorientate_coords (self, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (self, x2, y2, z2)

	return {
		mathmin (x1, x2),
		mathmin (y1, y2),
		mathmin (z1, z2),
		mathmax (x1, x2),
		mathmax (y1, y2),
		mathmax (z1, z2),
	}
end

local create_wing_room
local create_penthouse_room

local function create_monument_base (rng, x, z)
	local dir = random_orientation (rng)
	local bbox = make_rotated_bbox (x, 39, z, dir, 58, 23, 58)
	local meta_piece = {
		bbox = bbox,
		dir = dir,
		place = meta_piece_place,
	}

	local blueprint = create_monument_blueprint (meta_piece, rng)

	-- Create the central and source rooms.
	local pieces = {
		create_source_room (dir, meta_piece.source_room),
		create_central_room (dir, meta_piece.central_room),
	}
	local org_x, org_y, org_z = reorientate_coords (meta_piece, 9, 0, 22)

	-- Assign various types of rooms to positions on the grid.
	for _, data in ipairs (blueprint) do
		if band (data.flags, FLAG_ALLOCATED) == 0
		-- Not a penthouse or wing node.
			and data.index <= GRID_SIZE_TOTAL then
			for _, roomtype in ipairs (room_types) do
				if roomtype[1] (data) then
					local piece = roomtype[2] (rng, dir, data)
					insert (pieces, piece)
					break
				end
			end
		end
	end
	translate_pieces (pieces, org_x, org_y, org_z)
	meta_piece.pieces = pieces

	local wing_left_bbox
		= block_box_from_corners (meta_piece, 1, 1, 1, 23, 8, 21)
	local wing_right_bbox
		= block_box_from_corners (meta_piece, 34, 1, 1, 56, 8, 21)
	local penthouse_bbox
		= block_box_from_corners (meta_piece, 22, 13, 22, 35, 17, 35)

	local design_selector = rng:next_integer ()
	insert (pieces, create_wing_room (dir, wing_left_bbox, design_selector))
	insert (pieces, create_wing_room (dir, wing_right_bbox, design_selector + 1))
	insert (pieces, create_penthouse_room (dir, penthouse_bbox))

	return meta_piece
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

local cid_ice = getcid ("mcl_core:ice")
local cid_packed_ice = getcid ("mcl_core:packed_ice")
local cid_blue_ice = getcid ("mcl_core:blue_ice")
local cid_water_source = getcid ("mcl_core:water_source")

local cid_air = core.CONTENT_AIR

local set_block_checked = mcl_levelgen.set_block_checked
local set_block = mcl_levelgen.set_block

local function water_replaceable_p (cid, param2)
	return cid ~= cid_water_source
		and cid ~= cid_ice
		and cid ~= cid_packed_ice
		and cid ~= cid_blue_ice
end

local sea_level

local function fill_water (piece, x1, y1, z1, x2, y2, z2)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		if y >= sea_level then
			set_block_checked (x, y, z, cid_air, 0,
					   water_replaceable_p)
		else
			set_block_checked (x, y, z, cid_water_source, 0,
					   water_replaceable_p)
		end
	end
end

local function fill_area (piece, x1, y1, z1, x2, y2, z2, cid, param2)
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

local water_source_p = mcl_levelgen.water_source_p

local function fill_water_in_area (piece, x1, y1, z1, x2, y2, z2, cid, param2)
	local x1, y1, z1 = reorientate_coords (piece, x1, y1, z1)
	local x2, y2, z2 = reorientate_coords (piece, x2, y2, z2)

	for x, y, z in ipos3 (mathmin (x1, x2),
			      y1,
			      mathmin (z1, z2),
			      mathmax (x1, x2),
			      y2,
			      mathmax (z1, z2)) do
		set_block_checked (x, y, z, cid, param2, water_source_p)
	end
end

local function set_block_reorientated (piece, x, y, z, cid, param2)
	local x, y, z = reorientate_coords (piece, x, y, z)
	set_block (x, y, z, cid, param2)
end

local cid_prismarine = getcid ("mcl_ocean:prismarine")
local cid_prismarine_bricks
	= getcid ("mcl_ocean:prismarine_brick")
local cid_dark_prismarine
	= getcid ("mcl_ocean:prismarine_dark")
local cid_sea_lantern
	= getcid ("mcl_ocean:sea_lantern")
local px1, pz1, px2, pz2

local function intersect_local_p (self, lx1, lz1, lx2, lz2)
	local lx1, _, lz1 = reorientate_coords (self, lx1, 0, lz1)
	local lx2, _, lz2 = reorientate_coords (self, lx2, 0, lz2)
	local bx1 = mathmin (lx1, lx2)
	local bz1 = mathmin (lz1, lz2)
	local bx2 = mathmax (lx1, lx2)
	local bz2 = mathmax (lz1, lz2)

	return bx2 >= px1 and bx1 <= px2
		and bz2 >= pz1 and bz1 <= pz2
end

-- The coordinates provided to various functions were obtained by
-- monitoring the execution of Minecraft's ocean monument generator
-- class under the `jdump' tool.

local function place_wing (self, is_right, dx)
	if not intersect_local_p (self, dx, 0, dx + 23, 20) then
		return false
	end

	-- Generate the base.
	fill_area (self, dx, 0, 0, dx + 24, 0, 20, cid_prismarine, 0)
	fill_water (self, dx, 1, 0, dx + 24, 10, 20)

	-- Generate the steps of the pyramid.
	for ring = 0, 3 do
		fill_area (self, dx + ring, ring + 1, ring,
			   dx + ring, ring + 1, 20,
			   cid_prismarine_bricks, 0)
		fill_area (self, dx + ring + 7, ring + 5, ring + 7,
			   dx + ring + 7, ring + 5, 20,
			   cid_prismarine_bricks, 0)
		fill_area (self, dx + 17 - ring, ring + 5,
			   ring + 7, dx + 17 - ring, ring + 5, 20,
			   cid_prismarine_bricks, 0)
		fill_area (self, dx + 24 - ring, ring + 1,
			   ring, dx + 24 - ring, ring + 1, 20,
			   cid_prismarine_bricks, 0)
		fill_area (self, dx + ring + 1, ring + 1,
			   ring, dx + 23 - ring, ring + 1, ring,
			   cid_prismarine_bricks, 0)
		fill_area (self, dx + ring + 8, ring + 5,
			   ring + 7, dx + 16 - ring, ring + 5, ring + 7,
			   cid_prismarine_bricks, 0)
	end

	-- Pyramid surfaces.
	fill_area (self, dx + 4, 4, 4, dx + 6, 4, 20, cid_prismarine, 0)
	fill_area (self, dx + 7, 4, 4, dx + 17, 4, 6, cid_prismarine, 0)
	fill_area (self, dx + 18, 4, 4, dx + 20, 4, 20, cid_prismarine, 0)
	fill_area (self, dx + 11, 8, 11, dx + 13, 8, 20, cid_prismarine, 0)

	-- Studs.
	set_block_reorientated (self, dx + 12, 9, 12, cid_prismarine_bricks, 0)
	set_block_reorientated (self, dx + 12, 9, 15, cid_prismarine_bricks, 0)
	set_block_reorientated (self, dx + 12, 9, 18, cid_prismarine_bricks, 0)

	local x1, x2
	if is_right then
		x1 = dx + 19
		x2 = dx + 5
	else
		x1 = dx + 5
		x2 = dx + 19
	end

	for z = 20, 5, -3 do
		set_block_reorientated (self, x1, 5, z, cid_prismarine_bricks, 0)
	end

	for z = 19, 7, -3 do
		set_block_reorientated (self, x2, 5, z, cid_prismarine_bricks, 0)
	end

	for x = 0, 3 do
		local xoff = 17 - x * 3

		-- Mirror if right.
		local xpos = is_right and dx + 24 - xoff or dx + xoff
		set_block_reorientated (self, xpos, 5, 5, cid_prismarine_bricks, 0)
	end

	set_block_reorientated (self, x2, 5, 5, cid_prismarine_bricks, 0)

	-- Pillars.
	fill_area (self, dx + 11, 1, 12, dx + 13, 7, 12, cid_prismarine, 0)
	fill_area (self, dx + 12, 1, 11, dx + 12, 7, 13, cid_prismarine, 0)
end

local function place_arch (self)
	if not intersect_local_p (self, 22, 5, 35, 17) then
		return false
	end

	fill_water (self, 25, 0, 0, 32, 8, 20)

	for zlayer = 0, 3 do
		local dz = 5 + zlayer * 4
		fill_area (self, 24, 2, dz, 24, 4, dz, cid_prismarine_bricks, 0)
		fill_area (self, 22, 4, dz, 23, 4, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 25, 5, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 26, 6, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 26, 5, dz, cid_sea_lantern, 0)
		fill_area (self, 33, 2, dz, 33, 4, dz, cid_prismarine_bricks, 0)
		fill_area (self, 34, 4, dz, 35, 4, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 32, 5, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 31, 6, dz, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 31, 5, dz, cid_sea_lantern, 0)
		fill_area (self, 27, 6, dz, 30, 6, dz, cid_prismarine, 0)
	end
end

local function place_front_facade_wall (self)
	if not intersect_local_p (self, 15, 20, 42, 21) then
		return false
	end

	-- Wall with opening.
	fill_area (self, 15, 0, 21, 42, 0, 21, cid_prismarine, 0)
	fill_water (self, 26, 1, 21, 31, 3, 21)
	fill_area (self, 21, 12, 21, 36, 12, 21, cid_prismarine, 0)
	fill_area (self, 17, 11, 21, 40, 11, 21, cid_prismarine, 0)
	fill_area (self, 16, 10, 21, 41, 10, 21, cid_prismarine, 0)
	fill_area (self, 15, 7, 21, 42, 9, 21, cid_prismarine, 0)
	fill_area (self, 16, 6, 21, 41, 6, 21, cid_prismarine, 0)
	fill_area (self, 17, 5, 21, 40, 5, 21, cid_prismarine, 0)
	fill_area (self, 21, 4, 21, 36, 4, 21, cid_prismarine, 0)
	fill_area (self, 22, 3, 21, 26, 3, 21, cid_prismarine, 0)
	fill_area (self, 31, 3, 21, 35, 3, 21, cid_prismarine, 0)
	fill_area (self, 23, 2, 21, 25, 2, 21, cid_prismarine, 0)
	fill_area (self, 32, 2, 21, 34, 2, 21, cid_prismarine, 0)

	-- Entrance overhang.
	fill_area (self, 28, 4, 20, 29, 4, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 27, 3, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 30, 3, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 26, 2, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 31, 2, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 25, 1, 21, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 32, 1, 21, cid_prismarine_bricks, 0)

	-- V pattern.
	for i = 0, 6 do
		set_block_reorientated (self, 28 - i, 6 + i, 21, cid_dark_prismarine, 0)
		set_block_reorientated (self, 29 + i, 6 + i, 21, cid_dark_prismarine, 0)
	end

	-- Smaller V pattern.
	for i = 0, 3 do
		set_block_reorientated (self, 28 - i, 9 + i, 21, cid_dark_prismarine, 0)
		set_block_reorientated (self, 29 + i, 9 + i, 21, cid_dark_prismarine, 0)
	end

	-- 0 length V pattern.
	set_block_reorientated (self, 28, 12, 21, cid_dark_prismarine, 0)
	set_block_reorientated (self, 29, 12, 21, cid_dark_prismarine, 0)

	-- Bars.
	for i = 0, 2 do
		local dx = i * 2
		set_block_reorientated (self, 22 - dx, 8, 21, cid_dark_prismarine, 0)
		set_block_reorientated (self, 22 - dx, 9, 21, cid_dark_prismarine, 0)
		set_block_reorientated (self, 35 + dx, 8, 21, cid_dark_prismarine, 0)
		set_block_reorientated (self, 35 + dx, 9, 21, cid_dark_prismarine, 0)
	end

	-- Clear empty spaces.
	fill_water (self, 15, 13, 21, 42, 15, 21)
	fill_water (self, 15, 1, 21, 15, 6, 21)
	fill_water (self, 16, 1, 21, 16, 5, 21)
	fill_water (self, 17, 1, 21, 20, 4, 21)
	fill_water (self, 21, 1, 21, 21, 3, 21)
	fill_water (self, 22, 1, 21, 22, 2, 21)
	fill_water (self, 23, 1, 21, 24, 1, 21)
	fill_water (self, 42, 1, 21, 42, 6, 21)
	fill_water (self, 41, 1, 21, 41, 5, 21)
	fill_water (self, 37, 1, 21, 40, 4, 21)
	fill_water (self, 36, 1, 21, 36, 3, 21)
	fill_water (self, 33, 1, 21, 34, 1, 21)
	fill_water (self, 35, 1, 21, 35, 2, 21)
end

local function place_roof_and_floor (self)
	if not intersect_local_p (self, 21, 21, 36, 36) then
		return false
	end
	fill_area (self, 21, 0, 22, 36, 0, 36, cid_prismarine, 0)

	-- Bottom floor.
	fill_water (self, 21, 1, 22, 36, 23, 36)

	-- Generate steps.
	for d = 0, 3 do
		-- Front and back.
		fill_area (self, 21 + d, 13 + d, 21 + d, 36 - d, 13 + d, 21 + d,
			   cid_prismarine_bricks, 0)
		fill_area (self, 21 + d, 13 + d, 36 - d, 36 - d, 13 + d, 36 - d,
			   cid_prismarine_bricks, 0)

		-- Left and right.
		fill_area (self, 21 + d, 13 + d, 22 + d, 21 + d, 13 + d, 35 - d,
			   cid_prismarine_bricks, 0)
		fill_area (self, 36 - d, 13 + d, 22 + d, 36 - d, 13 + d, 35 - d,
			   cid_prismarine_bricks, 0)
	end

	-- Ceiling.
	fill_area (self, 25, 16, 25, 32, 16, 32, cid_prismarine, 0)

	-- Pillars.
	fill_area (self, 25, 17, 25, 25, 19, 25, cid_prismarine_bricks, 0)
	fill_area (self, 32, 17, 25, 32, 19, 25, cid_prismarine_bricks, 0)
	fill_area (self, 25, 17, 32, 25, 19, 32, cid_prismarine_bricks, 0)
	fill_area (self, 32, 17, 32, 32, 19, 32, cid_prismarine_bricks, 0)

	-- Arches w/ lamps.
	set_block_reorientated (self, 26, 20, 26, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 27, 21, 27, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 26, 20, 31, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 27, 21, 30, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 31, 20, 31, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 30, 21, 30, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 31, 20, 26, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 30, 21, 27, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 27, 20, 27, cid_sea_lantern, 0)
	set_block_reorientated (self, 27, 20, 30, cid_sea_lantern, 0)
	set_block_reorientated (self, 30, 20, 30, cid_sea_lantern, 0)
	set_block_reorientated (self, 30, 20, 27, cid_sea_lantern, 0)
	fill_area (self, 28, 21, 27, 29, 21, 27, cid_prismarine, 0)
	fill_area (self, 27, 21, 28, 27, 21, 29, cid_prismarine, 0)
	fill_area (self, 28, 21, 30, 29, 21, 30, cid_prismarine, 0)
	fill_area (self, 30, 21, 28, 30, 21, 29, cid_prismarine, 0)
end

local function place_low_wall (self)
	-- Left.

	if intersect_local_p (self, 0, 21, 6, 58) then
		fill_area (self, 0, 0, 21, 6, 0, 57, cid_prismarine, 0)
		fill_water (self, 0, 1, 21, 6, 7, 57)
		fill_area (self, 4, 4, 21, 6, 4, 53, cid_prismarine, 0)

		-- Steps.
		for d = 0, 3 do
			fill_area (self, d, d + 1, 21, d, d + 1, 57 - d,
				   cid_prismarine_bricks, 0)
		end

		-- Studs.
		for z = 23, 50, 3 do
			set_block_reorientated (self, 5, 5, z, cid_prismarine_bricks, 0)
		end
		set_block_reorientated (self, 5, 5, 52, cid_prismarine_bricks, 0)

		-- Pillar.
		fill_area (self, 4, 1, 52, 6, 3, 52, cid_prismarine, 0)
		fill_area (self, 5, 1, 51, 5, 3, 53, cid_prismarine, 0)
	end

	-- Right.

	if intersect_local_p (self, 51, 21, 58, 58) then
		fill_area (self, 51, 0, 21, 57, 0, 57, cid_prismarine, 0)
		fill_water (self, 51, 1, 21, 57, 7, 57)
		fill_area (self, 51, 4, 21, 53, 4, 53, cid_prismarine, 0)

		-- Steps.
		for d = 0, 3 do
			fill_area (self, 57 - d, d + 1, 21, 57 - d, d + 1, 57 - d,
				   cid_prismarine_bricks, 0)
		end

		-- Studs.
		for z = 23, 50, 3 do
			set_block_reorientated (self, 52, 5, z, cid_prismarine_bricks, 0)
		end
		set_block_reorientated (self, 52, 5, 52, cid_prismarine_bricks, 0)

		-- Pillar.
		fill_area (self, 51, 1, 52, 53, 3, 52, cid_prismarine, 0)
		fill_area (self, 52, 1, 51, 52, 3, 53, cid_prismarine, 0)
	end

	-- Back.
	if intersect_local_p (self, 0, 51, 57, 57) then
		fill_area (self, 7, 0, 51, 50, 0, 57, cid_prismarine, 0)
		fill_water (self, 7, 1, 51, 50, 10, 57)

		-- Steps.
		for d = 0, 3 do
			fill_area (self, d + 1, d + 1, 57 - d, 56 - d, d + 1, 57 - d,
				   cid_prismarine_bricks, 0)
		end
	end
end

local function place_decorated_wall (self)
	if intersect_local_p (self, 7, 21, 13, 54) then
		fill_area (self, 7, 0, 21, 13, 0, 50, cid_prismarine, 0)
		fill_water (self, 7, 1, 21, 13, 10, 50)
		fill_area (self, 11, 8, 21, 13, 8, 53, cid_prismarine, 0)

		-- Steps & studs.

		for i = 0, 3 do
			fill_area (self, i + 7, i + 5, 21, i + 7, i + 5, 54,
				   cid_prismarine_bricks, 0)
		end

		for z = 21, 45, 3 do
			set_block_reorientated (self, 12, 9, z, cid_prismarine_bricks, 0)
		end
	end

	if intersect_local_p (self, 44, 21, 50, 54) then
		fill_area (self, 44, 0, 21, 50, 0, 50, cid_prismarine, 0)
		fill_water (self, 44, 1, 21, 50, 10, 50)
		fill_area (self, 44, 8, 21, 46, 8, 53, cid_prismarine, 0)

		-- Steps & studs.

		for i = 0, 3 do
			fill_area (self, 50 - i, i + 5, 21, 50 - i, i + 5, 54,
				   cid_prismarine_bricks, 0)
		end

		for z = 21, 45, 3 do
			set_block_reorientated (self, 45, 9, z, cid_prismarine_bricks, 0)
		end
	end

	-- Rear decorated area.

	if intersect_local_p (self, 8, 44, 49, 54) then
		fill_area (self, 14, 0, 44, 53, 0, 50, cid_prismarine, 0)
		fill_water (self, 14, 1, 44, 43, 10, 50)

		for x = 12, 45, 3 do
			set_block_reorientated (self, x, 9, 45, cid_prismarine_bricks, 0)
			set_block_reorientated (self, x, 9, 52, cid_prismarine_bricks, 0)

			if x == 12 or x == 18 or x == 24 or x == 33 or x == 39 or x == 45 then
				set_block_reorientated (self, x, 9, 47, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 9, 50, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 10, 45, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 10, 46, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 10, 51, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 10, 52, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 11, 47, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 11, 50, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 12, 48, cid_prismarine_bricks, 0)
				set_block_reorientated (self, x, 12, 49, cid_prismarine_bricks, 0)
			end
		end

		-- Rear wall.

		for d = 0, 2 do
			fill_area (self, 8 + d, 5 + d, 54, 49 - d, 5 + d, 54,
				   cid_prismarine, 0)
		end

		fill_area (self, 11, 8, 54, 46, 8, 54, cid_prismarine_bricks, 0)
		fill_area (self, 14, 8, 44, 43, 8, 53, cid_prismarine, 0)
	end
end

local function place_upper_wall (self)
	if intersect_local_p (self, 14, 21, 20, 43) then
		fill_area (self, 14, 0, 21, 20, 0, 43, cid_prismarine, 0)
		fill_water (self, 14, 1, 22, 20, 14, 43)
		fill_area (self, 18, 12, 22, 20, 12, 39, cid_prismarine, 0)
		fill_area (self, 18, 12, 21, 20, 12, 21, cid_prismarine_bricks, 0)

		for i = 0, 3 do
			fill_area (self, i + 14, i + 9, 21, i + 14, i + 9, 43 - i,
				   cid_prismarine_bricks, 0)
		end

		for i = 23, 39, 3 do
			set_block_reorientated (self, 19, 13, i,
						cid_prismarine_bricks, 0)
		end
	end

	if intersect_local_p (self, 37, 21, 43, 43) then
		fill_area (self, 37, 0, 21, 43, 0, 43, cid_prismarine, 0)
		fill_water (self, 37, 1, 22, 43, 14, 43)
		fill_area (self, 37, 12, 22, 39, 12, 39, cid_prismarine, 0)
		fill_area (self, 37, 12, 21, 39, 12, 21, cid_prismarine_bricks, 0)

		for i = 0, 3 do
			fill_area (self, 43 - i, 9 + i, 21, 43 - i, 9 + i, 43 - i,
				   cid_prismarine_bricks, 0)
		end

		for i = 23, 39, 3 do
			set_block_reorientated (self, 38, 13, i,
						cid_prismarine_bricks, 0)
		end
	end

	if intersect_local_p (self, 15, 37, 42, 43) then
		fill_area (self, 21, 0, 37, 36, 0, 43, cid_prismarine, 0)
		fill_water (self, 21, 1, 37, 36, 14, 43)
		fill_area (self, 21, 12, 37, 36, 12, 39, cid_prismarine, 0)

		for i = 0, 3 do
			fill_area (self, 15 + i, 9 + i, 43 - i, 42 - i, 9 + i, 43 - i,
				   cid_prismarine_bricks, 0)
		end

		for i = 21, 36, 3 do
			set_block_reorientated (self, i, 13, 38,
						cid_prismarine_bricks, 0)
		end
	end
end

local strut_positions = {
	0, 0,
	0, 1,
	0, 2,
	0, 3,
	0, 4,
	0, 5,
	0, 6,
	1, 0,
	1, 6,
	2, 0,
	2, 6,
	3, 6,
	4, 0,
	4, 6,
	5, 0,
	5, 6,
	6, 0,
	6, 1,
	6, 2,
	6, 3,
	6, 4,
	6, 5,
	6, 6,
}

local index_heightmap = mcl_levelgen.index_heightmap
local water_or_air_p = mcl_levelgen.water_or_air_p

local function generate_struts (self)
	local ybase = self.bbox[2]
	for i = 1, #strut_positions, 2 do
		local x = strut_positions[i]
		local z = strut_positions[i + 1]

		local bx = x * 9
		local bz = z * 9

		if intersect_local_p (self, bx, bz, bx + 3, bz + 3) then
			for x, _, z in ipos4 (bx, 0, bz, bx + 3, 0, bz + 3) do
				local x, _, z = reorientate_coords (self, x, 0, z)
				local _, motion_blocking = index_heightmap (x, z, true)
				if motion_blocking > -64 then
					for y = ybase, motion_blocking, -1 do
						set_block (x, y, z, cid_prismarine_bricks, 0,
							   water_or_air_p)
					end
				end
			end
		end
	end
end

local function clear_surroundings_graded (self)
	for step = 0, 4 do
		fill_water (self, -1 - step, 0 + step * 2, -1 - step, -1 - step, 23, 58 + step)
		fill_water (self, 58 + step, 0 + step * 2, -1 - step, 58 + step, 23, 58 + step)
		fill_water (self, 0 - step, 0 + step * 2, -1 - step, 57 + step, 23, -1 - step)
		fill_water (self, 0 - step, 0 + step * 2, 58 + step, 57 + step, 23, 58 + step)
	end
end

local intersect_2d_p = mcl_levelgen.intersect_2d_p

function meta_piece_place (self, level, terrain, rng, x1, z1, x2, z2)
	sea_level = level.preset.sea_level
	local bbox = self.bbox
	px1, pz1, px2, pz2 = x1, z1, x2, z2
	fill_water (self, 0, 0, 0, 58, mathmax (sea_level, 64) - bbox[2], 58)
	place_wing (self, false, 0)
	place_wing (self, true, 33)
	place_arch (self)
	place_front_facade_wall (self)
	place_roof_and_floor (self)
	place_low_wall (self)
	place_decorated_wall (self)
	place_upper_wall (self)
	generate_struts (self)
	clear_surroundings_graded (self)

	for _, child in ipairs (self.pieces) do
		if intersect_2d_p (child.bbox, x1, z1, x2, z2) then
			child:place (level, terrain, rng, x1, z1, x2, z2)
		end
	end
end

-- Source room piece.

local function source_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	fill_area (self, 0, 3, 0, 2, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 5, 3, 0, 7, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 0, 2, 0, 1, 2, 7, cid_prismarine_bricks, 0)
	fill_area (self, 6, 2, 0, 7, 2, 7, cid_prismarine_bricks, 0)
	fill_area (self, 0, 1, 0, 0, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 7, 1, 0, 7, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 0, 1, 7, 7, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 0, 2, 3, 0, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 0, 6, 3, 0, cid_prismarine_bricks, 0)

	local flags = self.data.flags
	if band (flags, OPENING_NORTH) ~= 0 then
		fill_water (self, 3, 1, 7, 4, 2, 7)
	end
	if band (flags, OPENING_WEST) ~= 0 then
		fill_water (self, 0, 1, 3, 1, 2, 4)
	end
	if band (flags, OPENING_EAST) ~= 0 then
		fill_water (self, 6, 1, 3, 7, 2, 4)
	end
end

function create_source_room (dir, data)
	local bbox = bbox_in_grid (dir, data, 1, 1, 1)
	return {
		data = data,
		bbox = bbox,
		dir = dir,
		place = source_room_place,
	}
end

-- Central room piece.

local cid_gold_block = getcid ("mcl_core:goldblock")

local function fill_wall_layer (self, y, cid, param2)
	for x = 0, 15, 15 do
		fill_area (self, x, y, 0, x, y, 1, cid, param2)
		fill_area (self, x, y, 6, x, y, 9, cid, param2)
		fill_area (self, x, y, 14, x, y, 15, cid, param2)
	end

	set_block_reorientated (self, 1, y, 0, cid, param2)
	fill_area (self, 6, y, 0, 9, y, 0, cid, param2)
	set_block_reorientated (self, 14, y, 0, cid, param2)
	fill_area (self, 1, y, 15, 14, y, 15, cid, param2)
end

local function central_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	fill_water_in_area (self, 1, 8, 0, 14, 8, 14, cid_prismarine_bricks, 0)
	fill_area (self, 0, 7, 0, 0, 7, 15, cid_prismarine_bricks, 0)
	fill_area (self, 15, 7, 0, 15, 7, 15, cid_prismarine_bricks, 0)
	fill_area (self, 1, 7, 0, 15, 7, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 7, 15, 14, 7, 15, cid_prismarine_bricks, 0)

	fill_wall_layer (self, 1, cid_prismarine_bricks, 0)
	fill_wall_layer (self, 2, cid_prismarine, 0)
	fill_wall_layer (self, 3, cid_prismarine_bricks, 0)
	fill_wall_layer (self, 4, cid_prismarine_bricks, 0)
	fill_wall_layer (self, 5, cid_prismarine_bricks, 0)
	fill_wall_layer (self, 6, cid_prismarine, 0)

	-- Treasure cube.
	fill_area (self, 6, 3, 6, 9, 6, 9, cid_dark_prismarine, 0)
	fill_area (self, 7, 4, 7, 8, 5, 8, cid_gold_block, 0)

	-- Lamps.
	set_block_reorientated (self, 6, 3, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 6, 3, 9, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 3, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 3, 9, cid_sea_lantern, 0)
	set_block_reorientated (self, 6, 6, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 6, 6, 9, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 6, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 6, 9, cid_sea_lantern, 0)

	-- Arches and supports.
	fill_area (self, 5, 1, 6, 5, 2, 6, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 9, 5, 2, 9, cid_prismarine_bricks, 0)
	fill_area (self, 10, 1, 6, 10, 2, 6, cid_prismarine_bricks, 0)
	fill_area (self, 10, 1, 9, 10, 2, 9, cid_prismarine_bricks, 0)
	fill_area (self, 6, 1, 5, 6, 2, 5, cid_prismarine_bricks, 0)
	fill_area (self, 9, 1, 5, 9, 2, 5, cid_prismarine_bricks, 0)
	fill_area (self, 6, 1, 10, 6, 2, 10, cid_prismarine_bricks, 0)
	fill_area (self, 9, 1, 10, 9, 2, 10, cid_prismarine_bricks, 0)
	fill_area (self, 5, 2, 5, 5, 6, 5, cid_prismarine_bricks, 0)
	fill_area (self, 5, 2, 10, 5, 6, 10, cid_prismarine_bricks, 0)
	fill_area (self, 10, 2, 5, 10, 6, 5, cid_prismarine_bricks, 0)
	fill_area (self, 10, 2, 10, 10, 6, 10, cid_prismarine_bricks, 0)
	fill_area (self, 5, 7, 1, 5, 7, 6, cid_prismarine_bricks, 0)
	fill_area (self, 10, 7, 1, 10, 7, 6, cid_prismarine_bricks, 0)
	fill_area (self, 5, 7, 9, 5, 7, 14, cid_prismarine_bricks, 0)
	fill_area (self, 10, 7, 9, 10, 7, 14, cid_prismarine_bricks, 0)
	fill_area (self, 1, 7, 5, 6, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 1, 7, 10, 6, 7, 10, cid_prismarine_bricks, 0)
	fill_area (self, 9, 7, 5, 14, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 9, 7, 10, 14, 7, 10, cid_prismarine_bricks, 0)
	fill_area (self, 2, 1, 2, 2, 1, 3, cid_prismarine_bricks, 0)
	fill_area (self, 3, 1, 2, 3, 1, 2, cid_prismarine_bricks, 0)
	fill_area (self, 13, 1, 2, 13, 1, 3, cid_prismarine_bricks, 0)
	fill_area (self, 12, 1, 2, 12, 1, 2, cid_prismarine_bricks, 0)
	fill_area (self, 2, 1, 12, 2, 1, 13, cid_prismarine_bricks, 0)
	fill_area (self, 3, 1, 13, 3, 1, 13, cid_prismarine_bricks, 0)
	fill_area (self, 13, 1, 12, 13, 1, 13, cid_prismarine_bricks, 0)
	fill_area (self, 12, 1, 13, 12, 1, 13, cid_prismarine_bricks, 0)
end

function create_central_room (dir, data)
	local bbox = bbox_in_grid (dir, data, 2, 2, 2)
	return {
		data = data,
		bbox = bbox,
		dir = dir,
		place = central_room_place,
	}
end

local function is_opening_free (data, direction)
	local mask = lshift (1, direction + OPENING_SHIFT)
	if band (data.flags, mask) ~= 0 then
		return band (data.neighbors[direction].flags, FLAG_ALLOCATED) == 0
	end
	return false
end

-- Double XY room.

local function double_xy_room (origin)
	return is_opening_free (origin, EAST)
		and is_opening_free (origin, UP)
		and is_opening_free (origin.neighbors[EAST], UP)
end

local function generate_floor (self, x, z, create_vertical_connection)
	if create_vertical_connection then
		fill_area (self, x, 0, z, x + 2, 0, z + 7, cid_prismarine, 0)
		fill_area (self, x + 5, 0, z, x + 7, 0, z + 7, cid_prismarine, 0)
		fill_area (self, x + 3, 0, z, x + 4, 0, z + 2, cid_prismarine, 0)
		fill_area (self, x + 3, 0, z + 5, x + 4, 0, z + 7, cid_prismarine, 0)
		fill_area (self, x + 3, 0, z + 2, x + 4, 0, z + 2, cid_prismarine_bricks, 0)
		fill_area (self, x + 3, 0, z + 5, x + 4, 0, z + 5, cid_prismarine_bricks, 0)
		fill_area (self, x + 2, 0, z + 3, x + 2, 0, z + 4, cid_prismarine_bricks, 0)
		fill_area (self, x + 5, 0, z + 3, x + 5, 0, z + 4, cid_prismarine_bricks, 0)
	else
		fill_area (self, x, 0, z, x + 7, 0, z + 7, cid_prismarine, 0)
	end
end

local function has_flag (data, flag)
	return band (data.flags, flag) == flag
end

local function double_xy_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local east = self.data.neighbors[EAST]
	local _, gy, _ = decode_ordinary_index (data.index)

	if gy > 0 then
		generate_floor (self, 8, 0, has_flag (east, OPENING_DOWN))
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	local above = data.neighbors[UP]
	if not above.neighbors[UP] then
		fill_water_in_area (self, 1, 8, 1, 7, 8, 6, cid_prismarine, 0)
	end

	local east_above = east.neighbors[UP]
	if not east_above.neighbors[UP] then
		fill_water_in_area (self, 8, 8, 1, 14, 8, 6, cid_prismarine, 0)
	end

	-- Generate walls.
	for y = 1, 7 do
		local cid = cid_prismarine_bricks
		if y == 2 or y == 6 then
			cid = cid_prismarine
		end
		fill_area (self, 0, y, 0, 0, y, 7, cid, 0)
		fill_area (self, 15, y, 0, 15, y, 7, cid, 0)
		fill_area (self, 1, y, 0, 14, y, 0, cid, 0)
		fill_area (self, 1, y, 7, 14, y, 7, cid, 0)
	end

	-- Pillars.
	fill_area (self, 2, 1, 3, 2, 7, 4, cid_prismarine_bricks, 0)
	fill_area (self, 3, 1, 2, 4, 7, 2, cid_prismarine_bricks, 0)
	fill_area (self, 3, 1, 5, 4, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 13, 1, 3, 13, 7, 4, cid_prismarine_bricks, 0)
	fill_area (self, 11, 1, 2, 12, 7, 2, cid_prismarine_bricks, 0)
	fill_area (self, 11, 1, 5, 12, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 3, 5, 3, 4, cid_prismarine_bricks, 0)
	fill_area (self, 10, 1, 3, 10, 3, 4, cid_prismarine_bricks, 0)
	fill_area (self, 5, 7, 2, 10, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 5, 5, 2, 5, 7, 2, cid_prismarine_bricks, 0)
	fill_area (self, 10, 5, 2, 10, 7, 2, cid_prismarine_bricks, 0)
	fill_area (self, 5, 5, 5, 5, 7, 5, cid_prismarine_bricks, 0)
	fill_area (self, 10, 5, 5, 10, 7, 5, cid_prismarine_bricks, 0)

	-- Lamps.
	set_block_reorientated (self, 6, 6, 2, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 6, 2, cid_sea_lantern, 0)
	set_block_reorientated (self, 6, 6, 5, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 6, 5, cid_sea_lantern, 0)

	fill_area (self, 5, 4, 3, 6, 4, 4, cid_prismarine_bricks, 0)
	fill_area (self, 9, 4, 3, 10, 4, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 5, 4, 2, cid_sea_lantern, 0)
	set_block_reorientated (self, 5, 4, 5, cid_sea_lantern, 0)
	set_block_reorientated (self, 10, 4, 2, cid_sea_lantern, 0)
	set_block_reorientated (self, 10, 4, 5, cid_sea_lantern, 0)

	-- Connections.
	if has_flag (data, OPENING_SOUTH) then
		fill_water (self, 3, 1, 0, 4, 2, 0)
	end

	if has_flag (data, OPENING_NORTH) then
		fill_water (self, 3, 1, 7, 4, 2, 7)
	end

	if has_flag (data, OPENING_WEST) then
		fill_water (self, 0, 1, 3, 0, 2, 4)
	end

	if has_flag (east, OPENING_SOUTH) then
		fill_water (self, 11, 1, 0, 12, 2, 0)
	end

	if has_flag (east, OPENING_NORTH) then
		fill_water (self, 11, 1, 7, 12, 2, 7)
	end

	if has_flag (east, OPENING_EAST) then
		fill_water (self, 15, 1, 3, 15, 2, 4)
	end

	if has_flag (above, OPENING_SOUTH) then
		fill_water (self, 3, 5, 0, 4, 6, 0)
	end

	if has_flag (above, OPENING_NORTH) then
		fill_water (self, 3, 5, 7, 4, 6, 7)
	end

	if has_flag (above, OPENING_SOUTH) then
		fill_water (self, 0, 5, 3, 0, 6, 4)
	end

	if has_flag (east_above, OPENING_SOUTH) then
		fill_water (self, 11, 5, 0, 12, 6, 0)
	end

	if has_flag (east_above, OPENING_NORTH) then
		fill_water (self, 11, 5, 7, 12, 6, 7)
	end

	if has_flag (east_above, OPENING_EAST) then
		fill_water (self, 15, 5, 3, 15, 6, 4)
	end

	-- for x, y, z in ipos3 (unpack (self.bbox)) do
	-- 	set_block (x, y, z, cid_magenta_glass, 0)
	-- end
end

local function create_double_xy_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	alter_neighbor (data, EAST, FLAG_ALLOCATED)
	alter_neighbor (data, UP, FLAG_ALLOCATED)
	alter_neighbor (data.neighbors[EAST], UP, FLAG_ALLOCATED)

	local bbox = bbox_in_grid (dir, data, 2, 2, 1)
	return {
		place = double_xy_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Double YZ room.

local function double_yz_room (origin)
	return is_opening_free (origin, NORTH)
		and is_opening_free (origin, UP)
		and is_opening_free (origin.neighbors[NORTH], UP)
end

local function double_yz_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)
	local north = data.neighbors[NORTH]

	if gy > 0 then
		generate_floor (self, 0, 8, has_flag (north, OPENING_DOWN))
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	local above = data.neighbors[UP]
	local north_above = data.neighbors[UP]

	if not above.neighbors[UP] then
		fill_water_in_area (self, 1, 8, 1, 6, 8, 7,
				    cid_prismarine_bricks, 0)
	end

	if not north_above.neighbors[UP] then
		fill_water_in_area (self, 1, 8, 8, 6, 8, 14,
				    cid_prismarine_bricks, 0)
	end

	-- Generate walls.
	for y = 1, 7 do
		local cid = cid_prismarine_bricks
		if y == 2 or y == 6 then
			cid = cid_prismarine
		end
		fill_area (self, 0, y, 0, 0, y, 15, cid, 0)
		fill_area (self, 7, y, 0, 7, y, 15, cid, 0)
		fill_area (self, 1, y, 0, 6, y, 0, cid, 0)
		fill_area (self, 1, y, 15, 6, y, 15, cid, 0)
	end

	-- Generate lamp pillar.
	for y = 1, 7 do
		local cid = cid_dark_prismarine
		if y == 2 or y == 6 then
			cid = cid_sea_lantern
		end

		fill_area (self, 3, y, 7, 4, y, 8, cid, 0)
	end

	-- Generate openings and subsequently openings with flanges
	-- and overhangs.

	if has_flag (data, OPENING_SOUTH) then
		fill_water (self, 3, 1, 0, 4, 2, 0)
	end

	if has_flag (data, OPENING_EAST) then
		fill_water (self, 7, 1, 3, 7, 2, 4)
	end

	if has_flag (data, OPENING_WEST) then
		fill_water (self, 0, 1, 3, 0, 2, 4)
	end

	if has_flag (north, OPENING_NORTH) then
		fill_water (self, 3, 1, 15, 4, 2, 15)
	end

	if has_flag (north, OPENING_WEST) then
		fill_water (self, 0, 1, 11, 0, 2, 12)
	end

	if has_flag (north, OPENING_EAST) then
		fill_water (self, 7, 1, 11, 7, 2, 12)
	end

	if has_flag (above, OPENING_SOUTH) then
		fill_water (self, 3, 5, 0, 4, 6, 0)
	end

	if has_flag (above, OPENING_EAST) then
		fill_water (self, 7, 5, 3, 7, 6, 4)
		fill_area (self, 5, 4, 2, 6, 4, 5, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 2, 6, 3, 2, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 5, 6, 3, 5, cid_prismarine_bricks, 0)
	end

	if has_flag (above, OPENING_WEST) then
		fill_water (self, 0, 5, 3, 0, 6, 4)
		fill_area (self, 1, 4, 2, 2, 4, 5, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 2, 1, 3, 2, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 5, 1, 3, 5, cid_prismarine_bricks, 0)
	end

	if has_flag (north_above, OPENING_NORTH) then
		fill_water (self, 3, 5, 15, 4, 6, 15)
	end

	if has_flag (north_above, OPENING_WEST) then
		fill_water (self, 0, 5, 11, 0, 6, 12)
		fill_area (self, 1, 4, 10, 2, 4, 13, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 10, 1, 3, 10, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 13, 1, 3, 13, cid_prismarine_bricks, 0)
	end

	if has_flag (north_above, OPENING_EAST) then
		fill_water (self, 7, 5, 11, 7, 6, 12)
		fill_area (self, 5, 4, 10, 6, 4, 13, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 10, 6, 3, 10, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 13, 6, 3, 13, cid_prismarine_bricks, 0)
	end
end

local function create_double_yz_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	alter_neighbor (data, NORTH, FLAG_ALLOCATED)
	alter_neighbor (data, UP, FLAG_ALLOCATED)
	alter_neighbor (data.neighbors[NORTH], UP, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 1, 2, 2)
	return {
		place = double_yz_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Double Z room.

local function double_z_room (origin)
	return is_opening_free (origin, NORTH)
end

local function generate_rim (self, y, cid, param2)
	fill_area (self, 0, y, 0, 0, y, 15, cid, param2)
	fill_area (self, 7, y, 0, 7, y, 15, cid, param2)
	fill_area (self, 1, y, 0, 7, y, 0, cid, param2)
	fill_area (self, 1, y, 15, 6, y, 15, cid, param2)
end

local function double_z_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)
	local north = data.neighbors[NORTH]

	if gy > 0 then
		generate_floor (self, 0, 8, has_flag (north, OPENING_DOWN))
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	if not data.neighbors[UP] then
		fill_water_in_area (self, 1, 4, 1, 6, 4, 7, cid_prismarine, 0)
	end

	if not north.neighbors[UP] then
		fill_water_in_area (self, 1, 4, 8, 6, 4, 14, cid_prismarine, 0)
	end

	generate_rim (self, 3, cid_prismarine_bricks, 0)
	generate_rim (self, 2, cid_prismarine, 0)
	generate_rim (self, 1, cid_prismarine_bricks, 0)

	-- Corners and pillar.
	fill_area (self, 0, 1, 0, 0, 1, 15, cid_prismarine_bricks, 0)
	fill_area (self, 7, 1, 0, 7, 1, 15, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 0, 7, 1, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 15, 6, 1, 15, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 1, 1, 1, 2, cid_prismarine_bricks, 0)
	fill_area (self, 6, 1, 1, 6, 1, 2, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 1, 1, 3, 2, cid_prismarine_bricks, 0)
	fill_area (self, 6, 3, 1, 6, 3, 2, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 13, 1, 1, 14, cid_prismarine_bricks, 0)
	fill_area (self, 6, 1, 13, 6, 1, 14, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 13, 1, 3, 14, cid_prismarine_bricks, 0)
	fill_area (self, 6, 3, 13, 6, 3, 14, cid_prismarine_bricks, 0)
	fill_area (self, 2, 1, 6, 2, 3, 6, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 6, 5, 3, 6, cid_prismarine_bricks, 0)
	fill_area (self, 2, 1, 9, 2, 3, 9, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 9, 5, 3, 9, cid_prismarine_bricks, 0)
	fill_area (self, 3, 2, 6, 4, 2, 6, cid_prismarine_bricks, 0)
	fill_area (self, 3, 2, 9, 4, 2, 9, cid_prismarine_bricks, 0)
	fill_area (self, 2, 2, 7, 2, 2, 8, cid_prismarine_bricks, 0)
	fill_area (self, 5, 2, 7, 5, 2, 8, cid_prismarine_bricks, 0)

	-- Lanterns.
	set_block_reorientated (self, 2, 2, 5, cid_sea_lantern, 0)
	set_block_reorientated (self, 5, 2, 5, cid_sea_lantern, 0)
	set_block_reorientated (self, 2, 2, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, 5, 2, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, 2, 3, 5, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 5, 3, 5, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 2, 3, 10, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 5, 3, 10, cid_prismarine_bricks, 0)

	-- Openings.
	if has_flag (data, OPENING_SOUTH) then
		fill_water (self, 3, 1, 0, 4, 2, 0)
	end

	if has_flag (data, OPENING_EAST) then
		fill_water (self, 7, 1, 3, 7, 2, 4)
	end

	if has_flag (data, OPENING_WEST) then
		fill_water (self, 0, 1, 3, 0, 2, 4)
	end

	if has_flag (north, OPENING_NORTH) then
		fill_water (self, 3, 1, 15, 4, 2, 15)
	end

	if has_flag (north, OPENING_WEST) then
		fill_water (self, 0, 1, 11, 0, 2, 12)
	end

	if has_flag (north, OPENING_EAST) then
		fill_water (self, 7, 1, 11, 7, 2, 12)
	end
end

local function create_double_z_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	alter_neighbor (data, NORTH, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 1, 1, 2)
	return {
		place = double_z_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Double X room.

local function double_x_room (origin)
	return is_opening_free (origin, EAST)
end

local function double_x_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)
	local east = data.neighbors[EAST]

	if gy > 0 then
		generate_floor (self, 8, 0, has_flag (east, OPENING_DOWN))
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	if not data.neighbors[UP] then
		fill_water_in_area (self, 1, 4, 1, 7, 4, 6, cid_prismarine, 0)
	end

	if not east.neighbors[UP] then
		fill_water_in_area (self, 8, 4, 1, 14, 4, 6, cid_prismarine, 0)
	end

	fill_area (self, 0, 3, 0, 0, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 15, 3, 0, 15, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 0, 15, 3, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 7, 14, 3, 7, cid_prismarine_bricks, 0)

	fill_area (self, 0, 2, 0, 0, 2, 7, cid_dark_prismarine, 0)
	fill_area (self, 15, 2, 0, 15, 2, 7, cid_dark_prismarine, 0)
	fill_area (self, 1, 2, 0, 15, 2, 0, cid_dark_prismarine, 0)
	fill_area (self, 1, 2, 7, 14, 2, 7, cid_dark_prismarine, 0)

	fill_area (self, 0, 1, 0, 0, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 15, 1, 0, 15, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 0, 15, 1, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 7, 14, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 5, 1, 0, 10, 1, 4, cid_prismarine_bricks, 0)

	fill_area (self, 6, 2, 0, 9, 2, 3, cid_dark_prismarine, 0)

	fill_area (self, 5, 3, 0, 10, 3, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 6, 2, 3, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 2, 3, cid_sea_lantern, 0)

	-- Openings.
	if has_flag (data, OPENING_SOUTH) then
		fill_water (self, 3, 1, 0, 4, 2, 0)
	end

	if has_flag (data, OPENING_NORTH) then
		fill_water (self, 3, 1, 7, 4, 2, 7)
	end

	if has_flag (data, OPENING_WEST) then
		fill_water (self, 0, 1, 3, 0, 2, 4)
	end

	if has_flag (east, OPENING_SOUTH) then
		fill_water (self, 11, 1, 0, 12, 2, 0)
	end

	if has_flag (east, OPENING_NORTH) then
		fill_water (self, 11, 1, 7, 12, 2, 7)
	end

	if has_flag (east, OPENING_EAST) then
		fill_water (self, 15, 1, 3, 15, 2, 4)
	end
end

local function create_double_x_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	alter_neighbor (data, EAST, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 2, 1, 1)
	return {
		place = double_x_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Double Y room.

local function double_y_room (origin)
	return is_opening_free (origin, UP)
end

local function generate_walls (self, y, data)
	if has_flag (data, OPENING_SOUTH) then
		fill_area (self, 2, y, 0, 2, y + 2, 0, cid_prismarine_bricks, 0)
		fill_area (self, 5, y, 0, 5, y + 2, 0, cid_prismarine_bricks, 0)
		fill_area (self, 3, y + 2, 0, 4, y + 2, 0, cid_dark_prismarine, 0)
	else
		fill_area (self, 0, y, 0, 7, y + 2, 0, cid_prismarine_bricks, 0)
		fill_area (self, 0, y + 1, 0, 7, y + 1, 0, cid_dark_prismarine, 0)
	end

	if has_flag (data, OPENING_NORTH) then
		fill_area (self, 2, y, 7, 2, y + 2, 7, cid_prismarine_bricks, 0)
		fill_area (self, 5, y, 7, 5, y + 2, 7, cid_prismarine_bricks, 0)
		fill_area (self, 3, y + 2, 7, 4, y + 2, 7, cid_dark_prismarine, 0)
	else
		fill_area (self, 0, y, 7, 7, y + 2, 7, cid_prismarine_bricks, 0)
		fill_area (self, 0, y + 1, 7, 7, y + 1, 7, cid_dark_prismarine, 0)
	end

	if has_flag (data, OPENING_WEST) then
		fill_area (self, 0, y, 2, 0, y + 2, 2, cid_prismarine_bricks, 0)
		fill_area (self, 0, y, 5, 0, y + 2, 5, cid_prismarine_bricks, 0)
		fill_area (self, 0, y + 2, 3, 0, y + 2, 4, cid_dark_prismarine, 0)
	else
		fill_area (self, 0, y, 0, 0, y + 2, 7, cid_prismarine_bricks, 0)
		fill_area (self, 0, y + 1, 0, 0, y + 1, 7, cid_dark_prismarine, 0)
	end

	if has_flag (data, OPENING_EAST) then
		fill_area (self, 7, y, 2, 7, y + 2, 2, cid_prismarine_bricks, 0)
		fill_area (self, 7, y, 5, 7, y + 2, 5, cid_prismarine_bricks, 0)
		fill_area (self, 7, y + 2, 3, 7, y + 2, 4, cid_dark_prismarine, 0)
	else
		fill_area (self, 7, y, 0, 7, y + 2, 7, cid_prismarine_bricks, 0)
		fill_area (self, 7, y + 1, 0, 7, y + 1, 7, cid_dark_prismarine, 0)
	end
end

local function double_y_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Just one tall shaft with small outcroppings in the center.

	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)
	local up = data.neighbors[UP]

	if gy > 0 then
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	-- Ceiling.
	if not up.neighbors[UP] then
		fill_water_in_area (self, 1, 8, 1, 6, 8, 6, cid_prismarine_bricks, 0)
	end

	fill_area (self, 0, 4, 0, 0, 4, 7, cid_prismarine_bricks, 0)
	fill_area (self, 7, 4, 0, 7, 4, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 4, 0, 6, 4, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 4, 7, 6, 4, 7, cid_prismarine_bricks, 0)
	fill_area (self, 2, 4, 1, 2, 4, 2, cid_prismarine_bricks, 0)
	fill_area (self, 1, 4, 2, 1, 4, 2, cid_prismarine_bricks, 0)
	fill_area (self, 5, 4, 1, 5, 4, 2, cid_prismarine_bricks, 0)
	fill_area (self, 6, 4, 2, 6, 4, 2, cid_prismarine_bricks, 0)
	fill_area (self, 2, 4, 5, 2, 4, 6, cid_prismarine_bricks, 0)
	fill_area (self, 1, 4, 5, 1, 4, 5, cid_prismarine_bricks, 0)
	fill_area (self, 5, 4, 5, 5, 4, 6, cid_prismarine_bricks, 0)
	fill_area (self, 6, 4, 5, 6, 4, 5, cid_prismarine_bricks, 0)

	-- Generate walls or openings.
	generate_walls (self, 1, data)
	generate_walls (self, 5, up)
end

local function create_double_y_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	alter_neighbor (data, UP, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 1, 2, 1)
	return {
		place = double_y_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Simple room top.

local OPENINGS_EXCEPT_BOTTOM = bor (OPENING_UP,
				    OPENING_EAST,
				    OPENING_SOUTH,
				    OPENING_WEST,
				    OPENING_NORTH)

local function simple_room_top (origin)
	return band (origin.flags, OPENINGS_EXCEPT_BOTTOM) == 0
end

local cid_sponge_wet = getcid ("mcl_sponges:sponge_wet")

local function simple_room_top_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)

	if gy > 0 then
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	if not data.neighbors[UP] then
		fill_water_in_area (self, 1, 4, 1, 6, 4, 6, cid_prismarine, 0)
	end

	for x, _, z in ipos4 (1, 0, 1, 6, 0, 6) do
		if rng:next_within (3) ~= 0 then
			local height

			if rng:next_within (4) == 0 then
				height = 3
			else
				height = 2
			end

			fill_area (self, x, height, z, x, 3, z, cid_sponge_wet, 0)
		end
	end

	-- Walls.
	fill_area (self, 0, 1, 0, 0, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 7, 1, 0, 7, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 0, 6, 1, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 1, 7, 6, 1, 7, cid_prismarine_bricks, 0)

	fill_area (self, 0, 2, 0, 0, 2, 7, cid_dark_prismarine, 0)
	fill_area (self, 7, 2, 0, 7, 2, 7, cid_dark_prismarine, 0)
	fill_area (self, 1, 2, 0, 6, 2, 0, cid_dark_prismarine, 0)
	fill_area (self, 1, 2, 7, 6, 2, 7, cid_dark_prismarine, 0)

	fill_area (self, 0, 3, 0, 0, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 7, 3, 0, 7, 3, 7, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 0, 6, 3, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 3, 7, 6, 3, 7, cid_prismarine_bricks, 0)

	fill_area (self, 0, 1, 3, 0, 2, 4, cid_dark_prismarine, 0)
	fill_area (self, 7, 1, 3, 7, 2, 4, cid_dark_prismarine, 0)
	fill_area (self, 3, 1, 0, 4, 2, 0, cid_dark_prismarine, 0)
	fill_area (self, 3, 1, 7, 4, 2, 7, cid_dark_prismarine, 0)

	-- Openings.

	if has_flag (data, OPENING_SOUTH) then
		fill_water (self, 3, 1, 0, 4, 2, 0)
	end
end

local function create_simple_room_top (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 1, 1, 1)
	return {
		place = simple_room_top_place,
		dir = dir,
		bbox = bbox,
		data = data,
	}
end

-- Simple room.

local function simple_room (origin)
	return true
end

local factory
	= mcl_levelgen.overworld_preset.factory ("mcl_levelgen:monument_pillar")
local pillar_rng = factory:fork_positional ():create_reseedable ()

local function num_openings (data)
	local flags = data.flags
	local count = 0

	for i = 0, 5 do
		count = count + band (rshift (flags, i + OPENING_SHIFT), 1)
	end
	return count
end

local function simple_room_place (self, level, terrain, rng, x1, z1, x2, z2)
	local data = self.data
	local _, gy, _ = decode_ordinary_index (data.index)

	if gy > 0 then
		generate_floor (self, 0, 0, has_flag (data, OPENING_DOWN))
	end

	if not data.neighbors[UP] then
		fill_water_in_area (self, 1, 4, 1, 6, 4, 6, cid_prismarine, 0)
	end

	local bbox = self.bbox
	pillar_rng:reseed_positional (bbox[1], bbox[2], bbox[3])
	local design = self.design
	local pillar = design ~= 0 -- Not plus shaped.
		and not has_flag (data, OPENING_UP)
		and not has_flag (data, OPENING_DOWN)
		and pillar_rng:next_boolean ()
		and num_openings (data) > 1

	if design == 0 then
		-- Plus-shaped room.
		fill_area (self, 0, 1, 0, 2, 1, 2, cid_prismarine_bricks, 0)
		fill_area (self, 0, 3, 0, 2, 3, 2, cid_prismarine_bricks, 0)
		fill_area (self, 0, 2, 0, 0, 2, 2, cid_dark_prismarine, 0)
		fill_area (self, 1, 2, 0, 2, 2, 0, cid_dark_prismarine, 0)
		set_block_reorientated (self, 1, 2, 1, cid_sea_lantern, 0)
		fill_area (self, 5, 1, 0, 7, 1, 2, cid_prismarine_bricks, 0)
		fill_area (self, 5, 3, 0, 7, 3, 2, cid_prismarine_bricks, 0)
		fill_area (self, 7, 2, 0, 7, 2, 2, cid_dark_prismarine, 0)
		fill_area (self, 5, 2, 0, 6, 2, 0, cid_dark_prismarine, 0)
		set_block_reorientated (self, 6, 2, 1, cid_sea_lantern, 0)
		fill_area (self, 0, 1, 5, 2, 1, 7, cid_prismarine_bricks, 0)
		fill_area (self, 0, 3, 5, 2, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 0, 2, 5, 0, 2, 7, cid_dark_prismarine, 0)
		fill_area (self, 1, 2, 7, 2, 2, 7, cid_dark_prismarine, 0)
		set_block_reorientated (self, 1, 2, 6, cid_sea_lantern, 0)
		fill_area (self, 5, 1, 5, 7, 1, 7, cid_prismarine_bricks, 0)
		fill_area (self, 5, 3, 5, 7, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 7, 2, 5, 7, 2, 7, cid_dark_prismarine, 0)
		fill_area (self, 5, 2, 7, 6, 2, 7, cid_dark_prismarine, 0)
		set_block_reorientated (self, 6, 2, 6, cid_sea_lantern, 0)

		if has_flag (data, OPENING_SOUTH) then
			fill_area (self, 3, 3, 0, 4, 3, 0, cid_prismarine_bricks, 0)
		else
			fill_area (self, 3, 3, 0, 4, 3, 1, cid_prismarine_bricks, 0)
			fill_area (self, 3, 2, 0, 4, 2, 0, cid_dark_prismarine, 0)
			fill_area (self, 3, 1, 0, 4, 1, 1, cid_prismarine_bricks, 0)
		end

		if has_flag (data, OPENING_NORTH) then
			fill_area (self, 3, 3, 7, 4, 3, 7, cid_prismarine_bricks, 0)
		else
			fill_area (self, 3, 3, 6, 4, 3, 7, cid_prismarine_bricks, 0)
			fill_area (self, 3, 2, 7, 4, 2, 7, cid_prismarine_bricks, 0)
			fill_area (self, 3, 1, 6, 4, 1, 7, cid_prismarine_bricks, 0)
		end

		if has_flag (data, OPENING_WEST) then
			fill_area (self, 0, 3, 3, 0, 3, 4, cid_prismarine_bricks, 0)
		else
			fill_area (self, 0, 3, 3, 1, 3, 4, cid_prismarine_bricks, 0)
			fill_area (self, 0, 2, 3, 0, 2, 4, cid_prismarine_bricks, 0)
			fill_area (self, 0, 1, 3, 1, 1, 4, cid_prismarine_bricks, 0)
		end

		if has_flag (data, OPENING_EAST) then
			fill_area (self, 7, 3, 3, 7, 3, 4, cid_prismarine_bricks, 0)
		else
			fill_area (self, 6, 3, 3, 7, 3, 4, cid_prismarine_bricks, 0)
			fill_area (self, 7, 2, 3, 7, 2, 4, cid_prismarine_bricks, 0)
			fill_area (self, 6, 1, 3, 7, 1, 4, cid_prismarine_bricks, 0)
		end
	elseif design == 1 then
		-- 4-pillar room.
		fill_area (self, 2, 1, 2, 2, 3, 2, cid_prismarine_bricks, 0)
		fill_area (self, 2, 1, 5, 2, 3, 5, cid_prismarine_bricks, 0)
		fill_area (self, 5, 1, 5, 5, 3, 5, cid_prismarine_bricks, 0)
		fill_area (self, 5, 1, 2, 5, 3, 2, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 2, 2, 2, cid_sea_lantern, 0)
		set_block_reorientated (self, 2, 2, 5, cid_sea_lantern, 0)
		set_block_reorientated (self, 5, 2, 5, cid_sea_lantern, 0)
		set_block_reorientated (self, 5, 2, 2, cid_sea_lantern, 0)
		fill_area (self, 0, 1, 0, 1, 3, 0, cid_prismarine_bricks, 0)
		fill_area (self, 0, 1, 1, 0, 3, 1, cid_prismarine_bricks, 0)
		fill_area (self, 0, 1, 7, 1, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 0, 1, 6, 0, 3, 6, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 7, 7, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 7, 1, 6, 7, 3, 6, cid_prismarine_bricks, 0)
		fill_area (self, 6, 1, 0, 7, 3, 0, cid_prismarine_bricks, 0)
		fill_area (self, 7, 1, 1, 7, 3, 1, cid_prismarine_bricks, 0)
		set_block_reorientated (self, 1, 2, 0, cid_prismarine, 0)
		set_block_reorientated (self, 0, 2, 1, cid_prismarine, 0)
		set_block_reorientated (self, 1, 2, 7, cid_prismarine, 0)
		set_block_reorientated (self, 0, 2, 6, cid_prismarine, 0)
		set_block_reorientated (self, 6, 2, 7, cid_prismarine, 0)
		set_block_reorientated (self, 7, 2, 6, cid_prismarine, 0)
		set_block_reorientated (self, 6, 2, 0, cid_prismarine, 0)
		set_block_reorientated (self, 7, 2, 1, cid_prismarine, 0)

		if not has_flag (data, OPENING_SOUTH) then
			fill_area (self, 1, 3, 0, 6, 3, 0, cid_prismarine_bricks, 0)
			fill_area (self, 1, 2, 0, 6, 2, 0, cid_prismarine_bricks, 0)
			fill_area (self, 1, 1, 0, 6, 1, 0, cid_prismarine_bricks, 0)
		end

		if not has_flag (data, OPENING_NORTH) then
			fill_area (self, 1, 3, 7, 6, 3, 7, cid_prismarine_bricks, 0)
			fill_area (self, 1, 2, 7, 6, 2, 7, cid_prismarine_bricks, 0)
			fill_area (self, 1, 1, 7, 6, 1, 7, cid_prismarine_bricks, 0)
		end

		if not has_flag (data, OPENING_WEST) then
			fill_area (self, 0, 3, 1, 0, 3, 6, cid_prismarine_bricks, 0)
			fill_area (self, 0, 2, 1, 0, 2, 6, cid_prismarine_bricks, 0)
			fill_area (self, 0, 1, 1, 0, 1, 6, cid_prismarine_bricks, 0)
		end

		if not has_flag (data, OPENING_EAST) then
			fill_area (self, 7, 3, 1, 7, 3, 6, cid_prismarine_bricks, 0)
			fill_area (self, 7, 2, 1, 7, 2, 6, cid_prismarine_bricks, 0)
			fill_area (self, 7, 1, 1, 7, 1, 6, cid_prismarine_bricks, 0)
		end
	else
		-- Dark prismarine small room.
		fill_area (self, 0, 1, 0, 0, 1, 7, cid_prismarine_bricks, 0)
		fill_area (self, 7, 1, 0, 7, 1, 7, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 0, 6, 1, 0, cid_prismarine_bricks, 0)
		fill_area (self, 1, 1, 7, 6, 1, 7, cid_prismarine_bricks, 0)

		fill_area (self, 0, 2, 0, 0, 2, 7, cid_dark_prismarine, 0)
		fill_area (self, 7, 2, 0, 7, 2, 7, cid_dark_prismarine, 0)
		fill_area (self, 1, 2, 0, 6, 2, 0, cid_dark_prismarine, 0)
		fill_area (self, 1, 2, 7, 6, 2, 7, cid_dark_prismarine, 0)

		fill_area (self, 0, 3, 0, 0, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 7, 3, 0, 7, 3, 7, cid_prismarine_bricks, 0)
		fill_area (self, 1, 3, 0, 6, 3, 0, cid_prismarine_bricks, 0)
		fill_area (self, 1, 3, 7, 6, 3, 7, cid_prismarine_bricks, 0)

		fill_area (self, 0, 1, 3, 0, 2, 4, cid_dark_prismarine, 0)
		fill_area (self, 7, 1, 3, 7, 2, 4, cid_dark_prismarine, 0)
		fill_area (self, 3, 1, 0, 4, 2, 0, cid_dark_prismarine, 0)
		fill_area (self, 3, 1, 7, 4, 2, 7, cid_dark_prismarine, 0)

		if has_flag (data, OPENING_SOUTH) then
			fill_water (self, 3, 1, 0, 4, 2, 0)
		end

		if has_flag (data, OPENING_NORTH) then
			fill_water (self, 3, 1, 7, 4, 2, 7)
		end

		if has_flag (data, OPENING_WEST) then
			fill_water (self, 0, 1, 3, 0, 2, 4)
		end

		if has_flag (data, OPENING_EAST) then
			fill_water (self, 7, 1, 3, 7, 2, 4)
		end
	end

	if pillar then
		fill_area (self, 3, 1, 3, 4, 1, 4, cid_prismarine_bricks, 0)
		fill_area (self, 3, 2, 3, 4, 2, 4, cid_prismarine, 0)
		fill_area (self, 3, 3, 3, 4, 3, 4, cid_prismarine_bricks, 0)
	end
end

local function create_simple_room (rng, dir, data)
	alter_grid_data (data, FLAG_ALLOCATED)
	local bbox = bbox_in_grid (dir, data, 1, 1, 1)
	return {
		place = simple_room_place,
		dir = dir,
		bbox = bbox,
		data = data,
		design = rng:next_within (3),
	}
end

room_types = {
	{ double_xy_room, create_double_xy_room, },
	{ double_yz_room, create_double_yz_room, },
	{ double_z_room, create_double_z_room, },
	{ double_x_room, create_double_x_room, },
	{ double_y_room, create_double_y_room, },
	{ simple_room_top, create_simple_room_top, },
	{ simple_room, create_simple_room, },
}

local notify_generated = mcl_levelgen.notify_generated

local function spawn_elder_guardian (self, x, y, z)
	local x, y, z = reorientate_coords (self, x, y, z)
	notify_generated ("mcl_levelgen:monument_elder_guardian", x, y, z, {
		x = x,
		y = y,
		z = z,
	})
end

-- Wing room.

local function generate_lamp_slice (self, dx)
	fill_area (self, dx, 0, 10, dx, 6, 10, cid_prismarine_bricks, 0)
	fill_area (self, dx, 0, 12, dx, 6, 12, cid_prismarine_bricks, 0)
	set_block_reorientated (self, dx, 0, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, dx, 0, 12, cid_sea_lantern, 0)
	set_block_reorientated (self, dx, 4, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, dx, 4, 12, cid_sea_lantern, 0)
end

local function wing_room_1_place (self, level, terrain, rng, x1, z1, x2, z2)
	fill_area (self, 9, 3, 18, 13, 3, 20, cid_prismarine_bricks, 0)
	fill_area (self, 9, 0, 18, 9, 2, 18, cid_prismarine_bricks, 0)
	fill_area (self, 13, 0, 18, 13, 2, 18, cid_prismarine_bricks, 0)

	-- Arch contacting rear.
	set_block_reorientated (self, 9, 6, 20, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 9, 5, 20, cid_sea_lantern, 0)
	set_block_reorientated (self, 9, 4, 20, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 13, 6, 20, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 13, 5, 20, cid_sea_lantern, 0)
	set_block_reorientated (self, 13, 4, 20, cid_prismarine_bricks, 0)

	fill_area (self, 7, 3, 7, 15, 3, 14, cid_prismarine_bricks, 0)

	-- Lamp pillar.
	generate_lamp_slice (self, 10)
	generate_lamp_slice (self, 12)

	-- Upper platform & supports.
	fill_area (self, 8, 0, 7, 8, 2, 7, cid_prismarine_bricks, 0)
	fill_area (self, 8, 0, 14, 8, 2, 14, cid_prismarine_bricks, 0)
	fill_area (self, 14, 0, 7, 14, 2, 7, cid_prismarine_bricks, 0)
	fill_area (self, 14, 0, 14, 14, 2, 14, cid_prismarine_bricks, 0)
	fill_area (self, 8, 3, 8, 8, 3, 13, cid_dark_prismarine, 0)
	fill_area (self, 14, 3, 8, 14, 3, 13, cid_dark_prismarine, 0)
	spawn_elder_guardian (self, 11, 5, 13)
end

local function wing_room_0_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Exit stairs.
	for i = 0, 3 do
		fill_area (self, 10 - i, 3 - i, 20 - i, 12 + i, 3 - i, 20,
			   cid_prismarine_bricks, 0)
	end

	-- Antechamber.
	fill_area (self, 7, 0, 6, 15, 0, 16, cid_prismarine_bricks, 0)
	fill_area (self, 6, 0, 6, 6, 3, 20, cid_prismarine_bricks, 0)
	fill_area (self, 16, 0, 6, 16, 3, 20, cid_prismarine_bricks, 0)
	fill_area (self, 7, 1, 7, 7, 1, 20, cid_prismarine_bricks, 0)
	fill_area (self, 15, 1, 7, 15, 1, 20, cid_prismarine_bricks, 0)
	fill_area (self, 7, 1, 6, 9, 3, 6, cid_prismarine_bricks, 0)
	fill_area (self, 13, 1, 6, 15, 3, 6, cid_prismarine_bricks, 0)
	fill_area (self, 8, 1, 7, 9, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 13, 1, 7, 14, 1, 7, cid_prismarine_bricks, 0)
	fill_area (self, 9, 0, 5, 13, 0, 5, cid_prismarine_bricks, 0)
	fill_area (self, 10, 0, 7, 12, 0, 7, cid_prismarine_bricks, 0)
	fill_area (self, 8, 0, 10, 8, 0, 12, cid_prismarine_bricks, 0)
	fill_area (self, 14, 0, 10, 14, 0, 12, cid_prismarine_bricks, 0)

	-- Wall lamps.
	for z = 18, 7, -3 do
		set_block_reorientated (self, 6, 3, z, cid_sea_lantern, 0)
		set_block_reorientated (self, 16, 3, z, cid_sea_lantern, 0)
	end

	-- Lamp pillars.
	set_block_reorientated (self, 10, 0, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, 12, 0, 10, cid_sea_lantern, 0)
	set_block_reorientated (self, 10, 0, 12, cid_sea_lantern, 0)
	set_block_reorientated (self, 12, 0, 12, cid_sea_lantern, 0)
	set_block_reorientated (self, 8, 3, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 14, 3, 6, cid_sea_lantern, 0)
	set_block_reorientated (self, 4, 2, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 4, 1, 4, cid_sea_lantern, 0)
	set_block_reorientated (self, 4, 0, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 18, 2, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 18, 1, 4, cid_sea_lantern, 0)
	set_block_reorientated (self, 18, 0, 4, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 4, 2, 18, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 4, 1, 18, cid_sea_lantern, 0)
	set_block_reorientated (self, 4, 0, 18, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 18, 2, 18, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 18, 1, 18, cid_sea_lantern, 0)
	set_block_reorientated (self, 18, 0, 18, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 9, 7, 20, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 13, 7, 20, cid_prismarine_bricks, 0)

	-- Rear wall supports & Elder Guardian.
	fill_area (self, 6, 0, 21, 7, 4, 21, cid_prismarine_bricks, 0)
	fill_area (self, 15, 0, 21, 16, 4, 21, cid_prismarine_bricks, 0)
	spawn_elder_guardian (self, 11, 2, 16)
end

function create_wing_room (dir, bbox, design_selector)
	local design = band (design_selector, 1)

	if design == 1 then
		return {
			bbox = bbox,
			dir = dir,
			place = wing_room_1_place,
		}
	else
		return {
			bbox = bbox,
			dir = dir,
			place = wing_room_0_place,
		}
	end
end

-- Penthouse room.

local function penthouse_place (self, level, terrain, rng, x1, z1, x2, z2)
	-- Penthouse floor.
	fill_area (self, 2, -1, 2, 11, -1, 11, cid_prismarine_bricks, 0)
	fill_area (self, 0, -1, 0, 1, -1, 11, cid_prismarine, 0)
	fill_area (self, 12, -1, 0, 13, -1, 11, cid_prismarine, 0)
	fill_area (self, 2, -1, 0, 11, -1, 1, cid_prismarine, 0)
	fill_area (self, 2, -1, 12, 11, -1, 13, cid_prismarine, 0)
	fill_area (self, 0, 0, 0, 0, 0, 13, cid_prismarine_bricks, 0)
	fill_area (self, 13, 0, 0, 13, 0, 13, cid_prismarine_bricks, 0)
	fill_area (self, 1, 0, 0, 12, 0, 0, cid_prismarine_bricks, 0)
	fill_area (self, 1, 0, 13, 12, 0, 13, cid_prismarine_bricks, 0)

	-- Wall lamps.
	for i = 2, 11, 3 do
		set_block_reorientated (self, 0, 0, i, cid_sea_lantern, 0)
		set_block_reorientated (self, 13, 0, i, cid_sea_lantern, 0)
		set_block_reorientated (self, i, 0, 0, cid_sea_lantern, 0)
	end

	-- Corners of floor and pillar foundations.
	fill_area (self, 2, 0, 3, 4, 0, 9, cid_prismarine_bricks, 0)
	fill_area (self, 9, 0, 3, 11, 0, 9, cid_prismarine_bricks, 0)
	fill_area (self, 4, 0, 9, 9, 0, 11, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 5, 0, 8, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 8, 0, 8, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 10, 0, 10, cid_prismarine_bricks, 0)
	set_block_reorientated (self, 3, 0, 10, cid_prismarine_bricks, 0)
	fill_area (self, 3, 0, 3, 3, 0, 7, cid_dark_prismarine, 0)
	fill_area (self, 10, 0, 3, 10, 0, 7, cid_dark_prismarine, 0)
	fill_area (self, 6, 0, 10, 7, 0, 10, cid_dark_prismarine, 0)

	-- Pillars & Elder Guardian.
	for z = 2, 8, 3 do
		fill_area (self, 3, 0, z, 3, 2, z, cid_prismarine_bricks, 0)
		fill_area (self, 10, 0, z, 10, 2, z, cid_prismarine_bricks, 0)
	end
	fill_area (self, 5, 0, 10, 5, 2, 10, cid_prismarine_bricks, 0)
	fill_area (self, 8, 0, 10, 8, 2, 10, cid_prismarine_bricks, 0)
	fill_area (self, 6, -1, 7, 7, -1, 8, cid_dark_prismarine, 0)
	fill_water (self, 6, -1, 3, 7, -1, 4)
	spawn_elder_guardian (self, 6, 1, 6)
end

function create_penthouse_room (dir, bbox)
	return {
		bbox = bbox,
		dir = dir,
		place = penthouse_place,
	}
end

------------------------------------------------------------------------
-- Ocean Monument placement.
------------------------------------------------------------------------

local get_biomes_chebyshev = mcl_levelgen.get_biomes_chebyshev
local registered_biomes = mcl_levelgen.registered_biomes
local structure_biome_test = mcl_levelgen.structure_biome_test
local create_structure_start = mcl_levelgen.create_structure_start

local function ocean_monument_create_start (self, level, terrain, rng, cx, cz)
	local x = cx * 16 + 9
	local z = cz * 16 + 9

	-- Find a suitable generation point and guarantee that all
	-- chunks in a 29 block radius round the center are within
	-- Deep Ocean biomes.
	local preset = level.preset
	local biomes, _ = get_biomes_chebyshev (preset, x, preset.sea_level, z, 29)
	for _, biome in ipairs (biomes) do
		local def = registered_biomes[biome]
		if not def.groups.required_ocean_monument_surrounding then
			return nil
		end
	end

	local x = x - 1
	local z = z - 1
	local y = terrain:get_one_height (x, z, nil) - 1

	if not structure_biome_test (level, self, x, y, z) then
		return nil
	end

	local pieces = {
		create_monument_base (rng, cx * 16 - 29, cz * 16 - 29),
	}
	return create_structure_start (self, pieces)
end

------------------------------------------------------------------------
-- Ocean Monument registration.
------------------------------------------------------------------------

mcl_levelgen.modify_biome_groups ({"#is_deep_ocean",}, {
	has_ocean_monument = true,
})

mcl_levelgen.modify_biome_groups ({"#is_ocean", "#is_river",}, {
	required_ocean_monument_surrounding = true,
})

mcl_levelgen.register_structure ("mcl_levelgen:ocean_monument", {
	biomes = mcl_levelgen.build_biome_list ({"#has_ocean_monument",}),
	step = mcl_levelgen.SURFACE_STRUCTURES,
	create_start = ocean_monument_create_start,
	terrain_adaptation = "none",
})

mcl_levelgen.register_structure_set ("mcl_levelgen:ocean_monuments", {
	structures = {
		"mcl_levelgen:ocean_monument",
	},
	placement = R (1.0, "default", 32, 5, 10387313, "triangular", nil, nil),
})
