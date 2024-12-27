local TitleState = State:extend("TitleState")

TitleState.initialized = false

function TitleState:enter()
	self.notCreated = false
	self.skipTransIn = true

	self.script = Script("data/states/title", false)
	local event = self.script:call("create")
	if event == Script.Event_Cancel then
		self.notCreated = true
		TitleState.super.enter(self)
		self.script:call("postCreate")
		return
	end

	-- Update Presence
	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Title Screen"})
	end

	self.curWacky = self:getIntroTextShit()

	self.skippedIntro = false
	self.danceLeft = false
	self.confirmed = false

	self.gfDance = Sprite(game.width - 762, 40)
	self.gfDance:setFrames(paths.getSparrowAtlas("menus/title/gfDanceTitle"))
	self.gfDance:addAnimByIndices("danceLeft", "gfDance", {
		30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
	}, nil, 24, false)
	self.gfDance:addAnimByIndices("danceRight", "gfDance", {
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
	}, nil, 24, false)
	self.gfDance:play("danceRight")

	self.logoBl = Sprite(-150, -100)
	self.logoBl:setFrames(paths.getSparrowAtlas("menus/title/logoBumpin"))
	self.logoBl:addAnimByPrefix("bump", "logo bumpin", 24, false)
	self.logoBl:play("bump")
	self.logoBl:updateHitbox()

	self.titleText = Sprite(0, 590)
	self.titleText:setFrames(paths.getSparrowAtlas("menus/title/titleEnter"))
	self.titleText:addAnimByPrefix("idle", "Press Enter to Begin", 24)
	self.titleText:addAnimByPrefix("press", "ENTER PRESSED", 24)
	self.titleText:play("idle")
	self.titleText:screenCenter("x")
	self.titleText:updateHitbox()
	self.titleText.colors = {{50, 60, 205}, {50, 255, 255}}

	self.coolText = AtlasText(0, 160, "", "bold", game.width, "center")
	self:add(self.coolText)
	self.textBuffer = ""

	self.ngSpr = Sprite(0, game.height * 0.52):loadTexture(paths.getImage(
		'menus/title/newgrounds_logo'))
	self:add(self.ngSpr)
	self.ngSpr.visible = false
	self.ngSpr:setGraphicSize(math.floor(self.ngSpr.width * 0.8))
	self.ngSpr:updateHitbox()
	self.ngSpr:screenCenter("x")

	if TitleState.initialized then
		self:skipIntro()
	else
		TitleState.initialized = true
	end

	self.conductor = Conductor(102)
	self.conductor.onBeat = bind(self, self.beat)
	util.playMenuMusic(true)

	if love.system.getDevice() == "Mobile" then
		self:add(VirtualPad("return", 0, 0, game.width, game.height, false))
	end

	TitleState.super.enter(self)

	self.script:call("postCreate")
end

function TitleState:getIntroTextShit()
	local fullText = paths.getText('introText')
	local firstArray = fullText:split('\n')
	local swagGoodArray = firstArray[love.math.random(1, #firstArray)]

	return swagGoodArray:split('--')
end

function TitleState:update(dt)
	self.script:call("update", dt)
	if self.notCreated then
		TitleState.super.update(self, dt)
		self.script:call("postUpdate", dt)
		return
	end

	self.conductor.time = game.sound.music:tell() * 1000
	self.conductor:update(dt)

	if love.system.getDevice() == "Mobile" and game.keys.justPressed.ESCAPE then
		local name = love.window.getTitle()
		if #name == 0 or name == "Untitled" then name = "Game" end

		local pressed = love.window.showMessageBox("Quit " .. name .. "?", "", {"OK", "Cancel"})
		if pressed == 1 then love.event.push("quit") end
	end

	local pressedEnter = controls:pressed("accept")

	if pressedEnter and not self.confirmed and self.skippedIntro then
		self.confirmed = true
		self.titleText:play("press")
		util.playSfx(paths.getSound("confirmMenu"))
		game.camera:flash(Color.WHITE, 1)

		Timer.after(1.5, function() game.switchState(MainMenuState()) end)
	end
	self:updateEnterColor()

	if pressedEnter and not self.skippedIntro and TitleState.initialized then
		self:skipIntro()
	end
	TitleState.super.update(self, dt)

	self.script:call("postUpdate", dt)
end

function TitleState:updateEnterColor()
	local color = self.titleText.colors
	local time = love.timer.getTime()
	local t = (math.sin(time * 2 * math.pi / 5) + 1) / 2

	local alpha = 0.8
	if t <= 0.5 then
		t = t * 2
		self.titleText.color = Color.convert(Color.lerp(color[2], color[1], t))
		self.titleText.alpha = math.lerp(alpha, 0.5, t)
	else
		t = (t - 0.5) * 2
		self.titleText.color = Color.convert(Color.lerp(color[1], color[2], t))
		self.titleText.alpha = math.lerp(0.5, alpha, t)
	end

	if self.confirmed then
		self.titleText.color = Color.WHITE
		self.titleText.alpha = 1
	end
end

function TitleState:setText(text)
	if text and type(text) == "string" then text = {text} end
	local concat = text and table.concat(text, "\n") or ""
	local a = (self.textBuffer ~= "" and "\n" or "")
	self.textBuffer = self.textBuffer .. a .. concat
	if text == nil then self.textBuffer = "" end
	self.coolText.text = self.textBuffer
end

function TitleState:beat(b)
	self.logoBl:play("bump", true)

	self.danceLeft = not self.danceLeft
	if self.danceLeft then
		self.gfDance:play("danceLeft")
	else
		self.gfDance:play("danceRight")
	end

	if not self.skippedIntro then
		switch(b, {
			[{4, 12}] = function() self:setText() end,
			[1] = function() self:setText({'The', "Funkin' Crew Inc."}) end,
			[3] = function() self:setText('present') end,
			[5] = function() self:setText({'In association', 'with'}) end,
			[{7, 8}] = function()
				if b == 7 then self:setText('newgrounds') else self:setText() end
				self.ngSpr.visible = not self.ngSpr.visible
			end,
			[9] = function() self:setText({self.curWacky[1]}) end,
			[11] = function() self:setText(self.curWacky[2]) end,
			[13] = function() self:setText('Friday') end,
			[14] = function() self:setText('Night') end,
			[15] = function() self:setText('Funkin') end,
			[16] = function() self:skipIntro() end
		})
	end
end

function TitleState:skipIntro()
	if not self.skippedIntro then
		self:remove(self.ngSpr)
		self:remove(self.coolText)
		self:add(self.gfDance)
		self:add(self.logoBl)
		self:add(self.titleText)
		game.camera:flash(Color.WHITE, 4)
		self.skippedIntro = true
	end
end

function TitleState:leave()
	self.script:call("leave")
	if self.notCreated then
		self.script:call("postLeave")
		return
	end
	self.script:call("postLeave")
end

return TitleState
