local DialogueBox = SpriteGroup:extend("DialogueBox")

function DialogueBox:new(dialogueList, delayFirst)
	DialogueBox.super.new(self)

	self.bgFade = Graphic(-200, -200,
		math.floor(game.width * 1.3), math.floor(game.height * 1.3), Color.convert({179, 223, 216}))
	self.bgFade:setScrollFactor()
	self.bgFade.alpha = 0
	self:add(self.bgFade)

	for loop = 1, 5 do
		Timer.after(0.83 * loop, function()
			self.bgFade.alpha = self.bgFade.alpha + (1 / 5) * 0.7
			if self.bgFade.alpha > 0.7 then
				self.bgFade.alpha = 0.7
			end
		end)
	end

	self.portraitLeft = Sprite(-20, 40)
	self.portraitLeft:setFrames(paths.getSparrowAtlas('stages/school/senpaiPortrait'))
	self.portraitLeft:addAnimByPrefix('enter', 'Senpai Portrait Enter', 24, false)
	self.portraitLeft:setGraphicSize(math.floor(self.portraitLeft.width * 6 * 0.9))
	self.portraitLeft:updateHitbox()
	self.portraitLeft:setScrollFactor()
	self:add(self.portraitLeft)
	self.portraitLeft.visible = false
	self.portraitLeft.antialiasing = false

	self.portraitRight = Sprite(0, 40)
	self.portraitRight:setFrames(paths.getSparrowAtlas('stages/school/bfPortrait'))
	self.portraitRight:addAnimByPrefix('enter', 'Boyfriend portrait enter', 24, false)
	self.portraitRight:setGraphicSize(math.floor(self.portraitRight.width * 6 * 0.9))
	self.portraitRight:updateHitbox()
	self.portraitRight:setScrollFactor()
	self:add(self.portraitRight)
	self.portraitRight.visible = false
	self.portraitRight.antialiasing = false

	self.box = Sprite(-20, 45)
	self.box.antialiasing = false

	local hasDialog = true
	switch(PlayState.SONG.song:lower(), {
		["senpai"] = function()
			self.box:setFrames(paths.getSparrowAtlas('stages/school/pixelUI/dialogueBox-pixel'))
			self.box:addAnimByPrefix('normalOpen', 'Text Box Appear', 24, false)
			self.box:addAnimByIndices('normal', 'Text Box Appear', {4}, "", 24)
		end,
		["roses"] = function()
			self.box:setFrames(paths.getSparrowAtlas('stages/school/pixelUI/dialogueBox-senpaiMad'))
			self.box:addAnimByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false)
			self.box:addAnimByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', {4}, nil, 24)
		end,
		["thorns"] = function()
			self.box:setFrames(paths.getSparrowAtlas('stages/school-evil/pixelUI/dialogueBox-evil'))
			self.box:addAnimByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false)
			self.box:addAnimByIndices('normal', 'Spirit Textbox spawn', {11}, nil, 24)

			local face = Sprite(250, -90)
			face.antialiasing = false
			face:loadTexture(paths.getImage('stages/school-evil/spiritFaceForward'))
			face:setGraphicSize(math.floor(face.width * 6))
			self:add(face)
		end,
		default = function()
			hasDialog = false
		end
	})

	self.dialogueList = dialogueList

	if not hasDialog then
		return
	end

	self.box:play('normalOpen')
	self.box:setGraphicSize(math.floor(self.box.width * 6 * 0.9))
	self.box:updateHitbox()
	self:add(self.box)

	self.box:screenCenter('x')
	self.portraitLeft:screenCenter('x')

	self.handSelect = Sprite(1042, 590)
	self.handSelect:loadTexture(paths.getImage('stages/school/pixelUI/hand_textbox'))
	self.handSelect:setGraphicSize(math.floor(self.handSelect.width * 6 * 0.9))
	self.handSelect:updateHitbox()
	self.handSelect.visible = false
	self.handSelect.antialiasing = false
	self:add(self.handSelect)

	self.swagDialogue = TypeText(240, 500, "", paths.getFont('pixel.otf', 32),
		Color.convert({63, 32, 33}), 'left', math.floor(game.width * 0.6))
	self.swagDialogue.sound = paths.getSound("gameplay/pixelText")
	self.swagDialogue.antialiasing = false
	self.swagDialogue:setOutline("simple", 2, {x = 4, y = 4}, Color.convert({216, 148, 148}))
	self:add(self.swagDialogue)

	if PlayState.SONG.song:lower() == 'thorns' then
		self.swagDialogue.color = Color.WHITE
		self.swagDialogue.outline.color = Color.BLACK
	end

	self.curCharacter = 'dad'
	self.finishThing = nil
	self.isEnding = false

	self.delayFirst = delayFirst or 0

	self.dialogueOpened = false
	self.dialogueStarted = false
	self.dialogueEnded = false

	if love.system.getDevice() == "Mobile" then
		self.button = VirtualPad("return", 0, 0, game.width, game.height, false)
		self:add(self.button)
	end
end

function DialogueBox:update(dt)
	if self.box.curAnim then
		if self.box.curAnim.name == 'normalOpen' and self.box.animFinished then
			self.box:play('normal')
			if self.delayFirst > 0 then
				Timer.after(self.delayFirst, function() self.dialogueOpened = true end)
			else
				self.dialogueOpened = true
			end
		end
	end

	if self.dialogueOpened and not self.dialogueStarted then
		self:startDialogue()
		self.dialogueStarted = true
	end

	if self.buttons and game.keys.justPressed.ENTER or controls:pressed("accept") then
		if self.dialogueEnded then
			if self.dialogueList[2] == nil and self.dialogueList[1] ~= nil then
				if not self.isEnding then
					self.isEnding = true
					util.playSfx(paths.getSound('gameplay/clickText'))

					for loop = 1, 5 do
						Timer.after(0.2 * loop, function()
							self.box.alpha = self.box.alpha - 1 / 5
							self.bgFade.alpha = self.bgFade.alpha - 1 / 5 * 0.7
							self.portraitLeft.visible = false
							self.portraitRight.visible = false
							self.swagDialogue.alpha = self.swagDialogue.alpha - 1 / 5
							self.handSelect.alpha = self.handSelect.alpha - 1 / 5
						end)
					end

					Timer.after(1, function()
						self.finishThing()
						self:kill()
					end)
				end
			else
				table.remove(self.dialogueList, 1)
				self:startDialogue()
				util.playSfx(paths.getSound('gameplay/clickText'))
			end
		elseif self.dialogueStarted then
			self.swagDialogue:forceEnd()
			util.playSfx(paths.getSound('gameplay/clickText'))
		end
	end

	DialogueBox.super.update(self, dt)
end

function DialogueBox:startDialogue()
	self:clearDialog()

	self.swagDialogue:resetText(self.dialogueList[1])

	self.handSelect.visible = false
	self.dialogueEnded = false

	self.swagDialogue.completeCallback = function()
		self.handSelect.visible = true
		self.dialogueEnded = true
	end

	switch(self.curCharacter, {
		["dad"] = function()
			self.portraitRight.visible = false
			if not self.portraitLeft.visible then
				self.portraitLeft.visible = (PlayState.SONG.song:lower() == 'senpai')
				self.portraitLeft:play('enter')
			end
		end,
		["bf"] = function()
			self.portraitLeft.visible = false
			if not self.portraitRight.visible then
				self.portraitRight.visible = true
				self.portraitRight:play('enter')
			end
		end
	})
end

function DialogueBox:clearDialog()
	local splitName = self.dialogueList[1]:split(':')
	self.curCharacter = splitName[1]
	self.dialogueList[1] = splitName[2]
end

return DialogueBox
