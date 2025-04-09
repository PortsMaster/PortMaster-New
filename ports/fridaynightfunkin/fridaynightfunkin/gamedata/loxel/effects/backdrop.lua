-- bad code, rewrite needed but I'm lazy to
-- vi

local BackDrop = Object:extend("BackDrop")

function BackDrop:new(x, y, width, height, size, color, color2, speed)
	BackDrop.super.new(self, x or 0, y or 0)
	self.width = width or 500
	self.height = height or 400
	self.size = size or 50
	self.color = color or Color.WHITE
	self.color2 = color2 or {0.5, 0.5, 0.5}
	self.speed = {
		x = type(speed) == "table" and speed.x or speed or 0,
		y = type(speed) == "table" and speed.y or speed or 0
	}
	self.round = {0, 0}
	self.squares = {x = {}, y = {}}

	self.__x, self.__y = 0, 0
	self:_updateSquares()
end

function BackDrop:update(dt)
	self.__x = self.__x + self.speed.x * dt
	self.__y = self.__y + self.speed.y * dt

	if self.speed.x > 0 then
		if self.__x >= self.size then
			self.__x = -self.size
		end
	else
		if self.__x + self.size <= self.size then
			self.__x = self.size
		end
	end
	if self.speed.y > 0 then
		if self.__y >= self.size then
			self.__y = -self.size
		end
	else
		if self.__y + self.size <= self.size then
			self.__y = self.size
		end
	end
end

function BackDrop:updateSize(width, height, size)
	self.width = width or self.width
	self.height = height or self.height
	self.size = size or self.size
	self:_updateSquares()
end

function BackDrop:_updateSquares()
	self.squares.x = {}
	self.squares.y = {}
	local amountX = math.floor(self.width / self.size) + 3
	local amountY = math.floor(self.height / self.size) + 3

	for i = 1, amountX do
		for j = 1, amountY do
			local idx = (i + j) % 2 + 1
			local square = {
				x = (i - 2) * self.size,
				y = (j - 2) * self.size,
				size = self.size
			}
			if idx == 1 then
				table.insert(self.squares.x, square)
			else
				table.insert(self.squares.y, square)
			end
		end
	end
end

function BackDrop:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local shader = self.shader and love.graphics.getShader()
	local blendMode, alphaMode = love.graphics.getBlendMode()

	local x, y, w, h = self.x, self.y, self.width, self.height
	local sx, sy = self.scale.x * self.zoom.x, self.scale.y * self.zoom.y
	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	love.graphics.setShader(self.shader)
	love.graphics.setBlendMode(self.blend)

	love.graphics.push()
	love.graphics.scale(sx, sy)

	love.graphics.stencil(function()
		love.graphics.rectangle("fill", x, y, w, h, self.round[1], self.round[2])
	end, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	love.graphics.translate(x + self.__x, y + self.__y)
	for _, square in ipairs(self.squares.x) do
		love.graphics.setColor(self.color[1], self.color[2], self.color[3],
			(self.color[4] or 1) * self.alpha)
		love.graphics.rectangle("fill", square.x, square.y, square.size, square.size)
	end

	for _, square in ipairs(self.squares.y) do
		love.graphics.setColor(self.color2[1], self.color2[2], self.color2[3],
			(self.color2[4] or 1) * self.alpha)
		love.graphics.rectangle("fill", square.x, square.y, square.size, square.size)
	end
	love.graphics.setStencilTest()
	love.graphics.pop()

	love.graphics.setColor(r, g, b, a)
	love.graphics.setBlendMode(blendMode, alphaMode)
	if self.shader then love.graphics.setShader(shader) end
end

return BackDrop
