---@class Window:Object
local Window = Object:extend("Window")

function Window:new(x, y, width, height, title)
	Window.super.new(self, x, y)

	self.group = Group()
	self.members = self.group.members

	self.width = width or 400
	self.height = height or 200

	self.title = title or "Window"
	self.font = love.graphics.newFont(12)
	self.font:setFilter("nearest", "nearest")

	self.hovered = false
	self.minimized = false
	self.dragging = false
	self.focused = true
	self.onClosed = nil
	self.onMinimized = nil

	self.color = {0.3, 0.3, 0.3}
	self.barColor = {0.4, 0.4, 0.4}
	self.lineColor = Color.WHITE
	self.textColor = Color.WHITE

	self.lineSize = 1

	self.exitButton = ui.UIButton(0, 0, 22, 22, 'X', function()
		self:kill()
		if self.onClosed then self.onClosed() end
	end)
	self.exitButton.color = Color.RED
	self.minButton = ui.UIButton(0, 0, 22, 22, '-', function()
		self.minimized = not self.minimized
		if self.onMinimized then self.onMinimized() end
	end)
end

function Window:add(obj)
	obj.x = obj.x + self.x
	obj.y = obj.y + self.y
	obj.cameras = self.cameras
	return self.group:add(obj)
end

function Window:remove(obj) return self.group:remove(obj) end

function Window:sort(func) return self.group:sort(func) end

function Window:recycle(class, factory, revive) return self.group:recycle(class, factory, revive) end

function Window:clear() self.group:clear() end

function Window:kill()
	self.group:kill(); Object.super.kill(self)
end

function Window:revive()
	self.group:revive(); Object.super.revive(self)
end

function Window:destroy()
	self.group:destroy(); Object.super.destroy(self)
end

function Window:update(dt)
	Window.super.update(self, dt)

	self.prevMouseX = self.prevMouseX or game.mouse.x
	self.prevMouseY = self.prevMouseY or game.mouse.y

	self.group:update(dt)

	local mx, my = game.mouse.x, game.mouse.y
	self.hovered =
		(mx >= self.x and mx <= self.x + self.width and my >= self.y - 35 and my <=
			(self.minimized and self.y or self.y + self.height))

	local barHovered =
		(mx >= self.x and mx <= self.x + self.width and my >= self.y - 35 and my <=
			self.y)

	if barHovered and game.mouse.justPressedLeft then
		self.dragging = true
		self.prevMouseX = mx
		self.prevMouseY = my
		self.focused = true
	elseif not self.hovered and game.mouse.justPressedLeft then
		self.focused = false
	end

	if game.mouse.justReleasedLeft then
		self.dragging = false
	end

	if self.focused and self.dragging then
		local dx = mx - self.prevMouseX
		local dy = my - self.prevMouseY

		self.x = self.x + dx
		self.y = self.y + dy
		for _, obj in ipairs(self.members) do
			obj.x = obj.x + dx
			obj.y = obj.y + dy
		end

		self.prevMouseX = mx
		self.prevMouseY = my
	end

	self.exitButton:setPosition(self.x + self.width - 28, self.y - 29)
	self.exitButton.disabled = not self.focused
	self.exitButton:update()

	self.minButton:setPosition(self.x + self.width - 54, self.y - 29)
	self.minButton.disabled = not self.focused
	self.minButton:update()
end

function Window:__render(camera)
	local cr, cg, cb, ca = love.graphics.getColor()
	local lineWidth = love.graphics.getLineWidth()

	if self.minimized then
		love.graphics.setColor(self.barColor[1], self.barColor[2], self.barColor[3],
			self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 35, self.width, 35, 8, 8)

		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 18, self.width, 17, 8, 8)

		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.setColor(self.lineColor[1], self.lineColor[2], self.lineColor[3],
				self.alpha)
			love.graphics.rectangle("line", self.x, self.y - 35, self.width, 35, 8, 8)
			love.graphics.setLineWidth(lineWidth)
		end
	else
		love.graphics.setColor(self.barColor[1], self.barColor[2], self.barColor[3],
			self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 35, self.width, 50, 8, 8)

		love.graphics.setColor(self.color[1], self.color[2], self.color[3],
			self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 18, self.width, self.height + 18, 8, 8)

		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x, self.y, self.width, 2)

		love.graphics.setColor(self.barColor[1], self.barColor[2], self.barColor[3],
			self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 18, self.width, 17)

		love.graphics.setColor(0, 0, 0, 0.1 / self.alpha)
		love.graphics.rectangle("fill", self.x, self.y - 18, self.width, 17)

		if self.lineSize > 0 then
			love.graphics.setLineWidth(self.lineSize)
			love.graphics.setColor(self.lineColor[1], self.lineColor[2], self.lineColor[3],
				self.alpha)
			love.graphics.rectangle("line", self.x, self.y - 35, self.width, self.height + 35, 8, 8)
			love.graphics.setLineWidth(lineWidth)
		end

		for _, member in ipairs(self.members) do
			if member.x then
				love.graphics.push()
				member:__render(camera)
				love.graphics.pop()
			else
				member:__render(camera)
			end
		end
	end

	love.graphics.setColor(self.textColor[1], self.textColor[2],
		self.textColor[3], self.alpha)
	love.graphics.print(self.title, self.font, self.x + 10, self.y - 25)

	self.exitButton:__render(camera)
	self.minButton:__render(camera)

	love.graphics.setColor(cr, cg, cb, ca)
end

return Window
