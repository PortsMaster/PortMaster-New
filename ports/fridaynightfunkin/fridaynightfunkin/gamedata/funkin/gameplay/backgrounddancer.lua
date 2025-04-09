local BackgroundDancer = Sprite:extend("BackgroundDancer")

function BackgroundDancer:new(x, y)
	BackgroundDancer.super.new(self, x, y)

	self:setFrames(paths.getSparrowAtlas('stages/limo/limoDancer'))
	self:addAnimByIndices('danceLeft', 'bg dancer sketch PINK', {
		0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
	}, nil, 24, false)
	self:addAnimByIndices('danceRight', 'bg dancer sketch PINK', {
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29
	}, nil, 24, false)

	self:dance()
	self:finish()
end

BackgroundDancer.danceDir = false
function BackgroundDancer:dance()
	self.danceDir = not self.danceDir
	if self.danceDir then
		self:play('danceRight', true)
	else
		self:play('danceLeft', true)
	end
end

return BackgroundDancer
