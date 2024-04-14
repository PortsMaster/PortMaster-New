controls = {}
controls.players = {}

controls.registered_on_press = {}
function controls.register_on_press(func)
	controls.registered_on_press[#controls.registered_on_press+1] = func
end

controls.registered_on_release = {}
function controls.register_on_release(func)
	controls.registered_on_release[#controls.registered_on_release+1] = func
end

controls.registered_on_hold = {}
function controls.register_on_hold(func)
	controls.registered_on_hold[#controls.registered_on_hold+1]=func
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	controls.players[name] = {
		jump={false},
		right={false},
		left={false},
		LMB={false},
		RMB={false},
		sneak={false},
		aux1={false},
		down={false},
		up={false},
		zoom={false},
		dig={false},
		place={false}
	}
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	controls.players[name] = nil
end)

minetest.register_globalstep(function()
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local player_controls = player:get_player_control()
		for cname, cbool in pairs(player_controls) do
			if not controls.players[player_name] then
				-- player timed out but is still provided by get_connected_players(), disregard
				break
			end

			--Press a key
			if cbool==true and controls.players[player_name][cname][1]==false then
				for _, func in pairs(controls.registered_on_press) do
					func(player, cname)
				end
				controls.players[player_name][cname] = {true, os.clock()}
			elseif cbool==true and controls.players[player_name][cname][1]==true then
				for _, func in pairs(controls.registered_on_hold) do
					func(player, cname, os.clock()-controls.players[player_name][cname][2])
				end
			--Release a key
			elseif cbool==false and controls.players[player_name][cname][1]==true then
				for _, func in pairs(controls.registered_on_release) do
					func(player, cname, os.clock()-controls.players[player_name][cname][2])
				end
				controls.players[player_name][cname] = {false}
			end
		end
	end
end)
