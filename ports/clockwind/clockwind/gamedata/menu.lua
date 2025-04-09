menu = {}

--transition effects
local transitionin = false
local transitionintime = 0.4
local transitionout = false
local transitionouttime = 0.3
local menustate = "title"
local menutransition = false
local menutransitionfrom = false
local menutransitiontime = 0.2
local selectpulse = 0 --0-1

--mainmenu
local titlemenu = {"START", "SETTINGS"}
local titleselection

--settings
local targetscale
local targetvsync
local settingsselection = false
local settingsdir = false --left or right
local settingsanim = false
local settingsanimtime = 0.2
local settingsmenu
settingsmenu = {
	{"Volume: ", --name of setting
	draw = function() return math.floor(volume*100) .. "%" end, --display
	change = function(a) volume = math.floor(math.max(0, math.min(2, volume+(a*0.2)))*100)/100; love.audio.setVolume(volume) end, --change (a is -1 or 1)
	load = function() end,--load
	save = function() love.audio.setVolume(volume) end},--save
	{"Window: ",
	draw = function() return targetscale*WINWIDTH .. "x" .. targetscale*WINHEIGHT end,
	change = function(a) targetscale = math.max(1, math.min(6, targetscale+a)) end,
	load = function() targetscale = scale[1] end,
	save = function() if targetscale ~= scale[1] or targetvsync ~= vsync then vsync = targetvsync; setscale(targetscale) end end},
	{"Vsync: ",
	draw = function() if targetvsync then return "On" else return "Off" end end,
	change = function(a) targetvsync = not targetvsync end,
	load = function() targetvsync = vsync end,
	save = function() vsync = targetvsync end},
	{"Bind Controls",
	change = function() menu.setstate("controls") end},
	{"Reset Settings",
	change = function() 
		default_settings()
		for i, s in pairs(settingsmenu) do
			if s.save then
				s.save()
			end
		end
		save_settings()
		menu.setstate("settings")
	end,},
	{"Delete Save",
	change = function()
		delete_save()
	end},
	{"Apply",
	change = function()
		for i, s in pairs(settingsmenu) do
			if s.save then
				s.save()
			end
		end
		save_settings()
		menu.setstate("title")
	end,}
}

--control binding
local controlsbinding = false
local controlsblink = 0 --0-1
local controlsselection = 1
local controlsmenu = {
	{"Left: ", --name of setting
	draw = function() return controls["left"] end, --display
	change = function(a) controls["left"] = a end}, --change (key)
	{"Right: ",
	draw = function() return controls["right"] end,
	change = function(a) controls["right"] = a end},
	{"Up: ",
	draw = function() return controls["up"] end,
	change = function(a) controls["up"] = a end},
	{"Down: ",
	draw = function() return controls["down"] end,
	change = function(a) controls["down"] = a end},
	{"Jump: ",
	draw = function() return controls["jump"] end,
	change = function(a) controls["jump"] = a end},
	{"Action: ",
	draw = function() return controls["action"] end,
	change = function(a) controls["action"] = a end},
	{"Time Travel Left: ",
	draw = function() return controls["timeleft"] end,
	change = function(a) controls["timeleft"] = a end},
	{"Time Travel Right: ",
	draw = function() return controls["timeright"] end,
	change = function(a) controls["timeright"] = a end},
	{"Time Toggle (optional): ",
	draw = function() return controls["timetoggle"] end,
	change = function(a) controls["timetoggle"] = a end},
	{"Apply",
	change = function() menu.setstate("settings") end,}
}

local gearrot = 0

function menu.load(state)
	love.graphics.setBackgroundColor(51/255, 26/255, 25/255)
	titleselection = 1
	menu.setstate(state or "title")

	transitionin = transitionintime
end

function menu.update(dt)
	--transitions
	if transitionin then
		transitionin = transitionin - dt
		if transitionin < 0 then
			transitionin = false
		end
	elseif transitionout then
		transitionout = transitionout - dt
		if transitionout < 0 then
			if menustate == "title" then
				if titleselection == 1 then
					setgamestate("worldmap")
				end
			end
			transitionout = false
		end
	end

	gearrot = (gearrot+0.5*dt)%(math.pi*2)

	--misc animation
	selectpulse = (selectpulse+1.6*dt)%1
	if controlsbinding then
		controlsblink = (controlsblink+dt)%1
	end
end

function menu.draw()
	love.graphics.setColor(1,1,1)
	drawgear(10, 30, 70, gearrot)
	drawgear(298, 120, 50, -gearrot)
	if menustate == "title" then
		--title screen
		love.graphics.setColor(1,1,1)
		love.graphics.draw(titleimg, 57, 20)
		for i, s in pairs(titlemenu) do
			local name = s
			if i == titleselection then
				love.graphics.setColor(0,0,0,0.5)
				love.graphics.rectangle("fill", math.floor((WINWIDTH-90)/2), 122+21*(i-1), 90, 20, 10, 10, 5)
				local v = (0.4*math.sin(selectpulse*math.pi*2))
				love.graphics.setColor(1-v,1-v,1-v,1)
			else
				love.graphics.setColor(1,1,1,1)
			end
			love.graphics.print(name, math.floor((WINWIDTH-font:getWidth(name))/2), 126+21*(i-1))
		end
	elseif menustate == "settings" then
		--format the list of settings
		for i, s in pairs(settingsmenu) do
			local name = s[1]
			local selcolor = {1,1,1,1}
			if i == settingsselection then
				love.graphics.setColor(0,0,0,0.5)
				love.graphics.rectangle("fill", (WINWIDTH-190)/2, 17+21*(settingsselection-1), 190, 20, 10, 10, 5)
				local v = (0.4*math.sin(selectpulse*math.pi*2))
				selcolor = {1-v,1-v,1-v,1}
			end
			if s.draw then
				love.graphics.setColor(1,1,1,1)
				love.graphics.printf({selcolor, name, {1,1,1,1}, "< ", selcolor, s.draw(), {1,1,1,1}, " >"}, 0, 21+21*(i-1), WINWIDTH, "center")
			else
				love.graphics.setColor(selcolor)
				love.graphics.printf(name, 0, 21+21*(i-1), WINWIDTH, "center")
			end
		end
	elseif menustate == "controls" then
		--format the list of controls
		for i, s in pairs(controlsmenu) do
			local name = s[1]
			local selcolor = {1,1,1,1}
			if i == controlsselection then
				if controlsbinding then
					love.graphics.setColor(0,0,0,0.5)
					love.graphics.rectangle("fill", (WINWIDTH-200)/2, 8+16*(controlsselection-1), 200, 18, 10, 10, 5)
					local v = (0.4*math.sin(selectpulse*math.pi*2))
					selcolor = {1-v,1-v,1-v,1}
				else
					love.graphics.setColor(0,0,0,0.5)
					love.graphics.rectangle("fill", (WINWIDTH-200)/2, 8+16*(controlsselection-1), 200, 18, 10, 10, 5)
					local v = (0.4*math.sin(selectpulse*math.pi*2))
					selcolor = {1-v,1-v,1-v,1}
				end
			end
			if s.draw then
				if i == controlsselection and controlsbinding then
					--binding key
					local blinkingunderscore = {1,1,1,1}
					if controlsblink > 0.5 then
						blinkingunderscore = {1,1,1,0}
					end
					love.graphics.setColor(1,1,1,1)
					love.graphics.printf({{1,1,1,1}, name, blinkingunderscore, "_"}, 0, 11+16*(i-1), WINWIDTH, "center")
				else
					love.graphics.setColor(1,1,1,1)
					love.graphics.printf({selcolor, name, selcolor, s.draw()}, 0, 11+16*(i-1), WINWIDTH, "center")
				end
			else
				love.graphics.setColor(selcolor)
				love.graphics.printf(name, 0, 11+16*(i-1), WINWIDTH, "center")
			end
		end
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

function menu.keypressed(k)
	if transitionin or transitionout then
		return
	end
	if menustate == "title" then
		if k == controls["up"] or k == "up" then
			titleselection = math.max(1, titleselection - 1)
			selectpulse = 0
			playSound("press")
		elseif k == controls["down"] or k == "down" then
			titleselection = math.min(2, titleselection + 1)
			selectpulse = 0
			playSound("press")
		elseif k == controls["jump"] or k == controls["action"] or k == "space" or k == "return" then
			if titleselection == 1 then
				transitionout = transitionouttime
			elseif titleselection == 2 then
				menu.setstate("settings")
			end
			playSound("select")
		elseif k == "escape" then
			love.event.quit()
		end
	elseif menustate == "settings" then
		if k == controls["up"] or k == "up" then
			settingsselection = settingsselection - 1
			if settingsselection < 1 then
				settingsselection = #settingsmenu
			end
			selectpulse = 0
			playSound("press")
		elseif k == controls["down"] or k == "down" then
			settingsselection = settingsselection + 1
			if settingsselection > #settingsmenu then
				settingsselection = 1
			end
			selectpulse = 0
			playSound("press")
		elseif k == controls["left"] or k == "left" then
			settingsmenu[settingsselection].change(-1)
			playSound("press")
		elseif k == controls["right"] or k == "right" then
			settingsmenu[settingsselection].change(1)
			playSound("press")
		elseif k == controls["jump"] or k == controls["action"] or k == "space" or k == "return" then
			settingsmenu[settingsselection].change(1)
			playSound("select")
		end
	elseif menustate == "controls" then
		if controlsbinding then
			controlsmenu[controlsselection].change(k)
			controlsbinding = false
			playSound("press")
			return
		end
		if k == controls["up"] or k == "up" then
			controlsselection = controlsselection - 1
			if controlsselection < 1 then
				controlsselection = #controlsmenu
			end
			selectpulse = 0
			playSound("press")
		elseif k == controls["down"] or k == "down" then
			controlsselection = controlsselection + 1
			if controlsselection > #controlsmenu then
				controlsselection = 1
			end
			selectpulse = 0
			playSound("press")
		elseif k == controls["jump"] or k == controls["action"] or k == "space" or k == "return" then
			if controlsmenu[controlsselection].draw then --control bindable
				controlsbinding = true
				controlsblink = 0
			else
				controlsmenu[controlsselection].change()
			end
			playSound("select")
		end
	end
end

function menu.setstate(state)
	if menustate == "settings" then
	end
	menustate = state
	if state == "settings" then
		settingsselection = 1
		for i, s in pairs(settingsmenu) do
			if s.load then
				s.load()
			end
		end
	elseif state == "controls" then
		controlsselection = 1
	end
end