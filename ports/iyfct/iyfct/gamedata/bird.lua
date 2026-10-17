Bird = {}
Bird.__index = Bird

bird_frames = {}
bird_frames[0] = love.graphics.newQuad(0,64,11,8,128,128)
bird_frames[1] = love.graphics.newQuad(11,64,11,8,128,128)
bird_frames[2] = love.graphics.newQuad(22,64,11,8,128,128)
bird_frames[3] = love.graphics.newQuad(33,64,11,8,128,128)

function Bird.create()
	local self = {}
	setmetatable(self,Bird)
	self.x = WIDTH
	self.y = math.random(10,40)
	self.alive = true
	self.speed = math.random(180,210)
	self.frame = 0
	return self
end

function Bird:update(dt)
	self.x = self.x - dt * self.speed * global_speed
	self.frame = (self.frame + 10*dt) % 4
	if self.x < -12 then
		self.alive = false
	end
end

function Bird:draw()
	love.graphics.draw(imgSprites,bird_frames[math.floor(self.frame)],self.x,self.y)
end

function spawnBirds(dt)
	next_bird = next_bird - dt
	if next_bird <= 0 then
		if train.type ~= 1 and train.x < 200 and gorge.x < 100 then
			table.insert(birds,Bird.create())
		end
		next_bird = math.random()/2
	end
end
