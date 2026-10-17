Player = {}
Player.__index = Player

JUMP_POWER = -300
GRAVITY = 1000
PLAYER_WIDTH = 14
PLAYER_HEIGHT = 21
PLAYER_START_X = 54

player_frames = {}
for i=0,5 do
	player_frames[i] = love.graphics.newQuad(15*i,0,15,21,128,128)
end

function Player.create()
	local self = {}
	setmetatable(self,Player)
	self:reset()
	return self
end

function Player:reset()
	self.frame = 0
	self.x = PLAYER_START_X
	self.y = 71
	self.yspeed = 0
	self.onGround = true
	self.status = 0
	self.alive = true
	self.invul = true
	self.invultime = 1
end

function Player:update(dt)
	-- Check keyboard input
	if love.keyboard.isDown('space') and self.onGround == true then
		self.yspeed = JUMP_POWER
		self.onGround = false
	end

	self.onGround = false

	-- Update position
	self.yspeed = self.yspeed + dt*GRAVITY

	if self.status == 0 then -- normal ourside
		self.y = self.y + self.yspeed*dt
		if self.y > 71 then
			self.y = 71
			self.yspeed = 0
			self.onGround = true
		end
	
	elseif self.status == 3 then -- inside train
		self.y = self.y + self.yspeed*dt
		if self.y > 66 then
			self.y = 66
			self.yspeed = 0
			self.onGround = true
		elseif self.y < 60 then
			self.y = 60
			self.yspeed = 0
		end

	elseif self.status == 1 then -- hit by train
		self.y = self.y + self.yspeed*dt
		self.x = self.x - dt*300
	
	elseif self.status == 4 then -- falling through ground
		self.y = self.y + 150*dt
		if self.y > HEIGHT+10 then
			scrn_shake = 0.25
			auHit:stop() auHit:play()
			self.status = 1
		end

	elseif self.status == 5 then -- hit by mountain
		self.x = self.x - global_speed * dt * TRACK_SPEED * 1.5
	end

	-- Update walk frame
	self.frame = (self.frame + 20*dt) % 6

	-- Update invulnerability
	if self.invultime > 0 then
		self.invultime = self.invultime - dt
		if self.invultime <= 0 then
			self.invul = false
		end
	end
end

function Player:draw()
	if self.status == 0 then
		if self.invul == false or math.floor(self.frame) % 2 == 0 then
			love.graphics.draw(imgSprites,player_frames[math.floor(self.frame)],self.x,self.y)
		end

	elseif self.status == 1 or self.status == 5 then
		love.graphics.draw(imgSprites,player_frames[math.floor(self.frame)],self.x,self.y, -self.x/10, 1,1,7,10)

	else -- default case
		love.graphics.draw(imgSprites,player_frames[math.floor(self.frame)],self.x,self.y)
	end
end

function Player:kill(status)
	if self.invul == true or self.alive == false then
		return
	end

	if status ~= 4 then
		scrn_shake = 0.25
		auHit:stop() auHit:play()
	end

	if coffee >= 5 then
		self.invul = true
		self.invultime = 1
		coffee = 0
	else
		self.alive = false
		self.status = status
		if status == 1 then
			if self.yspeed > -100 then
				self.yspeed = -100
			end
		end
	end

	score = math.floor(score)
	if score > highscore[difficulty] then
		highscore[difficulty] = score
	end
end

function Player:collideWithTrain()
	if train.alive == false then
		return
	end

	if self.status == 0 then
		-- check collision with front of train
		if Player.collideWithPoint(self,train.x+4,train.y+10) or
		Player.collideWithPoint(self,train.x+2,train.y+24) then
			if train.type == 1 then -- hit by closed train
				self:kill(1)

			elseif train.type == 2 then -- hit by open train
				if self.yspeed >= 0 then
					self.status = 3
				else
					self:kill(1)
				end
			end
		-- check if landed on train
		elseif train.x < self.x and train.x+125 > self.x and self.yspeed > 0 then
			if self.y > 35 then
				self.y = 35
				self.yspeed = 0
				self.onGround = true
			end
		end
	end

	if self.status == 3 then -- inside open train
		if self.x > train.x+135 then
			self.status = 0
		elseif train.hasCoffee == true and
		self:collideWithPoint(train.x+57,train.y+20) then
			train.hasCoffee = false
			coffee = coffee + 1
			if coffee > 5 then coffee = 5 end
			auCoffee:stop() auCoffee:play()
		end
	end
end

function Player:collideWithTunnel()
	if tunnel.alive == false then
		return
	end

	if self.status == 0 then
		if self.y < 47 and self.x < tunnel.x and
		self.x > tunnel.x-16 then
			self:kill(5)
		end
	end
end

function Player:collideWithBirds()
	for i,v in ipairs(birds) do
		if Player.collideWithPoint(self,v.x+5.5,v.y+5) then
			self:kill(1)
			return
		end
	end
end

function Player:collideWithGorge()
	if self.y >= 71 and self.x > gorge.x+2 and self.x < gorge.x+92 then
		self:kill(4)	
	end
end

function Player:collideWithPoint(x,y)
	if x > self.x and x < self.x+PLAYER_WIDTH
	and y > self.y and y < self.y+PLAYER_HEIGHT then
		return true
	else
		return false
	end
end

--[[ Status values:
	0 = alive
	1 = hit by train
	2 = hit by bird
	3 = inside train
	4 = falling through ground?
	5 = hit by mountain
--]]
