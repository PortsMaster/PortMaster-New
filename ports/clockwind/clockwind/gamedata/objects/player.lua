Player = class("Player")

function Player:initialize(x, y)
	self.x = x
	self.y = y+TILE-PLAYER_height
	self.w = PLAYER_width
	self.h = PLAYER_height

	--physics
	self.category = 2
	self.mask = {true, false, true, false, true, true, true, true, true}

	self.active = true
	self.static = false

	self.sx = 0
	self.sy = 0
	self.gravity = PLAYER_gravity

	--graphics
	self.dir = "right"

	--states
	self.ground = false
	self.jumping = false

	self.carryobjects = {"seed", "tree", "bush", "bomb"}
	self.carrying = false

	self.frame = 1
	self.idleframe = 1
	self.walkframe = 1
	self.swimframe = 1

	--checkpoint tile
	self.checkpointx = x/TILE
	self.checkpointy = (y+TILE)/TILE

	self.dead = false
	self.deadblink = 0
	self.respawntimer = false

	self.speed = PLAYER_walkspeed
	self.acceleration = PLAYER_walkacceleration

	self.car = false
	self.carframe = 1--1, 2

	self.gear = false
	self.geargrabrotation = 0

	self.controlsenabled = true
end

function Player:update(dt)
	--respawn
	if self.respawntimer then
		self.respawntimer = self.respawntimer - dt
		if self.respawntimer <= 0 then
			self.respawntimer = false
			game.transitionout("respawn")
		end
		return
	end

	--start swimming?
	if waterlevel then
		if self.y+self.h > waterlevel then
			if not self.swimming then
				self:dive(true)
			end
		else
			if self.swimming then
				self:dive(false)
			end
		end
	end

	--movement
	if self.car then
		if timeperiod == 3 then
			--flying car
			self.gravity = 0
			self.speed = PLAYER_flyspeed
			self.acceleration = PLAYER_flyacceleration
			if self.controlsenabled and (love.keyboard.isDown(controls["up"]) and not love.keyboard.isDown(controls["timetoggle"])) then
				if self.sy > 0 then --skid faster
					self.sy = math.max(-self.speed, self.sy - self.acceleration*2*dt)
				else
					self.sy = math.max(-self.speed, self.sy - self.acceleration*dt)
				end
				self.carframe = (self.carframe - 1 + (math.abs(self.sy)/self.speed)*PLAYER_caranimspeed*dt)%2 + 1
			elseif self.controlsenabled and (love.keyboard.isDown(controls["down"]) and not love.keyboard.isDown(controls["timetoggle"])) then
				if self.sy < 0 then
					self.sy = math.min(self.speed, self.sy + self.acceleration*2*dt)
				else
					self.sy = math.min(self.speed, self.sy + self.acceleration*dt)
				end
				self.carframe = (self.carframe - 1 + (math.abs(self.sy)/self.speed)*PLAYER_caranimspeed*dt)%2 + 1
			else
				if self.sy > 0 then
					self.sy = math.max(0, self.sy - PLAYER_walkfriction*dt)
				elseif self.sy < 0 then
					self.sy = math.min(0, self.sy + PLAYER_walkfriction*dt)
				end		
			end
		else
			self.gravity = PLAYER_gravity
			self.speed = PLAYER_carspeed
			self.acceleration = PLAYER_caracceleration
		end
	end
	if self.gear then
		--rotate around gear
		local g = self.gear
		local tx, ty = (g.rx+math.sin(g.rotation+self.geargrabrotation)*g.r)-self.w/2, (g.ry+math.cos(g.rotation+self.geargrabrotation)*g.r)-self.h/2 --target
		local isinsidewall, _, inspikes = insidewall(map, tx, ty, self.w, self.h)
		if isinsidewall then
			self:grabgear(false)
			playSound("hit")
			if inspikes then
				self:die()
			end
		else
			self.x = tx
			self.y = ty
		end
	else
		--normal movement
		if self.controlsenabled and (love.keyboard.isDown(controls["left"]) and not love.keyboard.isDown(controls["timetoggle"])) then--and self.dir == "left" then
			self.dir = "left"
			if self.swimming then
				self.sx = math.max(-PLAYER_swimspeed, self.sx - PLAYER_swimacceleration*dt)
			else
				if self.ground and self.sx > 0 then --skid faster
					self.sx = math.max(-self.speed, self.sx - self.acceleration*2*dt)
				else
					self.sx = math.max(-self.speed, self.sx - self.acceleration*dt)
				end
				self.walkframe = (self.walkframe - 1 + (math.abs(self.sx)/self.speed)*PLAYER_walkanimspeed*dt)%4 + 1
				self.carframe = (self.carframe - 1 + (math.abs(self.sx)/self.speed)*PLAYER_caranimspeed*dt)%2 + 1
			end
		elseif self.controlsenabled and (love.keyboard.isDown(controls["right"]) and not love.keyboard.isDown(controls["timetoggle"])) then--and self.dir == "right" then
			self.dir = "right"
			if self.swimming then
				self.sx = math.min(PLAYER_swimspeed, self.sx + PLAYER_swimacceleration*dt)
			else
				if self.ground and self.sx < 0 then
					self.sx = math.min(self.speed, self.sx + self.acceleration*2*dt)
				else
					self.sx = math.min(self.speed, self.sx + self.acceleration*dt)
				end
				self.walkframe = (self.walkframe - 1 + (math.abs(self.sx)/self.speed)*PLAYER_walkanimspeed*dt)%4 + 1
				self.carframe = (self.carframe - 1 + (math.abs(self.sx)/self.speed)*PLAYER_caranimspeed*dt)%2 + 1
			end
		else
			if self.swimming then
				if self.sx > 0 then
					self.sx = math.max(0, self.sx - PLAYER_swimfriction*dt)
				elseif self.sx < 0 then
					self.sx = math.min(0, self.sx + PLAYER_swimfriction*dt)
				end
			elseif self.jumping then
				--air friction
				if self.sx > 0 then
					self.sx = math.max(0, self.sx - PLAYER_jumpfriction*dt)
				elseif self.sx < 0 then
					self.sx = math.min(0, self.sx + PLAYER_jumpfriction*dt)
				end
			else
				--ground friction
				if self.sx > 0 then
					self.sx = math.max(0, self.sx - PLAYER_walkfriction*dt)
				elseif self.sx < 0 then
					self.sx = math.min(0, self.sx + PLAYER_walkfriction*dt)
				end
				if self.sx == 0 then
					self.walkframe = 1
				end
				self.carframe = (self.carframe - 1 + (math.abs(self.sx)/self.speed)*PLAYER_caranimspeed*dt)%2 + 1
			end
		end
	end

	--is on ground?
	self.ground = (self.sy == 0)

	self.beingcarriedbypiston = false
	self.beingcarriedbybush = false

	--carrying
	if self.carrying then
		local cx, cy = self.x+self.w+PLAYER_carryx, self.y+PLAYER_carryy
		if self.dir == "left" then
			cx = self.x-PLAYER_carryx
		end
		self.carrying:carrymove(self.dir, cx, cy)
	end

	--checkpoints
	local cx, cy = math.floor((self.x+self.w/2)/TILE)+1, math.floor((self.y+self.h)/TILE)+1
	if checkpoints[cx .. "|" .. cy] then
		self.checkpointx = cx
		self.checkpointy = cy
	elseif checkpoints[cx .. "|" .. cy-1] then
		self.checkpointx = cx
		self.checkpointy = cy-1
	end
	if self.car then
		if carcheckpoints[cx .. "|" .. cy] then
			self.carride.spawnx = ((cx-1)*TILE)
			self.carride.spawny = ((cy)*TILE)-self.carride.h
		elseif carcheckpoints[cx .. "|" .. cy-1] then
			self.carride.spawnx = ((cx-1)*TILE)
			self.carride.spawny = (((cy)-1)*TILE)-self.carride.h
		end
	end
	--animation
	if self.gear then
		self.frame = 18
	elseif self.car then
		self.frame = 15+math.floor(self.carframe)
	elseif self.winned then
		self.frame = 15
	elseif self.dead then
		self.frame = 14
		self.deadblink = (self.deadblink+6*dt)%1
	elseif self.swimming then
		self.swimframe = (self.swimframe - 1 + PLAYER_swimanimspeed*dt)%4 + 1
		self.frame = math.floor(self.swimframe)+9
	elseif self.jumping then
		if self.sy < 0 then
			self.frame = 8
		else
			self.frame = 9
		end
	elseif not self.ground then
		self.frame = 9
	elseif math.abs(self.sx) > self.acceleration*dt then --self.sx ~= 0 then
		self.frame = 3+math.floor(self.walkframe)
	else
		self.idleframe = (self.idleframe - 1 + PLAYER_idleanimspeed*dt)%3 + 1
		self.frame = math.floor(self.idleframe)
	end

	--level editor (Delete maybe?)
	if self.y > map.h*TILE then
		self.y = self.y-map.h*TILE-self.h
	end
	self.col = false --delete
end

function Player:draw()
	if self.dead and self.deadblink > 0.5 then
		return false
	end
	if self.col then
		love.graphics.setColor(1,0,0,1)
	else
		love.graphics.setColor(1,1,1,1)
	end
	local y = 1
	if self.carrying then
		y = 2
	end
	local sx, sy = 1, 1
	if self.dir == "left" then
		sx = -1
	end
	if self.gear then--rotate
		love.graphics.draw(playerimg, playerq[y][self.frame], math.floor(self.x+self.w/2), math.floor(self.y+self.h/2), getangle(self.x+self.w/2, self.y+self.h/2, self.gear.rx, self.gear.ry), 1, sx, 20, 20)
	else
		love.graphics.draw(playerimg, playerq[y][self.frame], math.floor(self.x+self.w/2), math.floor(self.y+self.h+1), 0, sx, sy, 20, 40)
	end
	if self.car then
		drawtime(carimg, {carq[1][math.floor(self.carframe)], carq[2][math.floor(self.carframe)], carq[3][math.floor(self.carframe)]}, math.floor(self.x+self.w/2), math.floor(self.y+self.h+1), 0, sx, sy, 32, 40)
	end
end

function Player:jump(override)
	if self.car then
		self:ride(false)
	elseif self.gear then
		playSound("jump")
		self:grabgear(false, true)
		return
	end
	if self.swimming then
		self.sy = -PLAYER_swimforce
		playSound("swim")
	elseif self.ground or override or self.beingcarriedbybush then
		self.jumping = true
		self.ground = false
		self.sy = -PLAYER_jumpforce
		self.gravity = PLAYER_jumphighgravity
		if self.beingcarriedbypiston then
			self.sy = self.sy - self.beingcarriedbypiston
			self.beingcarriedbypiston = false
		end
		playSound("jump")
	end
end

function Player:stopjump()
	if self.swimming then
	elseif self.jumping then
		self.gravity = PLAYER_jumpgravity
	end
end

function Player:keypressed(k)
	if not self.controlsenabled then
		return false
	end
	if k == controls["left"] then
		if not self.gear then
			self.dir = "left"
		end
	elseif k == controls["right"] then
		if not self.gear then
			self.dir = "right"
		end
	elseif k == controls["jump"] then
		self:jump()
	elseif k == controls["action"] then
		if (not self.gear) and (not self.car) then
			if self.carrying then
				--toss
				local c = self.carrying
				local x1, x2 = insidewall(map, c.x, c.y, c.w, c.h, c.checkbreakable)
				--if not insidewall(map, c.x, c.y, c.w, c.h, c.checkbreakable) then
					local upthrow = love.keyboard.isDown(controls["up"])
					if noupthrowing[math.floor((self.x+self.w/2)/TILE)+1] then
						upthrow = false
					end
					self.carrying:toss(self.dir, upthrow)
					if x1 then
						if self.dir == "left" then
							self.carrying.x = x2
						else
							self.carrying.x = x1-self.carrying.w
						end
					end
					self.carrying = nil
					playSound("toss")
				--end
			else
				--carry things
				for name, t in pairs(self.carryobjects) do
					for a, b in pairs(obj[t]) do
						if b.grabbable then
							local x1, y1, w1, h1 = self.x+self.w+PLAYER_grabrangex, self.y+PLAYER_grabrangey, PLAYER_grabrangew, self.h+PLAYER_grabrangeh
							if self.dir == "left" then
								x1 = self.x-PLAYER_grabrangew-PLAYER_grabrangex
							end
							local x2, y2, w2, h2 = b.x, b.y, b.w, b.h
							if aabb(x1, y1, w1, h1, x2, y2, w2, h2) then
								local success, carryobject = b:grab()
								if success then
									self.carrying = carryobject or b
									return
								end
							end
						end
					end
				end
			end
		end
	end
end

function Player:keyreleased(k)
	if not self.controlsenabled then
		return false
	end
	if k == controls["jump"] then
		self:stopjump()
	end
end

function Player:collide(side, a, b)
	if not self.active then
		return
	end

	--spikes
	if a == "tile" and
		((map:getProp(b.tx, b.ty, "spikeup") and side == "down") or (map:getProp(b.tx, b.ty, "spikedown") and side == "up") or
		(map:getProp(b.tx, b.ty, "spikeleft") and side == "right") or (map:getProp(b.tx, b.ty, "spikeright") and side == "left")) then
		self:die()
		return false
	end

	--platforms
	if a == "tile" and map:getProp(b.tx, b.ty, "platform") and side ~= "down" then
		return false
	end

	--break blocks in car
	if self.car and timeperiod < 3 and (side == "left" or side == "right") then
		if a == "tile" and map:getProp(b.tx, b.ty, "breakable") then
			if math.abs(self.sx) >= PLAYER_carblockbreakspeed then
				explodetiles(b.tx,b.ty)
				playSound("boom")
				return true
			end
		end
	end

	if side == "down" then
		--land
		self:land()
		--[[if a == "tile" and not (map:getProp(b.tx, b.ty, "spikeup") or map:getProp(b.tx, b.ty, "spikedown") or 
			map:getProp(b.tx, b.ty, "spikeleft") or map:getProp(b.tx, b.ty, "spikeright") ) then
			--new checkpoint
			self.checkpointx = b.tx
			self.checkpointy = b.ty
		end]]

		if a == "car" and (not self.car) and (not self.winned) and (not self.carrying) then
			if math.abs((self.x+self.w/2)-(b.x+b.w/2)) < 20 then
				self:ride(true, b)
				return false
			end
		end
	end

	--enemies
	if a == "enemy" then
		--dino
		if b.t == "dino1" then
			if side ~= "down" and not b.bones then
				self:die()
			end
		elseif b.t == "bandit" then
			if self.car then
				if timeperiod <= 2 and math.abs(self.sx) >= PLAYER_carblockbreakspeed then
					b:die()
					return false
				else
					return true
				end
			else
				self:die()
			end
		end
	elseif a == "jelly" then
		self:die()
		return false
	end

	--leaves (jump through)
	if a == "branch" and side ~= "down" then
		return false
	end

	--goal
	if a == "goal" then
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

	--tree
	if a == "tree" then
		if side == "passive" then
			self.y = b.y-self.h
			self.sy = 0
			self:land()
		end
	end
	--bush, get pushed up
	if a == "bush" then
		if b.dir == "up" then
			if side == "passive" and self.y+self.h/2 < b.y then
				if not insidewall(map, self.x, b.y-self.h, self.w, self.h, nil, b) then
					if b.t == "piston" and (not b.retracting) and b.stoptimer < 0 then
						if self.jumping then
							return false
						else
							self.beingcarriedbypiston = b.speed
						end
					end
					if timetraveling and b.t ~= "piston" and self.jumping and self.sy < -4 then
						self.y = math.min(self.y, b.y-self.h)--0.1
						self.beingcarriedbybush = true
						return false
					end
					self.y = b.y-self.h--0.1
					self.sy = 0
					self:land()
				else
					if b.t == "piston" then --get crushed by piston
						self:die()
						return false
					else
						self.sy = math.max(0, self.sy)
					end
				end
			end
		elseif b.dir == "down" then
			if side == "passive" then --get crushed by piston
				if insidewall(map, self.x, b.y+b.h, self.w, self.h, nil, b) then
					self:die()
					return false
				else
					self.sy = math.max(0, self.sy+b.speed)
					self.y = b.y+b.h
				end
			end
		elseif b.dir == "right" then
			if side == "passive" and self.x > b.x+b.w-self.w/2 then
				if not insidewall(map, b.x+b.w, self.y, self.w, self.h, nil, b) then
					self.x = b.x+b.w
					self.sx = 0
				else --get crushed by piston
					self:die()
					return false
				end
			end
		elseif b.dir == "left" then
			if side == "passive" and self.x+self.w < b.x+self.w/2 then
				if not insidewall(map, b.x-self.w, self.y, self.w, self.h, nil, b) then
					self.x = b.x-self.w
					self.sx = 0
				else --get crushed by piston
					self:die()
					return false
				end
			end
		end
	end

	if self.car and (side == "left" or side == "right") and math.abs(self.sx) > 40 then
		playSound("hit")
	end

	--seed
	if b.grabbed then
		return false
	end

	return true
end

function Player:land()
	if self.swimming then
		return
	end
	self.gravity = PLAYER_gravity
	self.ground = true
	self.jumping = false
end

function Player:dive(water)
	if water then
		self.swimming = true
		self.sx = self.sx*PLAYER_waterdampingx
		self.sy = self.sy*PLAYER_waterdampingy
		self.gravity = PLAYER_watergravity
		playSound("splash")
	else
		self.swimming = false
		self.gravity = PLAYER_gravity
		if self.sy < 0 then
			self:jump()
			self.sy = -PLAYER_waterjumpoutforce
		end
		playSound("jump")
	end
end

function Player:die()
	if leveledit then
		return false
	end

	playSound("hurt")

	if self.carrying and self.carrying.damaged then
		self.carrying:toss()
		self.carrying:damaged()
		self.carrying = nil
	end

	if self.car then
		self:ride(false, "respawn")
	end

	self.active = false
	self.static = true
	self.dead = true
	self.deadblink = 0

	makepoof(self.x+self.w/2, self.y+self.h/2)
	self.respawntimer = PLAYER_respawntime
	self.controlsenabled = false
	--self:respawn()
end

function Player:respawn()
	self.dead = false

	if self.respawncar then
		self.respawncar:respawn()
	end

	self.controlsenabled = true
	self.x = ((self.checkpointx-1)*TILE)
	self.y = ((self.checkpointy-1)*TILE)+TILE-self.h
	self.sx = 0
	self.sy = 0
	self.active = true
	self.static = false
	camera:center(self.x, self.y, self.w, self.h)
	spawnonscreen()
end

function Player:win()
	if self.carrying and self.carrying.damaged then
		self.carrying:toss()
		self.carrying:damaged()
		self.carrying = nil
	end

	if self.car then
		self:ride(false, "respawn")
	end

	self.controlsenabled = false
	self.winned = true
	playSound("win")
	game.transitionout("startwin")
end

function Player:ride(ride, b)
	--ride a cool car
	if ride then
		self.car = true
		self.carride = b
		self.respawncar = b
		self.x = b.x
		self.y = b.y+b.h-PLAYER_carheight
		self.w = PLAYER_carwidth
		self.h = PLAYER_carheight
		b:ride(true)

		self.carframe = 2
		self.speed = PLAYER_carspeed
		self.acceleration = PLAYER_caracceleration

		if self.carrying then
			local c = self.carrying
			if not insidewall(map, c.x, c.y, c.w, c.h, c.checkbreakable) then
				self.carrying:toss(self.dir)
				self.carrying = nil
			else
				self.carrying:toss()
				self.carrying:damaged()
				self.carrying = nil
			end
		end
		playSound("car")
	else
		self.car = false
		self.carride:ride(false, self)
		if b and b == "respawn" then
			self.carride:respawn()
			self.respawncar = false
		end
		self.carride = false

		self.x = self.x+self.w/2
		self.y = self.y+self.h
		self.w = PLAYER_width
		self.h = PLAYER_height
		self.x = self.x-self.w/2
		self.y = self.y-self.h
		self.car = false
			
		self.speed = PLAYER_walkspeed
		self.acceleration = PLAYER_walkacceleration
		self.gravity = PLAYER_gravity
	end
end

function Player:grabgear(b, jump)
	if b then
		self.gear = b
		self.static = true
		self.geargrabrotation = getangle2(self.x+self.w/2, self.y+self.h/2, b.rx, b.ry)-b.rotation
		
		if self.carrying then
			local c = self.carrying
			local x1, x2 = insidewall(map, c.x, c.y, c.w, c.h, c.checkbreakable)
			if not x1 then
				self.carrying:toss(self.dir)
				self.carrying.sx = GEAR_shoveforce*math.sin(self.geargrabrotation+self.gear.rotation)
				self.carrying.sy = GEAR_shoveforce*math.cos(self.geargrabrotation+self.gear.rotation)
				self.carrying = nil
			else
				self.carrying:toss()
				if self.dir == "left" then
					self.carrying.x = x2
				else
					self.carrying.x = x1-self.carrying.w
				end
				self.carrying.sx = GEAR_shoveforce*math.sin(self.geargrabrotation+self.gear.rotation)
				self.carrying.sy = GEAR_shoveforce*math.cos(self.geargrabrotation+self.gear.rotation)
				--self.carrying:damaged()
				self.carrying = nil
			end
		end
		playSound("geargrab")
	else
		self.jumping = true
		self.ground = false
		self.sx = PLAYER_jumpforce*math.sin(self.geargrabrotation+self.gear.rotation)
		self.sy = PLAYER_jumpforce*math.cos(self.geargrabrotation+self.gear.rotation)
		if jump then
			self.sx = (PLAYER_jumpforce-11)*math.sin(self.geargrabrotation+self.gear.rotation)
			if self.sy < 0 then
				self.sy = self.sy-52
			end
		end
		self.gravity = PLAYER_jumphighgravity

		self.gear = false
		self.static = false
	end
end