local cursortrail = {}

function cursortrail:new(x, y)
	local p = {}
	self.__index = self
	p.x = x
	p.y = y
	p.size = 15
	p.alpha = 1
	return setmetatable(p, cursortrail)
end

function cursortrail:update(dt)
	self.size = self.size - 7 * dt
	self.alpha = self.alpha - 13 * dt
end

function cursortrail:draw()
	love.graphics.setColor(42 / 255, 49 / 255, 61 / 255, self.alpha)
	love.graphics.circle('fill', self.x, self.y, self.size)
end

return cursortrail
