Car = class("Car")

function Car:initialize(x, y, dir)
	self.w = CAR_width
	self.h = CAR_height
	self.x = x
	self.y = y-self.h

	self.dir = dir or "right"

	self.spawnx = self.x
	self.spawny = self.y

	--physics
	self.category = 3
	self.mask = {true, true, true, true, true}

	self.active = true
	self.static = false

	self.sx = 0
	self.sy = 0
end

function Car:update(dt)
	self.ground = (self.sy == 0)
	if self.ground then
		--ground friction
		if self.sx > 0 then
			self.sx = math.max(0, self.sx - FRICTION*dt)
		elseif self.sx < 0 then
			self.sx = math.min(0, self.sx + FRICTION*dt)
		end
	end
end

function Car:draw()
	if not self.active then
		return
	end
	love.graphics.setColor(1,1,1)
	local sx = 1
	if self.dir == "left" then
		sx = -1
	end
	drawtime(carimg, {carq[1][1], carq[2][1], carq[3][1]}, math.floor(self.x+self.w/2), math.floor(self.y+self.h+1), 0, sx, 1, 32, 40)
end

function Car:collide(side, a, b)
	return true
end

function Car:ride(ride, b)
	if ride then
		self.active = false
	else
		self.active = true
		self.x = b.x
		self.y = (b.y+b.h)-self.h
		self.dir = b.dir
	end
end

function Car:respawn()
	makepoof(self.x+self.w/2, self.y+self.h/2)
	self.x = self.spawnx
	self.y = self.spawny
	makepoof(self.x+self.w/2, self.y+self.h/2)
	self.dir = "right"
end