local Party = class('Party')

function Party:initialize()

	self.leftHandSlotIndex = 8
	self.rightHandSlotIndex = 6

	self.direction = 0
	self.x = 1
	self.y = 1
	
	self.cooldownDelays = {[1] = 2, [2] = 4, [3] = 8, [4] = 8}
	self.cooldownCounters = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}

	self.basestats =  {
		attack = 1,
		defence = 1,
		health_max = 20,
		mana_max = 20,
	}

	self.equipmentslots =  {
		{ type = "neck", x = 7, y = 7 },
		{ type = "head", x = 46, y = 7 },
		{ type = "back", x = 7, y = 45 },
		{ type = "torso", x = 46, y = 45 },
		{ type = "hands", x = 85, y = 45 },
		{ type = "offhand", x = 7, y = 83 },
		{ type = "waist", x = 46, y = 83 },
		{ type = "weapon", x = 85, y = 83 },
		{ type = "compass", x = 7, y = 122 },
		{ type = "map", x = 85, y = 122 },
		{ type = "feet", x = 46, y = 161 },
		{ type = "finger", x = 7, y = 200 },
		{ type = "finger", x = 46, y = 200 },
		{ type = "finger", x = 85, y = 200 },
		
	}
	
	self:resetStats()
	
end

function Party:update(dt)

	for i = 1,#self.cooldownCounters do
		if self.cooldownCounters[i] > 0 then
			self.cooldownCounters[i] = self.cooldownCounters[i] - dt
			if self.cooldownCounters[i] <= 0 then
				self.cooldownCounters[i] = 0
			end
		end
	end

end

function Party:attackWithMelee(enemy)

	local enemies = Game.enemies

	local handId = 1

	-- check if still cooling down

	if self.cooldownCounters[handId] > 0 then
		return false
	end

	-- make sure there is a weapon wielded
	
	local leftHand = party:getLeftHand()
	if not leftHand then return end

	self.cooldownCounters[handId] = self.cooldownDelays[handId]
	
	if not enemy then
		if handId == 1 then
			assets:playSound("player-miss")
		end
		return false
	end

	local damage

	-- there is always a small chance that there will be a miss in melee
		
	if math.random() > 0.85 then
		assets:playSound("player-miss")
		return false
	end
	
	assets:playSound("player-attack")
	
	damage = 2 * math.pow(party.stats.attack, 2) / (party.stats.attack + enemy.properties.defence)
	
	damage = randomizeDamage(damage)
	
	enemy.properties.health = enemy.properties.health - damage
	
	globalvariables:add(enemy.properties.id, "health", enemy.properties.health)
	
	for i = 1, #enemies do
		if enemies[i].enemy == enemy then
			enemies[i]:showHighlight()
		end
	end
		
	if enemy.properties.health <= 0 then
		assets:playSound(enemy.properties.sound_die)
		
		if enemy.properties.name == "The Queen" then
			self:victory()
			return true
		end
		
		globalvariables:add(enemy.properties.id, "state", 2)
		enemy.properties.state = 2
		
		for i = 1, #enemies do
			if enemies[i].enemy == enemy then
				enemies[i]:die()
				return true
			end
		end
	end
	
	return false
	
end

function Party:attackWithSpell(spell)

	local enemies = Game.enemies

	local handId = 2

	local enemy = level:getFacingEnemy()
	
	if enemy then
	
		local damage = 2 * math.pow(spell.modifiers.atk, 2) / (spell.modifiers.atk + enemy.properties.defence)

		damage = randomizeDamage(damage)

		assets:playSound(spell.id)
		
		enemy.properties.health = enemy.properties.health - damage

		globalvariables:add(enemy.properties.id, "health", enemy.properties.health)
		
		for i = 1, #enemies do
			if enemies[i].enemy == enemy then
				enemies[i]:showHighlight()
			end
		end
			
		if enemy.properties.health <= 0 then
			assets:playSound(enemy.properties.sound_die)
			
			if enemy.properties.name == "The Queen" then
				self:victory()
				return true
			end
			
			globalvariables:add(enemy.properties.id, "state", 2)
			enemy.properties.state = 2
			
			for i = 1, #enemies do
				if enemies[i].enemy == enemy then
					enemies[i]:die()
				end
			end
		end	
	
	else
	
		-- no enemy, just display spell animation and play sound
	
		assets:playSound(spell.id)
	
	end
	
	self.cooldownCounters[handId] = self.cooldownDelays[handId]
	
end

function Party:hasCooldown(handId)

	return self.cooldownCounters[handId] > 0

end

function Party:died()

	gameState = GameStates.GAMEOVER
	subState = SubStates.IDLE

	Timer.script(function(wait)
		wait(0.1)
		Timer.tween(1.0, fadeColor, {1,1,1}, 'in-out-quad', function()
		end)
	end)
	
end

function Party:victory()

	subState = SubStates.TWEENING
	Timer.script(function(wait)
		wait(1)
		fadeMusicVolume.v = savedsettings.musicVolume
		
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', function()
			assets:stopMusic(level.data.tileset)
			assets:playMusic("victory")
			
			gameState = GameStates.VICTORY
			subState = SubStates.IDLE

			Timer.script(function(wait)
				wait(0.1)
				Timer.tween(1.0, fadeColor, {1,1,1}, 'in-out-quad', function()
				end)
			end)	
			
		end)
	end)
	
end

function Party:updateStats()

	-- add the item modifiers
	
	local atk_mod = 0
	local def_mod = 0
	local hpmax_mod = 0
	local mpmax_mod = 0
	
	for i = 1, #self.equipped do
		
		if self.equipped[i].id ~= "" then
			
			local item = itemtemplates:get(self.equipped[i].id)
			
			if item.modifiers.atk then atk_mod = atk_mod + item.modifiers.atk end
			if item.modifiers.def then def_mod =def_mod + item.modifiers.def end
			if item.modifiers.maxhp then hpmax_mod = hpmax_mod + item.modifiers.maxhp end
			if item.modifiers.maxmp then mpmax_mod = mpmax_mod + item.modifiers.maxmp end
			
		end
	
	end
	
	-- set the modified stats
	
	self.stats.attack = self.basestats.attack + atk_mod 
	self.stats.defence = self.basestats.defence + def_mod
	self.stats.health_max = self.basestats.health_max + hpmax_mod
	self.stats.mana_max = self.basestats.mana_max + mpmax_mod
	
	-- make sure health and mana are never greater than max
	
	if self.stats.health > self.stats.health_max then self.stats.health = self.stats.health_max end
	if self.stats.mana > self.stats.mana_max then self.stats.mana = self.stats.mana_max end
	

end

function Party:consumeItem(id)

	for row = 1, 5 do
		for col = 1, 8 do
			if party.inventory[row][col] == id then
				party.inventory[row][col] = ""
				return true
			end
		end
	end
	
	return false
	
end

function Party:addGold(amount)

	self.gold = self.gold + amount

end

function Party:addAntsacs(amount)

	self.antsacs = self.antsacs + amount

end


function Party:addItem(id)

	for row = 1, 5 do
		for col = 1, 8 do
			if party.inventory[row][col] == "" then
				party.inventory[row][col] = id
				return
			end
		end
	end

	--print("Inventory is full. Unable to add '" .. id .."'")

end

function Party:addSpell(id)

	for i = 1, #self.spells do
		if self.spells[i] == id then
			return false
		end
	end

	table.insert(self.spells, id)

	return true

end

function Party:addItems(items)

	local itemslist = explode(items, ":")
	
	for i = 1, #itemslist do
		if itemslist[i] == "healing-potion" then
			self.healing_potions = self.healing_potions + 1
		elseif itemslist[i] == "mana-potion" then
			self.mana_potions = self.mana_potions + 1
		else
			self:addItem(itemslist[i])
		end
	end

end

function Party:getLeftHand()

	if self.equipped[self.leftHandSlotIndex].id ~= "" then
		return itemtemplates:get(self.equipped[self.leftHandSlotIndex].id)
	else
		return nil
	end

end

function Party:getrightHand()

	if self.equipped[self.rightHandSlotIndex].id ~= "" then
		return itemtemplates:get(self.equipped[self.rightHandSlotIndex].id)
	else
		return nil
	end
	
end

function Party:castSpell(id)

	-- check if still cooling down

	if self.cooldownCounters[2] > 0 then
		return
	end

	local spell = spelltemplates:get(id)
		
	if self.stats.mana >= spell.manacost then

		if spell.target == "player" then
		
			if spell.id == "lesser-heal" then
				if party.stats.health >= party.stats.health_max then
					renderer:showPopup("You are already at maximum health.")
					return false
				else
					party.stats.health = party.stats.health + math.floor(party.stats.health_max * 0.25)
					if party.stats.health > party.stats.health_max then party.stats.health = party.stats.health_max end
					assets:playSound(spell.id)
					self.cooldownCounters[2] = self.cooldownDelays[2]
				end
			elseif spell.id == "full-heal" then
				if party.stats.health >= party.stats.health_max then
					renderer:showPopup("You are already at maximum health.")
					return false
				else
					party.stats.health = party.stats.health_max
					assets:playSound(spell.id)
					self.cooldownCounters[2] = self.cooldownDelays[2]
				end
			elseif spell.id == "town-portal" then
				Game:invokeTownPortal()
			end
		
		else
			self:attackWithSpell(spell)
		end
	
		self.stats.mana = self.stats.mana - spell.manacost
		
		return true
	else
		renderer:showPopup("Not enough mana.")
		return false
	end

	return false

end

function Party:usePotion(index)

	if index == 1 then

		if self.healing_potions <= 0 then return end
		
		if self.cooldownCounters[index+2] > 0 then
			return
		end

		if party.stats.health >= party.stats.health_max then
			renderer:showPopup("You are already at maximum health.")
			return
		else
			self.cooldownCounters[index+2] = self.cooldownDelays[index+2]
			self.healing_potions = self.healing_potions - 1
			if self.healing_potions < 0 then self.healing_potions = 0 end
			self.stats.health = self.stats.health_max
		end
		
	else
		
		if self.mana_potions <= 0 then return end
		
		if self.cooldownCounters[index+2] > 0 then
			return
		end

		if party.stats.mana >= party.stats.mana_max then
			renderer:showPopup("You are already have maximum mana.")
			return
		else
			self.cooldownCounters[index+2] = self.cooldownDelays[index+2]
			self.mana_potions = self.mana_potions - 1
			if self.mana_potions < 0 then self.mana_potions = 0 end
			self.stats.mana = self.stats.mana_max
		end
		
	end
	
	assets:playSound("drink-potion")
	
end

function Party:hasCompass()

	return self.equipped[9].id ~= ""

end

function Party:hasMap()

	return self.equipped[10].id ~= ""

end

function Party:seenSquare(x, y)

	if self.mappedsquares and self.mappedsquares[level.data.id] and self.mappedsquares[level.data.id][x] and self.mappedsquares[level.data.id][x][y] then
		return self.mappedsquares[level.data.id][x][y] == 1
	end

	return false

end

function Party:squareIsSeen(x, y)

	if not self:hasMap() then
		return
	end
	
	if not self.mappedsquares then
		self.mappedsquares = {}
	end
	
	if not self.mappedsquares[level.data.id] then
		self.mappedsquares[level.data.id] = {}
	end	
	
	for row = -1, 1 do
		for col = -1, 1 do
		
			if not self.mappedsquares[level.data.id][x + col] then
				self.mappedsquares[level.data.id][x + col] = {}
			end
			
			self.mappedsquares[level.data.id][x + col][y + row] = 1	
		
		end
	end

end

function Party:hasSavegames()

	for i = 1, 3 do
		if self:isSavegameAtSlot(i) then
			return true
		end
	end

	return false
	
end

function Party:isSavegameAtSlot(index)

	local name = "savegame" .. index .. ".dat"

	local f = io.open(name, "r")
	
	return f ~= nil and io.close(f)
   
end

function Party:loadGameFromSlot(index)

	subState = SubStates.DISK_IO

	file, err = io.open("savegame"..index..".dat", "rb")
	
	if not err and file then
		
		local content = file:read("*all")
		file:close()
		
		local savedata = lume.deserialize(content)

		globalvariables.list = table.shallow_copy(savedata.vars)
		self.gold = savedata.gold
		self.antsacs = savedata.antsacs
		self.healing_potions = savedata.healing_potions
		self.mana_potions = savedata.mana_potions
		
		self.spells = table.shallow_copy(savedata.spells)
		self.mappedsquares = table.shallow_copy(savedata.mapped)
		self.inventory = table.shallow_copy(savedata.inventory)
		self.equipped = table.shallow_copy(savedata.equipped)
		self.stats = table.shallow_copy(savedata.stats)

		self.ticksElapsed = savedata.ticksElapsed and savedata.ticksElapsed or 0

		gameState = GameStates.LOADING_LEVEL
		fadeColor = {1,1,1}
		fadeMusicVolume.v = savedsettings.musicVolume
		
		Game.currentDoor = nil
		
		spawnTarget =  {
			x = savedata.x-1,
			y = savedata.y-1,
			direction = savedata.direction
		}		
		
		Timer.script(function(wait)
			Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
			end)
			Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
				assets:stopMusic(level.data.tileset)
				Game:loadArea(savedata.levelid)
			end)
		end)

		subState = SubStates.IDLE
		
		return true

	end

	subState = SubStates.IDLE
	
	return false

end

function Party:saveGameAtSlot(index)

	subState = SubStates.DISK_IO

	local savedata = {
		vars = globalvariables.list,
		mapped = self.mappedsquares,
		spells = self.spells,
		inventory = self.inventory,
		equipped = self.equipped,
		stats = self.stats,
		direction =	self.direction,
		x =	self.x,
		y = self.y,
		gold = self.gold,
		antsacs = self.antsacs,
		healing_potions = self.healing_potions,
		mana_potions = self.mana_potions,
		levelid = level.data.id,
		ticksElapsed = self.ticksElapsed
	}
	
	local serialized = lume.serialize(savedata)
	
	file, err = io.open("savegame"..index..".dat", "wb")
	
	if not err and file then
		file:write(serialized)
		file:close()
		savedsettings.lastSavegameSlot = index
		settings.savegameSlots[1] = self:isSavegameAtSlot(1)
		settings.savegameSlots[2] = self:isSavegameAtSlot(2)
		settings.savegameSlots[3] = self:isSavegameAtSlot(3)
		Game:saveSettings()
		subState = SubStates.IDLE
		return true
	else
		subState = SubStates.IDLE
		return false
	end
	
end

function Party:resetStats()

	-- saved properties

	self.spells = {}
	self.mappedsquares = {}

	self.gold = 0
	self.antsacs = 0
	self.healing_potions = 0
	self.mana_potions = 0
	
	self.ticksElapsed = 0
	
	self.stats =  {
		attack = 1,
		defence = 1,
		health = 20,
		health_max = 20,
		mana = 20,
		mana_max = 20,
	}
	
	self.spells = {}
	self.mappedsquares = {}
	
	self.inventory = {
		{"", "", "", "", "", "", "", ""},
		{"", "", "", "", "", "", "", ""},
		{"", "", "", "", "", "", "", ""},
		{"", "", "", "", "", "", "", ""},
		{"", "", "", "", "", "", "", ""},
	}
	
	self.equipped =  {
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = "sword-1"},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
		{ id = ""},
	}
	
end

return Party