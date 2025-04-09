---@class Flicker:Classic
local Flicker = Classic:extend("Flicker")

Flicker.instances = {}

function Flicker:new(object, duration, interval, endVisiblitity, forceRestart,
					 completionCallback, progressCallback)
	if object == nil then return end
	if duration == nil then duration = 1 end
	if interval == nil then interval = 1 end
	if endVisiblitity == nil then endVisiblitity = true end
	if completionCallback == nil then completionCallback = nil end
	if progressCallback == nil then progressCallback = nil end

	self.object = object
	self.duration = duration
	self.interval = interval
	self.endVisibility = endVisiblitity
	self.forceRestart = forceRestart
	self.completionCallback = completionCallback
	self.progressCallback = progressCallback
	self.flickerTime = 0
	self.timer = 0

	table.insert(Flicker.instances, self)
end

function Flicker:update(dt)
	self.timer = self.timer + dt

	if self.timer <= self.duration then
		self.flickerTime = self.flickerTime + dt

		if self.flickerTime >= self.interval then
			self.object.visible = not self.object.visible
			self.flickerTime = self.flickerTime - self.interval
		end
	end

	if self.timer >= self.duration then
		self.object.visible = self.endVisibility
		if self.completionCallback then self.completionCallback() end
		self:destroy()
	end
end

function Flicker:destroy()
	table.delete(Flicker.instances, self)

	self.object = nil
	self.duration = 1
	self.interval = 1
	self.endVisibility = true
	self.forceRestart = false
	self.completionCallback = nil
	self.progressCallback = nil
	self.flickerTime = 0
	self.timer = 0
end

return Flicker
