local CancellableEvent = require "funkin.backend.scripting.events.cancellable"

local PopUpScoreEvent = CancellableEvent:extend("PopUpScoreEvent")

function PopUpScoreEvent:new()
	PopUpScoreEvent.super.new(self)

	self.hideRating = false
	self.hideScore = false
end

function PopUpScoreEvent:cancelRating()
	self.hideRating = true
end

function PopUpScoreEvent:cancelScore()
	self.hideScore = true
end

return PopUpScoreEvent
