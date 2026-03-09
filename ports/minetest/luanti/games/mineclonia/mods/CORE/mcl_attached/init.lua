-- Overrides the builtin core.check_single_for_falling.
-- We need to do this in order to handle nodes in mineclonia specific groups
-- "supported_node" and "attached_node_facedir".
--
-- Nodes in group "supported_node" can be placed on any node that does not
-- have the "airlike" drawtype.  Carpets are an example of this type.

-- drop_attached_node(p)
--
-- This function is copied verbatim from minetest/builtin/game/falling.lua
-- We need this to do the exact same dropping node handling in our override
-- core.check_single_for_falling() function as in the builtin function.
--

mcl_attached = {}

function mcl_attached.drop_attached_node(p)
	local n = core.get_node(p)
	local drops = core.get_node_drops(n, "")
	local def = core.registered_nodes[n.name]

	if def and def.preserve_metadata then
		local oldmeta = core.get_meta(p):to_table().fields
		-- Copy pos and node because the callback can modify them.
		local pos_copy = vector.copy(p)
		local node_copy = { name = n.name, param1 = n.param1, param2 = n.param2 }
		local drop_stacks = {}
		for k, v in pairs(drops) do
			drop_stacks[k] = ItemStack(v)
		end
		drops = drop_stacks
		def.preserve_metadata(pos_copy, node_copy, oldmeta, drops)
	end

	if def and def.sounds and def.sounds.fall then
		core.sound_play(def.sounds.fall, { pos = p }, true)
	end

	core.remove_node(p)
	for _, item in pairs(drops) do
		local pos = vector.offset(p,
			math.random() / 2 - 0.25,
			math.random() / 2 - 0.25,
			math.random() / 2 - 0.25
		)
		core.add_item(pos, item)
	end
end

-- core.check_single_for_falling(pos)
--
-- * causes an unsupported `group:falling_node` node to fall and causes an
--   unattached `group:attached_node` or `group:attached_node_facedir` node
--   or unsupported `group:supported_node` node to drop.
-- * does not spread these updates to neighbours.
--
-- Returns true if the node at <pos> has spawned a falling node or has been
-- dropped as item(s).
--
local original_function = core.check_single_for_falling

function core.check_single_for_falling(pos)
	if original_function(pos) then
		return true
	end

	local node = core.get_node(pos)
	if core.get_item_group(node.name, "attached_node_facedir") ~= 0 and
		core.get_item_group(node.name, "attaches_to_base") == 0 and
		core.get_item_group(node.name, "attaches_to_side") == 0 and
		core.get_item_group(node.name, "attaches_to_top") == 0
	then
		local dir = core.facedir_to_dir(node.param2)
		if dir then
			if core.get_item_group(core.get_node(vector.add(pos, dir)).name, "solid") == 0 then
				mcl_attached.drop_attached_node(pos)
				return true
			end
		end
	end

	if core.get_item_group(node.name, "attached_node_wallmounted") ~= 0 then
		local dir = core.wallmounted_to_dir(node.param2)
		if dir then
			if core.get_item_group(core.get_node(vector.add(pos, dir)).name, "solid") == 0 then
				mcl_attached.drop_attached_node(pos)
				return true
			end
		end
	end

	if core.get_item_group(node.name, "supported_node") ~= 0 then
		local supporting_node = core.get_node(vector.offset(pos, 0, -1, 0))
		local def = core.registered_nodes[supporting_node.name]
		if def and def.drawtype == "airlike" then
			mcl_attached.drop_attached_node(pos)
			return true
		end
	end

	if core.get_item_group(node.name, "supported_node_facedir") ~= 0 then
		local dir = core.facedir_to_dir(node.param2)
		if dir then
			local def = core.registered_nodes[core.get_node(vector.add(pos, dir)).name]
			if def and def.drawtype == "airlike" then
				mcl_attached.drop_attached_node(pos)
				return true
			end
		end
	end

	if core.get_item_group(node.name, "supported_node_wallmounted") ~= 0 then
		local dir = core.wallmounted_to_dir(node.param2)
		if dir then
			local def = core.registered_nodes[core.get_node(vector.add(pos, dir)).name]
			if def and def.drawtype == "airlike" then
				mcl_attached.drop_attached_node(pos)
				return true
			end
		end
	end

	local floating = core.get_item_group(node.name, "floating_node")
	if floating ~= 0 then
		local supporting_node = core.get_node(vector.offset(pos, 0, -1, 0))
		local def = core.registered_nodes[supporting_node.name]
		if def and (def.drawtype ~= "liquid" or (floating > 1 and core.get_item_group(supporting_node.name, "liquid") ~= floating)) then
			mcl_attached.drop_attached_node(pos)
			return true
		end
	end

	local vine_group = core.get_item_group(node.name, "vinelike_node")
	if vine_group ~= 0 then
		local apos
		if vine_group == 1 or vine_group == 3 then
			-- attached to bottom of same node type
			apos = vector.offset(pos, 0, -1, 0)
		elseif vine_group == 2 or vine_group == 4 then
			-- attached to top of same node type
			apos = vector.offset(pos, 0, 1, 0)
		end
		local aname = core.get_node(apos).name
		if core.get_item_group(aname, "vinelike_node") ~= vine_group and
			core.get_item_group(aname, "solid") == 0
		then
			if vine_group == 2 then
				local def = core.registered_nodes[aname]
				if (def and def.drawtype ~= "airlike") then
					return false
				end
			end
			if vine_group == 3 or vine_group == 4 then
				apos = vector.add(pos, core.wallmounted_to_dir(node.param2))
				aname = core.get_node(apos).name
				if core.get_item_group(aname, "solid") ~= 0 then
					return false
				end
			end
			mcl_attached.drop_attached_node(pos)
			return true
		end
	end

	return false
end
