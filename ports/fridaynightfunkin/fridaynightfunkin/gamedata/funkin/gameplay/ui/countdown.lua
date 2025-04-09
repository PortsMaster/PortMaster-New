local Countdown = SpriteGroup:extend("Countdown")

function Countdown:new()
	Countdown.super.new(self)

	self.playback = 1
	self.duration = .8
	self.data = {
		{sound = "skins/default/intro3",  image = nil},
		{sound = "skins/default/intro2",  image = "skins/default/ready"},
		{sound = "skins/default/intro1",  image = "skins/default/set"},
		{sound = "skins/default/introGo", image = "skins/default/go"}
	}
end

function Countdown:doCountdown(beat)
	local data = self.data[beat]
	if not data then return end

	if data.sound then
		util.playSfx(paths.getSound(data.sound)):setPitch(self.playback)
	end
	if data.image then
		local countdownSprite = Sprite()
		countdownSprite:loadTexture(paths.getImage(data.image))
		countdownSprite:updateHitbox()

		countdownSprite.antialiasing = self.antialiasing
		countdownSprite:centerOffsets()

		Timer.tween(self.duration, countdownSprite, {alpha = 0}, "in-out-cubic", function()
			self:remove(countdownSprite)
			countdownSprite:destroy()
		end)
		self:add(countdownSprite)
	end
end

return Countdown
