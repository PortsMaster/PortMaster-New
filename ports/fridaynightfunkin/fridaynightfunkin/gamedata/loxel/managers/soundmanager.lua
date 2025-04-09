local SoundManager = {}
SoundManager.list = Group()
SoundManager.music = nil

SoundManager.__mute = false
SoundManager.__volume = 1
SoundManager.__pitch = 1

function SoundManager.load(asset, autoDestroy, ...)
	if autoDestroy == nil then autoDestroy = true end
	return SoundManager.list:recycle(Sound):load(asset, autoDestroy, ...)
end

function SoundManager.play(asset, volume, looped, autoDestroy, onComplete, ...)
	return SoundManager.load(asset, autoDestroy, onComplete):play(volume, looped, ...)
end

function SoundManager.loadMusic(asset)
	local music = SoundManager.music
	if not music then
		music = Sound()
		music.persist = true
		SoundManager.music = music
		SoundManager.list:add(music)
	end
	return music:load(asset)
end

function SoundManager.playMusic(asset, volume, looped, ...)
	if looped == nil then looped = true end
	return SoundManager.loadMusic(asset):play(volume, looped, ...)
end

function SoundManager.update(dt)
	SoundManager.list:update(dt)
end

function SoundManager.onFocus(focus)
	if love.autoPause then
		for _, sound in ipairs(SoundManager.list.members) do
			if sound.exists and sound.active then sound:onFocus(focus) end
		end
	end
end

function SoundManager.__adjust()
	for _, sound in ipairs(SoundManager.list.members) do
		if sound.exists and sound.active then
			sound:setVolume()
			sound:setPitch()
		end
	end
end

function SoundManager:adjust(mute, volume, pitch)
	if SoundManager.__mute == mute and SoundManager.__volume == volume and
		SoundManager.__pitch == pitch
	then
		return
	end
	SoundManager.__mute, SoundManager.__volume = mute, volume
	SoundManager.__pitch = pitch
	SoundManager.__adjust()
end

function SoundManager.setMute(mute)
	if SoundManager.__mute == mute then return end
	SoundManager.__mute = mute
	SoundManager.__adjust()
end

function SoundManager.setVolume(volume)
	if SoundManager.__volume == volume then return end
	SoundManager.__volume = volume
	SoundManager.__adjust()
end

function SoundManager.setPitch(pitch)
	if SoundManager.__pitch == pitch then return end
	SoundManager.__pitch = pitch
	SoundManager.__adjust()
end

function SoundManager.destroy(force)
	table.remove(SoundManager.list.members, function(t, i)
		local sound = t[i]
		if force or not sound.persist then
			sound:destroy()
			return true
		end
	end)
end

return SoundManager
