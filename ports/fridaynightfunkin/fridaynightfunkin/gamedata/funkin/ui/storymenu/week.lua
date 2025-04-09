---@class StoryWeek:Sprite
local StoryWeek = Sprite:extend("StoryWeek")

function StoryWeek:new(x, y, weekName)
	StoryWeek.super.new(self, x, y)
	self:loadTexture(paths.getImage('menus/storymenu/weeks/' .. weekName))
	self.flashingInt = 0
	self.__isFlashing = false
end

function StoryWeek:startFlashing() self.__isFlashing = true end

function StoryWeek:update(dt)
	StoryWeek.super.update(self, dt)

	if self.__isFlashing then
		self.flashingInt = self.flashingInt + 1
		local fakeFramerate = math.round((1 / dt) / 10)
		if self.flashingInt % fakeFramerate >= math.floor(fakeFramerate / 2) then
			self.color = Color.fromRGB(51, 255, 255)
		else
			self.color = Color.WHITE
		end
	end
end

return StoryWeek
