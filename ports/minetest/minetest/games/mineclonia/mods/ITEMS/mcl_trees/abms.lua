-- Leaf Decay
local function leafdecay_particles(pos, node)
	minetest.add_particlespawner({
		amount = math.random(10, 20),
		time = 0.1,
		minpos = vector.add(pos, {x=-0.4, y=-0.4, z=-0.4}),
		maxpos = vector.add(pos, {x=0.4, y=0.4, z=0.4}),
		minvel = {x=-0.2, y=-0.2, z=-0.2},
		maxvel = {x=0.2, y=0.1, z=0.2},
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 0.1,
		maxexptime = 0.5,
		minsize = 0.5,
		maxsize = 1.5,
		collisiondetection = true,
		vertical = false,
		node = node,
	})
end

-- Whenever a tree trunk node is removed, all `group:leaves` nodes in a radius
-- of 6 blocks are checked from the trunk node's `after_destruct` handler.
-- Any such nodes within that radius that has no trunk node present within a
-- distance of 6 blocks is replaced with a `group:orphan_leaves` node.
--
-- The `group:orphan_leaves` nodes are gradually decayed in this ABM.
minetest.register_abm({
	label = "Leaf decay",
	nodenames = {"group:orphan_leaves"},
	interval = 5,
	chance = 10,
		action = function(pos, node)
		-- Spawn item entities for any of the leaf's drops
		local itemstacks = minetest.get_node_drops(node.name)
		for _, itemname in pairs(itemstacks) do
			local p_drop = vector.offset(pos, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			minetest.add_item(p_drop, itemname)
		end
		-- Remove the decayed node
		minetest.remove_node(pos)
		leafdecay_particles(pos, node)
		minetest.check_for_falling(pos)

		-- Kill depending vines immediately to skip the vines decay delay
		local surround = {
			{ x = 0, y = 0, z = -1 },
			{ x = 0, y = 0, z = 1 },
			{ x = -1, y = 0, z = 0 },
			{ x = 1, y = 0, z = 0 },
			{ x = 0, y = -1, z = -1 },
		}
		for s=1, #surround do
			local spos = vector.add(pos, surround[s])
			local maybe_vine = minetest.get_node(spos)
			--local surround_inverse = vector.multiply(surround[s], -1)
			if maybe_vine.name == "mcl_core:vine" and (not mcl_core.check_vines_supported(spos, maybe_vine)) then
				local def = minetest.registered_nodes[maybe_vine.name]
				if def and def.on_dig then
					def.on_dig(spos,maybe_vine,nil)
				end
			end
		end
	end
})

-- Check if a node stops a tree from growing.  Torches, plants, wood, tree,
-- leaves and dirt does not affect tree growth.
local function node_stops_growth(node)
	if node.name == "air" then
		return false
	end

	local def = minetest.registered_nodes[node.name]
	if not def then
		return true
	end

	local groups = def.groups
	if not groups then
		return true
	end
	if (groups.plant or 0) ~= 0 or
			(groups.torch or 0) ~= 0 or
			(groups.dirt or 0) ~= 0 or
			(groups.dig_by_water or 0) ~= 0 or
			(groups.tree or 0) ~= 0 or
			(groups.bark or 0) ~= 0 or
			(groups.leaves or 0) ~= 0 or
			(groups.wood or 0) ~= 0 then
		return false
	end

	return true
end

-- Check the center column starting one node above the sapling
function mcl_trees.check_growth_simple(pos, height)
	for y = 1, height - 1 do
		local np = vector.offset(pos, 0, y, 0)
		if node_stops_growth(minetest.get_node(np)) then
			return false
		end
	end
	return true
end

-- check 6x6 area starting at sapling level
-- Assumes pos is "north east" sapling
function mcl_trees.check_growth_giant(pos, height)
	for x = -3, 2 do
		for z = -3, 2 do
			for y = 0, height - 1 do
				local np = vector.offset(pos, x, y, z)
				if node_stops_growth(minetest.get_node(np)) then
					return false
				end
			end
		end
	end
	return true
end

local function check_schem_growth(pos, file, giant)
	if file then
		local schem = loadstring(
			minetest.serialize_schematic(file, "lua", { lua_use_comments = false, lua_num_indent_spaces = 0 })
				.. " return schematic"
		)()
		if schem then
			local h = schem.size.y
			if giant then
				return mcl_trees.check_growth_giant(pos, h)
			else
				return mcl_trees.check_growth_simple(pos, h)
			end
		end
	end

	return false
end

function mcl_trees.grow_tree(pos, node)
	local name = node.name:gsub("mcl_trees:sapling_", "")
	if node.name:find("propagule") then
		name = "mangrove"
	end
	if not mcl_trees.woods[name] or ( not mcl_trees.woods[name].tree_schems and not mcl_trees.woods[name].tree_schems_2x2 ) then
		return
	end

	local schem, can_grow, tbt, ne
	local place_at = pos

	if mcl_trees.woods[name].tree_schems_2x2  then
		tbt, ne = mcl_trees.check_2by2_saps(pos, node)
		if tbt then
			table.shuffle(mcl_trees.woods[name].tree_schems_2x2)
			schem = mcl_trees.woods[name].tree_schems_2x2[1]
			can_grow = check_schem_growth(ne, schem.file, true)
			place_at = ne
		end
	end

	if not tbt and mcl_trees.woods[name].tree_schems then
		table.shuffle(mcl_trees.woods[name].tree_schems)
		schem = mcl_trees.woods[name].tree_schems[1]
		can_grow = check_schem_growth(place_at, schem.file, false)
	end

	if not schem then return end

	if can_grow then

		local offset = schem.offset
		minetest.remove_node(pos)
		if tbt then
			for _, v in pairs(tbt) do
				minetest.remove_node(v)
			end

			place_at = ne

			-- Assume trunk is in the center of the schema.
			-- Overide this in tree_schems if it isn't.
			if not offset then
				offset = vector.new(1, 0, 1)
			end
		end

		if offset then
			place_at = vector.subtract(place_at, offset)
		end

		minetest.place_schematic(
			place_at,
			schem.file,
			"random",
			nil,
			false,
			{ place_center_x = true, place_center_y = false, place_center_z = true }
		)
	end
end

minetest.register_abm({
	label = "Tree growth",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil_sapling","group:soil_propagule"},
	interval = 35,
	chance = 5,
	action = mcl_trees.grow_tree,
})

minetest.register_lbm({
	label = "Set old leaves param2",
	name = "mcl_trees:leaves_param2_update",
	nodenames = {"group:leaves"},
	run_at_every_load = false,
	action = function(pos, n)
		if minetest.get_item_group(n.name,"biomecolor") == 0 then return end
		local p2 = mcl_util.get_pos_p2(pos)
		if n.param2 ~= p2 then
			n.param2 = p2
			minetest.swap_node(pos, n)
		end
	end,
})
