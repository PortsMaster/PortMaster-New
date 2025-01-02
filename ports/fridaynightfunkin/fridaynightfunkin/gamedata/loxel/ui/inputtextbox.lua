---@class InputTextBox:Object
local InputTextBox = Object:extend("InputTextBox")

local RemoveType = {NONE = 0, DELETE = 1, BACKSPACE = 2}
local CursorDirection = {NONE = 0, LEFT = 1, RIGHT = 2}

function InputTextBox:new(x, y, width, height, font)
	InputTextBox.super.new(self, x, y)

	self.width = width or 100
	self.height = height or 20

	self.font = font or love.graphics.newFont(12)
	self.font:setFilter("nearest", "nearest")

	self.text = ""
	self.hovered = false
	self.onChanged = nil
	self.clearOnPressed = false
	self.focused = false

	self.color = {0.2, 0.2, 0.2}
	self.lineColor = Color.WHITE
	self.textColor = Color.WHITE
	self.cursorColor = Color.WHITE

	self.lineSize = 0.5
	self.round = {4, 4}

	-- cursor
	self.__cursorPos = 0
	self.__cursorBlinkTime = 0.5
	self.__cursorBlinkTimer = 0
	self.__cursorVisible = false
	self.__cursorMove = false
	self.__cursorMoveTime = 0.5
	self.__cursorMoveTimer = 0
	self.__cursorMoveDir = CursorDirection.NONE

	-- remove text
	self.__removeTime = 0.5
	self.__removeTimer = 0
	self.__removePressed = false
	self.__removeType = RemoveType.NONE

	-- insert text
	self.__insertTime = 0.5
	self.__insertTimer = 0
	self.__insertPressed = false
	self.__lastInput = nil

	-- scrolling text
	self.__scrollTextX = 0
	self.__prevTextWidth = self.font:getWidth(self.text)
	self.__newTextWidth = self.__prevTextWidth
end

function InputTextBox:__render()
	local r, g, b, a = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	love.graphics.setColor(self.color[1], self.color[2], self.color[3],
		self.alpha)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height,
		self.round[1], self.round[2])

	love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
	love.graphics.rectangle("fill", self.x, self.y + self.height / 2, self.width,
		self.height / 2, self.round[1], self.round[2])

	love.graphics.push()
	love.graphics.translate(self.x + 5, self.y)
	love.graphics.setScissor(self.x, self.y, self.width - 10, self.height)

	love.graphics.setColor(self.textColor[1], self.textColor[2],
		self.textColor[3], self.alpha)
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, -self.__scrollTextX,
		(self.height - self.font:getHeight()) / 2)
	love.graphics.pop()
	love.graphics.setScissor()

	if self.focused then
		love.graphics.setColor(self.cursorColor[1], self.cursorColor[2],
			self.cursorColor[3], self.alpha)
		love.graphics.rectangle("fill", self.x - self.__scrollTextX + 5 +
			self.font:getWidth(
				self.text:sub(1, self.__cursorPos)),
			self.y + 3, 1, self.height - 6)
	end

	if self.lineSize > 0 then
		love.graphics.setColor(self.lineColor[1], self.lineColor[2],
			self.lineColor[3], self.alpha)
		love.graphics.setLineWidth(self.lineSize)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height,
			self.round[1], self.round[2])
		love.graphics.setLineWidth(lineWidth)
	end

	love.graphics.setColor(r, g, b, a)
end

function InputTextBox:update(dt)
	InputTextBox.super.update(self, dt)

	local mx, my = game.mouse.x, game.mouse.y
	self.hovered =
		(mx >= self.x and mx <= self.x + self.width and my >= self.y and my <=
			self.y + self.height)
	if game.mouse.justPressedLeft then
		if self.hovered then
			self.focused = true
			self.__cursorVisible = true

			if self.clearOnPressed then
				self.text = ''
				self.__cursorPos = 0
			end

			self.__cursorPos = utf8.len(self.text)
		else
			self.focused = false
			self.__cursorVisible = false
		end
	end

	if self.focused and game.keys.justPressed.ANY then
		if not self.__removePressed then
			for key in pairs(game.keys.input.justPressed) do
				self.__insertPressed = true
				self.__lastInput = key
				local newText =
					self.text:sub(1, self.__cursorPos) .. key ..
					self.text:sub(self.__cursorPos + 1)
				self.text = newText

				self.__cursorPos = self.__cursorPos + utf8.len(key)
				if self.onChanged then self.onChanged(self.text) end
			end
		end

		if game.keys.justPressed.BACKSPACE then
			if self.__cursorPos > 0 then
				local byteoffset = utf8.offset(self.text, -1,
					self.__cursorPos + 1)
				if byteoffset then
					self.text = string.sub(self.text, 1, byteoffset - 1) ..
						string.sub(self.text, byteoffset + 1)
					self.__cursorPos = self.__cursorPos - 1
				end
			end
			self.__removePressed = true
			self.__removeType = RemoveType.BACKSPACE

			self.__newTextWidth = self.font:getWidth(self.text)
			if self.__newTextWidth > self.__prevTextWidth then
				self.__scrollTextX = math.max(
					self.__scrollTextX -
					(self.__newTextWidth -
						self.__prevTextWidth), 0)
			elseif self.__newTextWidth < self.__prevTextWidth and
				self.__scrollTextX > 0 then
				self.__scrollTextX = math.min(
					self.__scrollTextX +
					(self.__prevTextWidth -
						self.__newTextWidth),
					self.__prevTextWidth -
					(self.width - 10))
			end
			if self.onChanged then self.onChanged(self.text) end
		elseif game.keys.justPressed.DELETE then
			if self.__cursorPos < utf8.len(self.text) then
				local byteoffset = utf8.offset(self.text, 1,
					self.__cursorPos + 1)
				if byteoffset then
					self.text = string.sub(self.text, 1, byteoffset - 1) ..
						string.sub(self.text, byteoffset + 1)
				end
			end
			self.__removePressed = true
			self.__removeType = RemoveType.DELETE
			if self.onChanged then self.onChanged(self.text) end
		elseif game.keys.justPressed.LEFT then
			if self.__cursorPos > 0 then
				self.__cursorPos = self.__cursorPos - 1
			end
			self.__cursorMove = true
			self.__cursorMoveDir = CursorDirection.LEFT
		elseif game.keys.justPressed.RIGHT then
			if self.__cursorPos < utf8.len(self.text) then
				self.__cursorPos = self.__cursorPos + 1
			end
			self.__cursorMove = true
			self.__cursorMoveDir = CursorDirection.RIGHT
		end
	end

	if self.focused and game.keys.justReleased.ANY then
		self.__insertPressed = false
		self.__insertTimer = 0

		if game.keys.justReleased.BACKSPACE or game.keys.justReleased.DELETE then
			self.__removePressed = false
			self.__removeTimer = 0
			self.__removeType = RemoveType.NONE
		end
		if game.keys.justReleased.LEFT or game.keys.justReleased.RIGHT then
			self.__cursorMove = false
			self.__cursorMoveTimer = 0
			self.__cursorMoveDir = CursorDirection.NONE
		end
	end

	if self.focused then
		self.__prevTextWidth = self.font:getWidth(self.text)

		if self.__insertPressed then
			self.__insertTimer = self.__insertTimer + dt
			if self.__insertTimer >= self.__insertTime then
				local newText =
					self.text:sub(1, self.__cursorPos) .. self.__lastInput ..
					self.text:sub(self.__cursorPos + 1)
				self.text = newText
				self.__cursorPos = self.__cursorPos + utf8.len(self.__lastInput)
				if self.onChanged then self.onChanged(self.text) end
				self.__insertTimer = self.__insertTime - 0.02
			end
		end

		if self.__cursorMove then
			self.__cursorMoveTimer = self.__cursorMoveTimer + dt
			if self.__cursorMoveTimer >= self.__cursorBlinkTime then
				if self.__cursorMoveDir == CursorDirection.LEFT and
					self.__cursorPos > 0 then
					self.__cursorPos = self.__cursorPos - 1
				elseif self.__cursorMoveDir == CursorDirection.RIGHT and
					self.__cursorPos < utf8.len(self.text) then
					self.__cursorPos = self.__cursorPos + 1
				end
				self.__cursorMoveTimer = self.__cursorBlinkTime - 0.02
			end
		end

		if self.__removePressed then
			self.__removeTimer = self.__removeTimer + dt
			if self.__removeTimer >= self.__removeTime then
				if self.__removeType == RemoveType.BACKSPACE and
					self.__cursorPos > 0 then
					local byteoffset = utf8.offset(self.text, -1,
						self.__cursorPos + 1)
					if byteoffset then
						self.text = string.sub(self.text, 1, byteoffset - 1) ..
							string.sub(self.text, byteoffset + 1)
						self.__cursorPos = self.__cursorPos - 1
					end
				elseif self.__removeType == RemoveType.DELETE and
					self.__cursorPos < utf8.len(self.text) then
					local byteoffset = utf8.offset(self.text, 1,
						self.__cursorPos + 1)
					if byteoffset then
						self.text = string.sub(self.text, 1, byteoffset - 1) ..
							string.sub(self.text, byteoffset + 1)
					end
				end
				self.__removeTimer = self.__removeTime - 0.02
				if self.onChanged then self.onChanged(self.text) end
			end
			self.__newTextWidth = self.font:getWidth(self.text)
			if self.__newTextWidth > self.__prevTextWidth then
				self.__scrollTextX = math.max(
					self.__scrollTextX -
					(self.__newTextWidth -
						self.__prevTextWidth), 0)
			elseif self.__newTextWidth < self.__prevTextWidth and
				self.__scrollTextX > 0 then
				self.__scrollTextX = math.min(
					self.__scrollTextX +
					(self.__prevTextWidth -
						self.__newTextWidth),
					self.__prevTextWidth -
					(self.width - 10))
			end
		end

		self.__cursorBlinkTimer = self.__cursorBlinkTimer + dt
		if self.__cursorBlinkTimer >= self.__cursorBlinkTime then
			self.__cursorVisible = not self.__cursorVisible
			self.__cursorBlinkTimer = 0
		end

		local cursorX = self.x + 5 +
			self.font:getWidth(
				self.text:sub(1, self.__cursorPos)) -
			self.__scrollTextX
		if cursorX > self.x + self.width - 10 then
			self.__scrollTextX = self.__scrollTextX +
				(cursorX - (self.x + self.width - 10))
		elseif cursorX < self.x + 5 then
			self.__scrollTextX = self.__scrollTextX - (self.x + 5 - cursorX)
		elseif self.__scrollTextX < 0 then
			self.__scrollTextX = 0
		end
	end
end

return InputTextBox
