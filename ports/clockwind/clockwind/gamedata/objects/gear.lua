Gear = class("Gear")

function Gear:initialize(x, y, r, cc)
	--physics
	self.category = 9
	self.mask = {false, true, false, false, false, false, false, false, true}
	self.r = r*TILE --radius
	self.w = self.r*2
	self.h = self.r*2
	self.rx = x+TILE/2
	self.ry = y+TILE/2
	self.x = x+(TILE-self.w)/2
	self.y = y+(TILE-self.h)/2
	self.rotation = 0 --rotation
	self.cc = cc--counterclockwise

	self.active = true
	self.static = true

	self.sx = 0
	self.sy = 0

	self.initialupdate = true

	self.frame = 1
	self.animtimer = 0

	self.floattimer = 0
end

function Gear:update(dt)
	--slowly speed up and stop in future
	if timeperiod < 3 then
		self.rotation = (math.abs(self.rotation) + (GEAR_speedslow+((GEAR_speedfast-GEAR_speedslow)*(timep-1)))*dt)%(math.pi*2)
		if not self.cc then
			self.rotation = -self.rotation
		end
	end
end

function Gear:draw()
	drawgear(self.rx, self.ry, self.r, self.rotation)
end

function drawgear(x, y, r, a)
	love.graphics.setColor(193/255,127/255,89/255)
	local drawr = r-10
	love.graphics.circle("fill", math.floor(x), math.floor(y), drawr) --rawr xd
	
	love.graphics.setColor(1,1,1)
	local cogs = math.floor((math.pi*(drawr*2))/24)
	for i = 1, cogs do
		local rot = a+((math.pi*2)*((i-1)/(cogs)))
		love.graphics.draw(gearcogimg, x+math.sin(rot)*drawr, y+math.cos(rot)*drawr, -(rot+math.pi), 1, 1, 10, 19)
	end
	love.graphics.draw(gearholeimg, x, y, 0, 1, 1, 20, 20)
end

function Gear:collide(side, a, b)
	return true
end