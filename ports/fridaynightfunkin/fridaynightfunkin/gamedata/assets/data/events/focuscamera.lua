function event(params)
	local isTable = type(params.v) == "table"

	local n = isTable and params.v.char or tonumber(params.v)
	local ox, oy = isTable and params.v.x or 0, isTable and params.v.y or 0

	local notefield = state.notefields[n + 1]
	if notefield then
		local char = notefield.character
		if char then
			local camX, camY = state:getCameraPosition(char)
			ox, oy = ox + camX, oy + camY
			state.camTarget = char
		end
	end

	if isTable and params.v.ease then
		switch(params.v.ease, {
			["CLASSIC"] = function() state:cameraMovement(ox, oy) end,
			["INSTANT"] = function() state:cameraMovement(ox, oy, "linear", 0) end,
			default = function()
				state:cameraMovement(
					ox,
					oy,
					params.v.ease:gsub("(%w+)In", "in-%1"):gsub("(%w+)Out", "out-%1"):lower(),
					stepCrotchet * params.v.duration / 1000
				)
			end
		})
	else
		state:cameraMovement(ox, oy)
	end
end
