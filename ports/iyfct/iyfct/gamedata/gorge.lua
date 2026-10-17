Gorge = {}
Gorge.__index = Gorge

gorge_quad = love.graphics.newQuad(208,0,128,8,512,512)

function Gorge.create()
	local self = {}
	setmetatable(self,Gorge)
	self.x = WIDTH+10
	self.alive = true
	return self
end

function Gorge:update(dt)
	if self.alive == false then return end

	self.x = self.x - global_speed * dt * TRACK_SPEED

	if self.x < -130 then
		self.alive = false
	end
end

function Gorge:draw()
	love.graphics.draw(imgTerrain,gorge_quad,self.x-7,92)
end
