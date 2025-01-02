local Settings = require "funkin.ui.options.settings"

local resolutions = {0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1, 768 / 720, 1.125}
local resolutionf, resolutionf2 = "%sx (%dx%d)", "%sx/Full (%dx%d)"

local data = {
	{"GRAPHICS"},
	{"antialiasing", "Antialiasing", "boolean", function()
		local value = not ClientPrefs.data.antialiasing
		ClientPrefs.data.antialiasing = value
		Object.defaultAntialiasing = value
	end},
	{"lowQuality", "Low quality", "boolean"},
	{"shader",     "Shaders",     "boolean"},

	{"WINDOW"},
	{"fullscreen", "Fullscreen", "boolean", function()
		local value = not ClientPrefs.data.fullscreen
		ClientPrefs.data.fullscreen = value
		love.window.setFullscreen(value)
	end},
	{"resolution", "Resolution", "number", function(add)
		local value = ClientPrefs.data.resolution
		if value <= resolutions[#resolutions] then
			local i = #resolutions
			for i2 = i, 1, -1 do
				if value >= resolutions[i2] then
					i = i2
					break
				end
			end
			value = resolutions[math.max(i + add, 1)] or value + add / 8
		else
			value = value + add / 8
		end

		local _, ymax = love.window.getMaxDesktopDimensions()
		if Project.height * value >= ymax then value = ymax / Project.height end

		ClientPrefs.data.resolution = value
		Camera.defaultResolution = value
		---@diagnostic disable-next-line: missing-parameter
		love.window.updateMode(Project.width * value, Project.height * value)
		for _, camera in ipairs(game.cameras.list) do
			if camera then camera:resize(camera.width, camera.height, value) end
		end
	end, function(value)
		local _, ymax = love.window.getMaxDesktopDimensions()
		local height = Project.height * value
		if height >= ymax then
			return resolutionf2:format(math.truncate(value, 4),
				math.ceil(Project.width * value), height)
		end
		return resolutionf:format(tostring(math.truncate(value, 4)),
			math.ceil(Project.width * value), height)
	end},
	{"fps", "FPS", "number", function(add)
		local value = math.floor(ClientPrefs.data.fps)
		local _, _, mode = love.window.getMode()
		local expect, diff = value + add, value - mode.refreshrate
		local prev, clamped = value, math.clamp(expect, 30, 360)
		if value >= 1000 then
			if add < 0 then
				value = mode.refreshrate > 360 and mode.refreshrate or 360
			end
		elseif (math.abs(diff) <= 1 or expect ~= clamped) and math.abs(diff + add) < math.abs(diff) then
			value = mode.refreshrate
		else
			value = clamped
		end
		if value == prev and add > 0 then
			value = 1000
		end

		ClientPrefs.data.fps = value
		love.FPScap = value
	end, function(value)
		value = math.truncate(value, 3)
		return math.truncate(select(3, love.window.getMode()).refreshrate, 3) == value and
			("%shz"):format(tostring(value)) or tostring(value)
	end},
	{"parallelUpdate", "Parallel update", "boolean", function()
		local value = not ClientPrefs.data.parallelUpdate
		ClientPrefs.data.parallelUpdate = value
		love.parallelUpdate = value
	end},
	{"STATS"},
	{"toastPrints", "Toast prints", "boolean", function()
		local value = not ClientPrefs.data.toastPrints
		ClientPrefs.data.toastPrints = value
	end},
	{"showFps", "Show FPS", "boolean", function()
		local value = not ClientPrefs.data.showFps
		ClientPrefs.data.showFps = value
		game.statsCounter.showFps = value
	end},
	{"showMemory", "Show memory", "boolean", function()
		local value = not ClientPrefs.data.showMemory
		ClientPrefs.data.showMemory = value
		game.statsCounter.showMemory = value
	end},
	{"showRender", "Show renderer", "boolean", function()
		local value = not ClientPrefs.data.showRender
		ClientPrefs.data.showRender = value
		game.statsCounter.showRender = value
	end},
	{"showDraws", "Show draws", "boolean", function()
		local value = not ClientPrefs.data.showDraws
		ClientPrefs.data.showDraws = value
		game.statsCounter.showDraws = value
	end},
}

if love.system.getDevice() == "Mobile" then
	for _, v in pairs(data) do
		if #v > 1 and v[1] == "fullscreen" or v[1] == "resolution" then
			table.delete(data, v)
		end
	end
end

local Display = Settings:base("Display", data)
return Display
