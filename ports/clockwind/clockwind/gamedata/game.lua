game = {}

local editor = require("editor")
local Map = require("map")
local Camera = require("camera")

local spritebatch
local lockcamerax = false

--transition effects
local transitionin = false
local transitionintarget = false
local transitionintime = 0.4
local transitionout = false
local transitionouttime = 0.3

--visual flare
local timekeeperpopup = false
local timekeeperpopupspeed = 8
local timekeeperpopuptimerreached = false
local timekeeperpopuptimer = 0
local cloudscroll = 0
local pendulum = 0
local wateranimframe = 1
local wateranimdelay = 0.2
local wateranimtimer = 0
local wintransitionouttimer = false
local completetimer = false --game complete
local completetime = 10
local biggear = {{138, 38}, {92, 84}, {157, 115}, {226, 74}}
local biggearrot = {2,1,1.3,1.25/1.3}
local biggearappear
local biggearstage
local biggearrotation
local gearmovingx
local gearmovingy
local gearmovingspeed
local biggearspeed

leveledit = false

function game.load(level)
	love.graphics.setBackgroundColor(0,0,0.2)
	if not leveledit then
		transitionin = transitionintime
	end
	LEVEL = level or 1
	load_level(LEVEL)

	cloudscroll = 0

	if leveledit then
		editor.load()
	end
end

function game.update(dt)
	--transitions
	if transitionin then
		transitionin = transitionin - dt
		if transitionin < 0 then
			transitionin = false
		end
	elseif transitionout then
		transitionout = transitionout - dt
		if transitionout < 0 then
			if transitionouttarget == "lose" then
				setgamestate("worldmap")
			elseif transitionouttarget == "win" then
				if LEVEL == levelscompleted+1 then
					levelscompleted = levelscompleted + 1
					create_save()
				end
				setgamestate("worldmap")
			elseif transitionouttarget == "finalwin" then
				if LEVEL == levelscompleted+1 then
					levelscompleted = levelscompleted + 1
					create_save()
				end
				setgamestate("menu")
				completetimer = false
			elseif transitionouttarget == "respawn" then
				transitionin = transitionintime
				obj["player"][1]:respawn()
			end
			transitionout = false
		end
	end

	if completetimer then
		if gearmovingy then
			gearmovingspeed = gearmovingspeed + 320*dt
			gearmovingy = math.min(biggear[biggearstage][2], gearmovingy + gearmovingspeed*dt)
			if gearmovingy >= biggear[biggearstage][2] then
				biggearappear[biggearstage] = true
				makepoof(gearmovingx+camera.x, gearmovingy)

				biggearstage = biggearstage + 1
				if biggearstage > #biggear then
					gearmovingx = false
					gearmovingy = false
					playSound("gear")
					playSound("win")
				else
					gearmovingx = biggear[biggearstage][1]
					gearmovingy = -40
					gearmovingspeed = 0
					playSound("gear")
				end
			end
		else
			if completetimer > completetime then
				biggearrotation = biggearrotation + biggearspeed*dt
			else
				completetimer = completetimer + dt
				if completetimer > 2 and (not gearmovingx) and biggearstage <= 1 then
					biggearstage = 1
					gearmovingx = biggear[biggearstage][1]
					gearmovingy = -40
				end
				if (not leveledit) and camera:getY() > 0 then
					camera:move(camera:getX(), math.max(camera:getY()-50*dt))
				end
				if completetimer > 2 and (not gearmovingx) then
					biggearspeed = math.min(2, biggearspeed + 2*dt)
					biggearrotation = biggearrotation + biggearspeed*dt
				end
				if completetimer > completetime then
					game.transitionout("finalwin")
				end
			end
		end
	elseif wintransitionouttimer then
		wintransitionouttimer = wintransitionouttimer - dt
		if wintransitionouttimer < 0 then
			if LEVEL == 4 then
				completetimer = 0
				biggearspeed = 0
				wintransitionouttimer = false
				biggearappear = {false, false, false, false}
				biggearstage = 1
				biggearrotation = 0
				gearmovingx = false
				gearmovingy = false
				gearmovingspeed = 0
				if obj["goal"][1] then
					obj["goal"][1]:headout()
				end
			else
				game.transitionout("win")
				wintransitionouttimer = false
			end
		end
	end

	--time travel
	if not leveledit then
		local oldtimep = timep
		if (love.keyboard.isDown(controls["timeleft"]) or (love.keyboard.isDown(controls["timetoggle"]) and love.keyboard.isDown(controls["left"]))) and (not (timep-math.max(1, timep - TIMETRAVELSPEED*dt) == 0)) and obj["player"][1].controlsenabled then
			timep = math.max(1, timep - TIMETRAVELSPEED*dt)
			timetraveling = TIMETRAVELANIMTIME
		elseif (love.keyboard.isDown(controls["timeright"]) or (love.keyboard.isDown(controls["timetoggle"]) and love.keyboard.isDown(controls["right"]))) and (not (timep-math.min(TIMEPERIODS, timep + TIMETRAVELSPEED*dt) == 0)) and obj["player"][1].controlsenabled then
			timep = math.min(TIMEPERIODS, timep + TIMETRAVELSPEED*dt)
			timetraveling = TIMETRAVELANIMTIME
		elseif timetraveling then
			timetraveling = timetraveling - dt
			if timetraveling < 0 then
				timetraveling = false
				sounds["timetraveling"]:stop()
				playSound("timeoff")
			end
		end
		timetraveldist = timep-oldtimep
		if timetraveling then
			if not sounds["timetraveling"]:isPlaying() then
				playSound("timetraveling")
			end
		end

		--update water level
		if waterlevel then
			waterlevel = WATERLEVEL_high+((WATERLEVEL_low-WATERLEVEL_high)*((timep-1)/(TIMEPERIODS-1)))
		end

		--rounded time period
		local oldtimeperiod = timeperiod
		if timep-1 < ((TIMEPERIODS-1)/3) then
			timeperiod = 1
		elseif timep-1 < ((TIMEPERIODS-1)/3)*2 then
			timeperiod = 2
		else
			timeperiod = 3
		end
		if timeperiod ~= oldtimeperiod then
			timeperiodtransition = {TIMEPERIODTRANSITIONTIME, timeperiod, oldtimeperiod}
		end
		if timeperiodtransition then
			timeperiodtransition[1] = timeperiodtransition[1] - dt
			if timeperiodtransition[1] < 0 then
				timeperiodtransition = false
			end
		end
	end

	--old camera
	local oldcamera = {x = camera.x, y = camera.y}

	--physics objects
	local tdt = dt --time goes slower while time traveling
	local tanimdt = 0 --animations go fast to show passage of time
	if timetraveling then
		tdt = dt*(1-(TIMETRAVELSLOWDOWN*(timetraveling/TIMETRAVELANIMTIME)))
		
		if timetraveldist < 0 then
			tanimdt = -dt*(TIMETRAVELSLOWDOWN*(timetraveling/TIMETRAVELANIMTIME))
		elseif timetraveldist > 0 then
			tanimdt = dt*(TIMETRAVELSLOWDOWN*(timetraveling/TIMETRAVELANIMTIME))
		end
	end
	for name, t in pairs(obj) do
		local delete = {}
		if name ~= "tile" then
			for a, b in pairs(t) do --change variable
				if b.update then
					b:update(tdt)
				end
				if b.delete then
					table.insert(delete, a)
				end
			end
		end
		table.sort(delete, function(a, b) return a > b end)
		for i, d in pairs(delete) do
			table.remove(t, d)
		end
	end

	physics_update(tdt)

	--animated tiles
	for i, t in pairs(tilesanim) do
		t.timer = t.timer + tdt
		while t.timer > t.delay[t.frame] do
			t.timer = t.timer - t.delay[t.frame]
			t.frame = (t.frame)%#t.q[timeperiod]+1
		end
	end

	--poofs
	local delete = {}
	for i, p in pairs(poofs) do
		p.timer = p.timer + tdt
		while p.timer > p.delay do
			p.frame = p.frame + 1
			if p.frame > #p.frames then
				table.insert(delete, i)
				break
			end
			p.timer = p.timer - p.delay
		end
	end
	table.sort(delete, function(a,b) return a > b end)
	for i, d in pairs(delete) do
		table.remove(poofs, d)
	end

	--misc. animation
	cloudscroll = cloudscroll + 5*dt + 1000*tanimdt
	pendulum = (pendulum + 0.5*tdt)%1

	if waterlevel then
		wateranimtimer = wateranimtimer + dt
		while wateranimtimer > wateranimdelay do
			wateranimframe = wateranimframe + 1
			if wateranimframe > 4 then
				wateranimframe = 1
			end
			wateranimtimer = wateranimtimer - wateranimdelay
		end
	end

	if timekeeperpopup then
		if timekeeperpopuptimerreached then
			if ((not timetraveling) or timetraveling <= TIMETRAVELANIMTIME*0.75) and (not love.keyboard.isDown(controls["timetoggle"])) then
				if timekeeperpopuptimer == 1 then
					playSound("timeoff")
				end
				timekeeperpopuptimer = math.max(0, timekeeperpopuptimer - timekeeperpopupspeed*dt)
				if timekeeperpopuptimer <= 0 then
					timekeeperpopuptimerreached = false
					timekeeperpopup = false
				end
			end
		else
			if timekeeperpopuptimer == 0 then
				playSound("timeon")
			end
			timekeeperpopuptimer = math.min(1, timekeeperpopuptimer + timekeeperpopupspeed*dt)
			if timekeeperpopuptimer >= 1 then
				timekeeperpopuptimerreached = true
			end
		end
	end

	--focus camera on player
	local p = obj["player"][1]
	if not completetimer then
		camera:focus(p.x, p.y, p.width, p.height)
		if lockcamerax and not leveledit then
			camera:move(lockcamerax, camera:getY())
		end
	end

	--editor
	if leveledit then
		editor.update(dt)
	end

	--camera view (spritebatch)
	map:update(dt)
	
	camera:update()

	--spawn new enemies (invertio code didn't work, fuck it, bruteforce time)
	if not leveledit then
		local cx, ox = math.max(0, math.floor(camera.x/TILE))+1, math.max(0, math.floor(oldcamera.x/TILE))+1
		local cy, oy = math.max(0, math.floor(camera.y/TILE))+1, math.max(0, math.floor(oldcamera.y/TILE))+1
		local cw, ch = math.floor(camera.w/TILE)+1, math.floor(camera.h/TILE)+1
		if cx ~= ox then --left and right sides spawning
			local y1, y2 = oy, cy --down
			if cy < oy then--up
				y1, y2 = cy, oy
			end
			local x1, x2
			if cx > ox then --right
				x1, x2 = ox+cw, cx+cw
			else --left
				x1, x2 = cx, ox
			end
			for x = x1, x2 do
				for y = y1, y2+ch do
					if map:get(x, y, 2) then
						spawn_enemy(x, y)
					end
				end
			end
		end
		if cy ~= oy then --up and down sides spawning
			local x1, x2 = ox, cx --right
			if cx < ox then--left
				x1, x2 = cx, ox
			end
			local y1, y2
			if cy > oy then --down
				y1, y2 = oy+ch, cy+ch
			else --up
				y1, y2 = cy, oy
			end
			for x = x1, x2+cw do
				for y = y1, y2 do
					if map:get(x, y, 2) then
						spawn_enemy(x, y)
					end
				end
			end
		end
	end
end

local lg = love.graphics
function game.draw()
	--GAMEPLAY
	love.graphics.push()

	--Background
	if map.background then
		love.graphics.setColor(1,1,1)
		local scrolli = 0
		for i, t in pairs(backgrounds[map.background]) do
			local cx, cy = camera:getX(), camera:getY()
			local panx, pany = cx, math.max(0,(t.img:getHeight()/3)-WINHEIGHT)*(camera.y/(map.h*TILE-camera.h)) --cy

			if map.background == "4" then
				panx = 0
				pany = camera:getY()
				scrolli = scrolli + 1
				pany = pany*(0.15*(scrolli))
			else
				--hard coded clouds
				if i == 2 then
					panx = cloudscroll
				else
					scrolli = scrolli + 1
					panx = panx*(0.15*(scrolli-1))
				end
			end
			if map.background == "4" and i == 2 then
				--pendulum
				love.graphics.setColor(1,1,1)
				local py = -WINHEIGHT
				local r = WINHEIGHT*2
				local a = (math.sin(pendulum*math.pi*2))*0.104
				love.graphics.draw(t.img, WINWIDTH/2+math.sin(a)*r, 0+py+math.floor(math.cos(a)*r-(pany*0.2)), 0, 1, 1, t.img:getWidth()/2, t.img:getHeight()/2)
				love.graphics.draw(pendulumsupportimg, WINWIDTH/2+math.sin(a)*r, 0+py+math.floor(math.cos(a)*r-(pany*0.2)), -a, 1, 1, pendulumsupportimg:getWidth()/2, pendulumsupportimg:getHeight())
			else
				love.graphics.setColor(1,1,1)
				local x1, x2 = math.floor(panx/t.w)+1, math.floor((panx+WINWIDTH)/t.w)+1
				local y1, y2 = math.floor(pany/t.h)+1, math.floor((pany+WINHEIGHT)/t.h)+1
				if pany == 0 and t.h == WINHEIGHT then
					y2 = y1
				end
				if panx == 0 and t.w == WINWIDTH then
					x2 = x1
				end
				for x = x1, x2 do
					for y = y1, y2 do
						drawtime(t.img, t.q, math.floor((x-1)*t.w+(-panx)), math.floor((y-1)*t.h+(-pany)))
					end
				end
			end
		end
	end

	--Camera Translate
	love.graphics.translate(-math.floor(camera:getX()), -math.floor(camera:getY()))

	--Water Background
	if waterlevel then
		love.graphics.setColor(0, 0.2, 0.8, 0.6)
		if waterlevel+20 > camera.y and waterlevel < camera.y+WINHEIGHT then
			local x1, x2 = math.floor(camera.x/30)+1, math.floor((camera.x+WINWIDTH)/20)+1
			for x = x1, x2 do
				love.graphics.draw(waterbackimg, waterq[wateranimframe], math.floor((x-1)*30), waterlevel)
			end
		end
		local x1, x2 = camera.x, camera.x+WINWIDTH
		local y1, y2 = math.max(camera.y-1, waterlevel+20), math.min(camera.y+WINHEIGHT, map.h*TILE)
		love.graphics.polygon("fill", x1, y1, x2, y1, x2, y2, x1, y2)
	end

	--Tile map
	if timeperiodtransition then
		map:draw("back", timeperiodtransition[2], timeperiodtransition[1]/TIMEPERIODTRANSITIONTIME, timeperiodtransition[3])
	else
		map:draw("back", timeperiod)
	end

	--win animation
	
	if completetimer then
		love.graphics.setColor(1,1,1,1)
		for i = 1, #biggear do
			if biggearappear[i] then
				local rotationdirection = 1*biggearrot[i]
				if math.floor(i/2) ~= i/2 then
					rotationdirection = -1*biggearrot[i]
				end
				love.graphics.draw(biggearimg[i], biggear[i][1]+camera.x, biggear[i][2], biggearrotation*rotationdirection, 1, 1, biggearimg[i]:getWidth()/2, biggearimg[i]:getHeight()/2)
			end
		end
		if gearmovingx and obj["goal"][1] then
			love.graphics.draw(goalimg, goalq[obj["goal"][1].frame], gearmovingx+camera.x, gearmovingy, 0, 1, 1, 20, 20)
		end
	end

	--Objects
	for i, obj in pairs(obj["gear"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	for i, obj in pairs(obj["tree"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	for i, obj in pairs(obj["branch"]) do
		obj:draw()
	end
	for i, obj in pairs(obj["bush"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	
	for i, obj in pairs(obj["enemy"]) do
		if camera:visible(obj.x-20, obj.y-20, obj.w+40, obj.h+40) then
			obj:draw()
		end
	end
	for i, obj in pairs(obj["jelly"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end

	for i, obj in pairs(obj["player"]) do
		obj:draw()
	end

	for i, obj in pairs(obj["car"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	
	for i, obj in pairs(obj["seed"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	for i, obj in pairs(obj["bomb"]) do
		if camera:visible(obj.x, obj.y, obj.w, obj.h) then
			obj:draw()
		end
	end
	for i, obj in pairs(obj["goal"]) do
		if camera:visible(obj.x-20, obj.y-20, obj.w+40, obj.h+40) then
			obj:draw()
		end
	end

	--poofs
	for i, p in pairs(poofs) do
		love.graphics.setColor(1,1,1)
		love.graphics.draw(poofimg, poofq[p.frames[p.frame]], p.x, p.y, p.r, 1, 1, 20, 20)
	end

	--Tile map front
	if timeperiodtransition then
		map:draw("front", timeperiodtransition[2], timeperiodtransition[1]/TIMEPERIODTRANSITIONTIME, timeperiodtransition[3])
	else
		map:draw("front", timeperiod)
	end

	--Water
	if waterlevel then
		love.graphics.setBlendMode("screen", "premultiplied")
		if waterlevel+20 > camera.y and waterlevel < camera.y+WINHEIGHT then
			local x1, x2 = math.floor(camera.x/30)+1, math.floor((camera.x+WINWIDTH)/20)+1
			for x = x1, x2 do
				love.graphics.draw(waterimg, waterq[wateranimframe], math.floor((x-1)*30), waterlevel)
			end
		end
		love.graphics.setColor(0, 0.2, 0.8, 1)
		local x1, x2 = camera.x, camera.x+WINWIDTH
		local y1, y2 = math.max(camera.y-1, waterlevel+20), math.min(camera.y+WINHEIGHT, map.h*TILE)
		love.graphics.polygon("fill", x1, y1, x2, y1, x2, y2, x1, y2)
		love.graphics.setBlendMode("alpha")
	end

	--Debug
	if leveledit then
		camera:draw()
	end
	if PHYSICSDEBUG then
		for name, t in pairs(obj) do
			for a, b in pairs(t) do
				if not b.active then
					love.graphics.setColor(1,0,0,0.5)
				else
					love.graphics.setColor(1,1,1,0.5)
				end
				love.graphics.setLineWidth(1)
				love.graphics.rectangle("line", math.floor(b.x)+.5, math.floor(b.y)+.5, b.w-1, b.h-1)
				if b.r then
					love.graphics.circle("line", math.floor(b.rx)+.5, math.floor(b.ry)+.5, b.r)
				end
			end
		end
	end

	love.graphics.pop()

	--Time Travel FX
	if timetraveling then
		--color thing over everything
		love.graphics.setBlendMode("multiply", "premultiplied")
		love.graphics.setColor(1-0.08*(timetraveling/TIMETRAVELANIMTIME), 1-0.10*(timetraveling/TIMETRAVELANIMTIME), 1-0.13*(timetraveling/TIMETRAVELANIMTIME), 1)
		love.graphics.rectangle("fill", 0, 0, WINWIDTH, WINHEIGHT)
		love.graphics.setBlendMode("alpha")
	end

	--HUD
	if not leveledit then
		--time
		love.graphics.setColor(1,1,1)
		local y = 26*(1-easing.outQuad(timekeeperpopuptimer, 0, 1, 1))
		
		love.graphics.draw(timekeeperimg, timekeeperimg:getWidth()/2+(WINWIDTH-timekeeperimg:getWidth())*((timep-1)/(TIMEPERIODS-1)), WINHEIGHT+y, 0, 1, 1, timekeeperimg:getWidth()/2, timekeeperimg:getHeight())
	end

	--Gear Get!
	if completetimer then
		if completetimer > completetime-6 then
			local v = easing.outBounce(math.max(0,math.min(1,completetimer-(completetime-6))), 0, 1, 1)-1
			if completetimer > completetime-5 then
				v = 0
			end
			love.graphics.setColor(1,1,1)
			love.graphics.setFont(font)
			love.graphics.printf("CONGRATULATIONS!", 0, WINHEIGHT/2+v*12, WINWIDTH, "center")
		end
	elseif wintransitionouttimer then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(font)
		love.graphics.printf("GEAR GET!", 0, WINHEIGHT/2-easing.inBounce(math.max(0,wintransitionouttimer-1.5), 0, LEVEL_wintime-1.5, LEVEL_wintime-1.5)*12, WINWIDTH, "center")
	end

	--fps
	--love.graphics.setColor(1,1,1,0.8)
	--love.graphics.setFont(font)
	--love.graphics.print(love.timer.getFPS())

	--Editor
	if leveledit then
		editor.draw()
	end
	
	--transitions
	if transitionin then
		love.graphics.setColor(0,0,0,transitionin/transitionintime)
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	elseif transitionout then
		love.graphics.setColor(0,0,0,1-(transitionout/transitionouttime))
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	end
end

function load_level(level)
	--Level Info
	LEVEL = level or 1
	camera = Camera:new(0, 0, WINWIDTH, WINHEIGHT)
	camera:setRange(CAMERA_LEFTEDGE, CAMERA_TOPEDGE, CAMERA_RIGHTEDGE-CAMERA_LEFTEDGE, CAMERA_BOTTOMEDGE-CAMERA_TOPEDGE)

	--Time Travel
	timetaveling = false --number
	timep = 1 --timeperiod: 1-3
	timeperiod = 1 --timep rounded
	timeperiodtransition = false --table: {timer/alpha, to, from}
	timetraveldist = 0

	--Objects
	obj = {}
	obj["player"] = {}
	obj["tile"] = {}
	obj["border"] = {}
	obj["enemy"] = {}
	obj["seed"] = {}
	obj["tree"] = {}
	obj["branch"] = {}
	obj["bush"] = {}
	obj["goal"] = {}
	obj["bomb"] = {}
	obj["jelly"] = {}
	obj["car"] = {}
	obj["gear"] = {}

	poofs = {}
	checkpoints = {}
	carcheckpoints = {}
	noupthrowing = {}

	enemiesspawned = {}

	waterlevel = false
	lockcamerax = false

	--Tile map
	map = Map:new(nil, nil)
	if not map:load(LEVEL) then
		map:create(20, 9)
	end

	camera:setBounds(0, 0, map.w*TILE, map.h*TILE)

	local playerstartx, playerstarty = 1, 1 --player start
	for x = 1, map.w do
		for y = 1, map.h do
			local tilei = map:get(x, y, 1)
			local forei = map:get(x, y, 2)
			local obji = map:get(x, y, 3)
			local text = map:get(x, y, 4)
			map:updateTile(x, y)

			if (not leveledit) or obji == 1 then
				if obji == 1 then --player
					playerstartx = x
					playerstarty = y-1
				elseif obji == 4 then --bush
					table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "bush"))
				elseif obji == 5 then --goal
					table.insert(obj["goal"], Goal:new((x-1)*TILE, (y)*TILE))
				elseif obji == 6 then --seaweed
					table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "seaweed"))
				elseif obji == 9 then --checkpoint
					checkpoints[x .. "|" .. y] = true
				elseif obji == 10 then --water
					waterlevel = WATERLEVEL_high
				elseif obji == 11 then --car
					table.insert(obj["car"], Car:new((x-1)*TILE, (y)*TILE))
				elseif obji == 12 then --gear
					local radius = 2
					if text and tonumber(text) then
						radius = tonumber(text)
					end
					table.insert(obj["gear"], Gear:new((x-1)*TILE, (y-1)*TILE, radius, false))
				elseif obji == 13 then
					lockcamerax = tonumber(text) or 0
				elseif obji == 14 then --counterclockwise gear
					local radius = 2
					if text and tonumber(text) then
						radius = tonumber(text)
					end
					table.insert(obj["gear"], Gear:new((x-1)*TILE, (y-1)*TILE, radius, true))
				elseif obji == 15 then --car checkpoint
					carcheckpoints[x .. "|" .. y] = true
				elseif obji == 31 then
					--prevent player from throwing seeds up, fixes soft-locks in level 3 with platforms
					noupthrowing[x] = true
				end
			end
		end
	end

	table.insert(obj["player"], Player:new(playerstartx*TILE, playerstarty*TILE))

	--spawn enemies on screen
	camera:focus(obj["player"][1].x, obj["player"][1].y, obj["player"][1].width, obj["player"][1].height)
	spawnonscreen()

	--map borders
	table.insert(obj["border"], Border:new(-TILE, 0, map.h*TILE, "left"))
	table.insert(obj["border"], Border:new(map.w*TILE, 0, map.h*TILE, "right"))
end

function spawn_enemy(x,y)
	if enemiesspawned[x .. "|" .. y] then
		return false
	end
	local tilei = map:get(x, y, 1)
	local forei = map:get(x, y, 2)
	local obji = map:get(x, y, 3)
	local text = map:get(x, y, 4)
	local spawned = false

	if obji == 2 then --seed
		table.insert(obj["seed"], Seed:new((x-1)*TILE, (y)*TILE, 1))
		spawned = true
	elseif obji == 3 then --tricerotops dino
		table.insert(obj["enemy"], Enemy:new((x-1)*TILE, (y)*TILE, "dino1"))
		spawned = true
	elseif obji == 7 then --jelly fish
		table.insert(obj["jelly"], Jelly:new((x-1)*TILE, (y)*TILE))
		spawned = true
	elseif obji == 8 then --bomb
		table.insert(obj["bomb"], Bomb:new((x-1)*TILE, (y)*TILE))
		spawned = true
	elseif obji == 16 then --bandit
		table.insert(obj["enemy"], Enemy:new((x-1)*TILE, (y)*TILE, "bandit"))
		spawned = true
	elseif obji == 17 then --piston up
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "up", tonumber(text), true))
		spawned = true
	elseif obji == 18 then --piston down
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "down", tonumber(text), true))
		spawned = true
	elseif obji == 19 then --piston right
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "right", tonumber(text), true))
		spawned = true
	elseif obji == 20 then --piston left
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "left", tonumber(text), true))
		spawned = true
	elseif obji == 21 then --piston down offset
		local len = tonumber(text) or 3
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y-len)*TILE, "piston", "down", tonumber(text), true))
		spawned = true
	elseif obji == 22 then --piston up retracted
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "up", tonumber(text), false))
		spawned = true
	elseif obji == 23 then --piston down retracted
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "down", tonumber(text), false))
		spawned = true
	elseif obji == 24 then --piston right retracted
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "right", tonumber(text), false))
		spawned = true
	elseif obji == 25 then --piston left retracted
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y)*TILE, "piston", "left", tonumber(text), false))
		spawned = true
	elseif obji == 26 then --piston down offset retracted
		local len = tonumber(text) or 3
		table.insert(obj["bush"], Bush:new((x-1)*TILE, (y-len)*TILE, "piston", "down", tonumber(text), false))
		spawned = true
	elseif obji == 27 then --piston right offset
		table.insert(obj["bush"], Bush:new((x-2)*TILE, (y-2)*TILE, "piston", "right", tonumber(text), true))
		spawned = true
	elseif obji == 28 then --piston left offset
		table.insert(obj["bush"], Bush:new((x)*TILE, (y-2)*TILE, "piston", "left", tonumber(text), true))
		spawned = true
	elseif obji == 29 then --piston right retracted offset
		table.insert(obj["bush"], Bush:new((x-2)*TILE, (y-2)*TILE, "piston", "right", tonumber(text), false))
		spawned = true
	elseif obji == 30 then --piston left retracted offset
		table.insert(obj["bush"], Bush:new((x)*TILE, (y-2)*TILE, "piston", "left", tonumber(text), false))
		spawned = true
	end
	if spawned then
		enemiesspawned[x .. "|" .. y] = true
	end
end

function spawnonscreen()
	if not leveledit then
		for x = math.floor(camera.x/TILE)+1, math.floor((camera.x+camera.w)/TILE)+1 do
			for y = math.floor(camera.y/TILE)+1, math.floor((camera.y+camera.h)/TILE)+1 do
				if map:get(x, y, 2) then
					spawn_enemy(x, y)
				end
			end
		end
	end
end

function game.keypressed(k)
	if k == "escape" and leveleditreturn then
		--return to level editor
		local x, y, cx, cy = obj["player"][1].x, obj["player"][1].y, camera.x, camera.y
		leveledit = true
		game.load(LEVEL)
		if leveleditreturn == "fast" then
			obj["player"][1].x = x
			obj["player"][1].y = y
			camera:move(cx, cy)
		end
		leveleditreturn = false
		return false
	elseif k == "escape" and not leveledit then
		game.transitionout("lose")
		playSound("select")
		return false
	end
	if leveledit then
		editor.keypressed(k)
	end

	if (k == controls["timeleft"] or k == controls["timeright"] or k == controls["timetoggle"]) and obj["player"][1].controlsenabled then
		timekeeperpopup = true
		timekeeperpopuptimerreached = false
	end

	if love.keyboard.isDown(controls["timetoggle"]) then
		return false
	end

	for i, obj in pairs(obj["player"]) do
		obj:keypressed(k)
	end
end

function game.keyreleased(k)
	for i, obj in pairs(obj["player"]) do
		obj:keyreleased(k)
	end
	if leveledit then
		editor.keyreleased(k)
	end
	if (leveledit or leveleditreturn) and k == "f10" then
		PHYSICSDEBUG = not PHYSICSDEBUG
	end
end

function game.mousepressed(x, y, b)
	if leveledit then
		editor.mousepressed(x, y, b)
	end
end

function game.mousereleased(x, y, b)
	if leveledit then
		editor.mousereleased(x, y, b)
	end
end

function game.wheelmoved(dx, dy)
	if leveledit then
		editor.wheelmoved(dx, dy)
	end
end

function makepoof(x, y, i, r)
	local t = {
		timer = 0,
		delay = 0.06,
		frame = 1,
		x = x,
		y = y,
		r = r or 0}
	if i == "boom" then
		t.frames = {5,6,7,8}
	elseif i == "pound" then
		t.frames = {9,10,11,12}
	else
		t.frames = {1,2,3,4}
	end

	table.insert(poofs, t)
end

function drawtime(image, quad, x, y, r, sx, sy, ox, oy)
	--draws a set of three quads based on time period
	if timeperiodtransition then
		love.graphics.setColor(1,1,1,1)
		love.graphics.draw(image, quad[timeperiodtransition[3]], x, y, r, sx, sy, ox, oy)
		love.graphics.setColor(1,1,1,1-(timeperiodtransition[1]/TIMEPERIODTRANSITIONTIME))
		love.graphics.draw(image, quad[timeperiod], x, y, r, sx, sy, ox, oy)
	else
		love.graphics.draw(image, quad[timeperiod], x, y, r, sx, sy, ox, oy)
	end
end

function game.transitionout(t)
	if t == "startwin" then
		wintransitionouttimer = LEVEL_wintime
	else
		transitionouttarget = t
		transitionout = transitionouttime
	end
end