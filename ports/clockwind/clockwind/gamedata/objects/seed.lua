Seed = class("Seed")

function Seed:initialize(x, y, t)
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

	self.t = t or 1

	self.grabbable = true --can player interact
	self.carryable = true --reject carry if needed 
	self.grabbed = false
	self.bounce = false

	self.gear = false
	self.geargrabrotation = 0
end

function Seed:update(dt)
	self.ground = (self.sy == 0)
	if self.ground then
		--ground friction
		if self.sx > 0 then
			self.sx = math.max(0, self.sx - FRICTION*dt)
		elseif self.sx < 0 then
			self.sx = math.min(0, self.sx + FRICTION*dt)
		end
	end

	if self.gear then
		--rotate around gear
		local g = self.gear
		local tx, ty = (g.rx+math.sin(g.rotation+self.geargrabrotation)*g.r)-self.w/2, (g.ry+math.cos(g.rotation+self.geargrabrotation)*g.r)-self.h/2 --target
		if insidewall(map, tx, ty, self.w, self.h) then
			playSound("hit")
			self:grabgear(false)
		else
			self.x = tx
			self.y = ty
		end
	end

	--level editor (Delete maybe?)
	if self.y > map.h*TILE then
		self:damaged()
	end
end

function Seed:draw()
	love.graphics.setColor(1,1,1)
	drawtime(seedimg, {seedq[1][self.t][1],seedq[2][self.t][1],seedq[3][self.t][1]}, math.floor(self.x+7), math.floor(self.y+8), 0, 1, 1, 8, 8)
end

function Seed:grab()
	if not self.carryable then
		return false
	end
	if self.gear then
		self:grabgear(false)
	end
	playSound("grab")
	self.grabbed = true
	self.static = true
	self.active = false
	self.carryable = false
	return true
end

function Seed:toss(dir, up) --Salad:toss()
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
	self.carryable = true
end

function Seed:carrymove(dir, x, y) --bottom, edge
	if dir == "left" then
		self.x = x-self.w
	else
		self.x = x
	end
	self.y = y-self.h
end

function Seed:collide(side, a, b)
	if self.delete then
		return false
	end
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
	
	--platforms
	if a == "tile" and map:getProp(b.tx, b.ty, "platform") and side ~= "down" then
		return false
	end

	if side == "down" then
		--bounce
		if self.bounce then
			self.sy = -SEED_bounceforce
			self.bounce = false
		end

		if a == "tile" and map:getProp(b.tx, b.ty, "dirt") then
			local pass = true
			if self.x < b.x then
				if not map:getProp(math.floor(self.x/TILE)+1, b.ty, "dirt") then
					pass = false
				end
			elseif self.x+self.w > b.x+b.w then
				if not map:getProp(math.floor((self.x+self.w)/TILE)+1, b.ty, "dirt") then
					pass = false
				end
			end
			if pass then
				if self.t == 1 then
					table.insert(obj["bush"], Bush:new(self.x, b.y, "bushseed"))
				elseif self.t == 2 then
					table.insert(obj["tree"], Tree:new(self.x, b.y))
				end
				playSound("plant")
				self.delete = true
			end
		end
	elseif side == "left" then
		if a ~= "player" then
			self.sx = math.abs(self.sx)/2
		elseif a == "player" and b.car then
			self.sx = math.abs(b.sx)/2
			self.sy = -SEED_bounceforce
		end
	elseif side == "right" then
		if a ~= "player" then
			self.sx = -math.abs(self.sx)
		elseif a == "player" and b.car then
			self.sx = -math.abs(b.sx)
			self.sy = -SEED_bounceforce
		end
	end
	return true
end

function Seed:damaged()
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

function Seed:grabgear(b)
	if b then
		self.gear = b
		self.static = true
		self.geargrabrotation = getangle2(self.x+self.w/2, self.y+self.h/2, b.rx, b.ry)-b.rotation
		
		if self.grabbed then
			self:toss()
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