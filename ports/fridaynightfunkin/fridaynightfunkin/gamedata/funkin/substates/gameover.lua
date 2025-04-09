local GameOverSubstate = Substate:extend("GameOverSubstate")
GameOverSubstate.deaths = 0

function GameOverSubstate.resetVars()
	GameOverSubstate.characterName = 'bf-dead'
	GameOverSubstate.deathSoundName = 'gameplay/fnf_loss_sfx'
	GameOverSubstate.loopSoundName = 'gameOver'
	GameOverSubstate.endSoundName = 'gameOverEnd'
	GameOverSubstate.loseImageName = 'skins/default/lose'
end

GameOverSubstate.resetVars()

function GameOverSubstate:new(x, y)
	GameOverSubstate.super.new(self)

	Timer.setSpeed(1)

	self.isFollowing = false

	self.playingDeathSound = false
	self.startedDeath = false
	self.isEnding = false
	self.followTime = 0.5
	self._followTime = 0

	self.bg = Graphic(0, 0, 1, 1, Color.BLACK)
	self.bg.alpha = 0
	self.bg.scale.x, self.bg.scale.y = game.width * 3, game.height * 3
	self.bg:screenCenter()
	self.bg:updateHitbox()
	self.bg:setScrollFactor()
	self:add(self.bg)

	self.boyfriend = Character(x, y, GameOverSubstate.characterName, true)
	self:add(self.boyfriend)

	local boyfriendMidpointX, boyfriendMidpointY = self.boyfriend:getGraphicMidpoint()
	self.camFollow = {x = boyfriendMidpointX, y = boyfriendMidpointY - 10}

	if love.system.getDevice() == "Mobile" then
		local camButtons = Camera()
		game.cameras.add(camButtons, false)

		self.buttons = VirtualPadGroup()
		local w = 134

		local enter = VirtualPad("return", game.width - w, game.height - w)
		enter.color = Color.GREEN
		local back = VirtualPad("escape", enter.x - w, enter.y)
		back.color = Color.RED

		self.buttons:add(enter)
		self.buttons:add(back)
		self.buttons:set({cameras = {camButtons}})

		self:add(self.buttons)
	end

	if ClientPrefs.data.gameOverInfos then
		local lose = Sprite(game.width / 2, 23); self.lose = lose
		lose:setFrames(paths.getSparrowAtlas(GameOverSubstate.loseImageName))
		lose:addAnimByPrefix("lose", "lose", 24, false)

		local frame = lose.__animations.lose.frames; frame = frame[#frame]
		if frame then
			lose.offset.x, lose.offset.y = frame.width / 2, -frame.offset.y
			lose.antialiasing = ClientPrefs.data.antialiasing
		else
			lose:destroy()
			lose = nil
		end
	end
end

function GameOverSubstate:enter()
	self.scripts = self.parent.scripts or ScriptsHandler()
	self.boyfriend:playAnim('firstDeath')

	game.sound.music:setPitch(1)
	paths.getMusic(GameOverSubstate.loopSoundName)
	paths.getMusic(GameOverSubstate.endSoundName)
	util.playSfx(paths.getSound(GameOverSubstate.deathSoundName))

	self.scripts:call("gameOverStart")
end

function GameOverSubstate:update(dt)
	self.scripts:call("gameOverUpdate", dt)
	GameOverSubstate.super.update(self, dt)

	if not self.isEnding then
		if controls:pressed('back') then
			self.scripts:call("gameOverQuit")

			util.playMenuMusic()
			GameOverSubstate.deaths = 0
			local state = PlayState.isStoryMode and StoryMenuState or FreeplayState
			self.parent.__stickers:start(state())
			self.isEnding = true
		end

		if controls:pressed('accept') then
			self.scripts:call("gameOverConfirm")

			self.isEnding = true
			self.boyfriend:playAnim('deathConfirm', true)
			game.sound.music:stop()
			game.sound.play(paths.getMusic(GameOverSubstate.endSoundName), ClientPrefs.data.musicVolume / 100)
			Timer.after(0.7, function()
				Timer.tween(2, self.boyfriend, {alpha = 0}, "linear", function()
					game.resetState()
					if love.system.getDevice() == "Mobile" then
						self.buttons:destroy()
					end
				end)
			end)
			Timer.tween(2, self.bg, {alpha = 1}, 'out-sine')
			Timer.tween(2, game.camera, {zoom = 0.9}, "out-cubic")
		end
	end

	if self._followTime < self.followTime then
		self._followTime = self._followTime + dt
		if self._followTime >= self.followTime then
			self.scripts:call("gameOverFollow")

			self.isFollowing = true
			game.camera:follow(self.camFollow, nil, 2.4)
			Timer.tween(1, self.bg, {alpha = 0.7}, 'in-out-sine')
			Timer.tween(1, game.camera, {zoom = 1.1}, "in-out-cubic")

			local lose, par = self.lose, self.parent
			if par and lose then
				lose.cameras = {self.parent.camOther}
				Timer.after(1 - self.followTime, function()
					if self.parent ~= par then return end
					lose:play('lose')
					self:add(lose)
				end)
			end
		end
	end

	local curAnim = self.boyfriend.curAnim
	if curAnim ~= nil then
		if curAnim.name == 'firstDeath' and self.boyfriend.animFinished then
			if self.startedDeath then
				self.boyfriend:playAnim('deathLoop')
			else
				self.scripts:call("gameOverStartLoop")

				self.startedDeath = true
				self.boyfriend:playAnim('deathLoop')
				game.sound.playMusic(paths.getMusic(GameOverSubstate.loopSoundName), ClientPrefs.data.musicVolume / 100)

				self.scripts:call("postGameOverStartLoop")
			end
		end
	end

	self.scripts:call("postGameOverUpdate", dt)
end

return GameOverSubstate
