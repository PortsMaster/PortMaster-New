---@class Dropdown:Object
local Dropdown = Object:extend("Dropdown")

function Dropdown:new(x, y, options)
	Dropdown.super.new(self, x, y)

	self.width = 90
	self.height = 20

	self.font = font or love.graphics.newFont(12)
	self.font:setFilter("nearest", "nearest")

	self.options = options
	self.selectedOption = 1
	self.selectedLabel = self.options[1]

	self.hovered = false
	self.disabled = false
	self.isOpen = false
	self.onChanged = nil

	self.color = {0.2, 0.2, 0.2}
	self.lineColor = Color.WHITE
	self.textColor = Color.WHITE
	self.hoverColor = Color.WHITE

	self.__canScroll = false
	self.__curScroll = 0
	self.__maxShow = 10

	self.lineSize = 0.5
	self.round = {4, 4}

	self.__openButton = ui.UIButton(0, 0, self.height, self.height, "",
		function() self.isOpen = not self.isOpen end)
	self.__slider = ui.UISlider(0, 0, self.height - 8, self.height * 10, 0,
		nil, "vertical", 0, #self.options - self.__maxShow)
end

function Dropdown:update(dt)
	self.__canScroll = (#self.options > self.__maxShow and true or false)

	if game.mouse.wheel ~= 0 and self.__canScroll then
		self.__curScroll = self.__curScroll - game.mouse.wheel
		if self.__curScroll < 0 then
			self.__curScroll = 0
		elseif self.__curScroll > #self.options - self.__maxShow then
			self.__curScroll = #self.options - self.__maxShow
		end
		self.__slider.value = self.__curScroll
	end

	self.__openButton:update(dt)
	self.__slider:update()

	if game.mouse.justReleasedLeft then
		local optionClicked = self:isMouseOverOption(game.mouse.x, game.mouse.y)
		if self.isOpen and optionClicked then
			self:selectOption(optionClicked + self.__curScroll)
		end
	end
end

local function drawBoid(mode, x, y, length, width, angle)
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(math.rad(angle))
	love.graphics.polygon(mode, -length / 2, -width / 2, -length / 2, width / 2,
		length / 2, 0)
	love.graphics.pop()
end

function Dropdown:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()
	local ogScis_x, ogScis_y, ogScis_w, ogScis_h = love.graphics.getScissor()
	local mx, my = game.mouse.x, game.mouse.y

	if self.isOpen then
		local heightOption = #self.options
		if heightOption > self.__maxShow then heightOption = self.__maxShow end
		love.graphics.setColor(self.color[1], self.color[2],
			self.color[3], self.alpha)
		love.graphics.rectangle("fill", self.x, self.y, self.width,
			self.height * (heightOption + 1), self.round[1], self.round[2])

		for i, option in ipairs(self.options) do
			if i > self.__curScroll and i <= (self.__maxShow + self.__curScroll) then
				local fakeIndex = i - self.__curScroll
				local optionX = self.x
				local optionY = self.y + (self.height * fakeIndex)

				love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
				love.graphics.rectangle("fill", optionX, optionY + self.height / 2,
					self.width, self.height / 2, self.round[1],
					self.round[2])

				love.graphics.setColor(self.textColor[1], self.textColor[2],
					self.textColor[3], self.alpha)
				love.graphics.push()
				love.graphics.setScissor(optionX + 2, optionY, self.width - 7,
					self.height)
				love.graphics.print(option, optionX + 5, optionY +
					(self.height - self.font:getHeight()) /
					2)
				love.graphics.setScissor(ogScis_x, ogScis_y, ogScis_w, ogScis_h)
				love.graphics.pop()
				if mx >= optionX and mx < optionX + self.width and
					my >= optionY and my < optionY + self.height then
					love.graphics.setColor(self.hoverColor[1], self.hoverColor[2],
						self.hoverColor[3], 0.1 / self.alpha)
					love.graphics.rectangle("fill", optionX, optionY,
						self.width, self.height)
					love.graphics.setColor(self.textColor[1], self.textColor[2],
						self.textColor[3], self.alpha)
					love.graphics.push()
					love.graphics.setScissor(optionX + 2, optionY,
						self.width - 7, self.height)
					love.graphics.print(option, optionX + 5, optionY +
						(self.height - self.font:getHeight()) /
						2)
					love.graphics.setScissor(ogScis_x, ogScis_y, ogScis_w,
						ogScis_h)
					love.graphics.pop()
				end
			end
		end

		if self.lineSize > 0 then
			love.graphics.setColor(self.lineColor[1], self.lineColor[2],
				self.lineColor[3], self.alpha)
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.rectangle("line", self.x, self.y, self.width,
				self.height * (heightOption + 1), self.round[1], self.round[2])
			love.graphics.setLineWidth(lineWidth)
		end
	end

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.width + self.height,
		self.height, self.round[1], self.round[2])

	love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
	love.graphics.rectangle("fill", self.x, self.y + self.height / 2,
		self.width + self.height, self.height / 2, self.round[1],
		self.round[2])

	if self.lineSize > 0 then
		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.rectangle("line", self.x, self.y, self.width + self.height,
			self.height, self.round[1], self.round[2])
		love.graphics.setLineWidth(lineWidth)
	end

	love.graphics.setColor(self.textColor[1], self.textColor[2],
		self.textColor[3], self.alpha)
	love.graphics.push()
	love.graphics.setScissor(self.x + 2, self.y, self.width - 7, self.height)
	love.graphics.print(self.selectedLabel, self.x + 5,
		self.y + (self.height - self.font:getHeight()) / 2)
	love.graphics.setScissor(ogScis_x, ogScis_y, ogScis_w, ogScis_h)
	love.graphics.pop()

	if self.isOpen and #self.options > self.__maxShow then
		self.__slider.x = self.x + self.width + 4
		self.__slider.y = self.y + self.height
		self.__slider:__render(camera)
		self.__curScroll = math.floor(self.__slider.value)
	end

	self.__openButton.x = self.x + self.width
	self.__openButton.y = self.y
	self.__openButton:__render(camera)

	love.graphics.setColor(1, 1, 1)
	if self.isOpen then
		drawBoid("fill", self.__openButton.x + (self.__openButton.width * 0.49),
			self.__openButton.y + (self.__openButton.height * 0.49),
			self.__openButton.width * 0.4, self.__openButton.height * 0.6,
			-90)
	else
		drawBoid("fill", self.__openButton.x + (self.__openButton.width * 0.49),
			self.__openButton.y + (self.__openButton.height * 0.49),
			self.__openButton.width * 0.4, self.__openButton.height * 0.6,
			90)
	end

	love.graphics.setColor(r, g, b, a)
end

function Dropdown:selectOption(index)
	if index >= 1 and index <= #self.options then
		self.selectedLabel = self.options[index]
		self.selectedOption = index
		self.isOpen = false
		if self.onChanged then self.onChanged(self.selectedLabel) end
	end
end

function Dropdown:isMouseOverOption(mx, my)
	if self.isOpen and self.options then
		for i, _ in ipairs(self.options) do
			local optionX = self.x
			local optionY = self.y + (self.height * i)
			if mx >= optionX and mx < optionX + self.width and my >= optionY and
				my < optionY + self.height then
				return i
			end
		end
	end
end

return Dropdown
