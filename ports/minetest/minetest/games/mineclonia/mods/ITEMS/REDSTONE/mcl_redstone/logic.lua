local wireflag_tab = mcl_redstone._wireflag_tab
local opaque_tab = mcl_redstone._solid_opaque_tab

-- get_power, update and init callbacks by name
local get_power_tab = {}
local update_tab = {}
local init_tab = {}
local on_observer_change_tab = {}

local action_tab = mcl_redstone._action_tab

local function check_bit(n, b)
	return bit.band(n, bit.lshift(1, b)) ~= 0
end

-- 0-3 correspond to the direction bits in wireflags.
local sixdirs = {
	[0] = vector.new(0, 0, 1),
	[1] = vector.new(1, 0, 0),
	[2] = vector.new(0, 0, -1),
	[3] = vector.new(-1, 0, 0),
	[4] = vector.new(0, -1, 0),
	[5] = vector.new(0, 1, 0),
}

local wiredirs = {
	[0x1] = {wire = vector.new(0, 0, -1)},
	[0x2] = {wire = vector.new(-1, 0, 0)},
	[0x4] = {wire = vector.new(0, 0, 1)},
	[0x8] = {wire = vector.new(1, 0, 0)},
}

local wiredirs_up = {
	[0x1] = {wire = vector.new(0, 1, -1), obstruct = vector.new(0, 1, 0)},
	[0x2] = {wire = vector.new(-1, 1, 0), obstruct = vector.new(0, 1, 0)},
	[0x4] = {wire = vector.new(0, 1, 1), obstruct = vector.new(0, 1, 0)},
	[0x8] = {wire = vector.new(1, 1, 0), obstruct = vector.new(0, 1, 0)},
}

local wiredirs_down = {
	[0x1] = {wire = vector.new(0, -1, -1), obstruct = vector.new(0, 0, -1)},
	[0x2] = {wire = vector.new(-1, -1, 0), obstruct = vector.new(-1, 0, 0)},
	[0x4] = {wire = vector.new(0, -1, 1), obstruct = vector.new(0, 0, 1)},
	[0x8] = {wire = vector.new(1, -1, 0), obstruct = vector.new(1, 0, 0)},
}

local function iterate_wire_neighbours(wireflags)
	local i = 1
	local state = 0
	-- `state` is a special variable that meansL
	-- 0: now returning entry from the block to the side
	-- 1: now returning entry from the block to the side and up
	-- 2: now returning entry from the block to the side and down
	return function(wireflags)
		if state == 0 then
			while i <= 8 do
				local val = bit.band(wireflags, bit.bor(i, bit.lshift(i, 4)))
				local tmp = wiredirs[i]
				if val == i then
					-- if goes to the side of that block
					state = 2
					return tmp
				elseif val ~= 0 then
					-- if goes up a block
					state = 1
					return tmp
				end
				i = i * 2
			end
			return
		elseif state == 1 then
			state = 2
			return wiredirs_up[i]
		else
			local tmp = wiredirs_down[i]
			i = i * 2
			state = 0
			return tmp
		end
	end, wireflags
end

-- Get power from direct neighbours at pos. Returns "weak" and "strong" power.
--  weak:                soft powered. (i.e. activates components, doesn't power blocks.)
--  strong:              hard powered, strong power
--  weak_from_wire_only: hard powered, weak power. (doesn't power wire through blocks.)
local function get_node_power(pos, include_wire)
	local weak = 0
	local strong = 0
	local weak_from_wire_only = 0

	for i, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = core.get_node(pos2)

		if get_power_tab[node2.name] then
			local power, is_strong = get_power_tab[node2.name](node2, -dir)

			weak = math.max(weak, power)
			if is_strong then
				strong = math.max(strong, power)
			end
		elseif include_wire and wireflag_tab[node2.name] and (i == 5 or check_bit(wireflag_tab[node2.name], i)) then
			-- Wire is above or pointing towards this node.
			weak = math.max(weak, bit.band(node2.param2, 0xF))
			weak_from_wire_only = math.max(weak_from_wire_only, bit.band(node2.param2, 0xF))
		end
	end

	return weak, strong, weak_from_wire_only
end

-- Get strong power from neighbours (including opaque nodes) at pos.
local function get_node_power_2(pos)
	local max = get_node_power(pos)
	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = core.get_node(pos2)

		if opaque_tab[node2.name] then
			local _, power2 = get_node_power(pos2)
			max = math.max(max, power2)
		end
	end

	return max
end

-- Set/add a position to mcl_redstone._pending_updates.
local function set_pending_update(pos, node_name)
	if node_name and not update_tab[node_name] then
		return
	end
	mcl_redstone._pending_updates[core.hash_node_position(pos)] = pos
end

-- Propagate redstone power through wires. 'clear_queue' is a queue of events
-- were power which is lowered/removed. 'fill_queue' is a queue of events were
-- power is added/raised. 'update' is a table which gets populated with
-- positions that should get redstone update events.
local function propagate_wire(clear_nodes, fill_nodes, updates)
	local fill_queue = mcl_util.queue()
	local clear_queue = mcl_util.queue()
	local nodecache = {}
	local updates_ = {}

	local function get_node(pos)
		local h = core.hash_node_position(pos)
		if not nodecache[h] then
			nodecache[h] = core.get_node(pos)
		end
		return nodecache[h]
	end

	local function swap_node(pos, node)
		local h = core.hash_node_position(pos)
		node.dirty = true
		nodecache[h] = node
	end

	local function set_power(pos, power)
		local node = get_node(pos)
		node.param2 = bit.bor(bit.band(node.param2, 0xF0), power)
		node.dirty = true
	end

	local function get_power(node)
		if wireflag_tab[node.name] then
			return bit.band(node.param2, 0xF), bit.rshift(node.param2, 4)
		end
		return 0, 0
	end

	for _, entry in pairs(clear_nodes) do
		swap_node(entry.pos, {
			name = get_node(entry.pos).name,
			param2 = 0
		})
		clear_queue:enqueue(entry)
	end

	while clear_queue:size() > 0 do
		local entry = clear_queue:dequeue()
		local pos = entry.pos
		local power = entry.power
		local node = core.get_node(pos)

		updates_[core.hash_node_position(pos)] = pos

		for dir in iterate_wire_neighbours(wireflag_tab[node.name] or 0xFF) do
			if not dir.obstruct or not opaque_tab[get_node(pos:add(dir.obstruct)).name] then
				local pos2 = pos:add(dir.wire)
				local node2 = get_node(pos2)
				local power2, power2_direct = get_power(node2)

				if power2 > 0 then
					if power2 < power then
						set_power(pos2, 0)
						clear_queue:enqueue({pos = pos2, power = power2})
						if power2_direct > 0 then
							table.insert(fill_nodes, {pos = pos2, power = power2_direct})
						end
					else
						fill_queue:enqueue({pos = pos2, power = power2})
					end
				end
			end
		end
	end

	for _, entry in pairs(fill_nodes) do
		swap_node(entry.pos, {
			name = get_node(entry.pos).name,
			param2 = bit.bor(bit.lshift(entry.power, 4), entry.power)
		})
		fill_queue:enqueue(entry)
	end

	while fill_queue:size() > 0 do
		local entry = fill_queue:dequeue()
		local pos = entry.pos
		local power = entry.power
		local power2 = power - 1

		local nname = core.get_node(pos:subtract(vector.new(0, 1, 0))).name
		local on_slab = mcl_redstone._slab_tab[nname] ~= nil

		updates_[core.hash_node_position(pos)] = pos

		for dir in iterate_wire_neighbours(wireflag_tab[core.get_node(pos).name]) do
			if not (on_slab and dir.wire.y < 0) and (not dir.obstruct or not opaque_tab[get_node(pos:add(dir.obstruct)).name]) then
				local pos2 = pos:add(dir.wire)
				local node2 = get_node(pos2)
				if wireflag_tab[node2.name] and get_power(node2) < power2 then
					set_power(pos2, power2)
					fill_queue:enqueue({pos = pos2, power = power2})
				end
			end
		end
	end

	for hash, node in pairs(nodecache) do
		if node.dirty then
			local pos = core.get_position_from_hash(hash)
			core.swap_node(pos, node)
			-- Note: Observers might trigger despite no change in power level if
			-- wire propagation were to swap a node just to change the upper bits in param2.
			mcl_redstone._notify_observer_neighbours(pos)
		end
	end

	for _, pos in pairs(updates_) do
		for _, dir in pairs(sixdirs) do
			local pos2 = pos:add(dir)
			local node2 = get_node(pos2)
			set_pending_update(pos2, node2.name)

			if opaque_tab[node2.name] then
				for _, dir in pairs(sixdirs) do
					local pos3 = pos2:add(dir)
					local node3 = get_node(pos3)
					set_pending_update(pos3, node3.name)
				end
			end
		end
	end
end

function mcl_redstone.get_power(pos, dir, option)
	core.load_area(pos:subtract(2), pos:add(2))

	-- Create table with keys corresponding to bits in wireflags to
	-- simplify wire direction checks.
	local dirs = {}
	for k, v in pairs(sixdirs) do
		if not dir or v == dir then
			dirs[k] = v
		end
	end

	local power = 0
	for i, dir in pairs(dirs) do
		local pos2 = pos:add(dir)
		local node2 = core.get_node(pos2)

		if get_power_tab[node2.name] then
			local power2 = get_power_tab[node2.name](node2, -dir)
			power = math.max(power, power2)
		elseif wireflag_tab[node2.name] and (i == 5 or check_bit(wireflag_tab[node2.name], i)) then
			power = math.max(power, bit.band(node2.param2, 0xF))
		elseif opaque_tab[node2.name] and option ~= "direct" then
			local _, strong, weak_from_wire = get_node_power(pos2, true)
			power = math.max(power, math.max(strong, weak_from_wire))
		end
	end

	return power
end

local function schedule_update(pos, update)
	local delay = update.delay or 1
	local priority = update.priority or 1000
	local oldnode = core.get_node(pos)
	update.param2 = update.param2 or 0

	mcl_redstone._schedule_update(delay, priority, pos, update, oldnode)
end

local function call_init(pos)
	local node = core.get_node(pos)
	if init_tab[node.name] then
		local ret = init_tab[node.name](pos, node)
		if ret then
			schedule_update(pos, ret)
		end
	end
end

function mcl_redstone._call_update(pos)
	local node = core.get_node(pos)
	if update_tab[node.name] then
		local ret = update_tab[node.name](pos, node)
		if ret then
			schedule_update(pos, ret)
		end
	end
end

-- TODO: A bit ugly, could be refactored.
function mcl_redstone.update_node(pos)
	set_pending_update(pos)
end

local function notify_observer(pos, node, from_pos)
	if on_observer_change_tab[node.name] then
		on_observer_change_tab[node.name](pos, node, from_pos)
	end
end

-- Update/notify neighbouring observing nodes at pos, aka "shape update".
function mcl_redstone._notify_observer_neighbours(pos)
	for _, dir in pairs(sixdirs) do
		local pos2  = pos:add(dir)
		local node2 = core.get_node(pos2)
		notify_observer(pos2, node2, pos)
	end
end

-- Update neighbouring wires and components at pos. Oldnode is the previous
-- node at the position.
local function update_neighbours(pos, oldnode, newnode)
	core.load_area(pos:subtract(20), pos:add(20))

	local fill_nodes = {}
	local clear_nodes = {}
	local node = newnode or core.get_node(pos)
	local ndef = core.registered_nodes[node.name]
	local oldndef = oldnode and core.registered_nodes[oldnode.name]
	local get_power = ndef and ndef._mcl_redstone and ndef._mcl_redstone.get_power
	local old_get_power = oldndef and oldndef._mcl_redstone and oldndef._mcl_redstone.get_power

	local function update_wire(pos, oldpower)
		if oldpower then
			table.insert(clear_nodes, {pos = pos, power = oldpower})
		end
		local power = get_node_power_2(pos)

		table.insert(fill_nodes, {pos = pos, power = power})
	end

	set_pending_update(pos, node.name)

	if not (get_power or old_get_power) then return end

	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local power2 = get_power and get_power(node, dir) or 0
		local oldpower2 = old_get_power and old_get_power(oldnode, dir) or 0

		if power2 ~= oldpower2 then
			local node2 = core.get_node(pos2)
			set_pending_update(pos2, node2.name)

			if wireflag_tab[node2.name] then
				update_wire(pos2, oldpower2)
			elseif opaque_tab[node2.name] then
				for i, dir in pairs(sixdirs) do
					local pos3 = pos2:add(dir)
					local node3 = core.get_node(pos3)
					set_pending_update(pos3, node3.name)

					if wireflag_tab[node3.name] then
						update_wire(pos3, math.max(oldpower2, 0))
					end
				end
			end
		end
	end

	propagate_wire(clear_nodes, fill_nodes)
end

-- Piston pusher nodes calls this during init to avoid circuits stopping if a
-- piston was extended just before a server restart. It is not a clean solution
-- but it works.
function mcl_redstone._update_neighbours(pos, oldnode, newnode)
	update_neighbours(pos, oldnode, newnode)
	if  (oldnode and action_tab[oldnode.name])
			or (newnode and action_tab[newnode.name]) then
		local callbacks = {}

		for _, func in pairs(oldnode and action_tab[oldnode.name] or {}) do
			callbacks[func] = true
		end
		for _, func in pairs(newnode and action_tab[newnode.name] or {}) do
			callbacks[func] = true
		end

		for func, _ in pairs(callbacks) do
			func(pos, oldnode, newnode)
		end
	end
end

function mcl_redstone.swap_node(pos, node)
	local oldnode = core.get_node(pos)
	if not node then print(debug.traceback("trying to place nil")) end
	core.swap_node(pos, node)
	mcl_redstone._update_neighbours(pos, oldnode, node)
end

local function opaque_update_neighbours(pos, update_observers)
	local fill_nodes = {}
	local clear_nodes = {}

	local function update_wire(pos)
		local oldpower = bit.band(core.get_node(pos).param2, 0xF)
		local power = get_node_power_2(pos)

		table.insert(clear_nodes, {pos = pos, power = oldpower})
		table.insert(fill_nodes, {pos = pos, power = power})
	end

	for _, dir in pairs(sixdirs) do
		local pos2 = pos:add(dir)
		local node2 = core.get_node(pos2)
		if wireflag_tab[node2.name] then
			update_wire(pos2)
		elseif update_tab[node2.name] then
			set_pending_update(pos2, node2.name)
		end

		if update_observers then
			notify_observer(pos2, node2, pos)
		end
	end

	propagate_wire(clear_nodes, fill_nodes)
end

local function update_wire(pos, oldnode)
	local fill_nodes = {}
	local clear_nodes = {}
	local node = core.get_node(pos)
	local power = get_node_power_2(pos)

	table.insert(clear_nodes, {pos = pos, power = oldnode and oldnode.param2 or 0})
	if wireflag_tab[node.name] then
		table.insert(fill_nodes, {pos = pos, power = power})
	end

	propagate_wire(clear_nodes, fill_nodes)
end

-- Override nodes to perform redstone updates on changes.
core.register_on_mods_loaded(function()
	for name, ndef in pairs(core.registered_nodes) do
		local old_construct = ndef.on_construct
		local old_destruct = ndef.after_destruct
		if opaque_tab[name] then
			core.override_item(name, {
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					mcl_redstone._update_opaque_connections(pos)
					mcl_redstone.after(0, function()
						opaque_update_neighbours(pos, true) -- also notifies observers
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					mcl_redstone._update_opaque_connections(pos)
					mcl_redstone.after(0, function()
						opaque_update_neighbours(pos, true) -- also notifies observers
					end)
				end,
			})
		elseif core.get_item_group(name, "redstone_wire") == 0 and not ndef._mcl_redstone
		and name ~= "air" then
			core.override_item(name, {
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					mcl_redstone.after(0, function()
						mcl_redstone._notify_observer_neighbours(pos)
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					mcl_redstone.after(0, function()
						mcl_redstone._notify_observer_neighbours(pos)
					end)
				end,
			})
		end

		if core.get_item_group(name, "redstone_wire") ~= 0 then
			local old_construct = ndef.on_construct
			local old_destruct = ndef.after_destruct
			core.override_item(name, {
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					update_wire(pos)
					mcl_redstone.after(0, function()
						mcl_redstone._notify_observer_neighbours(pos)
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					update_wire(pos, oldnode)
					mcl_redstone.after(0, function()
						mcl_redstone._notify_observer_neighbours(pos)
					end)
				end,
			})
		end

		if ndef._mcl_redstone then
			local init = ndef._mcl_redstone.init or ndef._mcl_redstone.update
			get_power_tab[name]          = ndef._mcl_redstone.get_power
			init_tab[name]               = init
			update_tab[name]             = ndef._mcl_redstone.update
			on_observer_change_tab[name] = ndef._mcl_redstone.on_observer_neighbor_change

			local old_construct = ndef.on_construct
			local old_destruct = ndef.after_destruct
			core.override_item(name, {
				groups = table.merge(ndef.groups, {
					redstone_init = init and 1,
					redstone_get_power = ndef._mcl_redstone.get_power and 1,
				}),
				on_construct = function(pos)
					if old_construct then
						old_construct(pos)
					end
					if ndef._mcl_redstone.connects_to then
						mcl_redstone._connect_with_wires(pos)
					end
					mcl_redstone._abort_pending_update(pos)
					mcl_redstone.after(0, function()
						if init then
							call_init(pos)
						end
						if ndef._mcl_redstone.get_power then
							update_neighbours(pos)
						end
						mcl_redstone._notify_observer_neighbours(pos)
					end)
				end,
				after_destruct = function(pos, oldnode)
					if old_destruct then
						old_destruct(pos, oldnode)
					end
					if ndef._mcl_redstone.connects_to then
						mcl_redstone._connect_with_wires(pos)
					end
					if ndef._mcl_redstone.get_power then
						mcl_redstone._abort_pending_update(pos)
						mcl_redstone.after(0, function()
							update_neighbours(pos, oldnode)
							mcl_redstone._notify_observer_neighbours(pos)
						end)
					else
						mcl_redstone.after(0, function()
							mcl_redstone._notify_observer_neighbours(pos)
						end)
					end
				end,
			})
		end
	end
end)

core.register_lbm({
	label = "Perform redstone node initialization",
	name = "mcl_redstone:update",
	nodenames = {"group:redstone_init"},
	run_at_every_load = true,
	action = function(pos, node, dtime)
		call_init(pos)
	end,
})

core.register_lbm({
	label = "Perform redstone updates to neighbouring nodes",
	name = "mcl_redstone:update_neighbours",
	nodenames = {"group:redstone_get_power"},
	run_at_every_load = true,
	action = function(pos, node, dtime)
		update_neighbours(pos)
	end,
})
