local CancellableEvent = require "funkin.backend.scripting.events.cancellable"

local GameOverEvent = CancellableEvent:extend("GameOverEvent")

function GameOverEvent:new()
	GameOverEvent.super.new(self)

	self.pauseGame = true
	self.pauseSong = true

	self.characterName = 'bf-dead'
	self.deathSoundName = 'gameplay/fnf_loss_sfx'
	self.loopSoundName = 'gameOver'
	self.endSoundName = 'gameOverEnd'
end

function GameOverEvent:cancelPauseGame()
	self.pauseGame = false
end

function GameOverEvent:cancelPauseSong()
	self.pauseSong = false
end

return GameOverEvent
