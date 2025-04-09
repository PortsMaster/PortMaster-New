local Events = require "funkin.backend.scripting.events"
local PauseSubstate = require "funkin.substates.pause"
--[[ LIST TODO OR NOTES
	- ralty
	maybe make scripts vars just include conductor itself instead of the properties of conductor
	NVM NVM, maybe do make a var conductor but keep props

	rewrite timers. to just be dependancy to loxel,. just rewrite timers with new codes.

	- kaoy
	remake stuff like cameramove to be handled by events. also uuh do it softcoded mayb
]]

---@class PlayState:State
local PlayState = State:extend("PlayState")
PlayState.defaultDifficulty = "normal"

PlayState.inputDirections = {
	note_left = 0,
	note_down = 1,
	note_up = 2,
	note_right = 3
}
PlayState.keysControls = {}
for control, key in pairs(PlayState.inputDirections) do
	PlayState.keysControls[key] = control
end

PlayState.SONG = nil
PlayState.songDifficulty = ""

PlayState.storyPlaylist = {}
PlayState.storyMode = false
PlayState.storyWeek = ""
PlayState.storyScore = 0
PlayState.storyWeekFile = ""

PlayState.seenCutscene = false

PlayState.prevCamFollow = nil

-- Charting Stuff
PlayState.chartingMode = false
PlayState.startPos = 0

function PlayState.loadSong(song, diff)
	diff = diff or PlayState.defaultDifficulty
	PlayState.songDifficulty = diff

	PlayState.SONG = API.chart.parse(song, diff)

	return true
end

function PlayState:new(storyMode, song, diff)
	PlayState.super.new(self)

	if storyMode ~= nil then
		PlayState.storyMode = storyMode
		PlayState.storyWeek = ""
	end

	if song ~= nil then
		if storyMode and type(song) == "table" and #song > 0 then
			PlayState.storyPlaylist = song
			song = song[1]
		end
		if not PlayState.loadSong(song, diff) then
			setmetatable(self, TitleState)
			TitleState.new(self)
		end
	end
end

function PlayState:enter()
	if PlayState.SONG == nil then PlayState.loadSong("test") end
	PlayState.SONG.skin = util.getSongSkin(PlayState.SONG)

	local songName = paths.formatToSongPath(PlayState.SONG.song)

	local conductor = Conductor():setSong(PlayState.SONG)
	conductor.time = self.startPos - conductor.crotchet * 5
	conductor.onStep = bind(self, self.step)
	conductor.onBeat = bind(self, self.beat)
	conductor.onSection = bind(self, self.section)
	PlayState.conductor = conductor

	self.skipConductor = false

	Note.defaultSustainSegments = 3
	NoteModifier.reset()

	self.timer = Timer.new()
	self.camPosTween = nil

	self.scripts = ScriptsHandler()
	self.scripts:loadDirectory("data/scripts", "data/scripts/" .. songName, "songs/" .. songName)

	self.events = table.clone(PlayState.SONG.events)
	self.eventScripts = {}
	for _, e in ipairs(self.events) do
		local scriptPath = "data/events/" .. e.e:gsub(" ", "-"):lower()
		if not self.eventScripts[e.e] then
			self.eventScripts[e.e] = Script(scriptPath)
			self.eventScripts[e.e].belongsTo = e.e
			self.scripts:add(self.eventScripts[e.e])
		end
	end

	if Discord then self:updateDiscordRPC() end

	self.startingSong = true
	self.startedCountdown = false
	self.doCountdownAtBeats = nil
	self.lastCountdownBeats = nil

	self.isDead = false
	GameOverSubstate.resetVars()

	self.usedBotPlay = ClientPrefs.data.botplayMode
	self.downScroll = ClientPrefs.data.downScroll
	self.middleScroll = ClientPrefs.data.middleScroll
	self.playback = 1
	Timer.setSpeed(1)

	self.scripts:set("bpm", PlayState.conductor.bpm)
	self.scripts:set("crotchet", PlayState.conductor.crotchet)
	self.scripts:set("stepCrotchet", PlayState.conductor.stepCrotchet)

	self.scripts:call("create")

	self.camNotes = Camera() --Camera will be changed to ActorCamera once that class is done
	self.camHUD = Camera()
	self.camOther = Camera()
	game.cameras.add(self.camHUD, false)
	game.cameras.add(self.camNotes, false)
	game.cameras.add(self.camOther, false)

	self.camHUD.bgColor[4] = ClientPrefs.data.backgroundDim / 100

	if game.sound.music then game.sound.music:reset(true) end
	game.sound.loadMusic(paths.getInst(songName))
	game.sound.music:setLooping(false)
	game.sound.music:setVolume(ClientPrefs.data.musicVolume / 100)
	game.sound.music.onComplete = function() self:endSong() end

	self.stage = Stage(PlayState.SONG.stage)
	self:add(self.stage)
	self.scripts:add(self.stage.script)

	if PlayState.SONG.gfVersion ~= "" then
		self.gf = Character(self.stage.gfPos.x, self.stage.gfPos.y,
			PlayState.SONG.gfVersion, false)
		self.gf:setScrollFactor(0.95, 0.95)
		self:add(self.gf)
		self.scripts:add(self.gf.script)
	end

	if PlayState.SONG.player2 ~= "" then
		self.dad = Character(self.stage.dadPos.x, self.stage.dadPos.y,
			PlayState.SONG.player2, false)
		self:add(self.dad)
		self.scripts:add(self.dad.script)
	end

	if PlayState.SONG.player1 ~= "" then
		self.boyfriend = Character(self.stage.boyfriendPos.x,
			self.stage.boyfriendPos.y, PlayState.SONG.player1,
			true)
		self.boyfriend.waitReleaseAfterSing = not ClientPrefs.data.botplayMode
		self:add(self.boyfriend)
		self.scripts:add(self.boyfriend.script)
	end

	if self.gf and PlayState.SONG.player2:startsWith("gf") then
		self.gf.visible = false
		self.dad:setPosition(self.gf.x, self.gf.y)
	end

	self:add(self.stage.foreground)

	self.judgeSprites = Judgements(game.width / 3, 264, PlayState.SONG.skin)
	self:add(self.judgeSprites)

	game.camera.zoom, self.camZoom, self.camZooming,
	self.camZoomSpeed, self.camSpeed, self.camTarget =
		self.stage.camZoom, self.stage.camZoom, true,
		self.stage.camZoomSpeed, self.stage.camSpeed
	if PlayState.prevCamFollow then
		self.camFollow = PlayState.prevCamFollow
		PlayState.prevCamFollow = nil
	else
		self.camFollow = {
			x = 0,
			y = 0,
			tweening = false,
			set = function(this, x, y)
				this.x = x
				this.y = y
			end
		}
	end

	local playerVocals, enemyVocals, volume =
		paths.getVoices(songName, PlayState.SONG.player1, true)
		or paths.getVoices(songName, "Player", true)
		or paths.getVoices(songName, nil, true),
		paths.getVoices(songName, PlayState.SONG.player2, true)
		or paths.getVoices(songName, "Opponent", true),
		ClientPrefs.data.vocalVolume / 100
	if playerVocals then
		playerVocals = game.sound.load(playerVocals)
		playerVocals:setVolume(volume)
	end
	if enemyVocals then
		enemyVocals = game.sound.load(enemyVocals)
		enemyVocals:setVolume(volume)
	end
	local y, keys, volume = game.height / 2, 4, ClientPrefs.data.vocalVolume / 100
	self.playerNotefield = Notefield(0, y, keys, PlayState.SONG.skin,
		self.boyfriend, playerVocals, PlayState.SONG.speed)
	self.enemyNotefield = Notefield(0, y, keys, PlayState.SONG.skin,
		self.dad, enemyVocals, PlayState.SONG.speed)
	self.playerNotefield.bot, self.enemyNotefield.bot,
	self.enemyNotefield.canSpawnSplash = ClientPrefs.data.botplayMode, true, false
	self.playerNotefield.cameras, self.enemyNotefield.cameras = {self.camNotes}, {self.camNotes}
	self.notefields = {self.playerNotefield, self.enemyNotefield, {character = self.gf}}
	self:positionNotefields()

	for _, n in ipairs(PlayState.SONG.notes.enemy) do
		self:generateNote(self.enemyNotefield, n)
	end
	for _, n in ipairs(PlayState.SONG.notes.player) do
		self:generateNote(self.playerNotefield, n)
	end
	self:add(self.enemyNotefield)
	self:add(self.playerNotefield)

	local notefield
	for i, event in ipairs(self.events) do
		if event.t > 10 then
			break
		elseif event.e == "FocusCamera" then
			self:executeEvent(event)
			table.remove(self.events, i)
			break
		end
	end

	self.countdown = Countdown()
	self.countdown:screenCenter()
	self:add(self.countdown)

	local isPixel = PlayState.SONG.skin:endsWith("-pixel")
	local event = self.scripts:event("onCountdownCreation",
		Events.CountdownCreation({}, isPixel and {x = 7, y = 7} or {x = 1, y = 1}, not isPixel))
	if not event.cancelled then
		self.countdown.data = #event.data == 0 and {
			{
				sound = util.getSkinPath(PlayState.SONG.skin, "intro3", "sound"),
			},
			{
				sound = util.getSkinPath(PlayState.SONG.skin, "intro2", "sound"),
				image = util.getSkinPath(PlayState.SONG.skin, "ready", "image")
			},
			{
				sound = util.getSkinPath(PlayState.SONG.skin, "intro1", "sound"),
				image = util.getSkinPath(PlayState.SONG.skin, "set", "image")
			},
			{
				sound = util.getSkinPath(PlayState.SONG.skin, "introGo", "sound"),
				image = util.getSkinPath(PlayState.SONG.skin, "go", "image")
			}
		} or event.data
		self.countdown.scale = event.scale
		self.countdown.antialiasing = event.antialiasing
	end

	self.healthBar = HealthBar(self.boyfriend, self.dad)
	self.healthBar:screenCenter("x").y = game.height * 0.9
	self:add(self.healthBar)

	local fontScore = paths.getFont("vcr.ttf", 24)
	self.scoreText = Text(0, 0, "", fontScore, Color.WHITE, "right")
	self.scoreText.outline.width = 1
	self.scoreText.antialiasing = false
	self:add(self.scoreText)

	self.botplayText = Text(0, 0, "BOTPLAY", fontScore, Color.WHITE)
	self.botplayText.outline.width = 1
	self.botplayText.antialiasing = false
	self.botplayText.visible = self.usedBotPlay
	self:add(self.botplayText)

	for _, o in ipairs({
		self.judgeSprites, self.countdown, self.healthBar, self.scoreText, self.botplayText
	}) do o.cameras = {self.camHUD} end

	self.score = 0
	self.combo = 0
	self.misses = 0
	self.health = 1

	self.ratings = {
		{name = "perfect", time = 0.0125, score = 400, splash = true,  mod = 1},
		{name = "sick",    time = 0.045,  score = 350, splash = true,  mod = 0.98},
		{name = "good",    time = 0.090,  score = 200, splash = false, mod = 0.7},
		{name = "bad",     time = 0.135,  score = 100, splash = false, mod = 0.4},
		{name = "shit",    time = -1,     score = 50,  splash = false, mod = 0.2}
	}
	for _, r in ipairs(self.ratings) do
		self[r.name .. "s"] = 0
	end

	if love.system.getDevice() == "Mobile" then
		local w, h = game.width / 4, game.height

		self.buttons = VirtualPadGroup()

		local left = VirtualPad("left", 0, 0, w, h, Color.PURPLE)
		local down = VirtualPad("down", w, 0, w, h, Color.BLUE)
		local up = VirtualPad("up", w * 2, 0, w, h, Color.GREEN)
		local right = VirtualPad("right", w * 3, 0, w, h, Color.RED)

		self.buttons:add(left)
		self.buttons:add(down)
		self.buttons:add(up)
		self.buttons:add(right)
		self.buttons:set({
			fill = "line",
			lined = false,
			blend = "add",
			releasedAlpha = 0,
			cameras = {self.camOther},
			config = {round = {0, 0}}
		})
	end

	if self.buttons then
		self:add(self.buttons); self.buttons:disable()
	end

	self.lastTick = love.timer.getTime()

	self.bindedKeyPress = bind(self, self.onKeyPress)
	controls:bindPress(self.bindedKeyPress)

	self.bindedKeyRelease = bind(self, self.onKeyRelease)
	controls:bindRelease(self.bindedKeyRelease)

	if self.downScroll then
		for _, notefield in ipairs(self.notefields) do
			if notefield.is then notefield.downscroll = true end
		end
		self.healthBar.y = -self.healthBar.y + self.healthBar.offset.y * 2 +
			(game.height - self.healthBar:getHeight())
	end
	self:positionText()

	if self.storyMode and not PlayState.seenCutscene then
		PlayState.seenCutscene = true

		local fileExist, cutsceneType
		for i, path in ipairs({
			paths.getMods('data/cutscenes/' .. songName .. '.lua'),
			paths.getMods('data/cutscenes/' .. songName .. '.json'),
			paths.getPath('data/cutscenes/' .. songName .. '.lua'),
			paths.getPath('data/cutscenes/' .. songName .. '.json')
		}) do
			if paths.exists(path, 'file') then
				fileExist = true
				switch(path:ext(), {
					["lua"] = function() cutsceneType = "script" end,
					["json"] = function() cutsceneType = "data" end,
				})
			end
		end
		if fileExist then
			switch(cutsceneType, {
				["script"] = function()
					local cutsceneScript = Script('data/cutscenes/' .. songName)

					cutsceneScript:call("create")
					self.scripts:add(cutsceneScript)
				end,
				["data"] = function()
					local cutsceneData = paths.getJSON('data/cutscenes/' .. songName)

					for i, event in ipairs(cutsceneData.cutscene) do
						self.timer:after(event.time / 1000, function()
							self:executeCutsceneEvent(event.event)
						end)
					end
				end
			})
		else
			self:startCountdown()
		end
	else
		self:startCountdown()
	end
	self:recalculateRating()

	-- PRELOAD STUFF TO GET RID OF THE FATASS LAGS!!
	local path = "skins/" .. PlayState.SONG.skin .. "/"
	for _, r in ipairs(self.ratings) do paths.getImage(path .. r.name) end
	for _, num in ipairs({"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "negative"}) do
		paths.getImage(path .. "num" .. num)
	end
	local sprite
	for i, part in pairs(paths.getSkin(PlayState.SONG.skin)) do
		sprite = part.sprite
		if sprite then paths.getImage(path .. sprite) end
	end
	if ClientPrefs.data.hitSound > 0 then paths.getSound("hitsound") end

	self.__stickers = Stickers()
	self:add(self.__stickers)

	PlayState.super.enter(self)
	collectgarbage()

	self.scripts:call("postCreate")

	game.camera:follow(self.camFollow, nil, 2.4 * self.camSpeed)
	game.camera:snapToTarget()
end

function PlayState:positionNotefields()
	if self.middleScroll then
		self.playerNotefield:screenCenter("x")

		for _, notefield in ipairs(self.notefields) do
			if notefield.is and notefield ~= self.playerNotefield then
				notefield.visible = false
			end
		end
	else
		local baseX = 44
		self.playerNotefield.x = game.width / 2 + baseX
		self.enemyNotefield.x = baseX

		for _, notefield in ipairs(self.notefields) do
			if notefield.is then notefield.visible = true end
		end
	end
end

function PlayState:positionText()
	self.scoreText.x, self.scoreText.y = self.healthBar.x + self.healthBar.bg.width - 190, self.healthBar.y + 30
	self.botplayText.x, self.botplayText.y = game.width - self.botplayText:getWidth() - 36, self.scoreText.y
end

function PlayState:getRating(a, b)
	local diff = math.abs(a - b)
	for _, r in ipairs(self.ratings) do
		if diff <= (r.time < 0 and Note.safeZoneOffset or r.time) then return r end
	end
end

function PlayState:generateNote(notefield, n)
	if n.t >= PlayState.startPos then
		local sustainTime = n.l or 0
		if sustainTime > 0 then
			sustainTime = math.max(sustainTime / 1000, 0.125)
		end
		local note = notefield:makeNote(n.t / 1000, n.d % 4, sustainTime, n.k)
		if n.gf then note.character = self.gf end
	end
end

function PlayState:startCountdown()
	if self.buttons then self:add(self.buttons) end

	local event = self.scripts:call("startCountdown")
	if event == Script.Event_Cancel then return end

	self.playback = ClientPrefs.data.playback
	Timer.setSpeed(self.playback)

	local vocals
	for _, notefield in ipairs(self.notefields) do
		vocals = notefield.vocals
		if vocals then vocals:setPitch(self.playback) end
	end
	game.sound.music:setPitch(self.playback)

	self.startedCountdown = true
	self.doCountdownAtBeats = PlayState.startPos / PlayState.conductor.crotchet - 4

	self.countdown.duration = PlayState.conductor.crotchet / 1000
	self.countdown.playback = 1
end

function PlayState:getCameraPosition(char)
	local camX, camY = char:getMidpoint()
	if char == self.gf then
		camX, camY = camX - char.cameraPosition.x + self.stage.gfCam.x,
			camY - char.cameraPosition.y + self.stage.gfCam.y
	elseif char.isPlayer then
		camX, camY = camX - 100 - char.cameraPosition.x + self.stage.boyfriendCam.x,
			camY - 100 + char.cameraPosition.y + self.stage.boyfriendCam.y
	else
		camX, camY = camX + 150 + char.cameraPosition.x + self.stage.dadCam.x,
			camY - 100 + char.cameraPosition.y + self.stage.dadCam.y
	end
	return camX, camY
end

function PlayState:cameraMovement(ox, oy, ease, time)
	local event = self.scripts:event("onCameraMove", Events.CameraMove(self.camTarget))
	local camX, camY = (ox or 0) + event.offset.x, (oy or 0) + event.offset.y
	if self.camPosTween then
		self.timer:cancel(self.camPosTween)
	end
	if ease then
		if game.camera.followLerp then
			game.camera:follow(self.camFollow, nil)
		end
		self.camPosTween =
			self.timer:tween(time, self.camFollow, {x = camX, y = camY}, ease, function()
				self.camFollow.tweening = false
			end)
	else
		if not game.camera.followLerp then
			game.camera:follow(self.camFollow, nil, 2.4 * self.camSpeed)
		end
		self.camPosTween = nil
		self.camFollow:set(camX, camY)
	end
end

function PlayState:step(s)
	if self.skipConductor then return end

	if not self.startingSong then
		local time, rate = game.sound.music:tell(), math.max(self.playback, 1)
		if math.abs(time - PlayState.conductor.time / 1000) > 0.015 * rate then
			PlayState.conductor.time = time * 1000
		end
		local maxDelay, vocals = 0.0088 * rate
		for _, notefield in ipairs(self.notefields) do
			vocals = notefield.vocals
			if vocals and vocals:isPlaying()
				and math.abs(time - vocals:tell()) > maxDelay then
				vocals:seek(time)
			end
		end

		if Discord then
			coroutine.wrap(PlayState.updateDiscordRPC)(self)
		end
	end

	self.scripts:set("curStep", s)
	self.scripts:call("step", s)
	self.scripts:call("postStep", s)
end

function PlayState:beat(b)
	if self.skipConductor then return end

	self.scripts:set("curBeat", b)
	self.scripts:call("beat", b)

	local character
	for _, notefield in ipairs(self.notefields) do
		character = notefield.character
		if character then character:beat(b) end
	end

	local val, healthBar = 1.2, self.healthBar
	healthBar.iconScale = val
	healthBar.iconP1:setScale(val)
	healthBar.iconP2:setScale(val)

	self.scripts:call("postBeat", b)
end

function PlayState:section(s)
	if self.skipConductor then return end

	self.scripts:set("curSection", s)
	self.scripts:call("section", s)

	self.scripts:set("bpm", PlayState.conductor.bpm)
	self.scripts:set("crotchet", PlayState.conductor.crotchet)
	self.scripts:set("stepCrotchet", PlayState.conductor.stepCrotchet)

	if self.camZooming and game.camera.zoom < 1.35 then
		game.camera.zoom = game.camera.zoom + 0.015
		self.camHUD.zoom = self.camHUD.zoom + 0.03
	end

	self.scripts:call("postSection", s)
end

function PlayState:focus(f)
	self.scripts:call("focus", f)
	if Discord and love.autoPause then self:updateDiscordRPC(not f) end
	self.scripts:call("postFocus", f)
end

function PlayState:executeEvent(event)
	for _, s in pairs(self.eventScripts) do
		if s.belongsTo == event.e then s:call("event", event) end
	end
end

function PlayState:executeCutsceneEvent(event, isEnd)
	switch(event.name, {
		['Camera Position'] = function()
			local xCam, yCam = event.params[1], event.params[2]
			local isTweening = event.params[3]
			local time = event.params[4]
			local ease = event.params[6] .. '-' .. event.params[5]
			if isTweening then
				game.camera:follow(self.camFollow, nil)
				self.timer:tween(time, self.camFollow, {x = xCam, y = yCam}, ease)
			else
				self.camFollow:set(xCam, yCam)
				game.camera:follow(self.camFollow, nil, 2.4 * self.camSpeed)
			end
		end,
		['Camera Zoom'] = function()
			local zoomCam = event.params[1]
			local isTweening = event.params[2]
			local time = event.params[3]
			local ease = event.params[5] .. '-' .. event.params[4]
			if isTweening then
				self.timer:tween(time, game.camera, {zoom = zoomCam}, ease)
			else
				game.camera.zoom = zoomCam
			end
		end,
		['Play Sound'] = function()
			local soundPath = event.params[1]
			local volume = event.params[2]
			local isFading = event.params[3]
			local time = event.params[4]
			local volStart, volEnd = event.params[5], event.params[6]

			local sound = game.sound.play(paths.getSound(soundPath), volume)
			if isFading then sound:fade(time, volStart, volEnd) end
		end,
		['Play Animation'] = function()
			local character = nil
			switch(event.params[1], {
				['bf'] = function() character = self.boyfriend end,
				['gf'] = function() character = self.gf end,
				['dad'] = function() character = self.dad end
			})
			local animation = event.params[2]

			if character then character:playAnim(animation, true) end
		end,
		['End Cutscene'] = function()
			game.camera:follow(self.camFollow, nil, 2.4 * self.camSpeed)
			if isEnd then
				self:endSong(true)
			else
				local skipCountdown = event.params[1]
				if skipCountdown then
					PlayState.conductor.time = 0
					self.startedCountdown = true
					if self.buttons then self:add(self.buttons) end
				else
					self:startCountdown()
				end
			end
		end,
	})
end

function PlayState:doCountdown(beat)
	if self.lastCountdownBeats == beat then return end
	self.lastCountdownBeats = beat

	if beat > #self.countdown.data then
		self.doCountdownAtBeats = nil
	else
		self.countdown:doCountdown(beat)
	end
end

function PlayState:resetStroke(notefield, dir, doPress)
	local receptor = notefield.receptors[dir + 1]
	if receptor then
		receptor:play((doPress and not notefield.bot)
			and "pressed" or "static")
	end
end

function PlayState:update(dt)
	dt = dt * self.playback
	self.lastTick = love.timer.getTime()
	self.timer:update(dt)

	if self.startedCountdown then
		PlayState.conductor.time = PlayState.conductor.time + dt * 1000

		if self.startingSong and PlayState.conductor.time >= self.startPos then
			self.startingSong = false

			-- reload playback for countdown skip
			self.playback = ClientPrefs.data.playback
			Timer.setSpeed(self.playback)

			local time, vocals = self.startPos / 1000
			game.sound.music:setPitch(self.playback)
			game.sound.music:seek(time)
			for _, notefield in ipairs(self.notefields) do
				vocals = notefield.vocals
				if vocals then
					vocals:setPitch(self.playback)
					vocals:seek(time)
					vocals:play()
				end
			end
			game.sound.music:play()

			self:section(0)
			self.scripts:call("songStart")
		else
			local noFocus, events, e = true, self.events
			while events[1] do
				e = events[1]
				if e.t <= PlayState.conductor.time then
					self:executeEvent(e)
					table.remove(events, 1)
					if e.e == "FocusCamera" then noFocus = false end
				else
					break
				end
			end
			if noFocus and self.camTarget and game.camera.followLerp then
				self:cameraMovement(self:getCameraPosition(self.camTarget))
			end
		end

		PlayState.conductor:update()
		if self.skipConductor then self.skipConductor = false end

		if self.startingSong and self.doCountdownAtBeats then
			self:doCountdown(math.floor(
				PlayState.conductor.currentBeatFloat - self.doCountdownAtBeats + 1
			))
		end
	end

	local time = PlayState.conductor.time / 1000
	local missOffset = time - Note.safeZoneOffset / 1.25
	for _, notefield in ipairs(self.notefields) do
		if notefield.is then
			notefield.time, notefield.beat = time, PlayState.conductor.currentBeatFloat

			local isPlayer, sustainHitOffset, noSustainHit, sustainTime,
			noteTime, lastPress, dir, fullyHeldSustain, char, hasInput, resetVolume =
				not notefield.bot, 0.25 / notefield.speed
			for _, note in ipairs(notefield:getNotes(time, nil, true)) do
				noteTime, lastPress, dir, noSustainHit, char =
					note.time, note.lastPress, note.direction,
					not note.wasGoodSustainHit, note.character or notefield.character
				hasInput = not isPlayer or controls:down(PlayState.keysControls[dir])

				if note.wasGoodHit then
					sustainTime = note.sustainTime

					if hasInput then
						-- sustain hitting
						note.lastPress = time
						lastPress = time
						resetVolume = true
					else
						lastPress = note.lastPress
					end

					if not note.wasGoodSustainHit and lastPress ~= nil then
						if noteTime + sustainTime - sustainHitOffset <= lastPress then
							-- end of sustain hit
							fullyHeldSustain = noteTime + sustainTime <= lastPress
							if fullyHeldSustain or not hasInput then
								self:goodSustainHit(note, time, fullyHeldSustain)
								noSustainHit = false
							end
						elseif not hasInput and isPlayer and noteTime <= time then
							-- early end of sustain hit (no full score)
							self:goodSustainHit(note, time)
							noSustainHit, note.tooLate = false, true
						end
					end

					if noSustainHit and hasInput and char then
						char.lastHit = PlayState.conductor.time
					end
				elseif isPlayer then
					if noSustainHit
						and (lastPress or noteTime) <= missOffset then
						-- miss note
						self:miss(note)
					end
				elseif noteTime <= time then
					-- botplay hit
					self:goodNoteHit(note, time)
				end
			end

			if resetVolume then
				local vocals = notefield.vocals or self.playerNotefield.vocals
				if vocals then vocals:setVolume(ClientPrefs.data.vocalVolume / 100) end
			end
		end
	end

	self.scripts:call("update", dt)
	PlayState.super.update(self, dt)

	if self.camZooming then
		game.camera.zoom = util.coolLerp(game.camera.zoom, self.camZoom, 3, dt * self.camZoomSpeed)
		self.camHUD.zoom = util.coolLerp(self.camHUD.zoom, 1, 3, dt * self.camZoomSpeed)
	end
	self.camNotes.zoom = self.camHUD.zoom

	self.healthBar.value = util.coolLerp(self.healthBar.value, self.health, 15, dt)
	if not self.isDead and self.healthBar.value <= 0 then self:tryGameOver() end

	if self.startedCountdown then
		if (self.buttons and game.keys.justPressed.ESCAPE) or controls:pressed("pause") then
			self:tryPause()
		end

		if controls:pressed("debug_1") then
			game.camera:unfollow()
			game.sound.music:pause()
			local vocals
			for _, notefield in ipairs(self.notefields) do
				vocals = notefield.vocals
				if vocals then vocals:pause() end
			end
			game.switchState(ChartingState())
		end

		if controls:pressed("debug_2") then
			game.camera:unfollow()
			game.sound.music:pause()
			local vocals
			for _, notefield in ipairs(self.notefields) do
				vocals = notefield.vocals
				if vocals then vocals:pause() end
			end
			CharacterEditor.onPlayState = true
			game.switchState(CharacterEditor())
		end

		if not self.isDead and controls:pressed("reset") then self:tryGameOver() end
	end

	if Project.DEBUG_MODE then
		if game.keys.justPressed.ONE then self.playerNotefield.bot = not self.playerNotefield.bot end
		if game.keys.justPressed.TWO then self:endSong() end
		if game.keys.justPressed.THREE then
			local time, vocals = (PlayState.conductor.time +
				PlayState.conductor.crotchet * (game.keys.pressed.SHIFT and 8 or 4)) / 1000
			self.skipConductor, PlayState.conductor.time = true, time * 1000
			game.sound.music:seek(time)
			for _, notefield in ipairs(self.notefields) do
				vocals = notefield.vocals
				if vocals then vocals:seek(time) end
			end
		end
	end

	self.scripts:call("postUpdate", dt)
end

function PlayState:draw()
	self.scripts:call("draw")
	PlayState.super.draw(self)
	self.scripts:call("postDraw")
end

function PlayState:onSettingChange(category, setting)
	game.camera.freezed = false
	self.camNotes.freezed = false
	self.camHUD.freezed = false

	if category == "gameplay" then
		switch(setting, {
			["downScroll"] = function()
				local downscroll = ClientPrefs.data.downScroll
				for _, notefield in ipairs(self.notefields) do
					if notefield.is then notefield.downscroll = downscroll end
				end
				if downscroll ~= self.downScroll then
					if downscroll then
						self.healthBar.y = -self.healthBar.y + self.healthBar.offset.y * 2 +
							(game.height - self.healthBar:getHeight())
					else
						self.healthBar.y = self.healthBar.offset.y * 2 + game.height -
							(self.healthBar.y + self.healthBar:getHeight())
					end
				end
				self:positionText()
				self.downScroll = downscroll
			end,
			["middleScroll"] = function()
				self.middleScroll = ClientPrefs.data.middleScroll
				self:positionNotefields()
			end,
			["botplayMode"] = function()
				self.boyfriend.waitReleaseAfterSing = not ClientPrefs.data.botplayMode
				self.playerNotefield.bot = ClientPrefs.data.botplayMode
				self.botplayText.visible = ClientPrefs.data.botplayMode
			end,
			["backgroundDim"] = function()
				self.camHUD.bgColor[4] = ClientPrefs.data.backgroundDim / 100
			end,
			["playback"] = function()
				self.playback = ClientPrefs.data.playback
				Timer.setSpeed(self.playback)
				game.sound.music:setPitch(self.playback)
				local vocals
				for _, notefield in ipairs(self.notefields) do
					vocals = notefield.vocals
					if vocals then vocals:setPitch(self.playback) end
				end
			end
		})

		game.sound.music:setVolume(ClientPrefs.data.musicVolume / 100)
		local volume, vocals = ClientPrefs.data.vocalVolume / 100
		for _, notefield in ipairs(self.notefields) do
			vocals = notefield.vocals
			if vocals then vocals:setVolume(volume) end
		end
	elseif category == "controls" then
		controls:unbindPress(self.bindedKeyPress)
		controls:unbindRelease(self.bindedKeyRelease)

		self.bindedKeyPress = bind(self, self.onKeyPress)
		controls:bindPress(self.bindedKeyPress)

		self.bindedKeyRelease = bind(self, self.onKeyRelease)
		controls:bindRelease(self.bindedKeyRelease)
	end

	self.scripts:call("onSettingChange", category, setting)
end

function PlayState:goodNoteHit(note, time)
	self.scripts:call("goodNoteHit", note, rating)

	local notefield, dir, isSustain =
		note.parent, note.direction, note.sustain
	local event = self.scripts:event("onNoteHit",
		Events.NoteHit(notefield, note,
			note.character or notefield.character, rating))
	if not event.cancelled and not note.wasGoodHit then
		note.wasGoodHit = true

		if event.unmuteVocals then
			local vocals = notefield.vocals or self.playerNotefield.vocals
			if vocals then vocals:setVolume(ClientPrefs.data.vocalVolume / 100) end
		end

		local char = event.character
		if char and not event.cancelledAnim then
			local lastSustain, type = notefield.lastSustain, note.type
			if type ~= "alt" then type = nil end
			if lastSustain and not isSustain
				and lastSustain.sustainTime > note.sustainTime then
				local dir = lastSustain.direction
				if char.dirAnim ~= dir then
					char:sing(dir, type, false)
				end
			else
				char:sing(dir, type)
			end
		end

		if isSustain then
			notefield.lastSustain = note
		else
			notefield:removeNote(note)
			notefield.lastSustain = nil
		end

		local rating = self:getRating(note.time, time)

		local receptor = notefield.receptors[dir + 1]
		if receptor then
			if not event.strumGlowCancelled then
				receptor:play("confirm", true)
				receptor.holdTime = not isSustain and notefield.bot and 0.15 or 0
				if ClientPrefs.data.noteSplash and notefield.canSpawnSplash and rating.splash then
					receptor:spawnSplash()
				end
			end
			if isSustain and not event.coverSpawnCancelled then
				receptor:spawnCover(note)
			end
		end

		if self.playerNotefield == notefield then
			self.health = math.min(self.health + 0.023, 2)
			self.score, self.combo = self.score + rating.score, math.max(self.combo, 0) + 1
			self:recalculateRating(rating.name)

			local hitSoundVolume = ClientPrefs.data.hitSound
			if hitSoundVolume > 0 then
				game.sound.play(paths.getSound("hitsound"), hitSoundVolume / 100)
			end
		end
	end

	self.scripts:call("postGoodNoteHit", note, rating)
end

function PlayState:goodSustainHit(note, time, fullyHeldSustain)
	self.scripts:call("goodSustainHit", note)

	local notefield, dir, fullScore =
		note.parent, note.direction, fullyHeldSustain ~= nil
	local event = self.scripts:event("onSustainHit",
		Events.NoteHit(notefield, note,
			note.character or notefield.character))
	if not event.cancelled and not note.wasGoodSustainHit then
		note.wasGoodSustainHit = true

		if notefield == self.playerNotefield then
			if fullScore then
				self.score = self.score + note.sustainTime * 1000
			else
				self.score = self.score
					+ math.min(time - note.lastPress + Note.safeZoneOffset,
						note.sustainTime) * 1000
			end
			self:recalculateRating()
		end

		if not event.cancelledAnim then
			self:resetStroke(notefield, dir, fullyHeldSustain)
		end
		if fullScore then notefield:removeNote(note) end
	end

	self.scripts:call("postGoodSustainHit", note)
end

-- dir can be nil for non-ghost-tap
function PlayState:miss(note, dir)
	local ghostMiss = dir ~= nil
	if not ghostMiss then dir = note.direction end

	local funcParam = ghostMiss and dir or note
	self.scripts:call(ghostMiss and "miss" or "noteMiss", funcParam)

	local notefield = ghostMiss and note or note.parent
	local event = self.scripts:event(ghostMiss and "onMiss" or "onNoteMiss",
		Events.Miss(notefield, dir, ghostMiss and nil or note,
			note.character or notefield.character))
	if not event.cancelled and (ghostMiss or not note.tooLate) then
		if not ghostMiss then
			note.tooLate = true
		end

		if event.muteVocals and notefield.vocals then notefield.vocals:setVolume(0) end

		if event.triggerSound then
			util.playSfx(paths.getSound("gameplay/missnote" .. love.math.random(1, 3)),
				love.math.random(1, 2) / 10)
		end

		local char = event.character
		if char and not event.cancelledAnim then char:sing(dir, "miss") end

		if notefield == self.playerNotefield then
			if self.gf and not event.cancelledSadGF and self.combo >= 10
				and self.gf.__animations.sad then
				self.gf:playAnim("sad", true)
				self.gf.lastHit = notefield.time * 1000
			end

			self.health = math.max(self.health - (ghostMiss and 0.04 or 0.0475), 0)
			self.score, self.misses, self.combo =
				self.score - 100, self.misses + 1, math.min(self.combo, 0) - 1
			self:recalculateRating()
			self:popUpScore()
		end
	end

	self.scripts:call(ghostMiss and "postMiss" or "postNoteMiss", funcParam)
end

function PlayState:recalculateRating(rating)
	self.scoreText.content = "Score: " .. util.formatNumber(math.floor(self.score))
	if rating then
		local field = rating .. "s"
		self[field] = (self[field] or 0) + 1
		self:popUpScore(rating)
	end
end

function PlayState:popUpScore(rating)
	local event = self.scripts:event('onPopUpScore', Events.PopUpScore())
	if not event.cancelled then
		self.judgeSprites.ratingVisible = not event.hideRating
		self.judgeSprites.comboNumVisible = not event.hideScore
		self.judgeSprites:spawn(rating, self.combo)
	end
end

function PlayState:tryPause()
	local event = self.scripts:call("paused")
	if event ~= Script.Event_Cancel then
		game.camera:unfollow()
		game.camera:freeze()
		self.camNotes:freeze()
		self.camHUD:freeze()

		game.sound.music:pause()
		local vocals
		for _, notefield in ipairs(self.notefields) do
			vocals = notefield.vocals
			if vocals then vocals:pause() end
		end

		self.paused = true

		if self.buttons then
			self:remove(self.buttons)
		end

		local pause = PauseSubstate()
		pause.cameras = {self.camOther}
		self:openSubstate(pause)
	end
end

function PlayState:tryGameOver()
	local event = self.scripts:event("onGameOver", Events.GameOver())
	if not event.cancelled then
		self.paused = event.pauseGame

		if event.pauseSong then
			game.sound.music:pause()
			local vocals
			for _, notefield in ipairs(self.notefields) do
				vocals = notefield.vocals
				if vocals then vocals:pause() end
			end
		end

		self.camHUD.visible, self.camNotes.visible = false, false
		self.boyfriend.visible = false

		if self.buttons then
			self:remove(self.buttons)
		end

		GameOverSubstate.characterName = event.characterName
		GameOverSubstate.deathSoundName = event.deathSoundName
		GameOverSubstate.loopSoundName = event.loopSoundName
		GameOverSubstate.endSoundName = event.endSoundName
		GameOverSubstate.deaths = GameOverSubstate.deaths + 1

		self.scripts:call("gameOverCreate")

		self:openSubstate(GameOverSubstate(self.stage.boyfriendPos.x,
			self.stage.boyfriendPos.y))
		self.isDead = true

		self.scripts:call("postGameOverCreate")
	end
end

function PlayState:getKeyFromEvent(controls)
	for _, control in pairs(controls) do
		local dir = PlayState.inputDirections[control]
		if dir ~= nil then return dir end
	end
	return -1
end

function PlayState:onKeyPress(key, type, scancode, isrepeat, time)
	if self.substate and not self.persistentUpdate then return end
	local controls = controls:getControlsFromSource(type .. ":" .. key)

	if not controls then return end
	key = self:getKeyFromEvent(controls)
	if key < 0 then return end

	local fixedKey, offset = key + 1,
		(time - self.lastTick) * game.sound.music:getActualPitch()
	for _, notefield in ipairs(self.notefields) do
		if notefield.is and not notefield.bot then
			time = notefield.time + offset
			local hitNotes, hasSustain = notefield:getNotes(time, key)
			local l = #hitNotes
			if l == 0 then
				local receptor = notefield.receptors[fixedKey]
				if receptor then
					receptor:play(hasSustain and "confirm" or "pressed")
				end
				if not hasSustain and not ClientPrefs.data.ghostTap then
					self:miss(notefield, key)
				end
			else
				-- remove stacked notes (this is dedicated to spam songs)
				local i, firstNote, note = 2, hitNotes[1]
				while i <= l do
					note = hitNotes[i]
					if note and math.abs(note.time - firstNote.time) < 0.01 then
						notefield:removeNote(note)
					else
						break
					end
					i = i + 1
				end
				self:goodNoteHit(firstNote, time)
			end
		end
	end
end

function PlayState:onKeyRelease(key, type, scancode, time)
	if self.substate and not self.persistentUpdate then return end
	local controls = controls:getControlsFromSource(type .. ":" .. key)

	if not controls then return end
	key = self:getKeyFromEvent(controls)

	if key < 0 then return end

	local fixedKey = key + 1
	for _, notefield in ipairs(self.notefields) do
		if notefield.is and not notefield.bot then
			self:resetStroke(notefield, key)
		end
	end
end

function PlayState:closeSubstate()
	self.scripts:call("substateClosed")
	PlayState.super.closeSubstate(self)

	game.camera:unfreeze()
	self.camNotes:unfreeze()
	self.camHUD:unfreeze()

	game.camera:follow(self.camFollow, nil, 2.4 * self.camSpeed)

	if not self.startingSong then
		game.sound.music:play()
		local time, vocals = game.sound.music:tell()
		for _, notefield in ipairs(self.notefields) do
			vocals = notefield.vocals
			if vocals then
				vocals:seek(time)
				vocals:play()
			end
		end
		PlayState.conductor.time = time * 1000
		if Discord then self:updateDiscordRPC() end
	end

	if self.buttons then
		self:add(self.buttons)
	end

	self.scripts:call("postSubstateClosed")
end

function PlayState:endSong(skip)
	if skip == nil then skip = false end
	PlayState.seenCutscene = false
	self.startedCountdown = false
	self.boyfriend.waitReleaseAfterSing = false

	if self.storyMode and not PlayState.seenCutscene and not skip then
		PlayState.seenCutscene = true

		local songName = paths.formatToSongPath(PlayState.SONG.song)
		local cutscenePaths = {
			paths.getMods('data/cutscenes/' .. songName .. '-end.lua'),
			paths.getMods('data/cutscenes/' .. songName .. '-end.json'),
			paths.getPath('data/cutscenes/' .. songName .. '-end.lua'),
			paths.getPath('data/cutscenes/' .. songName .. '-end.json')
		}

		local fileExist, cutsceneType
		for i, path in ipairs(cutscenePaths) do
			if paths.exists(path, 'file') then
				fileExist = true
				switch(path:ext(), {
					["lua"] = function() cutsceneType = "script" end,
					["json"] = function() cutsceneType = "data" end,
				})
			end
		end
		if fileExist then
			switch(cutsceneType, {
				["script"] = function()
					local cutsceneScript = Script('data/cutscenes/' .. songName .. '-end')
					cutsceneScript:call("create")
					self.scripts:add(cutsceneScript)
					cutsceneScript:call("postCreate")
				end,
				["data"] = function()
					local cutsceneData = paths.getJSON('data/cutscenes/' .. songName .. '-end')
					for i, event in ipairs(cutsceneData.cutscene) do
						self.timer:after(event.time / 1000, function()
							self:executeCutsceneEvent(event.event, true)
						end)
					end
				end
			})
			return
		else
			self:endSong(true)
			return
		end
	end

	local event = self.scripts:call("endSong")
	if event == Script.Event_Cancel then return end
	game.sound.music.onComplete = nil

	Highscore.saveScore(PlayState.SONG.song, self.score, self.songDifficulty)

	if self.chartingMode then
		game.switchState(ChartingState())
		return
	end

	game.sound.music:reset(true)
	local vocals
	for _, notefield in ipairs(self.notefields) do
		vocals = notefield.vocals
		if vocals then vocals:seek(time) end
	end

	if self.storyMode then
		PlayState.storyScore = PlayState.storyScore + self.score

		table.remove(PlayState.storyPlaylist, 1)

		if #PlayState.storyPlaylist > 0 then
			game.sound.music:stop()

			if Discord then
				local detailsText = "Freeplay"
				if self.storyMode then detailsText = "Story Mode: " .. PlayState.storyWeek end

				Discord.changePresence({
					details = detailsText,
					state = 'Loading next song..'
				})
			end

			PlayState.loadSong(PlayState.storyPlaylist[1], PlayState.songDifficulty)
			game.resetState(true)
		else
			Highscore.saveWeekScore(self.storyWeekFile, self.storyScore, self.songDifficulty)
			self.__stickers:start(StoryMenuState())
			GameOverSubstate.deaths = 0

			util.playMenuMusic()
		end
	else
		game.camera:unfollow()
		self.__stickers:start(FreeplayState())
		GameOverSubstate.deaths = 0

		util.playMenuMusic()
	end

	self.scripts:call("postEndSong")
end

function PlayState:updateDiscordRPC(paused)
	if not Discord then return end

	local detailsText = "Freeplay"
	if self.storyMode then detailsText = "Story Mode: " .. PlayState.storyWeek end

	local diff = PlayState.defaultDifficulty
	if PlayState.songDifficulty ~= "" then
		diff = PlayState.songDifficulty:gsub("^%l", string.upper)
	end

	if paused then
		Discord.changePresence({
			details = "Paused - " .. detailsText,
			state = PlayState.SONG.song .. ' - [' .. diff .. ']'
		})
		return
	end

	if self.startingSong or not game.sound.music or not game.sound.music:isPlaying() then
		Discord.changePresence({
			details = detailsText,
			state = PlayState.SONG.song .. ' - [' .. diff .. ']'
		})
	else
		local startTimestamp = os.time(os.date("*t"))
		local endTimestamp = (startTimestamp + game.sound.music:getDuration()) - PlayState.conductor.time / 1000
		Discord.changePresence({
			details = detailsText,
			state = PlayState.SONG.song .. ' - [' .. diff .. ']',
			startTimestamp = math.floor(startTimestamp),
			endTimestamp = math.floor(endTimestamp)
		})
	end
end

function PlayState:leave()
	self.scripts:call("leave")

	PlayState.prevCamFollow = self.camFollow
	PlayState.conductor = nil
	Timer.setSpeed(1)

	controls:unbindPress(self.bindedKeyPress)
	controls:unbindRelease(self.bindedKeyRelease)

	for _, notefield in ipairs(self.notefields) do
		if notefield.is then notefield:destroy() end
	end

	self.scripts:call("postLeave")
	self.scripts:close()
end

return PlayState
