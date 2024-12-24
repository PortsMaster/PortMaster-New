---@class Trail:SpriteGroup
local Trail = SpriteGroup:extend("Trail")

local function setLength(list, newLength)
	if newLength < 0 then
		return list
	end

	local oldLength = #list
	local diff = newLength - oldLength
	if diff >= 0 then
		return list
	end

	diff = -diff
	for i = 1, diff do
		table.remove(list)
	end

	return list
end

function Trail:new(target, length, delay, alpha, diff)
	Trail.super.new(self)

	self.target = target
	self.delay = delay or 3

	self.xEnabled = true
	self.yEnabled = true
	self.rotationsEnabled = true
	self.scalesEnabled = true
	self.framesEnabled = true

	self.__counter = 0
	self.__trailLength = 0

	self.__transp = alpha or 0.4
	self.__difference = diff or 0.05

	self.__recentPositions = {}
	self.__recentAngles = {}
	self.__recentScales = {}
	self.__recentFrames = {}
	self.__recentFlipX = {}
	self.__recentFlipY = {}
	self.__recentAnimations = {}

	self.__spriteOrigin = target.origin

	self:increaseLength(length)
end

function Trail:destroy()
	self.__recentPositions = nil
	self.__recentAngles = nil
	self.__recentScales = nil
	self.__recentFrames = nil
	self.__recentFlipX = nil
	self.__recentFlipY = nil
	self.__recentAnimations = nil
	self.__spriteOrigin = nil
	self.target = nil

	Trail.super.destroy(self)
end

function Trail:update(dt)
	self.__counter = self.__counter + 1

	if self.__counter >= self.delay and self.__trailLength >= 1 then
		self.__counter = 0

		local sprPosition
		if #self.__recentPositions == self.__trailLength then
			sprPosition = table.remove(self.__recentPositions)
		end
		sprPosition = {
			x = self.target.x - self.target.offset.x,
			y = self.target.y - self.target.offset.y
		}
		table.insert(self.__recentPositions, 1, sprPosition)

		if self.rotationsEnabled then
			self:cacheValue(self.__recentAngles, self.target.angle)
		end

		if self.scalesEnabled then
			local sprScale
			if #self.__recentScales == self.__trailLength then
				sprScale = table.remove(self.__recentScales)
			else
				sprScale = {x = self.target.scale.x, y = self.target.scale.y}
			end
			table.insert(self.__recentScales, 1, sprScale)
		end

		if self.framesEnabled then
			self:cacheValue(self.__recentFrames, self.target.curFrame)
			self:cacheValue(self.__recentFlipX, self.target.flipX)
			self:cacheValue(self.__recentFlipY, self.target.flipY)
			self:cacheValue(self.__recentAnimations, self.target.curAnim)
		end

		local trailSprite
		for i = 1, #self.__recentPositions do
			trailSprite = self.members[i]
			trailSprite.x = self.__recentPositions[i].x
			trailSprite.y = self.__recentPositions[i].y

			if self.rotationsEnabled then
				trailSprite.angle = self.__recentAngles[i]
				trailSprite.origin.x = self.__spriteOrigin.x
				trailSprite.origin.y = self.__spriteOrigin.y
			end

			if self.scalesEnabled then
				trailSprite.scale.x = self.__recentScales[i].x
				trailSprite.scale.y = self.__recentScales[i].y
			end

			if self.framesEnabled then
				trailSprite.curFrame = self.__recentFrames[i]
				trailSprite.flipX = self.__recentFlipX[i]
				trailSprite.flipY = self.__recentFlipY[i]
				trailSprite.curAnim = self.__recentAnimations[i]
			end

			trailSprite.exists = true
		end
	end

	Trail.super.update(self, dt)
end

function Trail:cacheValue(list, value)
	table.insert(list, 1, value)
	setLength(list, self.__trailLength)
end

function Trail:resetTrail()
	table.splice(self.__recentPositions, 0, #self.__recentPositions)
	table.splice(self.__recentAngles, 0, #self.__recentAngles)
	table.splice(self.__recentScales, 0, #self.__recentScales)
	table.splice(self.__recentFrames, 0, #self.__recentFrames)
	table.splice(self.__recentFlipX, 0, #self.__recentFlipX)
	table.splice(self.__recentFlipY, 0, #self.__recentFlipY)
	table.splice(self.__recentAnimations, 0, #self.__recentAnimations)

	for i = 1, #self.members do
		if self.members[i] ~= nil then
			self.members[i].exists = false
		end
	end
end

function Trail:increaseLength(amount)
	if amount <= 0 then
		return
	end

	self.__trailLength = self.__trailLength + amount

	for i = 1, amount do
		local trailSprite = Sprite(0, 0)

		trailSprite:loadTextureFromSprite(self.target)
		trailSprite.exists = false
		trailSprite.active = false
		self:add(trailSprite)
		trailSprite.alpha = self.__transp
		self.__transp = self.__transp - self.__difference

		if trailSprite.alpha <= 0 then
			trailSprite:kill()
		end
	end
end

function Trail:changeValuesEnabled(angle, x, y, scale)
	self.rotationsEnabled = angle
	self.xEnabled = x or true
	self.yEnabled = y or true
	self.scalesEnabled = scale or true
end

return Trail
