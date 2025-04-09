---@class Substate:State
local Substate = State:extend("Substate")

function Substate:new()
	Substate.super.new(self)

	self.parent = nil
end

function Substate:belongsToParent()
	return self.parent and self.parent.substate == self
end

function Substate:update(dt)
	if self:belongsToParent() and self.parent.persistentUpdate then
		self.parent:update(dt)
	end
	Substate.super.update(self, dt)
end

function Substate:draw()
	if self:belongsToParent() and self.parent.persistentDraw then
		self.parent:draw()
	end
	Substate.super.draw(self)
end

function Substate:close()
	if self:belongsToParent() then self.parent:closeSubstate() end
end

return Substate
