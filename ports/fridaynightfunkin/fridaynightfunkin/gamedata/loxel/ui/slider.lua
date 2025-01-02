---@class Slider:Object
local Slider = Object:extend("Slider")

function Slider:new(x, y, width, height, value, snap, sliderType, min, max)
	Slider.super.new(self, x, y)

	self.width = width
	self.height = height

	self.value = value or 0
	self.min = min or 0
	self.max = max or 1
	self.snap = snap or nil

	self.dragging = false
	self.disabled = false
	self.onChanged = nil
	self.sliderType = (type(sliderType) == "string") and sliderType:lower()

	self.color = {0.2, 0.2, 0.2}
	self.lineColor = Color.WHITE
	self.knobColor = {0.4, 0.4, 0.4}

	self.lineSize = 0.5
	self.round = {4, 4}
end

function Slider:update()
	local mx, my = game.mouse.x, game.mouse.y
	if self.dragging then
		local newValue
		if self.sliderType == "vertical" then
			local relativeY = (game.mouse.y - self.width / 2) - self.y
			local clampedY = math.max(self.min, math.min(
				self.height - self.width, relativeY))
			newValue = self.min + (clampedY / (self.height - self.width)) *
				(self.max - self.min)
		else
			local relativeX = (game.mouse.x - self.height / 2) - self.x
			local clampedX = math.max(self.min, math.min(
				self.width - self.height, relativeX))
			newValue = self.min + (clampedX / (self.width - self.height)) *
				(self.max - self.min)
		end

		if self.snap then
			newValue =
				math.floor((newValue + self.snap * 0.5) / self.snap) * self.snap
			newValue = math.max(self.min, math.min(self.max, newValue))
		end

		if self.value ~= newValue then
			self.value = newValue
			if self.onChanged then self.onChanged(self.value) end
		end
	end

	if game.mouse.justPressedLeft then
		self.dragging = (mx >= self.x and mx <= self.x + self.width and my >=
			self.y and my <= self.y + self.height) and not self.disabled
	end
	if game.mouse.justReleasedLeft then
		self.dragging = false
	end
end

function Slider:__render()
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)

	if self.sliderType == "vertical" then
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
			self.round[1], self.round[2])

		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
				self.round[1], self.round[2])
			love.graphics.setLineWidth(lineWidth)
		end

		if self.snap then
			local stepCount = 0
			for i = self.min, self.max, self.snap do
				local snapY = self.y + (i - self.min) / (self.max - self.min) *
					(self.height - self.width) + self.width / 2 - 1
				local snapWidth = stepCount % 2 == 0 and 10 or 5
				local xOffset = stepCount % 2 == 0 and 5 or 2.5

				love.graphics.setColor(0, 0, 0, 0.5 / self.alpha)
				love.graphics.rectangle("fill", self.x - xOffset, snapY,
					self.width + snapWidth, 2)

				stepCount = (stepCount + 1) % 2
			end
		end

		local knobX = self.x - 5
		local knobY = self.y + (self.value - self.min) / (self.max - self.min) *
			(self.height - self.width)

		love.graphics.setColor(self.knobColor[1], self.knobColor[2],
			self.knobColor[3], self.alpha)
		love.graphics.rectangle("fill", knobX, knobY,
			self.width + 10, self.width, self.round[1], self.round[2])

		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", knobX, knobY +
			self.width / 2, self.width + 10, self.width / 2, self.round[1],
			self.round[2])

		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.rectangle("line", knobX, knobY,
				self.width + 10, self.width, self.round[1], self.round[2])
			love.graphics.setLineWidth(lineWidth)
		end
	else
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
			self.round[1], self.round[2])

		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
				self.round[1], self.round[2])
			love.graphics.setLineWidth(lineWidth)
		end

		if self.snap then
			local stepCount = 0
			for i = self.min, self.max, self.snap do
				local snapX = self.x + (i - self.min) / (self.max - self.min) *
					(self.width - self.height) + self.height / 2 - 1
				local snapHeight = stepCount % 2 == 0 and 10 or 5
				local yOffset = stepCount % 2 == 0 and 5 or 2.5

				love.graphics.setColor(0, 0, 0, 0.5 / self.alpha)
				love.graphics.rectangle("fill", snapX, self.y - yOffset,
					2, self.height + snapHeight)

				stepCount = (stepCount + 1) % 2
			end
		end

		local knobX = self.x + (self.value - self.min) / (self.max - self.min) *
			(self.width - self.height)
		local knobY = self.y - 5

		love.graphics.setColor(self.knobColor[1], self.knobColor[2],
			self.knobColor[3], self.alpha)
		love.graphics.rectangle("fill", knobX, knobY,
			self.height, self.height + 10, self.round[1], self.round[2])

		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", knobX, knobY + self.height / 2 + 5,
			self.height, self.height / 2 + 5, self.round[1], self.round[2])

		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.rectangle("line", knobX, knobY,
				self.height, self.height + 10, self.round[1], self.round[2])
			love.graphics.setLineWidth(lineWidth)
		end
	end

	love.graphics.setColor(r, g, b, a)
end

return Slider
