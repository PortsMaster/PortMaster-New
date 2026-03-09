if not mcl_util then
	mcl_util = {}
end

local ipairs = ipairs
local mathmax = math.max
local mathmin = math.min
local mathabs = math.abs
local insert = table.insert
local huge = math.huge

----------------------------------------------------------------------
-- Spatial index.
--
-- This module implements a spatial index which records information
-- connected to rectangular bounding boxes to be accessed by range
-- queries; in contrast to AreaStores, the identities of this
-- information are maintained, which facilitates implementing various
-- types of spatial caches (such as the POI search cache maintained by
-- villagers) on the basis of this structure.
----------------------------------------------------------------------

local spatial_index_class = {}

local spatial_index_meta = {
	__index = spatial_index_class,
}

local m = 15
local M = 50

-- Each node is an array of a bounding box X1, Y1, Z1, X2, Y2, Z2 and
-- M values; the root of a spatial index is either such a node or an
-- array of 2 to M values where N is -1.
--
-- Each value is a bounding box and a data element { X1, Y1, Z1, X2,
-- Y2, Z2, DATA }.

local function node_bbox (node)
	return node[1], node[2], node[3], node[4], node[5], node[6]
end

local function node_area (f)
	local x1, y1, z1, x2, y2, z2 = node_bbox (f)
	return (x2 - x1 + 1) * (y2 - y1 + 1) * (z2 - z1 + 1)
end

local function node_resize_area (a, b)
	local area_1 = node_area (a)
	local area_2 = node_area ({
		mathmin (a[1], b[1]),
		mathmin (a[2], b[2]),
		mathmin (a[3], b[3]),
		mathmax (a[4], b[4]),
		mathmax (a[5], b[5]),
		mathmax (a[6], b[6]),
	})
	return area_2 - area_1
end

local pdl = {}

local function choose_leaf (node, height, extents)
	local idx, area = 0
	while height > 0 do
		idx = idx + 1
		pdl[idx] = node
		height = height - 1

		local f = node[7]
		area = node_resize_area (node[7], extents)
		for i = 8, #node do
			local f1 = node[i]
			local area_1 = node_resize_area (f1, extents)
			if area > area_1
				or (area_1 == area
				    and node_area (f) > node_area (f1)) then
				f, area = f1, area
			end
		end
		node = f
	end
	return node, idx
end

local function encapsulating_bbox_area (a, b)
	local ax1, ay1, az1, ax2, ay2, az2 = node_bbox (a)
	local bx1, by1, bz1, bx2, by2, bz2 = node_bbox (b)
	return (mathmax (ax2, bx2) - mathmin (ax1, bx1) + 1)
		* (mathmax (az2, bz2) - mathmin (az1, bz1) + 1)
		* (mathmax (ay2, by2) - mathmin (ay1, by1) + 1)
end

local function bbox_growth (a, b)
	return encapsulating_bbox_area (a, b) - node_area (a)
end

local MAX_NEXT = 7 + M

local function pick_seeds (nodes)
	local ii, jj, iidx, jidx, max_wastage

	for i = 7, MAX_NEXT do
		if nodes[i] then
			for j = 7, MAX_NEXT do
				if j ~= i and nodes[j] then
					local a = encapsulating_bbox_area (nodes[i], nodes[j])
					local b = node_area (nodes[i])
					local c = node_area (nodes[j])
					local wastage = a - b - c

					if not ii or max_wastage < wastage then
						ii = nodes[i]
						jj = nodes[j]
						iidx = i
						jidx = j
						max_wastage = wastage
					end
				end
			end
		end
	end

	if iidx then
		nodes[iidx] = nil
		nodes[jidx] = nil
		return ii, jj
	end
	return nil
end

local function pick_next (node_a, node_b, nodes)
	local d_max, most_biased, i_most_biased

	for i = 7, MAX_NEXT do
		local candidate = nodes[i]
		if candidate then
			local growth_a = bbox_growth (node_a, candidate)
			local growth_b = bbox_growth (node_b, candidate)
			if not d_max or (mathabs (d_max)
					 < mathabs (growth_a - growth_b)) then
				d_max = growth_a - growth_b
				most_biased = candidate
				i_most_biased = i
			end
		end
	end

	if most_biased then
		nodes[i_most_biased] = nil
		return most_biased, d_max <= 0
	else
		return nil, false
	end
end

local function bbox_encapsulate (a, b)
	local x1, y1, z1, x2, y2, z2 = node_bbox (b)
	a[1] = mathmin (a[1], x1)
	a[2] = mathmin (a[2], y1)
	a[3] = mathmin (a[3], z1)
	a[4] = mathmax (a[4], x2)
	a[5] = mathmax (a[5], y2)
	a[6] = mathmax (a[6], z2)
end

local function assign_remaining (mbr, nodes)
	for i = 7, MAX_NEXT do
		if nodes[i] then
			insert (mbr, nodes[i])
			bbox_encapsulate (mbr, nodes[i])
		end
	end
end

local M1 = M + 1 - m + 6

local function split_node (nodes, dbg)
	local ii, jj = pick_seeds (nodes)
	local node_a = { ii[1], ii[2], ii[3], ii[4], ii[5], ii[6], ii, }
	local node_b = { jj[1], jj[2], jj[3], jj[4], jj[5], jj[6], jj, }

	local k, is_a = pick_next (node_a, node_b, nodes)
	while k do
		if is_a then
			insert (node_a, k)
			bbox_encapsulate (node_a, k)
		else
			insert (node_b, k)
			bbox_encapsulate (node_b, k)
		end
		if #node_a == M1 then
			-- Assign all remaining nodes to the second mbr.
			assign_remaining (node_b, nodes)
			break
		elseif #node_b == M1 then
			-- Assign all remaining nodes to the first mbr.
			assign_remaining (node_a, nodes)
			break
		end
		k, is_a = pick_next (node_a, node_b, nodes)
	end

	return node_a, node_b
end

local function indexof (array, value)
	for i, m in ipairs (array) do
		if m == value then
			return i
		end
	end
	return nil
end

local function insert_1 (self, dst_leaf, max_parent, new_entry)
	local ll = nil
	local l
	local entry
	if #dst_leaf - 6 < M then
		l = new_entry
		dst_leaf[#dst_leaf + 1] = new_entry
		entry = #dst_leaf + 1
		bbox_encapsulate (dst_leaf, new_entry)
	else
		-- Must split this leaf.
		dst_leaf[6 + M + 1] = new_entry
		l, ll = split_node (dst_leaf)
		if max_parent > 0 then
			local p = pdl[max_parent]
			entry = indexof (p, dst_leaf)
		end
	end

	-- Propagate splits up the tree while adjusting bounding
	-- boxes.
	for i = max_parent, 1, -1 do
		if not ll then
			bbox_encapsulate (pdl[i], l)
			pdl[i] = nil
		else
			-- If the node was split, the second child
			-- must be folded into the parent; if that
			-- operation would exceed the parent's child
			-- list's maximum dimensions, the parent
			-- should likewise be split, possibly
			-- recursively, such that
			--
			--       [ R1 R2 R3 ... R18 ]
			--         -> < R19 R20 ... R36 > < R37 >
			--
			-- becomes, initially:
			--
			--       [ R1 R2 R3 ... R18 ]
			--         -> < R19 R20 R21 ... > | < ... R35 R36 R37 >
			--
			-- and subsequently:
			--
			--       [ R1 R2 R3 ... ]       | [ ... R17 R18 R38 ]
			--         -> < ... R19 R20 R21 >      -> < ... R35 R36 R37 >
			--
			-- whereupon a new root node must be created
			-- to encompass these new nodes and the height
			-- of the tree incremented accordingly.
			local p = pdl[i]
			p[entry] = l
			if #p - 6 >= M then
				p[#p + 1] = ll
				l, ll = split_node (p)
			else
				p[#p + 1] = ll
				bbox_encapsulate (p, l)
				bbox_encapsulate (p, ll)
				l = p
				ll = nil
			end
			pdl[i] = nil

			if i > 1 then
				entry = indexof (pdl[i - 1], p)
			end
		end
	end

	-- If ll is yet set, create a new root node which encloses
	-- both values.
	if ll then
		local new_root = {
			mathmin (l[1], ll[1]),
			mathmin (l[2], ll[2]),
			mathmin (l[3], ll[3]),
			mathmax (l[4], ll[4]),
			mathmax (l[5], ll[5]),
			mathmax (l[6], ll[6]),
			l,
			ll,
		}
		local height = self.height
		self.height = height + 1
		self.root = new_root
	end
end

-- NOTE: DATA must be a value with an identity, which excludes strings
-- and numbers, unless you guarantee that any particular instance of
-- DATA will not appear in this class with the same EXTENTS oftener
-- than once.

function spatial_index_class:insert (extents, data)
	local dst_leaf, max_parent
		= choose_leaf (self.root, self.height, extents)
	local new_entry = {
		extents[1],
		extents[2],
		extents[3],
		extents[4],
		extents[5],
		extents[6],
		data,
	}
	insert_1 (self, dst_leaf, max_parent, new_entry)
end

local function bbox_intersect_p (a, b)
	local x1a, y1a, z1a, x2a, y2a, z2a = node_bbox (a)
	local x1b, y1b, z1b, x2b, y2b, z2b = node_bbox (b)

	return x1a <= x2b and y1a <= y2b
		and z1a <= z2b and x2a >= x1b
		and y2a >= y1b and z2a >= z1b
end

local function bbox_contains_p (a, b)
	local x1a, y1a, z1a, x2a, y2a, z2a = node_bbox (a)
	local x1b, y1b, z1b, x2b, y2b, z2b = node_bbox (b)

	return x1b >= x1a and z1b >= z1a and y1b >= y1a
		and x2b <= x2a and z2b <= z2a and y2b <= y2a
end

local function get_intersecting_1 (node, bbox, dst, height)
	if height == 0 then
		for i = 7, #node do
			if bbox_intersect_p (node[i], bbox) then
				insert (dst, node[i])
			end
		end
	else
		for i = 7, #node do
			if bbox_intersect_p (node[i], bbox) then
				get_intersecting_1 (node[i], bbox, dst, height - 1)
			end
		end
	end
end

function spatial_index_class:query_intersecting (bbox, dst)
	get_intersecting_1 (self.root, bbox, dst, self.height)
end

local function any_intersecting_1 (node, bbox, height)
	if height == 0 then
		for i = 7, #node do
			if bbox_intersect_p (node[i], bbox) then
				return node[i]
			end
		end
	else
		for i = 7, #node do
			if bbox_intersect_p (node[i], bbox) then
				local value = any_intersecting_1 (node[i], bbox, height - 1)
				if value then
					return value
				end
			end
		end
	end
	return false
end

function spatial_index_class:any_intersecting (bbox)
	return any_intersecting_1 (self.root, bbox, self.height)
end

local function get_containing_1 (node, x, y, z, dst, height)
	if height == 0 then
		for i = 7, #node do
			local node1 = node[i]
			if node1[1] <= x and node1[2] <= y and node1[3] <= z
				and node1[4] >= x and node1[5] >= y and node1[6] >= z then
				insert (dst, node[i])
			end
		end
	else
		for i = 7, #node do
			local node1 = node[i]
			if node1[1] <= x and node1[2] <= y and node1[3] <= z
				and node1[4] >= x and node1[5] >= y and node1[6] >= z then
				get_containing_1 (node1, x, y, z, dst, height - 1)
			end
		end
	end
end

function spatial_index_class:query_point (x, y, z, dst)
	get_containing_1 (self.root, x, y, z, dst, self.height)
end

local function delete_pop (pdl)
	if #pdl == 0 then
		return nil
	end

	local idx, node = pdl[#pdl - 1], pdl[#pdl]
	pdl[#pdl] = nil
	pdl[#pdl] = nil
	return idx, node
end

local function delete (array, idx, element)
	assert (array[idx] == element)
	for i = idx, #array - 1 do
		array[i] = array[i + 1]
	end
	array[#array] = nil
end

local function recompute_bbox (node)
	local x1, y1, z1 = huge, huge, huge
	local x2, y2, z2 = -huge, -huge, -huge
	for i = 7, #node do
		x1 = mathmin (x1, node[i][1])
		y1 = mathmin (y1, node[i][2])
		z1 = mathmin (z1, node[i][3])
		x2 = mathmax (x2, node[i][4])
		y2 = mathmax (y2, node[i][5])
		z2 = mathmax (z2, node[i][6])
	end
	node[1] = x1
	node[2] = y1
	node[3] = z1
	node[4] = x2
	node[5] = y2
	node[6] = z2
end

local function default_match_data (a, b)
	return a == b
end

function spatial_index_class:delete (extents, data, contains_p,
				     match_data)
	local node, i = self.root, 7
	local entry = nil
	local pdl = { }
	local height = self.height
	local contains_p = contains_p or bbox_contains_p
	local match_data = match_data or default_match_data

	while node do
		local lim = #node
		while i <= lim do
			if contains_p (node[i], extents) then
				if height == 0 and match_data (node[i][7], data) then
					entry = node[i]
					break
				elseif height > 0 then
					insert (pdl, i + 1)
					insert (pdl, node)
					node, i = node[i], 6
					lim = #node
					height = height - 1
				end
			end
			i = i + 1
		end

		if not entry then
			i, node = delete_pop (pdl)
			height = height + 1
		else
			break
		end
	end

	if not entry then
		return false
	end

	-- Delete ENTRY from NODE.
	delete (node, i, entry)

	-- Condense this tree.
	local elim = {}
	local bereaved = node

	while bereaved do
		local idx, parent = delete_pop (pdl)
		if parent then
			if #bereaved - 6 < m then
				insert (elim, height)
				for i = 7, #bereaved do
					insert (elim, bereaved[i])
				end
				delete (parent, idx - 1, bereaved)
			else
				-- Adjust MBR bounding box; if a child
				-- was deleted its bounding box will
				-- be recomputed here.
				recompute_bbox (bereaved)
			end
		end
		bereaved = parent
		height = height + 1
	end

	-- Reinsert each MBR eliminated for underflow at the level in
	-- the tree where it stood when it was deleted.

	local level
	for _, level_or_mbr in ipairs (elim) do
		if type (level_or_mbr) == "number" then
			level = level_or_mbr
		else
			local dst_leaf, max_parent
				= choose_leaf (self.root, self.height - level,
					       level_or_mbr)
			insert_1 (self, dst_leaf, max_parent, level_or_mbr)
		end
	end

	-- Has the root just one child and is it not itself a leaf?
	local root = self.root
	if self.height > 0 and #root == 7 then
		-- Pivot that only child to the root of the tree.
		self.root = root[7]
		self.height = self.height - 1
	else
		recompute_bbox (root)
	end

	return true
end

local function validate_1 (height, max_height, mbr, seen, is_leaf_element_p)
	assert (height >= 0, "Invalid height: " .. height)
	if #mbr > 6 then
		if is_leaf_element_p (mbr[7]) then
			assert (height == 0, "Leaf at erroneous level: " .. height)
		else
			assert (height ~= 0, "MBR at erroneous level: " .. height)
		end
	end

	if seen[mbr] then
		local message
			= string.format ("MBR appears repeatedly in tree: (%d,%d,%d) - (%d,%d,%d)",
					 node_bbox (mbr))
		assert (false, message)
	end
	seen[mbr] = true

	local x1, y1, z1, x2, y2, z2 = node_bbox (mbr)
	recompute_bbox (mbr)
	if not (x1 == mbr[1] and y1 == mbr[2] and z1 == mbr[3]
		and x2 == mbr[4] and y2 == mbr[5] and z2 == mbr[6]) then
		local message
			= string.format ("MBR/leaf bounding box mismatch at level %d: (%d,%d,%d) - (%d,%d,%d) "
					 .. "as against (%d,%d,%d) - (%d,%d,%d)", height,
					 x1, y1, z1, x2, y2, z2, node_bbox (mbr))
		assert (false, message)
	end
	if (height == 0 and max_height > 0 and #mbr - 6 < m)
		or #mbr - 6 > M then
		local blurb
			= string.format ("Invalid mbr dimensions at level %d: %d (m=%d, M=%d)",
					 height, #mbr - 6, m, M)
		assert (false, blurb)
	end

	if height > 0 then
		for i = 7, #mbr do
			validate_1 (height - 1, max_height, mbr[i], seen, is_leaf_element_p)
		end
	end
end

function spatial_index_class:validate (is_leaf_element_p)
	validate_1 (self.height, self.height, self.root, {}, is_leaf_element_p)
end

function mcl_util.make_spatial_index ()
	local tbl = {
		root = { huge, huge, huge, -huge, -huge, -huge, },
		height = 0,
	}
	setmetatable (tbl, spatial_index_meta)
	return tbl
end

if not core then
	return
end

----------------------------------------------------------------------
-- Node search cache.
----------------------------------------------------------------------

local search_cache_class = {}
local search_cache_meta = {
	__index = search_cache_class,
}

function mcl_util.construct_node_list (name_list)
	local names = {}
	for _, target in ipairs (name_list) do
		if target:sub (1, 6) == "group:" then
			local group = target:sub (7)
			for name, tbl in pairs (core.registered_nodes) do
				if tbl.groups[group] and tbl.groups[group] > 0 then
					local cid = core.get_content_id (name)
					table.insert (names, cid)
				end
			end
		else
			local cid = core.get_content_id (target)
			table.insert (names, cid)
		end
	end
	return names
end

function mcl_util.make_node_search_cache (eviction_policy, nodenames)
	local tbl = {
		eviction_policy = eviction_policy,
		spatial_index = mcl_util.make_spatial_index (),
		sections_indexed = {},
		nodenames = nodenames,
		cnt_entries = 0,
	}
	assert (tbl.eviction_policy == "limit_size")
	setmetatable (tbl, search_cache_meta)

	local node_names = {}
	core.register_on_mods_loaded (function ()
		node_names = mcl_util.construct_node_list (nodenames)
		tbl.node_ids = node_names
	end)

	core.register_on_dignode (function (pos, oldnode, digger)
		local cid = core.get_content_id (oldnode.name)
		if not indexof (node_names, cid) then
			return
		end
		tbl:notify_deleted (pos)
	end)

	core.register_on_placenode (function (pos, newnode, placer, oldnode, itemstack, pointed_thing)
		local cid = core.get_content_id (newnode.name)
		if not indexof (node_names, cid) then
			return
		end
		tbl:notify_placed (pos)
	end)

	return tbl
end

local v1 = vector.new ()
local v2 = vector.new ()

local function collect_nodes_in_area (bbox, nodenames, spatial_index)
	v1.x = bbox[1]
	v1.y = bbox[2]
	v1.z = bbox[3]
	v2.x = bbox[4]
	v2.y = bbox[5]
	v2.z = bbox[6]

	local nodes = core.find_nodes_in_area (v1, v2, nodenames)
	for _, node in ipairs (nodes) do
		local cid, _ = core.get_node_raw (node.x, node.y, node.z)
		spatial_index:insert ({
			node.x, node.y, node.z,
			node.x, node.y, node.z,
		}, cid)
	end
end

local CACHE_QUANTIZE = 16
local CACHE_QUANTIZE_INC = 16
local CACHE_QUANTIZE_MAX = 15
local band = bit.band
local SEARCH_CACHE_LIMIT = 8192

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end

local v = vector.new ()

local function match_always (a, b)
	return true
end

function search_cache_class:find_nodes_in_area (pos1, pos2, node_ids)
	if self.cnt_entries > SEARCH_CACHE_LIMIT then
		self:reset ()
	end

	pos1 = mcl_util.get_nodepos (pos1)
	pos2 = mcl_util.get_nodepos (pos2)
	local cached = {}
	local bbox = {
		band (pos1.x, -CACHE_QUANTIZE),
		band (pos1.y, -CACHE_QUANTIZE),
		band (pos1.z, -CACHE_QUANTIZE),
		band (pos2.x, -CACHE_QUANTIZE) + CACHE_QUANTIZE_MAX,
		band (pos2.y, -CACHE_QUANTIZE) + CACHE_QUANTIZE_MAX,
		band (pos2.z, -CACHE_QUANTIZE) + CACHE_QUANTIZE_MAX,
	}
	local search_bbox = {
		pos1.x, pos1.y, pos1.z,
		pos2.x, pos2.y, pos2.z,
	}
	local point_exists_p = self.sections_indexed
	local spatial_index = self.spatial_index

	local entries = 0
	for z = bbox[3], bbox[6], CACHE_QUANTIZE_INC do
		for y = bbox[2], bbox[5], CACHE_QUANTIZE_INC do
			for x = bbox[1], bbox[4], CACHE_QUANTIZE_INC do
				v.x = x
				v.y = y
				v.z = z
				local hash = longhash (x, y, z)
				if not point_exists_p[hash]
					and core.compare_block_status (v, "loaded") then
					local wanted = {
						x, y, z,
						x + CACHE_QUANTIZE_MAX,
						y + CACHE_QUANTIZE_MAX,
						z + CACHE_QUANTIZE_MAX,
					}
					point_exists_p[hash] = true
					entries = entries + 1
					collect_nodes_in_area (wanted,
							       self.nodenames,
							       spatial_index)
				end
			end
		end
	end
	self.cnt_entries = self.cnt_entries + entries
	spatial_index:query_intersecting (search_bbox, cached)

	local self_node_ids = self.node_ids
	local nodes = {}
	for _, pos in ipairs (cached) do
		local cid, _ = core.get_node_raw (pos[1], pos[2], pos[3])
		if indexof (self_node_ids, cid) or cid == nil then
			if not node_ids or indexof (node_ids, cid or pos[7]) then
				insert (nodes, vector.new (pos[1], pos[2], pos[3]))
			end
			pos[7] = cid
		else
			-- This node is no longer valid.
			local rc = spatial_index:delete (pos, nil, nil, match_always)
			assert (rc)
		end
	end
	return nodes
end

function search_cache_class:notify_placed (pos)
	local hash = longhash (band (pos.x, -CACHE_QUANTIZE),
			       band (pos.y, -CACHE_QUANTIZE),
			       band (pos.z, -CACHE_QUANTIZE))
	if self.sections_indexed[hash] then
		local index = self.spatial_index
		local cid, _ = core.get_node_raw (pos.x, pos.y, pos.z)
		local cached = {}
		index:query_point (pos.x, pos.y, pos.z, cached)
		if #cached == 0 then
			index:insert ({
					pos.x, pos.y, pos.z,
					pos.x, pos.y, pos.z,
			}, cid)
		else
			cached[1][7] = cid
		end
	end
end

function search_cache_class:notify_deleted (pos)
	local index = self.spatial_index
	index:delete ({
		pos.x, pos.y, pos.z,
		pos.x, pos.y, pos.z,
	}, nil, nil, match_always)
end

function search_cache_class:reset ()
	self.cnt_entries = 0
	self.sections_indexed = {}
	self.spatial_index = mcl_util.make_spatial_index ()
end
