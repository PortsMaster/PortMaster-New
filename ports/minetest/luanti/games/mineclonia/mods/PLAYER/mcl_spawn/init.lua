mcl_spawn = {}

local S = core.get_translator(core.get_current_modname())
local start_pos = mcl_biome_dispatch.get_spawn_point_2d ()

-- Bed spawning offsets
local node_search_list =
	{
	--[[1]]	{x =  0, y = 0, z = -1},	--
	--[[2]]	{x = -1, y = 0, z =  0},	--
	--[[3]]	{x = -1, y = 0, z =  1},	--
	--[[4]]	{x =  0, y = 0, z =  2},	-- z^ 8 4 9
	--[[5]]	{x =  1, y = 0, z =  1},	--  | 3   5
	--[[6]]	{x =  1, y = 0, z =  0},	--  | 2 * 6
	--[[7]]	{x = -1, y = 0, z = -1},	--  | 7 1 A
	--[[8]]	{x = -1, y = 0, z =  2},	--  +----->
	--[[9]]	{x =  1, y = 0, z =  2},	--	x
	--[[A]]	{x =  1, y = 0, z = -1},	--
	--[[B]]	{x =  0, y = 1, z =  0},	--
	--[[C]]	{x =  0, y = 1, z =  1},	--
	}

local function get_far_node(pos)
	local node = core.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end
	core.get_voxel_manip():read_from_map(pos, pos)
	return core.get_node(pos)
end

local function good_for_respawn(pos, player)
	local pos0 = {x = pos.x, y = pos.y - 1, z = pos.z}
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	local pos2 = {x = pos.x, y = pos.y + 1, z = pos.z}
	local node0 = get_far_node(pos0)
	local node1 = get_far_node(pos1)
	local node2 = get_far_node(pos2)

	local nn0, nn1, nn2 = node0.name, node1.name, node2.name
	if	   core.get_item_group(nn0, "destroys_items") ~=0
		or core.get_item_group(nn1, "destroys_items") ~=0
		or core.get_item_group(nn2, "destroys_items") ~=0
		or core.get_item_group(nn0, "portal") ~=0
		or core.get_item_group(nn1, "portal") ~=0
		or core.get_item_group(nn2, "portal") ~=0
		or core.is_protected(pos0, player or "")
		or core.is_protected(pos1, player or "")
		or core.is_protected(pos2, player or "")
		or (not player and core.get_node_light(pos1, 0.5) < 8)
		or (not player and core.get_node_light(pos2, 0.5) < 8)
		or nn0 == "ignore"
		or nn1 == "ignore"
		or nn2 == "ignore"
		   then
			return false
	end

	local def0 = core.registered_nodes[nn0]
	local def1 = core.registered_nodes[nn1]
	local def2 = core.registered_nodes[nn2]
	if not def0 or not def1 or not def2 then return false end
	return def0.walkable and (not def1.walkable) and (not def2.walkable) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0)
end


function mcl_spawn.get_world_spawn_pos (obj)
	if mcl_biome_dispatch.use_detailed_spawning_mechanics () then
		return mcl_biome_dispatch.next_respawn_position (obj), 0
	end
	return start_pos, false
end

-- Returns a spawn position of player.
-- If player is nil or not a player, a world spawn point is returned.
-- The second return value is true if returned spawn point is player-chosen,
-- false otherwise.
function mcl_spawn.get_bed_spawn_pos(player)
	local spawn, custom_spawn = nil, false
	if player and player:is_player() then
		local attr = player:get_meta():get_string("mcl_beds:spawn")
		if attr and attr ~= "" then
			spawn = core.string_to_pos(attr)
			custom_spawn = true
		end
	end
	if not spawn or spawn == "" then
		spawn = mcl_spawn.get_world_spawn_pos (player)
		custom_spawn = false
	end
	return spawn, custom_spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
-- If message is set, informs the player with a chat message when the spawn position
-- changed.
function mcl_spawn.set_spawn_pos(player, pos, message)
	local spawn_changed = false
	local meta = player:get_meta()
	if pos == nil then
		if meta:get_string("mcl_beds:spawn") ~= "" then
			spawn_changed = true
			if message then
				core.chat_send_player(player:get_player_name(), S("Respawn position cleared!"))
			end
		end
		meta:set_string("mcl_beds:spawn", "")
	else
		local oldpos = core.string_to_pos(meta:get_string("mcl_beds:spawn"))
		meta:set_string("mcl_beds:spawn", core.pos_to_string(pos))

		-- Set player ownership on bed
		local bed_meta = core.get_meta(pos)

		local bed_bottom = mcl_beds.get_bed_bottom (pos)
		local bed_bottom_meta = core.get_meta(bed_bottom)

		if bed_meta then
			bed_meta:set_string("player", player:get_player_name())

			-- Pass in villager as arg. Shouldn't know about villagers
			if bed_bottom_meta then
				bed_bottom_meta:set_string("villager", "")
				bed_bottom_meta:set_string("infotext", "")
			end

			if oldpos and oldpos ~= pos then
				local old_bed_meta = core.get_meta(oldpos)
				if old_bed_meta then
					old_bed_meta:set_string("player", "")
				end
			end
		end

		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			spawn_changed = vector.distance(pos, oldpos) > 0.1
		else
			-- If it wasn't set and now it will be set, it means it is changed
			spawn_changed = true
		end
		if spawn_changed and message then
			core.chat_send_player(player:get_player_name(), S("New respawn position set!"))
		end
	end
	return spawn_changed
end

function mcl_spawn.get_player_spawn_pos(player)
	local pos, custom_spawn = mcl_spawn.get_bed_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		local node_bed = get_far_node(pos)
		local bgroup = core.get_item_group(node_bed.name, "bed")
		if bgroup ~= 1 and bgroup ~= 2 then
			-- Bed is destroyed:
			if player and player:is_player() then
				local checkpos = core.string_to_pos(player:get_meta():get_string("mcl_beds:spawn"))
				local checknode = core.get_node(checkpos)

				if(string.match(checknode.name, "mcl_beds:respawn_anchor_charged_")) then
					local charge_level = tonumber(string.sub(checknode.name, -1))
					if not charge_level then
						core.log("warning","could not get level of players respawn anchor, sending him back to spawn!")
						player:get_meta():set_string("mcl_beds:spawn", "")
						core.chat_send_player(player:get_player_name(), S("Couldn't get level of your respawn anchor!"))
						return mcl_spawn.get_world_spawn_pos(player)
					elseif charge_level ~= 1 then
						core.set_node(checkpos, {name="mcl_beds:respawn_anchor_charged_".. charge_level-1})
						return checkpos, true
					else
						core.set_node(checkpos, {name="mcl_beds:respawn_anchor"})
						return checkpos, true
					end
				else
					player:get_meta():set_string("mcl_beds:spawn", "")
					core.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked, and you had no charged respawn anchor!"))
					return mcl_spawn.get_world_spawn_pos(player)
				end
			end
		end

		-- Find spawning position on/near the bed free of solid or damaging blocks iterating a square spiral 15x15:
		local dir = core.facedir_to_dir(core.get_node(pos).param2)
		local offset
		for _, o in ipairs(node_search_list) do
			if dir.z == -1 then
				offset = {x =  o.x, y = o.y,  z =  o.z}
			elseif dir.z == 1 then
				offset = {x = -o.x, y = o.y,  z = -o.z}
			elseif dir.x == -1 then
				offset = {x =  o.z, y = o.y,  z = -o.x}
			else -- dir.x == 1
				offset = {x = -o.z, y = o.y,  z =  o.x}
			end
			local player_spawn_pos = vector.add(pos, offset)
			if good_for_respawn(player_spawn_pos, player:get_player_name()) then
				return player_spawn_pos, true
			end
		end
		-- We here if we didn't find suitable place for respawn
	end
	return mcl_spawn.get_world_spawn_pos (player)
end

function mcl_spawn.spawn(player)
	local pos, override = mcl_spawn.get_player_spawn_pos(player)
	if override then
		player:set_pos(pos)
		return true
	end

	-- The engine finds a spawn position but sometimes players are spawned
	-- in the air. To avoid fall damage players are moved down such that
	-- they stand on top of a node.
	core.after(0, function()
		local pos = vector.round(player:get_pos())
		while pos.y > mcl_vars.mg_overworld_min do
			pos.y = pos.y - 1
			core.load_area(pos)

			local node = core.get_node(pos)
			local ndef = core.registered_nodes[node.name]
			if ndef and (ndef.walkable or ndef.liquidtype ~= "none") then
				break
			end
		end

		player:set_pos(pos:offset(0, 0.5, 0))
	end)
	return false
end

-- Respawn player at specified respawn position
core.register_on_respawnplayer(function(player) return mcl_spawn.spawn(player) end)
