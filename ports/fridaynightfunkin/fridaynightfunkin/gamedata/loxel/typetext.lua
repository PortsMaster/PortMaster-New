---@class TypeText:Text
local TypeText = Text:extend("TypeText")

function TypeText:new(x, y, content, font, color, align, limit)
	TypeText.super.new(self, x, y, "", font, color, align, limit)

	self.target = content

	self.speed = 0.04
	self.timer = 0

	self.completeCallback = nil

	self.index = 0
	self.sound = nil
end

function TypeText:update(dt)
	TypeText.super.update(self, dt)

	if not self.finished then
		self.timer = self.timer + dt
		if self.timer >= self.speed then
			self:addLetter(1)
		end

		local actualTarget = self:getWrappedContent()
		if self.index == utf8.len(actualTarget) then
			self.finished = true
			if self.completeCallback then self.completeCallback() end
		end
	end
end

function TypeText:resetText(content)
	self.finished = false

	self.content = ""

	self.timer = 0
	self.index = 0
	self.target = content
end

function TypeText:forceEnd()
	self.content = self.target
	self.finished = true
	if self.completeCallback then self.completeCallback() end
end

function TypeText:addLetter(i)
	self.timer = 0
	self.index = self.index + i

	local actualTarget = self:getWrappedContent()
	self.content = string.sub(actualTarget, 1, self.index)
	if self.sound then game.sound.play(self.sound) end
end

function TypeText:getWrappedContent()
	local _, lines = self.font:getWrap(self.target, self.limit or
		self:getWidth())
	return table.concat(lines, "\n")
end

return TypeText
