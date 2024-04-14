--[[

Copyright (C) 2016 - Auke Kok <sofar@foo-projects.org>
Adapted by MineClone2 contributors

"mcl_lightning" is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

local S = minetest.get_translator(minetest.get_current_modname())

mcl_lightning = {
	interval_low = 17,
	interval_high = 503,
	range_h = 100,
	range_v = 50,
	size = 100,
	on_strike_functions = {},
}

local rng = PcgRandom(32321123312123)

local ps = {}
local ttl = -1

local function revertsky(dtime)
	if ttl == 0 then
		return
	end
	ttl = ttl - dtime
	if ttl > 0 then
		return
	end

	mcl_weather.skycolor.remove_layer("lightning")

	ps = {}
end

minetest.register_globalstep(revertsky)

-- mcl_lightning strike API

-- See API.md
--[[
	mcl_lightning.register_on_strike(function(pos, pos2, objects)
		-- code
	end)
]]
function mcl_lightning.register_on_strike(func)
	table.insert(mcl_lightning.on_strike_functions, func)
end

-- select a random strike point, midpoint
local function choose_pos(pos)
	if not pos then
		local playerlist = minetest.get_connected_players()
		local playercount = table.getn(playerlist)

		-- nobody on
		if playercount == 0 then
			return nil, nil
		end

		local r = rng:next(1, playercount)
		local randomplayer = playerlist[r]
		pos = randomplayer:get_pos()

		-- avoid striking underground
		if pos.y < -20 then
			return nil, nil
		end

		pos.x = math.floor(pos.x - (mcl_lightning.range_h / 2) + rng:next(1, mcl_lightning.range_h))
		pos.y = pos.y + (mcl_lightning.range_v / 2)
		pos.z = math.floor(pos.z - (mcl_lightning.range_h / 2) + rng:next(1, mcl_lightning.range_h))
	end

	local b, pos2 = minetest.line_of_sight(pos, { x = pos.x, y = pos.y - mcl_lightning.range_v, z = pos.z }, 1)

	-- nothing but air found
	if b then
		return nil, nil
	end

	local n = minetest.get_node({ x = pos2.x, y = pos2.y - 1/2, z = pos2.z })
	if n.name == "air" or n.name == "ignore" then
		return nil, nil
	end

	return pos, pos2
end

function mcl_lightning.strike_func(pos, pos2, objects)
	local particle_pos = vector.offset(pos2, 0, (mcl_lightning.size / 2) + 0.5, 0)
	local particle_size = mcl_lightning.size * 10
	local time = 0.2
	minetest.add_particlespawner({
		amount = 1,
		time = time,
		-- make it hit the top of a block exactly with the bottom
		minpos = particle_pos,
		maxpos = particle_pos,
		minexptime = time,
		maxexptime = time,
		minsize = particle_size,
		maxsize = particle_size,
		collisiondetection = true,
		vertical = true,
		-- to make it appear hitting the node that will get set on fire, make sure
		-- to make the texture mcl_lightning bolt hit exactly in the middle of the
		-- texture (e.g. 127/128 on a 256x wide texture)
		texture = "lightning_lightning_" .. rng:next(1,3) .. ".png",
		glow = minetest.LIGHT_MAX,
	})

	minetest.sound_play({ name = "lightning_thunder", gain = 10 }, { pos = pos, max_hear_distance = 500 }, true)

	-- damage nearby objects, transform mobs
	for _, obj in pairs(objects) do
		local lua = obj:get_luaentity()
		if lua then
			if not lua.on_mcl_lightning_strike or ( lua.on_mcl_lightning_strike and lua.on_mcl_lightning_strike(lua, pos, pos2, objects) ~= true ) then
				mcl_util.deal_damage(obj, 5, { type = "lightning_bolt" })
			end
		else
			mcl_util.deal_damage(obj, 5, { type = "lightning_bolt" })
		end
	end

	--Affect nearby nodes if they define a "_on_lightning_strike" callback
	for _, npos in pairs(minetest.find_nodes_in_area(vector.offset(pos2, -5,-5,-5), vector.offset(pos2, 5, 5, 5), {"group:affected_by_lightning"})) do
		local def = minetest.registered_nodes[minetest.get_node(npos).name]
		if def and def._on_lightning_strike then
			def._on_lightning_strike(npos, pos, pos2)
		end
	end

	local playerlist = minetest.get_connected_players()
	for i = 1, #playerlist do
		local player = playerlist[i]
		local sky = {}
		local sky_table = player:get_sky(true)

		sky.bgcolor, sky.type, sky.textures = sky_table.base_color, sky_table.type, sky_table.textures

		local name = player:get_player_name()
		if ps[name] == nil then
			ps[name] = {p = player, sky = sky}
			mcl_weather.skycolor.add_layer("lightning", { { r = 255, g = 255, b = 255 } }, true)
			mcl_weather.skycolor.active = true
		end
	end

	-- trigger revert of skybox
	ttl = 0.1

	-- Events caused by the lightning strike: Fire, damage, mob transformations, rare skeleton spawn

	pos2.y = pos2.y + 1/2
	if minetest.get_item_group(minetest.get_node({ x = pos2.x, y = pos2.y - 1, z = pos2.z }).name, "liquid") < 1 then
		if minetest.get_node(pos2).name == "air" then
			-- Low chance for a lightning to spawn skeleton horse + skeletons
			if rng:next(1,100) <= 3 then
				minetest.add_entity(pos2, "mobs_mc:skeleton_horse")

				local angle, posadd
				angle = math.random(0, math.pi*2)
				for i=1,3 do
					posadd = { x=math.cos(angle),y=0,z=math.sin(angle) }
					posadd = vector.normalize(posadd)
					local mob = minetest.add_entity(vector.add(pos2, posadd), "mobs_mc:skeleton")
					if mob then
						mob:set_yaw(angle-math.pi/2)
					end
					angle = angle + (math.pi*2) / 3
				end

			-- Cause a fire
			else
				minetest.set_node(pos2, { name = "mcl_fire:fire" })
			end
		end
	end
end

-- * pos: optional, if not given a random pos will be chosen
-- * returns: bool - success if a strike happened
function mcl_lightning.strike(pos)
	local pos2
	pos, pos2 = choose_pos(pos)

	if not pos then
		return false
	end
	local do_strike = true
	if mcl_lightning.on_strike_functions then
		for _, func in pairs(mcl_lightning.on_strike_functions) do
			-- allow on_strike callbacks to destroy entities by re-obtaining objects for each callback
			local objects = minetest.get_objects_inside_radius(pos2, 3.5)
			local p,stop = func(pos, pos2, objects)
			if p then
				pos = p
				pos2 = choose_pos(p)
			end
			do_strike = do_strike and not stop
		end
	end
	if do_strike and pos and pos2 then
		mcl_lightning.strike_func(pos,pos2,minetest.get_objects_inside_radius(pos2, 3.5))
	end
end

minetest.register_chatcommand("lightning", {
	params = "[<X> <Y> <Z> | <player name>]",
	description = S("Let lightning strike at the specified position or player. No parameter will strike yourself."),
	privs = { maphack = true },
	func = function(name, param)
		local pos = {}
		pos.x, pos.y, pos.z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+)$")
		pos.x = tonumber(pos.x)
		pos.y = tonumber(pos.y)
		pos.z = tonumber(pos.z)
		local player_to_strike
		if not (pos.x and pos.y and pos.z) then
			pos = nil
			player_to_strike = minetest.get_player_by_name(param)
			if not player_to_strike and param == "" then
				player_to_strike = minetest.get_player_by_name(name)
			end
		end
		if not player_to_strike and pos == nil then
			return false, "No position specified and unknown player"
		end
		if pos then
			mcl_lightning.strike(pos)
		elseif player_to_strike then
			mcl_lightning.strike(player_to_strike:get_pos())
		end
		return true
	end,
})
