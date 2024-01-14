local Camera = class("Camera")

function Camera:initialize(x, y, w, h)
	self.x = 0
	self.y = 0
	self.w = w
	self.h = h
	
	--boundaries
	self.bx1 = 0
	self.by1 = 0
	self.bx2 = self.w
	self.by2 = self.h

	--moving range
	self.rx = 0
	self.ry = 0
	self.rw = self.w
	self.rh = self.h

	--translations
	self.scale = 1
	self.rotation = 0

	--old state
	self.oldx = 0
	self.oldy = 0
	self.changed = false
	self:change()
end

function Camera:update()
	self.oldx = self.x
	self.oldy = self.y
end

function Camera:draw()
	love.graphics.setLineWidth(1)
	--boundaries
	love.graphics.setColor(1, 0, 0, 1)
	love.graphics.rectangle("line", self.bx1, self.by1, self.bx2-self.bx1, self.by2-self.by1)
	--camera view
	love.graphics.setColor(1, 150/255, 0, 1)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
	--moving range
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.rectangle("line", self.x+self.rx, self.y+self.ry, self.rw, self.rh)
	--love.graphics.rectangle("fill", self.cx-self.x, 0, TILE, TILE)
end

function Camera:focus(x, y, w, h)
	--keep point or box in range
	local w, h = w or 0, h or 0
	if not self.frozen then
		if x+w > self.x+self.rx+self.rw then
			--right
			self:move(x+w-self.rx-self.rw, self:getY())
		elseif x < self.x+self.rx then
			--left
			self:move(x-self.rx, self:getY())
		end
		if y+h > self.y+self.ry+self.rh then
			--down
			self:move(self:getX(), y+h-self.ry-self.rh)
		elseif y < self.y+self.ry then
			--up
			self:move(self:getX(), y-self.ry)
		end
	end
end

function Camera:move(x, y)
	--set posistion
	self.x = x
	self.y = y

	if not self.frozen then
		self:clamp()
	end
end

function Camera:pan(dx, dy)
	--move distance
	self.x = self.x + dx
	self.y = self.y + dy

	if not self.frozen then
		self:clamp()
	end
end

function Camera:center(x, y, w, h)
	--center on point or box
	local w, h = w or 0, h or 0
	self.x = x+w/2 - self.w/2
	self.y = y+h/2 - self.h/2

	self:clamp()
end

function Camera:clamp()
	--keep camera in bounds
	self.x = math.max(math.min(self.x, self.bx2-self.w), self.bx1)
	self.y = math.max(math.min(self.y, self.by2-self.h), self.by1)
end

function Camera:setBounds(x1, y1, x2, y2)
	--set bounds
	self.bx1 = x1 or self.bx1
	self.by1 = y1 or self.by1
	self.bx2 = x2 or self.bx2
	self.by2 = y2 or self.by2
end

function Camera:setRange(x1, y1, x2, y2)
	--set range where points can be in
	self.rx = x1
	self.ry = y1
	self.rw = x2
	self.rh = y2
end

function Camera:getX()
	return self.x
end

function Camera:getY()
	return self.y
end

function Camera:getPosition()
	return self:getX(), self.getY()
end

function Camera:visible(x, y, w, h)
	--return if box is visible
	local w, h = w or 0, h or 0
	return self.x < x+w and self.y < y+h and self.x+self.w > x and self.y+self.h > y
end

function Camera:freeze(freeze)
	self.frozen = freeze
end

function Camera:change()
	--update spritebatch (not more than once per frame)
	self.changed = true
end

return Camera
