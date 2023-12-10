Tile = class("Tile")

function Tile:initialize(x, y, i)
	self.x = (x-1)*TILE
	self.y = (y-1)*TILE
	self.tx = x
	self.ty = y
	self.w = TILE
	self.h = TILE
	self.i = i or 1

	self.category = 1
	self.mask = {false, false}

	self.active = true
	self.static = true
end

function Tile:update(dt)

end

function Tile:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

function Tile:collide(side, a, b)

end

function Tile:hit()
	if true then
		self:destroy()
	end
end

function Tile:destroy()
	map:set(self.tx, self.ty, 0, 1)
	self.delete = true
end
