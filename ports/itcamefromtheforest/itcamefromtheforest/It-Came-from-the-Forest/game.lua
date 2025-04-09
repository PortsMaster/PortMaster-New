local Renderer = require "renderer"
local Assets = require "assets"
local Party = require "party"
local Level = require "level"
local Atlases = require "atlases"
local Enemy = require "enemy"
local Vendors = require "vendors"

Timer = require "libs/timer"
Button = require "button"


local GlobalVariables = require "globalvariables"
local ItemTemplates = require "itemtemplates"
local SpellTemplates = require "spelltemplates"

assets = Assets:new()
renderer = Renderer:new()
level = Level:new()
atlases = Atlases:new()
party = Party:new()
globalvariables = GlobalVariables:new()
vendors = Vendors:new()

local Game = class('Game')

itemtemplates = ItemTemplates:new()
spelltemplates = SpellTemplates:new()

function Game:initialize()

	math.randomseed(os.time())

	gameState = GameStates.INIT
	subState = SubStates.IDLE
	self.footStepIndex = 1
	love.graphics.setDefaultFilter( "nearest", "nearest", 0)
	
end

function wait(delay)
  delay = delay or 1
  local time_to = os.time() + delay
  while os.time() < time_to do end
end

function Game:init()

	self:loadSettings()

	love.window.setFullscreen(savedsettings.fullScreen and savedsettings.fullScreen == true)
	
	love.mouse.setGrabbed(true)
	love.mouse.setVisible(false)
	
	self.canvas = love.graphics.newCanvas(screen.width, screen.height)
	spawnTarget = nil
	assets:load()
	
	renderer:init(self)
	
	settings.canContinue = party:isSavegameAtSlot(savedsettings.lastSavegameSlot)
	
	settings.savegameSlots[1] = party:isSavegameAtSlot(1)
	settings.savegameSlots[2] = party:isSavegameAtSlot(2)
	settings.savegameSlots[3] = party:isSavegameAtSlot(3)
	
	party:updateStats()
	
	if settings.quickstart then
		gameState = GameStates.LOADING_LEVEL
		assets:stopMusic("mainmenu")
		self.fromSaveFile = false
		Game:loadArea(settings.startingArea)
	else 
		fadeMusicVolume.v = savedsettings.musicVolume
		assets:playMusic("buildup")
		gameState = GameStates.BUILDUP1
		Timer.script(function(wait)
			Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
			wait(4)
			Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep2)
		end)
	end
	
end

function Game:update(dt)


	if gameState == GameStates.EXPLORING then
		
		if subState == SubStates.IDLE then
		
			if self.enemies then
				for key,value in pairs(self.enemies) do
					self.enemies[key]:update(dt)
				end
			end
			
			party:update(dt)

		end
		
	end
	
	if gameState ~= GameStates.INIT then
		renderer:update(dt)
	end
	
	if gameState == GameStates.MAIN_MENU then
		if assets.music["mainmenu"] then
			assets:setMusicVolume("mainmenu", fadeMusicVolume.v)
		end
	end
	
	if gameState == GameStates.LOADING_LEVEL then
		if assets.music[level.data.tileset] then
			assets:setMusicVolume(level.data.tileset, fadeMusicVolume.v)
		end
	end	
	
	if subState == SubStates.TWEENING then
		if assets.music[level.data.tileset] then
			assets:setMusicVolume(level.data.tileset, fadeMusicVolume.v)
		end
	end	
	
	love.graphics.setColor(fadeColor)
	
	Timer.update(dt)
	
end

function Game:handleMousePressed(x, y, button, istouch)
	
	if gameState == GameStates.INIT or gameState == GameStates.LOADING_LEVEL then
		return
	end
	
	if button == 1 then
	
		if gameState == GameStates.BUILDUP1 or gameState == GameStates.BUILDUP2 or gameState == GameStates.BUILDUP3 or gameState == GameStates.BUILDUP4 then
			if savedsettings.skipIntro then
				self:jumpToMainmenu()
			end
			return
		end	
	
		if gameState == GameStates.EXPLORING then
			
			if subState == SubStates.IDLE then
				
				if self:checkIfClickedOnFacingObject(x, y) then
					return
				end
				
				if intersect(x, y, 278, 321, 34, 34) then -- attack with left hand
				
					local enemy = level:getFacingEnemy()

					if party:attackWithMelee(enemy) then -- returns true if enemy is killed
						if enemy.properties.antsacs > 0 or enemy.properties.gold > 0 or enemy.properties.loot ~= "" then
							renderer:showFoundLoot(enemy.properties.gold, explode(enemy.properties.loot, ":"), enemy.properties.antsacs)
							party:addAntsacs(enemy.properties.antsacs)
							party:addGold(enemy.properties.gold)
							party:addItems(enemy.properties.loot)
						end
						return
					end
					
				end
				
				if intersect(x, y, 326, 321, 34, 34) then-- attack with right hand
					if party:getrightHand() and not party:hasCooldown(2) then
						if #party.spells == 0 then
							renderer:showPopup("You don't have any spells.")
						else
							renderer:showSpellList()
						end
					end
					return
				end
				
				if intersect(x, y, 239, 325, 30, 30) then
					party:usePotion(1)
					return
				end
				
				if intersect(x, y, 372, 325, 30, 30) then
					party:usePotion(2)
					return
				end

				if intersect(x, y, 19, 321, 34, 34) then
					if not renderer:inventoryShowing() then
						renderer:showInventory(true)
						return
					end
				end

				if intersect(x, y, 541, 321, 34, 34) and party:hasMap() then
					if not renderer:automapperShowing() then
						renderer:showAutomapper(true)
						return
					end				
				end
				
				if intersect(x, y, 587, 321, 34, 34) then
					if not renderer:systemMenuShowing() then
						renderer:showSystemMenu(true)
						return
					end
				end
				
			end
			
		end
	
	end
	
	if button == 3 then
		local state = not love.mouse.isGrabbed()   -- the opposite of whatever it currently is
		love.mouse.setGrabbed(state)
	end
   
	renderer:handleMousePressed(x, y, button)
   
end


function Game:handleInput(key)

	if gameState == GameStates.INIT or gameState == GameStates.LOADING_LEVEL then
		return
	end

	local key = string.lower(key)

	-- COMMON
	
	if settings.debugmode then
	
		if key == 'f9' then
			gameState = GameStates.VICTORY
			subState = SubStates.IDLE
		end

		if key == 'f1' then
			if party:loadGameFromSlot(1) then
			end
		end
		
		if key == 'f3' then
			if party:loadGameFromSlot(2) then
			end
		end
		
		if key == 'f4' then
			if party:saveGameAtSlot(2) then
			end
		end
	
	end
	
    if key == 'return' then
		if love.keyboard.isDown("lalt") then
			love.window.setFullscreen(not love.window.getFullscreen())
			savedsettings.fullScreen = love.window.getFullscreen()
		end
    end

	if gameState == GameStates.FATAL_ERROR then
		love.event.quit()
		return
	end
	
	if gameState == GameStates.MAIN_MENU then
	
		if key == 'escape' then
			self:quitGame()
			return
		end
			
	end
	
	if gameState == GameStates.EXPLORING then

		if subState == SubStates.IDLE then

			if key == 'escape' then
				--self:quitGame()
				--return
			end

			if key == 'left' or key == 'kp7' or key == 'q' then
				party.direction = party.direction - 1
				if party.direction < 0 then
					party.direction = 3
				end
				renderer:flipGround()
				renderer:flipSky()
				self:playFootstepSound()
				return
			end

			if key == 'right' or key == 'kp9' or key == 'e' then
				party.direction = party.direction + 1
				if party.direction > 3 then
					party.direction = 0
				end
				renderer:flipGround()
				renderer:flipSky()
				self:playFootstepSound()
				return
			end
			
			if key == 'up' or key == 'kp8' or key == 'w' then
				self:moveForward()
				return
			end
			
			if key == 'down' or key == 'kp2' or key == 's' then
				self:moveBackward()
				return
			end
			
			if key == 'kp4' or key == 'a' then
				self:strafeLeft()
				return
			end
			
			if key == 'kp6' or key == 'd' then
				self:strafeRight()
				return
			end			

			if key == 'i' then
				if not renderer:inventoryShowing() then
					renderer:showInventory(true)
					return
				end
			end	
			
			if key == 'escape' then
				if not renderer:systemMenuShowing() then
					renderer:showSystemMenu(true)
					return
				end
			end	
			
			if key == 'm' and party:hasMap() then
				if not renderer:automapperShowing() then
					renderer:showAutomapper(true)
					return
				end				
			end	
			
		end

		renderer:handleInput(key)
		
	end
	
end

function Game:playFootstepSound()

	assets:playSound(assets.sfx.footsteps[level.data.tileset][self.footStepIndex])

	self.footStepIndex = self.footStepIndex + 1
	if self.footStepIndex > #assets.sfx.footsteps.city then
		self.footStepIndex = 1
	end
	
end

function Game:moveForward()

	local x,y = party.x,party.y

	if party.direction == 0 then
		y = party.y - 1
	elseif party.direction == 1 then
		x = party.x + 1
	elseif party.direction == 2 then
		y = party.y + 1
	elseif party.direction == 3 then
		x = party.x - 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end
	
	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:tick()

end

function Game:moveBackward()

	local x,y = party.x,party.y

	if party.direction == 0 then
		y = party.y + 1
	elseif party.direction == 1 then
		x = party.x - 1
	elseif party.direction == 2 then
		y = party.y - 1
	elseif party.direction == 3 then
		x = party.x + 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:tick()

end

function Game:strafeLeft()

	local x,y = party.x,party.y

	if party.direction == 0 then
		x = party.x - 1
	elseif party.direction == 1 then
		y = party.y - 1
	elseif party.direction == 2 then
		x = party.x + 1
	elseif party.direction == 3 then
		y = party.y + 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:tick()

end

function Game:strafeRight()

	local x,y = party.x,party.y

	if party.direction == 0 then
		x = party.x + 1
	elseif party.direction == 1 then
		y = party.y + 1
	elseif party.direction == 2 then
		x = party.x - 1
	elseif party.direction == 3 then
		y = party.y - 1
	end	

	local handled = self:handleTileCollide(x, y)

	if handled == true then
		return
	end

	party.x = x
	party.y = y
	
	renderer:flipGround()
	
	self:stepOnGround()

	self:tick()

end

function Game:handleTileCollide(x, y)

	-- enemies
	
	for key,value in pairs(level.data.enemies) do
		if level.data.enemies[key].x == x and level.data.enemies[key].y == y then
			if level.data.enemies[key].properties.state == 1 then
				return true
			end
		end
	end	
	
	-- wall

	if level.data.walls and level.data.walls[x][y] then

		if level.data.walls[x][y].type == 1 then
			return true
		end

		if level.data.walls[x][y].type == 2 then
			assets:playSound(level.data.tileset .. "-illusionary-wall")
			return false
		end
	
	end

	if level.data.boundarywalls and level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
		return true
	end
	
	-- static prop
	
	local prop = level:getObject(level.data.staticprops, x,y)
	
	if prop then
	
		if prop.properties.name == "barricade" then

			if prop.properties.visible == 1 then

				assets:playSound("barricade-hurt")
				
				party.stats.health = party.stats.health - 10
			
				if party.stats.health <= 0 then
					assets:playSound("player-death")
					party:died()
				end			
				
				return true
			else
				return false
			end	
		end
	
		if prop.properties.name == "city-garden" then

			return false
		end
	
		return true
	end		
	
	-- portal
	
	local portal = level:getObject(level.data.portals, x,y)
	
	if portal and portal.properties.visible == 1 then
		return true
	end
	
	-- boss gate
	
	local bossgate = level:getObject(level.data.bossgates, x,y)
	
	if bossgate and bossgate.properties.state ~= 1 then
		return true
	end
	
	-- npc
	
	local npc = level:getObject(level.data.npcs, x,y)
	
	if npc and npc.properties.visible == 1 then
		return true
	end
	
	-- chest
	
	if level:getObject(level.data.chests, x,y) then
		return true
	end
	
	-- well
	
	if level:getObject(level.data.wells, x,y) then
		return true
	end		
	
	-- levelexit
	
	if level:getObject(level.data.levelexits, x,y) then
		return true
	end		
	
	return false

end

function Game:teleportTo(x, y, direction)

	party.x = x
	party.y = y
	party.direction = direction

	self:stepOnGround()

end

function Game:stepOnGround(playFootsteps)

	party:squareIsSeen(party.x, party.y)

	-- Invisible teleporter

	local teleporter = level:getObject(level.data.teleporters, party.x, party.y)

	if teleporter then
		if teleporter.properties.state == 1 then
			self:teleportTo(teleporter.properties.targetx+1, teleporter.properties.targety+1, teleporter.properties.targetdir)
			assets:playSound("teleport")
			return
		end
	end

	if playFootsteps == true or playFootsteps == nil then
		self:playFootstepSound()
	end
	
	-- Spinner

	local spinner = level:getObject(level.data.spinners, party.x, party.y)

	if spinner then
		party.direction = party.direction + 2
		if party.direction > 3 then
			party.direction = (party.direction - 4)
		end
		return
	end
	
	-- Trigger
	
	local trigger = level:getObject(level.data.triggers, party.x, party.y)

	if trigger and trigger.properties.state == 1 then
		if trigger.properties.text ~= "" then
			renderer:showPopup(trigger.properties.text)
		end
		trigger.properties.state = 2
		globalvariables:add(trigger.properties.id, "state", trigger.properties.state)
		level:applyVars(trigger.properties.vars)
		return
	end	
	
end

function Game:loadArea(id)

	local target = nil

	if self.currentDoor then
		target = {}
		target.x = self.currentDoor.properties.targetx
		target.y = self.currentDoor.properties.targety
		target.direction = self.currentDoor.properties.targetdir
	else
		target = spawnTarget
	end

	if level:load(id, target) then

		if not atlases:load(level.data.tileset) then
			print("-- FATAL ERROR --",10,10)
			print("> Error loading atlases. Check console output.",10,40)
			print("Press any key to quit.",10,70)
			love.event.quit()
			return
		end	
	
		level.loaded = true

		local map = level:generatePathMap()

		self.enemies = {}
			
		for key,value in pairs(level.data.enemies) do
			local e = level.data.enemies[key]
			local enemy = Enemy:new(e)
			enemy:setMap(map)
			table.insert(self.enemies, enemy)
		end

		-- update objects that have a cooldown
		
		for key,value in pairs(level.data.wells) do
			
			local well = level.data.wells[key]

			well.properties.counter = well.properties.counter - party.ticksElapsed
			
			if well.properties.counter < 0 then
				well.properties.counter = 0
			end

		end	
	
		party.ticksElapsed = 0

		-- update state

		gameState = GameStates.EXPLORING
		subState = SubStates.IDLE

		-- fade in

		fadeColor = color.black
		
		Timer.clear()
		
		Timer.script(function(wait)
			Timer.tween(1, fadeMusicVolume, {v = savedsettings.musicVolume}, 'in-out-quad', function()
			end)
			Timer.tween(1, fadeColor, {1,1,1}, 'in-out-quad', function()
				Game.footStepIndex = 1
				Game:stepOnGround(false)
				assets:playMusic(level.data.tileset)
			end)
		end)
		
	else
		print("-- FATAL ERROR --",10,10)
		print("> Error loading level: \""..id..".lua\"",10,40)
		print("Press any key to quit.",10,70)
		love.event.quit()
	end

end

function Game:startGame()

	globalvariables:clear()
	party:resetStats()
	party:updateStats()

	spawnTarget = nil
	self.currentDoor = nil
	
	subState = SubStates.LOADING_LEVEL
	fadeColor = {1,1,1}
	Timer.script(function(wait)
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
			gameState = GameStates.LOADING_LEVEL
			assets:stopMusic("mainmenu")
			self.fromSaveFile = false
			Game:loadArea(settings.startingArea)
		end)
	end)
			
end

function Game:continueGame()

	subState = SubStates.LOADING_LEVEL
	fadeColor = {1,1,1}
	Timer.script(function(wait)
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
			assets:stopMusic("mainmenu")
			party:loadGameFromSlot(savedsettings.lastSavegameSlot)
		end)
		
	end)

end

function Game:checkIfClickedOnFacingObject(x, y)

	-- door

	local door = level:getFacingObject(level.data.doors, x, y)
	
	if door and intersectBox(x, y, world_hitboxes["door"]) then
		if door.properties.type == 1 then
			
			if door.properties.vendor ~= "" then
				renderer:showVendor(door.properties.vendor)
			else
				assets:playSound("door-locked", false)
				renderer:showPopup("There doesn't seem to be anyone home, or they're just too scared to open the door.", false)
			end

		elseif door.properties.type == 2 then
			if door.properties.state == 1 then
				if door.properties.keyid and door.properties.keyid ~= "" then
					if party:consumeItem(door.properties.keyid) then
						renderer:showPopup("You use a key to unlock the door.")
						door.properties.keyid = ""
						globalvariables:add(door.properties.id, "keyid", door.properties.keyid)
						assets:playSound("door-open")
						return true
					else
						renderer:showPopup("You don't have the key that unlocks this door.")
					end
				else
					gameState = GameStates.LOADING_LEVEL
					fadeColor = {1,1,1}
					if level.data.tileset == "dungeon" then
						assets:playSound("stairs")
					else
						assets:playSound("city-gate")
					end
					Game.currentDoor = door
					fadeMusicVolume.v = savedsettings.musicVolume
					self.fromSaveFile = false
					Timer.script(function(wait)
						Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
						end)
						Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
							assets:stopMusic(level.data.tileset)
							Game:loadArea(Game.currentDoor.properties.targetarea)
						end)
					end)				
				end
			else
				assets:playSound("hmm")
				renderer:showPopup("The door is blocked by some unknown mechanism.", false)
			end
		end
		return true
	end

	-- npc
	
	local npc = level:getFacingObject(level.data.npcs, x, y)

	if npc and npc.properties.visible == 1 and intersectBox(x, y, world_hitboxes["npc"]) then
	
		
		if checkCriterias(npc.properties.criterias) then
			npc.properties.delayedLoot = (npc.properties.state == 1) and true or false
			assets:playSound("quest-complete")
			npc.properties.state = 2
			npc.properties.criterias = ""
			globalvariables:add(npc.properties.id, "state", npc.properties.state)
			globalvariables:add(npc.properties.id, "criterias", npc.properties.criterias)
			level:applyVars(npc.properties.vars)
			renderer:showNPC(npc)
			return true
		end

		if npc.properties.state == 1 then
			level:applyVars(npc.properties.init_vars)
		end
		
		if npc.properties.state == 2 then
			npc.properties.state = 3
			globalvariables:add(npc.properties.id, "state", npc.properties.state)
			assets:playSound(npc.properties.sound)
			renderer:showNPC(npc)
			return true
		else
			assets:playSound(npc.properties.sound)
			renderer:showNPC(npc)
			return true
		end
		
	end

	-- boss gate

	local bossgate = level:getFacingObject(level.data.bossgates, x,y)
	
	if bossgate and intersectBox(x, y, world_hitboxes["door"]) then
		
		if bossgate.properties.state == 2 then
			if bossgate.properties.keyid and bossgate.properties.keyid ~= "" then
				if party:consumeItem(bossgate.properties.keyid) then
					bossgate.properties.keyid = ""
					globalvariables:add(bossgate.properties.id, "keyid", bossgate.properties.keyid)
					assets:playSound("unlock")
					renderer:showPopup("You use a key to unlock the gate.", false)
				else
					renderer:showPopup("You don't have the key that unlocks this gate.")
				end
			else
				bossgate.properties.state = 1
				globalvariables:add(bossgate.properties.id, "state", bossgate.properties.state)
				assets:playSound("bossgate")		
				
				local map = level:generatePathMap()
				for key,value in pairs(self.enemies) do
					self.enemies[key]:setMap(map)
				end
				
			end
			return true
		end
		
	end
	
	-- portal
	
	local portal = level:getFacingObject(level.data.portals, x, y)
	
	if portal and intersectBox(x, y, world_hitboxes["portal"]) then
		if portal.properties.state == 1 then
			assets:playSound("portal")
			party.y = portal.properties.targety+1
			party.x = portal.properties.targetx+1
			party.direction = portal.properties.targetdir
			renderer:flipGround()
			self:stepOnGround()
			self:playFootstepSound()
			self:tick()
		else
			renderer:showPopup("The portal seems to be inactive.")
		end
		return true
	end
	
	-- chest
	
	local chest = level:getFacingObject(level.data.chests, x,y)
	
	if chest and intersectBox(x, y, world_hitboxes["chest"]) then
		
		if chest.properties.state == 1 then
			if chest.properties.keyid and chest.properties.keyid ~= "" then
				if party:consumeItem(chest.properties.keyid) then
					chest.properties.keyid = ""
					globalvariables:add(chest.properties.id, "keyid", chest.properties.keyid)
					assets:playSound("unlock")
					renderer:showPopup("You use a key to unlock the chest.", false)
					return true
				else
					renderer:showPopup("You don't have the key that unlocks this chest.")
				end
			else
				chest.properties.state = 2
				if chest.properties.gold > 0 or chest.properties.loot ~= "" then
					renderer:showFoundLoot(chest.properties.gold, explode(chest.properties.loot, ":"), 0)
					party:addGold(chest.properties.gold)
					party:addItems(chest.properties.loot)
					chest.properties.gold = 0
					chest.properties.loot = ""
					globalvariables:add(chest.properties.id, "gold", chest.properties.gold)
					globalvariables:add(chest.properties.id, "loot", chest.properties.loot)
				end
				globalvariables:add(chest.properties.id, "state", chest.properties.state)
				assets:playSound("chest-open")
			end
		elseif chest.properties.state == 2 then
			chest.properties.state = 1
			globalvariables:add(chest.properties.id, "state", chest.properties.state)
			assets:playSound("chest-close")
		elseif chest.properties.state == 3 then
			renderer:showPopup("The chest is blocked by some unknown mechanism.")
		end
		return true
	end
	
	-- well
	
	local well = level:getFacingObject(level.data.wells, x,y)
	
	if well and intersectBox(x, y, world_hitboxes["well"]) then
		if well.properties.counter > 0 then
			renderer:showPopup("Drinking from the well has no effect. Maybe try again later?")
		else
			if party.stats.health < party.stats.health_max or party.stats.mana < party.stats.mana_max then
				party.stats.health = party.stats.health_max
				party.stats.mana = party.stats.mana_max
				assets:playSound("drink-fountain")
				well.properties.counter = well.properties.counter_max
				globalvariables:add(well.properties.id, "counter", well.properties.counter)
			else
				renderer:showPopup("You already feel fully refreshed.")
			end
		end
		return true
	end	
	
	-- static prop
	
	local prop = level:getFacingObject(level.data.staticprops, x,y)
	
	if prop and intersectBox(x, y, world_hitboxes["prop"]) then
	
		if prop.properties.name == "barrels" then
		
			if prop.properties.gold > 0 or prop.properties.loot ~= "" then
				renderer:showFoundLoot(prop.properties.gold, explode(prop.properties.loot, ":"), 0)
				party:addGold(prop.properties.gold)
				party:addItems(prop.properties.loot)
				prop.properties.gold = 0
				prop.properties.loot = ""
				globalvariables:add(prop.properties.id, "gold", prop.properties.gold)
				globalvariables:add(prop.properties.id, "loot", prop.properties.loot)
				return true
			end
	
		elseif prop.properties.text and prop.properties.text ~= "" then
			renderer:showPopup(prop.properties.text)
			return true
		end
	end		
	
	-- button
	
	local button = level:getFacingObject(level.data.buttons, x,y)
	
	if button and intersectBox(x, y, world_hitboxes["button"]) then
		if button.properties.state == 1 then
			button.properties.state = 2
			assets:playSound("button")
			globalvariables:add(button.properties.id, "state", button.properties.state)
			level:applyVars(button.properties.vars)
		end
		return true
	end		
	
	-- levelexit
	
	local levelexit = level:getFacingObject(level.data.levelexits, x,y)
	
	if levelexit and intersectBox(x, y, world_hitboxes["levelexit"]) then
		
		spawnTarget =  {
			x = levelexit.properties.targetx,
			y = levelexit.properties.targety,
			direction = levelexit.properties.targetdir
		}
		
		Game.currentDoor = nil
		gameState = GameStates.LOADING_LEVEL
		fadeColor = {1,1,1}
		self.fromSaveFile = false
		--assets:playSound("city-gate")
		fadeMusicVolume.v = savedsettings.musicVolume
		Timer.script(function(wait)
			Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
			end)
			Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
				assets:stopMusic(level.data.tileset)
				Game:loadArea(levelexit.properties.targetarea)
			end)
		end)	
					
		return true
	end	
	
	return false
	
end

function Game:jumpToMainmenu()

	Timer.clear()

	savedsettings.skipIntro = true

	gameState = GameStates.MAIN_MENU

	fadeColor = {1,1,1}

	love.graphics.setColor(1,1,1,1)

	assets:stopMusic("buildup")
	assets:playMusic("mainmenu")

end

function Game:invokeTownPortal()

	gameState = GameStates.LOADING_LEVEL
	self.currentDoor = nil
	fadeColor = {1,1,1}
	assets:playSound("portal")
	fadeMusicVolume.v = savedsettings.musicVolume
	Timer.script(function(wait)
		Timer.tween(1, fadeMusicVolume, {v = 0}, 'in-out-quad', function()
		end)
		Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad', function()
			assets:stopMusic(level.data.tileset)
			spawnTarget =  {
				x = 19,
				y = 15,
				direction = 1
			}			
			Game:loadArea("city")
		end)
	end)	

end

function Game:loadSettings()

	local filename = love.filesystem.getSourceBaseDirectory() .. "/settings.cfg"

	file, err = io.open(filename, "rb")
	
	if not err and file then
		local content = file:read("*all")
		savedsettings = lume.deserialize(content)
		file:close()
		return true
	else
		return false
	end

end

function Game:saveSettings()

	local filename = love.filesystem.getSourceBaseDirectory() .. "/settings.cfg"

	local serialized = lume.serialize(savedsettings)
	
	file, err = io.open(filename, "wb")
	
	if not err and file then
		file:write(serialized)
		file:close()
		return true
	else
		return false
	end

end

function Game:quitGame()

	gameState = GameStates.QUITTING

	self:saveSettings()

	love.event.quit()

end

function Game:tick()

	-- count down on all the wells in this area
	
	for key,value in pairs(level.data.wells) do
		
		local well = level.data.wells[key]

		well.properties.counter = well.properties.counter - 1
		globalvariables:add(well.properties.id, "counter", well.properties.counter)
		
		if well.properties.counter < 0 then
			well.properties.counter = 0
		end

	end	

	party.ticksElapsed = party.ticksElapsed + 1

end


function buildUpStep2()

	gameState = GameStates.BUILDUP2

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(4)
		Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep3)
	end)

end

function buildUpStep3()

	gameState = GameStates.BUILDUP3

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(4)
		Timer.tween(2, fadeColor, {0,0,0}, 'in-out-quad', buildUpStep4)
	end)

end

function buildUpStep4()

	gameState = GameStates.BUILDUP4

	Timer.script(function(wait)
		Timer.tween(2, fadeColor, {1,1,1}, 'in-out-quad')
		wait(5.4)
		Game:jumpToMainmenu()
	end)

end

---------------------------------------------------------------------------------------------------------------------------

return Game