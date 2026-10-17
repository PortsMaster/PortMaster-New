require("table-save")
require("player")
require("cloud")
require("train")
require("tunnel")
require("gorge")
require("bird")
require("terrain")
require("menu")

WIDTH = 300
HEIGHT = 100
SCALE = 3
local FIT = os.getenv("IYFCT_FIT") ~= nil
local OFFX, OFFY = 0, 0

bgcolor = {236/255,243/255,201/255,1}
darkcolor = {2/255,9/255,4/255,1}

TRACK_SPEED = 150

SPEED_INCREASE = 0.04
START_SPEED = 1.7
MAX_SPEED = 2.5

pause = false
mute = false
gamestate = 1
selection = 0
submenu = 0

highscore = {0,0,0}
difficulty = 1
difficulty_settings = {{1.5,0.03,2.5},{1.7,0.04,2.5},{2.25,0.06,3.1}}

use_music = true

function love.load()
	math.randomseed(os.time())
	love.graphics.setBackgroundColor(bgcolor)

	loadHighscore()
	loadResources()
	love.graphics.setFont(imgfont)

	pl = Player.create()
	updateScale()
	restart()
end

function restart()
	pl:reset()
	clouds = {}
	next_cloud = 0
	birds = {}
	next_bird = 1
	track_frame = 0
	scrn_shake = 0

	START_SPEED = difficulty_settings[difficulty][1]
	SPEED_INCREASE = difficulty_settings[difficulty][2]
	MAX_SPEED = difficulty_settings[difficulty][3]
	global_speed = START_SPEED

	train = Train.create()
	train.alive = false
	tunnel = Tunnel.create()
	tunnel.alive = false
	gorge = Gorge.create()
	gorge.alive = false

	score = 0
	coffee = 0
end

function love.update(dt)
	if gamestate == 0 then
		updateGame(dt)
	elseif gamestate == 1 then
		updateMenu(dt)
	end
end

function updateGame(dt)
	if pause == true then
		return
	end
	-- Update screenshake thingy
	if scrn_shake > 0 then
		scrn_shake = scrn_shake - dt
	end

	-- Update player
	pl:update(dt)

	-- Update clouds
	spawnClouds(dt)
	for i,cl in ipairs(clouds) do
		cl:update(dt)
		if cl.x < -32 then
			table.remove(clouds,i)
		end
	end

	-- Update trains
	train:update(dt)
	
	-- Update tunnel
	tunnel:update(dt)

	-- Update gorge
	gorge:update(dt)
	
	-- Update birds
	spawnBirds(dt)
	for i,b in ipairs(birds) do
		b:update(dt)
		if b.alive == false then
			table.remove(birds,i)
		end
	end

	-- Check collisions
	if pl.alive == true then
		pl:collideWithTrain()
		pl:collideWithTunnel()
		pl:collideWithBirds()
		pl:collideWithGorge()
	end

	-- Move railway tracks
	updateTracks(dt)

	-- Update terrain (skyscrapers etc.)
	updateTerrain(dt)

	-- Increase speed and score
	--if pl.status == 0 or pl.status == 3 then
	if pl.alive == true then
		global_speed = global_speed + SPEED_INCREASE*dt
		if global_speed > MAX_SPEED then global_speed = MAX_SPEED end
		score = score + 20*dt
	end

	-- Respawn train or tunnel
	if train.alive == false then
		if tunnel.alive == false then
			if gorge.alive == false then
				local banana = math.random(1,5)
				if banana == 1 then -- spawn tunnel
					tunnel = Tunnel.create()
				elseif banana == 2 and global_speed > 1.7 then
					gorge = Gorge.create()
				else
					train = Train.createRandom()
				end
			end
		else
			if tunnel.x > WIDTH then
				train = Train.create(2)
				train.x = tunnel.x + math.random(1,250) - (tunnel.x - WIDTH)
			end
		end
	end
end

function love.draw()
	if FIT then
		love.graphics.setScissor()
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.setScissor(OFFX, OFFY, math.ceil(WIDTH*SCALE), math.ceil(HEIGHT*SCALE))
		love.graphics.translate(OFFX, OFFY)
	end
	love.graphics.scale(SCALE,SCALE)
	love.graphics.setColor(1,1,1,1)
	if gamestate == 0 then
		drawGame()
	elseif gamestate == 1 then
		drawMenu()
	end
end

function drawGame()
	-- Shake camera if hit
	if scrn_shake > 0 then
		love.graphics.translate(5*(math.random()-0.5),5*(math.random()-0.5))
	end

	-- Draw terrain (skyscrapers etc.)
	drawTerrain()

	-- Draw clouds
	for i,cl in ipairs(clouds) do
		cl:draw()
	end

	-- Draw back of tunnel
	tunnel:drawBack()

	-- Draw railroad tracks
	drawTracks()

	-- Draw gorge
	gorge:draw()

	-- Draw train
	train:draw()

	-- Draw player
	love.graphics.setColor(1,1,1,1)
	pl:draw()

	-- Draw front of tunnel
	tunnel:drawFront()

	-- Draw birds
	for i,b in ipairs(birds) do
		b:draw(v)
	end

	-- Draw score
	love.graphics.setColor(darkcolor)
	love.graphics.print(math.floor(score),8,8)

	-- Draw game over message
	if pl.alive == false then
		love.graphics.printf("you didn't make it to work\npress r to retry",0,30,WIDTH,"center")
		love.graphics.printf("your score: ".. score .. " - highscore: " .. highscore[difficulty],0,65,WIDTH,"center")
	end

	-- Draw pause message
	if pause == true then
		love.graphics.printf("paused\npress p to continue",0,50,WIDTH,"center")
	end

	-- Draw coffee meter
	local cquad = love.graphics.newQuad(48+math.floor(coffee)*9,64,9,9,128,128)
	if coffee < 5 or pl.frame < 4 then
		love.graphics.draw(imgSprites,cquad,284,7)
	end
end

function love.keypressed(key,scancode)
	if key == 'space' then
		return         -- avoid unnecessary checks
	elseif key == 'r' then
		restart()
	elseif key == 'up' then
		selection = selection-1
	elseif key == 'down' then
		selection = selection+1

	elseif key == 'return' then
		if gamestate == 1 then
			if submenu == 0 then -- splash screen
				submenu = 2 -- Jumps straight to difficulty.
				auSelect:stop() auSelect:play()
			elseif submenu == 2 then  -- difficulty selection
				difficulty = selection+1
				auSelect:stop() auSelect:play()
				gamestate = 0
				restart()
			end
		end

	elseif key == 'escape' then
		if gamestate == 0 then -- ingame
			gamestate = 1
			submenu = 2
			selection = 0
		elseif gamestate == 1 then
			if submenu == 0 then
				love.event.quit()
			elseif submenu == 2 then
				submenu = 0
			end
		end
		auSelect:stop() auSelect:play()
	elseif key == 'p' then
		if gamestate == 0 and pl.alive == true then
			pause = not pause
		end
	elseif key == 'm' then
		if mute == false then
			mute = true
			love.audio.setVolume(0.0)
		else
			mute = false
			love.audio.setVolume(1.0)
		end
	elseif scancode == '1' or key == 'kp1' or key == 'f1' then
		SCALE = 1
		updateScale()
	elseif scancode == '2' or key == 'kp2' or key == 'f2' then
		SCALE = 2
		updateScale()
	elseif scancode == '3' or key == 'kp3' or key == 'f3' then
		SCALE = 3
		updateScale()
	elseif scancode == '4' or key == 'kp4' or key == 'f4' then
		SCALE = 4
		updateScale()
	elseif scancode == '5' or key == 'kp5' or key == 'f5' then
		SCALE = 5
		updateScale()
	elseif scancode == '6' or key == 'kp6' or key == 'f6' then
		SCALE = 6
		updateScale()
	end
end

function updateScale()
	if FIT then
		love.window.setMode(0, 0, {fullscreen=true, fullscreentype="desktop"})
		local w, h = love.graphics.getDimensions()
		SCALE = math.min(w/WIDTH, h/HEIGHT)
		OFFX, OFFY = math.floor((w - WIDTH*SCALE)/2), math.floor((h - HEIGHT*SCALE)/2)
		return
	end
	SCRNWIDTH = WIDTH*SCALE
	SCRNHEIGHT = HEIGHT*SCALE
	love.window.setMode(SCRNWIDTH,SCRNHEIGHT,{fullscreen=false})
end

function loadResources()
	-- Load images
	imgSprites = love.graphics.newImage("gfx/sprites.png")
	imgSprites:setFilter("nearest","nearest")
	
	imgTrains = love.graphics.newImage("gfx/trains.png")
	imgTrains:setFilter("nearest","nearest")

	imgTerrain = love.graphics.newImage("gfx/terrain.png")
	imgTerrain:setFilter("nearest","nearest")

	imgSplash = love.graphics.newImage("gfx/splash.png")
	imgSplash:setFilter("nearest","nearest")

	imgfont = love.graphics.newImageFont("gfx/imgfont.png"," abcdefghijklmnopqrstuvwxyz0123456789.!'-:*", 1)
	imgfont:setFilter("nearest","nearest")
	imgfont:setLineHeight(2)

	-- Load sound effects
	auCoffee = love.audio.newSource("sfx/coffee.wav","static")
	auHit = love.audio.newSource("sfx/hit.wav","static")
	auSelect = love.audio.newSource("sfx/select.wav","static")
	if use_music == true then
		auBGM = love.audio.newSource("sfx/bgm.ogg","stream")
		auBGM:setLooping(true)
		auBGM:setVolume(0.6)
		auBGM:play()
	end
end

function loadHighscore()
	if love.filesystem.getInfo("highscore") then
		local data = love.filesystem.read("highscore")
		if data ~=nil then
			local datatable = table.load(data)
			if #datatable == #highscore then
				highscore = datatable
			end
		end
	end
end

function saveHighscore()
	local datatable = table.save(highscore)
	love.filesystem.write("highscore",datatable)
end

function love.quit()
	saveHighscore()
end

function love.focus(f)
	if not f and gamestate == 0 and pl.alive == true then
		pause = true
	end
end

--[[
  Gamestates:
  0 ingame
  1 menu
--]]
