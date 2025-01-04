local encodeJson = require('lib.json').encode

local ChartingState = State:extend("ChartingState")

ChartingState.songPosition = 0
ChartingState.sustainColors = {
	{194, 75, 153}, {0, 255, 255}, {8, 250, 5}, {249, 57, 63}
}

function ChartingState:enter()
	love.mouse.setVisible(true)

	self.leavingState = false

	self.curSection = 0
	self.stepsToDo = 0
	Note.chartingMode = true

	self.curSelectedNote = nil

	self.saveData = {
		metronome = true,
		playerTick = true,
		opponentTick = true
	}
	if game.save.data.chartingData then
		--self.saveData = game.save.data.chartingData
	end

	self.metronome = self.saveData.metronome
	self.playerTick = self.saveData.playerTick
	self.opponentTick = self.saveData.opponentTick

	self.bg = Sprite()
	self.bg:loadTexture(paths.getImage("menus/menuDesat"))
	self.bg:screenCenter()
	self.bg.color = {0.05, 0.05, 0.05}
	self.bg:setScrollFactor()
	self:add(self.bg)

	self.playback = 1
	self.focused = true

	self.bgMusic = game.sound.play(paths.getMusic('chartEditorLoop'), 0.4, true)

	if PlayState.SONG ~= nil then
		self.__song = PlayState.SONG
	else
		self.__song = {
			song = 'Test',
			bpm = 150.0,
			speed = 1,
			needsVoices = true,
			stage = 'stage',
			player1 = 'bf',
			player2 = 'dad',
			gfVersion = 'gf',
			notes = {}
		}
		PlayState.SONG = self.__song
	end
	self.curDiff = PlayState.songDifficulty
	self:loadSong(self.__song.song)

	local songName = paths.formatToSongPath(self.__song.song)

	self.allNotes = Group()
	self.allSustains = Group()

	self.gridSize = 40

	self.strumLine = {x = self.gridSize * 16, y = 360}
	self.camHUD = Camera()
	self.camOther = Camera()
	game.cameras.add(self.camHUD, false)
	game.cameras.add(self.camOther, false)

	local centerGridX = (game.width / 2) - (self.gridSize * 4)
	self.gridBox = ui.UIGrid(centerGridX, 0, 40, 8, self.gridSize,
		{0.4, 0.4, 0.4}, {0.2, 0.2, 0.2})

	self:add(self.gridBox)

	if Discord then
		Discord.changePresence({
			details = "Charting",
			state = "Song: " .. self.__song.song,
			startTimestamp = os.time(os.date("*t"))
		})
	end

	local blackLine = Graphic(self.gridBox.x + (self.gridSize * 4) - 1, 0, 2, game.height, Color.BLACK)
	blackLine:setScrollFactor(1, 0)
	self:add(blackLine)

	self.beatLines = Group()
	self:updateBeatLine()
	self:add(self.beatLines)

	self.sectionLines = Group()
	self:updateSectionLine()
	self:add(self.sectionLines)

	self.dummyArrow = Graphic(0, 0, self.gridSize, self.gridSize, Color.WHITE)
	self:add(self.dummyArrow)

	self:generateNotes()
	self:add(self.allSustains)
	self:add(self.allNotes)

	local daBlack = Graphic(self.gridBox.x, 0, self.gridSize * 8,
		self.gridSize * 4, Color.BLACK)
	daBlack:setScrollFactor()
	daBlack.alpha = 0.4
	self:add(daBlack)

	local curPosLine = Graphic(self.gridBox.x - 5, self.gridSize * 4 - 2, self.gridSize * 8 + 10, 4, {0, 0.5, 1})
	curPosLine:setScrollFactor()
	self:add(curPosLine)

	self.iconsGroup = Group()
	self:add(self.iconsGroup)
	self:updateIcon()

	ChartingState.conductorInfo = Text(self.gridBox.x + (self.gridSize * 8) + 20, 60, '',
		love.graphics.newFont(16))
	ChartingState.conductorInfo:setScrollFactor()
	self:add(ChartingState.conductorInfo)

	local textInfo = "ENTER Test the chart.\n" ..
		"CTRL + ENTER Test on this position.\n" ..
		"SPACE Play / Pause song.\n" ..
		"A / D Change section.\n" .. "W / S Scroll.\n" ..
		"SHIFT 4x scroll speed."
	self.infoTxt = Text(10, 150, textInfo, love.graphics.newFont(16))
	self.infoTxt:setScrollFactor()
	self:add(self.infoTxt)

	self.blockInput = {}
	self.UI_Windows = {}
	self.curWindow = nil

	self.navbarChart = ui.UINavbar({
		{"File", function()
		end},
		{"Chart", function()
		end},
		{"Song", function() self:add_UIWindow_Song() end},
		{"Note", function() self:add_UIWindow_Note() end},
		{"Events", function()
		end}
	})
	self.navbarChart.cameras = {self.camHUD}
	self:add(self.navbarChart)

	self:updateIcon()
end

function ChartingState:add_UIWindow_Song()
	if self.UISongWindow then
		if self.UISongWindow.alive then
			self.UISongWindow:kill()
			table.delete(self.UI_Windows, self.UISongWindow)
			if self.UI_Windows.selected == self.UISongWindow then
				self.UI_Windows.selected = nil
			end
		else
			self.UISongWindow:clear()
			self.UISongWindow:revive()
			self:add(self.UISongWindow)
			table.insert(self.UI_Windows, self.UISongWindow)
		end
	else
		self.UISongWindow = ui.UIWindow(4, 84, nil, 300, "Song")
		self.UISongWindow.cameras = {self.camHUD}
		self.UISongWindow.onClosed = function() self:remove(self.UISongWindow) end
		self:add(self.UISongWindow)
		table.insert(self.UI_Windows, self.UISongWindow)
	end

	local rectline = Graphic(10, 10, 380, 100, {0.15, 0.15, 0.15},
		"rectangle", "line")
	rectline.line.width = 1
	rectline.config.round = {4, 4}

	local instTxt = Text(rectline.x + 18, rectline.y - 6, ' Instrumental ')
	instTxt.bgColor = {0.3, 0.3, 0.3}
	instTxt.antialiasing = false

	local format = 'Volume - {val}%'
	local instVolTxt = Text(rectline.x + 15, rectline.y + 14, '')
	instVolTxt.content = format:gsub('{val}',
		tostring(game.sound.music:getVolume() * 100))
	instVolTxt.antialiasing = false

	local instVolSlider = ui.UISlider(rectline.x + 15, rectline.y + 35, 150, 10,
		game.sound.music:getVolume(), 0.1)
	instVolSlider.onChanged = function(value)
		game.sound.music:setVolume(value)
		instVolTxt.content = format:gsub('{val}',
			tostring(game.sound.music:getVolume() * 100))
	end

	self.UISongWindow:add(rectline)
	self.UISongWindow:add(instTxt)
	self.UISongWindow:add(instVolTxt)
	self.UISongWindow:add(instVolSlider)

	local rectline = Graphic(10, 120, 380, 100, {0.15, 0.15, 0.15},
		"rectangle", "line")
	rectline.line.width = 1
	rectline.config.round = {4, 4}

	if self.__song.needsVoices then
		local vocTxt = Text(rectline.x + 18, rectline.y - 6, ' Voices ')
		vocTxt.bgColor = {0.3, 0.3, 0.3}
		vocTxt.antialiasing = false

		local vocVolTxt = Text(rectline.x + 15, rectline.y + 14, '')
		vocVolTxt.content = format:gsub('{val}',
			tostring(self.vocals:getVolume() * 100))
		vocVolTxt.antialiasing = false

		local vocVolSlider = ui.UISlider(rectline.x + 15, rectline.y + 35, 150, 10,
			self.vocals:getVolume(), 0.1)
		vocVolSlider.onChanged = function(value)
			self.vocals:setVolume(value)
			vocVolTxt.content = format:gsub('{val}',
				tostring(self.vocals:getVolume() * 100))
		end

		self.UISongWindow:add(rectline)
		self.UISongWindow:add(vocTxt)
		self.UISongWindow:add(vocVolTxt)
		self.UISongWindow:add(vocVolSlider)
	end

	local format = 'Playback - {val}%'
	local playbackTxt = Text(10, rectline.y + 110, '')
	playbackTxt.content = format:gsub('{val}', '1')
	playbackTxt.antialiasing = false

	local playbackSlider = ui.UISlider(10, rectline.y + 130, 380, 10,
		1, 0.05, nil, 0.2, 2)
	playbackSlider.onChanged = function(value)
		self.playback = value
		game.sound.music:setPitch(value)
		if self.__song.needsVoices then self.vocals:setPitch(value) end
		playbackTxt.content = format:gsub('{val}', tostring(value))
	end

	self.UISongWindow:add(playbackTxt)
	self.UISongWindow:add(playbackSlider)
end

function ChartingState:add_UIWindow_Note(note)
	if self.UINoteWindow then
		if self.UINoteWindow.alive then
			self.UINoteWindow:kill()
			table.delete(self.UI_Windows, self.UINoteWindow)
			if self.UI_Windows.selected == self.UINoteWindow then
				self.UI_Windows.selected = nil
			end
		else
			self.UINoteWindow:clear()
			self.UINoteWindow:revive()
			self:add(self.UINoteWindow)
			table.insert(self.UI_Windows, self.UINoteWindow)
		end
	else
		self.UINoteWindow = ui.UIWindow(4, 84, nil, nil, "Note")
		self.UINoteWindow.cameras = {self.camHUD}
		self.UINoteWindow.onClosed = function() self:remove(self.UINoteWindow) end
		self:add(self.UINoteWindow)
		table.insert(self.UI_Windows, self.UINoteWindow)
	end

	if note then
		local noteTimeTxt = Text(220, 12, 'Time')
		noteTimeTxt.antialiasing = false
		self.UINoteWindow:add(noteTimeTxt)

		local noteTimeInput = ui.UIInputTextBox(10, 10, 200)
		noteTimeInput.text = tostring(note.time)
		noteTimeInput.onChanged = function(text)
			if text:match("[0123456789%.]+") == text then
				note.time = tonumber(text)
				self.curSelectedNote[1] = note.time
				noteTimeTxt.content = 'Time'
				noteTimeTxt.color = Color.WHITE

				local bpmChanges, lastChange = ChartingState.conductor.bpmChanges,
					ChartingState.conductor.dummyBPMChange

				note.step = Conductor.getStepFromBPMChange(lastChange, note.time, 0)
				local yval = note.step * self.gridSize
				note.y = yval
			else
				noteTimeTxt.content = 'Time (invalid number)'
				noteTimeTxt.color = {1, 0.5, 0.5}
			end
		end
		self.UINoteWindow:add(noteTimeInput)

		local noteTypeDropDown = ui.UIDropDown(10, 40, {
			'Normal Note',
			'Hurt Note',
			'Alt Note'
		})
		if note.type then
			noteTypeDropDown:selectOption(table.find(noteTypeDropDown.options,
				note.type))
		else
			noteTypeDropDown:selectOption(1)
		end
		self.UINoteWindow:add(noteTypeDropDown)
	else
		local noteTypeDropDown = ui.UIDropDown(10, 10, {
			'Normal Note',
			'Hurt Note',
			'Alt Note'
		})
		self.UINoteWindow:add(noteTypeDropDown)
	end
end

function ChartingState:add_UI_Song()
	local input_song = ui.UIInputTextBox(45, 10, 135, 20)
	input_song.text = self.__song.song
	input_song.onChanged = function(value) self.__song.song = value end

	local metadata = paths.getJSON('songs/' ..
		paths.formatToSongPath(self.__song.song) ..
		'/meta')
	local diffs = {"easy", "normal", "hard"}
	if metadata and metadata.difficulties then
		diffs = {}
		for i = 1, #metadata.difficulties do
			diffs[i] = metadata.difficulties[i]:lower()
		end
	end
	local diff_dropdown = ui.UIDropDown(70, 40, diffs)
	if self.curDiff == "" then self.curDiff = "normal" end
	diff_dropdown.selectedLabel = self.curDiff
	diff_dropdown.onChanged = function(value) self.curDiff = value end

	local load_audio_button = ui.UIButton(300, 10, 80, 20, 'Load Audio',
		function()
			self:loadSong(input_song.text)
		end)

	local load_json_button = ui.UIButton(300, 40, 80, 20, 'Load JSON',
		function()
			game.sound.music:pause()
			if self.vocals then self.vocals:pause() end
			self:loadJson(input_song.text)
		end)

	local save_song_button = ui.UIButton(200, 10, 80, 20, 'Save Chart',
		function() self:saveJson() end)

	local voice_track = ui.UICheckbox(10, 70, 20)
	voice_track.checked = self.__song.needsVoices
	voice_track.callback = function()
		self.__song.needsVoices = voice_track.checked
	end

	local bpm_stepper = ui.UINumericStepper(10, 140, 1, self.__song.bpm, 1, 400)
	bpm_stepper.onChanged = function(value)
		self.__song.bpm = value
		ChartingState.conductor:setBPM(value)
		self:updateNotes()
	end

	local speed_stepper = ui.UINumericStepper(10, 190, 0.1, self.__song.speed,
		0.1, 10)
	speed_stepper.onChanged = function(value) self.__song.speed = value end

	local optionsChar = {}
	if Mods.currentMod then
		for _, str in pairs(love.filesystem.getDirectoryItems(paths.getMods(
			'data/characters'))) do
			local charName = str:withoutExt()
			if str:endsWith('.json') and not charName:endsWith('-dead') then
				table.insert(optionsChar, charName)
			end
		end
	end
	for _, str in pairs(love.filesystem.getDirectoryItems(paths.getPath(
		'data/characters', false))) do
		local charName = str:withoutExt()
		if str:endsWith('.json') and not charName:endsWith('-dead') then
			table.insert(optionsChar, charName)
		end
	end

	local boyfriend_dropdown = ui.UIDropDown(10, 250, optionsChar)
	boyfriend_dropdown.selectedLabel = self.__song.player1 or 'boyfriend'
	boyfriend_dropdown.onChanged = function(value)
		self.__song.player1 = value
		self:updateIcon()
	end

	local opponent_dropdown = ui.UIDropDown(10, 310, optionsChar)
	opponent_dropdown.selectedLabel = self.__song.player2 or 'boyfriend'
	opponent_dropdown.onChanged = function(value)
		self.__song.player2 = value
		self:updateIcon()
	end

	local girlfriend_dropdown = ui.UIDropDown(10, 370, optionsChar)
	girlfriend_dropdown.selectedLabel = self.__song.gfVersion or 'boyfriend'
	girlfriend_dropdown.onChanged = function(value)
		self.__song.gfVersion = value
	end

	local optionsStage = {}
	if Mods.currentMod then
		for _, str in pairs(love.filesystem.getDirectoryItems(paths.getMods(
			'data/stages'))) do
			local stageName = str:withoutExt()
			table.insert(optionsStage, stageName)
		end
	end
	for _, str in pairs(love.filesystem.getDirectoryItems(paths.getPath(
		'data/stages', false))) do
		local stageName = str:withoutExt()
		table.insert(optionsStage, stageName)
	end

	local stage_dropdown = ui.UIDropDown(140, 250, optionsStage)
	stage_dropdown.selectedLabel = self.__song.stage or 'stage'
	stage_dropdown.onChanged = function(value) self.__song.stage = value end

	local song_text = Text(4, 10, "Song:")
	song_text:setScrollFactor()

	local diff_text = Text(4, 40, "Difficulty:")
	diff_text:setScrollFactor()

	local voice_text = Text(34, 73, "Has voice track")
	voice_text:setScrollFactor()

	local bpm_text = Text(10, 120, "Song BPM:")
	bpm_text:setScrollFactor()

	local speed_text = Text(10, 170, "Song Speed:")
	speed_text:setScrollFactor()

	local gf_text = Text(10, 350, "Girlfriend:")
	gf_text:setScrollFactor()

	local opponent_text = Text(10, 290, "Opponent:")
	opponent_text:setScrollFactor()

	local bf_text = Text(10, 230, "Boyfriend:")
	bf_text:setScrollFactor()

	local tab_song = Group()
	tab_song.name = "Song"

	table.insert(self.blockInput, input_song)
	table.insert(self.blockInput, bpm_stepper)
	table.insert(self.blockInput, speed_stepper)

	tab_song:add(song_text)
	tab_song:add(input_song)
	tab_song:add(voice_text)
	tab_song:add(voice_track)
	tab_song:add(bpm_text)
	tab_song:add(bpm_stepper)
	tab_song:add(speed_text)
	tab_song:add(speed_stepper)
	tab_song:add(load_audio_button)
	tab_song:add(load_json_button)
	tab_song:add(save_song_button)
	tab_song:add(gf_text)
	tab_song:add(girlfriend_dropdown)
	tab_song:add(opponent_text)
	tab_song:add(opponent_dropdown)
	tab_song:add(bf_text)
	tab_song:add(boyfriend_dropdown)
	tab_song:add(stage_dropdown)
	tab_song:add(diff_text)
	tab_song:add(diff_dropdown)

	self.UI_Box:addGroup(tab_song)
end

function ChartingState:add_UI_Section()
	self.must_hit_sec = ui.UICheckbox(10, 20, 20)
	self.must_hit_sec.checked = self.__song.notes[self.curSection + 1]
		.mustHitSection
	self.must_hit_sec.callback = function()
		self.__song.notes[self.curSection + 1].mustHitSection =
			self.must_hit_sec.checked
		for _, n in ipairs(self.__song.notes[self.curSection + 1].sectionNotes) do
			if self.__song.notes[self.curSection + 1].mustHitSection then
				if n[2] > 3 then
					n[2] = n[2] - 4
				else
					n[2] = n[2] + 4
				end
			else
				if n[2] > 3 then
					n[2] = n[2] - 4
				else
					n[2] = n[2] + 4
				end
			end
		end
		self:generateNotes()
	end

	local tab_section = Group()
	tab_section.name = "Section"

	local mustHit_text = Text(34, 23, "Must Hit Section")
	mustHit_text:setScrollFactor()

	tab_section:add(mustHit_text)
	tab_section:add(self.must_hit_sec)

	self.UI_Box:addGroup(tab_section)
end

function ChartingState:add_UI_Charting()
	local metronome = ui.UICheckbox(10, 20, 20)
	metronome.checked = self.metronome
	metronome.callback = function()
		self.metronome = metronome.checked
		self.saveData.metronome = self.metronome
		game.save.data.chartingData = self.saveData
	end

	local player_hitsound = ui.UICheckbox(10, 50, 20)
	player_hitsound.checked = self.playerTick
	player_hitsound.callback = function()
		self.playerTick = player_hitsound.checked
		self.saveData.playerTick = self.playerTick
		game.save.data.chartingData = self.saveData
	end

	local opponent_hitsound = ui.UICheckbox(10, 80, 20)
	opponent_hitsound.checked = self.opponentTick
	opponent_hitsound.callback = function()
		self.opponentTick = opponent_hitsound.checked
		self.saveData.opponentTick = self.opponentTick
		game.save.data.chartingData = self.saveData
	end

	local mute_inst = ui.UICheckbox(110, 140, 20)
	mute_inst.checked = false
	mute_inst.callback = function()
		if mute_inst.checked then
			game.sound.music:setVolume(0)
		else
			game.sound.music:setVolume(1)
		end
	end

	local mute_voices = ui.UICheckbox(110, 190, 20)
	mute_voices.checked = false
	mute_voices.callback = function()
		if mute_voices.checked then
			if self.vocals then self.vocals:setVolume(0) end
		else
			if self.vocals then self.vocals:setVolume(1) end
		end
	end

	local vol_inst_stepper = ui.UINumericStepper(10, 140, 0.05, 1, 0, 1)
	vol_inst_stepper.onChanged = function(value)
		if not mute_inst.checked then
			game.sound.music:setVolume(1)
		end
	end

	local vol_voices_stepper = ui.UINumericStepper(10, 190, 0.05, 1, 0,
		1)
	vol_voices_stepper.onChanged = function(value)
		if not mute_voices.checked then
			if self.vocals then self.vocals:setVolume(1) end
		end
	end

	local metronome_text = Text(34, 23, "Metronome")
	metronome_text:setScrollFactor()

	local player_hit_text = Text(34, 53, "Player Hitsound")
	player_hit_text:setScrollFactor()

	local opponent_hit_text = Text(34, 83, "Oppoenent Hitsound")
	opponent_hit_text:setScrollFactor()

	local mute_inst_text = Text(134, 143, "Mute")
	mute_inst_text:setScrollFactor()

	local mute_voices_text = Text(134, 193, "Mute")
	mute_voices_text:setScrollFactor()

	local vol_inst_text = Text(10, 120, "Instrumental Volume")
	vol_inst_text:setScrollFactor()

	local vol_voices_text = Text(10, 170, "Vocals Volume")
	vol_voices_text:setScrollFactor()

	local tab_charting = Group()
	tab_charting.name = "Charting"

	tab_charting:add(metronome_text)
	tab_charting:add(metronome)
	tab_charting:add(player_hit_text)
	tab_charting:add(player_hitsound)
	tab_charting:add(opponent_hit_text)
	tab_charting:add(opponent_hitsound)
	tab_charting:add(mute_inst_text)
	tab_charting:add(mute_inst)
	tab_charting:add(mute_voices_text)
	tab_charting:add(mute_voices)
	tab_charting:add(vol_inst_text)
	tab_charting:add(vol_inst_stepper)
	tab_charting:add(vol_voices_text)
	tab_charting:add(vol_voices_stepper)

	self.UI_Box:addGroup(tab_charting)
end

function ChartingState:update_UI_Section()
	self.must_hit_sec.checked = self.__song.notes[self.curSection + 1]
		.mustHitSection
end

function ChartingState:UI_isHovered()
	for i, u in pairs(self.UI_Windows) do
		if u.hovered and game.mouse.justPressedLeft then
			self.curWindow = u
			self:remove(u)
			table.delete(self.UI_Windows, u)
			self:add(u)
			table.insert(self.UI_Windows, 1, u)
		end
		if u.alive then
			if u ~= self.curWindow then u.focused = false end
			if u.hovered then return true end
		end
	end
	return false
end

local colorSine = 0
function ChartingState:update(dt)
	ChartingState.super.update(self, dt)

	local oldStep = ChartingState.conductor.currentStep

	ChartingState.conductor:update()

	if oldStep > ChartingState.conductor.currentStep then
		self.curSection = 0
		self.stepsToDo = 0
		for i = 0, #self.__song.notes do
			if self.__song.notes[i + 1] ~= nil then
				self.stepsToDo = self.stepsToDo +
					math.round(self:getSectionBeats() * 4)
				if self.stepsToDo > ChartingState.conductor.currentStep then
					break
				end
				self.curSection = self.curSection + 1
			end
		end
	end

	if self.focused and not self.leavingState then
		if game.sound.music:isPlaying() and self.bgMusic:isPlaying() then
			self.bgMusic:pause()
		elseif not game.sound.music:isPlaying() and not self.bgMusic:isPlaying() then
			self.bgMusic:play()
			self.bgMusic:fade(2, 0, 0.4)
		end
	else
		if self.bgMusic:isPlaying() then self.bgMusic:pause() end
	end

	local isTyping = false
	for _, inputObj in ipairs(self.blockInput) do
		if inputObj.active then
			isTyping = true
			break
		end
		isTyping = false
	end

	local isHovered = self:UI_isHovered()

	if not self.leavingState then
		ChartingState.songPosition = game.sound.music:tell() * 1000
		ChartingState.conductor.time = ChartingState.songPosition
		self:strumPosUpdate()
	end

	local mouseX, mouseY = (game.mouse.x + game.camera.scroll.x),
		(game.mouse.y + game.camera.scroll.y)
	if not isHovered and mouseX > self.gridBox.x and mouseX < self.gridBox.x +
		self.gridBox.width and mouseY > self.strumLine.y - (self.gridSize * 4) and
		mouseY < self.strumLine.y + (self.gridSize * 18) then
		self.dummyArrow.visible = true
		self.dummyArrow.x = math.floor(mouseX / self.gridSize) * self.gridSize
		if game.keys.pressed.SHIFT then
			self.dummyArrow.y = (mouseY - (self.gridSize / 2))
		else
			local gridmult = self.gridSize / (16 / 16)
			self.dummyArrow.y = math.floor((mouseY) / gridmult) * gridmult
		end
	else
		self.dummyArrow.visible = false
	end

	if not self.leavingState and not isHovered and not isTyping then
		if game.keys.justPressed.S and game.keys.pressed.CONTROL then
			self:saveJson()
		end
		if game.mouse.justPressed then
			for _, n in ipairs(self.allNotes.members) do
				if game.mouse.overlaps(n) then
					if game.mouse.justPressedRight then
						self:deleteNote(n)
						if self.UINoteWindow then self.UINoteWindow:kill() end
					else
						self:selectNote(n)
						self:add_UIWindow_Note(n)
					end
					return
				end
			end
			if mouseX > self.gridBox.x and mouseX < self.gridBox.x +
				self.gridBox.width and mouseY > self.strumLine.y -
				(self.gridSize * 5) and mouseY < self.gridBox.y +
				(self.gridSize * 4 * 4) + (self.gridSize * 17) then
				local n = self:addNote()
				if self.UINoteWindow and self.UINoteWindow.alive then
					self:add_UIWindow_Note(n)
				end
			end
		end

		if game.keys.justPressed.SPACE then
			if game.sound.music:isPlaying() then
				game.sound.music:pause()
				if self.vocals then self.vocals:pause() end
			else
				if self.vocals then
					self.vocals:seek(
						game.sound.music:tell())
					self.vocals:play()
				end
				game.sound.music:play()
			end
		end

		if game.mouse.wheel ~= 0 or (game.keys.pressed.W or game.keys.pressed.S) then
			game.sound.music:pause()

			local shiftMult = 1
			if game.keys.pressed.CONTROL then
				shiftMult = 0.25
			elseif game.keys.pressed.SHIFT then
				shiftMult = 4
			end

			local addTime = (game.keys.pressed.W or game.keys.pressed.S) and 700 or 4000
			local daTime = addTime * dt * shiftMult

			if game.keys.pressed.W then
				local checkTime = game.sound.music:tell() -
					(daTime / 1000)
				if checkTime > 0 then
					game.sound.music:seek(
						game.sound.music:tell() - (daTime / 1000))
				end
			elseif game.keys.pressed.W then
				local checkLimit = game.sound.music:tell() +
					(daTime / 1000)
				if checkLimit < game.sound.music:getDuration() then
					game.sound.music:seek(
						game.sound.music:tell() + (daTime / 1000))
				else
					game.sound.music:seek(0)
				end
			else
				if game.mouse.wheel > 0 then
					local checkTime = game.sound.music:tell() -
						(daTime / 1000)
					if checkTime > 0 then
						game.sound.music:seek(
							game.sound.music:tell() - (daTime / 1000))
					end
				else
					local checkLimit = game.sound.music:tell() +
						(daTime / 1000)
					if checkLimit < game.sound.music:getDuration() then
						game.sound.music:seek(
							game.sound.music:tell() + (daTime / 1000))
					else
						game.sound.music:seek(0)
					end
				end
			end

			if self.vocals then
				self.vocals:pause()
				self.vocals:seek(game.sound.music:tell())
			end

			ChartingState.conductor:update()

			self.curSection = 0
			self.stepsToDo = 0
			for i = 0, #self.__song.notes do
				if self.__song.notes[i + 1] ~= nil then
					self.stepsToDo = self.stepsToDo +
						math.round(self:getSectionBeats() * 4)
					if self.stepsToDo > ChartingState.conductor.currentStep then
						break
					end
					self.curSection = self.curSection + 1
				end
			end

			--self:update_UI_Section()
		end

		if game.keys.justPressed.ENTER then
			game.sound.music:pause()
			if self.vocals then self.vocals:pause() end

			PlayState.chartingMode = true
			PlayState.startPos = (game.keys.pressed.CONTROL and
				ChartingState.songPosition or 0)
			game.switchState(PlayState())
		end

		if game.keys.justPressed.BACKSPACE then
			self.leavingState = true

			game.sound.music:pause()
			if self.vocals then self.vocals:pause() end

			PlayState.chartingMode = false
			PlayState.startPos = 0
			game.sound.playMusic(paths.getMusic("freakyMenu"))
			game.switchState(FreeplayState())
		end

		local shiftThing = 1
		if game.keys.pressed.SHIFT then shiftThing = 4 end

		if game.keys.justPressed.D then
			self:changeSection(self.curSection + shiftThing)
		end
		if game.keys.justPressed.A then
			self:changeSection(self.curSection - shiftThing)
		end
	end

	if not self.leavingState then
		ChartingState.songPosition = game.sound.music:tell() * 1000
		ChartingState.conductor.time = ChartingState.songPosition
		self:strumPosUpdate()
	end

	for _, n in pairs(self.allNotes.members) do
		n.color = Color.WHITE

		if self.curSelectedNote ~= nil then
			local datacheck = n.data
			if self.__song.notes[n.section] and n.mustPress ~=
				self.__song.notes[n.section].mustHitSection then
				datacheck = datacheck + 4
			end
			if self.curSelectedNote[1] == n.time and self.curSelectedNote[3] ~=
				nil and self.curSelectedNote[2] == datacheck then
				colorSine = colorSine + dt
				local colorVal = 0.7 + math.sin(math.pi * colorSine) * 0.3
				n.color = {colorVal, colorVal, colorVal}

				if game.keys.justPressed.Q or game.keys.justPressed.E then
					local stepCrot = ChartingState.conductor.stepCrotchet
					local susLength = self.curSelectedNote[3] +
						(game.keys.justPressed.E and stepCrot or -stepCrot)
					if susLength < 0 then
						n.sustainSprite.height = 0
						self.curSelectedNote[3] = 0
					else
						local susHeight = math.remapToRange(susLength, 0,
							ChartingState.conductor.stepCrotchet * 16, 0,
							(self.gridSize * 16))
						n.sustainSprite.height = susHeight
						self.curSelectedNote[3] = susLength
					end
				end
			end
		end

		if ChartingState.songPosition > n.time and not n.wasGoodHit then
			n.wasGoodHit = true
			n.alpha = 0.4
			if n.sustainSprite then n.sustainSprite.alpha = 0.4 end
			if n.mustPress and self.playerTick or not n.mustPress and
				self.opponentTick then
				if game.sound.music:isPlaying() then
					game.sound.play(paths.getSound('hitsound'))
				end
			end
		elseif ChartingState.songPosition < n.time then
			n.wasGoodHit = false
			n.alpha = 1
			if n.sustainSprite then n.sustainSprite.alpha = 1 end
		end
	end

	local daText = util.formatTime(ChartingState.songPosition / 1000) ..
		' / ' ..
		util.formatTime(
			game.sound.music:getDuration()) ..
		'\nSection: ' .. self.curSection .. '\nBeat: ' ..
		ChartingState.conductor.currentBeat .. '\nStep: ' ..
		ChartingState.conductor.currentStep
	ChartingState.conductorInfo.content = daText
end

function ChartingState:generateNotes()
	self.allNotes:clear()
	local skin, bpmChanges, lastChange =
		util.getSongSkin(self.__song),
		ChartingState.conductor.bpmChanges,
		ChartingState.conductor.dummyBPMChange
	for section_num, s in ipairs(self.__song.notes) do
		if s and s.sectionNotes then
			for note_num, n in ipairs(s.sectionNotes) do
				local daStrumTime = tonumber(n[1])
				local daNoteData = tonumber(n[2])
				if daStrumTime ~= nil and daNoteData ~= nil then
					daNoteData = daNoteData % 4
					local gottaHitNote = s.mustHitSection
					if n[2] > 3 then
						gottaHitNote = not gottaHitNote
					end

					lastChange = Conductor.getBPMChangeFromTime(bpmChanges, daStrumTime,
						lastChange.id) or lastChange

					local note = ChartingNote(daStrumTime, daNoteData, skin)
					note.section = section_num
					note.index = note_num
					note.step = Conductor.getStepFromBPMChange(lastChange, daStrumTime, 0)
					note.mustPress = gottaHitNote
					note.type = n[4]
					note:setGraphicSize(self.gridSize, self.gridSize)
					note:updateHitbox()
					local id = (note.mustPress and note.data + 4 or note.data)
					local yval = note.step * self.gridSize
					local xval = (self.gridBox.x) + (self.gridSize * id)
					note.x = xval
					note.y = yval
					self.allNotes:add(note)

					local sustain = Graphic(note.x + (self.gridSize / 2) - 4, note.y + (self.gridSize / 2),
						8, 0, Color.convert(self.sustainColors[note.data + 1]))
					note.sustainSprite = sustain
					self.allSustains:add(sustain)

					if n[3] ~= nil then
						local susLength = tonumber(n[3])
						if susLength ~= nil and susLength > 0 then
							local susHeight =
								math.remapToRange(susLength, 0,
									ChartingState.conductor
									.stepCrotchet * 16, 0,
									(self.gridSize * 16))
							sustain.height = math.floor(susHeight)
						end
					end
				end
			end
		end
	end

	table.sort(self.allNotes.members, Conductor.sortByTime)
end

function ChartingState:updateNotes(updateTime)
	if updateTime == nil then updateTime = true end
	for _, note in ipairs(self.allNotes.members) do
		if updateTime then
			note.time = ChartingState.conductor:getTimeFromStep(note.step)
		end
		local id = (note.mustPress and note.data + 4 or note.data)
		local yval = note.step * (self.gridSize * 4)
		local xval = (self.gridBox.x) + (self.gridSize * id)
		note.x = xval
		note.y = yval
		if note.sustainSprite then
			note.sustainSprite.y = note.y + (self.gridSize / 2)
		end

		self.__song.notes[note.section].sectionNotes[note.index][1] = note.time
	end
end

function ChartingState:updateBeatLine()
	self.beatLines:clear()
	for i = 0, 10 do
		local daLine = Graphic(self.gridBox.x - 4, 0,
			self.gridSize * 8 + 8, 2, Color.WHITE)
		daLine.alpha = 0.6
		daLine.y = self.gridBox.y + ((self.gridSize * 4) * i) - 1
		self.beatLines:add(daLine)
	end
end

function ChartingState:updateSectionLine()
	self.sectionLines:clear()
	local totalSteps = 0
	for _, s in ipairs(self.__song.notes) do
		local beats = 4
		if s and s.sectionBeats then beats = s.sectionBeats end
		local daLine = Graphic(self.gridBox.x - 5, 0,
			self.gridSize * 8 + 10, 4, Color.WHITE)
		daLine.alpha = 0.7
		daLine.y = (self.gridSize * totalSteps) - 2
		totalSteps = totalSteps + math.round(beats * 4)
		self.sectionLines:add(daLine)
	end
end

function ChartingState:strumPosUpdate()
	self.strumLine.y = (ChartingState.conductor.currentStepFloat *
		self.gridSize) - (self.gridSize * 4)
	self.gridBox.y = (self.gridSize * -8) + (self.gridSize * 8 *
		(math.floor(
			(ChartingState.conductor.currentStepFloat / 8) -
			(ChartingState.conductor.stepCrotchet / 16) /
			self.gridSize)))
	game.camera.scroll.y = self.strumLine.y
	self:updateBeatLine()
end

function ChartingState:loadSong(song)
	game.sound.loadMusic(paths.getInst(song)):setPitch(1)
	ChartingState.conductor = Conductor():setSong(self.__song)
	ChartingState.conductor.onStep = function(s)
		self:resyncVocals()

		if self.__song.notes[self.curSection + 2] == nil then
			self:addSection()
			self:updateSectionLine()
		end

		if self.stepsToDo < 1 then
			self.stepsToDo = math.round(self:getSectionBeats() * 4)
		end
		while s >= self.stepsToDo do
			self.curSection = self.curSection + 1
			self.stepsToDo = self.stepsToDo +
				math.round(self:getSectionBeats() * 4)

			--self:update_UI_Section()
		end
	end
	ChartingState.conductor.onBeat = function(b)
		if self.metronome and game.sound.music:isPlaying() then
			game.sound.play(paths.getSound('metronome'), 0.8)
		end
	end
	if self.__song.needsVoices then
		self.vocals = Sound():load(paths.getVoices(song))
		game.sound.list:add(self.vocals)
	end
	ChartingState.songPosition = game.sound.music:tell() * 1000
	ChartingState.conductor.time = ChartingState.songPosition

	local curTime = 0
	if #self.__song.notes <= 1 then
		while curTime < game.sound.music:getDuration() do
			self:addSection()
			curTime = curTime + (60 / self.__song.bpm) * 4000
		end
	end
end

function ChartingState:resyncVocals()
	local time = game.sound.music:tell()
	if self.vocals and math.abs(self.vocals:tell() * 1000 - time * 1000) > 20 then
		self.vocals:seek(time)
	end
	if math.abs(time * 1000 - ChartingState.songPosition) > 20 then
		ChartingState.songPosition = time * 1000
		game.sound.music:seek(ChartingState.songPosition / 1000)
	end
end

function ChartingState:updateIcon()
	local function getIconFromCharacter(char)
		local data = paths.getJSON("data/characters/" .. char)
		return (data and data.icon) and data.icon or 'bf'
	end
	local iconLeft = getIconFromCharacter(self.__song.player2)
	local iconRight = getIconFromCharacter(self.__song.player1)

	for _, icon in ipairs(self.iconsGroup.members) do icon:destroy() end
	self.iconsGroup:clear()

	local iconLeftSpr = HealthIcon(iconLeft)
	iconLeftSpr.x, iconLeftSpr.y = self.gridBox.x + 40, 50
	iconLeftSpr:setScrollFactor()

	local iconRightSpr = HealthIcon(iconRight)
	iconRightSpr.x, iconRightSpr.y = self.gridBox.x + (self.gridSize * 4) + 40,
		50
	iconRightSpr:setScrollFactor()

	iconLeftSpr.scale = {x = 0.53, y = 0.53}
	iconRightSpr.scale = {x = 0.53, y = 0.53}

	iconLeftSpr:updateHitbox()
	iconRightSpr:updateHitbox()

	self.iconsGroup:add(iconLeftSpr)
	self.iconsGroup:add(iconRightSpr)
end

function ChartingState:selectNote(note)
	local datacheck = note.data
	if self.__song.notes[note.section] then
		if note.mustPress ~= self.__song.notes[note.section].mustHitSection then
			datacheck = datacheck + 4
		end
		for _, n in ipairs(self.__song.notes[note.section].sectionNotes) do
			if n ~= self.curSelectedNote and #n > 2 and n[1] == note.time and n[2] ==
				datacheck then
				self.curSelectedNote = n
				break
			end
		end
	end
end

function ChartingState:deleteNote(note)
	local datacheck = note.data
	if self.__song.notes[note.section] then
		if note.mustPress ~= self.__song.notes[note.section].mustHitSection then
			datacheck = datacheck + 4
		end
		for _, n in ipairs(self.__song.notes[note.section].sectionNotes) do
			if n[1] == note.time and n[2] == datacheck then
				if n == self.curSelectedNote then
					self.curSelectedNote = nil
				end
				table.delete(self.__song.notes[note.section].sectionNotes, n)
				self.allSustains:remove(note.sustainSprite):destroy()
				self.allNotes:remove(note):destroy()
				break
			end
		end
	end
end

function ChartingState:addNote()
	local mouseX = (game.mouse.x + game.camera.scroll.x)
	local bpmChanges, lastChange = ChartingState.conductor.bpmChanges, ChartingState.conductor.dummyBPMChange
	local dummyStep = (self.dummyArrow.y /
		((16 * ChartingState.conductor.stepCrotchet) *
			(ChartingState.conductor.bpm / 60) / 4) * 1000) / self.gridSize

	local noteStrumTime = Conductor.stepToTimeFromBPMChange(lastChange, dummyStep, 0)
	local noteData = math.floor(((mouseX - self.gridSize * 11) - self.gridSize) /
		self.gridSize)
	local noteSus = 0
	local noteType = nil

	local arrowSection = 0
	local stepsToDo = 0
	for i = 0, #self.__song.notes do
		if self.__song.notes[i + 1] ~= nil then
			stepsToDo = stepsToDo +
				math.round(self:getSectionBeats(arrowSection) * 4)
			if stepsToDo > Conductor.getStepFromBPMChange(lastChange, noteStrumTime, 0) then
				break
			end
			arrowSection = arrowSection + 1
		end
	end

	local mustHitSection = self.__song.notes[arrowSection + 1].mustHitSection
	local gottaHitNote = mustHitSection
	if noteData > 3 then
		gottaHitNote = not gottaHitNote
	end

	if mustHitSection then
		if noteData < 4 then
			noteData = noteData + 4
		else
			noteData = noteData - 4
		end
		gottaHitNote = not gottaHitNote
	end

	table.insert(self.__song.notes[arrowSection + 1].sectionNotes,
		{noteStrumTime, noteData, noteSus})

	local noteIndex = #self.__song.notes[arrowSection + 1].sectionNotes

	local note = ChartingNote(noteStrumTime, noteData % 4)
	note.section = arrowSection + 1
	note.index = noteIndex
	note.step = Conductor.getStepFromBPMChange(lastChange, noteStrumTime, 0)
	note.mustPress = gottaHitNote
	note.type = noteType
	note:setGraphicSize(self.gridSize, self.gridSize)
	note:updateHitbox()
	local id = (note.mustPress and note.data + 4 or note.data)
	local yval = note.step * self.gridSize
	local xval = (self.gridBox.x) + (self.gridSize * id)
	note.x = xval
	note.y = yval
	self.allNotes:add(note)

	local sustain = Graphic(note.x + (self.gridSize / 2) - 4, note.y + (self.gridSize / 2),
		8, 0, Color.convert(self.sustainColors[note.data + 1]))
	note.sustainSprite = sustain
	self.allSustains:add(sustain)

	self.curSelectedNote = self.__song.notes[arrowSection + 1].sectionNotes[noteIndex]

	return note
end

function ChartingState:getSectionTime()
	local bpm = self.__song.bpm
	local pos = 0
	for i = 0, self.curSection - 1 do
		if self.__song.notes[i + 1] ~= nil then
			if self.__song.notes[i + 1].changeBPM then
				bpm = self.__song.notes[i + 1].bpm
			end
			pos = pos + self:getSectionBeats(i) * (1000 * 60 / bpm)
		end
	end
	return pos
end

function ChartingState:getSectionBeats(section)
	if section == nil then section = self.curSection end
	local val = nil
	if self.__song.notes[section + 1] ~= nil then
		val = self.__song.notes[section + 1].sectionBeats
	end
	return val ~= nil and val or 4
end

function ChartingState:changeSection(sec)
	if sec == nil then sec = self.curSection end
	if sec > #self.__song.notes - 1 then
		sec = #self.__song.notes - 1
	elseif sec < 0 then
		sec = 0
	end
	self.curSection = sec

	self:strumPosUpdate()
	game.sound.music:seek(self:getSectionTime() / 1000)
	if self.vocals then
		self.vocals:seek(game.sound.music:tell())
	end
	game.sound.music:pause()
	if self.vocals then self.vocals:pause() end
	self:strumPosUpdate()

	local totalSteps = 0
	for i, s in ipairs(self.__song.notes) do
		local beats = 4
		if s and s.sectionBeats then beats = s.sectionBeats end
		totalSteps = totalSteps + math.round(beats * 4)
		if i >= self.curSection + 1 then break end
		if s.changeBPM and s.bpm ~= nil then
			ChartingState.conductor:setBPM(s.bpm)
		end
	end
	self.stepsToDo = totalSteps

	--self:update_UI_Section()
end

function ChartingState:addSection()
	local sec = {
		sectionBeats = 4,
		bpm = self.__song.bpm,
		changeBPM = false,
		mustHitSection = true,
		gfSection = false,
		sectionNotes = {},
		typeOfSection = 0,
		altAnim = false
	}

	table.insert(self.__song.notes, sec)
end

function ChartingState:loadJson(song)
	local formatSong = paths.formatToSongPath(song)
	local diff = ""
	if self.curDiff ~= "normal" then diff = self.curDiff end
	PlayState.loadSong(formatSong, diff)
	game.resetState()
end

function ChartingState:saveJson()
	local formatSong = paths.formatToSongPath(self.__song.song)
	local diff = ""
	if self.curDiff ~= "normal" then diff = "-" .. self.curDiff end
	local filename = formatSong .. diff

	local file = WindowDialogue.askSaveAsFile(nil, {{"JSON Files", "*.json"}},
		filename .. ".json")
	if file then
		local chartData = {song = table.clone(self.__song)}
		local json_file = io.open(file, "wb")
		json_file:write(encodeJson(chartData))
		json_file:close()
	end
end

function ChartingState:focus(f) self.focused = f end

function ChartingState:leave()
	love.mouse.setVisible(false)

	game.save.data.chartingData = self.saveData
	ChartingState.conductor = nil

	Note.chartingMode = false
end

return ChartingState
