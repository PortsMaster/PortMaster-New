local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_chatcommand("setblock", {
	params = S("<X>,<Y>,<Z> <NodeString>"),
	description = S("Set node at given position"),
	privs = {give=true, interact=true},
	func = function(name, param)
		local p = {}
		local nodestring
		p.x, p.y, p.z, nodestring = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+) +(.+)$")
		p.x, p.y, p.z = tonumber(p.x), tonumber(p.y), tonumber(p.z)
		if p.x and p.y and p.z and nodestring then
			local itemstack = ItemStack(nodestring)
			if itemstack:is_empty() or not minetest.registered_nodes[itemstack:get_name()] then
				return false, S("Invalid node")
			end
			minetest.set_node(p, {name=nodestring})
			return true, S("@1 spawned.", nodestring)
		end
		return false, S("Invalid parameters (see /help setblock)")
	end,
})