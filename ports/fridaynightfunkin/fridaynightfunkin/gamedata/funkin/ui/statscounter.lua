-- this code fucking sucks
local StatsCounter = Object:extend("StatsCounter")

local rname, rversion, rvendor, rdevice
function StatsCounter:new(x, y, font, bigfont, color, align)
	StatsCounter.super.new(self, x, y)

	self.font = font or love.graphics.setNewFont(14)
	self.bigfont = bigfont or love.graphics.setNewFont(18)
	self.color = color or self.color
	self.alignment = align or "left"
	self.width = 512

	self.showFps = true
	self.showRender = true
	self.showMemory = true
	self.showDraws = true

	rname, rversion, rvendor, rdevice = love.graphics.getRendererInfo()
end

local combine, content, bigcontent = " | "
local fpsFormat, tpsFormat, inputsFormat = "%d FPS", "%d TPS", "Inputs: %dms"
local ramFormat, renderFormat, drawsFormat = "%s RAM | %s VRAM", "%s | %s", "%d DRAWS"
function StatsCounter:___render(x, y, r, g, b, a, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)
	if self.showFps then
		love.graphics.setFont(bigfont)
		love.graphics.setColor(r, g, b, a)
		love.graphics.printf(bigcontent, x, y, width, align, rad, sx, sy, ox, oy)
	end

	if self.showRender or self.showMemory or self.showDraws then
		love.graphics.setFont(font)
		love.graphics.setColor(r, g, b, a * 0.75)
		love.graphics.printf(content, x, y + (self.showFps and bigheight or 0), width, align, rad, sx, sy, ox, oy)
	end
end

local count, stats, ram, vram = "count"
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

	bigcontent = fpsFormat:format(math.min(love.timer.getFPS(), love.FPScap))
	if love.parallelUpdate then bigcontent = bigcontent .. combine .. tpsFormat:format(love.timer.getTPS()) end
	if love.asyncInput then bigcontent = bigcontent .. combine .. inputsFormat:format(love.timer.getInputs() * 1e4) end

	stats = love.graphics.getStats(stats)
	ram, vram = math.countbytes(collectgarbage(count), 2), math.countbytes(stats.texturememory)

	local contentSort = {}
	if self.showMemory then table.insert(contentSort, ramFormat:format(ram, vram)) end
	if self.showRender then table.insert(contentSort, renderFormat:format(rname, rdevice)) end
	if self.showDraws then table.insert(contentSort, drawsFormat:format(stats.drawcalls)) end
	content = #contentSort > 0 and table.concat(contentSort, "\n") or ""

	love.graphics.setShader(self.shader); love.graphics.setBlendMode(self.blend)

	self:___render(x + 2, y + 2, 0, 0, 0, self.alpha * 0.8, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)
	self:___render(x, y, color[1], color[2], color[3], self.alpha, font, bigfont, bigheight, width, align, rad, sx, sy, ox, oy)

	love.graphics.setFont(_font)
	love.graphics.setColor(r, g, b, a)
	love.graphics.setBlendMode(blendMode, alphaMode)
	if self.shader then love.graphics.setShader(shader) end
end

return StatsCounter
