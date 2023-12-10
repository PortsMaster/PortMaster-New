Border = class("Border")
--screen border so things don't fall off

function Border:initialize(x, y, h, side)
	self.x = x
	self.y = y
	self.w = TILE
	self.h = h or TILE
	self.side = side
	self.category = 1
	self.mask = {false}

	self.active = true
	self.static = true
end