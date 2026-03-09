-- register extra flavours of a base nodedef
mcl_walkover = {}

local on_object_over = {}
local on_object_in = {}
local registered_globals = {}

mcl_walkover.registered_globals = registered_globals

function mcl_walkover.register_global(func)
	table.insert(registered_globals, func)
end

core.register_on_mods_loaded(function()
	for name,def in pairs(core.registered_nodes) do
		if def._on_object_over then
			on_object_over[name] = def._on_object_over
		end
		if def._on_object_in then
			on_object_in[name] = def._on_object_in
		end
	end
end)

mcl_player.register_globalstep(function(player)
	local pos = player:get_pos()
	local npos = vector.add(pos, mcl_player.node_offsets.stand)
	local node = core.get_node(npos)
	if on_object_over[mcl_player.players[player].nodes.stand] then
		on_object_over[mcl_player.players[player].nodes.stand](npos, node, player)
	end
	for i = 1, #registered_globals do
		registered_globals[i](npos, node, player)
	end
	if on_object_in[mcl_player.players[player].nodes.feet] then
		local npos = vector.add(pos, mcl_player.node_offsets.feet)
		on_object_in[mcl_player.players[player].nodes.feet](npos, core.get_node(npos), player)
	end
	if on_object_in[mcl_player.players[player].nodes.head] then
		local npos = vector.add(pos, mcl_player.node_offsets.head)
		on_object_in[mcl_player.players[player].nodes.head](npos, core.get_node(npos), player)
	end
end)
