local TankmenBG = Sprite:extend("TankmenBG")

TankmenBG.animationNotes = {}

function TankmenBG:new(x, y, isGoingRight)
	TankmenBG.super.new(self, x, y)

	self.time = 0
	self.goingRight = isGoingRight or false
	self.tankSpeed = 0.7
	self.endingOffset = 0

	self:setFrames(paths.getSparrowAtlas('stages/tank/tankmanKilled1'))
	self:addAnimByPrefix('run', 'tankman running', 24)
	self:addAnimByPrefix('shot', 'John Shot ' .. love.math.random(1, 2), 24, false)
	self:play('run')
	self.curFrame = love.math.random(0, #self.curAnim.frames)

	self:updateHitbox()

	self:setGraphicSize(math.floor(self.width * 0.8))
	self:updateHitbox()
end

function TankmenBG:resetShit(x, y, isGoingRight)
	self:setPosition(x, y)
	self.goingRight = isGoingRight or false
	self.endingOffset = love.math.random(50, 200)
	self.tankSpeed = love.math.random(0.6, 1)
	self.flipX = self.goingRight
end

function TankmenBG:update(dt)
	TankmenBG.super.update(self, dt)

	if self.x <= game.width * -0.5 or self.x >= game.width * 1.2 then
		self.visible = false
	else
		self.visible = true
	end

	if self.curAnim.name == 'run' then
		local endDirection = (game.width * 0.74) + self.endingOffset
		if self.goingRight then
			endDirection = (game.width * 0.02) - self.endingOffset
			self.x = (endDirection + (PlayState.conductor.time - self.time) * self.tankSpeed)
		else
			self.x = (endDirection - (PlayState.conductor.time - self.time) * self.tankSpeed)
		end
	elseif self.animFinished then
		self:kill()
	end
	if PlayState.conductor.time > self.time then
		self:play('shot')
		if self.goingRight then
			self.offset.x = 200
			self.offset.y = 300
		end
	end
end

return TankmenBG
