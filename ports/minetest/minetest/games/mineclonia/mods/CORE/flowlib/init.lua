flowlib = {}

--sum of direction vectors must match an array index

--(sum,root)
--(0,1), (1,1+0=1), (2,1+1=2), (3,1+2^2=5), (4,2^2+2^2=8)

local inv_roots = {
	[0] = 1,
	[1] = 1,
	[2] = 0.70710678118655,
	[4] = 0.5,
	[5] = 0.44721359549996,
	[8] = 0.35355339059327,
}

local function to_unit_vector(dir_vector)
	local sum = dir_vector.x * dir_vector.x + dir_vector.z * dir_vector.z
	return {x = dir_vector.x * inv_roots[sum], y = dir_vector.y, z = dir_vector.z * inv_roots[sum]}
end

local function is_touching(realpos,nodepos,radius)
	local boarder = 0.5 - radius
	return math.abs(realpos - nodepos) > (boarder)
end

flowlib.is_touching = is_touching

local function is_water(pos)
	return core.get_item_group(core.get_node(pos).name, "water") ~= 0
end

flowlib.is_water = is_water

local function node_is_water(node)
	return core.get_item_group(node.name, "water") ~= 0
end

flowlib.node_is_water = node_is_water

local function is_lava(pos)
	return core.get_item_group(core.get_node(pos).name, "lava") ~= 0
end

flowlib.is_lava = is_lava

local function node_is_lava(node)
	return core.get_item_group(node.name, "lava") ~= 0
end

flowlib.node_is_lava = node_is_lava


local function is_liquid(pos)
	return core.get_item_group(core.get_node(pos).name, "liquid") ~= 0
end

flowlib.is_liquid = is_liquid

local function node_is_liquid(node)
	return core.get_item_group(node.name, "liquid") ~= 0
end

flowlib.node_is_liquid = node_is_liquid

--This code is more efficient
local function quick_flow_logic(node, pos_testing, direction)
	local name = node.name
	if not core.registered_nodes[name] then
		return 0
	end
	if core.registered_nodes[name].liquidtype == "source" then
		local node_testing = core.get_node(pos_testing)
		if not core.registered_nodes[node_testing.name] then
			return 0
		end
		if core.registered_nodes[node_testing.name].liquidtype ~= "flowing" then
			return 0
		else
			return direction
		end
	elseif core.registered_nodes[name].liquidtype == "flowing" then
		local node_testing = core.get_node(pos_testing)
		local param2_testing = node_testing.param2
		if not core.registered_nodes[node_testing.name] then
			return 0
		end
		if core.registered_nodes[node_testing.name].liquidtype == "source" then
			return -direction
		elseif core.registered_nodes[node_testing.name].liquidtype == "flowing" then
			if param2_testing < node.param2 then
				if (node.param2 - param2_testing) > 6 then
					return -direction
				else
					return direction
				end
			elseif param2_testing > node.param2 then
				if (param2_testing - node.param2) > 6 then
					return direction
				else
					return -direction
				end
			end
		end
	end
	return 0
end

local function quick_flow_vertical (node)
	local name = node.name
	if not core.registered_nodes[name] then
		return 0
	end
	if core.registered_nodes[name].liquidtype == "source" then
		return 0
	end
	return node.param2 >= 8 and 1 or 0
end

local function quick_flow(pos, node)
	if not node_is_liquid(node)  then
		return {x = 0, y = 0, z = 0}
	end
	local x = quick_flow_logic(node,{x = pos.x-1, y = pos.y, z = pos.z},-1) + quick_flow_logic(node,{x = pos.x+1, y = pos.y, z = pos.z}, 1)
	local y = quick_flow_vertical (node)
	local z = quick_flow_logic(node,{x = pos.x, y = pos.y, z = pos.z-1},-1) + quick_flow_logic(node,{x = pos.x, y = pos.y, z = pos.z+1}, 1)
	return to_unit_vector({x = x, y = -y, z = z})
end

flowlib.quick_flow = quick_flow

--if not in water but touching, move centre to touching block
--x has higher precedence than z
--if pos changes with x, it affects z

local function move_centre(pos, realpos, node, radius)
	if is_touching(realpos.x, pos.x, radius) then
		if is_liquid({x = pos.x-1, y = pos.y, z = pos.z}) then
			node = core.get_node({x=pos.x-1, y = pos.y, z = pos.z})
			pos = {x = pos.x-1, y = pos.y, z = pos.z}
		elseif is_liquid({x = pos.x+1, y = pos.y, z = pos.z}) then
			node = core.get_node({x = pos.x+1, y = pos.y, z = pos.z})
			pos = {x = pos.x+1, y = pos.y, z = pos.z}
		end
	end
	if is_touching(realpos.z, pos.z, radius) then
		if is_liquid({x = pos.x, y = pos.y, z = pos.z - 1}) then
			node = core.get_node({x = pos.x, y = pos.y, z = pos.z - 1})
			pos = {x = pos.x, y = pos.y, z = pos.z - 1}
		elseif is_liquid({x = pos.x, y = pos.y, z = pos.z + 1}) then
			node = core.get_node({x = pos.x, y = pos.y, z = pos.z + 1})
			pos = {x = pos.x, y = pos.y, z = pos.z + 1}
		end
	end
	return pos, node
end

flowlib.move_centre = move_centre
