local Judgements = SpriteGroup:extend("Judgements")
Judgements.area = {width = 336, height = 135}

function Judgements:new(x, y, skin)
	Judgements.super.new(self, x, y)
	self.timer = Timer()

	self.ratingVisible = true
	self.comboNumVisible = true

	skin = skin or "default"
	self.skin = skin
	self.antialiasing = not skin:endsWith("-pixel")
end

function Judgements:update(dt)
	Judgements.super.update(self, dt)
	self.timer:update(dt)
end

function Judgements:createSprite(name, scale, duration)
	local sprite = self:recycle()
	sprite:loadTexture(paths.getImage("skins/" .. self.skin .. "/" .. name))
	sprite:setGraphicSize(math.floor(sprite.width * scale))
	sprite.x, sprite.y = 0, 0
	sprite:updateHitbox()
	sprite.alpha = 1
	sprite.antialiasing = antialias

	sprite.moves = true
	sprite.velocity.x = 0
	sprite.velocity.y = 0
	sprite.acceleration.y = 0
	sprite.antialiasing = self.antialiasing
	self.timer:after(duration, function()
		self.timer:tween(0.2, sprite, {alpha = 0}, "linear", function()
			self.timer:cancelTweensOf(sprite)
			sprite:kill()
		end)
	end)
	return sprite
end

function Judgements:spawn(rating, combo)
	local accel = PlayState.conductor.crotchet * 0.001

	if rating and self.ratingVisible then
		local areaHeight = self.area.height / 2
		local ratingSpr = self:createSprite(rating, self.antialiasing and 0.65 or 4.2, accel)
		ratingSpr.x = (self.area.width - ratingSpr.width) / 2
		ratingSpr.y = (self.area.height - ratingSpr.height) / 2 - self.area.height / 3
		ratingSpr.acceleration.y = 550
		ratingSpr.velocity.y = ratingSpr.velocity.y - math.random(140, 175)
		ratingSpr.velocity.x = ratingSpr.velocity.x - math.random(0, 10)
		ratingSpr.visible = self.ratingVisible
	end

	if combo and self.comboNumVisible and (combo > 9 or combo < 0) then
		combo = string.format(combo < 0 and "-%03d" or "%03d", math.abs(combo))
		local l, x, char, comboNum = #combo, 36
		for i = 1, l do
			char = combo:sub(i, i)
			comboNum = self:createSprite("num" .. (char == "-" and "negative" or char),
				self.antialiasing and 0.45 or 4.2, accel * 2)
			x, comboNum.x, comboNum.y = x + comboNum.width,
				x, self.area.height - comboNum.height
			comboNum.acceleration.y, comboNum.velocity.x, comboNum.velocity.y = math.random(200, 300),
				math.random(-5.0, 5.0), comboNum.velocity.y - math.random(140, 160)
		end
	end
end

function Judgements:screenCenter()
	self.x, self.y = (game.width - self.area.width) / 2,
		(game.height - self.area.height) / 2
end

return Judgements
