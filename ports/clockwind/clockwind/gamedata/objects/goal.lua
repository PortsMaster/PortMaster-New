Goal = class("Goal")

function Goal:initialize(x, y)
	self.w = GOAL_width
	self.h = GOAL_height
	self.x = (x+TILE/2)-self.w/2
	self.y = y-self.h

	self.category = 8
	self.mask = {false, true, true, false, false, false, false, false, false}

	self.active = true
	self.static = true

	self.sx = 0
	self.sy = 0

	self.collected = false
	self.frame = 1
	self.floattimer = 0
	self.animtimer = 0

	self.speed = 0
	self.ightimmaheadout = false
end

function Goal:update(dt)
	if self.ightimmaheadout then
		self.speed = self.speed + 340*dt
		if self.y > -40 then
			self.y = self.y - self.speed*dt
		end
	else
		if self.collected then
			self:updatepos()
		end
		self.floattimer = (self.floattimer + dt)%1
	end
	self.animtimer = self.animtimer + dt
	while self.animtimer > GOAL_animdelay do
		self.frame = self.frame + 1
		if self.frame > 2 then
			self.frame = 1
		end
		self.animtimer = self.animtimer - GOAL_animdelay
	end
end

function Goal:draw()
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(goalimg, goalq[self.frame], self.x+self.w/2, self.y+self.h/2-8-3*math.sin(self.floattimer*math.pi*2), 0, 1, 1, 20, 20)
end

function Goal:collide(side, a, b)
	if self.collected then
		return false
	end
	if a == "player" then
		self:collect(b)
		return false
	end
end

function Goal:collect(b)
	self.collected = true
	self.master = b
	b:win()
	playSound("gear")
end

function Goal:updatepos()
	self.x = (self.master.x+self.master.w/2)-self.w/2
	self.y = self.master.y-self.h-8
end

function Goal:headout()
	self.ightimmaheadout = true
end