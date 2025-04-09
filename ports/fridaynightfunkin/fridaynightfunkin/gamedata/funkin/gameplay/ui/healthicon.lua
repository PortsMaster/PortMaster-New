local HealthIcon = Sprite:extend("HealthIcon")

HealthIcon.defaultIcon = "face"

function HealthIcon:new(icon, isPlayer, health)
	HealthIcon.super.new(self)

	self.isPlayer, self.isLegacyStyle = isPlayer or false, true
	self.health = health or 50
	self.flipX = self.isPlayer
	self.sprTracker = nil
	self:changeIcon(icon)
end

function HealthIcon:updateAnimation()
	local percent = self.health
	if not self.isPlayer then percent = 100 - percent end
	local isLosing = percent < 10
	if self.isLegacyStyle then
		self.curFrame = isLosing and 2 or 1
	else
		local isWinning = percent > 80
		local function backToIdleIfFinished()
			if self.animFinished then self:play("idle") end
		end
		switch(self.curAnim and self.curAnim.name or "idle", {
			["idle"] = function()
				if isLosing then
					self:fallbackPlay("toLosing", "losing")
				elseif isWinning then
					self:fallbackPlay("toWinning", "winning")
				else
					self:play("idle")
				end
			end,
			["winning"] = function()
				if not isWinning then
					self:fallbackPlay("fromWinning", "idle")
				else
					self:fallbackPlay("winning", "idle")
				end
			end,
			["losing"] = function()
				if not isLosing then
					self:fallbackPlay("fromLosing", "idle")
				else
					self:fallbackPlay("losing", "idle")
				end
			end,
			["toLosing"] = function()
				if self.animFinished then self:fallbackPlay("losing", "idle") end
			end,
			["toWinning"] = function()
				if self.animFinished then self:fallbackPlay("winning", "idle") end
			end,
			["fromLosing"] = backToIdleIfFinished,
			["fromWinning"] = backToIdleIfFinished,
			["default"] = function() self:play("idle") end
		})
	end
end

function HealthIcon:changeIcon(icon, ignoreDefault)
	if not icon or icon == "" or not paths.getImage("icons/" .. icon) then
		if ignoreDefault then return false end
		icon = HealthIcon.defaultIcon
	end

	self.icon = icon

	local hasOldSuffix = icon:endsWith("-old")
	self.isPixelIcon = icon:endsWith("-pixel") or
		(hasOldSuffix and icon:sub(1, -5):endsWith("-pixel"))
	self.isOldIcon = hasOldSuffix or
		(self.isPixelIcon and icon:sub(1, -7):endsWith("-old"))

	local path = "icons/" .. icon
	local isSparrow = paths.exists(paths.getPath("images/" .. path .. ".xml"), "file")
	self.isLegacyStyle = not isSparrow and not paths.exists(paths.getPath("images/" .. path .. ".txt"), "file")
	if self.isLegacyStyle then
		self:loadTexture(paths.getImage(path))
		if math.round(self.width / self.height) > 1 then
			self:loadTexture(self.texture, true,
				math.floor(self.width / 2),
				math.floor(self.height))
			self:addAnim("i", {0, 1}, 0)
			self:play("i")
		end

		self.iconOffset = {x = (self.width - 150) / 2, y = (self.height - 150) / 2}

		local zoom = self.isPixelIcon and 150 / self.height or 1
		self.zoom.x, self.zoom.y = zoom, zoom
		self.antialiasing = zoom < 2.5 and self.antialiasing
		self:updateHitbox()
	else
		self:setFrames(isSparrow and paths.getSparrowAtlas(path) or paths.getPackerAtlas(path))

		self:addAnimByPrefix("idle", "idle", 24, true)
		self:addAnimByPrefix("winning", "winning", 24, true)
		self:addAnimByPrefix("losing", "losing", 24, true)
		self:addAnimByPrefix("toWinning", "toWinning", 24, false)
		self:addAnimByPrefix("toLosing", "toLosing", 24, false)
		self:addAnimByPrefix("fromWinning", "fromWinning", 24, false)
		self:addAnimByPrefix("fromLosing", "fromLosing", 24, false)
	end

	self:updateAnimation()
	if not self.isLegacyStyle
		and self.curAnim
		and not self.curAnim.looped then
		self:finish()
	end

	return true
end

function HealthIcon:fallbackPlay(anim, fallback)
	self:play(self.__animations[anim] and anim or fallback)
end

function HealthIcon:setScale(scale)
	if self.isLegacyStyle then
		self.scale.x, self.scale.y = scale, scale
	else
		self.scale.x, self.scale.y = 1, 1
	end
	self:updateHitbox()
end

function HealthIcon:fixOffsets(width, height)
	if self.isLegacyStyle and self.iconOffset then
		self.offset.x, self.offset.y = self.iconOffset.x, self.iconOffset.y
	else
		HealthIcon.super.fixOffsets(self, width, height)
	end
end

function HealthIcon:update(dt)
	HealthIcon.super.update(self, dt)
	self:updateAnimation()
	if self.sprTracker then
		self:setPosition(self.sprTracker.x + self.sprTracker:getWidth() + 10,
			self.sprTracker.y - 30)
	end
end

return HealthIcon
