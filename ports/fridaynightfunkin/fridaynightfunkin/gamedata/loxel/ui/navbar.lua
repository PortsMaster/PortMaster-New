---@class Navbar:Object
local Navbar = Object:extend("Navbar")

function Navbar:new(list, position)
	Navbar.super.new(self)

	self.buttonList = {}
	self:setPosition(position)

	self.hovered = false

	self.color = {0.3, 0.3, 0.3}
	self.lineColor = Color.WHITE

	self.lineSize = 4

	for i, button in ipairs(list) do
		local btn = ui.UIButton(0, 0, 60, self.height, button[1], button[2])
		btn.lineSize = 0
		btn.round = {0, 0}
		table.insert(self.buttonList, btn)
	end
end

function Navbar:setPosition(position)
	self.position = position ~= nil and position:lower() or "top"
	if self.position == "bottom" then
		self.width = game.width
		self.height = 40
		self.x = 0
		self.y = game.height - self.height
	elseif self.position == "left" then
		self.width = 140
		self.height = game.height
		self.x = 0
		self.y = 0
	elseif self.position == "right" then
		self.width = 140
		self.height = game.height
		self.x = game.width - self.width
		self.y = 0
	else
		self.width = game.width
		self.height = 40
		self.x = 0
		self.y = 0
	end
end

function Navbar:update(dt)
	Navbar.super.update(self, dt)

	local mx, my = game.mouse.x, game.mouse.y
	self.hovered = (mx >= self.x and mx <= self.x + self.width and
		my >= self.y and my <= self.y + self.height)

	for i, btn in ipairs(self.buttonList) do
		btn.active = self.active
		btn:setPosition(self.x + ((i - 1) * 60), self.y)
		btn:update()
	end
end

function Navbar:__render()
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	love.graphics.setColor(self.lineColor[1], self.lineColor[2], self.lineColor[3],
		self.alpha)
	love.graphics.setLineWidth(self.lineSize)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	love.graphics.setLineWidth(lineWidth)

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	if self.position == "left" then
		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x, self.y, self.width / 2,
			self.height)
	elseif self.position == "right" then
		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x + self.width / 2, self.y, self.width / 2,
			self.height)
	else
		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x, self.y + self.height / 2, self.width,
			self.height / 2)
	end

	for i, btn in ipairs(self.buttonList) do
		btn:__render()
	end

	love.graphics.setColor(r, g, b, a)
end

return Navbar
