local mob_class = mcl_mobs.mob_class
local floor = math.floor
local luajit_present = core.global_exists ("jit")
local is_valid = mcl_util.is_valid_objectref

local function shift_up (self, node, idx)
	local priority = node.priority
	local heap = self.heap
	while idx > 1 do
		local parent = floor (idx / 2)
		local n = heap[parent]

		if n.priority < priority then
			break
		end

		-- Swap node positions.
		heap[idx] = n
		n.idx = idx
		idx = parent
	end

	-- idx is now the proper depth of this node in the tree.
	self.heap[idx] = node
	node.idx = idx
end

local function shift_down (self, node, idx)
	local priority = node.priority
	local heap = self.heap
	local size = self.size

	while true do
		local left = idx * 2
		local right = left + 1

		-- Break early if it is known that no nodes exist
		-- greater than this.
		if left > size then
			break
		end
		local leftnode = heap[left]
		local rightnode = heap[right]
		local lp, rp = leftnode.priority
		rp = rightnode and rightnode.priority or math.huge

		if lp < rp then
			if lp >= priority then
				break
			end
			heap[idx] = leftnode
			leftnode.idx = idx
			idx = left
		else
			if rp >= priority then
				break
			end
			heap[idx] = rightnode
			rightnode.idx = idx
			idx = right
		end
	end

	heap[idx] = node
	node.idx = idx
end

local function mintree_enqueue (self, item, priority)
	assert (not item.idx)
	local i = self.size + 1
	self.size = i
	self.heap[i] = item
	item.idx = i
	item.priority = priority
	shift_up (self, item, i)
end

local function mintree_dequeue (self, item, prfiority)
	local heap = self.heap
	local n, size = heap[1], self.size
	heap[1], heap[size] = heap[size], nil
	self.size = size - 1
	if size > 0 then
		shift_down (self, heap[1], 1)
	end
	heap.idx = nil
	return n
end

local function mintree_update (self, item, priority)
	local f_old = item.priority
	item.priority = priority

	if priority < f_old then
		shift_up (self, item, item.idx)
	elseif priority > f_old then
		shift_down (self, item, item.idx)
	end
end

local function mintree_empty (self)
	return self.size == 0
end

local function mintree_contains (self, item)
	return item.idx ~= nil
end

local function new_mintree ()
	return {
		heap = { },
		size = 0,
		enqueue = mintree_enqueue,
		dequeue = mintree_dequeue,
		update = mintree_update,
		empty = mintree_empty,
		contains = mintree_contains,
	}
end

-- Extensible A* pathfinder.
--
-- Notably, it is capable of moving diagonally, assigning deterrence
-- values to blocks, navigating to multiple targets, and returning
-- incomplete paths.

function mob_class:new_gwp_context ()
	return {
		open_set = new_mintree (),
		targets = {},
		arrivals = {},
		nodes = {},
		class_cache = {},
		tolerance = 0,
		time_elapsed = 0,
		total_nodes = 0,
		y_offset = 0,
	}
end

local hashpos

if not luajit_present then
	function hashpos (context, x, y, z)
		local x1, y1, z1
		x1 = x - context.minpos.x
		y1 = y - context.minpos.y
		z1 = z - context.minpos.z

		return x1 * 256*256 + y1 * 256 + z1
	end
	mcl_mobs.gwp_hashpos = hashpos
else
	function hashpos (context, x, y, z)
		local x1, y1, z1
		x1 = x - context.minpos.x
		y1 = y - context.minpos.y
		z1 = z - context.minpos.z

		return bit.lshift (x1, 16)
			+ bit.lshift (y1, 8)
			+ bit.tobit (z1)
	end
	mcl_mobs.gwp_hashpos = hashpos
end

local function longhash (x, y, z)
	return (32768 + x) * 65536 * 65536 + (32768 + y) * 65536
		+ (32768 + z)
end
mcl_mobs.gwp_longhash = longhash

function mob_class:get_gwp_node (context, x, y, z)
	-- assert (x % 1 == 0 and y % 1 == 0 and z % 1 == 0)
	local hash = hashpos (context, x, y, z)
	if context.nodes[hash] then
		return context.nodes[hash]
	end
	local obj = {
		x = x, y = y, z = z,
		g = nil, h = nil, penalty = 0,
		f = 0, total_d = 0,
	}
	context.nodes[hash] = obj
	return obj
end

function mob_class:gwp_target_pos (context, pos)
	local n = mob_class:get_gwp_node (context, floor (pos.x + 0.5),
					  floor (pos.y + 0.5),
					  floor (pos.z + 0.5))
	-- 3d Manhattan distance of closest_node.
	n.closest = -1
	-- Visited node nearest to the target.
	n.closest_node = nil
	-- Class and penalty of this node.
	n.class = self:gwp_classify_node (context, n)
	n.penalty = context.penalties[n.class]
	return n
end

local function round_trunc (n)
	return floor (n + 0.5)
end

local function is_water_source (name)
	return name == "mcl_core:water_source"
		or name == "mclx_core:river_water_source"
end

function mob_class:gwp_align_start_pos (pos)
	local x = floor (pos.x + 0.5)
	local y = floor (pos.y + 1.0) -- Deal with soul sand and slabs.
	local z = floor (pos.z + 0.5)
	return vector.new (x, y, z)
end

function mob_class:gwp_start_1 (context)
	local pos = self.object:get_pos ()
	-- It is possible for mobs to turn around during a repath if
	-- the start position returned is inconsistent with that of
	-- the last waypoint reached, for this will frequently produce
	-- a path containing the new start position, followed by that
	-- of the previous waypoint, while gwp_next_waypoint is only
	-- capable of eliminating one overrun waypoint at a time.
	local last_wp = self._last_wp
	if last_wp
		and math.abs (pos.x - last_wp.x) < 0.5
		and math.abs (pos.z - last_wp.z) < 0.5
		and math.abs (pos.y - last_wp.y) < 1.0 then
		pos.x = last_wp.x - last_wp.x_offset
		pos.y = last_wp.y - last_wp.y_offset
		pos.z = last_wp.z - last_wp.x_offset
	else
		pos = self:gwp_align_start_pos (pos)
	end
	local node = core.get_node (pos)
	local ground = core.get_node (vector.offset (pos, 0, -1, 0))

	-- If standing in water...
	if is_water_source (node.name) then
		if self.floats == 1
			and is_water_source (ground.name) then
			local nextnode = core.get_node (pos)
			-- Find the first water source beneath a
			-- non-source block.
			while is_water_source (nextnode.name) do
				pos.y = pos.y + 1
				nextnode = core.get_node (pos)
			end
			pos.y = pos.y - 1
			return pos, false
		end
	elseif self._moveresult and self._moveresult.touching_ground then
		-- If touching ground, return the position of the node
		-- at the center of this mob, which will prompt
		-- gwp_start to return a position derived from one of
		-- the corners of the bounding box if the mob is stuck
		-- with its center over the edge of a long drop.
		return pos, false
	else
		local class = self:gwp_classify_node (context, pos)
		if class ~= "OPEN" and context.penalties[class] >= 0.0 then
			return pos, false
		end
	end
	local target_y = pos.y - 128

	while pos.y > target_y do
		local class = self:gwp_classify_node (context, pos)
		if class ~= "OPEN" and context.penalties[class] >= 0.0 then
			return pos, true
		end
		pos.y = pos.y - 1
	end

	return nil, false
end

local function is_passable (class, penalties, startpos, context, mob)
	if (class ~= "OPEN" and penalties[class] >= 0.0) then
		return startpos
	end
	return nil
end

local function is_stuck (class, penalties, startpos, context, mob)
	if class == "BLOCKED"
		or class == "LAVA"
		or class == "FENCE"
		or class == "SLAB"
		or class == "DOOR_WOOD_CLOSED"
		or class == "DOOR_IRON_CLOSED" then
		return startpos
	end
	return nil
end

local function is_walkable (class, penalties, startpos, context, mob)
	if class == "WALKABLE" then
		return startpos
	end
	return nil
end

local function is_open_valid_fall (class, penalties, startpos, context, mob)
	if class == "OPEN" then
		local pos = mob:gwp_essay_drop (context, startpos)
		return pos and vector.copy (pos)
	end
	return nil
end

function mob_class:gwp_start_2 (context, cbox, self_pos, criteria)
	local c1, c2, c3, c4, class, output_pos
	local penalties = context.penalties
	local pos = self_pos
	c1 = vector.new (pos.x + cbox[1], pos.y, pos.z + cbox[3])
	c1 = self:gwp_align_start_pos (c1)
	class = self:gwp_classify_node (context, c1)
	output_pos = criteria (class, penalties, c1, context, self)
	if output_pos then
		return output_pos
	end
	c2 = vector.new (pos.x + cbox[1], pos.y, pos.z + cbox[6])
	c2 = self:gwp_align_start_pos (c2)
	class = self:gwp_classify_node (context, c2)
	output_pos = criteria (class, penalties, c2, context, self)
	if output_pos then
		return output_pos
	end
	c3 = vector.new (pos.x + cbox[4], pos.y, pos.z + cbox[3])
	c3 = self:gwp_align_start_pos (c3)
	class = self:gwp_classify_node (context, c3)
	output_pos = criteria (class, penalties, c3, context, self)
	if output_pos then
		return output_pos
	end
	c4 = vector.new (pos.x + cbox[4], pos.y, pos.z + cbox[6])
	c4 = self:gwp_align_start_pos (c4)
	class = self:gwp_classify_node (context, c4)
	output_pos = criteria (class, penalties, c4, context, self)
	if output_pos then
		return output_pos
	end
	return nil
end

function mob_class:gwp_corner_check_1 (context, self_pos, penalties)
	local nearest = {}
	local center = self:gwp_align_start_pos (self_pos)
	for x = -1, 1 do
		for z = -1, 1 do
			if x ~= 0 or z ~= 0 then
				local test = vector.offset (center, x, 0, z)
				table.insert (nearest, test)
			end
		end
	end
	table.sort (nearest, function (a, b)
		    return vector.distance (a, self_pos)
			    < vector.distance (b, self_pos)
	end)
	for i = 1, 3 do
		local node = nearest[i]
		local class = self:gwp_classify_node (context, node)
		local pos = is_walkable (class, penalties, node, context, self)
		if not pos then
			pos = is_open_valid_fall (class, penalties, node, context, self)
		end
		if pos then
			return pos
		end
	end
end

function mob_class:gwp_corner_check (context, cbox, pos, self_pos, penalties)
	local corner
		= self:gwp_start_2 (context, cbox, pos, is_open_valid_fall)
	if corner then
		return corner
	end

	if context.mob_width == 1 then
		return self:gwp_corner_check_1 (context, self_pos, penalties)
	end
	return nil
end

local function vertical_collision_encountered_p (moveresult, pos)
	for _, collision in ipairs (moveresult.collisions) do
		if collision.type == "node"
			and collision.axis == "y"
			and (collision.new_velocity.y
			     - collision.old_velocity.y) >= 0
			and vector.equals (collision.node_pos, pos) then
			return true
		end
	end
	return false
end

function mob_class:gwp_start (context)
	local pos, optional = self:gwp_start_1 (context)
	local penalties = context.penalties
	local cbox = self.collisionbox
	local start_class = nil
	if pos then
		start_class = self:gwp_classify_node (context, pos)
		-- Check for valid start positions at every block on
		-- which this mob is standing.
		if start_class ~= "OPEN" and penalties[start_class] >= 0.0 then
			-- `optional' indicates that the selected POS
			-- is sub-optimal and should be overridden by
			-- any other walkable node contacting this
			-- mob's bounding box.
			if optional then
				local self_pos = self.object:get_pos ()
				local optimal
					= self:gwp_start_2 (context, cbox, self_pos,
							is_walkable)
				return optimal or pos
			end
			return pos
		end
	end
	local self_pos = self.object:get_pos ()
	local pos1 = self:gwp_start_2 (context, cbox, self_pos, is_passable)
	if pos1 then
		return pos1
	end

	-- If this mob is supported by a suspended carpet or analogous
	-- node which is too thin to be classified as a valid surface
	-- but which is still capable of supporting objects, accept
	-- the initial position as-is.
	local moveresult = self._moveresult
	if moveresult and moveresult.touching_ground
		and start_class == "OPEN"
		and vertical_collision_encountered_p (moveresult, pos) then
		return pos
	end

	-- If this mob is stuck inside a fence-like node (by which it
	-- is meant any node narrower than a full node) placed upon a
	-- ledge, attempt to locate a corner that is aloft.  If no
	-- such corner is available, evaluate the six corners
	-- surrounding the fence and attempt to exit from the corner
	-- nearest to the fence.

	if not optional and start_class and start_class ~= "OPEN" then
		local corner = self:gwp_corner_check (context, cbox, pos,
						self_pos, penalties)
		if corner then
			return corner
		end
	end

	-- As a final attempt, try to exit any solid node in which
	-- this mob is stuck.
	return self:gwp_start_2 (context, cbox, self_pos, is_stuck)
end

local function manhattan3d (ax, ay, az, bx, by, bz)
	return math.abs (ax - bx) + math.abs (az - bz) + math.abs (ay - by)
end

local function d (node1, node2)
	return vector.distance (node1, node2)
end

local function h_to_nearest_target (node, context)
	local best_distance
	for _, target in ipairs (context.targets) do
		local d = manhattan3d (node.x, node.y, node.z,
				       target.x, target.y, target.z)
		if not best_distance or d < best_distance then
			best_distance = d
		end

		-- Save the nearest node into the target for use in
		-- reconstruction of partial paths.
		if not target.best_distance or target.best_distance > d then
			target.best_distance = d
			target.best_node = node
		end
	end
	assert (best_distance)
	return best_distance
end

function mob_class:gwp_limit_range (range)
	-- This limit is decided by the values `hashpos' is capable of
	-- handling.
	local range = range or self.tracking_distance
	return math.min (range, 127)
end

function mob_class:gwp_initialize (targets, range, tolerance, penalties)
	local context = self:new_gwp_context ()

	-- Compute pathfinding bounds.
	local pos = vector.apply (self.object:get_pos (), round_trunc)
	local range = self:gwp_limit_range (range)
	context.range = range
	context.minpos = vector.new (pos.x - range, pos.y - range,
				     pos.z - range)
	context.maxpos = vector.new (pos.x + range, pos.y + range,
				     pos.z + range)
	context.tolerance = tolerance or context.tolerance
	context.penalties = penalties or self.gwp_penalties

	-- Establish a limit on the distance of routes and on the
	-- number of nodes examined.
	context.maxdist = range
	context.maxnodes = floor (range * 16)

	-- Return positions touching the surfaces of the nodes below.
	context.y_offset = -0.5

	-- Calculate entity dimensions.
	local collisionbox = self.collisionbox
	local width = math.max (0, collisionbox[4] - collisionbox[1])
	local height = math.max (0, collisionbox[5] - collisionbox[2])
	local length = math.max (0, collisionbox[6] - collisionbox[3])
	context.mob_width = floor (math.max (width, length) + 1.0)
	context.mob_height = math.ceil (height)

	-- Map target positions to acceptable nodes.
	for _, pos in ipairs (targets) do
		local t = self:gwp_target_pos (context, pos)
		if t then
			table.insert (context.targets, t)
		end
	end

	-- Save information that may be accessed in deriving a start
	-- position.
	context.fall_distance = self:gwp_safe_fall_distance ()

	-- Derive a valid start position if suspended in water or the
	-- like.
	local start = self:gwp_start (context)
	if not start or not vector.in_area (start, context.minpos,
					context.maxpos) then
		return nil
	end

	-- Construct initial open set and initialize context for first
	-- cycle.
	start = self:get_gwp_node (context, start.x, start.y, start.z)
	start.class = self:gwp_classify_node (context, start)
	start.g = 0
	start.h = h_to_nearest_target (start, context)
	start.total_d = 0
	context.open_set:enqueue (start, start.h)
	return context
end

local BASE_FALL_DISTANCE = 3

function mob_class:gwp_safe_fall_distance ()
	local bonus = 0
	if self.attack then
		-- Derive this distance from difficulty and remaining
		-- health.  get_properties produces too much garbage.
		local props = self.initial_properties
		local sacrifice = self.health - props.hp_max * 0.33

		-- Be willing to sacrifice more health in pursuit of a
		-- target as difficulty increases.
		sacrifice = sacrifice - (3 - mcl_vars.difficulty) * 4
		bonus = math.max (0, sacrifice)
	end
	return BASE_FALL_DISTANCE + bonus
end

local get_us_time = core.get_us_time

function mob_class:gwp_cycle (context, timeout)
	local time = get_us_time ()
	local set = context.open_set
	local clock
	local n_total = context.total_nodes
	local maxnodes = context.maxnodes

	-- Convert this timeout to us.
	timeout = math.round (timeout * 1e6)
	context.fall_distance = self:gwp_safe_fall_distance ()
	repeat
		if set:empty () or n_total + 1 > maxnodes then
			local time = get_us_time () - time
			context.time_elapsed = context.time_elapsed + time
			context.total_nodes = n_total
			return true, time / 1e6
		end

		local node = set:dequeue ()
		node.covered = true
		n_total = n_total + 1

		-- Evaluate this node...does it constitute an arrival
		-- at any target?
		for _, target in ipairs (context.targets) do
			if manhattan3d (node.x, node.y, node.z,
					target.x, target.y, target.z)
				<= context.tolerance then
				table.insert (context.arrivals, target)
			end
		end
		if #context.arrivals >= 1 then
			local time = get_us_time () - time
			context.time_elapsed = context.time_elapsed + time
			context.total_nodes = n_total
			return true, time / 1e6
		end

		-- Enter each neighbor into the queue.
		local neighbors = self:gwp_edges (context, node)
		for _, neighbor in ipairs (neighbors) do
			if not neighbor.covered then
				-- What is the distance from hence to this
				-- neighbor?
				local dist = d (node, neighbor)
				neighbor.total_d = node.total_d + dist
				if dist <= context.range
					and neighbor.total_d < context.maxdist then
					local new_g = node.g + dist + neighbor.penalty
					local new_h = h_to_nearest_target (neighbor, context) * 1.5 -- Minecraft value.
					if set:contains (neighbor) then
						-- Re-enqueue this neighbor if this
						-- path to it is shorter.
						if new_g < neighbor.g then
							neighbor.g = new_g
							neighbor.h = new_h
							neighbor.referrer = node
							set:update (neighbor, new_g + new_h)
						end
					else
						-- N.B. in this branch neighbor.g and
						-- .h might not yet have been
						-- computed.
						neighbor.g = new_g
						neighbor.h = new_h
						neighbor.referrer = node
						set:enqueue (neighbor, new_g + new_h)
					end
				end
			end
		end
		clock = get_us_time ()
	until clock - time >= timeout
	context.time_elapsed = context.time_elapsed + (clock - time)
	context.total_nodes = n_total
	return false, (clock - time) / 1e6
end

function mob_class:gwp_reconstruct_path (context, arrival)
	local list = {arrival}
	-- Adjust waypoint position so as to center the mob on
	-- the path.
	local x_offset = context.mob_width * 0.5 - 0.5
	local y_offset = context.y_offset
	arrival.x = arrival.x + x_offset
	arrival.z = arrival.z + x_offset
	arrival.y = arrival.y + y_offset
	arrival.x_offset = x_offset
	arrival.y_offset = y_offset
	while arrival.referrer ~= nil do
		table.insert (list, arrival.referrer)
		arrival = arrival.referrer
		-- Adjust waypoint position so as to center the mob on
		-- the path.
		arrival.x = arrival.x + x_offset
		arrival.z = arrival.z + x_offset
		arrival.y = arrival.y + y_offset
		arrival.x_offset = x_offset
		arrival.y_offset = y_offset
	end
	return list
end

function mob_class:gwp_reconstruct (context, real_dest)
	local path, partial
	if #context.arrivals > 0 then
		-- Return the path traversing the fewest nodes.
		for _, arrival in ipairs (context.arrivals) do
			local candidate
			local contact = arrival.best_node

			-- If real_dest is set, replace the best node
			-- with it.  This facility is only exercised
			-- by the Ender Dragon.
			if real_dest and contact then
				real_dest.referrer = contact
				contact = real_dest
			end

			if contact then
				candidate = self:gwp_reconstruct_path (context, contact)
				candidate.target = arrival
				if not path or #candidate > #path then
					path = candidate
					partial = false
				end
			end
		end
	else
		-- Generate a list of paths to nodes nearest their respective
		-- targets, and select that crossing the fewest nodes.
		local path_dist
		for _, target in ipairs (context.targets) do
			local candidate

			if target.best_node then
				candidate = self:gwp_reconstruct_path (context, target.best_node)
				local dist = d (target.best_node, target)
				if not path or dist >= path_dist and #candidate > #path then
					path = candidate
					path_dist = dist
					partial = true
				end
			end
		end
	end
	return path, partial
end

function mob_class:bench_pathing (iterations)
	local self_pos = self.object:get_pos ()
	local self_pos = self:gwp_align_start_pos (self_pos)
	local time = 0
	for i = 1, iterations do
		local x = math.random (-40, 40)
		local y = math.random (-40, 40)
		local z = math.random (-40, 40)
		local context = self:gwp_initialize ({
			vector.offset (self_pos, x, y, z),
		}, 48.0, 0.0)
		local _, dtime = self:gwp_cycle (context, math.huge)
		time = time + dtime
	end
	return time, time / iterations
end

------------------------------------------------------------------------------
--- Graph edge generation.  It is expected that different versions of
--- these functions will be provided by mobs according to how they
--- move.
------------------------------------------------------------------------------

local nodes_this_step = {}
local get_node_raw = mcl_mobs.get_node_raw

local function gwp_nodevalue_to_name (nodevalue)
	if get_node_raw then
		return core.get_name_from_content_id (nodevalue)
	else
		return nodevalue
	end
end

local function gwp_name_to_nodevalue (name)
	if get_node_raw then
		return core.get_content_id (name)
	else
		return name
	end
end

mcl_mobs.gwp_nodevalue_to_name = gwp_nodevalue_to_name
mcl_mobs.gwp_name_to_nodevalue = gwp_name_to_nodevalue

local function gwp_get_node (pos)
	local x, y, z = pos.x, pos.y, pos.z
	local hash = longhash (x, y, z)
	local map = nodes_this_step
	local cache = map[hash]

	if cache then
		return cache
	end

	if get_node_raw then
		cache = get_node_raw (x, y, z)
		map[hash] = cache
	else
		cache = core.get_node (pos).name
		map[hash] = cache
	end
	return cache
end

local levelgen_enabled = mcl_levelgen.levelgen_enabled
local conv_pos_dimension = mcl_levelgen.conv_pos_dimension
local is_regeneration_possible
	= mcl_levelgen.is_regeneration_possible

local function gwp_node_regeneration_possible_p (door_node)
	if not levelgen_enabled then
		return false
	end

	local x, y, z, dim = conv_pos_dimension (door_node)
	return is_regeneration_possible (dim, x, y, z)
end

mcl_mobs.gwp_get_node = gwp_get_node

local ground_height_scratch = vector.zero ()
local gwp_fixed_ground_height = {}

local function ground_height (context, node)
	local below = ground_height_scratch
	below.x = node.x
	below.y = node.y - 1
	below.z = node.z

	local nodevalue = gwp_get_node (below)
	local fixed = gwp_fixed_ground_height[nodevalue]
	if fixed then
		return fixed + below.y
	else
		local boxes = core.get_node_boxes ("collision_box", below)
		local y = 0

		for _, box in ipairs (boxes) do
			local max = math.max (box[2], box[5])
			if y < max then
				y = max
			end
		end

		local value = below.y + y
		return value
	end
end

local gwp_ej_scratch = vector.zero ()
local gwp_parent_penalty = nil

local GWP_JUMP_HEIGHT = 1.125

function mob_class:gwp_essay_jump (context, target, parent, floor)
	local class = self:gwp_classify_node (context, target)
	local penalty = context.penalties[class]

	-- Classify the block above the parent's position, unless
	-- already classified.
	if gwp_parent_penalty == nil then
		gwp_ej_scratch.x = parent.x
		gwp_ej_scratch.y = parent.y + 1
		gwp_ej_scratch.z = parent.z
		local jump = self:gwp_classify_node (context, gwp_ej_scratch)
		local penalty = context.penalties[jump]
		gwp_parent_penalty = penalty
	end

	-- And make sure it both the target and the parent are
	-- navigable.
	if penalty < 0.0 or gwp_parent_penalty < 0.0 then
		return nil
	end
	-- Return true if this node is walkable or water.
	if class ~= "OPEN" or (self.floats == 0 and class == "WATER") then
		-- But first, verify that the node is not too far
		-- above the current node.
		local this_floor = ground_height (context, target)
		if this_floor - floor > GWP_JUMP_HEIGHT then
			return nil
		end
		local node = self:get_gwp_node (context, target.x, target.y,
						target.z)
		node.class = class
		node.penalty = math.max (node.penalty, penalty)
		return node
	end
	return nil
end

local gwp_ed_scratch = vector.zero ()

function mob_class:gwp_essay_drop (context, node)
	local fall_distance = context.fall_distance
	local lim = node.y - fall_distance
	local target = gwp_ed_scratch

	target.x = node.x
	target.y = node.y
	target.z = node.z
	repeat
		target.y = target.y - 1
		local class = self:gwp_classify_node (context, target)
		if class ~= "OPEN" then
			-- Walkable?
			local penalty = context.penalties[class]
			if penalty < 0 then
				return nil
			end
			local node = self:get_gwp_node (context, target.x, target.y, target.z)
			node.penalty = math.max (penalty, node.penalty)
			node.class = class
			return node
		end
	until target.y < lim
	return nil
end

local gwp_edd_scratch = vector.zero ()

-- Try to descend from the second (or higher) block of a wooden door.
-- This is necessary for the reason that doors will otherwise always
-- be considered equivalent to walkable surfaces.

function mob_class:gwp_essay_descend_door (context, object)
	local fall_distance = context.fall_distance
	local lim = object.y - fall_distance
	local target = gwp_edd_scratch
	local last_class, class

	target.x = object.x
	target.y = object.y
	target.z = object.z
	repeat
		target.y = target.y - 1
		last_class = class
		class = self:gwp_classify_node (context, target)
		if class ~= "DOOR_WOOD_CLOSED" and class ~= "DOOR_OPEN" then
			if not last_class then
				-- No need to descend; reuse the input
				-- object.
				return object
			else
				local penalty = context.penalties[last_class]
				if penalty < 0 then
					return nil
				end
				local node = self:get_gwp_node (context, target.x,
								target.y + 1, target.z)
				node.penalty = math.max (penalty, node.penalty)
				node.class = class
				return node
			end
		end
	until target.y < lim

	-- It's doors all the way down.
	return nil
end

local MAX_WATER_DROP = 64

function mob_class:gwp_essay_drift (context, target, object)
	local fall_distance = MAX_WATER_DROP
	local lim = target.y - fall_distance
	local last = object and object.class
	while target.y >= lim do
		local class = self:gwp_classify_node (context, target)
		if class ~= "WATER" then
			if not last then
				return nil
			end
			local penalty = context.penalties[last]
			if penalty < 0 then
				return nil
			end
			local node = self:get_gwp_node (context, target.x,
							target.y + 1, target.z)
			node.penalty = math.max (penalty, node.penalty)
			node.class = last
			return node
		end
		last = class
		target.y = target.y - 1
	end
	return nil
end

local gwp_edges_1_scratch = vector.zero ()

local function gwp_edges_1 (self, context, parent, floor, xoff, zoff, jump, amphibious)
	local node = gwp_edges_1_scratch
	node.x = parent.x + xoff
	node.y = parent.y
	node.z = parent.z + zoff
	if not vector.in_area (node, context.minpos, context.maxpos) then
		return nil
	end
	local ground = ground_height (context, node)

	-- Can this mob climb from PARENT to this node on the same
	-- level without jumping?
	if ground - floor > self._initial_step_height then
		return nil
	else
		local class = self:gwp_classify_node (context, node)
		local penalty = context.penalties[class]
		local object

		-- Is the node traversable?  Return fences though they
		-- are not, as they are needed to validate diagonal
		-- movements.
		if penalty >= 0.0 or class == "FENCE" then
			object = self:get_gwp_node (context, node.x, node.y, node.z)
			object.class = class
			if penalty < 0 then
				object.penalty = penalty
			else
				object.penalty = math.max (penalty, object.penalty)
			end
		end

		-- Is the node unusable?
		if class ~= "WALKABLE" and (not amphibious or class ~= "WATER") then
			-- Should there be an attempt to jump onto
			-- this node?
			if class == "OPEN" then
				object = self:gwp_essay_drop (context, node)
				-- This explicitly excludes trapdoors
				-- and suchlike from consideration.
			elseif class == "BLOCKED" or class == "SLAB" then
				node.y = node.y + 1
				object = self:gwp_essay_jump (context, node, parent, floor)
			elseif (class == "WATER" and self.floats == 0) then
				object = self:gwp_essay_drift (context, node, object)
			elseif (penalty >= 0.0 and (class == "DOOR_WOOD_CLOSED"
						    or class == "DOOR_OPEN")) then
				object = self:gwp_essay_descend_door (context, object)
			-- Any test for `IGNORE' here would simply be
			-- redundant, as it is always assigned a
			-- penalty of -1.
			-- elseif class == "IGNORE" then
			-- 	object = nil
			end
		end
		return object
	end
end

mob_class.gwp_penalties = {
	-- A penalty < 0 indicates unconditional rejection, while one
	-- greater than zero compounds the heuristic distance.
	BLOCKED = -1.0,
	LEAVES = -1.0,
	SLAB = -1.0,
	DAMAGE_FIRE = 16.0,
	DAMAGE_OTHER = -1.0,
	DANGER_FIRE = 8.0,
	DANGER_OTHER = 8.0,
	DOOR_IRON_CLOSED = -1.0,
	DOOR_OPEN = 0.0,
	DOOR_WOOD_CLOSED = -1.0,
	FENCE = -1.0,
	IGNORE = -1.0,
	LAVA = -1.0,
	OPEN = 0.0,
	TRAPDOOR = 0.0,
	WALKABLE = 0.0,
	WATER = 8.0,
}

mob_class.gwp_floortypes = {
	OPEN = "OPEN",
	WATER = "OPEN",
	LAVA = "OPEN",
	DAMAGE_FIRE = "DAMAGE_FIRE",
	DAMAGE_OTHER = "DAMAGE_OTHER",
	IGNORE = "IGNORE",
}

local half_cube = mcl_util.decompose_AABBs ({
	{
		-0.25, -0.25, -0.25,
		0.25, 0.25, 0.25,
	},
})

local function get_partial_type (name, nodedef)
	if nodedef.groups.pathfinder_partial == 3 then
		return "SLAB"
	elseif nodedef.groups.pathfinder_partial == 2 then
		return "BLOCKED"
	elseif nodedef.groups.pathfinder_partial == 1 then
		return "OPEN"
	end

	local boxes = nodedef.collision_box or nodedef.node_box

	-- Return whether the node is the default cube.
	if not boxes or boxes.type == "regular" then
		return "BLOCKED"
	elseif boxes.type == "fixed" or boxes.type == "connected" then
		-- ALways read from the default box.
		local fixed = boxes.fixed

		if type (fixed[1]) == "number" then
			fixed = {fixed}
		end
		local shape = mcl_util.decompose_AABBs (fixed)
		if not shape then
			error (name .. "'s collision box is too complex to be evaluated by the pathfinder")
		end
		-- The assumption is that any node whose cbox
		-- intersects with a centered half cube obstructs mob
		-- movement.
		if shape:intersect_p (half_cube) then
			return "BLOCKED"
		end
	elseif boxes.type == "leveled" or boxes.type == "wallmounted" then
		return "BLOCKED"
	end

	return "OPEN"
end

-- local record_pathfinding_stats = true
-- local bc_stats = { }

local gwp_basic_node_classes = {}

mcl_mobs.gwp_basic_node_classes = gwp_basic_node_classes
mcl_mobs.gwp_fixed_ground_height = gwp_fixed_ground_height

if get_node_raw then
	gwp_basic_node_classes[65536] = nil
	gwp_fixed_ground_height[65536] = nil
end

local gwp_door_classes = {}

local function gwp_compute_fixed_ground_height (def)
	-- Treat non-walkable nodes as identical to air, although this
	-- is far from their true bounding boxes, to avoid certain
	-- inconsistencies.
	if not def.walkable then
		return 0.5
	end
	if def.paramtype2 == "color"
		or def.paramtype2 == "none" then
		local node_box = def.collision_box
			or def.node_box
			or {type = "regular"}
		if node_box.type == "regular" then
			return 0.5
		elseif node_box.type == "fixed" then
			local tallest = nil
			if type (node_box.fixed[1]) == "number" then
				tallest = node_box.fixed[5]
			else
				for _, box in pairs (node_box.fixed) do
					if tallest then
						tallest = math.max (tallest, box[5])
					else
						tallest = box[5]
					end
				end
			end
			return tallest
		end
	end
	return nil
end

-- Pre-compute node classes for efficiency.  Beware that
-- DOOR_IRON_CLOSED and DOOR_WOOD_CLOSED must still be processed
-- specially to establish whether doors are open.

core.register_on_mods_loaded (function ()
	for name, def in pairs (core.registered_nodes) do
		local value = "OPEN"
		local key = gwp_name_to_nodevalue (name)

		if def._pathfinding_class then
			value = def._pathfinding_class
		elseif def.damage_per_second ~= 0 then
			value = "DAMAGE_OTHER"
		elseif core.get_item_group (name, "door") > 0 then
			value = nil
			if core.get_item_group (name, "door_iron") > 0 then
				gwp_door_classes[key] = "DOOR_IRON_CLOSED"
			else
				gwp_door_classes[key] = "DOOR_WOOD_CLOSED"
			end
		elseif core.get_item_group (name, "leaves") > 0 then
			value = "LEAVES"
		elseif def.walkable then
			value = get_partial_type (name, def)
		end
		gwp_fixed_ground_height[key]
			= gwp_compute_fixed_ground_height (def)
		gwp_basic_node_classes[key] = value
	end
end)

local function gwp_basic_classify (pos)
	local nodevalue = gwp_get_node (pos)
	local value

	-- Minecraft assigns blocks to one of these classes:
	-- (See: https://nekoyue.github.io/ForgeJavaDocs-NG/javadoc/1.12.2/net/minecraft/pathfinding/PathNodeType.html)
	-- BLOCKED
	-- DAMAGE_CACTUS (not necessary in Mineclonia)
	-- DAMAGE_FIRE
	-- DAMAGE_OTHER
	-- DANGER_CACTUS (not necessary in Mineclonia)
	-- DANGER_FIRE
	-- DANGER_OTHER
	-- DOOR_IRON_CLOSED
	-- DOOR_OPEN
	-- DOOR_WOOD_CLOSED
	-- FENCE
	-- LAVA
	-- OPEN
	-- RAIL (not necessary in Mineclonia)
	-- TRAPDOOR
	-- WALKABLE
	-- WATER
	--
	-- Danger-inflicting nodes are penalized in the pathfinding
	-- process but not categorically avoided.
	-- Damage-inflicting nodes are penalized more, and
	-- encompass LAVA and the like.
	-- If a hazardous node adjoins a node, the latter will be
	-- classified as damage-inflicting.

	value = gwp_basic_node_classes[nodevalue]

	-- A value of nil indicates a door whose state must be
	-- checked.
	if not value then
		if mcl_doors.is_open (pos) then
			value = "DOOR_OPEN"
		else
			value = gwp_door_classes[nodevalue]
			if not value then
				value = "IGNORE" -- Unknown nodes.
			end
		end
	end
	-- if record_pathfinding_stats then
	-- 	bc_stats[value] = (bc_stats[value] or 0) + 1
	-- end
	return value
end
mcl_mobs.gwp_basic_classify = gwp_basic_classify

local gwp_classify_node_1_scratch = vector.zero ()

local function gwp_classify_node_1 (self, pos)
	local class_1 = gwp_basic_classify (pos)

	-- If this block (the block in which the mob stands) is air,
	-- evaluate the node below.
	if class_1 == "OPEN" then
		-- Don't cons a new vector.
		local pos_2 = gwp_classify_node_1_scratch
		pos_2.x = pos.x
		pos_2.y = pos.y - 1
		pos_2.z = pos.z
		local class_2 = gwp_basic_classify (pos_2)
		local floortype = self.gwp_floortypes[class_2]

		if floortype == "OPEN" then
			-- An OPEN node resting on an OPEN surface
			-- above a FENCE should be reset to WALKABLE,
			-- as the collision box of the FENCE will
			-- extend into the node above, becoming
			-- something of a slab.
			pos_2.y = pos_2.y - 1
			local class_3 = gwp_basic_classify (pos_2)
			if class_3 == "FENCE" then
				floortype = "WALKABLE"
			end
		end

		-- Otherwise, this is walkable.  Adjust its
		-- class according to its surroundings.
		return floortype
			or self:gwp_classify_surroundings (pos, "WALKABLE")
	end
	return class_1
end

mcl_mobs.gwp_classify_node_1 = gwp_classify_node_1

-- Evaluate the approximate traversability of nodes that would contact
-- this mob at POS, examining them, and if open, the node(s) beneath
-- them.

local gwp_classify_node_scratch = vector.zero ()
-- local gwp_cc_hits, gwp_cc_misses = 0, 0

function mob_class:gwp_classify_node (context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	-- This is very expensive, as core.get_node conses too
	-- much.
	if cache then
		-- if record_pathfinding_stats then
		-- 	gwp_cc_hits = gwp_cc_hits + 1
		-- end
		return cache
	end
	-- if record_pathfinding_stats then
	-- 	gwp_cc_misses = gwp_cc_misses + 1
	-- end

	local sx, sy, sz = pos.x, pos.y, pos.z
	local worst, penalty = "OPEN", 0.0
	local vector = gwp_classify_node_scratch
	local b_width, b_height
	local penalties = context.penalties

	b_width = context.mob_width - 1
	b_height = context.mob_height - 1

	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z
				local class = gwp_classify_node_1 (self, vector)
				-- Report impassible nodes
				-- immediately.
				if penalties[class] < 0.0 then
					worst = class
					context.class_cache[hash] = worst
					return worst
				-- Otherwise select the worst class possible.
				elseif worst == "OPEN" or penalty < penalties[class] then
					penalty = penalties[class]
					worst = class
				end
			end
		end
	end
	context.class_cache[hash] = worst
	return worst
end

function mob_class:gwp_classify_for_movement (pos)
	local sx, sy, sz = pos.x, pos.y, pos.z
	local worst, penalty = "OPEN", 0.0
	local vector = gwp_classify_node_scratch
	local b_width, b_height
	local penalties = self.gwp_penalties
	local collisionbox = self.collisionbox
	local width = math.max (0, collisionbox[4] - collisionbox[1])
	local height = math.max (0, collisionbox[5] - collisionbox[2])
	local length = math.max (0, collisionbox[6] - collisionbox[3])

	b_width = floor (math.max (width, length) + 1.0) - 1
	b_height = math.ceil (height) - 1

	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z
				local class = gwp_classify_node_1 (self, vector)
				-- Report impassible nodes
				-- immediately.
				if penalties[class] < 0.0 then
					return class
				-- Otherwise select the worst class possible.
				elseif worst == "OPEN" or penalty < penalties[class] then
					penalty = penalties[class]
					worst = class
				end
			end
		end
	end
	return worst
end

local gwp_classify_surroundings_scratch = vector.zero ()

local gwp_influence_by_type = {
	DAMAGE_FIRE = "DANGER_FIRE",
	LAVA = "DANGER_FIRE",
	DAMAGE_OTHER = "DANGER_OTHER",
}

function mob_class:gwp_classify_surroundings (pos, default)
	local x, y, z = pos.x, pos.y, pos.z
	local v = gwp_classify_surroundings_scratch
	local influences = gwp_influence_by_type

	v.x = x + -1
	v.y = y + -1
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + -1
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + -1
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + 0
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + 0
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + 1
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + -1
	v.y = y + 1
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 0
	v.y = y + -1
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 0
	v.y = y + -1
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
		-- Nodes above fences should be regarded as slabs, as
		-- their collision boxes extend into nodes above.
	elseif new == "FENCE" then
		return "BLOCKED"
	end

	v.x = x + 0
	v.y = y + 0
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 0
	v.y = y + 0
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 0
	v.y = y + 1
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 0
	v.y = y + 1
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + -1
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + -1
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + 0
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + 0
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + 1
	v.z = z + -1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + 1
	v.z = z + 0
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	v.x = x + 1
	v.y = y + 1
	v.z = z + 1
	local new = gwp_basic_classify (v)
	local influence = influences[new]
	if influence then
		return influence
	end

	-- Otherwise the node is walkable.
	return default
end

function mob_class:gwp_check_diagonal (node, flanking1, flanking2)
	-- flanking1 and flanking2 are to be the two nodes flanking
	-- the path from NODE to the target.

	-- Reject movements over nonexistent flanking nodes or those
	-- taller than the origin.
	if not flanking1 or not flanking2
		or flanking1.y > node.y or flanking2.y > node.y then
		return false
	-- Reject open doors, which obstruct diagonal movement.
	elseif flanking2.class == "DOOR_OPEN"
		or flanking1.class == "DOOR_OPEN" then
		return false
	-- Special treatment for movements flanked by fences on both
	-- sides being performed by mobs smaller than half a block in
	-- width.
	elseif flanking2.class == "FENCE" and flanking1.class == "FENCE"
		and self.collisionbox[4] - self.collisionbox[1] <= 0.6 then
		return true
	end
	local f1_valid = flanking1.penalty >= 0 or flanking1.y < node.y
	local f2_valid = flanking2.penalty >= 0 or flanking2.y < node.y
	return f1_valid and f2_valid
end

local gwp_check_diagonal_1_scratch = {}

function mob_class:gwp_check_diagonal_1 (context, d, flanking1, flanking2, y)
	if d.y <= y then
		return d.penalty >= 0.0
	elseif d.penalty >= 0.0 then
		-- Reject a diagonal jump if the jump would be
		-- obstructed if performed from either of the flanking
		-- nodes.
		local node = gwp_check_diagonal_1_scratch
		local penalties = context.penalties

		node.x = flanking1.x
		node.y = y + 1
		node.z = flanking1.z
		local class_1 = self:gwp_classify_node (context, node)
		if penalties[class_1] >= 0.0 then
			node.x = flanking2.x
			node.z = flanking2.z
			local class_2 = self:gwp_classify_node (context, node)
			return penalties[class_2] >= 0.0
		end
	end
	return false
end

local gwp_edges_scratch = {}

function mob_class:gwp_edges (context, node)
	local array, c1, c2, c3, c4 = gwp_edges_scratch
	local floor = ground_height (context, node)
	local n = 0
	gwp_parent_penalty = nil

	-- Consider neighbors in the four cardinal directions.
	c1 = gwp_edges_1 (self, context, node, floor, 1, 0)
	if c1 and c1.penalty >= 0.0 then n = n + 1; array[n] = c1 end
	c2 = gwp_edges_1 (self, context, node, floor, 0, 1)
	if c2 and c2.penalty >= 0.0 then n = n + 1; array[n] = c2 end
	c3 = gwp_edges_1 (self, context, node, floor, -1, 0)
	if c3 and c3.penalty >= 0.0 then n = n + 1; array[n] = c3 end
	c4 = gwp_edges_1 (self, context, node, floor, 0, -1)
	if c4 and c4.penalty >= 0.0 then n = n + 1; array[n] = c4 end

	-- Consider diagonal neighbors at an angle.
	local y = node.y
	if self:gwp_check_diagonal (node, c1, c2) then
		local d = gwp_edges_1 (self, context, node, floor, 1, 1)
		if d and self:gwp_check_diagonal_1 (context, d, c1, c2, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c1, c4) then
		local d = gwp_edges_1 (self, context, node, floor, 1, -1)
		if d and self:gwp_check_diagonal_1 (context, d, c1, c4, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c3, c2) then
		local d = gwp_edges_1 (self, context, node, floor, -1, 1)
		if d and self:gwp_check_diagonal_1 (context, d, c3, c2, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c3, c4) then
		local d = gwp_edges_1 (self, context, node, floor, -1, -1)
		if d and self:gwp_check_diagonal_1 (context, d, c3, c4, y) then
			n = n + 1; array[n] = d
		end
	end
	array[n + 1] = nil
	return array
end

if luajit_present then
	-- jit.off (mob_class.gwp_edges, true)
	-- jit.off (gwp_edges_1, true)
	-- jit.off (mob_class.gwp_classify_node, true)
	-- jit.off (gwp_basic_classify, true)
	-- jit.off (mob_class.gwp_essay_drop, true)
	-- jit.off (mob_class.gwp_essay_jump, true)
	jit.opt.start ("maxtrace=24000", "maxrecord=32000",
		       "minstitch=3", "maxmcode=163840",
		       "loopunroll=40", "maxside=1000")
end

----------------------------------------------------------------------------------
-- Pathfinder testing command `/mobpathfind'
--
-- Some code adopted from the devtest mod `testpathfinder', which is
-- Copyright (C) 2020 Wuzzy <Wuzzy@disroot.org>
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as published by
-- the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
----------------------------------------------------------------------------------

mcl_mobs.mobs_being_tested = {}
mcl_mobs.players_selecting_mob = {}

local blurb = "Right-click to select a mob, move to the target position, and type /mobpathfind start"
local DTIME_LIMIT = 0.15

local function create_path_particles (path, playername, delay, additive)
	for s=1, #path do
		local t
		if s == #path then
			t = "testpathfinder_waypoint_end.png"
		elseif s == 1 then
			t = "testpathfinder_waypoint_start.png"
		else
			local c = floor (((#path-s)/#path)*255)
			t = string.format("testpathfinder_waypoint.png^[multiply:#%02x%02x00", 0xFF-c, c)
		end
		core.add_particle({
				pos = path[s],
				expirationtime = delay + additive * s,
				playername = playername,
				glow = core.LIGHT_MAX,
				texture = t,
				size = 3,
		})
	end
end

local function cancel_test (mob, complete, sneaking)
	if complete then
		local player = core.get_player_by_name (complete)
		if not player then
			mob.pathfinding_context = nil
			mob.on_step = mob._old_onstep
			return
		end
		local msg = "Pathfinding completed in "
			.. (string.format ("%.2f", 1000 * mob.pathfinding_duration)) .. " ms"
		core.chat_send_player (complete, msg)

		local path = mob:gwp_reconstruct (mob.pathfinding_context)
		create_path_particles (path, complete, 5, 0.2)

		if sneaking then
			mob.waypoints = path
			mob.waypoint_age = 0
			mob.gowp_velocity = mob.movement_speed
			mob.gowp_animation = "walk"
			mob._gwp_timeout = 20
		end
	end
	mob.pathfinding_context = nil
	mob.on_step = mob._old_onstep
end

function mcl_mobs.maybe_test_pathfinding (mob, clicker)
	local name = clicker:get_player_name ()
	if mcl_mobs.players_selecting_mob[name] then
		mcl_mobs.players_selecting_mob[name] = mob.object
		core.chat_send_player (name, "Mob selected")
		mob.stupefied = true
		mob.waypoints = nil
	end
end

local cdef = {
	privs = { server = true, },
	params = "[ cancel | start | choose | classify ]",
	func = function (playername, param)
		local player = core.get_player_by_name (playername)
		local mobs = mcl_mobs.mobs_being_tested

		if param == "cancel" then
			if mobs[playername] then
				cancel_test (mobs[playername])
				mobs[playername] = nil
			end
			if mcl_mobs.players_selecting_mob[playername] then
				mcl_mobs.players_selecting_mob[playername] = nil
			end
			core.chat_send_player (playername, "Canceled")
		elseif param == "choose" then
			if mobs[playername] then
				cancel_test (mobs[playername])
				mobs[playername] = nil
			end
			core.chat_send_player (playername, blurb)
			mcl_mobs.players_selecting_mob[playername] = true
		elseif param == "start" then
			local mob = mcl_mobs.players_selecting_mob[playername]
			if mob == true or not mob or not is_valid (mob) then
				local blurb = "You must select a valid mob"
				core.chat_send_player (playername, blurb)
				return
			end
			local position = player:get_pos ()
			position = vector.apply (position, round_trunc)
			local start = mob:get_pos ()
			start = vector.apply (start, round_trunc)

			local msg = "Pathfinding from mob at "
				.. start.x .. ", " .. start.y .. ", " .. start.z .. " "
				.. "to player, at " .. position.x .. ", "
				.. position.y .. ", " .. position.z .. "..."
			core.chat_send_player (playername, msg)

			local entity = mob:get_luaentity ()
			entity.pathfinding_context = entity:gwp_initialize ({position})
			entity.pathfinding_duration = 0
			local old_step = entity.on_step
			entity._old_onstep = old_step
			entity.on_step = function (self, moveresult)
				if entity.pathfinding_context then
					local context = self.pathfinding_context
					local complete, dtime = self:gwp_cycle (context, DTIME_LIMIT)

					self.pathfinding_duration
						= self.pathfinding_duration + dtime
					if complete then
						mobs[playername] = nil
						cancel_test (self, playername)
					end
					return
				end
				return old_step (self, moveresult)
			end
		elseif param == "classify" then
			local mob = mcl_mobs.players_selecting_mob[playername]
			if mob == true or not mob or not is_valid (mob) then
				local blurb = "You must select a valid mob"
				core.chat_send_player (playername, blurb)
				return
			end
			local entity = mob:get_luaentity ()
			-- Target position is immaterial here.
			local pos = vector.apply (player:get_pos (), round_trunc)
			local context = entity:gwp_initialize ({pos})
			if not context then
				core.chat_send_player (playername, "Cannot pathfind!")
				return
			end
			local class1 = entity:gwp_classify_node (context, pos)
			local class2 = entity:gwp_classify_node (context, pos)
			core.chat_send_player (playername,
						   string.format ("Position (%d, %d, %d): %s",
								  pos.x, pos.y, pos.z, class1)
						   .. "\nIntrinsic: " .. class2 .. "\n")

			local width = context.mob_width
			local height = context.mob_height
			core.chat_send_player (playername, "WIDTH (& LENGTH), HEIGHT: "
						   .. width .. " " .. height)
		end
	end
}

core.register_on_leaveplayer (function (object, timed_out)
		local playername = object:get_player_name ()
		local mobs = mcl_mobs.mobs_being_tested
		if mobs[playername] then
			cancel_test (mobs[playername])
			mobs[playername] = nil
		end
end)
core.register_chatcommand ("mobpathfind", cdef)

local function print_node_classification (itemstack, user, pointed_thing)
	if not (user and user:is_player ()) then
		return
	end
	local playername = user:get_player_name ()
	if pointed_thing.type == "node" then
		local mob = mcl_mobs.players_selecting_mob[playername]
		if not mob or mob == true then
			core.chat_send_player (playername,
						   "Run `/mobpathfind choose' to select a mob to"
						   .. " impersonate before using this tool.")
			return
		end
		local entity = mob:get_luaentity ()
		if not entity then
			return
		end
		-- Target position is immaterial here.
		local context = entity:gwp_initialize ({user:get_pos ()})
		if not context then
			core.chat_send_player (playername, "Cannot pathfind!")
			return
		end
		local class1 = entity:gwp_classify_node (context, pointed_thing.under)
		local class2 = entity:gwp_classify_node (context, pointed_thing.above)
		local class3 = gwp_basic_classify (pointed_thing.under)
		local class4 = gwp_basic_classify (pointed_thing.above)
		core.chat_send_player (playername,
					   "ABOVE: " .. class2 .. " "
					   .. ground_height (context, pointed_thing.above)
					   .. "\nUNDER: " .. class1
					   .. "\nABOVE (basic): "
					   .. class4
					   .. "\nUNDER (basic): "
					   .. class3)

		local width = context.mob_width
		local height = context.mob_height
		core.chat_send_player (playername, "WIDTH (& LENGTH), HEIGHT: "
					   .. width .. " " .. height)
	elseif pointed_thing.type == "object" then
		local mob = pointed_thing.ref
		local entity = mob:get_luaentity ()
		if entity and entity.is_mob then
			mcl_mobs.players_selecting_mob[playername] = mob
			core.chat_send_player (playername, "Mob selected")
			entity.stupefied = true
			entity.waypoints = nil
		end
	end
end

local function print_node_neighbors (itemstack, user, pointed_thing)
	if not (user and user:is_player ()) then
		return
	end
	local playername = user:get_player_name ()
	if pointed_thing.type == "node" then
		local mob = mcl_mobs.players_selecting_mob[playername]
		if not mob or mob == true then
			core.chat_send_player (playername,
						   "Run `/mobpathfind choose' to select a mob to"
						   .. " impersonate before using this tool.")
			return
		end
		local entity = mob:get_luaentity ()
		if not entity then
			return
		end
		-- Target position is immaterial here.
		local context = entity:gwp_initialize ({user:get_pos ()})
		local edges_under = entity:gwp_edges (context, pointed_thing.under)
		edges_under = table.copy (edges_under)
		local edges_above = entity:gwp_edges (context, pointed_thing.above)
		edges_above = table.copy (edges_above)

		print (dump (edges_under))
		print (dump (edges_above))
	end
end

local function pathfind_selected_mob (itemstack, user, pointed_thing)
	if not (user and user:is_player ()) or pointed_thing.type ~= "node" then
		return
	end
	local mobs = mcl_mobs.mobs_being_tested
	local playername = user:get_player_name ()
	local mob = mcl_mobs.players_selecting_mob[playername]
	if not mob or mob == true then
		core.chat_send_player (playername,
					   "Run `/mobpathfind choose' to select a mob to"
					   .. " impersonate before using this tool.")
		return
	end
	local entity = mob:get_luaentity ()
	if not entity then
		return
	end
	local position = pointed_thing.above
	position = vector.apply (position, round_trunc)
	local start = mob:get_pos ()
	start = vector.apply (start, round_trunc)

	local msg = "Pathfinding from mob at "
		.. start.x .. ", " .. start.y .. ", " .. start.z .. " "
		.. "to node, at " .. position.x .. ", "
		.. position.y .. ", " .. position.z .. "..."
	core.chat_send_player (playername, msg)

	local entity = mob:get_luaentity ()
	entity.pathfinding_context = entity:gwp_initialize ({position})
	entity.pathfinding_duration = 0
	local old_step = entity.on_step
	entity._old_onstep = old_step
	local sneaking = user:get_player_control ().sneak
	entity.on_step = function (self, moveresult)
		if entity.pathfinding_context then
			local context = self.pathfinding_context
			local complete, dtime = self:gwp_cycle (context, DTIME_LIMIT)

			self.pathfinding_duration
				= self.pathfinding_duration + dtime
			if complete then
				mobs[playername] = nil
				cancel_test (self, playername, sneaking)
			end
			return
		end
		return old_step (self, moveresult)
	end
end

core.register_tool ("mcl_mobs:pathfinder_stick", {
	description = "Classify blocks",
	inventory_image = "default_stick.png",
	groups = { testtool = 1, disable_repair = 1,
		   not_in_creative_inventory = 1, },
	on_use = print_node_classification,
	on_place = pathfind_selected_mob,
})

core.register_tool ("mcl_mobs:pathfinder_liquid_stick", {
	description = "Classify liquids",
	inventory_image = "default_stick.png",
	groups = { testtool = 1, disable_repair = 1,
		   not_in_creative_inventory = 1, },
	pointabilities = {
		nodes = {
			["group:water"] = true,
		},
	},
	on_use = print_node_classification,
	on_place = pathfind_selected_mob,
})

core.register_tool ("mcl_mobs:pathfinder_edge_stick", {
	description = "Print neighbors of blocks",
	inventory_image = "default_stick.png",
	groups = { testtool = 1, disable_repair = 1,
		   not_in_creative_inventory = 1, },
	pointabilities = {
		nodes = {
			["group:water"] = true,
		},
	},
	on_use = print_node_neighbors,
})

mcl_mobs.last_dbg_entity = nil

core.register_tool ("mcl_mobs:pathfinder_dump_stick", {
	description = "Dump object luaentities",
	inventory_image = "default_stick.png",
	groups = { testtool = 1, disable_repair = 1,
		   not_in_creative_inventory = 1, },
	on_use = function (itemstack, user, pointed_thing)
		if not (user and user:is_player ()) or pointed_thing.type ~= "object" then
			return
		end
		print (dump (pointed_thing.ref:get_luaentity ()))
		mcl_mobs.last_dbg_entity = pointed_thing.ref:get_luaentity ()
	end,
})

-- Number of seconds per step permissible for pathfinding.
local PATHFIND_PER_STEP = 0.035
local PATHFIND_TIMEOUT  = 10.0 / 1000

-- Number of seconds spent pathfinding during this step.
local pathfinding_quota = PATHFIND_PER_STEP
local mobs_this_step = 0
-- local pathfinding_history = {  }

core.register_globalstep (function (dtime)
		nodes_this_step = {}
		if pathfinding_quota <= 0.0 then
			core.log ("warning", "Global pathfinding quota exceeded...")
		end
		-- if record_pathfinding_stats then
		-- 	if #pathfinding_history >= 20 then
		-- 		local total, max = 0, 0
		-- 		for _, item in ipairs (pathfinding_history) do
		-- 			total = total + item
		-- 			if item > max then
		-- 				max = item
		-- 			end
		-- 		end
		-- 		core.log ("action", "During the previous 20 steps, an average"
		-- 			      .. " of " .. string.format ("%.2f", total / 20 * 1000)
		-- 			      .. " ms, and a maximum of "
		-- 			      .. string.format ("%.2f", max * 1000)
		-- 			      .. " ms, were spent pathfinding on behalf of ~"
		-- 			      .. mobs_this_step .. " mobs (amounting to "
		-- 			      .. string.format ("%.2f", max * 1000 / mobs_this_step)
		-- 			      .. "/mob).")
		-- 		total = 0
		-- 		for nodetype, n in pairs (bc_stats) do
		-- 			total = total + n
		-- 		end
		-- 		core.log ("action", "In the process, " .. total .. " nodes were examined,"
		-- 			      .. " distributed between: ")
		-- 		local t = {}
		-- 		for nodetype, n in pairs (bc_stats) do
		-- 			table.insert (t, { n, nodetype, })
		-- 		end
		-- 		table.sort (t, function (a, b) return a[1] < b[1] end)
		-- 		for _, item in ipairs (t) do
		-- 			core.log ("action", string.format ("   %s: %d nodes (%.2f %%)",
		-- 							       item[2], item[1],
		-- 							       item[1] / total * 100))
		-- 		end
		-- 		core.log ("action", string.format ("%.2f%% of classification attempts registered cache hits", (gwp_cc_hits / (gwp_cc_hits + gwp_cc_misses)) * 100))
		-- 		gwp_cc_hits = 0
		-- 		gwp_cc_misses = 0
		-- 		bc_stats = {}
		-- 		pathfinding_history = { }
		-- 		mobs_this_step = 0
		-- 	end
		-- 	table.insert (pathfinding_history, PATHFIND_PER_STEP - pathfinding_quota)
		-- end
		pathfinding_quota = PATHFIND_PER_STEP
end)

------------------------------------------------------------------------
-- Pathfinding for swimming mobs.
------------------------------------------------------------------------

local function waterbound_gwp_basic_classify (pos)
	local nodevalue, value = gwp_get_node (pos), nil
	if not nodevalue then
		return "IGNORE"
	end
	local name = gwp_nodevalue_to_name (nodevalue)
	local def = core.registered_nodes[name]
	if not def or not def.groups.water or def.groups.water <= 0 then
		value = "BLOCKED"
	end
	return value
end

mcl_mobs.waterbound_gwp_basic_classify
	= waterbound_gwp_basic_classify

local function waterbound_gwp_classify_node (self, context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	if cache then
		-- if record_pathfinding_stats then
		-- 	gwp_cc_hits = gwp_cc_hits + 1
		-- end
		return cache
	end
	-- if record_pathfinding_stats then
	-- 	gwp_cc_misses = gwp_cc_misses + 1
	-- end

	local b_width, b_height
	b_width = context.mob_width - 1
	b_height = context.mob_height - 1

	local sx, sy, sz = pos.x, pos.y, pos.z
	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z

				local class = waterbound_gwp_basic_classify (vector)
				context.class_cache[hash] = class
				if class then
					return class
				end
			end
		end
	end
	context.class_cache[hash] = "WATER"
	return "WATER"
end

local function waterbound_gwp_classify_for_movement (self, pos)
	local b_width, b_height
	local collisionbox = self.collisionbox
	local width = math.max (0, collisionbox[4] - collisionbox[1])
	local height = math.max (0, collisionbox[5] - collisionbox[2])
	local length = math.max (0, collisionbox[6] - collisionbox[3])

	b_width = floor (math.max (width, length) + 1.0) - 1
	b_height = math.ceil (height) - 1

	local sx, sy, sz = pos.x, pos.y, pos.z
	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z

				local class = waterbound_gwp_basic_classify (vector)
				if class then
					return class
				end
			end
		end
	end
	-- Water should be reported as walkable, to match callers'
	-- expectations.
	return "WALKABLE"
end

-- The final two elements of each vector define the indices of nodes
-- on either side of a diagonal movement that must be checked in
-- validating it.

-- Cardinal directions.

local gwp_waterbound_directions = {
	-- North.
	{ 0, 0, 1, },
	-- West.
	{-1, 0, 0, },
	-- South.
	{ 0, 0, -1, },
	-- East.
	{ 1, 0, 0, },
	-- Bottom.
	{ 0, -1, 0, },
	-- Top.
	{ 0, 1, 0, },
}

-- Level diagonal movement.

for i, d in ipairs (gwp_waterbound_directions) do
	if i > 4 then
		break
	end
	local ccw = i == 4 and 1 or i + 1
	local counterclockwise = gwp_waterbound_directions[ccw]
	local diagonal = {
		d[1] + counterclockwise[1],
		d[2] + counterclockwise[2],
		d[3] + counterclockwise[3],
		i,
		ccw,
	}
	table.insert (gwp_waterbound_directions, diagonal)
end

local waterbound_gwp_edges_scratch = vector.zero ()
local waterbound_gwp_edges_scratch_1 = {}
local waterbound_gwp_edges_buffer = {}

local function waterbound_gwp_edges (self, context, node)
	local penalties = context.penalties
	local buffer = waterbound_gwp_edges_buffer
	local saved = waterbound_gwp_edges_scratch_1
	local directions = gwp_waterbound_directions
	local n = 0

	for i, direction in ipairs (directions) do
		local vector = waterbound_gwp_edges_scratch
		local x, y, z = node.x + direction[1],
			node.y + direction[2],
			node.z + direction[3]
		vector.x = x
		vector.y = y
		vector.z = z

		saved[i] = nil
		if not direction[4]
			or (saved[direction[4]] and saved[direction[5]]) then
			local class = self:gwp_classify_node (context, vector)
			local penalty = penalties[class]
			if penalty >= 0.0 then
				local object = self:get_gwp_node (context, x, y, z)

				-- Record this class and update the node's
				-- pathfinding penalty.
				object.class = class
				if penalty > object.penalty then
					object.penalty = penalty
				end

				-- Save the result.
				saved[i] = object
				n = n + 1
				buffer[n] = object
			end
		end
	end

	buffer[n + 1] = nil
	return buffer
end

local function waterbound_gwp_start (self, context)
	local pos = self.object:get_pos ()
	pos.x = floor (pos.x + 0.5)
	pos.y = floor (pos.y + 0.5)
	pos.z = floor (pos.z + 0.5)
	return pos
end

local function waterbound_gwp_initialize (self, targets, range, penalties)
	local context = mob_class.gwp_initialize (self, targets, range, penalties)
	if not context then
		return nil
	end
	local cbox = self.collisionbox
	local cbox_height = cbox[5] - cbox[2]

	-- Offset Y positions of reconstructed path nodes so as to
	-- center the mob in the said nodes if it is sufficiently
	-- small.
	if cbox_height < 0.4 then
		context.y_offset = -(cbox_height / 2) - cbox[2]
	end
	return context
end

------------------------------------------------------------------------
-- Pathfinding for amphibious mobs.
------------------------------------------------------------------------

local amphibious_gwp_edges_scratch = vector.zero ()

local function amphibious_gwp_edges_1 (self, context, node, yoff)
	local v = amphibious_gwp_edges_scratch
	v.x = node.x
	v.y = node.y + yoff
	v.z = node.z
	local class = self:gwp_classify_node (context, v)

	if class == "WATER" then
		local penalty = context.penalties[class]
		local object = self:get_gwp_node (context, v.x, v.y, v.z)
		object.class = class
		if penalty >= 0.0 then
			object.penalty = math.max (penalty, object.penalty)
		else
			-- Impassible node.
			object.penalty = -1
		end
		return object
	end
	return nil
end

local function amphibious_gwp_edges (self, context, node)
	local array, c1, c2, c3, c4, c5, c6 = gwp_edges_scratch
	local floor = ground_height (context, node)
	local n = 0
	gwp_parent_penalty = nil

	-- Consider neighbors in the four cardinal directions.
	c1 = gwp_edges_1 (self, context, node, floor, 1, 0, true)
	if c1 and c1.penalty >= 0.0 then n = n + 1; array[n] = c1 end
	c2 = gwp_edges_1 (self, context, node, floor, 0, 1, true)
	if c2 and c2.penalty >= 0.0 then n = n + 1; array[n] = c2 end
	c3 = gwp_edges_1 (self, context, node, floor, -1, 0, true)
	if c3 and c3.penalty >= 0.0 then n = n + 1; array[n] = c3 end
	c4 = gwp_edges_1 (self, context, node, floor, 0, -1, true)
	if c4 and c4.penalty >= 0.0 then n = n + 1; array[n] = c4 end
	-- Consider diagonal neighbors at an angle.
	local y = node.y
	if self:gwp_check_diagonal (node, c1, c2) then
		local d = gwp_edges_1 (self, context, node, floor, 1, 1, true)
		if d and self:gwp_check_diagonal_1 (context, d, c1, c2, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c1, c4) then
		local d = gwp_edges_1 (self, context, node, floor, 1, -1, true)
		if d and self:gwp_check_diagonal_1 (context, d, c1, c4, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c3, c2) then
		local d = gwp_edges_1 (self, context, node, floor, -1, 1, true)
		if d and self:gwp_check_diagonal_1 (context, d, c3, c2, y) then
			n = n + 1; array[n] = d
		end
	end
	if self:gwp_check_diagonal (node, c3, c4) then
		local d = gwp_edges_1 (self, context, node, floor, -1, -1, true)
		if d and self:gwp_check_diagonal_1 (context, d, c3, c4, y) then
			n = n + 1; array[n] = d
		end
	end
	-- Consider neighbors vertically above and below, but only if
	-- they be water.
	c5 = amphibious_gwp_edges_1 (self, context, node, 1)
	if c5 then n = n + 1; array[n] = c5 end
	c6 = amphibious_gwp_edges_1 (self, context, node, -1)
	if c6 then n = n + 1; array[n] = c6 end
	array[n + 1] = nil
	return array
end

local function amphibious_gwp_start (self, context, node)
	if not self.standing_in
		or core.get_item_group (self.standing_in, "water") == 0 then
		return mob_class.gwp_start (self, context, node)
	else
		return waterbound_gwp_start (self, context, node)
	end
end

------------------------------------------------------------------------
-- Pathfinding for airborne mobs.
------------------------------------------------------------------------

local function airborne_gwp_edges_1 (self, context, pos)
	local class = self:gwp_classify_node (context, pos)
	local penalty = context.penalties[class]

	if penalty >= 0.0 then
		local node = self:get_gwp_node (context, pos.x, pos.y, pos.z)
		node.class = class
		node.penalty = math.max (node.penalty or 0, penalty)
		if class == "WALKABLE" then
			-- Prefer direct paths to paths over land.
			node.penalty = node.penalty + 1
		end
		return node
	end
	return nil
end

local airborne_gwp_edges_scratch = vector.zero ()
local airborne_gwp_edges_buffer = {}

local function airborne_gwp_edges (self, context, node)
	local results = airborne_gwp_edges_buffer
	local n = 0
	local v = airborne_gwp_edges_scratch

	v.x = node.x + 0
	v.y = node.y + 0
	v.z = node.z + 1
	local e1 = airborne_gwp_edges_1 (self, context, v)
	if e1 then
		n = n + 1; results[n] = e1
	end
	v.x = node.x + -1
	v.y = node.y + 0
	v.z = node.z + 0
	local e2 = airborne_gwp_edges_1 (self, context, v)
	if e2 then
		n = n + 1; results[n] = e2
	end
	v.x = node.x + 0
	v.y = node.y + 0
	v.z = node.z + -1
	local e3 = airborne_gwp_edges_1 (self, context, v)
	if e3 then
		n = n + 1; results[n] = e3
	end
	v.x = node.x + 1
	v.y = node.y + 0
	v.z = node.z + 0
	local e4 = airborne_gwp_edges_1 (self, context, v)
	if e4 then
		n = n + 1; results[n] = e4
	end
	v.x = node.x + 0
	v.y = node.y + -1
	v.z = node.z + 0
	local e5 = airborne_gwp_edges_1 (self, context, v)
	if e5 then
		n = n + 1; results[n] = e5
	end
	v.x = node.x + 0
	v.y = node.y + 1
	v.z = node.z + 0
	local e6 = airborne_gwp_edges_1 (self, context, v)
	if e6 then
		n = n + 1; results[n] = e6
	end
	v.x = node.x + 0
	v.y = node.y + 1
	v.z = node.z + 1
	local e7 = airborne_gwp_edges_1 (self, context, v)
	if e7
		and e6
		and e1 then
		n = n + 1; results[n] = e7
	end
	v.x = node.x + -1
	v.y = node.y + 1
	v.z = node.z + 0
	local e8 = airborne_gwp_edges_1 (self, context, v)
	if e8
		and e6
		and e2 then
		n = n + 1; results[n] = e8
	end
	v.x = node.x + 0
	v.y = node.y + 1
	v.z = node.z + -1
	local e9 = airborne_gwp_edges_1 (self, context, v)
	if e9
		and e6
		and e3 then
		n = n + 1; results[n] = e9
	end
	v.x = node.x + 1
	v.y = node.y + 1
	v.z = node.z + 0
	local e10 = airborne_gwp_edges_1 (self, context, v)
	if e10
		and e6
		and e4 then
		n = n + 1; results[n] = e10
	end
	v.x = node.x + 0
	v.y = node.y + -1
	v.z = node.z + 1
	local e11 = airborne_gwp_edges_1 (self, context, v)
	if e11
		and e5
		and e1 then
		n = n + 1; results[n] = e11
	end
	v.x = node.x + -1
	v.y = node.y + -1
	v.z = node.z + 0
	local e12 = airborne_gwp_edges_1 (self, context, v)
	if e12
		and e5
		and e2 then
		n = n + 1; results[n] = e12
	end
	v.x = node.x + 0
	v.y = node.y + -1
	v.z = node.z + -1
	local e13 = airborne_gwp_edges_1 (self, context, v)
	if e13
		and e5
		and e3 then
		n = n + 1; results[n] = e13
	end
	v.x = node.x + 1
	v.y = node.y + -1
	v.z = node.z + 0
	local e14 = airborne_gwp_edges_1 (self, context, v)
	if e14
		and e5
		and e4 then
		n = n + 1; results[n] = e14
	end
	v.x = node.x + -1
	v.y = node.y + 0
	v.z = node.z + 1
	local e15 = airborne_gwp_edges_1 (self, context, v)
	if e15
		and e1
		and e2 then
		n = n + 1; results[n] = e15
	end
	v.x = node.x + 1
	v.y = node.y + 0
	v.z = node.z + -1
	local e16 = airborne_gwp_edges_1 (self, context, v)
	if e16
		and e1
		and e4 then
		n = n + 1; results[n] = e16
	end
	v.x = node.x + -1
	v.y = node.y + 0
	v.z = node.z + -1
	local e17 = airborne_gwp_edges_1 (self, context, v)
	if e17
		and e3
		and e2 then
		n = n + 1; results[n] = e17
	end
	v.x = node.x + 1
	v.y = node.y + 0
	v.z = node.z + -1
	local e18 = airborne_gwp_edges_1 (self, context, v)
	if e18
		and e3
		and e4 then
		n = n + 1; results[n] = e18
	end
	v.x = node.x + -1
	v.y = node.y + 1
	v.z = node.z + 1
	local e19 = airborne_gwp_edges_1 (self, context, v)
	if e19
		and e15
		and e1
		and e2
		and e6
		and e7
		and e8 then
		n = n + 1; results[n] = e19
	end
	v.x = node.x + 1
	v.y = node.y + 1
	v.z = node.z + -1
	local e20 = airborne_gwp_edges_1 (self, context, v)
	if e20
		and e16
		and e1
		and e4
		and e6
		and e7
		and e10 then
		n = n + 1; results[n] = e20
	end
	v.x = node.x + -1
	v.y = node.y + 1
	v.z = node.z + -1
	local e21 = airborne_gwp_edges_1 (self, context, v)
	if e21
		and e17
		and e3
		and e2
		and e6
		and e9
		and e8 then
		n = n + 1; results[n] = e21
	end
	v.x = node.x + 1
	v.y = node.y + 1
	v.z = node.z + -1
	local e22 = airborne_gwp_edges_1 (self, context, v)
	if e22
		and e18
		and e3
		and e4
		and e6
		and e9
		and e10 then
		n = n + 1; results[n] = e22
	end
	v.x = node.x + -1
	v.y = node.y + -1
	v.z = node.z + 1
	local e23 = airborne_gwp_edges_1 (self, context, v)
	if e23
		and e15
		and e1
		and e2
		and e5
		and e11
		and e12 then
		n = n + 1; results[n] = e23
	end
	v.x = node.x + 1
	v.y = node.y + -1
	v.z = node.z + -1
	local e24 = airborne_gwp_edges_1 (self, context, v)
	if e24
		and e16
		and e1
		and e4
		and e5
		and e11
		and e14 then
		n = n + 1; results[n] = e24
	end
	v.x = node.x + -1
	v.y = node.y + -1
	v.z = node.z + -1
	local e25 = airborne_gwp_edges_1 (self, context, v)
	if e25
		and e17
		and e3
		and e2
		and e5
		and e13
		and e12 then
		n = n + 1; results[n] = e25
	end
	v.x = node.x + 1
	v.y = node.y + -1
	v.z = node.z + -1
	local e26 = airborne_gwp_edges_1 (self, context, v)
	if e26
		and e18
		and e3
		and e4
		and e5
		and e13
		and e14 then
		n = n + 1; results[n] = e26
	end
	results[n + 1] = nil
	return results
end

local function aabb_avg_size (aabb)
	return ((aabb[4] - aabb[1])
		+ (aabb[5] - aabb[2])
		+ (aabb[6] - aabb[3])) / 3
end

local function airborne_gwp_start_1 (self, self_pos, context)
	local cbox = self.collisionbox
	local size = aabb_avg_size (cbox)
	local positions = {}
	if size < 1.0 then
		local v1, v2, v3, v4
		v1 = vector.offset (self_pos, cbox[1], 0, cbox[3])
		v1 = vector.apply (v1, round_trunc)
		v2 = vector.offset (self_pos, cbox[4], 0, cbox[3])
		v2 = vector.apply (v2, round_trunc)
		v3 = vector.offset (self_pos, cbox[1], 0, cbox[6])
		v3 = vector.apply (v3, round_trunc)
		v4 = vector.offset (self_pos, cbox[4], 0, cbox[6])
		v4 = vector.apply (v4, round_trunc)
		table.insert (positions, v1)
		table.insert (positions, v2)
		table.insert (positions, v3)
		table.insert (positions, v4)
		return ipairs (positions)
	else
		local n = 10
		cbox = table.copy (cbox)
		cbox[1] = floor (cbox[1] + self_pos.x + 0.5)
		cbox[2] = floor (cbox[2] + self_pos.y + 0.5)
		cbox[3] = floor (cbox[3] + self_pos.z + 0.5)
		cbox[4] = floor (cbox[4] + self_pos.x + 0.5)
		cbox[5] = floor (cbox[5] + self_pos.y + 0.5)
		cbox[6] = floor (cbox[6] + self_pos.z + 0.5)
		local xw, yw, zw = cbox[4] - cbox[1] + 1,
			cbox[5] - cbox[2] + 1,
			cbox[6] - cbox[3] + 1
		return function ()
			if n <= 0 then
				return nil
			end
			n = n - 1
			return 10 - n, {
				x = cbox[1] + math.random (0, xw + 1),
				y = cbox[2] + math.random (0, yw + 1),
				z = cbox[3] + math.random (0, zw + 1),
			}
		end
	end
end

local function airborne_gwp_start (self, context)
	local self_pos = self.object:get_pos ()
	-- TODO: ascend to surface of water if floating.
	for _, pos in airborne_gwp_start_1 (self, self_pos, context) do
		local class = self:gwp_classify_node (context, pos)
		if class and context.penalties[class] >= 0.0 then
			return pos
		end
	end
	return nil
end

local function airborne_gwp_initialize (self, targets, range, penalties)
	local context = mob_class.gwp_initialize (self, targets, range, penalties)
	if not context then
		return nil
	end
	local cbox = self.collisionbox

	-- Offset Y positions of reconstructed nodes so as to center
	-- the mob itself, if it is less than one node in height, in
	-- the said nodes.
	local height = cbox[5] - cbox[2]
	if height <= 1.0 then
		context.y_offset = -(height / 2) - cbox[2]
	end
	return context
end

local gwp_airborne_floortypes = {
	BLOCKED = "WALKABLE",
	LEAVES = "WALKABLE",
	DAMAGE_FIRE = "DAMAGE_FIRE",
	DAMAGE_OTHER = "DAMAGE_OTHER",
	DANGER_FIRE = "WALKABLE",
	DANGER_OTHER = "WALKABLE",
	DOOR_IRON_CLOSED = "WALKABLE",
	DOOR_OPEN = "WALKABLE",
	DOOR_WOOD_CLOSED = "WALKABLE",
	FENCE = "WALKABLE",
	IGNORE = "IGNORE",
	LAVA = "OPEN",
	OPEN = "OPEN",
	SLAB = "WALKABLE",
	TRAPDOOR = "WALKABLE",
	WALKABLE = "WALKABLE",
	WATER = "OPEN",
}

local function airborne_gwp_classify_node_1 (self, pos)
	local class_1 = gwp_basic_classify (pos)

	-- If this block (the block in which the mob stands) is air,
	-- evaluate the node below.
	if class_1 == "OPEN" then
		-- Don't cons a new vector.
		local pos_2 = gwp_classify_node_1_scratch
		pos_2.x = pos.x
		pos_2.y = pos.y - 1
		pos_2.z = pos.z
		local class_2 = gwp_basic_classify (pos_2)
		local floortype = gwp_airborne_floortypes[class_2]

		-- Open nodes should also be modified by their
		-- surroundings with airborne mobs.
		if floortype == "OPEN" or floortype == "WALKABLE" then
			if floortype == "OPEN" then
				-- An OPEN node resting on an OPEN
				-- surface above a FENCE should be
				-- reset to WALKABLE, as the collision
				-- box of the FENCE will extend into
				-- the node above, becoming something
				-- of a slab.
				pos_2.y = pos_2.y - 1
				local class_3 = gwp_basic_classify (pos_2)
				if class_3 == "FENCE" then
					floortype = "WALKABLE"
				end
			end

			floortype = self:gwp_classify_surroundings (pos, floortype)
		end
		return floortype
	end
	return class_1
end

-- This duplicates much of `gwp_classify_node', but the performance
-- improvement yielded by calling an upvalue is substantial.

local function airborne_gwp_classify_node (self, context, pos)
	local hash = hashpos (context, pos.x, pos.y, pos.z)
	local cache = context.class_cache[hash]

	-- This is very expensive, as core.get_node conses too
	-- much.
	if cache then
		-- if record_pathfinding_stats then
		-- 	gwp_cc_hits = gwp_cc_hits + 1
		-- end
		return cache
	end
	-- if record_pathfinding_stats then
	-- 	gwp_cc_misses = gwp_cc_misses + 1
	-- end

	local sx, sy, sz = pos.x, pos.y, pos.z
	local worst, penalty = "OPEN", 0.0
	local vector = gwp_classify_node_scratch
	local b_width, b_height
	local penalties = context.penalties

	b_width = context.mob_width - 1
	b_height = context.mob_height - 1

	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z
				local class = airborne_gwp_classify_node_1 (self, vector)
				-- Report impassible nodes
				-- immediately.
				if penalties[class] < 0.0 then
					worst = class
					context.class_cache[hash] = worst
					return worst
				-- Otherwise select the worst class possible.
				elseif worst == "OPEN" or penalty < penalties[class] then
					penalty = penalties[class]
					worst = class
				end
			end
		end
	end
	context.class_cache[hash] = worst
	return worst
end

local function airborne_gwp_classify_for_movement (self, pos)
	local sx, sy, sz = pos.x, pos.y, pos.z
	local worst, penalty = "OPEN", 0.0
	local vector = gwp_classify_node_scratch
	local b_width, b_height
	local penalties = self.gwp_penalties
	local collisionbox = self.collisionbox
	local width = math.max (0, collisionbox[4] - collisionbox[1])
	local height = math.max (0, collisionbox[5] - collisionbox[2])
	local length = math.max (0, collisionbox[6] - collisionbox[3])

	b_width = floor (math.max (width, length) + 1.0) - 1
	b_height = math.ceil (height) - 1

	for x = sx, sx + b_width do
		for y = sy, sy + b_height do
			for z = sz, sz + b_width do
				vector.x = x
				vector.y = y
				vector.z = z
				local class = airborne_gwp_classify_node_1 (self, vector)
				-- Report impassible nodes
				-- immediately.
				if penalties[class] < 0.0 then
					return worst
				-- Otherwise select the worst class possible.
				elseif worst == "OPEN" or penalty < penalties[class] then
					penalty = penalties[class]
					worst = class
				end
			end
		end
	end
	return worst
end

------------------------------------------------------------------------
-- External interface.
------------------------------------------------------------------------

local MAX_STALE_PATH_AGE = 1.25

function mob_class:gopath_internal (target, speed_bonus, animation, tolerance, penalties)
	local mob = self
	if mob.waypoints then
		local wp_target = mob.waypoints[1]
		local target_x = floor (target.x + 0.5)
		local target_y = floor (target.y + 0.5)
		local target_z = floor (target.z + 0.5)
		local wp_target_x = wp_target.x - wp_target.x_offset
		local wp_target_y = wp_target.y - wp_target.y_offset
		local wp_target_z = wp_target.z - wp_target.x_offset

		-- Attempt to reuse existing paths if possible.
		if wp_target
			and manhattan3d (target_x, target_y, target_z,
						wp_target_x, wp_target_y, wp_target_z)
				<= (tolerance or 0)
			and mob.waypoint_age < MAX_STALE_PATH_AGE then
			return true
		end
	end

	mob.gowp_velocity = speed_bonus and speed_bonus * mob.movement_speed
	mob.gowp_animation = animation or "walk"
	mob.pathfinding_context
		= mob:gwp_initialize ({target}, nil, tolerance, penalties)
	mob._gwp_did_timeout = false

	-- Cancel navigation if pathing is impossible.
	if not mob.pathfinding_context then
		mob:cancel_navigation ()
	end
	return mob.pathfinding_context
end

function mob_class:gopath (target, speed_bonus, animation, tolerance, penalties)
	local mob = self:mob_controlling_movement ()
	return mob:gopath_internal (target, speed_bonus, animation, tolerance, penalties)
end

local GWP_TIMEOUT	= 100 / 20

function mob_class:gwp_position_on_path ()
	return self.object:get_pos ()
end

function mob_class:gwp_timeout (dtime)
	local timeout = self._gwp_timeout
	local previous_pos = self._gwp_previous_pos
	timeout = timeout - dtime

	if timeout <= 0 then
		local speed = self.acc_speed or self.movement_speed
		local expected_speed

		if speed >= 20.0 then
			-- The speed won't be scaled by itself.
			expected_speed = speed
		else
			expected_speed = speed * speed * 0.05
		end
		local pos = self:gwp_position_on_path ()
		if previous_pos then
			local mindist = expected_speed * GWP_TIMEOUT * 0.25
			if mindist > vector.distance (pos, previous_pos) then
				self.waypoints = nil
				self:halt_in_tracks ()
				self._gwp_did_timeout = true
				return
			end
		end

		self._gwp_previous_pos = pos
		self._gwp_timeout = GWP_TIMEOUT
	else
		self._gwp_timeout = math.max (0, timeout)
	end
end

function mob_class:validate_waypoints (waypoints)
end

function mob_class:next_waypoint (dtime)
	self:gwp_close_memorized_doors ()
	-- Pathfind for at most half the remaining quota.
	if self.pathfinding_context then
		-- Continue pathfinding till either the process times
		-- out, or the pathfinding time quota is exhausted.
		mobs_this_step = mobs_this_step + 1
		local quota = pathfinding_quota
		if quota < 0 then
			return
		end
		local ctx = self.pathfinding_context
		local time_sec = ctx.time_elapsed * 1e6
		local timeout = math.min (PATHFIND_TIMEOUT - time_sec,
					  quota)
		local result, elapsed
			= self:gwp_cycle (ctx, math.max (0, timeout))
		if ctx.time_elapsed * 1e6 > PATHFIND_TIMEOUT then
			result = true
		end
		pathfinding_quota = pathfinding_quota - elapsed
		self._gwp_timeout = GWP_TIMEOUT

		if result then
			local waypoints, _
			waypoints, _ = self:gwp_reconstruct (ctx)

			-- TODO: some criteria for rejecting partial
			-- destinations that are too distant.
			if waypoints then
				self.waypoints = waypoints
				self.waypoint_age = 0

				-- if self.name == "mobs_mc:drowned" then
				-- 	create_path_particles (waypoints, "repetitivestrain", 1, 0.1)
				-- end
			else
				self:cancel_navigation ()
			end
			self:set_animation (self.gowp_animation)
			self.pathfinding_context = nil
		end
	end

	-- Continue navigating even if another pathfinding operation
	-- is in progress.  This appears to reduce jank.
	if self.waypoints then
		self.waypoint_age = self.waypoint_age + dtime
		self:validate_waypoints (self.waypoints)
		self:gwp_next_waypoint (dtime)
		self:gwp_timeout (dtime)
	end
end

local function is_door_in_waypoints (mob, door)
	local mob_waypoints = mob.waypoints
	if not mob_waypoints then
		return false
	end
	local max = #mob_waypoints
	for i = 0, max - 1 do
		local node = mob_waypoints[max - i]
		if vector.equals (node, door) then
			return true
		end
	end
end

local function is_mob_to_close_door (mob, door)
	if not mob.doors_to_close then
		return false
	end
	for _, closedoor in pairs (mob.doors_to_close) do
		if vector.equals (door, closedoor) then
			return true
		end
	end
	return false
end

local function xz_distance (v1, v2)
	local dx, dz = v1.x - v2.x, v1.z - v2.z
	return math.sqrt (dx*dx + dz*dz)
end

local function door_has_other_users (self, door)
	-- Locate users of this door besides `self' who are within two
	-- blocks of the said door and are pathfinding through it, or
	-- are within 0.5 blocks and preparing to close it.
	for object in core.objects_inside_radius (door, 2) do
		local entity
		entity = object:get_luaentity ()
		if entity and entity.is_mob and entity ~= self
			and entity.can_open_doors then
			local pos = object:get_pos ()
			if vector.distance (pos, door) <= 2
				and is_door_in_waypoints (entity, door) then
				return true
			end
			if math.abs (pos.y - door.y) <= 2.0
				and xz_distance (pos, door) <= 0.7
				and is_mob_to_close_door (entity, door) then
				return true
			end
		end
	end
end

function mob_class:gwp_close_memorized_doors ()
	if not self.doors_to_close then
		return
	end
	local self_pos = self.object:get_pos ()
	local remaining = {}
	for _, door in pairs (self.doors_to_close) do
		if math.abs (self_pos.y - door.y) <= 2.0
			and xz_distance (self_pos, door) <= 0.7 then
			table.insert (remaining, door)
		elseif not is_door_in_waypoints (self, door)
			and vector.distance (self_pos, door) <= 3
			and not door_has_other_users (self, door) then
			local door_node = mcl_util.get_nodepos (door)
			local node = core.get_node (door_node)
			if core.get_item_group (node.name, "door") ~= 0 then
				if mcl_doors.is_open (door_node) then
					local def = core.registered_nodes[node.name]
					def.on_rightclick (door_node, node, self)
				end
			end
		end
	end
	self.doors_to_close = remaining
end

function mob_class:gwp_memorize_door (door_wp)
	if not self.doors_to_close then
		self.doors_to_close = { door_wp, }
	else
		table.insert (self.doors_to_close, door_wp)
	end
end

function mob_class:gwp_open_door (door_node, node, dtime)
	local def = core.registered_nodes[node.name]
	-- Copy this position, lest it be modified by
	-- the right click handler.
	if def.on_rightclick then
		def.on_rightclick (door_node, node, self)
	end
end

function mob_class:gwp_open_and_memorize_door (door, dtime)
	local door_node = mcl_util.get_nodepos (door)
	local node = core.get_node (door_node)
	if core.get_item_group (node.name, "door") ~= 0
		and core.get_item_group (node.name, "door_iron") == 0 then
		-- Don't open any doors that are still in or bordering
		-- proto-chunks, lest a subsequent regeneration
		-- operation restore a closed door node without
		-- replacing its metadata.
		if not gwp_node_regeneration_possible_p (door_node) then
			if not mcl_doors.is_open (door_node) then
				self:gwp_open_door (door_node, node, dtime)
			end
			self:gwp_memorize_door (door)
		end
	end
end

local SQRT_HALF = math.sqrt (0.5)
local COS_15_DEG = math.cos (math.rad (15))

function mob_class:gwp_skip_waypoint (self_pos, next_wp, ahead)
	local dist_to_next_wp = vector.distance (next_wp, self_pos)

	if dist_to_next_wp < 2.0 then
		local dist_to_ahead = vector.distance (ahead, self_pos)

		-- Does the current position fall between the target
		-- waypoint and the waypoint ahead of it?
		local dir = vector.direction (self_pos, ahead)
		local dir1 = vector.direction (self_pos, next_wp)
		local dot = vector.dot (dir, dir1)

		-- Is it safe to pass directly onto the next waypoint?
		if dist_to_ahead < dist_to_next_wp
			or dist_to_next_wp < SQRT_HALF then
			return dot < 0
		elseif dot < 0 then
			-- Otherwise, is the horizontal direction from
			-- the current position to the waypoint ahead
			-- approximately identical to that from the
			-- target waypoint behind to the current?
			local dx_to_ahead = ahead.x - self_pos.x
			local dz_to_ahead = ahead.z - self_pos.z
			local dir_to_ahead
				= vector.new (dx_to_ahead, 0, dz_to_ahead)
			local dx_to_self = self_pos.x - next_wp.x
			local dz_to_self = self_pos.z - next_wp.z
			local dir_to_self
				= vector.new (dx_to_self, 0, dz_to_self)
			dir_to_ahead = vector.normalize (dir_to_ahead)
			dir_to_self = vector.normalize (dir_to_self)

			local dot = vector.dot (dir_to_ahead, dir_to_self)
			if dot > COS_15_DEG then
				return true
			end
		end
	end
	return false
end

function mob_class:gwp_next_waypoint (dtime)
	local waypoints = self.waypoints
	local n_waypoints = #waypoints
	if n_waypoints < 1 then
		self:cancel_navigation ()
		self:halt_in_tracks ()
		if self.callback_arrived then
			self:callback_arrived ()
		end
		return
	end
	local next_wp = waypoints[#waypoints]
	local prev_wp = next_wp
	local self_pos = self.object:get_pos ()
	local dist_to_xcenter = math.abs (next_wp.x - self_pos.x)
	local dist_to_ycenter = math.abs (next_wp.y - self_pos.y)
	local dist_to_zcenter = math.abs (next_wp.z - self_pos.z)
	local cbox = self.collisionbox
	local girth = math.max (cbox[4] - cbox[1], cbox[6] - cbox[3])
	local mindist = girth > 0.75 and girth / 2 or 0.75 - girth / 2
	local ahead = n_waypoints > 1 and waypoints[#waypoints - 1]

	-- Be less tolerant on the approach to a door.
	if self.can_open_doors
		and (next_wp.class == "DOOR_WOOD_CLOSED"
		     or next_wp.class == "DOOR_OPEN"
		     or ahead and (ahead.class == "DOOR_OPEN"
					or ahead.class == "DOOR_WOOD_CLOSED")) then
		mindist = math.min (mindist, 0.25)
	end

	if dist_to_xcenter < mindist
		and dist_to_zcenter < mindist
		and dist_to_ycenter < 1.0 then
		self._last_wp = {
			x = next_wp.x,
			y = next_wp.y,
			z = next_wp.z,
			x_offset = next_wp.x_offset,
			y_offset = next_wp.y_offset,
		}
		next_wp = ahead
		waypoints[#waypoints] = nil
		if #waypoints > 1 then
			ahead = waypoints[#waypoints - 1]
		end
	end

	-- Is this mob already en route to the next waypoint?
	if #waypoints > 1
		and self:gwp_skip_waypoint (self_pos, next_wp, ahead) then
		self._last_wp = {
			x = next_wp.x,
			y = next_wp.y,
			z = next_wp.z,
			x_offset = next_wp.x_offset,
			y_offset = next_wp.y_offset,
		}
		next_wp = ahead
		waypoints[#waypoints] = nil
	end

	if next_wp then
		if self.movement_goal ~= "jump" then
			-- Head to the center of the waypoint.
			self.movement_goal = "go_pos"
		end
		self.movement_target = next_wp
		self.movement_velocity = self.gowp_velocity or self.movement_speed

		-- Open doors that are encountered, but remember to
		-- close them behind us.
		if self.can_open_doors
			and (next_wp.class == "DOOR_WOOD_CLOSED"
				or next_wp.class == "DOOR_OPEN") then
			self:gwp_open_and_memorize_door (next_wp, dtime)
		end
	else
		self:cancel_navigation ()
		self:halt_in_tracks ()
		if self.callback_arrived then
			self:callback_arrived ()
		end
	end

	-- If a waypoint that has been put behind is a closed door,
	-- open it also.
	if prev_wp ~= next_wp
		and self.can_open_doors
		and (prev_wp.class == "DOOR_WOOD_CLOSED"
			or prev_wp.class == "DOOR_OPEN") then
		self:gwp_open_and_memorize_door (prev_wp, dtime)
	end
end

local function obstruction_is_water (name, def)
	-- Water source blocks are always traversible.
	return is_water_source (name)
end

local function standing_in_water (self)
	return core.get_item_group (self.standing_in, "water") ~= 0
end

local function aquatic_gwp_skip_waypoint (self, self_pos, next_wp, ahead)
	local cbox = self.collisionbox
	local bottom = {
		x = self_pos.x,
		y = self_pos.y + cbox[2],
		z = self_pos.z,
	}
	local ahead_adj = {
		x = ahead.x,
		-- Test a position slightly above the
		-- target position to deal with
		-- grazing lines of sight.
		y = ahead.y + (cbox[5] - cbox[2]) / 2,
		z = ahead.z,
	}
	local do_line_of_sight_check
		= self.swims or self.airborne or self._swims_specially
		or (self.amphibious and standing_in_water (self))

	if do_line_of_sight_check
		and self:line_of_sight (bottom, ahead_adj,
					obstruction_is_water) then
		return true
	end

	return mob_class.gwp_skip_waypoint (self, self_pos, next_wp, ahead)
end

function mob_class:gwp_configure_default_mob ()
	self.gwp_edges = mob_class.gwp_edges
	self.gwp_start = mob_class.gwp_start
	self.gwp_initialize = mob_class.gwp_initialize
	self.gwp_classify_node = mob_class.gwp_classify_node
	self.gwp_classify_for_movement
		= mob_class.gwp_classify_for_movement
	self.gwp_skip_waypoint = mob_class.gwp_skip_waypoint
end

function mob_class:gwp_configure_aquatic_mob (nocopy)
	self.gwp_edges = waterbound_gwp_edges
	self.gwp_start = waterbound_gwp_start
	self.gwp_initialize = waterbound_gwp_initialize
	self.gwp_classify_node = waterbound_gwp_classify_node
	self.gwp_classify_for_movement
		= waterbound_gwp_classify_for_movement
	self.gwp_skip_waypoint = aquatic_gwp_skip_waypoint

	if not nocopy then
		local new_penalties = table.copy (mob_class.gwp_penalties)
		new_penalties.WATER = 0.0
		self.gwp_penalties = new_penalties
	end
end

function mob_class:gwp_configure_airborne_mob ()
	self.gwp_edges = airborne_gwp_edges
	self.gwp_start = airborne_gwp_start
	self.gwp_initialize = airborne_gwp_initialize
	self.gwp_classify_node = airborne_gwp_classify_node
	self.gwp_classify_for_movement
		= airborne_gwp_classify_for_movement
	self.gwp_skip_waypoint = aquatic_gwp_skip_waypoint
end

function mob_class:gwp_configure_amphibious_mob ()
	self.gwp_edges = amphibious_gwp_edges
	self.gwp_start = amphibious_gwp_start
	self.gwp_skip_waypoint = aquatic_gwp_skip_waypoint
	local new_penalties = table.copy (mob_class.gwp_penalties)
	new_penalties.WATER = 0.0
	self.gwp_penalties = new_penalties
end
