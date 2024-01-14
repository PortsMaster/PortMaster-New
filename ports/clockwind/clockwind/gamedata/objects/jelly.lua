Jelly = class("Jelly")

function Jelly:initialize(x, y)
	self.w = 20
	self.h = 20
	self.x = x+(TILE-self.w)/2
	self.y = y-self.h
	self.oy = self.y

	--physics
	self.category = 6
	self.mask = {false, true, true, true, true, true}

	self.active = true
	self.static = true

	self.sx = 0
	self.sy = 0

	self.initialupdate = true

	self.frame = 1
	self.animtimer = 0

	self.floattimer = 0
end

function Jelly:update(dt)
	--die in future
	if timetraveling or self.initialupdate then
		if waterlevel and ((self.y > waterlevel) or ((not waterlevel) and timeperiod <= 2)) then
			self.active = true
		else
			self.active = false
		end
		if self.initialupdate then
			self.initialupdate = false
		end
	end

	if self.active then
		self.floattimer = (self.floattimer + dt)%1
		self.y = self.oy - 3*math.sin(self.floattimer*math.pi*2)
	end

	self.animtimer = self.animtimer + dt
	while self.animtimer > JELLY_animdelay do
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
		self.animtimer = self.animtimer - JELLY_animdelay
	end
end

function Jelly:draw()
	love.graphics.setColor(1,1,1)
	--drawtime(jellyimg, {jellyq[1][self.frame], jellyq[2][self.frame], jellyq[3][self.frame]}, math.floor(self.x+7), math.floor(self.y+8), 0, 1, 1, 8, 8)
	if self.active then
		love.graphics.draw(jellyimg, jellyq[1][self.frame], math.floor(self.x+7), math.floor(self.y+8), 0, 1, 1, 8, 8)
	else
		love.graphics.draw(jellyimg, jellyq[3][self.frame], math.floor(self.x+7), math.floor(self.y+8), 0, 1, 1, 8, 8)
	end
end

function Jelly:collide(side, a, b)
	return true
end