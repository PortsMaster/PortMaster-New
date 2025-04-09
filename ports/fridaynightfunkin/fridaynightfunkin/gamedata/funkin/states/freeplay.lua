local json = require "lib.json".encode
local FreeplayState = State:extend("FreeplayState")
FreeplayState.curDifficulty = 2

function FreeplayState:enter()
	self.notCreated = false

	self.script = Script("data/states/freeplay", false)
	local event = self.script:call("create")
	if event == Script.Event_Cancel then
		FreeplayState.super.enter(self)
		self.script:call("postCreate")
		self.notCreated = true
		return
	end

	-- Update Presence
	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Freeplay Menu"})
	end

	self.lerpScore = 0
	self.intendedScore = 0

	self.selected = false

	self.persistentUpdate = true
	self.persistentDraw = true

	self.songsData = {}
	self:loadSongs()

	self.bg = Sprite(0, 0, paths.getImage('menus/menuDesat'))
	self:add(util.responsiveBG(self.bg))

	self.songs = MenuList(paths.getSound('scrollMenu'), true)
	self.songs.changeCallback = bind(self, self.changeSelection)
	self.songs.selectCallback = bind(self, self.openSong)
	self:add(self.songs)

	if #self.songsData == 0 then
		self.noSongTxt = AtlasText(0, 0, 'No songs here', "bold")
		self.noSongTxt:screenCenter()
		self:add(self.noSongTxt)
	end

	if #self.songsData > 0 then
		for i = 1, #self.songsData do
			local songText = AtlasText(0, 0,
				self.songsData[i].name, "bold")
			songText.data = self.songsData[i]

			local icon = HealthIcon(self.songsData[i].icon)
			icon:updateHitbox()

			if songText:getWidth() > 980 then
				local textScale = 980 / songText:getWidth()
				songText.origin.x = 0
				songText.scale.x = textScale
			end

			self.songs:add(songText, icon)
		end
	end

	self.scoreText = Text(game.width * 0.7, 5, "", paths.getFont("vcr.ttf", 32),
		Color.WHITE, "right")
	self.scoreText.antialiasing = false

	self.scoreBG = Graphic(self.scoreText.x - 6, 0, 1, 66, Color.BLACK)
	self.scoreBG.alpha = 0.6
	self:add(self.scoreBG)

	self.diffText = Text(self.scoreText.x, self.scoreText.y + 36, "DIFFICULTY",
		paths.getFont("vcr.ttf", 24))
	self.diffText.antialiasing = false
	self:add(self.diffText)
	self:add(self.scoreText)

	if love.system.getDevice() == "Mobile" then
		self.buttons = VirtualPadGroup()
		local w = 134

		local left = VirtualPad("left", 0, game.height - w)
		local up = VirtualPad("up", left.x + w, left.y - w)
		local down = VirtualPad("down", up.x, left.y)
		local right = VirtualPad("right", down.x + w, left.y)

		local enter = VirtualPad("return", game.width - w, left.y)
		enter.color = Color.GREEN
		local back = VirtualPad("escape", enter.x - w, left.y)
		back.color = Color.RED

		self.buttons:add(left)
		self.buttons:add(up)
		self.buttons:add(down)
		self.buttons:add(right)

		self.buttons:add(enter)
		self.buttons:add(back)

		self:add(self.buttons)
	end

	self.throttles = {}
	self.throttles.left = Throttle:make({controls.down, controls, "ui_left"})
	self.throttles.right = Throttle:make({controls.down, controls, "ui_right"})

	if #self.songsData > 0 then
		self.songs.curSelected = math.min(#self.songsData, self.songs.curSelected)
		self.songs:changeSelection()

		self.bg.color = Color.fromString(self.songsData[self.songs.curSelected].color)
	end

	FreeplayState.super.enter(self)

	self.script:call("postCreate")
end

function FreeplayState:openSong(song)
	if not self.selected then
		self.selected = true
		if #self.songsData > 0 then
			if controls:pressed('accept') then
				PlayState.storyMode = false
				local diff = song.data.difficulties[FreeplayState.curDifficulty]

				if game.keys.pressed.SHIFT then
					PlayState.loadSong(song.data.name, diff)
					PlayState.storyDifficulty = diff
					game.switchState(ChartingState())
				else
					game.switchState(PlayState(false, song.data.name, diff))
				end
			end
		end
	end
end

function FreeplayState:update(dt)
	self.script:call("update", dt)
	if self.notCreated then
		FreeplayState.super.update(self, dt)
		self.script:call("postUpdate")
		return
	end

	self.lerpScore = util.coolLerp(self.lerpScore, self.intendedScore, 24, dt)
	if math.abs(self.lerpScore - self.intendedScore) <= 10 then
		self.lerpScore = self.intendedScore
	end
	self.scoreText.content = "PERSONAL BEST: " .. math.floor(self.lerpScore)

	self:positionHighscore()

	if not self.selected then
		if #self.songsData > 0 and self.throttles then
			if self.throttles.left:check() then self:changeDiff(-1) end
			if self.throttles.right:check() then self:changeDiff(1) end
		end
		if controls:pressed("back") then
			util.playSfx(paths.getSound('cancelMenu'))
			self.selected = true
			game.switchState(MainMenuState())
		end
	end

	if #self.songsData > 0 then
		local colorBG = Color.fromString(self.songsData[self.songs.curSelected].color)
		self.bg.color = Color.lerpDelta(self.bg.color, colorBG, 3, dt)
	end
	FreeplayState.super.update(self, dt)

	self.script:call("postUpdate", dt)
end

function FreeplayState:closeSubstate()
	self.selected = false
	FreeplayState.super.closeSubstate(self)
end

function FreeplayState:changeDiff(change)
	if change == nil then change = 0 end
	local songDiffs = self.songsData[self.songs.curSelected].difficulties

	FreeplayState.curDifficulty = FreeplayState.curDifficulty + change
	FreeplayState.curDifficulty = (FreeplayState.curDifficulty - 1) % #songDiffs + 1

	self.intendedScore = Highscore.getScore(self.songsData[self.songs.curSelected].name,
		songDiffs[FreeplayState.curDifficulty])

	if #songDiffs > 1 then
		self.diffText.content = "< " ..
			songDiffs[FreeplayState.curDifficulty]:upper() ..
			" >"
	else
		self.diffText.content = songDiffs[FreeplayState.curDifficulty]:upper()
	end
	self:positionHighscore()
end

function FreeplayState:changeSelection(change) self:changeDiff(0) end

function FreeplayState:positionHighscore()
	self.scoreText.x = game.width - self.scoreText:getWidth() - 6
	self.scoreBG.width = self.scoreText:getWidth() + 12
	self.scoreBG.x = self.scoreText.x - 6
	self.diffText.x = math.floor(self.scoreBG.x + (self.scoreBG.width - self.diffText:getWidth()) / 2)
end

local function getSongMetadata(song)
	local song_metadata = paths.getJSON(
		'songs/' .. paths.formatToSongPath(song) ..
		'/meta')
	if song_metadata == nil then
		song_metadata = {}
	end
	return {
		name = song_metadata.name or song,
		icon = song_metadata.icon or 'face',
		color = song_metadata.color or '#0F0F0F',
		difficulties = song_metadata.difficulties or
			{'Easy', PlayState.defaultDifficulty, 'Hard'}
	}
end

function FreeplayState:loadSongs()
	local listData, func = nil, Mods.currentMod and paths.getMods or function(...)
		return paths.getPath(..., false)
	end
	if paths.exists(func('data/freeplayList.txt'), 'file') then
		listData = paths.getText('freeplayList')
	elseif paths.exists(func('data/freeplaySonglist.txt'), 'file') then
		listData = paths.getText('freeplaySonglist')
	else
		if paths.exists(func('data/weekList.txt'), 'file') then
			listData = paths.getText('weekList'):gsub('\r', ''):split(
				'\n')
			for _, week in pairs(listData) do
				local weekData = paths.getJSON('data/weeks/weeks/' .. week)
				if not weekData.hide_fm then
					for _, song in ipairs(weekData.songs) do
						table.insert(self.songsData, getSongMetadata(song))
					end
				end
			end
		else
			for _, str in pairs(love.filesystem.getDirectoryItems(func('data/weeks/weeks'))) do
				local weekName = str:withoutExt()
				if str:endsWith('.json') then
					local weekData = paths.getJSON(
						'data/weeks/weeks/' .. weekName)
					if not weekData.hide_fm then
						for _, song in ipairs(weekData.songs) do
							table.insert(self.songsData, getSongMetadata(song))
						end
					end
				end
			end
		end
		return
	end
	listData = listData:gsub('\r', ''):split('\n')
	for _, song in pairs(listData) do
		table.insert(self.songsData, getSongMetadata(song))
	end
end

function FreeplayState:leave()
	self.script:call("leave")
	if self.notCreated then
		self.script:call("postLeave")
		return
	end

	for _, v in ipairs(self.throttles) do v:destroy() end
	self.throttles = nil

	self.script:call("postLeave")
end

return FreeplayState
