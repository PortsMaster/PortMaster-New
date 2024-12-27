---@class TransitionFade:TransitionData
local TransitionFade = TransitionData:extend("TransitionFade")

function TransitionFade:new(duration)
	TransitionFade.super.new(self, duration)
	if not TransitionFade.gradient then
		TransitionFade.gradient = util.newGradient("vertical", Color.BLACK, Color.BLACK, {0, 0, 0, 0})
	end
end

function TransitionFade:draw()
	if TransitionFade.gradient then
		local a = self.timer / self.duration
		local flip, y = self.status == "in"
		local height = self.height * 2
		if flip then
			y = math.remapToRange(a, 0, 1, height / 2, height * 1.5)
		else
			y = math.remapToRange(a, 0, 1, -height, 0)
		end

		love.graphics.draw(TransitionFade.gradient, 0, y, 0, self.width, flip and -height or height)
	end
end

return TransitionFade
