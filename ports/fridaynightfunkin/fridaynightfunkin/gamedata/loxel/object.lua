local abs, rad, deg, atan, cos, sin = math.abs, math.rad, math.deg, math.atan, math.fastcos, math.fastsin
local function checkCollisionFast(
	x1, y1, w1, h1, sx1, sy1, ox1, oy1, a1,
	x2, y2, w2, h2, sx2, sy2, ox2, oy2, a2
)
	local hw1, hw2, hh1, hh2 = w1 / 2, w2 / 2, h1 / 2, h2 / 2
	local rad1, rad2 = rad(a1), rad(a2)
	local sin1, cos1 = abs(sin(rad1)), abs(cos(rad1))
	local sin2, cos2 = abs(sin(rad2)), abs(cos(rad2))

	-- i hate this alot, but fuck it. -ralty
	-- todo: make it work for origin
	return abs(x2 + hw2 - x1 - hw1)
		- hw1 * cos1 * sx1 - hh1 * sin1 * sy1
		- hw2 * cos2 * sx2 - hh2 * sin2 * sy2 < 0
		and abs(y2 + hh2 - y1 - hh1)
		- hh1 * cos1 * sy1 - hw1 * sin1 * sx1
		- hh2 * cos2 * sy2 - hw2 * sin2 * sx2 < 0
end

---@class Object:Basic
local Object = Basic:extend("Object")
Object.checkCollisionFast = checkCollisionFast
Object.defaultAntialiasing = false

function Object.getAngleTowards(x, y, x2, y2)
	return deg(atan((x2 - x) / (y2 - y))) + (y > y2 and 180 or 0)
end

function Object.saveDrawState(obj)
	local lg = love.graphics

	local blend, alpha = lg.getBlendMode()
	local lstyle, lwidth, ljoin =
		lg.getLineStyle(), lg.getLineWidth(), lg.getLineJoin()

	local min, mag, anisotropy
	if obj and obj.getFilter then
		min, mag, anisotropy = obj:getFilter()
	end

	return {
		object = obj,
		shader = lg.getShader(),
		filter = {min, mag, anisotropy},
		color = {lg.getColor()},
		blend = {blend, alpha},
		font = lg.getFont(),
		line = {lstyle, lwidth, ljoin},
	}
end

function Object.loadDrawState(state)
	love.graphics.setShader(state.shader)
	love.graphics.setColor(unpack(state.color))
	love.graphics.setBlendMode(unpack(state.blend))
	love.graphics.setFont(state.font)
	love.graphics.setLineStyle(state.line[1])
	love.graphics.setLineWidth(state.line[2])
	love.graphics.setLineJoin(state.line[3])

	if state.object and state.object.setFilter then
		state.object:setFilter(unpack(state.filter))
	end
end

function Object:new(x, y)
	Object.super.new(self)

	self:setPosition(x, y)
	self.width, self.height = 0, 0

	self.offset = {x = 0, y = 0}
	self.origin = {x = 0, y = 0}
	self.scale = {x = 1, y = 1}
	self.zoom = {x = 1, y = 1} -- same as scale
	self.scrollFactor = {x = 1, y = 1}
	self.flipX = false
	self.flipY = false

	self.shader = nil
	self.antialiasing = Object.defaultAntialiasing or false
	self.color = Color.WHITE
	self.blend = "alpha"

	self.alpha = 1
	self.angle = 0

	self.moves = false
	self.velocity = {x = 0, y = 0}
	self.acceleration = {x = 0, y = 0}
end

function Object:destroy()
	Object.super.destroy(self)

	self.offset.x, self.offset.y = 0, 0
	self.scale.x, self.scale.y = 1, 1

	self.shader = nil
end

function Object:setPosition(x, y)
	self.x, self.y = x or 0, y or 0
end

function Object:setScrollFactor(x, y)
	self.scrollFactor.x, self.scrollFactor.y = x or 0, y or x or 0
end

function Object:getMidpoint()
	return self.x + self.width / 2, self.y + self.height / 2
end

function Object:screenCenter(axes)
	local centerAll = axes == nil or axes == "xy"
	if centerAll or axes == "x" then self.x = (game.width - self.width) / 2 end
	if centerAll or axes == "y" then self.y = (game.height - self.height) / 2 end
	return self
end

function Object:updateHitbox()
	local width, height
	if self.getWidth then width, height = self:getWidth(), self:getHeight() end
	self:fixOffsets(width, height)
	self:centerOrigin(width, height)
end

function Object:centerOffsets(__width, __height)
	self.offset.x = (__width or self.width) / 2
	self.offset.y = (__height or self.height) / 2
end

function Object:fixOffsets(__width, __height)
	self.offset.x = ((__width or self.width) - self.width) / 2
	self.offset.y = ((__height or self.height) - self.height) / 2
end

function Object:centerOrigin(__width, __height)
	self.origin.x = (__width or self.width) / 2
	self.origin.y = (__height or self.height) / 2
end

function Object:getMultColor(r, g, b, a)
	local c = self.color
	return c[1] * math.min(r, 1), c[2] * math.min(g, 1), c[3] * math.min(b, 1),
		self.alpha * (math.min(a or 1, 1))
end

function Object:update(dt)
	if self.moves then
		self.velocity.x = self.velocity.x + self.acceleration.x * dt
		self.velocity.y = self.velocity.y + self.acceleration.y * dt

		self.x = self.x + self.velocity.x * dt
		self.y = self.y + self.velocity.y * dt
	end
end

function Object:_isOnScreen(x, y, w, h, sx, sy, ox, oy, sfx, sfy, c)
	local x2, y2, w2, h2, sx2, sy2, ox2, oy2 = c:_getCameraBoundary()
	return checkCollisionFast(
		x - c.scroll.x * sfx, y - c.scroll.y * sfy, w, h, sx, sy, ox, oy, self.angle,
		x2, y2, w2, h2, sx2, sy2, ox2, oy2, c.angle
	)
end

function Object:isOnScreen(cameras)
	local sf = self.scrollFactor
	local sfx, sfy, x, y, w, h, sx, sy, ox, oy = sf and sf.x or 1, sf and sf.y or 1,
		self:_getBoundary()

	if cameras.x then return self:_isOnScreen(x, y, w, h, sx, sy, ox, oy, sfx, sfy, cameras) end

	for _, c in pairs(cameras) do
		if self:_isOnScreen(x, y, w, h, sx, sy, ox, oy, sfx, sfy, c) then return true end
	end
	return false
end

function Object:_canDraw()
	return self.alpha > 0 and (self.scale.x * self.zoom.x ~= 0 or
		self.scale.y * self.zoom.y ~= 0) and Object.super._canDraw(self)
end

-- i hate this too -ralty
function Object:_getBoundary()
	local x, y = self.x or 0, self.y or 0
	if self.offset ~= nil then x, y = x - self.offset.x, y - self.offset.y end
	if self.getCurrentFrame then
		local f = self:getCurrentFrame()
		if f then x, y = x - f.offset.x, y - f.offset.y end
	end

	local w, h
	if self.getWidth then
		w, h = self:getWidth(), self:getHeight()
	else
		w, h = (self.getFrameWidth and self:getFrameWidth() or self.width or 0),
			(self.getFrameHeight and self:getFrameHeight() or self.height or 0)
	end

	return x, y, w, h, abs(self.scale.x * self.zoom.x), abs(self.scale.y * self.zoom.y),
		self.origin.x, self.origin.y
end

return Object
