---@class Graphic:Object
local Graphic = Object:extend("Graphic")

function Graphic:new(x, y, width, height, color, type, fill, lined)
	Graphic.super.new(self, x, y)

	self.width = width or 120
	self.height = height or 50

	self.color = color or Color.BLACK
	self.type = type or "rectangle"
	self.fill = fill or "fill"
	self.lined = lined or false

	self.config = {
		type = "open",
		angle = {0, 360},
		round = {0, 0},
		segments = 36,
		vertices = nil
	}

	self.line = {
		width = 6,
		color = {1, 1, 1, 1},
		join = "miter"
	}
end

function Graphic:_canDraw()
	return (self.width > 0 or self.height > 0 or
		self.config.vertices) and Graphic.super._canDraw(self)
end

function Graphic:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local shader = self.shader and love.graphics.getShader()
	local blendMode, alphaMode = love.graphics.getBlendMode()
	local lineStyle = love.graphics.getLineStyle()
	local lineWidth = love.graphics.getLineWidth()
	local lineJoin = love.graphics.getLineJoin()

	local line = self.line
	local linesize = line.width
	love.graphics.setLineStyle(self.antialiasing and "smooth" or "rough")
	love.graphics.setLineWidth(linesize)
	love.graphics.setLineJoin(line.join)

	local x, y, w, h, sx, sy, ox, oy = self.x, self.y, self.width or 0, self.height or 0,
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	local config = self.config
	local rnd, ang1, ang2 = config.round, 0, 0
	if config.angle then
		local pi180 = math.pi / 180
		ang1, ang2 = config.angle[1] * pi180, config.angle[2] * pi180
	end

	if self.fill == "line" then
		x, y = x + linesize / 2, y + linesize / 2
		w, h = w - linesize, h - linesize
	end
	local rad = math.min(w, h) / 2

	local color = self.color
	love.graphics.setShader(self.shader)
	love.graphics.setBlendMode(self.blend)
	love.graphics.setColor(color[1], color[2], color[3], self.alpha)

	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.rotate(math.rad(self.angle))
	love.graphics.scale(sx, sy)

	local function drawShape(type, fill)
		if type == "rectangle" then
			love.graphics.rectangle(fill, -ox, -oy, w, h, config.round[1], config.round[2], config.segments)
		elseif type == "polygon" and config.vertices then
			love.graphics.translate(-ox, -oy)
			love.graphics.polygon(fill, config.vertices)
		elseif type == "circle" then
			if w == h then
				love.graphics.circle(fill, rad - ox, rad - oy, rad, config.segments)
			else
				local x, y = w / 2, h / 2
				love.graphics.ellipse(fill, x - ox, y - oy, x, y, config.segments)
			end
		elseif type == "arc" then
			love.graphics.arc(fill, config.type, rad - ox, rad - oy, rad, ang1, ang2,
				math.ceil(config.segments * math.min((ang2 - ang1) / math.pi / 2, 1)))
		end
	end

	drawShape(self.type, self.fill)
	if self.lined then
		color = line.color
		love.graphics.setColor(color[1], color[2], color[3], (color[4] or 1) * self.alpha)
		drawShape(self.type, "line")
	end

	love.graphics.pop()

	love.graphics.setColor(r, g, b, a)
	love.graphics.setBlendMode(blendMode, alphaMode)
	love.graphics.setLineStyle(lineStyle)
	love.graphics.setLineWidth(lineWidth)
	love.graphics.setLineJoin(lineJoin)
	if self.shader then love.graphics.setShader(shader) end
end

return Graphic
