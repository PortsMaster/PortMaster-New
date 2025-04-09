local CancellableEvent = require "funkin.backend.scripting.events.cancellable"

local MissEvent = CancellableEvent:extend("MissEvent")

function MissEvent:new(notefield, direction, note, character, sound)
	MissEvent.super.new(self)

	self.muteVocals = true
	self.cancelledAnim = false
	self.cancelledSadGF = false
	self.triggerSound = sound == nil and true or sound

	self.notefield = notefield
	self.direction = direction
	self.note = note
	self.character = character
end

function MissEvent:cancelAnim()
	self.cancelledAnim = true
end

function MissEvent:cancelMuteVocals()
	self.muteVocals = false
end

function MissEvent:cancelSadGF()
	self.cancelledSadGF = true
end

function MissEvent:cancelSound()
	self.triggerSound = false
end

return MissEvent
