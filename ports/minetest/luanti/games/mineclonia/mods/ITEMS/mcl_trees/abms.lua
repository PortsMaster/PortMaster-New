-- Leaf Decay
local function leafdecay_particles(pos, node)
	core.add_particlespawner({
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
core.register_abm({
	label = "Leaf decay",
	nodenames = {"group:orphan_leaves"},
	interval = 5,
	chance = 10,
		action = function(pos, node)
		-- Spawn item entities for any of the leaf's drops
		local itemstacks = core.get_node_drops(node.name)
		for _, itemname in pairs(itemstacks) do
			local p_drop = vector.offset(pos, math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
			core.add_item(p_drop, itemname)
		end
		-- Remove the decayed node
		core.remove_node(pos)
		leafdecay_particles(pos, node)
		core.check_for_falling(pos)
	end
})

core.register_abm({
	label = "Tree growth",
	nodenames = {"group:sapling"},
	neighbors = {"group:soil_sapling","group:soil_propagule"},
	interval = 35,
	chance = 5,
	action = function(pos, node)
		-- instead of checking if there are no non-transparent nodes between the sapling and the sky,
		-- which would be too laborious in an abm, check if the node would be in full daylight at noon.
		if core.get_node_light(pos) <= 7 and core.get_node_light(pos, 0.5) < core.LIGHT_MAX then
			core.remove_node(pos)
			core.add_item(pos, node)
		else
			mcl_trees.grow_tree(pos, node)
		end
	end,
})

core.register_lbm({
	label = "Set old leaves param2",
	name = "mcl_trees:leaves_param2_update",
	nodenames = {"group:leaves"},
	run_at_every_load = false,
	action = function(pos, n)
		if core.get_item_group(n.name,"biomecolor") == 0 then return end
		local p2 = mcl_util.get_pos_p2(pos, true)
		if n.param2 ~= p2 then
			n.param2 = p2
			core.swap_node(pos, n)
		end
	end,
})
