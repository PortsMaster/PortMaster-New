Train = {}
Train.__index = Train

normal_train_quad = love.graphics.newQuad(0,0,132,36,256,256)
open_train_quad = love.graphics.newQuad(0,48,146,36,256,256)
inside_train_quad = love.graphics.newQuad(0,96,146,36,256,256)

coffee_cup_quad = love.graphics.newQuad(96,0,26,23,128,128)

TRAIN_MIN_SPEED = 160
TRAIN_MAX_SPEED = 200

function Train.createRandom()
	if math.random(1,3) == 1 then
		return Train.create(2)
	else
		return Train.create(1)
	end
end

function Train.create(type)
	local self = {}
	setmetatable(self,Train)
	self.speed = math.random(TRAIN_MIN_SPEED,TRAIN_MAX_SPEED)
	self.x = WIDTH
	self.y = 56
	self.type = type
	self.alive = true
	self.hasCoffee = false
	if self.type == 2 then
		if math.random(2) == 1 then
			self.hasCoffee = true
		end
	end
	return self
end

function Train:update(dt)
	if self.alive == false then
		return
	end

	self.x = self.x - self.speed*dt*global_speed
	if self.x < -146 then
		self.alive = false
	end
end

function Train:draw()
	if self.alive == false then
		return
	end

	if self.type == 1 then -- closed train
		love.graphics.draw(imgTrains,normal_train_quad,self.x,self.y)
	elseif self.type == 2 then -- open train
		if pl.status == 3 then -- inside
			love.graphics.draw(imgTrains,inside_train_quad,self.x-7,self.y)
			if self.hasCoffee == true then
				love.graphics.draw(imgSprites,coffee_cup_quad,self.x+54,self.y+8)
			end
		else -- outside
			love.graphics.draw(imgTrains,open_train_quad,self.x-7,self.y)
		end
	end
end
