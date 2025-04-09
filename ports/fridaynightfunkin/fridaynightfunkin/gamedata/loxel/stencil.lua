local Stencil = Object:extend("Stencil")

function Stencil:new(object, x, y, width, height)
	Stencil.super.new(self, x or 0, y or 0)
	assert(object ~= nil, "An object must be set to use stencil!")

	self.object = object
	self.stencilObject = nil
	self.width, self.height = width or 100, height or 100
end

-- GOOFY
function Stencil:update(dt)
	Stencil.super.update(self, dt)
	self.object:update(dt)
end

function Stencil:_getBoundary(...)
	return self.object:_getBoundary(...)
end

function Stencil:_isOnScreen(...)
	return self.object:_isOnScreen(...)
end

function Stencil:isOnScreen(...)
	return self.object:isOnScreen(...)
end

function Stencil:_canDraw(...)
	return self.object:_canDraw(...)
end

function Stencil:__render(camera)
	local x, y, rad = self.x, self.y, math.rad(self.angle)
	x, y = x - self.offset.x - (camera.scroll.x * self.scrollFactor.x),
		y - self.offset.y - (camera.scroll.y * self.scrollFactor.y)

	love.graphics.stencil(function()
		if self.stencilObject then self.stencilObject:__render(camera); return
		else love.graphics.rectangle("fill", x, y, self.width, self.height) end
	end, "replace", 1, false)
	love.graphics.setStencilTest("greater", 0)
	self.object:__render(camera)
	love.graphics.setStencilTest()
end

return Stencil
