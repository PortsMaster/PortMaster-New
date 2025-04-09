local CancellableEvent = require "funkin.backend.scripting.events.cancellable"

local CountdownCreationEvent = CancellableEvent:extend("CountdownCreationEvent")

function CountdownCreationEvent:new(data, scale, antialiasing)
	CountdownCreationEvent.super.new(self)

	self.data = data
	self.scale = scale
	self.antialiasing = antialiasing
end

return CountdownCreationEvent
