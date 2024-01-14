worldmap = {}

--transition effects
local transitionin = false
local transitionintime = 0.4
local transitionout = false
local transitionouttime = 0.3

local levelselection = 1
local levels = 4

local markerspeed = 5
local markeroffset = 0 -- -1 to 1

local fliptimer = 0

function worldmap.load()
	transitionin = transitionintime

	if levelselection > levelscompleted+1 then
		levelselection = levelscompleted+1
	end
end

function worldmap.update(dt)
	--transitions
	if transitionin then
		transitionin = transitionin - dt
		if transitionin < 0 then
			transitionin = false
		end
	elseif transitionout then
		transitionout = transitionout - dt
		if transitionout < 0 then
			setgamestate("game", {levelselection})
			transitionout = false
		end
	end

	--marker
	if markeroffset ~= 0 then
		if markeroffset < 0 then
			markeroffset = markeroffset + markerspeed*dt
			if markeroffset >= 0 then
				markeroffset = 0
			end
		else
			markeroffset = markeroffset - markerspeed*dt
			if markeroffset <= 0 then
				markeroffset = 0
			end
		end
	end

	fliptimer = (fliptimer + 1.8*dt)%1
end

function worldmap.draw()
	--world map
	love.graphics.setColor(1,1,1)
	love.graphics.draw(worldmapimg, 0, 0)

	--level marker
	love.graphics.setColor(1,1,1)
	for i = 1, levels do
		local q = 1
		if i <= levelscompleted+1 then
			q = 2
		end
		love.graphics.draw(levelmarkerimg, levelmarkerq[q], 38+75*(i-1), 130)
	end

	--marker
	local dirscale = 1
	if fliptimer > 0.5 then
		dirscale = -1
	end
	love.graphics.draw(playerimg, playerq[1][19], 48+75*(levelselection-1+markeroffset), 140, 0, dirscale, 1, 20, 40)

	--transitions
	if transitionin then
		love.graphics.setColor(0,0,0,transitionin/transitionintime)
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	elseif transitionout then
		love.graphics.setColor(0,0,0,1-(transitionout/transitionouttime))
		love.graphics.rectangle("fill",0,0,WINWIDTH,WINHEIGHT)
	end
end

function worldmap.keypressed(k)
	if transitionin or transitionout then
		return
	end
	if k == "escape" then
		setgamestate("menu")
		return
	end
	if markeroffset == 0 then
		if k == controls["left"] or k == "left" then
			if levelselection > 1 then
				markeroffset = 1
				playSound("press")
			end
			levelselection = math.max(1, levelselection - 1)
		elseif k == controls["right"] or k =="right" then
			if levelselection < levels and levelselection < levelscompleted+1 then
				markeroffset = -1
				playSound("press")
			end
			levelselection = math.min(math.min(levelscompleted+1, levels), levelselection + 1)
		elseif k == controls["action"] or k == controls["jump"] or k == "return" then
			transitionout = transitionouttime
			playSound("select")
		end
	end
end