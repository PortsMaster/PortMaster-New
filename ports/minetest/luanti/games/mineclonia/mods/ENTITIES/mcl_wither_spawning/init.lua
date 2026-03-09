local dim = {"x", "z"}

local modpath = core.get_modpath(core.get_current_modname())

local peaceful = core.settings:get_bool("only_peaceful_mobs", false)

local function load_schem(filename)
	local file = io.open(modpath .. "/schems/" .. filename, "r")
	if file then
		local data = core.deserialize(file:read())
		file:close()
		return data
	end
end

local wither_spawn_schems = {}

for _, d in pairs(dim) do
	wither_spawn_schems[d] = load_schem("wither_spawn_" .. d .. ".we")
end

local function check_schem(pos, schem)
	for _, n in pairs(schem) do
		local node = core.get_node(vector.add(pos, n))
		local valid_name = n.name and node.name == n.name
		local valid_group = n.group and core.get_item_group(node.name, n.group) ~= 0

		if not (valid_name or valid_group) then
			return false
		end
	end
	return true
end

local function remove_schem(pos, schem)
	for _, n in pairs(schem) do
		core.remove_node(vector.add(pos, n))
	end
end

local function wither_spawn(pos, player)
	if peaceful then return end
	for _, d in pairs(dim) do
		for i = 0, 2 do
			local p = vector.add(pos, {x = 0, y = -2, z = 0, [d] = -i})
			local schem = wither_spawn_schems[d]
			if check_schem(p, schem) then
				remove_schem(p, schem)
				local wither = core.add_entity(vector.add(p, {x = 0, y = 1, z = 0, [d] = 1}), "mobs_mc:wither")
				if not wither then return end
				local wither_ent = wither:get_luaentity()
				wither_ent._spawner = player:get_player_name()
				for players in core.objects_inside_radius(pos, 20) do
					if players:is_player() then
						awards.unlock(players:get_player_name(), "mcl:witheringHeights")
					end
				end
			end
		end
	end
end

local wither_head = core.registered_nodes["mcl_heads:wither_skeleton"]
local old_on_place = wither_head.on_place
core.override_item("mcl_heads:wither_skeleton",{
	on_place = function(itemstack, placer, pointed)
		local n = core.get_node(vector.offset(pointed.above,0,-1,0))
		if core.get_item_group(n.name, "soul_block") ~= 0 then
			core.after(0, wither_spawn, pointed.above, placer)
		end
		return old_on_place(itemstack, placer, pointed)
	end
})
