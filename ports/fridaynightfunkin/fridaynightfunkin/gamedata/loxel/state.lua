---@class State:Group
local State = Group:extend("State")

State.defaultTransIn = nil
State.defaultTransOut = nil

function State:new()
	State.super.new(self)

	self.persistentUpdate = false
	self.persistentDraw = true

	self.skipTransIn = false
	self.skipTransOut = false
	self.currentTransition = nil
	self.exiting = false
end

function State:enter()
	if self.skipTransIn or (self.parent and self.currentTransition) then return end

	local transIn = self.transIn or State.defaultTransIn
	if transIn then
		self.currentTransition = Transition(transIn, "in", self)
	end
end

function State:openSubstate(substate)
	self.substate = substate
	substate.parent = self
	game.openSubstate(substate)
end

function State:closeSubstate()
	if self.substate then
		game.closeSubstate(self.substate)
		self.substate = nil
	end
end

function State:discardTransition()
	local transition = self.currentTransition
	if transition and not self.exiting then
		transition:cancel()
		self.currentTransition = nil
	end
end

function State:startOutro(onOutroComplete)
	local transOut = self.transOut or State.defaultTransOut
	if self.skipTransOut or not transOut then
		onOutroComplete()
	elseif self.exiting and self.currentTransition then
		self.currentTransition.callback = onOutroComplete
	else
		self:discardTransition()
		self.exiting, self.currentTransition = true, Transition(transOut, "out", self, onOutroComplete)
	end
end

return State
