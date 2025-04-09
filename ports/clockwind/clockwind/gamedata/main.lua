---------------------------------------------------
--------------------BY ALESAN99--------------------
---------------------------------------------------
--STARTED: 11/24/2019

local randomize, canvas
scale, vsync, fullscreen = {2,2}, false, false

function love.load()
	randomize()

	class = require("middleclass")
	require "variables"

	require "intro"
	require "game"
	require "menu"
	require "worldmap"

	require "camera"

	require "physics"
	require "objects/player"
	require "objects/enemy"
	require "objects/tile"
	require "objects/border"
	require "objects/seed"
	require "objects/tree"
	require "objects/bush"
	require "objects/goal"
	require "objects/bomb"
	require "objects/jelly"
	require "objects/car"
	require "objects/gear"

	easing = require("easing")

	--Settings
	love.filesystem.setIdentity("clockwind")
	load_settings()
	setscale(scale[1])
	load_save()
	
	love.window.setTitle("Clockwind")
	love.window.setIcon(love.image.newImageData("graphics/icon.png"))

	--Graphics
	love.graphics.setDefaultFilter("nearest", "nearest")
	canvas = love.graphics.newCanvas(WINWIDTH, WINHEIGHT)
	canvas:setFilter("nearest", "nearest")

	--menu
	titlescreenbackground = love.graphics.newImage("graphics/titlescreenbackground.png")
	titleimg = love.graphics.newImage("graphics/title.png")

	tilesimg = {}
	tileq = {{},{},{}}
	tileprops = {"collision", "foreground", "anim", "dirt", "platform", "breakable", "spikeup", "spikedown", "spikeleft", "spikeright"}
	tilepropst = {}
	for i = 1, #tileprops do
		tilepropst[tileprops[i]] = i
	end

	--world map
	worldmapimg = love.graphics.newImage("graphics/worldmap.png")
	
	for i = 1, 3 do --load 3 tile maps (three time periods)
		tilesimg[i] = love.graphics.newImage("graphics/tiles" .. i .. ".png")
		local tilesimgd = love.image.newImageData("graphics/tiles" .. i .. ".png")
		for y = 1, tilesimg[i]:getHeight()/(TILE+1) do
			for x = 1, tilesimg[i]:getWidth()/TILE do
				local t = {}
				--1:Collision
				--2:Foreground?
				--3:Animation id
				--4:Dirt (for trees)
				--5:Platform (todo)
				--6:Breakable
				--7:Spikes Up
				--8:Spikes Down
				--9:Spikes Left
				--10:Spikes Right
				for i = 1, TILE do
					local r, g, b, a = tilesimgd:getPixel((TILE*(x-1))+(i-1), ((TILE+1)*(y-1))+TILE)
					if a > 0 then
						if i == 3 then
							--animated
							t[i] = math.floor(r*255) .. "-" .. math.floor(g*255) .. "-" .. math.floor(b*255) .. "-" .. math.floor(a*255)
						else
							t[i] = i
						end
					end
				end
				table.insert(tileq[i], {love.graphics.newQuad(TILE*(x-1), (TILE+1)*(y-1), TILE, TILE, tilesimg[i]:getWidth(), tilesimg[i]:getHeight()), t = t})
			end
		end
	end
	objtileq = {} --object tiles
	objtilesimg = love.graphics.newImage("graphics/objects.png")
	for y = 1, objtilesimg:getHeight()/TILE do
		for x = 1, objtilesimg:getWidth()/TILE do
			table.insert(objtileq, love.graphics.newQuad(TILE*(x-1), (TILE+1)*(y-1), TILE, TILE, objtilesimg:getWidth(), objtilesimg:getHeight()))
		end
	end

	--animated tiles
	tilesanim = {}
	local files = love.filesystem.getDirectoryItems("graphics/tilesanim")
	for i, name in pairs(files) do
		if name:sub(-4, -1) == ".png" then
			--filename is r, g, b, a of animated tile id
			local vals = name:sub(1, -5)
			vals = vals:split("-")
			local r, g, b, a = tonumber(vals[1]), tonumber(vals[2]), tonumber(vals[3]), tonumber(vals[4])
			local t = {}
			local img = love.graphics.newImage("graphics/tilesanim/" .. name)
			t.img = img
			t.q = {}
			for y = 1, 3 do --time periods
				t.q[y] = {}
				for x = 1, math.floor(img:getWidth()/TILE) do
					t.q[y][x] = love.graphics.newQuad(TILE*(x-1), (TILE+1)*(y-1), TILE, TILE, img:getWidth(), img:getHeight())
				end
			end
			--delays
			local s = love.filesystem.read("graphics/tilesanim/" .. name:sub(1, -5) .. ".txt")
			local s2 = s:split(",")
			t.delay = {}
			for x = 1, math.floor(img:getWidth()/TILE) do
				table.insert(t.delay, tonumber(s2[math.min(x, #s2)]))
			end
			t.frame = 1
			t.timer = 0
			tilesanim[r .. "-" .. g .. "-" .. b .. "-" .. a] = t
		end
	end

	--backgrounds
	backgrounds = {}
	local files = love.filesystem.getDirectoryItems("graphics/backgrounds")
	for i2, foldername in pairs(files) do
		local folder = love.filesystem.getDirectoryItems("graphics/backgrounds/" .. foldername)
		backgrounds[foldername] = {}
		for i, name in pairs(folder) do
			if name:sub(-4, -1) == ".png" then
				local t = {}
				t.img = love.graphics.newImage("graphics/backgrounds/" .. foldername .. "/" .. name)
				t.w = t.img:getWidth()
				t.h = t.img:getHeight()/3
				t.q = {}
				local h = t.img:getHeight()/3
				for y = 1, 3 do
					t.q[y] = love.graphics.newQuad(0, h*(y-1), t.img:getWidth(), h, t.img:getWidth(), t.img:getHeight())
				end
				backgrounds[foldername][tonumber(name:sub(1, -5))] = t
			end
		end
	end

	--font
	font = love.graphics.newImageFont("graphics/font.png", "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .!?<>,_-=/\\;':%", 1)
	love.graphics.setFont(font)
	tinyfont = love.graphics.newFont(8)

	playerimg = love.graphics.newImage("graphics/player.png")
	playerq = {}
	for y = 1, 2 do
		playerq[y] = {}
		for x = 1, 20 do
			playerq[y][x] = love.graphics.newQuad(40*(x-1), 40*(y-1), 40, 40, playerimg:getWidth(), playerimg:getHeight())
		end
	end

	timekeeperimg = love.graphics.newImage("graphics/timekeeper.png")

	treeimg = love.graphics.newImage("graphics/tree.png")
	treeq = {}
	treeq.top = love.graphics.newQuad(0, 0, 20, 20, treeimg:getWidth(), treeimg:getHeight())
	treeq.trunk = love.graphics.newQuad(0, 20, 20, 20, treeimg:getWidth(), treeimg:getHeight())
	treeq.branchright = love.graphics.newQuad(20, 0, 41, 20, treeimg:getWidth(), treeimg:getHeight())
	treeq.branchleft = love.graphics.newQuad(20, 20, 41, 20, treeimg:getWidth(), treeimg:getHeight())

	seedimg = love.graphics.newImage("graphics/seed.png")
	seedq = {}
	for i = 1, 3 do
		seedq[i] = {}
		for x = 1, seedimg:getWidth()/16 do
			seedq[i][x] = {}
			for y = 1, 2 do
				seedq[i][x][y] = love.graphics.newQuad(16*(x-1), 16*(y-1)+32*(i-1), 16, 16, seedimg:getWidth(), seedimg:getHeight())
			end
		end
	end

	bombimg = love.graphics.newImage("graphics/bomb.png")
	bombq = {}
	for x = 1, bombimg:getWidth()/16 do
		bombq[x] = love.graphics.newQuad(16*(x-1), 0, 16, 16, bombimg:getWidth(), bombimg:getHeight())
	end

	bushimg = love.graphics.newImage("graphics/bush.png")
	pistonimg = love.graphics.newImage("graphics/piston.png")
	seaweedimg = love.graphics.newImage("graphics/seaweed.png")
	bushq = {}
	for t = 1, 3 do --timeperiod
		bushq[t] = {}
		for i = 1, 2 do
			bushq[t][i] = {}
			bushq[t][i][1] = love.graphics.newQuad(20*(i-1), 40*(t-1), 20, 10, bushimg:getWidth(), bushimg:getHeight())
			bushq[t][i][2] = love.graphics.newQuad(20*(i-1), 10+40*(t-1), 20, 20, bushimg:getWidth(), bushimg:getHeight())
			bushq[t][i][3] = love.graphics.newQuad(20*(i-1), 30+40*(t-1), 20, 10, bushimg:getWidth(), bushimg:getHeight())
		end
	end

	goalimg = love.graphics.newImage("graphics/goal.png")
	goalq = {}
	for x = 1, 2 do
		goalq[x] = love.graphics.newQuad(40*(x-1), 0, 40, 40, goalimg:getWidth(), goalimg:getHeight())
	end

	jellyimg = love.graphics.newImage("graphics/jelly.png")
	jellyq = {}
	for t = 1, 3 do
		jellyq[t] = {}
		for x = 1, 2 do
			jellyq[t][x] = love.graphics.newQuad(20*(x-1), 20*(t-1), 20, 20, jellyimg:getWidth(), jellyimg:getHeight())
		end
	end

	waterimg = love.graphics.newImage("graphics/water.png")
	waterbackimg = love.graphics.newImage("graphics/waterback.png")
	waterq = {}
	for x = 1, 4 do
		waterq[x] = love.graphics.newQuad(30*(x-1), 0, 30, 20, waterimg:getWidth(), waterimg:getHeight())
	end

	dinoimg = love.graphics.newImage("graphics/dino.png")
	dinoq = {}
	for t = 1, 3 do
		dinoq[t] = {}
		for x = 1, 4 do
			dinoq[t][x] = love.graphics.newQuad(64*(x-1), 40*(t-1), 64, 40, dinoimg:getWidth(), dinoimg:getHeight())
		end
	end

	carimg = love.graphics.newImage("graphics/car.png")
	carq = {}
	for t = 1, 3 do
		carq[t] = {}
		for x = 1, 2 do
			carq[t][x] = love.graphics.newQuad(66*(x-1), 40*(t-1), 66, 40, carimg:getWidth(), carimg:getHeight())
		end
	end

	gearcogimg = love.graphics.newImage("graphics/gearcog.png")
	gearholeimg = love.graphics.newImage("graphics/gearhole.png")

	banditimg = love.graphics.newImage("graphics/bandit.png")
	banditq = {}
	for t = 1, 3 do
		banditq[t] = {}
		for x = 1, 2 do
			banditq[t][x] = love.graphics.newQuad(20*(x-1), 40*(t-1), 20, 40, banditimg:getWidth(), banditimg:getHeight())
		end
	end

	pendulumsupportimg = love.graphics.newImage("graphics/pendulumsupport.png")

	biggearimg = {}
	biggearimg[1] = love.graphics.newImage("graphics/biggear1.png")
	biggearimg[2] = love.graphics.newImage("graphics/biggear2.png")
	biggearimg[3] = love.graphics.newImage("graphics/biggear3.png")
	biggearimg[4] = love.graphics.newImage("graphics/biggear4.png")

	levelmarkerimg = love.graphics.newImage("graphics/levelmarker.png")
	levelmarkerq = {}
	for i = 1, 2 do
		levelmarkerq[i] = love.graphics.newQuad(20*(i-1), 0, 20, 18, levelmarkerimg:getWidth(), levelmarkerimg:getHeight())
	end

	poofimg = love.graphics.newImage("graphics/poof.png")
	poofq = {}
	for x = 1, math.floor(poofimg:getWidth()/40) do
		table.insert(poofq, love.graphics.newQuad(40*(x-1), 0, 40, 40, poofimg:getWidth(), poofimg:getHeight()))
	end

	sounds = {}
	local files = love.filesystem.getDirectoryItems("sounds")
	for i, n in pairs(files) do
		local name = n:sub(1, -5)
		sounds[name] = love.audio.newSource("sounds/" .. name .. ".ogg", "static")
	end

	--setgamestate("game")
	setgamestate("intro")
end

function love.update(dt)
	local dt = math.min(0.03333333333, dt)
	if _G[gamestate].update then
		_G[gamestate].update(dt)
	end
end

local usecanvas = true
function love.draw()
	if usecanvas then
		love.graphics.setCanvas{canvas, stencil=true}
		love.graphics.clear()
		love_draw()
		love.graphics.setCanvas()
		love.graphics.setColor(1,1,1)
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(canvas, 0, 0, 0, love.graphics.getWidth()/WINWIDTH, love.graphics.getHeight()/WINHEIGHT)
		love.graphics.setBlendMode("alpha")
	else
		love.graphics.scale(love.graphics.getWidth()/WINWIDTH, love.graphics.getHeight()/WINHEIGHT)
		love_draw()
	end
end

function love_draw()
	love.graphics.setColor(love.graphics.getBackgroundColor())
	love.graphics.rectangle("fill", 0, 0, WINWIDTH, WINHEIGHT)
	love.graphics.setColor(1,1,1)
	if _G[gamestate].draw then
		_G[gamestate].draw()
	end
end

function love.keypressed(key)
	if key == "return" and love.keyboard.isDown("lalt") then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen)
		return
	end
	if _G[gamestate].keypressed then
		_G[gamestate].keypressed(key)
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

function love.mousemoved(dx, dy)
	local dx, dy = dx/scale[1], dy/scale[2]
	if _G[gamestate].mousemoved then
		_G[gamestate].mousemoved(dx, dy)
	end
end

function love.wheelmoved(dx, dy)
	if _G[gamestate].wheelmoved then
		_G[gamestate].wheelmoved(dx, dy)
	end
end

function setgamestate(state, args)
	assert(_G[state], "Invalid game state")
	gamestate = state
	local args = args or {}
	_G[state].load(unpack(args))
end

--Saving
function load_settings()
	if love.filesystem.exists("settings") then
		local s = love.filesystem.read("settings")
		local s2 = s:split("~")

		volume = tonumber(s2[1])
		love.audio.setVolume(volume)
		scale = {tonumber(s2[2]), tonumber(s2[2])}
		vsync = (s2[3] == "true")

		default_controls()
		local controli = 1
		for i = 1, #controlstable do
			controls[controlstable[i]] = s2[3+i]
		end
	else
		default_settings()
	end
end

function default_settings()
	fullscreen = false
	vsync = false
	scale = {2, 2}
	volume = 1

	default_controls()
end

function default_controls()
	controlstable = {"left", "right", "up", "down", "action", "jump", "timeleft", "timeright", "timetoggle"}
	controls = {}
	controls["left"] = love.keyboard.getScancodeFromKey("a")
	controls["right"] = love.keyboard.getScancodeFromKey("d")
	controls["up"] = love.keyboard.getScancodeFromKey("w")
	controls["down"] = love.keyboard.getScancodeFromKey("s")
	controls["action"] = love.keyboard.getScancodeFromKey("lshift")
	controls["jump"] = love.keyboard.getScancodeFromKey("space")

	controls["timeleft"] = love.keyboard.getScancodeFromKey("left")
	controls["timeright"] = love.keyboard.getScancodeFromKey("right")
	controls["timetoggle"] = love.keyboard.getScancodeFromKey("f")
end

function save_settings()
	local s = volume .. "~"
	s = s .. scale[1] .. "~"
	s = s .. tostring(vsync) .. "~"
	for i = 1, #controlstable do
		s = s .. tostring(controls[controlstable[i]]) .. "~"
	end

	love.filesystem.write("settings", s)
end

function load_save()
	levelscompleted = 0
	if love.filesystem.exists("save") then
		local s = love.filesystem.read("save")
		levelscompleted = tonumber(s) or 0
	end
end

function create_save()
	local s = tostring(levelscompleted)
	love.filesystem.write("save", s)
end

function delete_save()
	local s = "0"
	love.filesystem.write("save", s)
	levelscompleted = 0
end

function setscale(s)
	fullscreen = false
	scale = {s, s}
	love.window.setMode(WINWIDTH*s, WINHEIGHT*s, {vsync = vsync, resizable = true, minwidth = WINWIDTH, minheight = WINHEIGHT})
end

function string:split(d)
	local data = {}
	local from, to = 1, string.find(self, d)
	while to do
		table.insert(data, string.sub(self, from, to-1))
		from = to+#d
		to = string.find(self, d, from)
	end
	table.insert(data, string.sub(self, from))
	return data
end

function math.round(v)
	return math.floor(v+.5)
end

function playSound(sound, a)
	if not a then
		sounds[sound]:stop()
	end
	sounds[sound]:play()
end

function randomize()
	math.randomseed(os.time())
	for i = 1, 5 do
		math.random()
	end
end

function getangle(x1, y1, x2, y2)
	return math.atan2(y2-y1, x2-x1)
end
function getangle2(x1, y1, x2, y2)
	return -math.atan2(y2-y1, x2-x1)+math.pi*1.5
end

function love.filesystem.exists(file)
	return love.filesystem.getInfo(file)
end

--scaling edits
lgs = love.graphics.setScissor
function love.graphics.setScissor(x, y, w, h)
	if x and y and w and h then
		if rescale then
			x, y, w, h = x*scale[1], y*scale[2], w*scale[1], h*scale[2]
		end
		lgs(x, y, w, h)
	else
		lgs()
	end
end

lmx = love.mouse.getX
function love.mouse.getX()
	local x = lmx()
	x = x/scale[1]
	return x
end
lmy = love.mouse.getY
function love.mouse.getY()
	local y = lmy()
	y = y/scale[2]
	return y
end
function love.mouse.getPosition()
	local x, y = love.mouse.getX(), love.mouse.getY()
	return x, y
end
