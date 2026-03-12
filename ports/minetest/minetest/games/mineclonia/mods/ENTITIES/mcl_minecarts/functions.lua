function mcl_minecarts:get_sign(z)
	if z == 0 then
		return 0
	else
		return z / math.abs(z)
	end
end

function mcl_minecarts:velocity_to_dir(v)
	if math.abs(v.x) > math.abs(v.z) then
		return {x=mcl_minecarts:get_sign(v.x), y=mcl_minecarts:get_sign(v.y), z=0}
	else
		return {x=0, y=mcl_minecarts:get_sign(v.y), z=mcl_minecarts:get_sign(v.z)}
	end
end

function mcl_minecarts:is_rail(pos, railtype)
	local node = core.get_node(pos).name
	if node == "ignore" then
		local vm = core.get_voxel_manip()
		local emin, emax = vm:read_from_map(pos, pos)
		local area = VoxelArea:new{
			MinEdge = emin,
			MaxEdge = emax,
		}
		local data = vm:get_data()
		local vi = area:indexp(pos)
		node = core.get_name_from_content_id(data[vi])
	end
	if core.get_item_group(node, "rail") == 0 then
		return false
	end
	if not railtype then
		return true
	end
	return core.get_item_group(node, "connect_to_raillike") == railtype
end

function mcl_minecarts:check_front_up_down(pos, dir_, check_down, railtype)
	local dir = vector.new(dir_)
	-- Front
	dir.y = 0
	local cur = vector.add(pos, dir)
	if mcl_minecarts:is_rail(cur, railtype) then
		return dir
	end
	-- Up
	if check_down then
		dir.y = 1
		cur = vector.add(pos, dir)
		if mcl_minecarts:is_rail(cur, railtype) then
			return dir
		end
	end
	-- Down
	dir.y = -1
	cur = vector.add(pos, dir)
	if mcl_minecarts:is_rail(cur, railtype) then
		return dir
	end
	return nil
end

function mcl_minecarts:get_rail_direction(pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round(pos_)
	local cur
	local left_check, right_check = true, true

	-- Check left and right
	local left = {x=0, y=0, z=0}
	local right = {x=0, y=0, z=0}
	if dir.z ~= 0 and dir.x == 0 then
		left.x = -dir.z
		right.x = dir.z
	elseif dir.x ~= 0 and dir.z == 0 then
		left.z = dir.x
		right.z = -dir.x
	end

	if ctrl then
		if old_switch == 1 then
			left_check = false
		elseif old_switch == 2 then
			right_check = false
		end
		if ctrl.left and left_check then
			cur = mcl_minecarts:check_front_up_down(pos, left, false, railtype)
			if cur then
				return cur, 1
			end
			left_check = false
		end
		if ctrl.right and right_check then
			cur = mcl_minecarts:check_front_up_down(pos, right, false, railtype)
			if cur then
				return cur, 2
			end
			right_check = true
		end
	end

	-- Normal
	cur = mcl_minecarts:check_front_up_down(pos, dir, true, railtype)
	if cur then
		return cur
	end

	-- Left, if not already checked
	if left_check then
		cur = mcl_minecarts:check_front_up_down(pos, left, false, railtype)
		if cur then
			return cur
		end
	end

	-- Right, if not already checked
	if right_check then
		cur = mcl_minecarts:check_front_up_down(pos, right, false, railtype)
		if cur then
			return cur
		end
	end
	-- Backwards
	if not old_switch then
		cur = mcl_minecarts:check_front_up_down(pos, {
				x = -dir.x,
				y = dir.y,
				z = -dir.z
			}, true, railtype)
		if cur then
			return cur
		end
	end
	return {x=0, y=0, z=0}
end

local plane_adjacents = {
	vector.new(-1,0,0),
	vector.new(1,0,0),
	vector.new(0,0,-1),
	vector.new(0,0,1),
}

function mcl_minecarts:get_start_direction(pos)
	local dir
	local i = 0
	while (not dir and i < #plane_adjacents) do
		i = i+1
		local node = core.get_node_or_nil(vector.add(pos, plane_adjacents[i]))
		if node ~= nil
		and core.get_item_group(node.name, "rail") == 0
		and core.get_item_group(node.name, "solid") == 1
		and core.get_item_group(node.name, "opaque") == 1
		then
			dir = mcl_minecarts:check_front_up_down(pos, vector.multiply(plane_adjacents[i], -1), true)
		end
	end
	return dir
end

function mcl_minecarts:set_velocity(obj, dir, factor)
	obj._velocity = vector.multiply(dir, factor or 3)
	obj._old_pos = nil
	obj._punched = true
end
