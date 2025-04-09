---@class Button:Object
local Button = Object:extend("Button")

function Button:new(x, y, width, height, text, callback)
	Button.super.new(self, x, y)

	self.width = width or 80
	self.height = height or 20

	self.text = text or "Button"
	self.font = love.graphics.newFont(12)
	self.font:setFilter("nearest", "nearest")

	self.hovered = false
	self.callback = callback
	self.disabled = false

	self.color = {0.3, 0.3, 0.3}
	self.lineColor = Color.WHITE
	self.lineColorHovered = {0.8, 0.8, 0.8}
	self.textColor = Color.WHITE

	self.lineSize = 0.5
	self.round = {4, 4}
end

function Button:update(dt)
	Button.super.update(self, dt)

	local mx, my = game.mouse.x, game.mouse.y
	self.hovered = (mx >= self.x and mx < self.x + self.width and
		my >= self.y and my < self.y + self.height)

	if not self.disabled and self.hovered and game.mouse.justReleased then
		if self.callback then self.callback() end
	end
end

function Button:__render()
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
		self.round[1], self.round[2])

	love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
	love.graphics.rectangle("fill", self.x, self.y + self.height / 2, self.width,
		self.height / 2, self.round[1], self.round[2])

	if not self.disabled and self.hovered then
		local color = {0, 0, 0, 0.1 / self.alpha}
		if game.mouse.pressed then
			color = {1, 1, 1, 0.1 / self.alpha}
		end
		love.graphics.setColor(unpack(color))
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
			self.round[1], self.round[2])
	end

	if self.lineSize > 0 then
		if not self.disabled and self.hovered then
			love.graphics.setColor(self.lineColorHovered[1],
				self.lineColorHovered[2], self.lineColorHovered[3], self.alpha)
		else
			love.graphics.setColor(self.lineColor[1], self.lineColor[2],
				self.lineColor[3], self.alpha)
		end
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
			self.round[1], self.round[2])
		love.graphics.setLineWidth(lineWidth)
	end

	local textX = self.x
	local textY = self.y + (self.height - self.font:getHeight()) / 2

	love.graphics.setColor(self.textColor[1], self.textColor[2],
		self.textColor[3], self.alpha)
	love.graphics.printf(self.text, self.font, textX, textY, self.width, "center")

	love.graphics.setColor(r, g, b, a)
end

return Button
