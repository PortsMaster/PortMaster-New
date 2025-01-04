local json = require("lib.json")

local Save = {
	data = {},
	path = "",
	initialized = false
}

function Save.init(name)
	if Save.initialized then return end
	Save.initialized = true

	Save.path = love.filesystem.getSaveDirectory()
	local dataFile = love.filesystem.read(name .. ".lox")
	if dataFile then
		Save.data = json.decode(love.data.decode("string", "hex", dataFile))
	end
end

function Save.bind(name)
	love.filesystem.write(name .. ".lox", love.data.encode("string", "hex", json.encode(Save.data)))
end

return Save
