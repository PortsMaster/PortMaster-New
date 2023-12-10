Bush = class("Bush")

function Bush:initialize(x, y, t, dir, length, retracting)
	self.x = x
	self.y = y-TILE
	self.w = TILE
	self.h = TREE_startlength
	self.t = t or "bush"

	self.category = 5
	self.mask = {false, true, true, true, false}

	self.active = true
	self.static = true

	self.sx = 0
	self.sy = 0

	self.born = timep
	self.bornperiod = timeperiod
	self.length = TREE_startlength
	self.dir = "up"

	--graphics
	self.quadset = 1
	self.img = bushimg
	if self.t == "bushseed" then
		self.quadset = 2
		self.grabbable = true
		self.planted = true
		self.length = 13
		self.y = self.y + self.h - self.length
		self.h = self.length
	elseif self.t == "seaweed" then --the boof
		self.img = seaweedimg
		self.length = BUSH_length
		self.y = self.y + self.h - self.length
		self.h = self.length
	elseif self.t == "piston" then
		self.dir = dir
		self.img = pistonimg
		self.maxlength = PISTON_length
		if length then
			self.maxlength = length*TILE
		end
		if retracting then
			self.length = self.maxlength
		else
			self.length = PISTON_startlength 
		end
		if dir == "up" then
			self.y = self.y + self.h - self.length
			self.h = self.length
		elseif dir == "down" then
			self.h = self.length
		elseif dir == "left" then
			self.x = self.x+TILE
			self.h = TILE
			self.x = self.x + self.w - self.length
			self.w = self.length
		elseif dir == "right" then
			self.h = TILE
			self.w = self.length
		end
		self.speed = 0
		
		if retracting then
			self.retracting = true
		else
			self.retracting = false
		end
		self.stoptimer = PISTON_timestop
	end
end

function Bush:update(dt)
	if self.t == "piston" then
		if timeperiod <= 2 then
			if self.stoptimer > 0 then
				self.stoptimer = self.stoptimer - dt
			else
				if self.retracting then
					--slowly go back
					self.length = math.max(PISTON_startlength, self.length - PISTON_retractspeed*dt)
					if self.length <= PISTON_startlength then
						self.retracting = false
						self.stoptimer = PISTON_timestop
					end
				else
					--smash fast
					self.speed = math.min(PISTON_speed, self.speed + PISTON_acceleration*dt)
					self.length = math.min(self.maxlength, self.length + self.speed*dt)
					if self.length >= self.maxlength then
						self.speed = 0
						self.retracting = true
						self.stoptimer = PISTON_timestop
						if self.dir == "up" then
							makepoof(self.x+self.w/2, self.y, "pound", math.pi)
						elseif self.dir == "right" then
							makepoof(self.x+self.w, self.y+self.h/2, "pound", math.pi*1.5)
						elseif self.dir == "left" then
							makepoof(self.x, self.y+self.h/2, "pound", math.pi*.5)
						else
							makepoof(self.x+self.w/2, self.y+self.h, "pound", 0)
						end
						if camera:visible(self.x, self.y, self.w, self.h) then
							playSound("piston")
						end
					end
				end
				if self.dir == "up" then
					self.y = self.y + self.h - self.length
					self.h = self.length
				elseif self.dir == "down" then
					self.h = self.length
				elseif self.dir == "left" then
					self.x = self.x + self.w - self.length
					self.w = self.length
				elseif self.dir == "right" then
					self.h = TILE
					self.w = self.length
				end
				if self.retracting and self.dir == "up" then
					--hacky solution
					if obj["player"][1] then
						local p = obj["player"][1]
						if (not p.jumping) and p.x+p.w > self.x and p.x < self.x+self.w and p.y+p.h >= self.y-PISTON_retractspeed*dt and p.y+p.h <= self.y and (not p.gear) then
							p:land()
							p.sy = 0
							p.y = self.y-p.h
						end
					end
				end
				if self.dir == "left" or self.dir == "right" then
					--carry player
					local p = obj["player"][1]
					if p.x+p.w > self.x and p.x < self.x+self.w and p.y+p.h == self.y then
						local speed = self.speed
						if self.retracting then
							speed = -PISTON_retractspeed
						end
						if self.dir == "left" then
							speed = -speed
						end
						if not insidewall(map, p.x+speed*dt, p.y, p.w, p.h) then
							p.x = p.x+speed*dt
						end
					end
				end
			end
		end
	elseif timetraveling then
		if self.t == "seaweed" then
			self.length = BUSH_length - ((BUSH_length-BUSH_startlength) * (((timep-1)-(self.born-1))/(TIMEPERIODS-1)))
			self.length = math.min(BUSH_length, self.length)
		else
			self.length = BUSH_startlength + ((BUSH_length-BUSH_startlength) * easing.outQuad((((timep-1)-(self.born-1))/(TIMEPERIODS-1)), 0, 1, 1))
			self.length = math.max(BUSH_startlength, self.length)
		end

		--seed form
		if self.planted then
			if self.length <= BUSH_startlength or self.bornperiod > 2 then
				self.grabbable = true
				self.length = 13
			else
				self.grabbable = false
			end
		end

		self.y = self.y + self.h - self.length
		self.h = self.length
	end
end

function Bush:draw()
	love.graphics.setColor(1,1,1,1)
	if self.planted then
		--stiped bush, shows up with color when born
		if self.length <= BUSH_startlength then --pullable seed
			love.graphics.draw(seedimg, seedq[self.bornperiod][1][2], math.floor(self.x+self.w/2-8), self.y+self.h-16)
		else
			love.graphics.setScissor(math.floor(self.x-camera.x), math.floor(self.y+10-camera.y), 21, math.ceil(self.h-19))
			for i = 1, math.ceil((self.length-20)/20) do
				love.graphics.draw(self.img, bushq[self.bornperiod][self.quadset][2], math.floor(self.x), math.ceil(self.y+self.h-10-20*i))
			end
			love.graphics.setScissor()
			love.graphics.draw(self.img, bushq[self.bornperiod][self.quadset][1], math.floor(self.x+self.w/2-10), self.y)
			love.graphics.draw(self.img, bushq[self.bornperiod][self.quadset][3], math.floor(self.x+self.w/2-10), self.y+self.h-10)
		end
	elseif self.t == "piston" then
		if self.dir == "up" then
			love.graphics.setScissor(self.x-math.floor(camera.x), self.y+10-math.floor(camera.y), 20, math.ceil(self.h-20))
			for i = 1, math.ceil((self.length-20)/20) do
				drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.floor(self.x), math.ceil(self.y+self.h-10-20*i))
			end
			love.graphics.setScissor()
			drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, math.floor(self.x+self.w/2-10), self.y)
			drawtime(self.img, {bushq[1][self.quadset][3], bushq[2][self.quadset][3], bushq[3][self.quadset][3]}, math.floor(self.x+self.w/2-10), self.y+self.h-10)
		elseif self.dir == "down" then
			love.graphics.setScissor(self.x-math.floor(camera.x), self.y+10-math.floor(camera.y), 20, math.ceil(self.h-20))
			for i = 1, math.ceil((self.length-20)/20) do
				drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.floor(self.x), math.ceil(self.y+self.h-10-20*i), 0, 1, -1, 0, 20)
			end
			love.graphics.setScissor()
			drawtime(self.img, {bushq[1][self.quadset][3], bushq[2][self.quadset][3], bushq[3][self.quadset][3]}, math.floor(self.x+self.w/2-10), self.y, 0, 1, -1, 0, 10)
			drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, math.floor(self.x+self.w/2-10), self.y+self.h-10, 0, 1, -1, 0, 10)
		elseif self.dir == "left" then
			love.graphics.setScissor(self.x+10-math.floor(camera.x), self.y-math.floor(camera.y), math.ceil(self.w-20), 20)
			for i = 1, math.ceil((self.length-20)/20) do
				drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.ceil(self.x+self.w-20*i), math.floor(self.y), math.pi*1.5,1,1,20,10)
			end
			love.graphics.setScissor()
			drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, self.x+10, math.floor(self.y+self.h/2)-10, math.pi*1.5,1,1,20,10)
			drawtime(self.img, {bushq[1][self.quadset][3], bushq[2][self.quadset][3], bushq[3][self.quadset][3]}, self.x+self.w, math.floor(self.y+self.h/2)-10, math.pi*1.5,1,1,20,10)
		elseif self.dir == "right" then
			love.graphics.setScissor(self.x+10-math.floor(camera.x), self.y-math.floor(camera.y), math.ceil(self.w-20), 20)
			for i = 1, math.ceil((self.length-20)/20) do
				drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.ceil(self.x+self.w-20*i), math.floor(self.y)+20, math.pi*.5,-1,1,0,10)
			end
			love.graphics.setScissor()
			drawtime(self.img, {bushq[1][self.quadset][3], bushq[2][self.quadset][3], bushq[3][self.quadset][3]}, self.x, math.floor(self.y+self.h/2)+10, math.pi*.5,-1,1,0,10)
			drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, self.x+self.w-10, math.floor(self.y+self.h/2)+10, math.pi*.5,-1,1,0,10)
		end
	elseif self.t == "seaweed" then
		--changes color based on current time period
		love.graphics.setScissor(math.floor(self.x-camera.x), self.y+10-math.floor(camera.y), 21, math.ceil(self.h)-10)
		for i = 1, math.ceil((self.length-10)/20) do
			drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.floor(self.x), math.floor(self.y-10+20*i))
		end
		love.graphics.setScissor()
		drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, math.floor(self.x+self.w/2-10), self.y)
	else
		--changes color based on current time period
		love.graphics.setScissor(self.x-math.floor(camera.x), self.y+10-math.floor(camera.y), 20, math.ceil(self.h-20))
		for i = 1, math.ceil((self.length-20)/20) do
			drawtime(self.img, {bushq[1][self.quadset][2], bushq[2][self.quadset][2], bushq[3][self.quadset][2]}, math.floor(self.x), math.ceil(self.y+self.h-10-20*i))
		end
		love.graphics.setScissor()
		drawtime(self.img, {bushq[1][self.quadset][1], bushq[2][self.quadset][1], bushq[3][self.quadset][1]}, math.floor(self.x+self.w/2-10), self.y)
		drawtime(self.img, {bushq[1][self.quadset][3], bushq[2][self.quadset][3], bushq[3][self.quadset][3]}, math.floor(self.x+self.w/2-10), self.y+self.h-10)
	end
end

function Bush:collide(side, a, b)

end

function Bush:grab()
	local seed = Seed:new(self.x, self.y, 1)
	seed:grab()
	table.insert(obj["seed"], seed)
	
	self.delete = true
	return true, seed
end