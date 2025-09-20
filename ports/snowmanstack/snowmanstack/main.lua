---------------------------------------------------
--------------------BY ALESAN99--------------------
---------------------------------------------------

--Christmas is fun and I am continuing tradition of making a game every Christmas
--Last year I made Incredible lawnmower and it was a good game.
--MERRY CHISTMAS

-- Virtual resolution & dynamic scaling (added)
VIRTUAL_W, VIRTUAL_H = 256, 256  -- matches the existing canvas size
offsetx, offsety = 0, 0          -- draw offsets for centering
scale = {1, 1}                   -- keep as table for compatibility
rescale = true                   -- always rescale with virtual canvas unless unsupported
canvassupported = false
canvas = nil

local function ensureCanvas()
	if not canvas then
		canvassupported = love.graphics.isSupported("canvas")
		if canvassupported then
			canvas = love.graphics.newCanvas(VIRTUAL_W, VIRTUAL_H)
			canvas:setFilter("nearest", "nearest")
		end
	end
end

local function recalcScale(w, h)
	w = w or love.graphics.getWidth()
	h = h or love.graphics.getHeight()

	-- Fit to window on the limiting dimension (fractional scale allowed for better fill)
	local s = math.max(0.5, math.min(w / VIRTUAL_W, h / VIRTUAL_H))
	scale = {s, s}

	-- Center on both axes
	offsetx = math.floor((w - VIRTUAL_W * s) / 2)
	offsety = math.floor((h - VIRTUAL_H * s) / 2)
end

function love.load()
	randomize()

	require "game"
	require "menu"
	require "win"

	--settings--
	love.filesystem.setIdentity("snowman_stack")
	res = {love.window.getWidth(), love.window.getHeight()}
	controlstable = {"left", "right", "up", "down", "select", "fast forward"}
	if love.filesystem.exists("settings") then
		loadsettings()
	else
		defaultsettings()
	end
	love.audio.setVolume(volume)

	-- Make window resizable & initialize virtual scaling (added)
	love.window.setMode(res[1], res[2], { vsync = vsync, resizable = true, minwidth = VIRTUAL_W, minheight = VIRTUAL_H })
	ensureCanvas()
	recalcScale(res[1], res[2])

	--variables--
	cursordelay = 0.2 --cursor anim speed
	switchspeed = 232 --how fast pieces are switched
	disappeartime = 0.4 --how long it takes for pieces to disappear
	fallingspeed = 56 --falling pieces
	scorepointerlife = .8 --score things
	scorepointerspeed = 40
	scores = {
		50,
		100,
		500,
		1000,
		1500,
		2000,
		5000,
		10000,
		15000,
		20000,
		25000,
		30000,
		40000,
		50000
		}
	pieceanimlength = 0.8 --length of piece animation (divide by 4 for each frame)
	snowdelay = 0.07 -- how fast snow appears
	cursormovetime = 0.25 --how much time you have to hold to move cursor
	cursormovespeed = 0.06 --how fast if moves when held
	stages = { --{how many snowmen are required to beat levels; 18 total, how much fill is there?, drops, drop delay}
		{10, 3, 2, 2.2}, --1
		{10, 3, 2, 1.8}, --2
		{10, 4, 2, 2.2}, --3
		{10, 4, 2, 1.8}, --4
		{10, 5, 2, 2.2}, --5
		{15, 5, 2, 1.8}, --6
		{15, 6, 2, 2.2}, --7
		{15, 6, 2, 1.8}, --8
		{15, 7, 3, 2.4}, --9
		{20, 7, 3, 2}, --10
		{20, 8, 3, 2.6}, --11
		{20, 8, 3, 2.2}, --12
		{20, 9, 3, 2.8}, --13
		{25, 9, 3, 2.4}, --14
		{25, 10, 3, 2.8}, --15
		{25, 10, 3, 2.4}, --16
		{25, 11, 3, 3.6}, --17
		{50, 11, 4, 3.2} --18
	}
	gameplayselections = {gameplayselections[1], stages[1][2], stages[1][3], stages[1][4]}--quick change in menu selection
	startdelay = 2 --have a lil' starting delay
	startshow = 0.5 --how many seconds from the start will it show text
	nextstagedelay = 2.5
	arrowanimdelay = 0.18
	fastforwardspeed = 2.6 --fast forward speed up when holding down button
	gamemodes = {--1player
		"stages",
		"forever",
		"panic"
	}
	gamemodes2 = {--2player
		"battle",
		"co-op"
	}
	fillrange = {0, 12}
	dropsrange = {1, 8}
	dropsrange2 = {1, 5} --2 player
	dropspeedrange = {1, 5}
	presentsrange = {"YES", "NO"}
	panicfill = 11
	fastforwardanimlength = 0.4--how long it takes to complete an animation cycle for fast forward arrows

	--images--
	love.graphics.setDefaultFilter("nearest", "nearest")
	piecesimg = love.graphics.newImage("graphics/pieces.png")
	piecesq = {}
	for x = 0, piecesimg:getWidth()/16 do
		piecesq[x] = {}
		for y = 1, 3 do
			piecesq[x][y] = love.graphics.newQuad(16*x, 16*(y-1), 16, 16, piecesimg:getWidth(), piecesimg:getHeight())
		end
	end
	starspritebatch = love.graphics.newSpriteBatch(piecesimg)
	starspritebatch:bind()
	for x = 1, 8 do
		for y = 1, 14 do
			starspritebatch:add(piecesq[0][1], (x-1)*16, (y-1)*16)
		end
	end
	starspritebatch:unbind()
	guiimg = love.graphics.newImage("graphics/gui.png")
	guiredimg = love.graphics.newImage("graphics/guired.png")
	guigreenimg = love.graphics.newImage("graphics/guigreen.png")
	guiq = {}
	for y = 1, 3 do
		for x = 1, 3 do
			guiq[3*(y-1)+x] = love.graphics.newQuad(8*(x-1), 8*(y-1), 8, 8, 24, 24)
		end
	end
	cursorimg = love.graphics.newImage("graphics/cursor.png")
	cursorq = {}
	for x = 1, 2 do
		cursorq[x] = love.graphics.newQuad(10*(x-1), 0, 10, 20, 20, 20)
	end
	goneimg = love.graphics.newImage("graphics/gone.png")
	goneq = {}
	for x = 1, 8 do
		goneq[x] = love.graphics.newQuad(16*(x-1), 0, 16, 16, 128, 16)
	end
	backgroundimg = love.graphics.newImage("graphics/background.png")
	arrowimg = love.graphics.newImage("graphics/arrow.png")
	arrowq = {}
	for x = 1, 5 do
		arrowq[x] = love.graphics.newQuad(16*(x-1), 0, 16, 16, 96, 16)
	end
	logoimg = love.graphics.newImage("graphics/logo.png")
	alesanimg = love.graphics.newImage("graphics/alesan.png")
	snowimg = love.graphics.newImage("graphics/snow.png")
	snowq = {}
	for x = 1, 4 do
		snowq[x] = love.graphics.newQuad(3*(x-1), 0, 3, 3, 12, 3)
	end
	selectorimg = love.graphics.newImage("graphics/selector.png")
	selectorblueimg = love.graphics.newImage("graphics/selectorblue.png")
	selectorq = {}
	for x = 1, 2 do
		for y = 1, 2 do
			selectorq[2*(y-1)+x] = love.graphics.newQuad(6*(x-1), 6*(y-1), 6, 6, 18, 12)
		end
	end
	selectorq[5] = love.graphics.newQuad(12, 0, 6, 6, 18, 12)
	scrollerimg = love.graphics.newImage("graphics/scroller.png")
	scrollerq = {}
	scrollerq[1] = love.graphics.newQuad(0, 0, 2, 12, 17, 12)
	scrollerq[2] = love.graphics.newQuad(2, 0, 4, 12, 17, 12)
	scrollerq[3] = love.graphics.newQuad(6, 0, 4, 12, 17, 12)
	scrollerq[4] = love.graphics.newQuad(10, 0, 7, 5, 17, 12)
	scrollerq[5] = love.graphics.newQuad(10, 5, 7, 5, 17, 12)
	changearrowimg = love.graphics.newImage("graphics/changearrow.png")
	fastforwardimg = love.graphics.newImage("graphics/fastforward.png")
	fastforwardq = {}
	for x = 1, 5 do
		fastforwardq[x] = love.graphics.newQuad(18*(x-1), 0, 18, 24, 90, 24)
	end
	congratulationsimg = love.graphics.newImage("graphics/congratulations.png")
	snowballimg = love.graphics.newImage("graphics/snowball.png")
	patternimg = love.graphics.newImage("graphics/pattern.png")
	starimg = love.graphics.newImage("graphics/star.png")
	starq = {}
	starq[1] = love.graphics.newQuad(0, 0, 12, 13, 24, 13)
	starq[2] = love.graphics.newQuad(12, 0, 12, 13, 24, 13)
	battletextimg = love.graphics.newImage("graphics/battletext.png")
	battletextq = {}
	battletextq[1] = love.graphics.newQuad(0, 0, 18, 8, 39, 24)
	battletextq[2] = love.graphics.newQuad(18, 0, 19, 8, 39, 24)
	battletextq[3] = love.graphics.newQuad(0, 8, 39, 8, 39, 24)
	battletextq[4] = love.graphics.newQuad(0, 16, 23, 8, 39, 24)

	--fonts--
	font = love.graphics.newImageFont("graphics/font.png", "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?_',-./:;% ")
	scorefont = love.graphics.newImageFont("graphics/scorefont.png", "0123456789")
	love.graphics.setFont(font)

	--sounds--
	selectsound = love.audio.newSource("sound/select.ogg", "static")
	stacksound = love.audio.newSource("sound/stack.ogg", "static")
	switchsound = love.audio.newSource("sound/switch.ogg", "static")

	--music--
	--[[menumusic = love.audio.newSource("music/menu.ogg", "stream")
	menumusic:setLooping(true)
	gamemusic = love.audio.newSource("music/game.ogg", "stream")
	gamemusic:setLooping(true)]]
	musicenabled = false --don't have to hear my horrible music

	setgamestate("menu")
end

function love.update(dt)
	dt = math.min(0.5, dt)
	if _G[gamestate].update then
		_G[gamestate].update(dt)
	end
end

-- Draw centered with fit-to-window scaling (updated)
function love.draw()
	if canvassupported and canvas then
		canvas:clear()
		canvas:renderTo(love_draw)
		love.graphics.setColor(255, 255, 255)
		love.graphics.setBlendMode("premultiplied")
		love.graphics.draw(canvas, offsetx, offsety, 0, scale[1], scale[2])
		love.graphics.setBlendMode("alpha")
	else
		love.graphics.push()
		love.graphics.translate(offsetx, offsety)
		love.graphics.scale(scale[1], scale[2])
		love_draw()
		love.graphics.pop()
	end
end

function love_draw()
	if _G[gamestate].draw then
		_G[gamestate].draw()
	end
end

function love.keypressed(key)
	if _G[gamestate].keypressed then
		_G[gamestate].keypressed(key)
	end
	if key == "escape" then
		love.event.quit()
	end
end

function love.keyreleased(key)
	if _G[gamestate].keyreleased then
		_G[gamestate].keyreleased(key)
	end
end

function love.mousepressed(x, y, button)
	local x, y = love.mouse.getX(), love.mouse.getY()
	if _G[gamestate].mousepressed then
		_G[gamestate].mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	local x, y = love.mouse.getX(), love.mouse.getY()
	if _G[gamestate].mousereleased then
		_G[gamestate].mousereleased(x, y, button)
	end
end

function setgamestate(state, args)
	assert(_G[state], "Invalid game state")
	gamestate = state
	local args = args or {}
	_G[state].load(unpack(args))
end

function defaultsettings()
	volume = 1
	love.audio.setVolume(1)
	vsync = false
	setscale(2)

	defaultcontrols()
end

-- Joystick → fake keyboard mapping
function love.joystickpressed(js, button)
	if button == 7 then
		love.keypressed(" ")           -- Start / Select (Space)
	elseif button == 8 then
		love.keypressed("escape")      -- Back
	elseif button == 1 then
		love.keypressed(" ")           -- A -> Select (Space)
	elseif button == 2 then
		love.keypressed("lshift")      -- B -> Fast forward
	elseif button == 3 then
		love.keypressed("z")           -- X button (optional)
	elseif button == 4 then
		love.keypressed("x")           -- Y button (optional)
	end
end

function love.joystickreleased(js, button)
	if button == 7 then
		love.keyreleased(" ")
	elseif button == 8 then
		love.keyreleased("escape")
	elseif button == 1 then
		love.keyreleased(" ")
	elseif button == 2 then
		love.keyreleased("lshift")
	elseif button == 3 then
		love.keyreleased("z")
	elseif button == 4 then
		love.keyreleased("x")
	end
end

-- D-pad as hat → arrow keys
function love.joystickhat(js, hat, dir)
	love.keyreleased("up"); love.keyreleased("down")
	love.keyreleased("left"); love.keyreleased("right")

	if dir:find("u", 1, true) then love.keypressed("up") end
	if dir:find("d", 1, true) then love.keypressed("down") end
	if dir:find("l", 1, true) then love.keypressed("left") end
	if dir:find("r", 1, true) then love.keypressed("right") end
end

-- Left stick axes (invert both X & Y)
local axisState = {}  -- per-joystick edge detection

function love.joystickaxis(js, axis, value)
	local id = js:getID()
	axisState[id] = axisState[id] or { x="none", y="none" }
	local dead = 0.5

	if axis == 1 then
		-- Inverted: negative -> RIGHT, positive -> LEFT
		local new = (value < -dead) and "right" or (value > dead) and "left" or "none"
		if new ~= axisState[id].x then
			if axisState[id].x == "left"  then love.keyreleased("left")  end
			if axisState[id].x == "right" then love.keyreleased("right") end
			if new == "left"  then love.keypressed("left")  end
			if new == "right" then love.keypressed("right") end
			axisState[id].x = new
		end
	elseif axis == 2 then
		-- Inverted: negative -> DOWN, positive -> UP
		local new = (value < -dead) and "down" or (value > dead) and "up" or "none"
		if new ~= axisState[id].y then
			if axisState[id].y == "up"   then love.keyreleased("up")   end
			if axisState[id].y == "down" then love.keyreleased("down") end
			if new == "up"   then love.keypressed("up")   end
			if new == "down" then love.keypressed("down") end
			axisState[id].y = new
		end
	end
end

function defaultcontrols()
	--player 1
	controls = {}
	controls["left"] = "left"
	controls["right"] = "right"
	controls["up"] = "up"
	controls["down"] = "down"
	controls["select"] = " "
	controls["fast forward"] = "lshift"
	--player 2
	controls2 = {}
	controls2["left"] = "kp4"
	controls2["right"] = "kp6"
	controls2["up"] = "kp8"
	controls2["down"] = "kp2"
	controls2["select"] = "kpenter"
	controls2["fast forward"] = "kp9"
end

function savesettings()
	local s = volume .. "~"
	s = s .. scale[1] .. "~"
	for i = 1, #controlstable-1 do
		s = s .. controls[controlstable[i]] .. "`"
	end
	s = s .. controls[controlstable[#controlstable]] .. "~"
	for i = 1, #controlstable-1 do
		s = s .. controls2[controlstable[i]] .. "`"
	end
	s = s .. controls2[controlstable[#controlstable]] .. "~"
	s = s .. tostring(vsync)

	love.filesystem.write("settings", s)
end

function loadsettings()
	local s = love.filesystem.read("settings")
	local s2 = s:split("~")
	volume = tonumber(s2[1])
	scale = {tonumber(s2[2]), tonumber(s2[2])}
	local s3 = s2[3]:split("`")
	defaultcontrols()
	for i = 1, #s3 do
		controls[controlstable[i]] = s3[i]
	end
	local s3 = s2[4]:split("`")
	for i = 1, #s3 do
		controls2[controlstable[i]] = s3[i]
	end
	vsync = (s2[5] == "true")
end

-- Updated: make setscale recompute based on window size instead of forcing window size
function setscale(s)
	ensureCanvas()
	recalcScale(love.graphics.getWidth(), love.graphics.getHeight())
end

function string:split(d)
	local data = {}
	local from, to = 1, string.find(self, d)
	while to do
		table.insert(data, string.sub(self, from, to-1))
		from = to+d:len()
		to = string.find(self, d, from)
	end
	table.insert(data, string.sub(self, from))
	return data
end

function math.round(v)
	--decide if it should round up or down
	local a, b = math.floor(v), math.ceil(v)
	if v > ((a+b)/2) then
		return math.ceil(v)
	else
		return math.floor(v)
	end
end

function playsound(sound, a)
	if not a then
		sound:stop()
	end
	sound:play()
end

function playmusic(music)
	if musicenabled then
		if music then
			music:stop()
		end
		love.audio.stop()
		if music then
			music:play()
		end
	end
end

function randomize()
	math.randomseed(os.time())
	for i = 1, 5 do
		math.random()
	end
end

--scaling edits
lgs = love.graphics.setScissor
function love.graphics.setScissor(x, y, w, h)
	if x and y and w and h then
		-- If drawing directly (no canvas), adjust for offset and scale.
		if not canvas then
			x, y, w, h = (x*scale[1] + offsetx), (y*scale[2] + offsety), (w*scale[1]), (h*scale[2])
		end
		lgs(x, y, w, h)
	else
		lgs()
	end
end

-- Updated mouse helpers: account for offset and scale so clicks match visuals
lmx = love.mouse.getX
function love.mouse.getX()
	local x = lmx()
	x = (x - offsetx) / scale[1]
	return x
end
lmy = love.mouse.getY
function love.mouse.getY()
	local y = lmy()
	y = (y - offsety) / scale[2]
	return y
end
function love.mouse.getPosition()
	local x, y = love.mouse.getX(), love.mouse.getY()
	return x, y
end

-- Handle window resizes (added)
function love.resize(w, h)
	recalcScale(w, h)
end
