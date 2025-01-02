local Character = Sprite:extend("Character")

Character.directions = {"left", "down", "up", "right"}
Character.editorMode = false

function Character:new(x, y, char, isPlayer)
	Character.super.new(self, x, y)

	if not Character.editorMode then
		self.script = Script("data/characters/" .. char, false)
		self.script:set("self", self)
		self.script:call("create")
	end

	self.char = char
	self.isPlayer = isPlayer or false
	self.animOffsets = {}
	self.animAtlases = {}
	self.__reverseDraw = self.__reverseDraw or false

	self.dirAnim, self.holdTime, self.lastHit, self.waitReleaseAfterSing =
		nil, 4, math.negative_infinity, false
	self.danceSpeed, self.danced = 2, false

	local jsonData = paths.getJSON("data/characters/" .. char)
	if jsonData == nil then jsonData = paths.getJSON("data/characters/bf") end

	self.ogFrames = paths.getAtlas(jsonData.sprite)
	self:setFrames(self.ogFrames)

	self.imageFile = jsonData.sprite
	self.jsonScale = 1
	if jsonData.scale and jsonData.scale ~= 1 then
		self.jsonScale = jsonData.scale
		self:setGraphicSize(math.floor(self.width * self.jsonScale))
		self:updateHitbox()
	end

	if jsonData.sing_duration ~= nil then
		self.holdTime = jsonData.sing_duration
	end

	self.positionTable = {x = 0, y = 0}
	if jsonData.position then
		self.positionTable.x = jsonData.position[1]
		self.positionTable.y = jsonData.position[2]
	end
	self.cameraPosition = {x = 0, y = 0}
	if jsonData.camera_points then
		self.cameraPosition.x = jsonData.camera_points[1]
		self.cameraPosition.y = jsonData.camera_points[2]
	end

	self.icon = jsonData.icon or char
	self.iconColor = jsonData.color

	self.flipX = jsonData.flip_x == true
	self.jsonFlipX = self.flipX

	self.jsonAntialiasing = jsonData.antialiasing == nil and true or jsonData.antialiasing
	self.antialiasing = ClientPrefs.data.antialiasing and self.jsonAntialiasing or false

	self.animationsTable = jsonData.animations
	self:resetAnimations()
	if self.isPlayer then self.flipX = not self.flipX end

	if self.__animations['danceLeft'] and self.__animations['danceRight'] then
		self.danceSpeed = 1
	end

	self.x = self.x + self.positionTable.x
	self.y = self.y + self.positionTable.y

	self:dance()
	if self.curAnim and not self.curAnim.looped then
		self:finish()
	end
end

function Character:resetAnimations(skipSwap)
	if self.animationsTable and #self.animationsTable > 0 then
		for _, anim in ipairs(self.animationsTable) do
			local animAnim = '' .. anim[1]
			local animName = '' .. anim[2]
			local animIndices = anim[3]
			local animFps = anim[4]
			local animLoop = anim[5]
			local animOffsets = anim[6]
			local animAtlas = anim[7]

			if animAtlas and animAtlas ~= "" then
				self:addAtlas(animAnim, animAtlas)
			end

			if animIndices ~= nil and #animIndices > 0 then
				self:addAnimByIndices(animAnim, animName, animIndices, nil,
					animFps, animLoop)
			else
				self:addAnimByPrefix(animAnim, animName, animFps, animLoop)
			end

			if animOffsets ~= nil and #animOffsets > 1 then
				self:addOffset(animAnim, animOffsets[1], animOffsets[2])
			end
		end
	end
	if self.isPlayer ~= self.flipX and not skipSwap then
		self.__reverseDraw = true
		self:switchAnim("singLEFT", "singRIGHT")
		self:switchAnim("singLEFTmiss", "singRIGHTmiss")
		self:switchAnim("singLEFT-loop", "singRIGHT-loop")
	end
end

function Character:switchAnim(oldAnim, newAnim)
	local leftAnim = self.__animations[oldAnim]
	if leftAnim and self.__animations[newAnim] then
		leftAnim.name = newAnim
		self.__animations[oldAnim] = self.__animations[newAnim]
		self.__animations[oldAnim].name = oldAnim
		self.__animations[newAnim] = leftAnim
	end

	local leftOffsets = self.animOffsets[oldAnim]
	if leftOffsets and self.animOffsets[newAnim] then
		self.animOffsets[oldAnim] = self.animOffsets[newAnim]
		self.animOffsets[newAnim] = leftOffsets
	end
end

function Character:update(dt)
	if self.curAnim then
		if self.animFinished and self.__animations[self.curAnim.name .. '-loop'] ~=
			nil then
			self:playAnim(self.curAnim.name .. '-loop')
		end
		local offset = self.animOffsets[self.curAnim.name]
		if offset then
			local rot = math.pi * self.angle / 180
			local offX, offY = self.__reverseDraw and -offset.x or offset.x, offset.y
			local rotOffX = offX * math.cos(rot) - offY * math.sin(rot)
			local rotOffY = offX * math.sin(rot) + offY * math.cos(rot)
			self.offset.x, self.offset.y = rotOffX, rotOffY
		else
			self.offset.x, self.offset.y = 0, 0
		end
	end
	if self.lastHit > 0 and self.lastHit +
		PlayState.conductor.stepCrotchet * self.holdTime
		< PlayState.conductor.time then
		local canDance = true
		if self.waitReleaseAfterSing then
			for input, _ in pairs(PlayState.inputDirections) do
				if controls:down(input) then
					canDance = false
					break
				end
			end
		end
		if canDance then
			self:dance()
			self.lastHit = math.negative_infinity
		end
	end
	Character.super.update(self, dt)
end

function Character:beat(b)
	if self.lastHit <= 0 and b % self.danceSpeed == 0 then
		self:dance(self.danceSpeed < 2)
	end
end

function Character:playAnim(anim, force, frame)
	if self.animAtlases[anim] and self.__frames ~= self.animAtlases[anim].frames then
		self:setFrames(self.animAtlases[anim])
		self:resetAnimations(true)
	elseif self.animAtlases[anim] == nil and self.__frames ~= self.ogFrames.frames then
		self:setFrames(self.ogFrames)
		self:resetAnimations(true)
	end

	Character.super.play(self, anim, force, frame)
	self.dirAnim = nil

	local offset = self.animOffsets[anim]
	if offset then
		local rot = math.pi * self.angle / 180
		local offX, offY = offset.x, offset.y
		if self.__reverseDraw then offX = -offX end
		local rotOffX = offX * math.cos(rot) - offY * math.sin(rot)
		local rotOffY = offX * math.sin(rot) + offY * math.cos(rot)
		self.offset.x, self.offset.y = rotOffX, rotOffY
	else
		self.offset.x, self.offset.y = 0, 0
	end

	if self.__animations["danceLeft"] and self.__animations["danceRight"] then
		if anim == "singLEFT" then
			self.danced = true
		elseif anim == "singRIGHT" then
			self.danced = false
		end
		if anim == "singUP" or anim == "singDOWN" then
			self.danced = not self.danced
		end
	end
end

function Character:sing(dir, type, force)
	local anim = "sing" .. string.upper(Character.directions[dir + 1])
	if type then
		local altAnim = anim .. (type == "miss" and type or "-" .. type)
		if self.__animations[altAnim] then anim = altAnim end
	end
	self:playAnim(anim, force == nil and true or force)

	self.dirAnim = type == "miss" and nil or dir
	self.lastHit = PlayState.conductor.time
end

function Character:dance(force)
	if self.__animations then
		local result = self.script:call("dance")
		if result == nil then result = true end
		if result then
			if self.__animations["danceLeft"] and self.__animations["danceRight"] then
				self.danced = not self.danced

				if self.danced then
					self:playAnim("danceRight", force)
				else
					self:playAnim("danceLeft", force)
				end
			elseif self.__animations["idle"] then
				self:playAnim("idle", force)
			end
		end
	end
end

function Character:addOffset(anim, x, y)
	if x == nil then x = 0 end
	if y == nil then y = 0 end
	self.animOffsets[anim] = {x = x, y = y}
end

function Character:addAtlas(anim, atlasName)
	local atlas = paths.getAtlas(atlasName)
	self.animAtlases[anim] = atlas
end

return Character
