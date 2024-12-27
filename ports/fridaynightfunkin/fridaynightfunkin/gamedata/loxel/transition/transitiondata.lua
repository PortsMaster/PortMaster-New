---@class TransitionData:Classic
local TransitionData = Classic:extend("TransitionData")

function TransitionData:new(duration, color)
	self.duration = duration
	self.color = color or Color.BLACK
end

function TransitionData:start()
	self.timer = 0
end

function TransitionData:cancel()
	self.timer = self.duration
end

function TransitionData:update(dt)
	self.timer = self.timer + dt
	if self.timer >= self.duration then
		self:finish()
	end
end

function TransitionData:draw()
	local a, color = self.timer / self.duration, self.color
	if self.status == "in" then a = -a + 1 end
	love.graphics.setColor(color[1], color[2], color[3], a)
	love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

return TransitionData
