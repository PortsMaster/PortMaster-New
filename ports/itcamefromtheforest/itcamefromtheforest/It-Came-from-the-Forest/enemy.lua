local Enemy = class('Enemy')

local EnemyState = {
	INIT = 0,
	WANDER = 1,
	TRACKING = 2,
	ATTACKING = 3,
	DEAD = 4
}

function Enemy:initialize(enemy)
	
	local map = {
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	  {0,0,0,0,0,0},
	}
	
	self.enemy = enemy
	self.enemy.properties.attacking = 0
	
	self.pathFinder = {}
	self.pathFinder = Pathfinder(Grid(map), 'ASTAR', 0)
	self.pathFinder:setHeuristic('MANHATTAN')
	self.pathFinder:setMode('ORTHOGONAL')
	self.path = nil
	
	self.tickDelay = 1.5
	self.attackDelay = 2
	self.decayDelay = 10
	self.tickCounter = math.random()
	self.attackCounter = math.random()
	self.decayCounter = 0
	self.highlightCounter = 0
	
	self.state = EnemyState.INIT
	
end	

function Enemy:setMap(map)

	self.map = map
	self.pathFinder:setGrid(Grid(map))
	self.state = EnemyState.WANDER
	
end

function Enemy:update(dt)
	
	if self.enemy.properties.state == 2 then
		return
	end

	balle = self.state

	if self.state == EnemyState.DEAD then
		self.decayCounter = self.decayCounter + dt
		if self.decayCounter > self.decayDelay then
			self.enemy.properties.state = 2
		end
	end

	if self.enemy.highlight == 1 then
	
		self.highlightCounter = self.highlightCounter + dt * 1
		
		if self.highlightCounter > 0.25 then
			self.highlightCounter = 0
			self.enemy.highlight = 0
		end
	end
	
	if self.state == EnemyState.ATTACKING then

		if self.attackCounter > self.attackDelay then
			self.attackCounter = 0
			self:attack()
		end
		
		if self.attackCounter > 0.5 then
			self.enemy.properties.attacking = 0
		end
		
		self.attackCounter = self.attackCounter + dt
		
		return
	
	elseif self.tickCounter > self.tickDelay then

		self.tickCounter = 0

		if self.state == EnemyState.WANDER then
		
			if self:canSeePlayer() then
				if self:calcPathToPlayerPosition() then
					self.state = EnemyState.TRACKING
					if not self:walkToNextPathNode() then
						self:initiateAttack()
					end
				end
			else
				self:wander()
			end	
		elseif self.state == EnemyState.TRACKING then
			if self:calcPathToPlayerPosition() then
				if not self:walkToNextPathNode() then
					self:initiateAttack()
				end
			else 
				self.state = EnemyState.WANDER
			end
		end
		
	end

	self.tickCounter = self.tickCounter + dt;

end

function Enemy:calcPathToPlayerPosition()

	self.path = self.pathFinder:getPath(self.enemy.x,self.enemy.y, party.x,party.y)
	
	if self.path then
		self.pathlength = self.path:getLength()
		if self.pathlength < 7 then
			self.pathNodeIndex = 2
			return true
		end
	end

	self.path = nil

	return false
	
end

function Enemy:canSeePlayer()

	local distance = distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y)
	
	if distance < 5 then
		return bresenham.los(party.x, party.y, self.enemy.x, self.enemy.y, function(x, y)
				return self.map[y][x] == 0
		end)	
	end
	
	return false

end

function Enemy:initiateAttack()

	self.state = EnemyState.ATTACKING
	if math.random() > 0.5 then
		self.attackCounter = self.attackDelay  -0.2
	else
		self.attackCounter = 0.5 + math.random()
	end
	
end

function Enemy:walkToNextPathNode()

	-- no path

	if not self.path then
		return false
	end	

	-- reached end of path

	if self.pathNodeIndex > self.pathlength then
		self.path = nil
		return false
	end

	-- follow the path

	local stepindex = 1

	for node, count in self.path:nodes() do
		if stepindex == self.pathNodeIndex then

			local nx = node:getX()
			local ny = node:getY()

			-- check if enemy in the way

			for key,value in pairs(level.data.enemies) do
				if level.data.enemies[key].x == nx and level.data.enemies[key].y == ny then
					if level.data.enemies[key].properties.state == 1 then
						self.path = nil
						return false
					end
				end
			end
			
			local angle = math.angle(self.enemy.x, self.enemy.y, nx, ny)
			
			local dir = 0
			if angle == 0 then dir = 1 end
			if angle == 90 then dir = 2 end
			if angle == 180 then dir = 3 end
			if angle == 270 then dir = 0 end
			
			self.enemy.properties.direction = dir
			self.enemy.x = nx
			self.enemy.y = ny
			
			globalvariables:add(self.enemy.properties.id, "x", self.enemy.x)
			globalvariables:add(self.enemy.properties.id, "y", self.enemy.y)
			globalvariables:add(self.enemy.properties.id, "direction", self.enemy.properties.direction)
			
			if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) < 5 then
				assets:playSound(self.enemy.properties.sound_move)
			end

			self.pathNodeIndex = self.pathNodeIndex + 1
			
			if self.pathNodeIndex > self.pathlength then
				self.path = nil
				return false
			end			
			
			return true
		
		end
		
		stepindex = stepindex + 1
		
	end

	return false
		
end

function Enemy:directionVectorOffsets()

    if self.enemy.properties.direction == 0 then
        return { x = self.enemy.x, y = self.enemy.y - 1 };
	elseif self.enemy.properties.direction == 1 then
		return { x = self.enemy.x + 1, y = self.enemy.y };
	elseif self.enemy.properties.direction == 2 then
		return { x = self.enemy.x, y = self.enemy.y + 1 };
	elseif self.enemy.properties.direction == 3 then
		return { x = self.enemy.x - 1, y = self.enemy.y };
	end

end

function Enemy:canWalk(x,y)

	if level.data.walls and level.data.walls[x][y] then

		if level.data.walls[x][y].type == 1 then
			return false
		end

		if level.data.walls[x][y].type == 2 then
			return false
		end
	
	end

	if level.data.boundarywalls and level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
		return false
	end
	
	if level:getObject(level.data.enemyblockers, x,y) then return false end	
	if level:getObject(level.data.enemies, x,y) then return false end	
	if level:getObject(level.data.doors, x,y) then return false end	
	if level:getObject(level.data.portals, x,y) then return false end
	if level:getObject(level.data.npcs, x,y) then return false end
	if level:getObject(level.data.chests, x,y) then	return false end
	if level:getObject(level.data.wells, x,y) then return false	end	
	
	local prop = level:getObject(level.data.staticprops, x,y)
	if prop then
		if prop.properties.name == "city-garden" then
			return true
		end
		return false
	end
	
	return true

end

function Enemy:isEnemyAt(x, y)

	local enemy = level:getObject(level.data.enemies, x,y)
	
	if enemy and enemy.properties.state == 1 then
		return true
	end
	
	return false

end

function Enemy:wander()

	-- 25% chance to scream

	if math.random() < 0.05 then
		if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) < 5 then
			assets:playSound(self.enemy.properties.sound_scream)
		end			
	
		return
	end
	
	-- 25% chance to turn around

	if math.random() < 0.15 then
		self.enemy.properties.direction = math.floor(math.random()*4)
		return
	end

	if self.enemy.properties.wanderer == 1 then

		local p = self:directionVectorOffsets()

		-- 75% chance to move if the enemy is a wanderer

		if math.random() < 0.75 then
		
			-- first check if there is an enemy in that direction. if there is then try to move in opposite direction
			
			if self:isEnemyAt(p.x,p.y) then
				self.enemy.properties.direction = self.enemy.properties.direction + 2
				if self.enemy.properties.direction > 3 then
					self.enemy.properties.direction = (self.enemy.properties.direction - 4)
				end
			end
			
			if self:canWalk(p.x,p.y) then
				if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) < 5 then
					assets:playSound(self.enemy.properties.sound_move)
				end			
				self.enemy.x = p.x
				self.enemy.y = p.y
				return
			else
				if math.random() < 0.75 then
					self.enemy.properties.direction = math.floor(math.random()*4)
					return
				end			
			end
			
		end

	end

end

function Enemy:attack()

	-- make sure enemy can't attack if player has just left
	
	if distanceFrom(party.x, party.y, self.enemy.x, self.enemy.y) <= 1 then
		assets:playSound(self.enemy.properties.sound_attack)
		self:facePlayer()
		self.enemy.properties.attacking = 1
		
		-- there is always a small chance that there will be a miss
		
		if math.random() > 0.5 then
			return
		end		

		local damage = 2 * math.pow(self.enemy.properties.attack, 2) / (self.enemy.properties.attack + party.stats.defence)

		damage = randomizeDamage(damage)

		party.stats.health = party.stats.health - damage
	
		if party.stats.health <= 0 then
			party.stats.health = 0
			assets:playSound("player-hit")
			subState = SubStates.TWEENING
			Timer.script(function(wait)
				wait(1)
				fadeMusicVolume.v = savedsettings.musicVolume
				
				--wait(2)
				assets:playSound("player-death")
				Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
				end)
				Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', function()
					assets:stopMusic(level.data.tileset)
					assets:playMusic("gameover")
					party:died()
				end)
			end)		
		else
			assets:playSound("player-hit")
		end
	
	end

	-- see if player left and calculate new tracking path
	
	if self:calcPathToPlayerPosition() then
		if self.pathlength > 1 then
			self.enemy.properties.attacking = 0
			self.state = EnemyState.TRACKING
		end
	end	
			
end

function Enemy:facePlayer()

	if party.x > self.enemy.x then self.enemy.properties.direction = 1 return end
	if party.x < self.enemy.x then self.enemy.properties.direction = 3 return end
	if party.y > self.enemy.y then self.enemy.properties.direction = 2 return end
	if party.y < self.enemy.y then self.enemy.properties.direction = 0 return end

end

function Enemy:showHighlight()

	self.highlightCounter = 0
	self.enemy.highlight = 1

end

function Enemy:die()
	
	self.enemy.properties.state = 3
	self.state = EnemyState.DEAD

end

return Enemy
