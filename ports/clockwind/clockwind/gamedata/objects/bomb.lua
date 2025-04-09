Bomb = class("Bomb")

function Bomb:initialize(x, y)
	self.w = 15
	self.h = 15
	self.x = x+(TILE-self.w)/2
	self.y = y-self.h

	self.spawnx = self.x
	self.spawny = self.y

	--physics
	self.category = 3
	self.mask = {true, true, true, true, true, false, false, false, true}

	self.active = true
	self.static = false

	self.sx = 0
	self.sy = 0

	self.grabbable = true --can player interact
	self.carryable = true --reject carry if needed 
	self.grabbed = false
	self.bounce = false
	self.checkbreakable = true
	self.everthrown = false

	self.dir = "right"

	self.frame = 1
	self.animtimer = 0

	self.lit = true --not lit if underwater

	self.gear = false
	self.geargrabrotation = 0
end

function Bomb:update(dt)
	self.ground = (self.sy == 0)
	if self.ground then
		--ground friction
		if self.sx > 0 then
			self.sx = math.max(0, self.sx - FRICTION*dt)
		elseif self.sx < 0 then
			self.sx = math.min(0, self.sx + FRICTION*dt)
		end
	end

	if self.lit then
		if self.frame == 3 then
			self.frame = 1
		end
		self.animtimer = self.animtimer + dt
		while self.animtimer > BOMB_animdelay do
			self.frame = self.frame + 1
			if self.frame > 2 then
				self.frame = 1
			end
			self.animtimer = self.animtimer - BOMB_animdelay
		end
	end

	if waterlevel then
		self.lit = (self.y+self.h < waterlevel)
		if self.lit then
			self.checkbreakable = true
		else
			self.checkbreakable = false
			self.frame = 3
		end
	end

	--fall off
	if self.y > map.h*TILE then
		self.delete = true
	end
end

function Bomb:draw()
	love.graphics.setColor(1,1,1)
	local dirscale, offx = 1, 0
	if self.dir == "left" then
		dirscale = -1
		offx = 1
	end
	if self.lit then --we liiit
		love.graphics.draw(bombimg, bombq[self.frame], math.floor(self.x+7+offx), math.floor(self.y+8), 0, dirscale, 1, 8, 8)
	else
		love.graphics.draw(bombimg, bombq[self.frame], math.floor(self.x+7+offx), math.floor(self.y+8), 0, dirscale, 1, 8, 8)
	end
end

function Bomb:grab()
	if not self.carryable then
		return false
	end
	playSound("grab")
	if self.gear then
		self:grabgear(false)
	end
	self.grabbed = true
	self.static = true
	self.active = false
	return true
end

function Bomb:toss(dir, up) --Salad:toss()
	self.grabbed = false
	self.static = false
	self.active = true
	if dir == "left" then
		self.sx = -SEED_tossforcex
	else
		self.sx = SEED_tossforcex
	end
	if up then
		self.sx = 0
		self.sy = -SEED_tossforceyup
	else
		self.sy = -SEED_tossforcey
	end
	self.bounce = true
	self.everthrown = true --only kill enemies if it has been thrown first
end

function Bomb:carrymove(dir, x, y) --bottom, edge
	if dir == "left" then
		self.x = x-self.w
	else
		self.x = x
	end
	self.y = y-self.h
	self.dir = dir
end

function Bomb:collide(side, a, b)
	if (not self.grabbed) and a == "tile" and
		((map:getProp(b.tx, b.ty, "spikeup") and side == "down") or (map:getProp(b.tx, b.ty, "spikedown") and side == "up") or
		(map:getProp(b.tx, b.ty, "spikeleft") and side == "right") or (map:getProp(b.tx, b.ty, "spikeright") and side == "left")) then
		self:damaged()
		return false
	end

	--ignore player on gear
	if a == "player" and b.gear then
		return false
	end

	--explode
	if self.lit and (not self.grabbed) and a == "tile" and map:getProp(b.tx, b.ty, "breakable") then
		self:explode(b.tx, b.ty)
		return false
	end

	--grab onto gear
	if a == "gear" then
		if not self.gear then
			local angle = ((getangle2(self.x+self.w/2, self.y+self.h/2, b.rx, b.ry)-math.pi*.5)/math.pi)
			if (((angle > 0 and angle < .25) or (angle > 1.75)) and self.sx <= 0) or (angle > .25 and angle < .75 and self.sy >= 0) or
			(angle > .75 and angle < 1.25 and self.sx >= 0) or (angle > 1.25 and angle < 1.75 and self.sy <= 0) then
				self:grabgear(b)
			end
		end
	end

	--kill enemy
	if a == "enemy" and b.t == "bandit" and self.everthrown then
		b:die()
		makepoof(self.x+self.w/2, self.y+self.h/2, "boom")
		playSound("boom")
		self.delete = true
	end

	--platforms
	if a == "tile" and map:getProp(b.tx, b.ty, "platform") and side ~= "down" then
		return false
	end

	if side == "down" then
		--bounce
		if self.bounce then
			self.sy = -BOMB_bounceforce
			self.bounce = false
		end
	elseif side == "left" then
		if a ~= "player" then
			self.sx = math.abs(self.sx)/2
		elseif a == "player" and b.car then
			self.sx = math.abs(b.sx)/2
			self.sy = -BOMB_bounceforce
			return false
		end
	elseif side == "right" then
		if a ~= "player" then
			self.sx = -math.abs(self.sx)
		elseif a == "player" and b.car then
			self.sx = -math.abs(b.sx)
			self.sy = -BOMB_bounceforce
			return false
		end
	end
	return true
end

function Bomb:explode(tx, ty)
	explodetiles(tx, ty)
	--poof goes here when implemented
	makepoof(self.x+self.w/2, self.y+self.h/2, "boom")
	playSound("boom")

	self.delete = true
end

function explodetiles(tx, ty)
	--made this a global function cause the car needs it too
	map:set(tx, ty, 0, 1)
	makepoof(tx*TILE-TILE/2, ty*TILE-TILE/2, "break")
	--break all tiles up
	local x, y = tx, ty
	while map:getProp(x, y-1, "breakable") do
		y = y - 1
		map:set(x, y, 0, 1)
		makepoof(x*TILE-TILE/2, y*TILE-TILE/2, "break")
	end
	--break all tiles down
	local x, y = tx, ty
	while map:getProp(x, y+1, "breakable") do
		y = y + 1
		map:set(x, y, 0, 1)
		makepoof(x*TILE-TILE/2, y*TILE-TILE/2, "break")
	end
	--break all tiles left
	local x, y = tx, ty
	while map:getProp(x-1, y, "breakable") do
		x = x - 1
		map:set(x, y, 0, 1)
		makepoof(x*TILE-TILE/2, y*TILE-TILE/2, "break")
	end
	--break all tiles right
	local x, y = tx, ty
	while map:getProp(x+1, y, "breakable") do
		x = x + 1
		map:set(x, y, 0, 1)
		makepoof(x*TILE-TILE/2, y*TILE-TILE/2, "break")
	end
end

function Bomb:damaged()
	if self.gear then
		self:grabgear(false)
	end
	playSound("hurt")
	self.grabbed = false
	self.static = false
	self.active = true

	makepoof(self.x+self.w/2, self.y+self.h/2)
	self.x = self.spawnx
	self.y = self.spawny-0.1
	makepoof(self.x+self.w/2, self.y+self.h/2)
	self.bounce = false
	self.sx = 0
	self.sy = 0
end

function Bomb:grabgear(b)
	if b then
		self.gear = b
		self.static = true
		self.geargrabrotation = getangle2(self.x+self.w/2, self.y+self.h/2, b.rx, b.ry)-b.rotation
		
		if self.carrying then
			self.carrying:toss()
			self.carrying:damaged()
			self.carrying = nil
		end
		playSound("geargrab")
	else
		self.ground = false
		self.sx = GEAR_shoveforce*math.sin(self.geargrabrotation+self.gear.rotation)
		self.sy = GEAR_shoveforce*math.cos(self.geargrabrotation+self.gear.rotation)
		
		self.gear = false
		self.static = false
	end
end