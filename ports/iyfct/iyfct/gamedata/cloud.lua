MAX_CLOUDS = 32
Cloud = {}
Cloud.__index = Cloud

function Cloud.create(y,size,type)
	local self = {}
	setmetatable(self,Cloud)
	self.x = WIDTH
	self.y = y
	self.size = size
	self.speed = math.random(80,130)
	self.type = type
	self.alive = true
	return self
end

function Cloud:update(dt)
	-- self.x = self.x - dt*self.speed OLD way
	self.x = self.x - global_speed * dt * self.speed
end

function Cloud:draw()
	local quad = nil
	if self.size == 1 then
		quad = love.graphics.newQuad(self.type*16,32,16,16,128,128)
	elseif self.size == 2 then
		quad = love.graphics.newQuad(48+self.type*32,32,32,16,128,128)
	end
	if quad ~= nil then
		love.graphics.draw(imgSprites,quad,self.x,self.y)
	end
end

function spawnClouds(dt)
	next_cloud = next_cloud - dt
	if next_cloud <= 0 then
		if #clouds < MAX_CLOUDS then
			if math.random(2) == 1 then -- small cloud
				table.insert(clouds,Cloud.create(math.random(32),1,math.random(0,2)))
			else -- large cloud
				table.insert(clouds,Cloud.create(math.random(32),2,math.random(0,1)))
			end
		end
		next_cloud = math.random()
	end
end
