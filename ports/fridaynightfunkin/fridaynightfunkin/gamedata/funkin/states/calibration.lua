local CalibrationState = State:extend("CalibrationState")
local grayColor = {24 / 100, 24 / 100, 24 / 100}

CalibrationState.transOut = TransitionData(0.4, grayColor)
function CalibrationState.transOut:start()
	self.timer = 0
	if game.sound.music then
		game.sound.music:fade(0.7, game.sound.music:getVolume(), 0)
	end
end

function CalibrationState:enter()
	self.notCreated = false

	self.script = Script("data/states/calibration", false)
	local event = self.script:call("create")
	if event == Script.Event_Cancel then
		self.notCreated = true
		return
	end

	self.gray = Graphic(0, 0, game.width, game.height, grayColor)
	self.gray:setScrollFactor()
	self:add(self.gray)

	CalibrationState.super.enter(self)
	game.discardTransition()

	if game.sound.music then game.sound.music:cancelFade() end
	game.sound.playMusic(paths.getMusic("chart_loop"), ClientPrefs.data.musicVolume)
end

function CalibrationState:leave()
	self.script:call("leave")
	if self.notCreated then return end
	self.script:call("postLeave")
end

return CalibrationState
