local StoryMenuState = State:extend("StoryMenuState")

local StoryCharacter = require "funkin.ui.storymenu.character"
local StoryWeek = require "funkin.ui.storymenu.week"

StoryMenuState.curDifficulty = 2

function StoryMenuState:enter()
	self.notCreated = false

	self.script = Script("data/states/storymenu", false)
	local event = self.script:call("create")
	if event == Script.Event_Cancel then
		StoryMenuState.super.enter(self)
		self.notCreated = true
		self.script:call("postCreate")
		return
	end

	-- Update Presence
	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Story Menu"})
	end

	self.lerpScore = 0
	self.intendedScore = 0

	self.inSubstate = false

	self.persistentUpdate = true
	self.persistentDraw = true

	self.movedBack = false
	self.selectedWeek = false
	self.diffs = {"Easy", PlayState.defaultDifficulty, "Hard"}

	PlayState.storyMode = true

	self.scoreText = Text(10, 10, "SCORE: 49324858",
		paths.getFont('vcr.ttf', 36), Color.WHITE, 'right')
	self.scoreText.antialiasing = false

	self.txtWeekTitle = Text(game.width * 0.7, 10, "",
		paths.getFont('vcr.ttf', 32), Color.WHITE, 'right')
	self.txtWeekTitle.alpha = 0.7
	self.txtWeekTitle.antialiasing = false

	local ui_tex = paths.getSparrowAtlas(
		'menus/storymenu/campaign_menu_UI_assets');
	local bgYellow =
		Graphic(0, 56, game.width, 386, Color.fromRGB(249, 207, 81))

	self.weekList = MenuList(paths.getSound("scrollMenu"), true, "centered")
	self.weekList.changeCallback = bind(self, self.changeWeek)
	self:add(self.weekList)

	local blackBar = Graphic(0, 0, game.width, 56, Color.BLACK)
	self:add(blackBar)

	self.grpWeekCharacters = Group()

	self.grpLocks = Group()
	self:add(self.grpLocks)

	self.weeksData = {}
	self:loadWeeks()
	local l = #self.weeksData
	if l ~= 0 and self.weekList.curSelected > l then
		self.weekList.curSelected = l
	end

	if #self.weeksData > 0 then
		for i, week in pairs(self.weeksData) do
			local weekThing = StoryWeek(0, bgYellow.y + bgYellow.height + 10,
				week.sprite)

			self.weekList:add(weekThing)
			weekThing.spaceFactor = 1
			weekThing.yAdd = game.height * 0.68

			if week.locked then
				local lock = Sprite(weekThing.width + 10 + weekThing.x)
				lock:setFrames(ui_tex)
				lock:addAnimByPrefix('lock', 'lock')
				lock:play('lock')

				weekThing.attach = lock
			end
		end

		local charTable = self.weeksData[self.weekList.curSelected].characters
		for char = 0, 2 do
			local weekCharThing = StoryCharacter(
				(game.width * 0.25) * (1 + char) - 150,
				charTable[char + 1])
			weekCharThing.y = weekCharThing.y + 70
			self.grpWeekCharacters:add(weekCharThing)
		end

		self.difficultySelector = SpriteGroup()
		self:add(self.difficultySelector)

		self.leftArrow = Sprite(0, self.weekList.members[1].y)
		self.leftArrow:setFrames(ui_tex)
		self.leftArrow:addAnimByPrefix('idle', "arrow left")
		self.leftArrow:addAnimByPrefix('press', "arrow push left")
		self.leftArrow:play('idle')
		self.difficultySelector:add(self.leftArrow)

		self.sprDifficulty = Sprite(0, self.leftArrow.y)
		self.difficultySelector:add(self.sprDifficulty)

		self.rightArrow = Sprite(self.leftArrow.x + 376, self.leftArrow.y)
		self.rightArrow:setFrames(ui_tex)
		self.rightArrow:addAnimByPrefix('idle', "arrow right")
		self.rightArrow:addAnimByPrefix('press', "arrow push right")
		self.rightArrow:play('idle')
		self.difficultySelector:add(self.rightArrow)

		local grp = self.weekList.members[1]
		self.difficultySelector.x = grp.x + grp.width + 10
	end

	self:add(bgYellow)
	self:add(self.grpWeekCharacters)

	if #self.weeksData == 0 then
		self.noWeeksTxt = AtlasText(0, 210, 'No weeks here', "bold")
		self.noWeeksTxt:screenCenter('x')
		self:add(self.noWeeksTxt)
	end

	self.txtTrackList = Text(game.width * 0.05,
		bgYellow.x + bgYellow.height + 100, "TRACKS",
		paths.getFont('vcr.ttf', 32),
		Color.fromRGB(229, 87, 119), 'center')
	self.txtTrackList.visible = (#self.weeksData > 0)
	self.txtTrackList.antialiasing = false
	self:add(self.txtTrackList)
	self:add(self.scoreText)
	self:add(self.txtWeekTitle)

	self.throttles = {}
	self.throttles.left = Throttle:make({controls.down, controls, "ui_left"})
	self.throttles.right = Throttle:make({controls.down, controls, "ui_right"})

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

	if #self.weeksData > 0 then
		self:changeWeek()
		self.weekList:changeSelection()
		self:changeDifficulty()
	end

	StoryMenuState.super.enter(self)

	self.script:call("postCreate")
end

local tweenDifficulty = Timer.new()
function StoryMenuState:update(dt)
	self.script:call("update", dt)
	if self.notCreated then
		StoryMenuState.super.update(self, dt)
		self.script:call("postUpdate")
		return
	end

	self.lerpScore = util.coolLerp(self.lerpScore, self.intendedScore, 30, dt)
	self.scoreText.content = 'LEVEL SCORE:' .. math.round(self.lerpScore)

	if #self.weeksData > 0 and not self.movedBack and not self.selectedWeek and
		not self.inSubstate and self.throttles then
		if controls:down("ui_left") then
			self.leftArrow:play('press')
		else
			self.leftArrow:play('idle')
		end
		if controls:down("ui_right") then
			self.rightArrow:play('press')
		else
			self.rightArrow:play('idle')
		end

		if self.throttles.left:check() then self:changeDifficulty(-1) end
		if self.throttles.right:check() then self:changeDifficulty(1) end

		if controls:pressed("accept") then self:selectWeek() end
	end

	if controls:pressed("back") and not self.movedBack and not self.selectedWeek and
		not self.inSubstate then
		util.playSfx(paths.getSound("cancelMenu"))
		self.movedBack = true
		game.switchState(MainMenuState())
	end

	StoryMenuState.super.update(self, dt)

	tweenDifficulty:update(dt)

	self.script:call("postUpdate", dt)
end

function StoryMenuState:selectWeek()
	if not self.weeksData[self.weekList.curSelected].locked then
		local songTable = {}
		local leWeek = self.weeksData[self.weekList.curSelected]
		for i = 1, #leWeek.songs do
			table.insert(songTable, leWeek.songs[i])
		end

		local diff = (leWeek.difficulties and leWeek.difficulties[StoryMenuState.curDifficulty] or
			self.diffs[StoryMenuState.curDifficulty])

		local toState = PlayState(true, songTable, diff)
		PlayState.storyWeek = leWeek.name
		PlayState.storyWeekFile = leWeek.file

		if not self.selectedWeek then
			util.playSfx(paths.getSound('confirmMenu'))
			self.weekList.members[self.weekList.curSelected]:startFlashing()
			for _, char in pairs(self.grpWeekCharacters.members) do
				if char.character ~= '' and char.hasConfirmAnimation then
					char:play('confirm')
				end
			end
			self.selectedWeek = true
			self.weekList.lock = true
		end

		Timer.after(1, function() game.switchState(toState) end)
	else
		util.playSfx(paths.getSound('cancelMenu'))
	end
end

function StoryMenuState:changeDifficulty(change)
	if change == nil then change = 0 end
	local songDiffs = self.weeksData[self.weekList.curSelected].difficulties or
		self.diffs

	StoryMenuState.curDifficulty = StoryMenuState.curDifficulty + change
	StoryMenuState.curDifficulty = (StoryMenuState.curDifficulty - 1) % #songDiffs + 1

	local storyDiff = songDiffs[StoryMenuState.curDifficulty]
	local newImage = paths.getImage('menus/storymenu/difficulties/' ..
		paths.formatToSongPath(storyDiff))

	if self.sprDifficulty.texture ~= newImage then
		self.sprDifficulty:loadTexture(newImage)
		local area = (self.leftArrow.x + self.leftArrow.width) + self.rightArrow.x
		self.sprDifficulty.x = (area - self.sprDifficulty.width) / 2
		self.sprDifficulty.y = self.leftArrow.y - 15
		self.sprDifficulty.alpha = 0

		Timer:cancelTweensOf(tweenDifficulty)
		tweenDifficulty:tween(0.07, self.sprDifficulty,
			{y = self.leftArrow.y + 15, alpha = 1})
	end

	self.intendedScore = Highscore.getWeekScore(self.weeksData[self.weekList.curSelected].file,
		songDiffs[StoryMenuState.curDifficulty])
end

function StoryMenuState:changeWeek(change)
	local leWeek = self.weeksData[self.weekList.curSelected]
	self.txtWeekTitle.content = leWeek.name:upper()
	self.txtWeekTitle.x = game.width - (self.txtWeekTitle:getWidth() + 10)

	for _, spr in pairs(self.difficultySelector.members) do
		spr.visible = not leWeek.locked
	end

	self:updateText()
end

function StoryMenuState:updateText()
	local weekTable = self.weeksData[self.weekList.curSelected].characters
	for i = 1, #weekTable do
		self.grpWeekCharacters.members[i]:changeCharacter(weekTable[i])
	end

	local leWeek = self.weeksData[self.weekList.curSelected]
	local songs = table.concat(leWeek.songs, "\n")
	self.txtTrackList.content = 'TRACKS\n\n' .. songs
	self.txtTrackList:screenCenter("x")
	self.txtTrackList.x = self.txtTrackList.x - game.width * 0.35

	self.intendedScore = Highscore.getWeekScore(self.weeksData[self.weekList.curSelected].file,
		leWeek.difficulties
		and leWeek.difficulties[StoryMenuState.curDifficulty]
		or self.diffs[StoryMenuState.curDifficulty])
end

function StoryMenuState:closeSubstate()
	self.inSubstate = false
	StoryMenuState.super.closeSubstate(self)
end

function StoryMenuState:loadWeeks()
	local func = Mods.currentMod and paths.getMods or function(...)
		return paths.getPath(..., false)
	end
	if paths.exists(func('data/weekList.txt'), 'file') then
		for _, week in pairs(paths.getText('weekList'):gsub('\r', ''):split('\n')) do
			local data = paths.getJSON('data/weeks/weeks/' .. week)
			if not data.hide_sm then
				data.file = week
				table.insert(self.weeksData, data)
			end
		end
	else
		for _, str in pairs(love.filesystem.getDirectoryItems(func('data/weeks/weeks'))) do
			if str:endsWith('.json') then
				local week = str:withoutExt()
				local data = paths.getJSON('data/weeks/weeks/' .. week)
				if not data.hide_sm then
					data.file = week
					table.insert(self.weeksData, data)
				end
			end
		end
	end
end

function StoryMenuState:leave()
	self.script:call("leave")
	if self.notCreated then
		self.script:call("postLeave")
		return
	end

	for _, v in ipairs(self.throttles) do v:destroy() end
	self.throttles = nil

	self.script:call("postLeave")
end

return StoryMenuState
