local S = core.get_translator(core.get_current_modname())

core.register_chatcommand("playsound",{
	params = S("<sound> <target>"), --TODO:add source
	description = S("Play a sound. Arguments: <sound>: name of the sound. <target>: Target."),
	privs = {server = true},
	func = function(_, rawparams)
		local P = {}
		local i = 0
		for str in string.gmatch(rawparams, "([^ ]+)") do
			i = i + 1
			P[i] = str
		end
		local params = {}
		if P[1] == tostring(P[1]) then
			params.name = P[1]
		else
			return false, S("Sound name is invalid!") --TODO: add mc chat message
		end
		if P[2] == tostring(P[2]) and core.player_exists(P[2]) then
			params.target = P[2]
		else
			return false, S("Target is invalid!!")
		end
		-- if P[3] then
			-- params.pos = nil --TODO:position
		-- else
			-- params.pos = nil
		-- end
		-- if P[4] == tonumber(P[4]) then
			-- params.gain = P[4]
		-- else
			-- params.gain = 1.0
		-- end
		-- if P[5] == tonumber(P[5]) then
			-- params.pitch = P[5]
		-- else
			-- params.pitch = 1.0
		-- end
		core.sound_play({name = params.name}, {to_player = params.target}, true) --TODO: /stopsound
		return true
	end,
})
