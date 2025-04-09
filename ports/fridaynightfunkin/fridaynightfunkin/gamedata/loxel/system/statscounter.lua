local StatsCounter = Object:extend("StatsCounter")

function StatsCounter:new(x, y, font, bigfont, color, align)
	StatsCounter.super.new(self, x, y)

	self.font = font or love.graphics.setNewFont(14)
	self.bigfont = bigfont or love.graphics.setNewFont(18)
	self.color = color or self.color
	self.alignment = align or "left"
	self.width = 512
end

local content, bigcontent
local fpsFormat = "%d FPS"
local format = "%s RAM | %s VRAM\n%d DRAWS"
function StatsCounter:___render(x, y, r, g, b, a, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)
	love.graphics.setFont(bigfont)
	love.graphics.setColor(r, g, b, a)
	love.graphics.printf(bigcontent, x, y, width, align, rad, sx, sy, ox, oy)

	love.graphics.setFont(font)
	love.graphics.setColor(r, g, b, a * 0.75)
	love.graphics.printf(content, x, y + bigheight, width, align, rad, sx, sy, ox, oy)
end

local count, stats = "count"
function StatsCounter:__render(camera)
	local r, g, b, a = love.graphics.getColor()
	local shader = self.shader and love.graphics.getShader()
	local blendMode, alphaMode = love.graphics.getBlendMode()
	local _font = love.graphics.getFont()

	local x, y, rad, sx, sy, ox, oy = self.x, self.y, math.rad(self.angle),
		self.scale.x * self.zoom.x, self.scale.y * self.zoom.y,
		self.origin.x, self.origin.y

	if self.flipX then sx = -sx end
	if self.flipY then sy = -sy end

	x, y = x + ox - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y + oy - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	local font, bigfont = self.font, self.bigfont
	local align, color, width, bigheight = self.alignment, self.color, self.width, bigfont:getHeight()

	bigcontent = fpsFormat:format(love.timer.getFPS())

	stats = love.graphics.getStats(stats)
	content = format:format(math.countbytes(collectgarbage(count), 2), math.countbytes(stats.texturememory), stats.drawcalls)

	love.graphics.setShader(self.shader); love.graphics.setBlendMode(self.blend)

	self:___render(x + 2, y + 2, 0, 0, 0, self.alpha * 0.8, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)
	self:___render(x, y, color[1], color[2], color[3], self.alpha, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)

	love.graphics.setFont(_font)
	love.graphics.setColor(r, g, b, a)
	love.graphics.setBlendMode(blendMode, alphaMode)
	if self.shader then love.graphics.setShader(shader) end
end

return StatsCounter
