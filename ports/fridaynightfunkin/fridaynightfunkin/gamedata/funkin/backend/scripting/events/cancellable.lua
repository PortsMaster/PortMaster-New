local CancellableEvent = Object:extend("CancellableEvent")

CancellableEvent.cancelled = false
CancellableEvent.__continueCalls = true

CancellableEvent.data = {}

function CancellableEvent:cancel(continue)
	self.cancelled = true
	self.__continueCalls = continue
end

function CancellableEvent:recycle()
	self.data = {}
	self.cancelled = false
	self.__continueCalls = true
end

return CancellableEvent
