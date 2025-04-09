-- need rework

---@class Transition:Classic
local Transition = Classic:extend("Transition")

function Transition.__init(width, height, group)
	Transition.width = width
	Transition.height = height
	Transition.group = group
end

function Transition:new(data, status, state, callback)
	local group = Transition.group
	if not group or not data or not data.start then
		return callback()
	end

	self.data = data
	self.status = status
	self.state = state
	self.callback = callback
	self.group = group
	self.running = true
	for i, v in pairs(data) do
		if not self[i] then self[i] = v end
	end

	group:add(self)
	data.start(self)
end

function Transition:cancel()
	self.__remove = true
	self.running = false
	self.data.cancel(self)
	if self.state then self.state.currentTransition = nil end
end

function Transition:finish()
	if not self.running then return end

	self:cancel()
	if self.callback then self.callback() end
end

function Transition:update(dt)
	if not self.running then return end
	self.data.update(self, dt)
end

function Transition:__render()
	self.data.draw(self)
	if self.__remove then self.group:remove(self) end
end

return Transition
