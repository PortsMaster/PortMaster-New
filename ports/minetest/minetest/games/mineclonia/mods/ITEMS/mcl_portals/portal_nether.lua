local S = minetest.get_translator("mcl_portals")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local portal_search_groups = { "group:building_block", "group:dig_by_water", "group:liquid" }

local TELEPORT_DELAY = 3
local TELEPORT_COOLOFF = 4

local MIN_PORTAL_NODES = 6
local MAX_PORTAL_NODES = 256

local NETHER_SCALE = 8
local MAP_EDGE = math.floor(mcl_vars.mapgen_limit / (16 * 5)) * 16 * 5 - 16 * 3
local MAP_SIZE = MAP_EDGE * 2

local mod_storage_keys = {
	overworld = "overworld_portals",
	nether = "nether_portals",
}

-- List of positions of portals in the nether and overworld.
local portals = {
	overworld = {},
	nether = {},
}
local portal_count = 0
for dim, key in pairs(mod_storage_keys) do
	for _, portal in pairs(minetest.deserialize(mcl_portals.storage:get_string(key)) or {}) do
		portal = vector.copy(portal)
		portals[dim][minetest.hash_node_position(portal)] = portal
		portal_count = portal_count + 1
	end
end

-- The distance portals can be apart and still link.
local link_distance = {
	overworld = 16 * NETHER_SCALE,
	nether = 16,
}

-- The min and max y levels when searching for a place to generate a new nether
-- portal.
local search_y_min = {
	overworld = mcl_vars.mg_bedrock_overworld_max + 1,
	nether = mcl_vars.mg_bedrock_nether_bottom_max + 1,
}
local search_y_max = {
	overworld = mcl_vars.mg_overworld_max_official,
	nether = mcl_vars.mg_bedrock_nether_top_min - 6,
}

-- Table of objects (including players) which were recently teleported by a
-- nether portal. They have a brief cooloff period before they can teleport
-- again. This prevents annoying back-and-forth teleportation.
local portal_cooloff = {}
function mcl_portals.nether_portal_cooloff(object)
	return portal_cooloff[object]
end

-- Get list of portals in dimension as an array.
local function get_portals(dim)
	local values = {}
	for _, v in pairs(portals[dim]) do
		table.insert(values, v)
	end
	return values
end

local function update_mod_storage(dim)
	mcl_portals.storage:set_string(mod_storage_keys[dim], minetest.serialize(get_portals(dim)))
end

local function register_portal(pos)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if not portals[dim] then
		return
	end
	local hash = minetest.hash_node_position(pos)
	if not portals[dim][hash] then
		portals[dim][hash] = pos
		portal_count = portal_count + 1
		minetest.log("action", "[mcl_portal] Registered portal at " .. tostring(pos))
		minetest.log("action", "[mcl_portal] There are " .. portal_count .. " registered portals in total")
		update_mod_storage(dim)
	end
end

local function unregister_portal(pos)
	if not pos then
		return
	end
	local dim = mcl_worlds.pos_to_dimension(pos)
	if not portals[dim] then
		return
	end
	local hash = minetest.hash_node_position(pos)
	if portals[dim][hash] then
		portals[dim][hash] = nil
		portal_count = portal_count - 1
		minetest.log("action", "[mcl_portal] Registered portal at " .. tostring(pos))
		minetest.log("action", "[mcl_portal] There are " .. portal_count .. " registered portals in total")
		update_mod_storage(dim)
	end
end

-- Rotate vector 90 degrees if 'param2 % 2 == 1'.
local function orient(pos, param2)
	if (param2 % 2) == 1 then
		return vector.new(pos.z, pos.y, pos.x)
	end
	return pos
end

local function queue()
	return {
		front = 1,
		back = 1,
		queue = {},
		enqueue = function(self, value)
			self.queue[self.back] = value
			self.back = self.back + 1
		end,
		dequeue = function(self) local value = self.queue[self.front]
			if not value then
				return
			end
			self.queue[self.front] = nil
			self.front = self.front + 1
			return value
		end,
		size = function(self)
			return self.back - self.front
		end,
	}
end

-- Check if node is replacable with a portal node.
local function replacable_with_portal(name)
	return name == "air" or
		minetest.get_item_group(name, "fire") ~= 0 or
		minetest.get_item_group(name, "dig_by_water") ~= 0
end

-- Gets the position in a portal which players are teleported to.
local function get_center_portal(nodes)
	local center = vector.zero()
	for _, pos in pairs(nodes) do
		center = center + pos
	end
	center = center:divide(#nodes):round()

	while replacable_with_portal(minetest.get_node(center:offset(0, -1, 0)).name) do
		center = center:offset(0, -1, 0)
	end

	return center
end

-- Initialize metadata for a portal containing nodes. Nodes is a list of
-- positions for the portal nodes.
local function init_portal_meta(nodes, portal)
	for _, pos in pairs(nodes) do
		minetest.get_meta(pos):set_string("portal", minetest.serialize(portal))
	end
end

-- Attempts to light a nether portal at the specified position and param2 value.
-- The position must be one of the nodes inside the frame which must be filled
-- only with nodes diggable by water. Returns true if portal was created, false
-- otherwise.
local function light_nether_portal(pos, param2)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim ~= "overworld" and dim ~= "nether" then
		return false
	end

	local nodes = {}
	local queue = queue()
	local checked = {}

	queue:enqueue(pos)
	while queue:size() > 0 do
		local pos = queue:dequeue()
		local hash = minetest.hash_node_position(pos)

		if not checked[hash] then
			local name = minetest.get_node(pos).name
			if replacable_with_portal(name) then
				queue:enqueue(pos + orient(vector.new(0, -1, 0), param2))
				queue:enqueue(pos + orient(vector.new(0, 1, 0), param2))
				queue:enqueue(pos + orient(vector.new(-1, 0, 0), param2))
				queue:enqueue(pos + orient(vector.new(1, 0, 0), param2))

				if #nodes > MAX_PORTAL_NODES then
					return false
				end
				table.insert(nodes, pos)
			elseif name ~= "mcl_core:obsidian" then
				return false
			end

			checked[hash] = true
		end
	end

	local center = get_center_portal(nodes)
	if #nodes >= MIN_PORTAL_NODES and replacable_with_portal(minetest.get_node(center:offset(0, 1, 0)).name) then
		minetest.bulk_set_node(nodes, {
			name = "mcl_portals:portal",
			param2 = param2,
		})
		init_portal_meta(nodes, center)
		register_portal(center)
		return true
	end
	return false
end

-- Get the positions of portal nodes adjacent to position.
local function get_adjacent_portal_nodes(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "mcl_portals:portal" then
		return {}
	end

	local param2 = node.param2
	local checked_tab = { [minetest.hash_node_position(pos)] = true }
	local nodes = { pos }

	local function check_remove(pos)
		local hash = minetest.hash_node_position(pos)
		if checked_tab[hash] then
			return
		end

		local node = minetest.get_node(pos)
		if node and node.name == "mcl_portals:portal" and (param2 == nil or node.param2 == param2) then
			table.insert(nodes, pos)
			checked_tab[hash] = true
		end
	end

	local i = 1
	while i <= #nodes do
		pos = nodes[i]
		if param2 % 2 == 0 then
			check_remove({x = pos.x - 1, y = pos.y, z = pos.z})
			check_remove({x = pos.x + 1, y = pos.y, z = pos.z})
		else
			check_remove({x = pos.x, y = pos.y, z = pos.z - 1})
			check_remove({x = pos.x, y = pos.y, z = pos.z + 1})
		end
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
		i = i + 1
	end

	return nodes
end

-- For backwards compatibility, update and register source and destination
-- portals which have the old 'target_portal' metadata.
local function update_old_meta(portal)
	local target_hash = tonumber(minetest.get_meta(portal):get_string("target_portal"))

	if target_hash then
		for _, pos in pairs(get_adjacent_portal_nodes(portal)) do
			minetest.get_meta(pos):set_string("target_portal", "")
		end

		-- Initialize the destination portal so it will link with the
		-- current portal.
		local target_portal = minetest.get_position_from_hash(target_hash)
		if mcl_vars.get_node(target_portal).name ~= "mcl_portals:portal" then
			return
		end

		local nodes = get_adjacent_portal_nodes(target_portal)
		for _, target_portal in pairs(nodes) do
			minetest.get_meta(target_portal):set_string("portal_portal", "")
		end

		local center = get_center_portal(nodes)
		init_portal_meta(nodes, center)
		register_portal(center)
	end
end

-- Get portal at specified position. Returns (pos, node) for the portal.
local function get_portal(pos)
	local node = mcl_vars.get_node(pos)
	if node.name == "mcl_portals:portal" then
		update_old_meta(pos) -- For backwards compatibility.

		local portal = minetest.deserialize(minetest.get_meta(pos):get_string("portal"))
		if portal then
			return vector.copy(portal), node
		else
			local nodes = get_adjacent_portal_nodes(pos)
			local center = get_center_portal(nodes)
			init_portal_meta(nodes, center)
			return center, minetest.get_node(pos)
		end
	end
end

-- Destroy a nether portal. Connected portal nodes are searched and removed
-- using 'bulk_set_node'. This function is called on destruction of portal and
-- obsidian nodes.
--
-- The flag 'destroying_portal' is used to avoid this function being called
-- recursively through callbacks in 'bulk_set_node'.
local destroying_portal = false
local function destroy_portal(pos, node)
	if destroying_portal then
		return
	end
	destroying_portal = true

	if get_portal(pos) then
		unregister_portal(get_portal(pos))
	end
	minetest.bulk_set_node(get_adjacent_portal_nodes(pos), { name = "air" })
	destroying_portal = false
end

local function nether_to_overworld(x)
	local x = x * NETHER_SCALE + MAP_EDGE
	return MAP_EDGE - math.abs(x % (2 * MAP_SIZE) - MAP_SIZE)
end

local function overworld_to_nether(x)
	return x / NETHER_SCALE
end

-- Build portal at position facing the direction specified in param2. If
-- bad_spot is true, then it will make a small platform and clear air space
-- above it.
local function build_portal(pos, param2, bad_spot)
	local portals = {}
	local obsidian = {}
	local air = {}

	for i = -1, 2 do
		table.insert(obsidian, pos + orient(vector.new(i, -1, 0), param2))
		table.insert(obsidian, pos + orient(vector.new(i, 3, 0), param2))
	end

	for i = 0, 2 do
		table.insert(obsidian, pos + orient(vector.new(-1, i, 0), param2))
		table.insert(portals, pos + orient(vector.new(0, i, 0), param2))
		table.insert(portals, pos + orient(vector.new(1, i, 0), param2))
		table.insert(obsidian, pos + orient(vector.new(2, i, 0), param2))
	end

	if bad_spot then
		table.insert(obsidian, pos + orient(vector.new(0, -1, -1), param2))
		table.insert(obsidian, pos + orient(vector.new(1, -1, -1), param2))
		table.insert(obsidian, pos + orient(vector.new(0, -1, 1), param2))
		table.insert(obsidian, pos + orient(vector.new(1, -1, 1), param2))
		for i = 0, 2 do
			table.insert(air, pos + orient(vector.new(0, i, -1), param2))
			table.insert(air, pos + orient(vector.new(1, i, -1), param2))
			table.insert(air, pos + orient(vector.new(0, i, 1), param2))
			table.insert(air, pos + orient(vector.new(1, i, 1), param2))
		end
	end

	minetest.bulk_set_node(obsidian, { name = "mcl_core:obsidian" })
	minetest.bulk_set_node(air, { name = "air" })
	minetest.bulk_set_node(portals, { name = "mcl_portals:portal", param2 = param2 })
	init_portal_meta(portals, pos)
	register_portal(pos)

	minetest.log("action", "[mcl_portal] Destination portal generated at " .. tostring(pos))
end

local function teleport_finished(obj)
	minetest.after(TELEPORT_COOLOFF, function(obj)
		portal_cooloff[obj] = nil
	end, obj)
end

local function finalize_teleport(obj, pos, old_param2, new_param2)
	-- Adjust the player's look direction depending on the relative
	-- direction of the portals.
	if obj:is_player() then
		local new_look = (old_param2 - new_param2 + 2) * math.pi / 2
		obj:set_look_horizontal(obj:get_look_horizontal() + new_look)
	end

	obj:set_pos(pos)
	if obj:is_player() then
		minetest.sound_play("mcl_portals_teleport", {pos = pos, gain = 0.5, max_hear_distance = 1}, true)
		mcl_worlds.dimension_change(obj)
		minetest.log("action", "[mcl_portal] " .. obj:get_player_name() .. " teleported to " .. tostring(pos))
	else
		local l = obj:get_luaentity()
		if l and l.is_mob then
			l._just_portaled = 5
		end
	end

	teleport_finished(obj)
end

local function build_portal_and_teleport(obj, pos, param2, bad_spot)
	build_portal(pos, param2, bad_spot)
	finalize_teleport(obj, pos, param2, param2)
end

local function can_place_portal(pos, player_name)
	local pos1 = pos:offset(-8, -8, -8)
	local pos2 = pos:offset(8, 8, 8)
	return not minetest.is_area_protected(pos1, pos2, player_name)
end

-- Check if portal with param2 can be placed at position.
local function suitable_for_portal(pos, param2)
	local pos1 = pos + orient(vector.new(-1, 0, -1), param2)
	local pos2 = pos + orient(vector.new(2, 0, 1), param2)
	local ground_nodes = minetest.find_nodes_in_area(pos1, pos2, portal_search_groups)
	if #ground_nodes ~= 12 then
		return false
	end

	local air_pos1 = pos + orient(vector.new(-1, 1, -1), param2)
	local air_pos2 = pos + orient(vector.new(2, 4, 1), param2)
	local air_nodes = minetest.find_nodes_in_area(air_pos1, air_pos2, { "air" })
	return #air_nodes == 48
end

-- Check if object is in portal, returns the (position, node) of the portal if
-- it is, otherwise nil.
local function in_portal(obj)
	local pos = obj:get_pos()
	if not pos then
		return
	end
	pos.y = math.ceil(pos.y)
	pos = vector.round(pos)

	return get_portal(pos)
end

local function portal_distance(a, b)
	return math.max(math.abs(a.x - b.x), math.abs(math.abs(a.z - b.z)))
end

-- Scan emerged area and build a portal at a suitable spot. If no suitable spot
-- is found, then it will build the portal at a random location.
local function portal_emerge_area(blockpos, action, calls_remaining, param)
	if param.done_flag or calls_remaining ~= 0 then
		return
	end
	local portal = param.portal
	local dim = param.dim
	local target = param.target
	local minpos = param.minpos
	local maxpos = param.maxpos
	local param2 = param.param2
	local obj = param.obj
	local player_name = obj:get_player_name()

	-- Since there is a significant delay until the callback is run, we do
	-- another check if the player is still standing in the portal.
	if not in_portal(obj) then
		portal_cooloff[obj] = nil
	end

	local function finalize(obj, pos, param2, bad_pos)
		-- Move portal down one node if on snow cover or grass.
		if minetest.get_item_group(minetest.get_node(pos).name, "dig_by_water") ~= 0 then
			pos.y = pos.y - 1
		end

		pos = vector.new(pos.x, pos.y + 1, pos.z)
		build_portal_and_teleport(obj, pos, param2, bad_pos)
		param.done_flag = true
	end

	local liquid_pos
	local nodes = minetest.find_nodes_in_area_under_air(minpos, maxpos, portal_search_groups)
	for _, pos in pairs(nodes) do
		if suitable_for_portal(pos, param2) and can_place_portal(pos, player_name) and portal_distance(pos, target) < link_distance[dim] then
			if minetest.get_item_group(minetest.get_node(pos).name, "liquid") <= 0 then
				finalize(obj, pos, param2, false)
				return
			end
			liquid_pos = pos
		end
	end

	if liquid_pos then
		finalize(obj, liquid_pos, param2, true)
		return
	end

	-- 5 attempts to find a random spot which is not protected.
	for i = 1, 5 do
		local pos = vector.new(target.x, math.random(minpos.y, maxpos.y), target.z)
		if can_place_portal(pos, player_name) then
			finalize(obj, pos, param2, true)
			return
		end
	end

	minetest.sound_play("mcl_portals_teleport", {pos = obj:get_pos(), gain = 0.5, max_hear_distance = 1}, true)
	minetest.log("action", "[mcl_portal] Could not generate destination portal for " .. player_name .. " at " .. tostring(portal))
	minetest.remove_node(portal)
	teleport_finished(obj)
end

-- Get the target dimension and coordinate from portal located at position.
-- Returns (dimension, position).
local function get_teleport_target(pos)
	local dim = mcl_worlds.pos_to_dimension(pos)
	if dim == "overworld" then
		return "nether", vector.new(overworld_to_nether(pos.x), 0, overworld_to_nether(pos.z)):round()
	elseif dim == "nether" then
		return "overworld", vector.new(nether_to_overworld(pos.x), 0, nether_to_overworld(pos.z)):round()
	end
end

-- Get portal nearby position in dimension or nil.
local function get_linked_portal(dim, pos)
	local portals = get_portals(dim)

	table.sort(portals, function(a, b)
		return portal_distance(a, pos) < portal_distance(b, pos)
	end)

	for _, portal in pairs(portals) do
		if portal_distance(portal, pos) > link_distance[dim] then
			return
		end

		-- Check that it is still a portal (not destroyed).
		if get_portal(portal) then
			return portal
		else
			unregister_portal(portal)
		end
	end
end

local function teleport(obj)
	local portal, node = in_portal(obj)
	if not portal or portal_cooloff[obj] then
		return
	end

	local dim, target = get_teleport_target(portal)
	if not portals[dim] then
		return
	end

	register_portal(portal) -- Register portal if not already registered.
	portal_cooloff[obj] = true

	local linked_portal = get_linked_portal(dim, target)
	if linked_portal then
		local linked_node = minetest.get_node(linked_portal)
		finalize_teleport(obj, linked_portal, node.param2, linked_node.param2)
	elseif obj:is_player() then -- Generate portal and teleport.
		local param2 = node.param2
		local y_min = search_y_min[dim]
		local y_max = search_y_max[dim]
		local minpos = vector.new(target.x - 16, y_min, target.z - 16)
		local maxpos = vector.new(target.x + 16, y_max, target.z + 16)
		minetest.emerge_area(minpos, maxpos, portal_emerge_area, {
			obj = obj,
			param2 = param2,
			minpos = minpos,
			maxpos = maxpos,
			portal = portal,
			dim = dim,
			target = target,
			done_flag = false,
		})
	end
end

local function initiate_teleport(obj)
	local creative = minetest.is_creative_enabled(obj:is_player() and obj:get_player_name() or nil)
	minetest.after(creative and 0 or TELEPORT_DELAY, function()
		teleport(obj)
	end)
end

local function teleport_objs_in_portal(pos)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		local lua_entity = obj:get_luaentity()
		if obj:is_player() or lua_entity then
			initiate_teleport(obj)
		end
	end
end

local function emit_portal_particles(pos, node)
	local param2 = node.param2
	local direction = math.random(0, 1)
	local time = math.random() * 1.9 + 0.5

	local velocity = vector.new(math.random() - 0.5, math.random() - 0.5, math.random() * 0.7 + 0.3)
	local acceleration = vector.new(math.random() - 0.5, math.random() - 0.5, math.random() * 1.1 + 0.3)
	if param2 % 2 == 1 then
		velocity.x, velocity.z = velocity.z, velocity.x
		acceleration.x, acceleration.z = acceleration.z, acceleration.x
	end
	local distance = vector.add(vector.multiply(velocity, time), vector.multiply(acceleration, time * time / 2))
	if direction == 1 then
		if param2 % 2 == 1 then
			distance.x = -distance.x
			velocity.x = -velocity.x
			acceleration.x = -acceleration.x
		else
			distance.z = -distance.z
			velocity.z = -velocity.z
			acceleration.z = -acceleration.z
		end
	end
	distance = vector.subtract(pos, distance)
	for _, obj in pairs(minetest.get_objects_inside_radius(pos, 15)) do
		if obj:is_player() then
			minetest.add_particle({
				amount = 1,
				pos = distance,
				velocity = velocity,
				acceleration = acceleration,
				expiration_time = time,
				size = 0.3 + math.random() * (1.8 - 0.3),
				collisiondetection = false,
				texture = "mcl_particles_nether_portal.png",
				playername = obj:get_player_name(),
			})
		end
	end
end

local longdesc = minetest.registered_nodes["mcl_core:obsidian"]._doc_items_longdesc .. "\n" .. S("Obsidian is also used as the frame of Nether portals.")
local usagehelp = S("To open a Nether portal, place an upright frame of obsidian with a width of at least 4 blocks and a height of 5 blocks, leaving only air in the center. After placing this frame, light a fire in the obsidian frame. Nether portals only work in the Overworld and the Nether.")

function mcl_portals.light_nether_portal(pos)
	for param2 = 0, 1 do
		if light_nether_portal(pos, param2) then
			return true
		end
	end
	return false
end

minetest.override_item("mcl_core:obsidian", {
	_doc_items_longdesc = longdesc,
	_doc_items_usagehelp = usagehelp,
	on_destruct = function(pos, node)
		local function check_remove(pos, param2)
			local node = minetest.get_node(pos)
			if node.name == "mcl_portals:portal" and (not param2 or node.param2 % 2 == param2) then
				minetest.remove_node(pos)
			end
		end

		check_remove({x = pos.x - 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x + 1, y = pos.y, z = pos.z}, 0)
		check_remove({x = pos.x, y = pos.y, z = pos.z - 1}, 1)
		check_remove({x = pos.x, y = pos.y, z = pos.z + 1}, 1)
		check_remove({x = pos.x, y = pos.y - 1, z = pos.z})
		check_remove({x = pos.x, y = pos.y + 1, z = pos.z})
	end,
	_on_ignite = function(user, pointed_thing)
		local pos = pointed_thing.above

		-- Light portal with param2 depending on where player is
		-- looking.
		local x_delta = user:get_pos().x - pos.x
		local z_delta = user:get_pos().z - pos.z
		local portal_placed = false
		if z_delta < 0 then
			portal_placed = light_nether_portal(pos, 0)
		end
		if not portal_placed and z_delta > 0 then
			portal_placed = light_nether_portal(pos, 2)
		end
		if not portal_placed and x_delta < 0 then
			portal_placed = light_nether_portal(pos, 1)
		end
		if not portal_placed then
			portal_placed = light_nether_portal(pos, 3)
		end

		if portal_placed then
			minetest.log("action", "[mcl_portal] Portal activated at " .. tostring(pos))
			if minetest.get_modpath("doc") then
				doc.mark_entry_as_revealed(user:get_player_name(), "nodes", "mcl_portals:portal")

				local dim = mcl_worlds.pos_to_dimension(pos)
				if minetest.get_modpath("awards") and dim ~= "nether" and user:is_player() then
					awards.unlock(user:get_player_name(), "mcl:buildNetherPortal")
				end
			end
			return true
		else
			return false
		end
	end,
})

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.disallow
end

minetest.register_node("mcl_portals:portal", {
	description = S("Nether Portal"),
	_doc_items_longdesc = S("A Nether portal teleports creatures and objects to the hot and dangerous Nether dimension (and back!). Enter at your own risk!"),
	_doc_items_usagehelp = S("Stand in the portal for a moment to activate the teleportation. Entering a Nether portal for the first time will also create a new portal in the other dimension. If a Nether portal has been built in the Nether, it will lead to the Overworld. A Nether portal is destroyed if the any of the obsidian which surrounds it is destroyed, or if it was caught in an explosion."),

	tiles = {
		"blank.png",
		"blank.png",
		"blank.png",
		"blank.png",
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
		{
			name = "mcl_portals_portal.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.25,
			},
		},
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "blend" or true,
	walkable = false,
	buildable_to = false,
	is_ground_content = false,
	drop = "",
	light_source = 11,
	post_effect_color = {a = 180, r = 51, g = 7, b = 89},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.1,  0.5, 0.5, 0.1},
		},
	},
	groups = { creative_breakable = 1, portal = 1, not_in_creative_inventory = 1 },
	sounds = mcl_sounds.node_sound_glass_defaults(),
	on_destruct = destroy_portal,
	on_rotate = on_rotate,
	_mcl_hardness = -1,
	_mcl_blast_resistance = 0,
	_on_walk_through = function(pos, node, player)
		emit_portal_particles(pos, node)
		teleport_objs_in_portal(pos)
	end,
})

minetest.register_chatcommand("dumpportals", {
	description = S("Dump coordinates of registered portals"),
	privs = { debug = true },
	params = "[nether | overworld]",
	func = function(name, param)
		if param ~= "nether" and param ~= "overworld" then
			return false, S("Invalid dimension argument.")
		end
		local dim = param

		local output = ""
		for _, portal in pairs(portals[dim]) do
			output = output .. minetest.pos_to_string(portal) .. "\n"
		end

		return true, output
	end,
})

minetest.register_abm({
	label = "Nether portal teleportation and particles",
	nodenames = { "mcl_portals:portal" },
	interval = 1,
	chance = 1,
	action = function(pos, node)
		emit_portal_particles(pos, node)
		teleport_objs_in_portal(pos)
	end,
})

mcl_structures.register_structure("nether_portal",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal.mts"
	},
})

mcl_structures.register_structure("nether_portal_open",{
	nospawn = true,
	filenames = {
		modpath.."/schematics/mcl_portals_nether_portal_open.mts"
	},
})
