---@diagnostic disable: cast-local-type
versionNumber = "1.0.0"

-- the actual width/height of the window
baseWindowWidth = 640
baseWindowHeight = 640
windowWidth = baseWindowWidth
windowHeight = baseWindowHeight
referenceDT = 1/60
maxDT = 1/15 -- lowest framerate allowed is 15 fps. If you get a lag spike that goes over 15 fps, it should clamp to this

resizeMode = "letterbox" -- "letterbox" or "stretch". If "stretch", then use non-integer multiples of the scale. If "letterbox" (default), use letterboxing and only integer multiples

-- Determines how much the render canvas needs to be scaled up to fit the window.
-- Gets recomputed by WindowUtils (Don't set this here)
windowCanvasScale = 1
-- Determines how much the UI and all post-camera items need to be scaled to fit the window.
-- Gets recomputed by WindowUtils (Don't set this here)
uiScale = 1

useLoadingScreen = false
debugMode = false -- make sure this is false when shipping. allows timeslowdown with the "1" key
usetick = false -- set to true if you want to use tick's fixed timestep for update. if false, then we only use fixed timestep for physics/collision.
web = false -- true if web version, false if not web version. Set this before you build for web
armorgames = false -- true if releasing on armorgames
crazygames = false -- true if releasing on crazygames
itch = false -- true if exporting to the itch version, in which controller support should be enabled
manualGC = true -- disable automatic garbage collection
manualGCPerFrame = false -- enable manual garbage collection every frame
logGC = false -- enable logging of garbage collection
showFPS = false -- turn on fps counter
profileOn = false -- turn on profiler
profileInterval = 10 -- how often does the profiler report (ever N seconds)
iconControlChar = "~"
mouseVisible = false

-- For JPROF: use PROF_CAPTURE
-- Run the game with PROF_CAPTURE=true, then run the command below in the folder outside the jprof project
-- cd to C:\Users\abhim\Documents\GameDev\Love2dDev
-- Then run:
-- "C:\Program Files (x86)\LOVE\love.exe" Jprof PutridShotUltra prof.mpack
-- That should visualize the profile. You can annotate other functions with prof.push/pop wherever we want to profile
PROF_CAPTURE=false

function love.conf(t)
    t.window.title = "Loading Game"
    t.window.width = windowWidth
    t.window.height = windowHeight
    if web and not itch then
        t.modules.joystick = false
    end
	if web and itch then -- from https://github.com/Davidobot/love.js/issues/16
		t.window.minwidth = 100
		t.window.minheight = 100
		-- resizable must be true for fullscreen events to call love.resize
		-- from this: https://github.com/Davidobot/love.js/issues/59
		t.window.resizable = true
	end
end

-- TODO
-- make all black colors actually the secondary color (i.e update the card spritesheet)
-- make enemy eyes match the 'red' color (use image data mapping)
all_palettes = {
	default_palette = {
		white_color = {1,1,1,1},
		blue_color = {0,1,1,1},
		primary_color = {1,1,1,1},
		secondary_color = {0,0,0,1},
		green_color = {0,1,0,1},
		yellow_color = {1,1,0,0},
		background_color = {0.15, 0.15, 0.15, 1},
		greyed_color = {0.5,0.5,0.5,1},
		corpse_color = {0.15,0.15,0.15,1},
		red_color = {1,0,0,1},
		primary_color_ignorelight = {0.942, 1, 0.987, 1},
	},
	death_palette = {
		primary_color = {0,0,0,1},
		secondary_color = {1,0,0,1},
		background_color = {1, 0, 0, 1},
		greyed_color = {1,0,0,1},
		corpse_color = {1,0,0,1},
		red_color = {0,0,0,1},
		primary_color_ignorelight = {0,0,0,1},
	},
	rusty_steam = { -- by Sumedh Natu https://lospec.com/palette-list/rusty-steam
		primary_color = {0.827,0.827,0.827,1},
		secondary_color = {0.192,0.306,0.322,1},
		background_color = {},
		greyed_color = {},
		corpse_color = {},
		red_color = {0.949, 0.631, 0.329,1},
		primary_color_ignorelight = {}
	},
	hunt = { -- by brush.kat https://lospec.com/palette-list/hunt
		primary_color = {1,0.988,0.955,1},
		secondary_color = {0.173, 0.157, 0.247,1},
		background_color = {},
		greyed_color = {},
		corpse_color = {},
		red_color = {0.984, 0.173, 0.525,1},
		primary_color_ignorelight = {}
	},
	death_valley = { -- by ATB Man, modified by me
		primary_color = {0.173, 0.157, 0.247,1},
		secondary_color = {0.85, 0.70, 0.44,1},
		background_color = {},
		greyed_color = {},
		corpse_color = {},
		red_color = {0.16, 0.61, 0.52,1},
		primary_color_ignorelight = {}
	}
}

current_palette = "default_palette"
corpse_color_factor = 0.15
greyed_color_factor = 0.5
ignore_light_factor = {0.942, 1, 0.987, 1}
background_color_factor = {0.15, 0.15, 0.15, 1}

-- This definition exists only to enable vscode auto-complete. It gets overridden by resetPalette immediately
global_pallete = {
	white_color = {1,1,1,1},
	orange_color = {0.894, 0.580, 0.227, 1},
	black_color = {0,0,0,1},
	blue_color = {0,1,1,1},
	purple_color = {0.439, 0.216, 0.498, 1},
	light_blue_color = {0.494, 0.769, 0.757, 1},
	primary_color = {1,1,1,1},
    secondary_color = {0,0,0,1},
	yellow_color = {1,1,0,0},
	green_color = {0.392, 0.490, 0.204,1},
	background_color = {},
    greyed_color = {0.5,0.5,0.5,1},
	corpse_color = {0.15,0.15,0.15,1},
    red_color = {1,0,0,1},
	primary_color_ignorelight = {0.942, 1, 0.987, 1} -- Pick a color very close to white but that is unlikely to appear naturally
}

function resetPalette()
	for k,v in pairs(all_palettes[current_palette]) do
		for k2 = 1,3 do
			-- by lerping between the primary and secondary color, we can get a really nice transition from bright to dark for our dependent colors
			if k == "greyed_color" then
				global_pallete[k][k2] = lerp(all_palettes[current_palette].secondary_color[k2], all_palettes[current_palette].primary_color[k2], greyed_color_factor)
			elseif k == "corpse_color" then
				global_pallete[k][k2] = lerp(all_palettes[current_palette].secondary_color[k2], all_palettes[current_palette].primary_color[k2], corpse_color_factor)
			elseif k == "primary_color_ignorelight" then
				-- The "ignore-light" color is the only one that's not lerped, as it must simply be a color very close to our main color
				global_pallete[k][k2] = all_palettes[current_palette].primary_color[k2] * ignore_light_factor[k2]
			elseif k == "background_color" then
				global_pallete[k][k2] = lerp(all_palettes[current_palette].secondary_color[k2], all_palettes[current_palette].primary_color[k2], background_color_factor[k2])
			else
				global_pallete[k][k2] = v[k2]
			end
		end
		global_pallete[k][4] = 1 -- alpha is always 1
	end
end

function goToTitleScreen(dontPauseMusic)
	MusicManager.stopAllTracks()
    gameState.levelIndex = 2
    gameState.loadLevel = true
end

function restartStage()
	gameState.state.bossHealthOnDeath = 0
    gameState.state.bossHealthPreviousAttempt = 0
    gameState.state.justGotBackUp = false
    gameState.state.playerKnockdownXPosition = 0
	gameState.state.bossKnockdownXPosition = 0
	gameState.loadLevel = true
end

function hideMouse()
    if mouseVisible then
        love.mouse.setVisible(false)
        mouseVisible = false
    end
end

function showMouse()
    if not mouseVisible then
        love.mouse.setVisible(true)
        mouseVisible = true
    end
end

-- CRASH HANDLING
local utf8 = require("utf8")

local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errorhandler(msg)
	msg = tostring(msg)

	error_printer(msg, 2)
    -- Custom code starts here
    -- Save the crash log to a file
    if not love.filesystem.getInfo("CrashLogs", "directory") then
        love.filesystem.createDirectory("CrashLogs")
    end
    love.filesystem.write("CrashLogs/crashlog" .. os.time() .. ".txt", (debug.traceback("Error: " .. tostring(msg), 1+(2 or 1)):gsub("\n[^\n]+$", "")))
    -- Custom code ends here

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setRelativeMode(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
		draw()
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end