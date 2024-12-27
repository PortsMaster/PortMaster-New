---@class Sound:Basic
local Sound = Basic:extend("Sound")

function Sound:new(x, y)
	Sound.super.new(self)
	self:revive()
	self.visible, self.cameras = nil, nil
end

function Sound:revive()
	self:reset(true)
	self.__volume = 1
	self.__pitch = 1
	self.__duration = 0
	self.__wasPlaying = false
	Sound.super.revive(self)
end

function Sound:reset(cleanup, x, y)
	if cleanup then
		self:cleanup()
	elseif self.__source ~= nil then
		self:stop()
	end
	self:setPosition(x or self.x, y or self.y)

	self.__wasPlaying = false
	self.looped = false
	self.autoDestroy = false
	self.radius = 0
	self:cancelFade()
	self:setVolume(1)
	self:setPitch(1)
end

function Sound:fade(duration, startVolume, endVolume)
	self.__fadeElapsed = 0
	self.__fadeDuration = duration
	self.__startVolume = startVolume
	self.__endVolume = endVolume
end

function Sound:cancelFade()
	self.__fadeDuration = nil
end

function Sound:cleanup()
	self.active = false
	self.target = nil
	self.onComplete = nil

	if self.__source ~= nil then
		self:stop()
		if self.__isSource and self.__source.release then
			self.__source:release()
		end
	end
	self.__paused = true
	self.__isFinished = false
	self.__isSource = false
	self.__source = nil
end

function Sound:destroy()
	Sound.super.destroy(self)
	self:cleanup()
end

function Sound:kill()
	Sound.super.kill(self)
	self:reset(self.autoDestroy)
end

function Sound:setPosition(x, y)
	self.x, self.y = x or 0, y or 0
end

function Sound:load(asset, autoDestroy, onComplete)
	if not self.exists or asset == nil then return end
	self:cleanup()

	self.__isSource = asset:typeOf("SoundData")
	self.__source = self.__isSource and love.audio.newSource(asset) or asset
	return self:init(autoDestroy, onComplete)
end

function Sound:init(autoDestroy, onComplete)
	if autoDestroy ~= nil then self.autoDestroy = autoDestroy end
	if onComplete ~= nil then self.onComplete = onComplete end

	self.active = true

	if self.__source then
		self.__duration = self.__source:getDuration()
	end

	return self
end

function Sound:play(volume, looped, pitch, restart)
	if not self.active or not self.__source then return self end

	if restart then
		pcall(self.__source.stop, self.__source)
	elseif self:isPlaying() then
		return self
	end

	self.__paused = false
	self.__isFinished = false
	self:setVolume(volume)
	self:setLooping(looped)
	self:setPitch(pitch)
	pcall(self.__source.play, self.__source)
	return self
end

function Sound:pause()
	self.__paused = true
	if self.__source then pcall(self.__source.pause, self.__source) end
	return self
end

function Sound:stop()
	self.__paused = true
	if self.__source then pcall(self.__source.stop, self.__source) end
	return self
end

function Sound:proximity(x, y, target, radius)
	self:setPosition(x, y)
	self.target = target
	self.radius = radius
	return self
end

function Sound:update(dt)
	local isFinished = self:isFinished()
	if isFinished and not self.__isFinished then
		local onComplete = self.onComplete
		if self.autoDestroy then
			self:kill()
		else
			self:stop()
		end

		if onComplete then onComplete() end
	end

	self.__isFinished = isFinished

	if self.__fadeDuration then
		self.__fadeElapsed = self.__fadeElapsed + dt
		if self.__fadeElapsed < self.__fadeDuration then
			self:setVolume(math.lerp(self.__startVolume, self.__endVolume, self.__fadeElapsed / self.__fadeDuration))
		else
			self:setVolume(self.__endVolume)
			self.__fadeStartTime, self.__fadeDuration, self.__startVolume, self.__endVolume = nil
		end
	end
end

function Sound:onFocus(focus)
	if not self:isFinished() then
		if focus then
			if self.__wasPlaying then self:play() end
		elseif self:isPlaying() then
			self.__wasPlaying = true
			self:pause()
		else
			self.__wasPlaying = false
		end
	end
end

function Sound:isPlaying()
	if not self.__source then return false end
	local success, playing = pcall(self.__source.isPlaying, self.__source)
	return success and playing
end

function Sound:isFinished()
	return self.active and not self.__paused and not self:isPlaying() and
		not self:isLooping()
end

function Sound:tell()
	if not self.__source then return 0 end
	local success, position = pcall(self.__source.tell, self.__source)
	return success and position or 0
end

function Sound:seek(position)
	if not self.__source then return false end
	return pcall(self.__source.seek, self.__source, position)
end

function Sound:getDuration()
	if not self.__source then return -1 end
	local success, duration = pcall(self.__source.getDuration, self.__source)
	return success and duration or -1
end

function Sound:setVolume(volume)
	self.__volume = volume or self.__volume
	if not self.__source then return false end
	return pcall(self.__source.setVolume, self.__source, self:getActualVolume())
end

function Sound:getActualVolume()
	return self.__volume * (game.sound.__mute and 0 or 1) * (game.sound.__volume or 1)
end

function Sound:getVolume() return self.__volume end

function Sound:setPitch(pitch)
	self.__pitch = pitch or self.__pitch
	if not self.__source then return false end
	return pcall(self.__source.setPitch, self.__source, self:getActualPitch())
end

function Sound:getActualPitch()
	return self.__pitch * (game.sound.__pitch or 1)
end

function Sound:getPitch() return self.__pitch end

function Sound:setLooping(loop)
	if not self.__source then return false end
	return pcall(self.__source.setLooping, self.__source, loop)
end

function Sound:isLooping()
	if not self.__source then return end
	local success, loop = pcall(self.__source.isLooping, self.__source)
	if success then return loop end
end

return Sound
