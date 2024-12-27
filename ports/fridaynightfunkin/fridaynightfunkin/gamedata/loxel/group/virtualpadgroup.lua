---@class VirtualPadGroup:Group
local VirtualPadGroup = Group:extend("VirtualPadGroup")

function VirtualPadGroup:new()
	VirtualPadGroup.super.new(self)

	self.stunDelay = 0
	self.elapsedTime = 0
	self.pendingEnable = false
end

function VirtualPadGroup:set(params)
	for _, pad in ipairs(self.members) do
		for key, value in pairs(params) do
			pad[key] = value
		end
	end
end

function VirtualPadGroup:enter()
	for _, pad in ipairs(self.members) do
		if pad.enter then pad:enter() end
		self:enable()
	end
end

function VirtualPadGroup:leave()
	for _, pad in ipairs(self.members) do
		if pad.leave then pad:leave() end
		self:disable()
	end
end

function VirtualPadGroup:enable(delay)
	self.stunDelay = delay or 0.2
	self.elapsedTime = 0
	self.pendingEnable = true

	self:set({visible = true})
end

function VirtualPadGroup:update(dt)
	VirtualPadGroup.super.update(self, dt)

	if self.pendingEnable then
		self.elapsedTime = self.elapsedTime + dt

		if self.elapsedTime >= self.stunDelay then
			self:set({stunned = false})
			self.pendingEnable = false
		end
	end
end

function VirtualPadGroup:disable()
	self:set({visible = false, stunned = true})
end

return VirtualPadGroup
