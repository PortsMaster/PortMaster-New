intro = {}

local transitiontime = 1.1 --time it takes to transition
local transitionin = true
local transitionout = false
local timer = 0
local introtime = 3.8
local introskip = false
local alesanimg
local res = {WINWIDTH, WINHEIGHT}

function intro.load(s)
	--fade in
	transitionin = true
	timer = 0
	love.graphics.setBackgroundColor(0, 0, 0)

	alesanimg = love.graphics.newImage("graphics/alesan.png")
end

function intro.update(dt)
	timer = timer + dt
	if timer > introtime then
		setgamestate("menu")
		return
	end
	transitionin = (timer < transitiontime)
	transitionout = (timer > introtime-transitiontime)
end

function intro.draw()
	--background
	local a = 1
	if transitionin then
		a = timer/transitiontime
	elseif transitionout then
		a = -(timer-introtime)/transitiontime
	end
	love.graphics.setColor(1, 1, 1, a)
	love.graphics.draw(alesanimg, math.floor((res[1]-alesanimg:getWidth())/2), math.floor((res[2]-alesanimg:getHeight())/2))
end

function intro.skip()
	if transitionout then
		timer = introtime
	else
		timer = math.max(introtime-transitiontime, introtime-timer)
	end
	introskip = true
end

function intro.keypressed(k)
	if not introskip then
		intro.skip()
	end
end

function intro.mousepressed(x, y, b)
	if not introskip then
		intro.skip()
	end
end

function intro.mousereleased(x, y, b)
end