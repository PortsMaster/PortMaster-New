
function mcl_trees.strip_tree(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then return end

	local node = minetest.get_node(pointed_thing.under)
	local noddef = minetest.registered_nodes[node.name]

	if noddef._mcl_stripped_variant and minetest.registered_nodes[noddef._mcl_stripped_variant] then
		minetest.swap_node(pointed_thing.under, {name=noddef._mcl_stripped_variant, param2=node.param2})
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			-- Add wear (as if digging a axey node)
			local toolname = itemstack:get_name()
			local wear = mcl_autogroup.get_wear(toolname, "axey")
			itemstack:add_wear(wear)
		end
	end
	return itemstack
end

function mcl_trees.rotate_climbable(pos, node, user, mode)
	if mode == screwdriver.ROTATE_FACE then
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		minetest.swap_node(pos, node)
		return true
	end
	return false
end

local diagonals = {
	vector.new(1,0,1),
	vector.new(-1,0,1),
	vector.new(1,0,-1),
	vector.new(-1,0,-1),
}

function mcl_trees.check_2by2_saps(pos, node)
	local n = node.name
	-- we need to check 4 possible 2x2 squares on the x/z plane each uniquely defined by one of the
	-- diagonals of the position we're checking:
	for _,v in pairs(diagonals) do
		local d = vector.add(pos,v) --one of the 4 diagonal positions from this node
		local xp = vector.new(d.x,d.y,d.z-v.z) --go "back" towards our position on the z axis
		local zp = vector.new(d.x-v.x,d.y,d.z) --go "back" towards our position on the x axis

		local dn = minetest.get_node(d).name
		local xn = minetest.get_node(xp).name
		local zn = minetest.get_node(zp).name
		if n == dn and n == xn and n == zn then
			--if all the 3 acquired positions have the same nodename as the original node it must be a square
			local ne = pos
			for _,p in pairs({pos,d,xp,zp}) do
				if p.x > ne.x or p.z > ne.z then ne = p end
			end --find northeasternmost node
			return {d,xp,zp}, ne
		end
	end
end
