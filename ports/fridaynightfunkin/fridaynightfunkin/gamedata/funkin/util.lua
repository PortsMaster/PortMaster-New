local util = {}

function util.getSongSkin(song)
	if song.meta and song.meta.skin then
		return song.meta.skin
	elseif song.skin then
		return song.skin
	end
	return "default"
end

-- also handles caching of the asset located in said path
function util.getSkinPath(skin, key, type)
	local path, obj = "skins/" .. skin .. "/" .. key
	switch(type, {
		["image"] = function()
			obj = paths.getImage(path)
		end,
		["atlas"] = function()
			obj = paths.getAtlas(path)
		end,
		["music"] = function()
			obj = paths.getMusic(path)
		end,
		["sound"] = function()
			obj = paths.getSound(path)
		end
	})
	if obj then return path end
	return "skins/" .. (skin:endsWith("-pixel") and "default-pixel" or "default") .. "/" .. key
end

function util.coolLerp(x, y, i, delta)
	local v = math.lerp(y, x, math.exp(-(delta or game.dt) * i))
	return (y == 0 and v > y) and 0 or v
end

function util.newGradient(dir, ...)
	local colorSize, meshData = select("#", ...) - 1, {}
	local off = dir:sub(1, 1):lower() == "v" and 1 or 2

	for i = 0, colorSize do
		local idx, color, x = i * 2 + 1, select(i + 1, ...), i / colorSize
		local r, g, b, a = color[1], color[2], color[3], color[4] or 1

		meshData[idx] = {x, x, x, x, r, g, b, a}
		meshData[idx + 1] = {x, x, x, x, r, g, b, a}

		for o = off, off + 2, 2 do
			meshData[idx][o], meshData[idx + 1][o] = 1, 0
		end
	end

	return love.graphics.newMesh(meshData, "strip", "static")
end

local time, clock, ms = "%d:%02d", "%d:%02d:%02d", "%.3f"
function util.formatTime(seconds, includeMS)
	local minutes = seconds / 60
	local str = minutes < 60 and time:format(minutes, seconds % 60) or
		clock:format(minutes / 60, minutes % 60, seconds % 60)
	if not includeMS then return str end
	return str .. ms:format(seconds - math.floor(seconds)):sub(2)
end

function util.formatNumber(number)
	if math.abs(number) < 1000 then return tostring(number) end
	local int, frac = tostring(number):match("([^%.]+)%.?(.*)")
	int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse()

	if int:sub(1, 1) == "," then int = int:sub(2) end
	if frac ~= "" then int = int .. "." .. frac end

	return int
end

function util.playMenuMusic(fade)
	local menu = paths.getMusic("freakyMenu")
	if not game.sound.music or not game.sound.music:isPlaying() or game.sound.music.__source ~= menu then
		if game.sound.music then game.sound.music:reset(true) end
		game.sound.playMusic(menu, fade and 0 or ClientPrefs.data.menuMusicVolume / 100)
		if fade then game.sound.music:fade(4, 0, ClientPrefs.data.menuMusicVolume / 100) end
	end
end

function util.playSfx(asset, volume, ...)
	return game.sound.play(asset, (volume or 1) * ClientPrefs.data.sfxVolume / 100, ...)
end

-- menu thing
function util.responsiveBG(bg)
	local scale = math.max(game.width / bg.width, game.height / bg.height)
	bg:setGraphicSize(math.floor(bg.width * scale))
	bg:updateHitbox()
	bg:screenCenter()
	bg:setScrollFactor()

	return bg
end

return util
