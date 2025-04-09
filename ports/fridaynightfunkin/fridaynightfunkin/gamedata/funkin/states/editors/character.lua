local buildCharFile = require("funkin.backend.jsonbuilder").buildChar

local CharacterEditor = State:extend("CharacterEditor")

CharacterEditor.onPlayState = false

function CharacterEditor:enter()
	love.mouse.setVisible(true)

	Character.editorMode = true

	self.curChar = 'bf'
	self.curSelected = 1
	self.curAnim = nil
	self.isPlayer = true

	if CharacterEditor.onPlayState then
		self.curChar = PlayState.SONG.player2
		self.isPlayer = self.curChar:startsWith('bf')
	end

	self.camFollow = {x = 0, y = 0}
	self.curZoom = 1

	self.camChar = Camera()
	self.camChar.scroll = {x = 0, y = 0}
	self.camMenu = Camera()
	game.cameras.add(self.camChar, false)
	game.cameras.add(self.camMenu, false)

	local bg = Sprite(-game.width * 0.2)
	bg:loadTexture(paths.getImage('menus/menuDesat'))
	bg.color = {0.15, 0.15, 0.15}
	bg:setScrollFactor()
	self:add(bg)

	self.floor = Graphic(0, 840, game.width, 4, Color.BLACK)
	self.floor:setScrollFactor(0, 1)
	self.floor.cameras = {self.camChar}
	self:add(self.floor)

	self.bfPos = Sprite(777, 449):loadTexture(paths.getImage('editor/character/bf-white'))
	self.bfPos.cameras = {self.camChar}
	self.bfPos.alpha = 0.4
	self:add(self.bfPos)

	self.dadPos = Sprite(105, 100):loadTexture(paths.getImage('editor/character/dad-white'))
	self.dadPos.cameras = {self.camChar}
	self.dadPos.alpha = 0.4
	self:add(self.dadPos)

	self.charLayer = Group()
	self:add(self.charLayer)

	self:loadCharacter()

	if Discord then
		self.startTimestamp = os.time(os.date("*t"))
		Discord.changePresence({
			details = "Character Editor",
			state = "Character: " .. self.curChar,
			startTimestamp = self.startTimestamp
		})
	end

	self:changeAnim()

	self.camPoint1 = Graphic(0, 0, 3, 30, Color.WHITE)
	self.camPoint1.cameras = {self.camChar}
	self:add(self.camPoint1)

	self.camPoint2 = Graphic(0, 0, 30, 3, Color.WHITE)
	self.camPoint2.cameras = {self.camChar}
	self:add(self.camPoint2)

	self.blockInput = {}
	self.hoveredUI = {}

	self.charTab = ui.UITabMenu(game.width * 0.7, 0, {'Character'})
	self.charTab.width = game.width * 0.3
	self.charTab.height = game.height * 0.5
	self:add(self.charTab)

	self.animationTab = ui.UITabMenu(game.width * 0.7, self.charTab.height,
		{'Animation'})
	self.animationTab.width = game.width * 0.3
	self.animationTab.height = game.height * 0.5
	self:add(self.animationTab)

	self.animInfoTxt = Text(20, 260, '', paths.getFont('phantommuff.ttf', 20))
	self:add(self.animInfoTxt)

	self.charInfoTxt = Text(20, 50, '', paths.getFont('phantommuff.ttf', 14))
	self:add(self.charInfoTxt)

	self:add_UI_Character()

	for _, o in ipairs({
		self.charTab, self.animationTab, self.animInfoTxt, self.charInfoTxt
	}) do o.cameras = {self.camMenu} end
	CharacterEditor.super.enter(self)
end

function CharacterEditor:add_UI_Character()
	local tab_char = Group()
	tab_char.name = 'Character'

	local save_char = ui.UIButton(140, 10, 100, 20, 'Save',
		function() self:saveCharacter() end)

	local playable_check = ui.UICheckbox(10, 40, 20)
	playable_check.checked = self.isPlayer
	playable_check.callback = function()
		self.isPlayer = not self.isPlayer

		self.char.__reverseDraw = not self.char.__reverseDraw
		self.char:switchAnim("singLEFT", "singRIGHT")
		self.char:switchAnim("singLEFTmiss", "singRIGHTmiss")
		self.char:switchAnim("singLEFT-loop", "singRIGHT-loop")
		self.char.flipX = not self.char.flipX

		self.char.x = (self.isPlayer and 770 or 100) + self.char.positionTable.x
		self.char.y = 100 + self.char.positionTable.y
		self.camFollow = {x = (self.isPlayer and 350 or -310), y = 294}

		if self.char.curAnim.name:find('LEFT') or
			self.char.curAnim.name:find('RIGHT') then
			self.char:playAnim(self.curAnim[1], true)
		end
	end

	local flipX_check = ui.UICheckbox(10, 70, 20)
	flipX_check.checked = self.char.flipX
	if self.isPlayer then flipX_check.checked = not flipX_check.checked end
	flipX_check.callback = function()
		self.char.jsonFlipX = not self.char.jsonFlipX
		self.char.flipX = self.char.jsonFlipX
		if self.isPlayer then self.char.flipX = not self.char.flipX end
	end

	local camX_stepper = ui.UINumericStepper(10, 168, 10,
		self.char.cameraPosition.x, -9000,
		9000)
	camX_stepper.onChanged = function(value)
		self.char.cameraPosition.x = value
	end

	local camY_stepper = ui.UINumericStepper(camX_stepper.x + 90,
		camX_stepper.y, 10,
		self.char.cameraPosition.y, -9000,
		9000)
	camY_stepper.onChanged = function(value)
		self.char.cameraPosition.y = value
	end

	local posX_stepper = ui.UINumericStepper(camX_stepper.x,
		camX_stepper.y + 50, 10,
		self.char.positionTable.x, -9000,
		9000)
	posX_stepper.onChanged = function(value)
		self.char.positionTable.x = value
		self.char.x = (self.isPlayer and 770 or 100) + self.char.positionTable.x
	end
	local posY_stepper = ui.UINumericStepper(posX_stepper.x + 90,
		posX_stepper.y, 10,
		self.char.positionTable.y, -9000,
		9000)
	posY_stepper.onChanged = function(value)
		self.char.positionTable.y = value
		self.char.y = 100 + self.char.positionTable.y
	end

	local healthIcon_input = ui.UIInputTextBox(10, 118, 80, 20)
	healthIcon_input.text = self.char.icon
	healthIcon_input.onChanged = function(value)
		self.char.icon = value

		self.charLayer:add(self.healthIcon)
		self.healthIcon:destroy()
		self.healthIcon = HealthIcon(self.char.icon, false)
		self.healthIcon.cameras = {self.camMenu}
		self.healthIcon:setPosition(20, 157)
		self.healthIcon.scale = {x = 0.6, y = 0.6}
		self.healthIcon:updateHitbox()
		self.charLayer:add(self.healthIcon)
	end

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

	local char_dropdown = ui.UIDropDown(10, 10, optionsChar)
	char_dropdown.selectedLabel = self.curChar
	char_dropdown.onChanged = function(value)
		self.isPlayer = value:startsWith('bf')
		playable_check.checked = self.isPlayer

		self.curChar = value
		self:loadCharacter()

		if Discord then
			Discord.changePresence({
				details = "Character Editor",
				state = "Character: " .. self.curChar,
				startTimestamp = self.startTimestamp
			})
		end

		healthIcon_input.text = self.char.icon

		camX_stepper.value = tostring(self.char.cameraPosition.x)
		camY_stepper.value = tostring(self.char.cameraPosition.y)

		posX_stepper.value = tostring(self.char.positionTable.x)
		posY_stepper.value = tostring(self.char.positionTable.y)

		flipX_check.checked = self.char.flipX
		if self.isPlayer then
			flipX_check.checked = not flipX_check.checked
		end
	end

	tab_char:add(Text(38, 43, 'Playable Character'))
	tab_char:add(Text(38, 73, 'flipX'))
	tab_char:add(Text(10, 98, 'Icon'))
	tab_char:add(Text(10, camX_stepper.y - 20, 'Camera X/Y'))
	tab_char:add(Text(10, posX_stepper.y - 20, 'Position X/Y'))
	tab_char:add(flipX_check)
	tab_char:add(playable_check)
	tab_char:add(camX_stepper)
	tab_char:add(camY_stepper)
	tab_char:add(posX_stepper)
	tab_char:add(posY_stepper)
	tab_char:add(save_char)
	tab_char:add(healthIcon_input)
	tab_char:add(char_dropdown)

	table.insert(self.blockInput, healthIcon_input)
	table.insert(self.blockInput, camX_stepper)
	table.insert(self.blockInput, camY_stepper)
	table.insert(self.blockInput, posX_stepper)
	table.insert(self.blockInput, posY_stepper)

	table.insert(self.hoveredUI, save_char)

	self.charTab:addGroup(tab_char)
end

local function updateCamPoint(self)
	local midPointX, midPointY = self.char:getMidpoint()
	midPointX = midPointX + (self.isPlayer and -100 or 150)
	midPointY = midPointY + -100

	self.camPoint1.x, self.camPoint1.y = midPointX - 1.5, midPointY - 15
	self.camPoint2.x, self.camPoint2.y = midPointX - 15, midPointY - 1.5

	local camPosX, camPosY = self.char.cameraPosition.x,
		self.char.cameraPosition.y
	camPosX = (self.isPlayer and -camPosX or camPosX)

	self.camPoint1.x, self.camPoint1.y = self.camPoint1.x + camPosX,
		self.camPoint1.y + camPosY
	self.camPoint2.x, self.camPoint2.y = self.camPoint2.x + camPosX,
		self.camPoint2.y + camPosY
end

function CharacterEditor:update(dt)
	CharacterEditor.super.update(self, dt)

	local isTyping = false
	for _, inputObj in ipairs(self.blockInput) do
		if inputObj.active then
			isTyping = true
			break
		end
	end

	local mouseHovered = false
	for _, hoveredObj in ipairs(self.hoveredUI) do
		if hoveredObj.active and hoveredObj.hovered then
			mouseHovered = true
			break
		end
	end

	local mouseOnScreen = game.mouse.x >= 0 and game.mouse.x < game.width * 0.7
		and game.mouse.y >= 0 and game.mouse.y < game.height
	if mouseOnScreen and WindowUtil then
		WindowUtil.setCursor(mouseHovered and "hand" or "arrow")
	end

	if not isTyping then
		if game.keys.justPressed.SPACE then
			self.char:playAnim(self.curAnim[1], true)
		end

		local shiftMult = game.keys.pressed.SHIFT and 10 or 1

		if game.keys.pressed.A then
			self.camFollow.x = self.camFollow.x - (2 + shiftMult)
		elseif game.keys.pressed.D then
			self.camFollow.x = self.camFollow.x + (2 + shiftMult)
		end
		if game.keys.pressed.W then
			self.camFollow.y = self.camFollow.y - (2 + shiftMult)
		elseif game.keys.pressed.S then
			self.camFollow.y = self.camFollow.y + (2 + shiftMult)
		end
		if mouseOnScreen and game.mouse.pressedLeft then
			self.camFollow.x = self.camFollow.x - (game.mouse.deltaScreenX / self.curZoom)
			self.camFollow.y = self.camFollow.y - (game.mouse.deltaScreenY / self.curZoom)
		end
		if game.keys.pressed.CONTROL then
			if game.keys.justPressed.PLUS then
				self.curZoom = self.curZoom + 0.1
				if self.curZoom > 1.8 then self.curZoom = 1.8 end
			elseif game.keys.justPressed.MINUS then
				self.curZoom = self.curZoom - 0.1
				if self.curZoom < 0.1 then self.curZoom = 0.1 end
			end
		end

		if game.keys.justPressed.LEFT then
			self.curAnim[6][1] = self.curAnim[6][1] + shiftMult
			self:changeOffsets(self.curAnim[6][1], self.curAnim[6][2])
		elseif game.keys.justPressed.RIGHT then
			self.curAnim[6][1] = self.curAnim[6][1] - shiftMult
			self:changeOffsets(self.curAnim[6][1], self.curAnim[6][2])
		end
		if game.keys.justPressed.UP then
			self.curAnim[6][2] = self.curAnim[6][2] + shiftMult
			self:changeOffsets(self.curAnim[6][1], self.curAnim[6][2])
		elseif game.keys.justPressed.DOWN then
			self.curAnim[6][2] = self.curAnim[6][2] - shiftMult
			self:changeOffsets(self.curAnim[6][1], self.curAnim[6][2])
		end

		if game.keys.justPressed.Q then
			self:changeAnim(-1)
		elseif game.keys.justPressed.E then
			self:changeAnim(1)
		end

		if game.keys.justPressed.ESCAPE then
			if CharacterEditor.onPlayState then
				CharacterEditor.onPlayState = false
				game.switchState(PlayState())
			else
				util.playMenuMusic()
				game.switchState(MainMenuState())
			end
		end
	end

	self.camChar.zoom = math.lerp(self.camChar.zoom, self.curZoom, 0.08)
	self.floor.scale.x = game.width / self.camChar.zoom

	self.camChar.scroll.x, self.camChar.scroll.y =
		util.coolLerp(self.camChar.scroll.x, self.camFollow.x, 12, dt),
		util.coolLerp(self.camChar.scroll.y, self.camFollow.y, 12, dt)

	updateCamPoint(self)

	local animInfo = 'Current Animation\n' .. '\nName: ' .. self.curAnim[1] ..
		'\nOffsets: [' .. self.curAnim[6][1] .. ', ' ..
		self.curAnim[6][2] .. ']' .. '\nFPS: ' ..
		self.curAnim[4]
	self.animInfoTxt.content = animInfo

	local charInfo = 'Current Character\n' .. '\nName: ' .. self.curChar ..
		'\nImage: ' .. self.char.imageFile .. '\nIcon: ' ..
		self.char.icon .. '\nFlip X: ' ..
		tostring(self.char.jsonFlipX)
	self.charInfoTxt.content = charInfo
end

function CharacterEditor:loadCharacter()
	self.charLayer:clear()
	self.char = Character(0, 0, self.curChar, self.isPlayer)
	self.char.cameras = {self.camChar}
	self.charLayer:add(self.char)
	if self.char.animationsTable[1] ~= nil then
		self.char:playAnim(self.char.animationsTable[1][1], true)
	end

	if self.char.iconColor then
		self.iconColor = Graphic(125, 177, 40, 40, Color.fromString(self.char.iconColor))
		self.iconColor.lined = true
		self.iconColor.line.width = 3
		self.iconColor.line.color = Color.BLACK
		self.iconColor.config.round = {8, 8}
		self.iconColor.cameras = {self.camMenu}
		self.charLayer:add(self.iconColor)
	end

	self.healthIcon = HealthIcon(self.char.icon, false)
	self.healthIcon.cameras = {self.camMenu}
	self.healthIcon:setPosition(20, 157)
	self.healthIcon.scale = {x = 0.6, y = 0.6}
	self.healthIcon:updateHitbox()
	self.charLayer:add(self.healthIcon)

	self.curSelected = 1
	self.curAnim = self.char.animationsTable[self.curSelected]

	self.char.x = (self.isPlayer and 770 or 100) + self.char.positionTable.x
	self.char.y = 100 + self.char.positionTable.y

	self.camFollow = {x = (self.isPlayer and 530 or -130), y = 294}
end

function CharacterEditor:changeOffsets(x, y)
	self.char.offset.x, self.char.offset.y = x, y
	self.char.animOffsets[self.curAnim[1]] = {x = x, y = y}
end

function CharacterEditor:changeAnim(huh)
	huh = huh or 0
	self.curSelected = self.curSelected + huh

	if self.curSelected > #self.char.animationsTable then
		self.curSelected = 1
	elseif self.curSelected < 1 then
		self.curSelected = #self.char.animationsTable
	end

	self.curAnim = self.char.animationsTable[self.curSelected]
	self.char:playAnim(self.curAnim[1], true)
end

function CharacterEditor:saveCharacter()
	local file = WindowDialogue.askSaveAsFile(nil, {{"JSON Files", "*.json"}},
		self.curChar .. ".json")

	if file then
		local charData = {
			animations = self.char.animationsTable,
			sprite = self.char.imageFile,
			position = self.char.positionTable,
			icon = self.char.icon,
			color = self.char.iconColor,
			flip_x = self.char.jsonFlipX,
			antialiasing = self.char.jsonAntialiasing,
			camera_points = self.char.cameraPosition,
			sing_duration = self.char.holdTime,
			scale = self.char.jsonScale
		}

		local json_file = io.open(file, "wb")
		json_file:write(buildCharFile(charData))
		json_file:close()
	end
end

function CharacterEditor:leave()
	love.mouse.setVisible(false)
	Character.editorMode = false
	love.window.setTitle(Project.title)
end

return CharacterEditor
