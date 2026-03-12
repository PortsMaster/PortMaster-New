local GRAVITY = tonumber(core.settings:get("movement_gravity"))

local inv_nodes_movable = core.settings:get_bool("mcl_inv_nodes_movable", true)

mcl_pistons.registered_on_move = {}

local sixdirs = {
	vector.new(1,  0, 0),
	vector.new(-1,  0, 0),
	vector.new(0,  1, 0),
	vector.new(0, -1, 0),
	vector.new(0,  0, 1),
	vector.new(0,  0, -1)
}

-- Functions to be called on piston movement
-- See also the callback
function mcl_pistons.register_on_move(callback)
	table.insert(mcl_pistons.registered_on_move, callback)
end

local function run_on_mcl_piston_move(moved_nodes)
	for _, callback in ipairs(mcl_pistons.registered_on_move) do
		callback(moved_nodes)
	end
end

-- pos: pos of block to be pushed;
-- movedir: direction of actual movement
-- maximum: maximum nodes to be pushed
-- player_name: player who is moving the block
-- piston_pos: position of the piston
function mcl_pistons.push(pos, movedir, maximum, player_name, piston_pos)
	-- table containing nodes to be moved, has the following format:
	-- pos: position after being moved
	-- old_pos: position before being moved
	-- node: node information, courtesy of core.get_node
	-- meta: node metadata, nil if dosent have it
	-- timer: node timer, nil if dosent have it
	local nodes = {}

	-- table containing nodes to be dug by the piston. Same format nodes
	local dig_nodes = {}
	local frontiers = {pos}

	while #frontiers > 0 do
		local np = frontiers[1]
		local nn = core.get_node(np)
		if nn.name == "ignore" then
			core.get_voxel_manip():read_from_map(np, np)
			nn = core.get_node(np)
		end

		-- Abort if trying to push an unmovable block. The piston itself counts as unmovable.
		local def = core.registered_nodes[nn.name]
		if core.get_item_group(nn.name, "unmovable_by_piston") == 1
			or (not inv_nodes_movable and core.get_item_group(nn.name, "container") ~= 0)
			or not def
			or vector.equals(piston_pos, np) then
			return
		end

		if core.is_protected(np, player_name) then
			return
		end

		if core.get_item_group(nn.name, "dig_by_piston") == 1 then
			-- if we want the node to drop, e.g. sugar cane, do not count towards push limit
			table.insert(dig_nodes, {node = nn, pos = vector.add(np, movedir), old_pos = vector.copy(np)})
		else
			if not def.buildable_to then
				table.insert(nodes, {node = nn, pos = vector.add(np, movedir), old_pos = vector.copy(np)})
				if #nodes > maximum then
					return
				end

				-- add connected nodes to frontiers, connected is a vector list
				-- the vectors must be absolute positions
				local connected= {}
				local is_connected, offset_node, offset_pos
				if def._mcl_pistons_sticky then
					-- when pushing a sticky block, push all applicable blocks with it
					for _, dir in pairs(sixdirs) do
						offset_pos = np:add(dir:multiply(-1))
						offset_node = core.get_node(offset_pos)
						is_connected = def._mcl_pistons_sticky(nn, offset_node, dir)

						-- Only insert connected node if it is movable and can stick to current node.
						-- The piston itself counts as unmovable.
						if is_connected and core.get_item_group(offset_node.name, "unsticky") == 0
							and core.get_item_group(offset_node.name, "unmovable_by_piston") == 0
							and (inv_nodes_movable or core.get_item_group(offset_node.name, "container") == 0)
							and not vector.equals(piston_pos, offset_pos) then
							table.insert(connected, offset_pos)
						end
					end
				end

				-- add node infront of the current node as connected. Because its being pushed
				table.insert(connected, vector.add(np, movedir))

				-- Make sure there are no duplicates in frontiers / nodes before
				-- adding nodes in "connected" to frontiers
				for _, cp in ipairs(connected) do
					local duplicate = false
					for _, rp in ipairs(nodes) do
						if vector.equals(cp, rp.old_pos) then
							duplicate = true
						end
					end
					if not duplicate then
						for _, rp in ipairs(frontiers) do
							if vector.equals(cp, rp) then
								duplicate = true
							end
						end
					end
					if not duplicate then
						table.insert(frontiers, cp)
					end
				end
			end
		end
		table.remove(frontiers, 1)
	end

	-- dig all nodes
	for id, n in ipairs(dig_nodes) do
		-- if current node has already been destroyed (e.g. chain reaction of sugar cane breaking), skip it
		if core.get_node(n.old_pos).name == n.node.name then
			local def = core.registered_nodes[n.node.name]
			if def then
				def.on_dig(n.old_pos, n.node) --no need to check if it exists since all nodes have this via metatable (defaulting to core.node_dig which will handle drops)
				core.remove_node(n.old_pos)
			end
		end
	end

	-- remove old nodes that are about to be pushed
	for id, n in ipairs(nodes) do
		n.meta = core.get_meta(n.old_pos) and core.get_meta(n.old_pos):to_table()
		core.remove_node(n.old_pos)
		local node_timer = core.get_node_timer(n.old_pos)
		if node_timer:is_started() then
			n.node_timer = {node_timer:get_timeout(), node_timer:get_elapsed()}
		end
	end

	-- add nodes after being pushed
	for id, n in ipairs(nodes) do
		-- local np = newpos[id]
		core.set_node(n.pos, n.node)
		if n.meta then
			core.get_meta(n.pos):from_table(n.meta)
		end
		if n.node_timer then
			core.get_node_timer(n.pos):set(unpack(n.node_timer))
		end
		if string.find(n.node.name, "mcl_observers:observer") then
			-- It also counts as a block update when the observer itself is moved by a piston (Wiki):
			mcl_observers.observer_activate(n.pos)
		end
	end

	local function move_object(obj, n, is_pulled)
		local entity = obj:get_luaentity()
		local player = obj:is_player()
		if (entity or player) and not (entity and core.registered_entities[entity.name]._mcl_pistons_unmovable) then
			local new_pos = obj:get_pos():add(movedir)
			local def = core.registered_nodes[core.get_node(new_pos).name]
			if def and def.walkable then
				return
			end

			obj:move_to(new_pos, true)
			-- Launch Player, TNT & mobs like in Minecraft
			-- Only doing so if slimeblock is attached.
			if n.node.name == "mcl_core:slimeblock" and not is_pulled then
				obj:set_acceleration({x=movedir.x, y=-GRAVITY, z=movedir.z})

				--Need to set velocities differently for players, items & mobs/tnt, and falling anvils.
				if player then
					obj:add_velocity(vector.new(movedir.x * 10, movedir.y * 13, movedir.z * 10))
				elseif entity.name == "__builtin:item" then
					obj:add_velocity(vector.new(movedir.x * 9, movedir.y * 11, movedir.z * 9))
				elseif entity.name == "__builtin:falling_node" then
					obj:add_velocity(vector.new(movedir.x * 43, movedir.y * 72, movedir.z * 43))
				elseif entity.is_mob then
					obj:add_velocity (vector.new (movedir.x * 20, movedir.y * 20, movedir.z * 20))
				else
					obj:add_velocity(vector.new(movedir.x * 6, movedir.y * 9, movedir.z * 6))
				end
			end
		end
	end

	-- Collect positions/nodes where objects should be moved.
	local move_positions = {}
	for id, n in ipairs(nodes) do
		-- If moving up, dont add positions above moved nodes. The second table.insert does it already.
		if movedir.y ~= 1 then
			table.insert(move_positions, {pos = n.old_pos:offset(0, 1, 0), node = n, is_pulled = true})
		end
		table.insert(move_positions, {pos = n.pos, node = n, is_pulled = false})
	end

	-- Make sure that objects dug by piston head gets moved as well.
	for id, n in ipairs(dig_nodes) do
		table.insert(move_positions, {pos = n.old_pos, node = n, is_pulled = false})
	end

	-- Search for and move objects. Make sure they dont get moved more than once.
	local moved_objects = {}
	local processed = {}
	for id, p in ipairs(move_positions) do
		local h = core.hash_node_position(p.pos)
		if not processed[h] then
			processed[h] = true

			local objects = core.get_objects_inside_radius(p.pos, 0.9)
			for _, obj in ipairs(objects) do
				if not moved_objects[obj] then
					move_object(obj, p.node, p.is_pulled)
					moved_objects[obj] = true
				end
			end
		end
	end

	run_on_mcl_piston_move(nodes)

	return true
end

mcl_pistons.register_on_move(function(moved_nodes)
	for i = 1, #moved_nodes do
		local moved_node = moved_nodes[i]
		core.after(0, function()
			core.check_for_falling(moved_node.old_pos)
			core.check_for_falling(moved_node.pos)
		end)

		-- Callback for on_move stored in nodedef
		local node_def = core.registered_nodes[moved_node.node.name]
		if node_def and node_def._mcl_piston_on_move then
			node_def._mcl_piston_on_move(moved_node)
		end
	end
end)
