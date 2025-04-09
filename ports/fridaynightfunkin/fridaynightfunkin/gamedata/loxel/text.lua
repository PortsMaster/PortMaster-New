---@class Text:Object
local Text = Object:extend("Text")

function Text:new(x, y, content, font, color, align, limit)
	Text.super.new(self, x, y)
	self.width, self.height = 0, 0

	self.content = content
	self.font = font or love.graphics.getFont()
	self.color = color or self.color
	self.alignment = align or "left"
	self.limit = limit
	self.bgColor = {0, 0, 0, 0}

	self.outline = {
		style = "normal",
		color = {0, 0, 0, 1},
		width = 0,
		offset = {x = 0, y = 0},

		-- these affects the outline quality
		precision = 8,
		antialiasing = true
	}

	self.__content = nil
	self.__limit = nil
	self.__font = nil

	self:__updateDimension()
end

function Text:destroy()
	Text.super.destroy(self)

	self.font = nil
	self.content = nil
	self.outline = nil
end

function Text:__updateDimension()
	if self.__content == self.content and self.__font == self.font and
		self.__limit == self.limit
	then
		return
	end
	self.__content = self.content
	self.__limit = self.limit
	self.__font = self.font

	self.width = self.font:getWidth(self.content)
	self.height = self.font:getHeight()
	if self.limit ~= nil or self.width ~= 0 then
		local _, lines = self.font:getWrap(self.content, self.limit or self.width)
		self.height = self.height * #lines
	end
end

function Text:getWidth()
	self:__updateDimension()
	return self.width
end

function Text:getHeight()
	self:__updateDimension()
	return self.height
end

function Text:screenCenter(axes)
	self:__updateDimension()
	if axes == nil then axes = "xy" end
	if axes:find("x") then self.x = (game.width - self.width) / 2 end
	if axes:find("y") then self.y = (game.height - self.height) / 2 end
	return self
end

function Text:fixOffsets(__width, __height)
	self.offset.x = ((__width or self:getWidth()) - self.width) / 2
	self.offset.y = ((__height or self:getHeight()) - self.height) / 2
end

function Text:centerOrigin(__width, __height)
	self.origin.x = (__width or self:getWidth()) / 2
	self.origin.y = (__height or self:getHeight()) / 2
end

function Text:setOutline(style, width, offset, color)
	if not self.outline then self.outline = table.new(0, 4) end
	self.outline.style = style or "normal"
	self.outline.width = width or 0
	self.outline.offset = offset or {x = 0, y = 0}
	self.outline.color = color or {0, 0, 0, 1}
end

function Text:_canDraw()
	return self.content and self.content ~= "" and Text.super._canDraw(self)
end

function Text:_getBoundary()
	local abs = math.abs
	local x, y = self.x or 0, self.y or 0
	if self.offset ~= nil then x, y = x - self.offset.x, y - self.offset.y end
	local w, h = self.limit ~= nil and self.limit or self:getWidth(), self:getHeight()

	return x, y, w, h, abs(self.scale.x * self.zoom.x), abs(self.scale.y * self.zoom.y),
		self.origin.x, self.origin.y
end

function Text:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local shader = self.shader and love.graphics.getShader()
	local blendMode, alphaMode = love.graphics.getBlendMode()
	local font = love.graphics.getFont()

	local min, mag, anisotropy = self.font:getFilter()
	local mode = self.antialiasing and "linear" or "nearest"
	self.font:setFilter(mode, mode, anisotropy)

	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	local content, align, outline = self.content, self.alignment, self.outline
	local width, color = self.limit or self:getWidth()

	love.graphics.setShader(self.shader); love.graphics.setBlendMode(self.blend)
	love.graphics.setFont(self.font)

	if outline then
		color = outline.color
		love.graphics.setColor(color[1], color[2], color[3], (color[4] or 1) * self.alpha)

		if outline.style == "simple" then
			love.graphics.printf(content,
				x + outline.offset.x, y + outline.offset.y,
				width, align, rad, sx, sy, ox, oy)
		elseif outline.width > 0 and outline.style == "normal" then
			local step = (2 * math.pi) / outline.precision
			for i = 1, outline.precision do
				local dx = math.cos(i * step) * outline.width
				local dy = math.sin(i * step) * outline.width
				if outline.antialiasing ~= nil then
					local omode = outline.antialiasing and "linear" or "nearest"
					self.font:setFilter(omode, omode, anisotropy)
				end
				love.graphics.printf(content, x + dx, y + dy,
					width, align, rad, sx, sy, ox, oy)
			end
		end
	end
	self.font:setFilter(mode, mode, anisotropy)

	color = self.bgColor
	local bgAlpha = #color > 3 and color[4] * self.alpha or self.alpha
	love.graphics.setColor(color[1], color[2], color[3], bgAlpha)
	love.graphics.rectangle("fill", x, y, self:getWidth(), self:getHeight())

	color = self.color
	love.graphics.setColor(color[1], color[2], color[3], self.alpha)
	love.graphics.printf(content, x, y, width, align, rad, sx, sy, ox, oy)

	self.font:setFilter(min, mag, anisotropy)
	love.graphics.setColor(r, g, b, a)
	love.graphics.setFont(font)
	love.graphics.setBlendMode(blendMode, alphaMode)
	if self.shader then love.graphics.setShader(shader) end
end

return Text
