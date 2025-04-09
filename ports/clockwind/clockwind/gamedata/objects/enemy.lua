Enemy = class("Enemy")

function Enemy:initialize(x, y, t)
	self.t = t
	if self.t == "dino1" then
		self.w = DINO1_width
		self.h = DINO1_height
	elseif self.t == "bandit" then
		self.w = BANDIT_width
		self.h = BANDIT_height
	end

	self.x = x+(TILE-self.w)/2
	self.y = y-self.h

	--physics
	self.category = 6
	self.mask = {true, true, true, false, true, true, true}

	self.active = true
	self.static = false

	self.carryable = false
	self.grabbed = false

	if self.t == "dino1" then
		self.dir = "left"
		self.speed = DINO1_speed
		self.sx = -self.speed
		self.sy = 0

		self.animtimer = 0
		self.frame = 1
		self.turning = false
		self.turntimer = 0
		self.turndir = "right"
	elseif self.t == "bandit" then
		self.speed = BANDIT_speedslow
		self.dir = "left"
		self.sx = -self.speed
		self.sy = 0

		self.animtimer = 0
		self.frame = 1
	end

	self.initialupdate = true
end

function Enemy:update(dt)
	--DINOSAUR
	if self.t == "dino1" then
		--movement
		self.ground = (self.sy == 0)
		if self.bones or self.turning then
			self.sx = 0
		else
			if self.dir == "left" then
				self.sx = -self.speed
			elseif self.dir == "right" then
				self.sx = self.speed
			end
		end

		--carry player
		local p = obj["player"][1]
		if p.x+p.w > self.x and p.x < self.x+self.w and p.y+p.h == self.y then
			if not insidewall(map, p.x+self.sx*dt, p.y, p.w, p.h) then
				p.x = p.x+self.sx*dt
			end
		end

		--die in the future lol
		if timetraveling or self.initialupdate then
			if timeperiod <= 2 then
				self.bones = false
			else
				self.bones = true
			end
			if self.initialupdate then
				self.initialupdate = false
			end
		end

		if not self.bones then
			if not self.turning then
				self.animtimer = self.animtimer + dt
				while self.animtimer > DINO1_animdelay do
					self.frame = self.frame + 1
					if self.frame > 2 then
						self.frame = 1
					end
					self.animtimer = self.animtimer - DINO1_animdelay
				end
			else
				self.turntimer = self.turntimer + dt
				if self.turntimer > DINO1_turntime then
					if self.turndir == "right" then
						self.dir = "right"
						self.sx = self.speed
					else
						self.dir = "left"
						self.sx = -self.speed
					end
					self.frame = 1
					self.turning = false
					self.turntimer = 0
				elseif self.turntimer > DINO1_turntime/2 then
					self.frame = 4
				else
					self.frame = 3
				end
			end
		end
	elseif self.t == "bandit" then
		self.speed = BANDIT_speedslow+((BANDIT_speedfast-BANDIT_speedslow)*((timep-1)/2))
		if self.dir == "right" then
			self.sx = self.speed
		else
			self.sx = -self.speed
		end

		--turn around
		local tx, ty = math.floor((self.x+self.w/2)/TILE)+1, math.floor((self.y+self.h+0.1)/TILE)+1
		if map:getCollision(tx, ty) then
			if self.dir == "left" and not map:getCollision(math.floor((self.x)/TILE)+1, ty) then
				self.dir = "right"
				self.sx = self.speed
			elseif self.dir == "right" and not map:getCollision(math.floor((self.x+self.w)/TILE)+1, ty) then
				self.dir = "left"
				self.sx = -self.speed
			end
		end

		--carrying
		if self.carrying then
			local cx, cy = self.x+self.w+BANDIT_carryx, self.y+BANDIT_carryy
			if self.dir == "left" then
				cx = self.x-BANDIT_carryx
			end
			self.carrying:carrymove(self.dir, cx, cy)
		end
		--animation
		self.animtimer = self.animtimer + dt
		local delay = BANDIT_animdelayslow+((BANDIT_animdelayfast-BANDIT_animdelayslow)*((timep-1)/2))
		while self.animtimer > delay do
			self.frame = self.frame + 1
			if self.frame > 2 then
				self.frame = 1
			end
			self.animtimer = self.animtimer - delay
		end
	end

	--level editor (Delete maybe?)
	if self.y > map.h*TILE then
		self.delete = true
	end
end

function Enemy:draw()
	if self.t == "dino1" then
		love.graphics.setColor(1,1,1,1)
		local dirscale = 1
		if self.dir == "right" then
			dirscale = -1
		end
		drawtime(dinoimg, {dinoq[1][self.frame],dinoq[2][self.frame],dinoq[3][self.frame]}, self.x+self.w/2, self.y+self.h, 0, dirscale, 1, 32, 40)
	elseif self.t == "bandit" then
		love.graphics.setColor(1,1,1,1)
		local dirscale = 1
		if self.dir == "right" then
			dirscale = -1
		end
		drawtime(banditimg, {banditq[1][self.frame],banditq[2][self.frame],banditq[3][self.frame]}, self.x+self.w/2, self.y+self.h, 0, dirscale, 1, 10, 40)
	end
end

function Enemy:grab()
	if not self.carryable then
		return false
	end
	self.grabbed = true
	self.static = true
	return true
end

function Enemy:collide(side, a, b)
	--platforms
	if a == "tile" and map:getProp(b.tx, b.ty, "platform") and side ~= "down" then
		return false
	end

	if self.t == "dino1" then
		if a == "player" then
			return false
		elseif not self.turning then
			--start turning
			if side == "left" and self.dir == "left" then
				self.turndir = "right"
				self.turning = true
				self.turntimer = 0
			elseif side == "right" and self.dir == "right" then
				self.turndir = "left"
				self.turning = true
				self.turntimer = 0
			end
		end
	elseif self.t == "bandit" then
		if (not self.carrying) and b.grabbable then
			local success, carryobject = b:grab()
			if success then
				self.carrying = carryobject or b
				return false
			end
		end

		if side == "left" then
			self.sx = math.abs(self.sx)
			self.dir = "right"
		elseif side == "right" then
			self.sx = -math.abs(self.sx)
			self.dir = "left"
		end
	end
	return true
end

function Enemy:die()
	if self.carrying then
		local c = self.carrying
		local x1, x2 = insidewall(map, c.x, c.y, c.w, c.h, c.checkbreakable)
		self.carrying:toss(self.dir)
		if x1 then
			if self.dir == "left" then
				self.carrying.x = x2
			else
				self.carrying.x = x1-self.carrying.w
			end
		end
		self.carrying = nil
	end
	makepoof(self.x+self.w/2, self.y+self.h/2)
	playSound("hurt")
	self.delete = true
end