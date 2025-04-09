local Assets = class('Assets')

function Assets:initialize()
	
	self.images = {}
	self.fonts = {}
	self.jsons = {}
	self.music = {}
	self.sfx = {
		footsteps = {
			city = {},
			forest = {},
			dungeon = {}
		},
		misc = {}
	}
	self.itemicons = {}
	
end

function Assets:load()

	local city_footsteps = {
		"walk-stone-1.wav",
		"walk-stone-2.wav",
		"walk-stone-3.wav",
		"walk-stone-4.wav",
		"walk-stone-5.wav",
		"walk-stone-6.wav",
		"walk-stone-7.wav"
	}
	
	for i = 1, #city_footsteps do
		table.insert(self.sfx.footsteps.city, love.audio.newSource("files/sfx/movement/"..city_footsteps[i], "static"))
		table.insert(self.sfx.footsteps.dungeon, love.audio.newSource("files/sfx/movement/"..city_footsteps[i], "static"))
	end
	
	local forest_footsteps = {
		"walk-grass-1.wav",
		"walk-grass-2.wav",
		"walk-grass-3.wav",
		"walk-grass-4.wav",
		"walk-grass-5.wav",
		"walk-grass-6.wav",
		"walk-grass-7.wav"
	}	

	for i = 1, #forest_footsteps do
		table.insert(self.sfx.footsteps.forest, love.audio.newSource("files/sfx/movement/"..forest_footsteps[i], "static"))
	end

	-- load all sounds in the files/sfx/misc/ directory

	self.sfx.misc = {}

	local files = love.filesystem.getDirectoryItems("files/sfx/misc/")
	
	for k, file in ipairs(files) do
		local shortname = file:gsub("%.wav", "")
		self.sfx.misc[shortname] = love.audio.newSource("files/sfx/misc/"..file, "static")
	end

	-- load all ui images in the files/ui/ directory

	self.images = {}

	local files = love.filesystem.getDirectoryItems("files/ui/")
	
	for k, file in ipairs(files) do
		local shortname = file:gsub("%.png", "")
		self.images[shortname] = love.graphics.newImage("files/ui/"..file)
	end
	
	-- load all item icons in the files/itemicons/ directory

	local files = love.filesystem.getDirectoryItems("files/itemicons/")
	
	for k, file in ipairs(files) do
		local shortname = file:gsub("%.png", "")
		self.images[shortname] = love.graphics.newImage("files/itemicons/"..file)
	end
	
	-- music

	self.music["forest"] = love.audio.newSource("files/music/forest.mp3", "stream")
	self.music["forest"]:setLooping(true)
	self.music["city"] = love.audio.newSource("files/music/city.mp3", "stream")
	self.music["city"]:setLooping(true)
	self.music["dungeon"] = love.audio.newSource("files/music/dungeon.mp3", "stream")
	self.music["dungeon"]:setLooping(true)
	self.music["mainmenu"] = love.audio.newSource("files/music/mainmenu.mp3", "stream")
	self.music["mainmenu"]:setLooping(true)
	self.music["buildup"] = love.audio.newSource("files/music/buildup.mp3", "stream")
	self.music["buildup"]:setLooping(false)
	self.music["gameover"] = love.audio.newSource("files/music/gameover.mp3", "stream")
	self.music["gameover"]:setLooping(false)
	self.music["victory"] = love.audio.newSource("files/music/victory.mp3", "stream")
	self.music["victory"]:setLooping(false)
	
	-- font

	self.fonts["main"] = love.graphics.newFont("files/fonts/windows_command_prompt.ttf", 16 , "none", love.graphics.getDPIScale())
	self.fonts["mainmenu"] = love.graphics.newFont("files/fonts/alagard.ttf", 16 , "none", love.graphics.getDPIScale())
	
	-- generate quads for compass
	
	self.compass_quads = {}
	
	for i = 0, 3 do
		local quad = love.graphics.newQuad(i*70, 0, 70, 18, self.images["compass-letters"]:getWidth(), self.images["compass-letters"]:getHeight())
		self.compass_quads[i] = quad
	end
	
	-- generate quads for digits
	
	self.digit_quads = {}
	
	for i = 0, 9 do
		local quad = love.graphics.newQuad(i*5, 0, 5, 6, self.images["digits"]:getWidth(), self.images["digits"]:getHeight())
		self.digit_quads[i] = quad
	end
	
	-- generate quads for automapper
	
	self.automapper_quads = {}
	
	for i = 0, 29 do
		local quad = love.graphics.newQuad(i*6, 0, 6, 6, self.images["automapper-sprites"]:getWidth(), self.images["automapper-sprites"]:getHeight())
		self.automapper_quads[i] = quad
	end
	
end

function Assets:setMusicVolume(id, value)

	if self.music[id] then
		self.music[id]:setVolume(value)
	end

end

function Assets:playMusic(id)

	if not self.music[id] then
		return
	end

	self.music[id]:setVolume(savedsettings.musicVolume)
	self.music[id]:play()

end

function Assets:stopMusic(id)

	if not self.music[id] then
		return
	end

	self.music[id]:stop()

end

function Assets:isPlaying(id)

	if not self.music[id] then
		return false
	end

	return self.music[id]:isPlaying()

end

function Assets:playSound(value)

	if type(value) == 'string' then
		local sound = self.sfx.misc[value]
		if sound then
			sound:stop()
			sound:setVolume(savedsettings.sfxVolume)
			sound:play()
		end
	elseif type(value) == 'userdata' then
		value:setVolume(savedsettings.sfxVolume)
		value:play()
	end
	
end

return Assets
