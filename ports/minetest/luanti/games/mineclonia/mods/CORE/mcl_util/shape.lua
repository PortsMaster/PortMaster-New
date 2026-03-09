--- NOTE: if performance should become a consideration it may be
--- worthwhile to create an FFI wrapper around the C reference
--- implementation, which is included for reference, as you would
--- expect, in tools/shapelib/shape.c.

if core then
	if not core.global_exists ("mcl_util") then
		mcl_util = {}
	end
elseif not mcl_util then
	mcl_util = {}
end

-- Region data structure.
--
-- A set of AABBs is decomposed into a sorted set of edges along each
-- axis, and each vertex occupied by an AABB's min_pos or between the
-- same and its max_pos is marked as such.

------------------------------------------------------------------------
-- Shape initialization.
------------------------------------------------------------------------

local region_class = {}
region_class.__index = region_class

local MAX_EDGES_PER_AXIS = 1023 -- 2 ^ 10 - 1.
local WORD_BITS = 32

local function push (list, seen, value)
	if not seen[value + 0.001] then -- Force the creation of a
					-- sparse table.
		seen[value + 0.001] = true
		table.insert (list, value)
	end
end

local floor = math.floor
local mathmax = math.max
local lshift = bit.lshift

local function next_power_of_two (n)
	if n <= MAX_EDGES_PER_AXIS then
		for i = 1, 31 do
			if lshift (1, i) >= n then
				return i
			end
		end
	end
	return -1
end

local function bitset_size (disp, x, y, z)
	return floor ((lshift (x, disp + disp)
		       + lshift (y, disp) + z
		       + WORD_BITS - 1) / WORD_BITS)
end

local function region_displacement_xyz (x, y, z)
	return next_power_of_two (mathmax (x, y, z))
end

-- local function region_displacement (rgn)
-- 	return region_displacement_xyz (rgn.x_size, rgn.y_size, rgn.z_size)
-- end

local function bisect (edges, nmemb, value)
	local low, high, mid = 0, nmemb - 1
	if nmemb > 0 then
		while low ~= high do
			mid = floor ((low + high) / 2)
			if edges[mid + 1] < value then
				low = mid + 1
			else
				high = mid
			end
		end

		if edges[low + 1] > value then
			return low > 0 and low or nil
		end

		return low + 1
	end
	return nil
end

local band = bit.band
local lshift = bit.lshift
local bor = bit.bor

local function mark_occupied (region, disp, x, y, z)
	local index = lshift (x, disp + disp)
		+ lshift (y, disp) + z
	local idx = floor ((index / WORD_BITS)) + 1
	local off = band (index, WORD_BITS - 1)
	local mask = lshift (1, off)
	region.solids[idx] = bor (region.solids[idx], mask)
end

local function is_occupied_p (region, disp, x, y, z)
	local index = lshift (x, disp + disp)
		+ lshift (y, disp) + z
	local idx = floor ((index / WORD_BITS)) + 1
	local off = band (index, WORD_BITS - 1)
	local mask = lshift (1, off)
	return band (region.solids[idx], mask) ~= 0
end

function mcl_util.decompose_AABBs (aabbs)
	local x_edges, y_edges, z_edges = {}, {}, {}
	local x_seen, y_seen, z_seen = {}, {}, {}

	for _, aabb in ipairs (aabbs) do
		local x1, y1, z1, x2, y2, z2 = unpack (aabb)
		push (x_edges, x_seen, x1)
		push (x_edges, x_seen, x2)
		push (y_edges, y_seen, y1)
		push (y_edges, y_seen, y2)
		push (z_edges, z_seen, z1)
		push (z_edges, z_seen, z2)
	end

	table.sort (x_edges)
	table.sort (y_edges)
	table.sort (z_edges)

	if #x_edges > MAX_EDGES_PER_AXIS
		or #y_edges > MAX_EDGES_PER_AXIS
		or #z_edges > MAX_EDGES_PER_AXIS then
		return nil
	end

	local b_disp = region_displacement_xyz (#x_edges, #y_edges, #z_edges)
	local b_size = bitset_size (b_disp, #x_edges, #y_edges, #z_edges)
	local region = {
		x_edges = x_edges,
		y_edges = y_edges,
		z_edges = z_edges,
		x_size = #x_edges,
		y_size = #y_edges,
		z_size = #z_edges,
		b_size = b_size,
		b_disp = b_disp,
		solids = {},
	}
	setmetatable (region, region_class)
	do
		local solids = region.solids
		for i = 1, b_size do
			solids[i] = 0
		end
	end

	-- Mark AABBs.
	for _, aabb in ipairs (aabbs) do
		local x1 = bisect (x_edges, #x_edges, aabb[1])
		local y1 = bisect (y_edges, #y_edges, aabb[2])
		local z1 = bisect (z_edges, #z_edges, aabb[3])
		local x2 = bisect (x_edges, #x_edges, aabb[4])
		local y2 = bisect (y_edges, #y_edges, aabb[5])
		local z2 = bisect (z_edges, #z_edges, aabb[6])

		assert (x_edges[x1] == aabb[1])
		assert (y_edges[y1] == aabb[2])
		assert (z_edges[z1] == aabb[3])
		assert (x_edges[x2] == aabb[4])
		assert (y_edges[y2] == aabb[5])
		assert (z_edges[z2] == aabb[6])

		for x = x1, x2 - 1 do
			for y = y1, y2 - 1 do
				for z = z1, z2 - 1 do
					mark_occupied (region, b_disp, x - 1,
						       y - 1, z - 1)
				end
			end
		end
	end

	return region
end

------------------------------------------------------------------------
-- Shape operations.
------------------------------------------------------------------------

local min = math.min

local function merge_edge_list (l, r)
	local output = {}
	local i, il, ir = 1, 1, 1
	local l_max = #l + 1
	local r_max = #r + 1
	local next_val = min (l[1], r[1])

	while il ~= l_max or ir ~= r_max do
		local l_old, r_old = il, ir

		output[i] = next_val
		i = i + 1

		if il ~= l_max and (r_old == r_max or l[l_old] <= r[r_old]) then
			il = il + 1
		end
		if ir ~= r_max and (l_old == l_max or r[r_old] <= l[l_old]) then
			ir = ir + 1
		end
		if il ~= l_max and ir ~= r_max then
			next_val = min (l[il], r[ir])
		elseif il ~= l_max then
			next_val = l[il]
		elseif ir ~= r_max then
			next_val = r[ir]
		end
	end

	return output
end

local function get_dominating_values (il, ir, l, r, l_max, r_max)
	local ldom, rdom

	if il == l_max then
		ldom = nil
		rdom = ir ~= r_max and ir or nil
	elseif ir == r_max then
		ldom = il ~= l_max and il or nil
		rdom = nil
	elseif l[il] < r[ir] then
		ldom = il
		rdom = ir ~= 1 and ir - 1 or nil
	elseif r[ir] < l[il] then
		ldom = il ~= 1 and il - 1 or nil
		rdom = ir
	else
		ldom = il
		rdom = ir
	end

	return ldom, rdom
end

mcl_util.OP_OR = function (l, r)
	return l or r
end

mcl_util.OP_AND = function (l, r)
	return l and r
end

mcl_util.OP_SUB = function (l, r)
	return l and not r
end

mcl_util.OP_NEQ = function (l, r)
	return l ~= r
end

mcl_util.OP_BNA = function (l, r)
	return r and not l
end

local OP_OR = mcl_util.OP_OR
local OP_AND = mcl_util.OP_AND
local OP_SUB = mcl_util.OP_SUB
local OP_NEQ = mcl_util.OP_NEQ
local OP_BNA = mcl_util.OP_BNA

local empty_region = {
	x_size = 0,
	y_size = 0,
	z_size = 0,
	b_size = 0,
	x_edges = {},
	y_edges = {},
	z_edges = {},
	solids = {},
}

setmetatable (empty_region, region_class)
mcl_util.empty_region = empty_region

local function region_op (l, r, op)
	-- Punt if empty.
	if l.x_size == 0 or l.y_size == 0 or l.z_size == 0 then
		if op == OP_OR or op == OP_NEQ then
			return r
		end
		return empty_region
	elseif r.x_size == 0 or r.y_size == 0 or r.z_size == 0 then
		if op == OP_OR or op == OP_NEQ or op == OP_SUB then
			return l
		end
		return empty_region
	end

	local x_edges = merge_edge_list (l.x_edges, r.x_edges)
	local y_edges = merge_edge_list (l.y_edges, r.y_edges)
	local z_edges = merge_edge_list (l.z_edges, r.z_edges)
	local x_size, y_size, z_size = #x_edges, #y_edges, #z_edges

	if x_size > MAX_EDGES_PER_AXIS
		or y_size > MAX_EDGES_PER_AXIS
		or z_size > MAX_EDGES_PER_AXIS then
		return nil
	end

	-- Allocate the region.
	local b_disp = region_displacement_xyz (x_size, y_size, z_size)
	local b_size = bitset_size (b_disp, x_size, y_size, z_size)

	local region = {
		x_edges = x_edges,
		y_edges = y_edges,
		z_edges = z_edges,
		x_size = x_size,
		y_size = y_size,
		z_size = z_size,
		b_size = b_size,
		b_disp = b_disp,
		solids = {},
	}
	setmetatable (region, region_class)
	do
		local solids = region.solids
		for i = 1, region.b_size do
			solids[i] = 0
		end
	end

	local lx_max = l.x_size + 1
	local rx_max = r.x_size + 1
	local l_b_disp = l.b_disp
	local r_b_disp = r.b_disp
	local lx, rx = 1, 1
	local x = 0

	while lx ~= lx_max or rx ~= rx_max do
		local lx_old, rx_old = lx, rx
		local ly_max = l.y_size + 1
		local ry_max = r.y_size + 1
		local ly, ry = 1, 1
		local lx_dom, rx_dom
			= get_dominating_values (lx, rx, l.x_edges, r.x_edges,
						 lx_max, rx_max)
		local y = 0

		while ly ~= ly_max or ry ~= ry_max do
			local ly_old, ry_old = ly, ry
			local lz_max = l.z_size + 1
			local rz_max = r.z_size + 1
			local lz, rz = 1, 1
			local ly_dom, ry_dom
				= get_dominating_values (ly, ry, l.y_edges, r.y_edges,
							 ly_max, ry_max)
			local z = 0

			while lz ~= lz_max or rz ~= rz_max do
				local lz_old, rz_old = lz, rz
				local lz_dom, rz_dom
					= get_dominating_values (lz, rz, l.z_edges, r.z_edges,
								 lz_max, rz_max)
				local l_on = lx_dom and ly_dom and lz_dom
					and is_occupied_p (l, l_b_disp, lx_dom - 1,
							   ly_dom - 1, lz_dom - 1)
				local r_on = rx_dom and ry_dom and rz_dom
					and is_occupied_p (r, r_b_disp, rx_dom - 1,
							   ry_dom - 1, rz_dom - 1)

				if op (l_on or false, r_on or false) then
					mark_occupied (region, b_disp, x, y, z)
				end

				-- Decide which value to increment and
				-- adjust l_on/r_on accordingly.
				if lz ~= lz_max
					and (rz_old == rz_max
					     or l.z_edges[lz_old] <= r.z_edges[rz_old]) then
					lz = lz + 1
				end
				if rz ~= rz_max
					and (lz_old == lz_max
					     or r.z_edges[rz_old] <= l.z_edges[lz_old]) then
					rz = rz + 1
				end
				z = z + 1
			end

			if ly ~= ly_max
				and (ry_old == ry_max
				     or l.y_edges[ly_old] <= r.y_edges[ry_old]) then
				ly = ly + 1
			end
			if ry ~= ry_max
				and (ly_old == ly_max
				     or r.y_edges[ry_old] <= l.y_edges[ly_old]) then
				ry = ry + 1
			end
			y = y + 1
		end

		if lx ~= lx_max
			and (rx_old == rx_max
			     or l.x_edges[lx_old] <= r.x_edges[rx_old]) then
			lx = lx + 1
		end
		if rx ~= rx_max
			and (lx_old == lx_max
			     or r.x_edges[rx_old] <= l.x_edges[lx_old]) then
			rx = rx + 1
		end
		x = x + 1
	end

	return region
end

local function region_is_AABB (region, x, y, z)
	local px = bisect (region.x_edges, region.x_size, x)
	local py = bisect (region.y_edges, region.y_size, y)
	local pz = bisect (region.z_edges, region.z_size, z)

	return px and py and pz
		and region.x_edges[px] == x
		and region.y_edges[py] == y
		and region.z_edges[pz] == z
		and is_occupied_p (region, region.b_disp, px - 1,
				   py - 1, pz - 1)
end

region_class.is_AABB = region_is_AABB

local function region_evaluate (l, r, op)
	-- Punt if empty.
	if l.x_size == 0 or l.y_size == 0 or l.z_size == 0 then
		return op (false, not r:is_empty ())
	elseif r.x_size == 0 or r.y_size == 0 or r.z_size == 0 then
		return op (not l:is_empty (), false)
	end

	local lx_max = l.x_size + 1
	local rx_max = r.x_size + 1
	local l_b_disp = l.b_disp
	local r_b_disp = r.b_disp
	local lx, rx = 1, 1
	local x = 0

	while lx ~= lx_max or rx ~= rx_max do
		local lx_old, rx_old = lx, rx
		local ly_max = l.y_size + 1
		local ry_max = r.y_size + 1
		local ly, ry = 1, 1
		local lx_dom, rx_dom
			= get_dominating_values (lx, rx, l.x_edges, r.x_edges,
						 lx_max, rx_max)
		local y = 0

		while ly ~= ly_max or ry ~= ry_max do
			local ly_old, ry_old = ly, ry
			local lz_max = l.z_size + 1
			local rz_max = r.z_size + 1
			local lz, rz = 1, 1
			local ly_dom, ry_dom
				= get_dominating_values (ly, ry, l.y_edges, r.y_edges,
							 ly_max, ry_max)
			local z = 0

			while lz ~= lz_max or rz ~= rz_max do
				local lz_old, rz_old = lz, rz
				local lz_dom, rz_dom
					= get_dominating_values (lz, rz, l.z_edges, r.z_edges,
								 lz_max, rz_max)
				local l_on = lx_dom and ly_dom and lz_dom
					and is_occupied_p (l, l_b_disp, lx_dom - 1,
							   ly_dom - 1, lz_dom - 1)
				local r_on = rx_dom and ry_dom and rz_dom
					and is_occupied_p (r, r_b_disp, rx_dom - 1,
							   ry_dom - 1, rz_dom - 1)

				if op (l_on or false, r_on or false) then
					return true
				end

				-- Decide which value to increment and
				-- adjust l_on/r_on accordingly.
				if lz ~= lz_max
					and (rz_old == rz_max
					     or l.z_edges[lz_old] <= r.z_edges[rz_old]) then
					lz = lz + 1
				end
				if rz ~= rz_max
					and (lz_old == lz_max
					     or r.z_edges[rz_old] <= l.z_edges[lz_old]) then
					rz = rz + 1
				end
				z = z + 1
			end

			if ly ~= ly_max
				and (ry_old == ry_max
				     or l.y_edges[ly_old] <= r.y_edges[ry_old]) then
				ly = ly + 1
			end
			if ry ~= ry_max
				and (ly_old == ly_max
				     or r.y_edges[ry_old] <= l.y_edges[ly_old]) then
				ry = ry + 1
			end
			y = y + 1
		end

		if lx ~= lx_max
			and (rx_old == rx_max
			     or l.x_edges[lx_old] <= r.x_edges[rx_old]) then
			lx = lx + 1
		end
		if rx ~= rx_max
			and (lx_old == lx_max
			     or r.x_edges[rx_old] <= l.x_edges[lx_old]) then
			rx = rx + 1
		end
		x = x + 1
	end

	return false
end

function region_class:equal_p (r)
	return self == r or not region_evaluate (self, r, OP_NEQ)
end

function region_class:intersect_p (r)
	return self == r or region_evaluate (self, r, OP_AND)
end

function region_class:contains_p (r)
	return self == r or not region_evaluate (self, r, OP_BNA)
end

local function any_occupied_p (region)
	local disp = region.b_disp
	for x = 0, region.x_size - 1 do
		for y = 0, region.y_size - 1 do
			for z = 0, region.z_size - 1 do
				if is_occupied_p (region, disp, x, y, z) then
					return true
				end
			end
		end
	end
	return false
end

function region_class:is_empty ()
	return self.x_size == 0
		or self.y_size == 0
		or self.z_size == 0
		or not any_occupied_p (self)
end

region_class.op = region_op

------------------------------------------------------------------------
-- Region traversal.
------------------------------------------------------------------------

local queue_class = {
	first = 0,
	last = -1,
}
queue_class.__index = queue_class

local function make_queue ()
	local queue = {
		data = {},
	}
	setmetatable (queue, queue_class)
	return queue
end

-- https://www.lua.org/pil/11.4.html implies this is optimized by the
-- Lua runtime.

function queue_class:read ()
	local first = self.first
	if first > self.last then
		return nil
	end
	local value = self[first]
	self[first] = nil        -- to allow garbage collection
	self.first = first + 1
	return value
end

function queue_class:insert (region)
	local last = self.last + 1
	self.last = last
	self[last] = region
end

local function unpack6 (aabb)
	return aabb[1], aabb[2], aabb[3], aabb[4], aabb[5], aabb[6]
end

local function find_cuboid (region, part, cuboid, explored)
	local disp = region.b_disp
	local x1, y1, z1, x2, y2, z2 = unpack6 (part)
	local identified = false
	local start_x, start_y, start_z
	for x = x1, x2 - 1 do
		for y = y1, y2 - 1 do
			for z = z1, z2 - 1 do
				if is_occupied_p (region, disp, x, y, z) then
					identified = true
					start_x, start_y, start_z = x, y, z
					break
				end
			end
			if identified then
				break
			end
		end

		if identified then
			break
		end
	end

	if not identified then
		return false
	end

	explored[1] = part[1]
	explored[2] = part[2]
	explored[3] = part[3]
	explored[4] = start_x
	explored[5] = start_y
	explored[6] = start_z
	cuboid[1] = start_x
	cuboid[2] = start_y
	cuboid[3] = start_z

	local x_end = start_x + 1
	while x_end < x2 do
		if not is_occupied_p (region, disp, x_end,
				      start_y, start_z) then
			break
		end
		x_end = x_end + 1
	end

	-- X is the outer extent of this cuboid on the X axis.
	-- Establish how far it extends along the Y axis.

	local y_end = start_y + 1
	while y_end < y2 do
		local done = false
		for x_test = start_x, x_end - 1 do
			if not is_occupied_p (region, disp, x_test,
					      y_end, start_z) then
				done = true
				break
			end
		end
		if done then
			break
		end
		y_end = y_end + 1
	end

	-- Y is the outer extent of this cuboid on the Y axis.  Verify
	-- how far it extends along the Z axis.

	local z_end = start_z + 1
	while z_end < z2 do
		local done = false
		for y_test = start_y, y_end - 1 do
			for x_test = start_x, x_end - 1 do
				if not is_occupied_p (region, disp, x_test,
						      y_test, z_end) then
					done = true
					break
				end
			end
			if done then
				break
			end
		end
		if done then
			break
		end
		z_end = z_end + 1
	end

	cuboid[4] = x_end
	cuboid[5] = y_end
	cuboid[6] = z_end

	-- This partly amounts to an assertion of the validity of
	-- every region in that every cuboid must be terminated by an
	-- unmarked edge.
	assert (x_end > cuboid[1] and y_end > cuboid[2] and z_end > cuboid[3])
	assert (x_end <= x2 and y_end <= y2 and z_end <= z2)
	return true
end

local function region_walk (region, fn, data)
	local x_max = region.x_size + 1
	local y_max = region.y_size + 1
	local z_max = region.z_size + 1

	if x_max == 1 or y_max == 1 or z_max == 1 then
		return 0
	end

	local queue = make_queue ()
	local initial = {
		0, 0, 0,
		region.x_size - 1,
		region.y_size - 1,
		region.z_size - 1,
	}
	queue:insert (initial)

	local next_val = queue:read ()
	local cuboid, explored = {}, {}
	while next_val do
		if find_cuboid (region, next_val, cuboid, explored) then
			local aabb = {
				region.x_edges[cuboid[1] + 1],
				region.y_edges[cuboid[2] + 1],
				region.z_edges[cuboid[3] + 1],
				region.x_edges[cuboid[4] + 1],
				region.y_edges[cuboid[5] + 1],
				region.z_edges[cuboid[6] + 1],
			}
			if fn (aabb, data) == 1 then
				return 1
			end

			-- Subtract cuboid from next.

			-- Lengthwise segments.
			if cuboid[1] > next_val[1] then
				queue:insert ({
					next_val[1],
					next_val[2],
					next_val[3],
					cuboid[1],
					next_val[5],
					next_val[6],
				})
			end
			if cuboid[4] < next_val[4] then
				queue:insert ({
					cuboid[4],
					next_val[2],
					next_val[3],
					next_val[4],
					next_val[5],
					next_val[6],
				})
			end

			-- Vertical segments.
			if cuboid[2] > next_val[2] then
				queue:insert ({
					cuboid[1],
					next_val[2],
					next_val[3],
					cuboid[4],
					cuboid[2],
					next_val[6],
				})
			end
			if cuboid[5] < next_val[5] then
				queue:insert ({
					cuboid[1],
					cuboid[5],
					next_val[3],
					cuboid[4],
					next_val[5],
					next_val[6],
				})
			end

			-- Lengthwise segments.
			if cuboid[3] > next_val[3] then
				queue:insert ({
					cuboid[1],
					cuboid[2],
					next_val[3],
					cuboid[4],
					cuboid[5],
					cuboid[3],
				})
			end

			if cuboid[6] < next_val[6] then
				queue:insert ({
					cuboid[1],
					cuboid[2],
					cuboid[6],
					cuboid[4],
					cuboid[5],
					next_val[6],
				})
			end
		end

		next_val = queue:read ()
	end
	return 0
end

region_class.walk = region_walk

------------------------------------------------------------------------
-- Region simplification.
------------------------------------------------------------------------

local function edge_redundant_p (region, edge, other_0_end, other_1_end, is_occupied_p)
	local x_pos = edge
	local disp = region.b_disp

	for y_pos = 1, other_0_end do
		for z_pos = 1, other_1_end do
			local prev_state = false
			local state

			-- This edge must not appear in an
			-- on-transition or an off-transition.  That
			-- is to say, for every vertex intersecting
			-- this edge the preceding position on its
			-- axis must be identical to the status of the
			-- said vertex.

			state = is_occupied_p (region, disp, x_pos - 1,
					       y_pos - 1, z_pos - 1)
			if x_pos > 1 then
				prev_state = is_occupied_p (region, disp, x_pos - 2,
							    y_pos - 1, z_pos - 1)
			end

			if prev_state ~= state then
				return false
			end
		end
	end

	return true
end

local function is_occupied_p_yxz (region, disp, y, x, z)
	return is_occupied_p (region, disp, x, y, z)
end

local function is_occupied_p_zxy (region, disp, z, x, y)
	return is_occupied_p (region, disp, x, y, z)
end

local function region_simplify (region)
	local new = {
		x_edges = {},
		y_edges = {},
		z_edges = {},
		solids = {},
	}
	setmetatable (new, region_class)

	local x_edges = new.x_edges
	local y_edges = new.y_edges
	local z_edges = new.z_edges

	for x = 1, region.x_size do
		-- Is this X edge redundant wrt Y and Z?
		if not edge_redundant_p (region, x, region.y_size,
					 region.z_size, is_occupied_p) then
			table.insert (x_edges, region.x_edges[x])
		end
	end

	for y = 1, region.y_size do
		-- Is this Y edge redundant wrt X and Z?
		if not edge_redundant_p (region, y, region.x_size,
					 region.z_size, is_occupied_p_yxz) then
			table.insert (y_edges, region.y_edges[y])
		end
	end

	for z = 1, region.z_size do
		-- Is this Z edge redundant wrt X and Z?
		if not edge_redundant_p (region, z, region.x_size,
					 region.y_size, is_occupied_p_zxy) then
			table.insert (z_edges, region.z_edges[z])
		end
	end

	new.x_size = #x_edges
	new.y_size = #y_edges
	new.z_size = #z_edges

	-- Allocate or resize solids array.
	new.b_disp = region_displacement_xyz (new.x_size, new.y_size, new.z_size)
	new.b_size = bitset_size (new.b_disp, new.x_size, new.y_size, new.z_size)
	do
		local solids = new.solids
		for i = 1, new.b_size do
			solids[i] = 0
		end
	end

	local region_b_disp = region.b_disp
	local disp = new.b_disp
	for x = 1, #x_edges do
		local src_x = bisect (region.x_edges,
				      region.x_size, x_edges[x])
		for y = 1, #y_edges do
			local src_y = bisect (region.y_edges,
					      region.y_size,
					      y_edges[y])
			for z = 1, #z_edges do
				local src_z = bisect (region.z_edges,
						      region.z_size,
						      z_edges[z])

				if is_occupied_p (region, region_b_disp,
						  src_x - 1, src_y - 1, src_z - 1) then
					mark_occupied (new, disp, x - 1,
						       y - 1, z - 1)
				end
			end
		end
	end

	return new
end

region_class.simplify = region_simplify

------------------------------------------------------------------------
-- Region utilities.
------------------------------------------------------------------------

local default_solids = {
	1,
}

for i = 2, bitset_size (1, 2, 2, 2) do
	default_solids[i] = 0
end

local function region_init_from_aabb (aabb)
	local region = {}
	region.solids = default_solids
	region.b_size = bitset_size (1, 2, 2, 2)
	region.b_disp = 1
	region.x_size = 2
	region.y_size = 2
	region.z_size = 2
	region.x_edges = {
		aabb[1],
		aabb[4],
	}
	region.y_edges = {
		aabb[2],
		aabb[5],
	}
	region.z_edges = {
		aabb[3],
		aabb[6],
	}
	setmetatable (region, region_class)
	return region
end
mcl_util.region_init_from_aabb = region_init_from_aabb

function region_class:intersect (aabb)
	return region_op (self, region_init_from_aabb (aabb), OP_AND)
end

function region_class:subtract (aabb)
	return region_op (self, region_init_from_aabb (aabb), OP_SUB)
end

function region_class:union (aabb)
	return region_op (self, region_init_from_aabb (aabb), OP_OR)
end

------------------------------------------------------------------------
-- Region cross-sections (a.k.a. faces).
------------------------------------------------------------------------

local function mark_occupied_yxz (region, disp, y, x, z)
	mark_occupied (region, disp, x, y, z)
end

local function mark_occupied_zxy (region, disp, z, x, y)
	mark_occupied (region, disp, x, y, z)
end

local function region_select_face (region, normal_axis, pos)
	local m, m_size, a, a_size, b, b_size, occupancy_test
	local set_occupied

	if normal_axis == "x" then
		m = region.x_edges
		m_size = region.x_size
		a = region.y_edges
		a_size = region.y_size
		b = region.z_edges
		b_size = region.z_size
		occupancy_test = is_occupied_p
		set_occupied = mark_occupied
	elseif normal_axis == "y" then
		m = region.y_edges
		m_size = region.y_size
		a = region.x_edges
		a_size = region.x_size
		b = region.z_edges
		b_size = region.z_size
		occupancy_test = is_occupied_p_yxz
		set_occupied = mark_occupied_yxz
	elseif normal_axis == "z" then
		m = region.z_edges
		m_size = region.z_size
		a = region.x_edges
		a_size = region.x_size
		b = region.y_edges
		b_size = region.y_size
		occupancy_test = is_occupied_p_zxy
		set_occupied = mark_occupied_zxy
	end

	-- Locate a value along M matching POS.
	local basis = bisect (m, m_size, pos)
	if not basis then
		return empty_region
	end

	-- If there is an edge at POS, its on state is governed not
	-- only by itself but also its previous value.
	local basis_other = (m[basis] == pos and basis ~= 1)
		and basis - 1 or basis

	-- Iterate over A and B, the remaining axes.
	local out_a = {}
	local out_b = {}
	out_a[a_size] = nil
	out_a[b_size] = nil
	for _, value in ipairs (a) do
		table.insert (out_a, value)
	end
	for _, value in ipairs (b) do
		table.insert (out_b, value)
	end

	local new = {}
	setmetatable (new, region_class)

	if normal_axis == "x" then
		new.x_edges = {
			math.min (pos, -pos),
			math.max (pos, -pos),
		}
		new.x_size = 2
		new.y_edges = out_a
		new.y_size = a_size
		new.z_edges = out_b
		new.z_size = b_size
	elseif normal_axis == "y" then
		new.y_edges = {
			math.min (pos, -pos),
			math.max (pos, -pos),
		}
		new.y_size = 2
		new.x_edges = out_a
		new.x_size = a_size
		new.z_edges = out_b
		new.z_size = b_size
	elseif normal_axis == "z" then
		new.z_edges = {
			math.min (pos, -pos),
			math.max (pos, -pos),
		}
		new.z_size = 2
		new.x_edges = out_a
		new.x_size = a_size
		new.y_edges = out_b
		new.y_size = b_size
	end

	local solids = {}
	new.solids = solids
	new.b_disp = region_displacement_xyz (new.x_size, new.y_size, new.z_size)
	new.b_size = bitset_size (new.b_disp, new.x_size, new.y_size, new.z_size)
	for i = 1, new.b_size do
		solids[i] = 0
	end

	local region_disp = new.b_disp
	local disp = new.b_disp
	for b1 = 0, b_size - 1 do
		for a1 = 0, a_size - 1 do
			if occupancy_test (region, region_disp,
					   basis - 1, a1, b1)
				or occupancy_test (region, region_disp,
						   basis_other - 1, a1, b1) then
				set_occupied (new, disp, 0, a1, b1)
			end
		end
	end
	return new
end

region_class.select_face = region_select_face
