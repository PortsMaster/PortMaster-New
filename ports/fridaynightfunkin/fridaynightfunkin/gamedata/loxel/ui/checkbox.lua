---@class Checkbox:Object
local Checkbox = Object:extend("Checkbox")

function Checkbox:new(x, y, size, callback)
	Checkbox.super.new(self, x, y)

	self.size = size or 20

	self.checked = false
	self.hovered = false
	self.callback = callback

	self.color = {0.2, 0.2, 0.2}
	self.lineColor = Color.WHITE
	self.lineColorHovered = {0.8, 0.8, 0.8}
	self.checkColor = Color.WHITE

	self.lineSize = 0.5
	self.round = {4, 4}
end

function Checkbox:update(dt)
	Checkbox.super.update(self, dt)

	local mx, my = game.mouse.x, game.mouse.y
	self.hovered =
		(mx >= self.x and mx <= self.x + self.size and my >= self.y and my <=
			self.y + self.size)

	if self.hovered and game.mouse.justReleased then
		self.checked = not self.checked
		if self.callback then self.callback() end
	end
end

function Checkbox:__render()
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.size, self.size,
		self.round[1], self.round[2])

	love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
	love.graphics.rectangle("fill", self.x, self.y + self.size / 2, self.size,
		self.size / 2, self.round[1], self.round[2])

	if self.hovered then
		local color = {0, 0, 0, 0.1 / self.alpha}
		if game.mouse.pressed then
			color = {1, 1, 1, 0.1 / self.alpha}
		end
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle("fill", self.x, self.y, self.size, self.size,
			self.round[1], self.round[2])

		love.graphics.setColor(self.lineColorHovered[1], self.lineColorHovered[2],
			self.lineColorHovered[3], self.alpha)
	else
		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
	end

	if self.lineSize > 0 then
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.rectangle("line", self.x, self.y, self.size, self.size,
			self.round[1], self.round[2])
		love.graphics.setLineWidth(lineWidth)
	end

	if self.checked then
		love.graphics.push()

		local checkX = self.x + self.size / 2
		local checkY = self.y + self.size / 2

		love.graphics.translate(checkX, checkY)
		love.graphics.setColor(self.checkColor[1], self.checkColor[2],
			self.checkColor[3], self.alpha)

		local logo_position = {(-self.size) * 0.3, (-self.size) * -0.3}

		love.graphics.rotate(math.rad(45))
		love.graphics.rectangle("fill", logo_position[1], logo_position[2],
			(self.size * 0.5), (self.size * 0.2))
		love.graphics.rectangle("fill", 0, logo_position[2] * -2,
			(self.size * 0.2), (self.size * 1.1))

		love.graphics.pop()
	end

	love.graphics.setColor(r, g, b, a)
end

return Checkbox
