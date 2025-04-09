---@class SpriteGroup:Sprite
local SpriteGroup = Sprite:extend("SpriteGroup")

function SpriteGroup:new(x, y)
	SpriteGroup.super.new(self, x, y)

	self.memberScales = {x = 1, y = 1}
	self.memberAngles = 0

	self.group = Group()
	self.members = self.group.members

	self.__unusedCameraRenderQueue = {}
	self.__cameraRenderQueue = {}

	self:_initializeDrawFunctions()
end

-- personally, dont use width, height, or origin if you plan to use "dynamic" scrollFactors
function SpriteGroup:__getNestDimension(members)
	local xmin, xmax, ymin, ymax, x, y, width, height = 0, 0, 0, 0
	for _, member in ipairs(members) do
		if member.x then
			x, y = member.x, member.y
			width = x + (member.getWidth and member:getWidth() or member.width)
			height = y + (member.getHeight and member:getHeight() or member.height)
		elseif member.members then
			x, width, y, height = self:__getNestDimension(member.members)
		end
		if width > xmax then xmax = width end
		if x < xmin then xmin = x end
		if height > ymax then ymax = height end
		if y < ymin then ymin = y end
	end
	return xmin, xmax, ymin, ymax
end

function SpriteGroup:getWidth()
	if not next(self.members) then return 0 end

	local xmin, xmax, ymin, ymax = self:__getNestDimension(self.members)
	self.width, self.height = xmax - xmin, ymax - ymin
	return self.width
end

function SpriteGroup:getHeight()
	if not next(self.members) then return 0 end

	local xmin, xmax, ymin, ymax = self:__getNestDimension(self.members)
	self.width, self.height = xmax - xmin, ymax - ymin
	return self.height
end

function SpriteGroup:screenCenter(axes)
	self:getWidth()
	return SpriteGroup.super.screenCenter(self, axes)
end

function SpriteGroup:centerOffsets()
	self.offset.x, self.offset.y = 0, 0
end

function SpriteGroup:centerOrigin(__width, __height)
	self:getWidth()
	self.origin.x = (__width or self.width) / 2
	self.origin.y = (__height or self.height) / 2
end

function SpriteGroup:__drawNestGroup(members, camera, list, x2, y2, sf, force, zoomx, zoomy)
	for _, member in ipairs(members) do
		local sf2, px, py, sfx, sfy = member.scrollFactor, member.x, member.y
		if px then
			member.x, member.y = px + x2, py + y2
		end
		if sf2 then
			sfx, sfy = sf2.x, sf2.y
			sf2.x, sf2.y = sfx * sf.x, sfy * sf.y
		end

		if member.__cameraRenderQueue then
			if Sprite.super._canDraw(member) and next(member:_prepareCameraDraw(camera, force)) then
				table.insert(list, member)
			end
		elseif member:_canDraw() then
			if member.__render then
				local x, y, w, h, sx, sy, ox, oy = member:_getBoundary()

				if member:_isOnScreen(x, y, w, h, sx, sy, ox, oy,
						sf2 and sf2.x or 1, sf2 and sf2.y or 1, camera)
				then
					table.insert(list, member)
				end
			elseif member.members then
				self:__drawNestGroup(member.members, camera, list,
					(member.x or x2), (member.y or y2), (sf2 or sf), force, zoomx, zoomy)
			end
		end

		member.x, member.y = px, py
		if sf2 then
			sf2.x, sf2.y = sfx, sfy
		end
	end
end

function SpriteGroup:_prepareCameraDraw(c, force)
	local list = self.__cameraRenderQueue[c]
	if list then
		if force then
			table.clear(list)
		else
			return list
		end
	else
		list = table.remove(self.__unusedCameraRenderQueue) or {}
		self.__cameraRenderQueue[c] = list
	end
	self:__drawNestGroup(self.members, c, list, self.x + self.offset.x, self.y + self.offset.y, self.scrollFactor, force, c:getZoomXY())

	return list
end

function SpriteGroup:_canDraw()
	for c, list in pairs(self.__cameraRenderQueue) do
		self.__cameraRenderQueue[c] = nil
		table.insert(self.__unusedCameraRenderQueue, list)
		table.clear(list)
	end

	-- skips the Sprite check
	if Sprite.super._canDraw(self) then
		local yeah = false
		for _, c in pairs(self.cameras or Camera.__defaultCameras) do
			local list = self:_prepareCameraDraw(c, true)
			yeah = yeah or next(list) ~= nil
		end

		return yeah
	end

	return false
end

function SpriteGroup:_isOnScreen(x, y, w, h, sx, sy, ox, oy, sfx, sfy, camera)
	return next(self:_prepareCameraDraw(camera)) ~= nil
end

function SpriteGroup:isOnScreen(cameras, force)
	if cameras.x then return next(self:_prepareCameraDraw(cameras)) ~= nil end
	for _, c in pairs(cameras) do
		if next(self:_prepareCameraDraw(c, force)) then return true end
	end
	return false
end

function SpriteGroup:__render(camera)
	local list = self.__cameraRenderQueue[camera]
	if not list then return end

	local cr, cg, cb, ca = love.graphics.getColor()

	love.graphics.push()

	self.__ogSetColor, love.graphics.setColor = love.graphics.setColor, self.__setColor

	local angle, sx, sy = self.memberAngles, self.memberScales.x, self.memberScales.y

	love.graphics.translate(self.x + self.origin.x + self.offset.x, self.y + self.origin.y + self.offset.y)
	love.graphics.scale(self.scale.x * self.zoom.x, self.scale.y * self.zoom.y)
	love.graphics.rotate(math.rad(self.angle))
	love.graphics.translate(-self.origin.x, -self.origin.y)

	local a, b = camera.scroll, self.scrollFactor
	for i, member in ipairs(list) do
		if member.x then
			local msc = member.scale
			local pa, psx, psy, psz = member.angle, msc.x, msc.y, msc.z

			love.graphics.push()
			love.graphics.translate(a.x * member.scrollFactor.x * (1 - b.x), a.y * member.scrollFactor.y * (1 - b.y))

			member.angle, msc.x, msc.y = pa + angle, psx * sx, psy * sy

			member:__render(camera)

			member.angle, msc.x, msc.y = pa, psx, psy

			love.graphics.pop()
		else
			member:__render(camera)
		end

		list[i] = nil
	end
	self.__cameraRenderQueue[camera] = nil
	table.insert(self.__unusedCameraRenderQueue, list)

	love.graphics.pop()

	love.graphics.setColor = self.__ogSetColor
	self.__ogSetColor(cr, cg, cb, ca)
end

function SpriteGroup:_getBoundary()
	local x, y = self.x or 0, self.y or 0
	if self.offset ~= nil then x, y = x - self.offset.x, y - self.offset.y end

	self:getWidth()
	return x, y, self.width, self.height,
		math.abs(self.scale.x * self.zoom.x), math.abs(self.scale.y * self.zoom.y),
		self.origin.x, self.origin.y
end

function SpriteGroup:_initializeDrawFunctions()
	function self.__setColor(r, g, b, a)
		if type(r) == "table" then
			self.__ogSetColor(self:getMultColor(r[1], r[2], r[3], r[4]))
		else
			self.__ogSetColor(self:getMultColor(r, g, b, a))
		end
	end
end

function SpriteGroup:updateHitbox()
	self:centerOffsets(); self:centerOrigin()
end

function SpriteGroup:loadTexture() return self end

function SpriteGroup:setFrames() return self.__frames end

function SpriteGroup:update(dt) self.group:update(dt) end

function SpriteGroup:add(obj) return self.group:add(obj) end

function SpriteGroup:remove(obj) return self.group:remove(obj) end

function SpriteGroup:sort(func) return self.group:sort(func) end

function SpriteGroup:recycle(class, factory, revive) return self.group:recycle(class, factory, revive) end

function SpriteGroup:clear() self.group:clear() end

function SpriteGroup:kill()
	self.group:kill(); Sprite.super.kill(self)
end

function SpriteGroup:revive()
	self.group:revive(); Sprite.super.revive(self)
end

function SpriteGroup:destroy()
	self.group:destroy(); Sprite.super.destroy(self)
end

return SpriteGroup
