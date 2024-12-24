local Renderer = class('Renderer')

local direction_names = {[0] = "North", [1] = "East", [2] = "South", [3] = "West"}

function Renderer:initialize()
	
end

function Renderer:init(caller)
		
	self.caller = caller
	self.canvas = caller.canvas
	self.dungeonDepth = 6
	self.dungeonWidth = 4
	self.backgroundIndex = 1
	self.skyIndex = 1
	self.currentNPC = nil
	self.currentVendor = nil
	self.doShowSystemMenu = false
	self.doShowAutomapper = false
	self.doShowInventory = false
	self.currentHoverItem = nil
	self.currentHoverSpell = nil
	self.showSpellEffect = false
	self.showTavern = false
	
	self.popupText = ""
	
	self.buttons = {}
	
	local button = Button:new()
	button.id = "close-inventory"
	button.x = settings.inventoryX+363
	button.y = settings.inventoryY+200
	button.width = 32
	button.height = 32
	button.normal = "button-close-1"
	button.over = "button-close-2"
	button.trigger = self.onCloseButtonClick

	self.buttons[button.id] = button
	
	local button = Button:new()
	button.id = "close-vendor"
	button.x = 516
	button.y = 236
	button.width = 32
	button.height = 32
	button.normal = "button-close-1"
	button.over = "button-close-2"
	button.trigger = self.onCloseVendorButtonClick

	self.buttons[button.id] = button

	local button = Button:new()
	button.id = "close-map"
	button.x = 439
	button.y = 216
	button.width = 32
	button.height = 32
	button.normal = "button-close-1"
	button.over = "button-close-2"
	button.trigger = self.onCloseMapButtonClick

	self.buttons[button.id] = button
	
	local button = Button:new()
	button.id = "close-tavern"
	button.x = 516
	button.y = 236
	button.width = 32
	button.height = 32
	button.normal = "button-close-1"
	button.over = "button-close-2"
	button.trigger = self.onCloseTavernButtonClick

	self.buttons[button.id] = button	
	
	self.menuitemsOffsetX = 512
	self.menuitemsOffsetY = 120
	self.menuitems = {
		{ caption = "New game", trigger = self.onStartButtonClick},
		{ caption = "Continue", trigger = self.onContinueGameButtonClick},
		{ caption = "Credits", trigger = self.onCreditsButtonClick},
		{ caption = "About", trigger = self.onAboutButtonClick},
		{ caption = "Quit", trigger = self.onQuitButtonClick}
	}	

	self.systemmenuOffsetY = 65
	self.systemmenuitemsOffsetY = 110
	self.systemmenuitems = {
		{ caption = "Exit to main menu", trigger = function() self:onBackToMenuButtonClick() end},
		{ caption = "Quit to desktop", trigger = function() self:onQuitButtonClick() end},
		{ caption = "Close", trigger = function() self:onCloseSystemMenuButtonClick() end},
	}	
	
	self.loadslots = {
		{caption = "SLOT 1", x = 214, y = 214, w = 55, h = 17},
		{caption = "SLOT 2", x = 214+60, y = 214, w = 55, h = 17},
		{caption = "SLOT 3", x = 214+60*2, y = 214, w = 55, h = 17}
	}
	
	self.saveslots = {
		{caption = "SLOT 1", x = 214, y = 236, w = 55, h = 17},
		{caption = "SLOT 2", x = 214+60, y = 236, w = 55, h = 17},
		{caption = "SLOT 3", x = 214+60*2, y = 236, w = 55, h = 17}
	}
	
end

function Renderer:drawImage(x, y, id, center)

	if assets.images[id] then

		if center and center == true then
			x = math.floor(screen.width/2 - assets.images[id]:getWidth()/2)
		end

		love.graphics.draw(assets.images[id], x, y)	

	end

end

function Renderer:update(dt)

	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	love.graphics.setColor(1,1,1,1)
	love.graphics.setFont(assets.fonts["main"]);
	love.graphics.setLineStyle("rough")
	love.graphics.setShader(highlightshader)
	
	if gameState == GameStates.EXPLORING then
	
		self:drawViewport()

		-- Enemy in front of player?

		local enemy = level:getFacingEnemy()
		
		if enemy and enemy.properties.state == 1 then
			self:drawEnemyStats(enemy)
		end

		if self.doShowAutomapper then
			self:drawAutomapper()
		end

		if self.doShowInventory then
			self:drawInventory()
			self:showPlayerStats()
		end
		
		if subState == SubStates.SELECT_SPELL then
			self:drawSpellList()
		end

		self:drawUI()
	
	end

	if gameState == GameStates.BUILDUP1 then
		love.graphics.draw(assets.images["zoopersoft-games"], 0, 0)
	end
	
	if gameState == GameStates.BUILDUP2 then
		self:drawWrappedText(0,170, "AN UNSPEAKABLE EVIL HAS FALLEN UPON US", screen.width, {1,1,1,1}, "center")
	end
	
	if gameState == GameStates.BUILDUP3 then
		self:drawWrappedText(0,170, "IT IS NOT KNOWN WHO OR WHAT IS BEHIND IT", screen.width, {1,1,1,1}, "center")
	end
	
	if gameState == GameStates.BUILDUP4 then
		self:drawWrappedText(0,170, "ALL WE KNOW IS...", screen.width, {1,1,1,1}, "center")
	end
	
	if gameState == GameStates.MAIN_MENU then
		self:drawMainmenu()
	end
	
	if gameState == GameStates.CREDITS then
		self:drawCredits()
	end	
	
	if gameState == GameStates.ABOUT then
		self:drawAbout()
	end		

	if gameState == GameStates.SETTINGS then
		self:drawSettings()
	end		
	
	if subState == SubStates.VENDOR then
		self:drawVendor()
	end
	
	if self.showTavern then
		self:drawTavern()
	end	
	
	if subState == SubStates.POPUP then
		self:drawPopup()
	end

	if subState == SubStates.NPC then
		if self.currentNPC then
			self:drawNPC()
		end
	end
	
	if gameState == GameStates.GAMEOVER then
		self:drawGameOver()
	end

	if gameState == GameStates.VICTORY then
		self:drawVictory()
	end
	
	if subState == SubStates.FOUND_LOOT then
		self:drawFoundLoot()
	end
	
	if subState == SubStates.VENDOR_ANTSACS then
		self:drawAntsacsVendor()
	end	

	if self.doShowSystemMenu then
		self:drawSystemMenu()
	end
	
	if self.showSpellEffect then
		self:drawImage(320, 170, self.currentSpell.imageid, true)
	end
	
	if gameState == GameStates.EXPLORING
	or gameState == GameStates.MAIN_MENU
	or gameState == GameStates.CREDITS
	or gameState == GameStates.ABOUT
	or gameState == GameStates.GAMEOVER
	or gameState == GameStates.VICTORY
	then
		self:drawPointer()	
	end
	
	if self.currentHoverItem then
		self:showItemHoverStats(self.currentHoverItem)
	end
	
	if self.currentHoverSpell then
		self:showSpellHoverStats(self.currentHoverSpell)
	end	


	if settings.debugmode then
		--local mx, my = love.mouse.getPosition()
		--self:drawText(20, 20, mx .. "/" .. my, {1,1,1,1}, "left")
		--self:drawText(20, 40, tostring(love.timer.getFPS()), {1,1,1,1})
	end
	
	love.graphics.setCanvas()

end

function Renderer:handleMousePressed(x, y, button)
	
	if button == 1 then

		if gameState == GameStates.GAMEOVER or gameState == GameStates.VICTORY then
			fadeMusicVolume.v = savedsettings.musicVolume
			settings.canContinue = settings.savegameSlots[savedsettings.lastSavegameSlot]
			assets:stopMusic("victory")
			assets:stopMusic("gameover")
			assets:stopMusic(level.data.tileset)
			assets:setMusicVolume("mainmenu", savedsettings.musicVolume)
			assets:playMusic("mainmenu")
			gameState = GameStates.MAIN_MENU
			subState = SubStates.IDLE
			return
		end
		
		if subState == SubStates.INVENTORY then
			if self.doShowInventory then
				self:clickOnInventory(x, y)
				return
			end
		end
		
		if subState == SubStates.VENDOR then
			self:clickOnVendor(x, y)
			return
		end		
		
		if subState == SubStates.SELECT_SPELL then
			self:clickOnSpellList(x, y)
			return
		end
		
		if subState == SubStates.POPUP or subState == SubStates.FOUND_LOOT then
			subState = SubStates.IDLE
		end
		
		if subState == SubStates.NPC then
		
			local npc = self.currentNPC
		
			if npc and npc.properties.state == 2 and npc.properties.gold > 0 or npc.properties.loot ~= "" then
				if npc.properties.delayedLoot and npc.properties.delayedLoot == true then
					self:showFoundLoot(npc.properties.gold, explode(npc.properties.loot, ":"), 0)
					party:addGold(npc.properties.gold)
					party:addItems(npc.properties.loot)
					npc.properties.gold = 0
					npc.properties.loot = ""
					globalvariables:add(npc.properties.id, "gold", npc.properties.gold)
					globalvariables:add(npc.properties.id, "loot", npc.properties.loot)
				else
				subState = SubStates.IDLE
				end
			else
				subState = SubStates.IDLE
			end			

			return

		end
		
		if subState == SubStates.VENDOR_ANTSACS then
			subState = SubStates.IDLE
			if party.antsacs > 0 then
				party.gold = party.gold + party.antsacs * settings.prices.antsacs
				party.antsacs = 0
			end
		end
		
		if subState == SubStates.AUTOMAPPER then
			if intersect(x, y, 541, 321, 34, 34) then
				self:showAutomapper(false)
				return
			end
			
			if self.buttons["close-map"]:isOver(x, y) then
				self.buttons["close-map"].trigger()
				return
			end
		end
		
		if subState == SubStates.TAVERN then
			
			if self.buttons["close-tavern"]:isOver(x, y) then
				self.buttons["close-tavern"].trigger()
				return
			end
			
			for i = 1, #self.loadslots do
				if settings.savegameSlots[i] then
					if intersect(x, y, self.loadslots[i].x, self.loadslots[i].y, self.loadslots[i].w, self.loadslots[i].h) then
						if party:loadGameFromSlot(i) then
						end
						renderer.showTavern = false
						return
					end
				end
			end
			
			for i = 1, #self.saveslots do
				if intersect(x, y, self.saveslots[i].x, self.saveslots[i].y, self.saveslots[i].w, self.saveslots[i].h) then
					if party:saveGameAtSlot(i) then
						fadeMusicVolume.v = savedsettings.musicVolume
						subState = SubStates.TWEENING
						Timer.script(function(wait)
							Timer.tween(1, fadeColor, {0,0,0}, 'in-out-quad')
							wait(1.25)
							renderer.showTavern = false
							party.stats.health = party.stats.health_max
							party.stats.mana = party.stats.mana_max
							Timer.tween(1, fadeColor, {1,1,1}, 'in-out-quad')
							wait(1.25)
							renderer:showPopup("Thank you for staying with us. Hope to see you again soon!")
						end)					
					end
					return
				end
			end	
			return
		end
		
		if subState == SubStates.SYSTEM_MENU then
		
			if intersect(x, y, 587, 321, 34, 34) then
				self:showSystemMenu(false)
				return
			end	
			
			for i = 1, #self.systemmenuitems do
				if intersect(x, y, 247, self.systemmenuOffsetY + self.systemmenuitemsOffsetY + ((i-1)*25), 150, 20) then
					self.systemmenuitems[i].trigger()
					return
				end
			end	
			
			if intersect(x, y, 300, self.systemmenuOffsetY + 53, 88, 15) then
				local bw = (x-300)/88
				if bw > 0.99 then bw = 1.0 end
				if bw < 0.01 then bw = 0.0 end
				savedsettings.musicVolume = bw
				fadeMusicVolume.y = bw
				assets:setMusicVolume(level.data.tileset, bw)
				assets:playSound("click-1")
				return
			end
			
			if intersect(x, y, 300, self.systemmenuOffsetY + 73, 88, 15) then
				local bw = (x-300)/88
				if bw > 0.99 then bw = 1.0 end
				if bw < 0.01 then bw = 0.0 end
				savedsettings.sfxVolume = bw
				assets:playSound("click-1")
				return
			end
			
			return
		end
		
		if gameState == GameStates.MAIN_MENU and subState == SubStates.IDLE then
		
			local adjustY = settings.canContinue and -15 or 0
			local index = 0
			
			for i = 1, #self.menuitems do
			
				if not settings.canContinue and i == 2 then
					-- skip this menuitem
				else
					if intersect(x, y, self.menuitemsOffsetX, self.menuitemsOffsetY + adjustY + (index*30), 100, 20) then
						self.menuitems[i].trigger()
					end
					index = index + 1
				end
			
			end		
			return
				
		end
		
		if gameState == GameStates.CREDITS or gameState == GameStates.ABOUT then
			gameState = GameStates.MAIN_MENU
			return
		end

		if gameState == GameStates.SETTINGS then
			gameState = GameStates.MAIN_MENU
			return
		end
		
	end
	
end

function Renderer:handleInput(key)

	if inventoryDragSource.item ~= nil then
		return
	end

	if subState == SubStates.INVENTORY then
	
		if key == 'i' or key == 'escape' then
			self:showInventory(false)
			return
		end
			
	end
	
	if subState == SubStates.POPUP or subState == SubStates.VENDOR_ANTSACS or subState == SubStates.VENDOR or self.showTavern then
		if key == 'escape' then
			subState = SubStates.IDLE
			return
		end
	end	
	
	if subState == SubStates.POPUP then
	
		if key == 'escape' then
			subState = SubStates.IDLE
			return
		end
			
	end		
	
	if subState == SubStates.AUTOMAPPER then
	
		if key == 'm' or key == 'escape'  then
			self:showAutomapper(false)
			return
		end

	end	
	
	if subState == SubStates.SYSTEM_MENU then
	
		if key == 'escape' then
			self:showSystemMenu(false)
			return
		end

	end		
	
end

function Renderer:flipGround()

	self.backgroundIndex = self.backgroundIndex + 1
	if self.backgroundIndex > 2 then
		self.backgroundIndex = 1
	end
	
end

function Renderer:flipSky()

	self.skyIndex = self.skyIndex + 1
	if self.skyIndex > 2 then
		self.skyIndex = 1
	end
	
end

function Renderer:getPlayerDirectionVectorOffsets(x, z)

    if party.direction == 0 then
        return { x = party.x + x, y = party.y + z };
	elseif party.direction == 1 then
		return { x = party.x - z, y = party.y + x };
	elseif party.direction == 2 then
		return { x = party.x - x, y = party.y - z };
	elseif party.direction == 3 then
		return { x = party.x + z, y = party.y - x };
	end
	

end

function Renderer:getObjectDirectionID(prefix, direction)

	local result = nil
	
	if direction == -1 then
		return prefix
	end
	
	
	if direction == 0 then
		if party.direction == 2 then
			result = prefix.."-1"
		end
		if party.direction == 0 then
			result = prefix.."-2"
		end
		if party.direction == 1 then
			result = prefix.."-4"
		end			
		if party.direction == 3 then
			result = prefix.."-3"
		end	
	elseif direction == 1 then
		if party.direction == 2 then
			result = prefix.."-4"
		end
		if party.direction == 0 then
			result = prefix.."-3"
		end
		if party.direction == 1 then
			result = prefix.."-2"
		end			
		if party.direction == 3 then
			result = prefix.."-1"
		end					
	elseif direction == 2 then
		if party.direction == 2 then
			result = prefix.."-2"
		end
		if party.direction == 0 then
			result = prefix.."-1"
		end
		if party.direction == 1 then
			result = prefix.."-3"
		end			
		if party.direction == 3 then
			result = prefix.."-4"
		end	
	elseif direction == 3 then
		if party.direction == 2 then
			result = prefix.."-3"
		end
		if party.direction == 0 then
			result = prefix.."-4"
		end
		if party.direction == 1 then
			result = prefix.."-1"
		end			
		if party.direction == 3 then
			result = prefix.."-2"
		end	
	end
		
	return result
		
end



function Renderer:getTile(atlasId, layerId, tileType, x, z)

	if not atlases.jsondata[atlasId].layer[layerId] then
		return nil
	end

	local layer = atlases.jsondata[atlasId].layer[layerId]
	
	if not layer then return false end
	
	for i = 1, #layer.tiles do
		local tile = layer.tiles[i]
		if tile.type == tileType and tile.tile.x == x and tile.tile.y == z then
			return tile
		end
	end

	return nil
	
end

function Renderer:drawText(x, y, text, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+1, y+1, 640, align)
	love.graphics.setColor(color)
	love.graphics.printf(text, x, y, 640, align)
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawText2(x, y, text, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x, y, 640, align)
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawCenteredText(x, y, text, color)


	local strlen = assets.fonts["main"]:getWidth(text)

	local offsetx = math.floor(strlen/2)

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, (x+1)-offsetx, y+1, strlen*2, "left")
	love.graphics.setColor(color)
	love.graphics.printf(text, x-offsetx, y, strlen*2, "left")
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawWrappedText(x, y, text, wrapAt, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x+1, y+1, wrapAt, align)
	love.graphics.setColor(color)
	love.graphics.printf(text, x, y, wrapAt, align)
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawWrappedText2(x, y, text, wrapAt, color, align)

	align = align and align or "left"

	love.graphics.setColor(0,0,0,1)
	love.graphics.printf(text, x, y, wrapAt, align)
	love.graphics.setColor(1,1,1,1)
	
end

function Renderer:drawPointer()

	local x, y = love.mouse.getPosition()

	if love.mouse.isGrabbed() then

		if x > screen.width then
			love.mouse.setPosition(screen.width,love.mouse.getY())
		end
		
		if y > screen.height then
			love.mouse.setPosition(love.mouse.getX(), screen.height)
		end	
	
	end
	
	local x, y = love.mouse.getPosition()
	
	if inventoryDragSource.item and assets.images[inventoryDragSource.item.id] then
		love.graphics.draw(assets.images[inventoryDragSource.item.id], x-16, y-16)
	else
		love.graphics.draw(assets.images["pointer"], x, y)
	end
	
end

function Renderer:drawGameOver()

	love.graphics.draw(assets.images["gameover"], 0,0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	local text = "Death must be so beautiful.\n\nTo lie in the soft brown earth, with the grasses waving above one's head, and listen to silence.\n\nTo have no yesterday, and no to-morrow.\n\nTo forget time, to forget life, to be at peace."

	self:drawWrappedText(50, 50+10, text, 240, color.white, "left")

	self:drawText(50,255+10, "- Oscar Wilde", {1,1,1,1}, "left")

end

function Renderer:drawVictory()

	love.graphics.draw(assets.images["victory"], 0,0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	local text = "Victory is sweetest when you've known defeat.."

	self:drawWrappedText2(350, 50+10, text, 240, color.white, "left")

	self:drawText2(350,100, "- Malcolm Forbes", {1,1,1,1}, "left")
	
	text = "Once again the sun rise over the kingdom. The people have been liberated from the terrifying scourge which plagued them for so long."
	self:drawWrappedText2(350, 150, text, 240, color.white, "left")

	text = "Thank you for your service!"
	self:drawWrappedText2(350, 280, text, 240, color.white, "left")

end

function Renderer:drawFoundLoot()

	love.graphics.draw(assets.images["popup-background-small"], 194, 100)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	self:drawText(0,110, "You find", {1,1,1,1}, "center")

	local loot = {}
	
	if self.foundloot.gold > 0 then
		table.insert(loot, "coins")
	end

	if self.foundloot.antsacs and self.foundloot.antsacs > 0 then
		table.insert(loot, "antsac")
	end

	if self.foundloot.items and #self.foundloot.items > 0 then
		for i = 1, #self.foundloot.items do
			if self.foundloot.items[i] ~= "" then
				table.insert(loot, self.foundloot.items[i])
			end
		end
	end

	local offsetx = math.floor(320 - (#loot * 40)/2) + 4

	for i = 1, #loot do
		love.graphics.draw(assets.images[loot[i]], offsetx + (i-1)*40, 136)	
	end

	if self.foundloot.gold > 0 then
		self:drawDigits(self.foundloot.gold, offsetx+23, 136+22)
	end

end

function Renderer:drawPopup()

	if #self.popupText < 120 then
		self:drawSmallPopup(self.popupText)
	else
		self:drawLargePopup(self.popupText)
	end

end

function Renderer:drawSmallPopup(text)

	love.graphics.draw(assets.images["popup-background-small"], 194, 100)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 232)

	local offsety = 143

	if #wrappedtext > 1 then
		offsety = offsety - math.floor((#wrappedtext*16)/2)
	else
		offsety = offsety - 8
	end

	for i = 1, #wrappedtext do
		self:drawText(0,offsety + (i-1)*16, wrappedtext[i], {1,1,1,1}, "center")
	end

	love.graphics.setFont(assets.fonts["main"]);

end
function Renderer:drawLargePopup(text)

	love.graphics.draw(assets.images["popup-background-large"], 160, 50)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 300)

	local offsety = 150

	if #wrappedtext > 1 then
		offsety = offsety - math.floor((#wrappedtext*16)/2)
	else
		offsety = offsety - 8
	end

	for i = 1, #wrappedtext do
		self:drawText(0,offsety + (i-1)*16, wrappedtext[i], {1,1,1,1}, "center")
	end

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawCredits()

	love.graphics.draw(assets.images["credits-background"], 0, 0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	self:drawText(152,24, "Code & Art*", {1,1,1,1})
	self:drawText(414,24, "Music", {1,1,1,1})

	self:drawText(98,174, "Dan Thoresen (zooperdan)", {1,1,1,1})
	self:drawText(355,174, "Travis Sullivan (travsul)", {1,1,1,1})

	self:drawText(140,224, "zooperdan", {1,1,1,1})
	self:drawText(140,256, "zooperdan.itch.io", {1,1,1,1})
	self:drawText(140,288, "dungeoncrawlers.org", {1,1,1,1})

	self:drawText(378,224, "SullyMusic", {1,1,1,1})
	self:drawText(378,256, "travisoraziosullivan", {1,1,1,1})
	self:drawText(378,288, "travissullivan.com/composer/", {1,1,1,1})

	self:drawText(0,340, "* Refer to attribution.txt for more information", {1,1,1,.25}, "center")

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawAbout()

	--self:drawText(0, 40, "- ABOUT -", {1,1,1,1}, "center")

	local text = "I made this game to demonstrate the capabilities of an AtlasMaker tool I created. It is a Unity package and runs inside the editor. With it you can automate then render of 3D-models into 2D sprites and pack them together on one or more image atlases. These atlases can in turn be used in a game to render dungeons using the old methods of back to front drawing. All the in-game graphics in this game has been made using AtlasMaker."

	local offsety = 10

	self:drawWrappedText(30, offsety, text, screen.width-60, {1,1,1,1}, "center")

	self:drawImage(0,offsety+75, "about", true)

	self:drawText(93, offsety + 85, "Image atlas", {1,1,1,1})

	self:drawWrappedText(30, 275, "If you are interested in using AtlasMaker in your own projects you will find it at https://github.com/zooperdan/AtlasMaker-for-2D-Dungeon-Crawlers", screen.width-60, {1,1,1,1}, "center")
	self:drawWrappedText(30, 315, "If you run into any problems or have some questions or suggestions then find me on the dungeoncrawler.org Discord server or Twitter (@zooperdan).", screen.width-60, {1,1,1,1}, "center")

end

function Renderer:drawSettings()

	self:drawText(0, 40, "- SETTINGS -", {1,1,1,1}, "center")

end

function Renderer:drawSpellList()

	local mx, my = love.mouse.getPosition()

	local offsetx = 328
	local offsety = 284

	self.currentHoverSpell = nil

	for i = 1, #party.spells do
	
		local spell = spelltemplates:get(party.spells[i])
		local y = offsety - (i-1)*34
		self:drawImage(offsetx, y, spell.id, false) 
		if intersect(mx, my, offsetx, y, 32, 32) then
			self.currentHoverSpell = spell
			love.graphics.draw(assets.images["inventory-slot-highlight"], offsetx-1, y-1)
		end
	
	end

end

function Renderer:clickOnSpellList(x, y)

	if y > 316 then
		return
	end	

	local offsetx = 328
	local offsety = 284

	for i = 1, #party.spells do
		local yy = offsety - (i-1)*34
		if intersect(x, y, offsetx, yy, 32, 32) then
			if party:castSpell(party.spells[i]) then
				subState = SubStates.IDLE
				local spell = spelltemplates:get(party.spells[i])
				self.currentSpell = spell
				self.showSpellEffect = true
				Timer.script(function(wait)
					wait(0.1)
					renderer.showSpellEffect = false
				end)				
			end
			self.currentHoverSpell = nil
			return true
		end
	end

	self.currentHoverSpell = nil
	subState = SubStates.IDLE

	return false

end

function Renderer:drawNPC()

	local text
	local offsetx
	local offsety
	local textx
	local imageid
	local portraitid = self.currentNPC.properties.imageid

	if self.currentNPC.properties.state == 1 then
		text = self.currentNPC.properties.text
	elseif self.currentNPC.properties.state == 2 then
		text = self.currentNPC.properties.questdelivertext
	elseif self.currentNPC.properties.state == 3 then
		text = self.currentNPC.properties.questdonetext
	end

	local width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227)
	
	if #wrappedtext > 3 then
		width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227+135)
		offsety = 65
		offsetx = 85
		imageid = "npc-background-large"
		textx = 169
	else
		offsety = 100
		offsetx = 160
		imageid = "npc-background-small"
		textx = 244
	end

	love.graphics.draw(assets.images[imageid], offsetx, offsety)	
	love.graphics.draw(assets.images[portraitid], offsetx+9, offsety+9)	
	love.graphics.setFont(assets.fonts["mainmenu"]);
	self:drawText(textx, offsety + 8, self.currentNPC.properties.name, {1,1,1,1}, "left")

	for i = 1, #wrappedtext do
		self:drawText(textx,offsety + 37 + (i-1)*14, wrappedtext[i], {1,1,1,1}, "left")
	end

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawTavern() 

	local mx, my = love.mouse.getPosition()
	
	local name = "The Randy Boar Inn"
	local text = "Welcome adventurer. I am Biok Kai, the innkeeper of this fine establishment.\n\nDo you want to rest your weary bones in one of our comfortable rooms?"
	local offsetx = 85
	local offsety = 65
	local textx = 169
	local portraitid = "npc-monk"

	local width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227+135)

	self.buttons["close-tavern"]:isOver(mx, my)

	love.graphics.draw(assets.images["npc-background-large"], offsetx, offsety)	
	love.graphics.draw(assets.images[portraitid], offsetx+9, offsety+9)	
	love.graphics.setFont(assets.fonts["mainmenu"]);
	self:drawText(textx,offsety + 8, name, {1,1,1,1}, "left")

	for i = 1, #wrappedtext do
		self:drawText(textx,offsety + 37 + (i-1)*14, wrappedtext[i], {1,1,1,1}, "left")
	end

	self:drawText(textx, self.loadslots[1].y+2, "LOAD", {1,1,1,1})

	for i = 1, #self.loadslots do
		if settings.savegameSlots[i] then
			if intersect(mx, my, self.loadslots[i].x, self.loadslots[i].y, self.loadslots[i].w, self.loadslots[i].h) then
				self:box(self.loadslots[i].x, self.loadslots[i].y, self.loadslots[i].w, self.loadslots[i].h, {1,1,1,1}, false)
			else
				self:box(self.loadslots[i].x, self.loadslots[i].y, self.loadslots[i].w, self.loadslots[i].h, settings.frameColor, false)
			end
			self:drawText(self.loadslots[i].x+4, self.loadslots[i].y+2, self.loadslots[i].caption, {1,1,1,1})
		else
			self:box(self.loadslots[i].x, self.loadslots[i].y, self.loadslots[i].w, self.loadslots[i].h, settings.frameColor, false)
			self:drawText(self.loadslots[i].x+4, self.loadslots[i].y+2, self.loadslots[i].caption, settings.frameColor)
		end
	end

	self:drawText(textx, self.saveslots[1].y+2, "SAVE", {1,1,1,1})

	for i = 1, #self.saveslots do
		if intersect(mx, my, self.saveslots[i].x, self.saveslots[i].y, self.saveslots[i].w, self.saveslots[i].h) then
			self:box(self.saveslots[i].x, self.saveslots[i].y, self.saveslots[i].w, self.saveslots[i].h, {1,1,1,1}, false)
		else
			self:box(self.saveslots[i].x, self.saveslots[i].y, self.saveslots[i].w, self.saveslots[i].h, settings.frameColor, false)
		end
		self:drawText(self.saveslots[i].x+4, self.saveslots[i].y+2, self.saveslots[i].caption, {1,1,1,1})
	end

	love.graphics.draw(self.buttons["close-tavern"]:getImage(),  self.buttons["close-tavern"].x, self.buttons["close-tavern"].y)

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawVendor() 

	local mx, my = love.mouse.getPosition()
	
	local text = self.currentVendor.text
	local name = self.currentVendor.name
	local offsetx = 168
	local offsety = 65
	local portraitid = self.currentVendor.imageid

	local width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227+135)

	self.buttons["close-vendor"]:isOver(mx, my)

	love.graphics.draw(assets.images["npc-background-large"], 85, offsety)	
	love.graphics.draw(assets.images[portraitid], 85+9, offsety+9)	
	love.graphics.setFont(assets.fonts["mainmenu"]);
	self:drawText(169,offsety + 8, name, {1,1,1,1}, "left")

	for i = 1, #wrappedtext do
		self:drawText(169,offsety + 37 + (i-1)*14, wrappedtext[i], {1,1,1,1}, "left")
	end

	-- draw items in stock
	
	self.currentHoverItem = nil
	
	for i = 1, #self.currentVendor.stock do
		local item
		if self.currentVendor.id == "alchemist" then
			item = itemtemplates:get(self.currentVendor.stock[i])
		elseif self.currentVendor.id == "magicshop" then
			item = spelltemplates:get(self.currentVendor.stock[i])
		end
		local x = offsetx + (i-1)*34
		local y = 188
		
		love.graphics.draw(assets.images[item.id], x, y)	
		if intersect(mx, my, x, y, 32, 32) then
			self.currentHoverItem = item
			love.graphics.draw(assets.images["inventory-slot-highlight"], x-1, y-1)
		end
		self:drawCenteredText(x+16, y+34, self.currentVendor.prices[i], {1,1,1,1})		
	end

	love.graphics.draw(self.buttons["close-vendor"]:getImage(),  self.buttons["close-vendor"].x, self.buttons["close-vendor"].y)

	love.graphics.draw(assets.images["coins"], 92, 237)
	self:drawDigits(party.gold, 92+23,237+22)
	love.graphics.setFont(assets.fonts["main"]);
	
end

function Renderer:clickOnVendor(x, y)

	if self.buttons["close-vendor"]:isOver(x, y) then
		self.buttons["close-vendor"].trigger()
		return
	end		

	local offsetx = 168

	for i = 1, #self.currentVendor.stock do
		local xx = offsetx + (i-1)*34
		local yy = 188
		if intersect(x, y, xx, yy, 32, 32) then
			if party.gold >= self.currentVendor.prices[i] then
				if self.currentVendor.stock[i] == "healing-potion" then
					party.healing_potions = party.healing_potions + 1
					party.gold = party.gold - self.currentVendor.prices[i]
					assets:playSound("buy")
				elseif self.currentVendor.stock[i] == "mana-potion" then
					party.mana_potions = party.mana_potions + 1
					party.gold = party.gold - self.currentVendor.prices[i]
					assets:playSound("buy")
				else
					if party:addSpell(self.currentVendor.stock[i]) then
						party.gold = party.gold - self.currentVendor.prices[i]
						assets:playSound("buy")
					else
						assets:playSound("cantafford")
					end
				end
				
			else
				assets:playSound("cantafford")
			end
		end
	end	

end

function Renderer:drawAntsacsVendor() 

	local text = ""
	local name = "Gurik Masiv"
	local offsetx
	local offsety
	local textx
	local imageid
	local portraitid = "npc-sorcerer-1"

	if party.antsacs == 0 then
		text = "Hey, listen! If you ever manage to kill one of those giant ants in the forest, could you please bring me their ant sac? It's vile I know, but it's a sought after ingredient among potion makers.\n\nI will give you some coins for the trouble."
	else
		local str = party.antsacs == 1 and "this ant sac!" or "these ant sacs!"
		text = "Excellent!\n\nThank you for bringing me " .. str .. "\n\nAs promised, here are some coins."
	end

	local width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227)
	
	if #wrappedtext > 3 then
		width, wrappedtext = assets.fonts["mainmenu"]:getWrap(text, 227+135)
		offsety = 65
		offsetx = 85
		imageid = "npc-background-large"
		textx = 169
	else
		offsety = 100
		offsetx = 160
		imageid = "npc-background-small"
		textx = 244
	end

	love.graphics.draw(assets.images[imageid], offsetx, offsety)	
	love.graphics.draw(assets.images[portraitid], offsetx+9, offsety+9)	
	love.graphics.setFont(assets.fonts["mainmenu"]);
	self:drawText(textx,offsety + 8, name, {1,1,1,1}, "left")

	for i = 1, #wrappedtext do
		self:drawText(textx,offsety + 37 + (i-1)*14, wrappedtext[i], {1,1,1,1}, "left")
	end

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawInventory()

	local mx, my = love.mouse.getPosition()

	love.graphics.setColor(1,1,1,1)

	love.graphics.draw(assets.images["inventory-ui"],  settings.inventoryX, settings.inventoryY)

	if not inventoryDragSource.item then
		self.buttons["close-inventory"]:isOver(mx, my)
	end
	
	love.graphics.draw(self.buttons["close-inventory"]:getImage(),  self.buttons["close-inventory"].x, self.buttons["close-inventory"].y)

	local slotsize = 33
	local hovercell = nil
	local showingItemStats = false

	self.currentHoverItem = nil

	-- trash icon

	local x = settings.inventoryX + 325
	local y = settings.inventoryY + 200
	
	if intersect(mx, my, x, y, slotsize, slotsize) then
		if inventoryDragSource.item then
			local item = itemtemplates:get(inventoryDragSource.item.id)
			if item.slot ~= "key" then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			end
		end
	end	

	-- equipment slots
	
	for i = 1, #party.equipmentslots do
	
		local x = settings.inventoryX + party.equipmentslots[i].x
		local y = settings.inventoryY + party.equipmentslots[i].y
		
		-- draw slot highlight
		
		if intersect(mx, my, x, y, slotsize, slotsize) then
			if inventoryDragSource.item then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			else
				if party.equipped[i].id ~= "" then
					love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
					self.currentHoverItem = itemtemplates:get(party.equipped[i].id)
				end
			end
			hovercell = {index = i}
		end
		
		-- draw slot highlight for matching slot type
		
		if inventoryDragSource.item then
		
			local item = itemtemplates:get(inventoryDragSource.item.id)
			
			if party.equipmentslots[i].type == item.slot then
				love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
			end
		
		end
		
		-- draw item icons
		
		if party.equipped[i].id ~= "" then
		
			local item = itemtemplates:get(party.equipped[i].id)

			if item and assets.images[item.id] then
				love.graphics.draw(assets.images[item.id], x+1, y+1)
			end
			
		end
		
	end	

	if hovercell and not inventoryDragSource.item and party.equipped[hovercell.index].id ~= "" then
		showingItemStats = true
		local item = itemtemplates:get(party.equipped[hovercell.index].id)
	end
	
	-- inventory slots

	hovercell = nil

	for row = 1, 5 do
		for col = 1, 8 do
		
			local x = settings.inventorySlotsStartX + (col-1) * slotsize
			local y = settings.inventorySlotsStartY + (row-1) * slotsize
			
			-- draw slot highlight
			
			if intersect(mx, my, x, y, slotsize, slotsize) then
				if inventoryDragSource.item then
					love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
				else
					if party.inventory[row][col] ~= "" then
						love.graphics.draw(assets.images["inventory-slot-highlight"], x, y)
						self.currentHoverItem = itemtemplates:get(party.inventory[row][col])
					end
				end
				hovercell = {row = row, col = col}
			end
			
			-- draw item icons
			
			if party.inventory[row][col] ~= "" then
			
				local item = itemtemplates:get(party.inventory[row][col])
	
				if item and assets.images[item.id] then
					love.graphics.draw(assets.images[item.id], x+1, y+1)
				end
				
			end
			
		end
	end
	
	if hovercell and not inventoryDragSource.item and party.inventory[hovercell.row][hovercell.col] ~= "" then
		showingItemStats = true
		local item = itemtemplates:get(party.inventory[hovercell.row][hovercell.col])
	end
	
end

function Renderer:clickOnInventory(mx, my)

	if not inventoryDragSource.item then
		if self.buttons["close-inventory"]:isOver(mx, my) then
			self.buttons["close-inventory"].trigger()
		end
	end

	local slotsize = 33

	-- inventory button in main ui
	
	if not inventoryDragSource.item and intersect(mx, my, 19, 321, 34, 34) then
		if not self:inventoryShowing() then
			self:showInventory(true)
			return
		else
			self:showInventory(false)
			return
		end
	end		

	-- trash icon

	local x = settings.inventoryX + 325
	local y = settings.inventoryY + 200
	
	if intersect(mx, my, x, y, slotsize, slotsize) then
		if inventoryDragSource.item then
			local item = itemtemplates:get(inventoryDragSource.item.id)
			if item.slot ~= "key" then
				inventoryDragSource = {}
				assets:playSound("trash")
			end
		end
	end
	
	-- equipment slots
	
	for i = 1, #party.equipmentslots do
	
		local x = settings.inventoryX + party.equipmentslots[i].x
		local y = settings.inventoryY + party.equipmentslots[i].y
		
		if intersect(mx, my, x, y, slotsize, slotsize) then
	
			if inventoryDragSource.item then
	
				if party.equipmentslots[i].type == inventoryDragSource.item.slot then
	
					if party.equipped[i].id == "" then
		
						party.equipped[i].id = inventoryDragSource.item.id
			
						inventoryDragSource = {}

						assets:playSound("click-2")

					else
					
						local item = itemtemplates:get(party.equipped[i].id)
						
						party.equipped[i].id = inventoryDragSource.item.id

						inventoryDragSource = {
							source = "equipment",
							item = item,
							src_row = row,
							src_col = col,
						}

						assets:playSound("click-2")

					end

					party:squareIsSeen(party.x, party.y)

				end
				
			else
			
				if party.equipped[i].id ~= "" then

					local item = itemtemplates:get(party.equipped[i].id)
					
					inventoryDragSource = {
						source = "equipment",
						item = item,
						src_row = row,
						src_col = col,
					}
					
					party.equipped[i].id = ""
					assets:playSound("click-2")
				else 
					inventoryDragSource = {}
					assets:playSound("click-2")
				end				
			
			end
	
		end
		
	end

	-- inventory slots

	if intersect(mx, my, settings.inventorySlotsStartX, settings.inventorySlotsStartY, 295, 184) then

		local col = math.floor((mx - settings.inventorySlotsStartX) / slotsize)+1
		local row = math.floor((my - settings.inventorySlotsStartY) / slotsize)+1
		
		col = math.clamp(col, 1, 8)
		row = math.clamp(row, 1, 5)

		if inventoryDragSource.item then
		
			if party.inventory[row][col] == "" then

				party.inventory[row][col] = inventoryDragSource.item.id
			
				inventoryDragSource = {}
				assets:playSound("click-2")

			else

				local item = itemtemplates:get(party.inventory[row][col])
				
				party.inventory[row][col] = inventoryDragSource.item.id

				inventoryDragSource = {
					source = "inventory",
					item = item,
					src_row = row,
					src_col = col,
				}				
				assets:playSound("click-2")

			end
		
		else

			if party.inventory[row][col] ~= "" then

				local item = itemtemplates:get(party.inventory[row][col])
				
				inventoryDragSource = {
					source = "inventory",
					item = item,
					src_row = row,
					src_col = col,
				}
				
				party.inventory[row][col] = ""
				assets:playSound("click-2")
				
			else 
				inventoryDragSource = {}
			end
			
		end
	
	end
	
	party:updateStats()
	
end

function Renderer:box(x, y, w, h, color, filled)
	
	r, g, b, a = love.graphics.getColor()
	 
	local oldColor = {r, g, b, a} 

	local f = filled and filled == true and "fill" or "line"

	love.graphics.setColor(color)
	love.graphics.rectangle(f, x, y, w, h)

	love.graphics.setColor(oldColor)

end

function Renderer:drawSystemMenu()

	local mx, my = love.mouse.getPosition()

	love.graphics.setFont(assets.fonts["mainmenu"]);

	local offsety =  self.systemmenuOffsetY

	self:box(230,offsety,182,185,{0,0,0,1},true)
	self:box(230,offsety,182,185,settings.frameColor,false)

	local index = 0
	
	for i = 1, #self.systemmenuitems do
	
		local x = 247
		local y = self.systemmenuitemsOffsetY + offsety + (index*25)
	
		if intersect(mx, my, x, y, 145, 20) then
			self:drawText(0, y, self.systemmenuitems[i].caption, {1,1,1,1}, "center")
		else
			self:drawText(0, y, self.systemmenuitems[i].caption, {1.0,.85,.75,1}, "center")
		end
		index = index + 1
	
	end	

	self:drawText(0, offsety + 15, "System menu", {1,1,1,1}, "center")

	local bw = math.floor(88*savedsettings.musicVolume)

	self:box(300,offsety + 53,bw, 15, settings.sliderColor, true)
	self:drawText(251, self.systemmenuOffsetY + 53, "Music", {1,1,1,1}, "left")
	self:box(300,offsety + 53,88, 15,settings.frameColor,false)
	self:box(300+1,offsety + 53 +1,86, 13, color.black,false)

	local bw = math.floor(88*savedsettings.sfxVolume)

	self:box(300,offsety + 73,bw, 15, settings.sliderColor,true)
	self:drawText(251, self.systemmenuOffsetY + 73, "SFX", {1,1,1,1}, "left")
	self:box(300,offsety + 73,88, 15,settings.frameColor,false)
	self:box(300+1,offsety + 73 +1,86, 13, color.black,false)

	love.graphics.setFont(assets.fonts["main"]);

end

function Renderer:drawMainmenu()

	local mx, my = love.mouse.getPosition()

	love.graphics.draw(assets.images["mainmenu-background"], 0, 0)	

	love.graphics.setFont(assets.fonts["mainmenu"]);

	local index = 0
	local adjustY = settings.canContinue and -15 or 0
	
	for i = 1, #self.menuitems do
	
		if not settings.canContinue and i == 2 then
			-- skip this menuitem
		else

			local x = self.menuitemsOffsetX
			local y = self.menuitemsOffsetY + adjustY + (index*30)
		
			if not self.doShowSystemMenu and intersect(mx, my, x, y, 100, 20) then
				self:drawText(x, y, self.menuitems[i].caption, {1,1,1,1})
			else
				self:drawText(x, y, self.menuitems[i].caption, {1.0,.85,.75,1})
			end
			index = index + 1
		end
	
	end

	self:drawText(-10,340, "v" .. settings.version, {1,1,1,.15}, "right")

	love.graphics.setFont(assets.fonts["main"]);

	love.graphics.setColor(1,1,1,1)

end

function Renderer:showPlayerStats()
	
	love.graphics.draw(assets.images["coins"], settings.inventoryX+8, settings.inventoryY+162)
	love.graphics.draw(assets.images["antsac"], settings.inventoryX+86, settings.inventoryY+162)

	self:drawDigits(party.gold, 150, 234)
	self:drawDigits(party.antsacs, 228, 234)

	self:drawText(251, 228, "HEALTH", {1,1,1,1})
	self:drawText(251, 228+14, "MANA", {1,1,1,1})

	self:drawText(251, 228+28, "ATK", {1,1,1,1})
	self:drawText(251, 228+42, "DEF", {1,1,1,1})
	
	self:drawText(298, 228, ":", {1,1,1,1})
	self:drawText(298, 228+14, ":", {1,1,1,1})
	self:drawText(298, 228+28, ":", {1,1,1,1})
	self:drawText(298, 228+42, ":", {1,1,1,1})

	local r = 248/255
	local g = 197/255
	local b = 58/255

	self:drawText(304, 228, party.stats.health .. " (" .. party.stats.health_max .. ")", {r,g,b,1})
	self:drawText(304, 228+14, party.stats.mana .. " (" .. party.stats.mana_max .. ")", {r,g,b,1})
	self:drawText(304, 228+28, party.stats.attack, {r,g,b,1})
	self:drawText(304, 228+42, party.stats.defence, {r,g,b,1})
	
end

function Renderer:showItemHoverStats(item)
		
	if item and assets.images[item.id] then

		local mx, my = love.mouse.getPosition()

		local str = ""
		for key,value in pairs(item.modifiers) do
			local mod = item.modifiers[key]
			if key == "health" or key == "mana" then
				str = str .. key:upper() .. ": " .. value .. "%  "
			elseif key == "maxhp" then
				str = str .. "HEALTH" .. ": " .. value .. "  "
			elseif key == "maxmp" then
				str = str .. "MANA" .. ": " .. value .. "  "
			else
				str = str .. key:upper() .. ": " .. value .. "   "
			end
		end

		local boxheight = str ~= "" and 40 or 25

		local statslen = assets.fonts["main"]:getWidth(str.trim(str))+10
		local namelen = assets.fonts["main"]:getWidth(item.name.trim(item.name))+10

		local l = namelen

		if namelen < statslen then
			l = statslen
		end

		if mx + l + 15 > screen.width then
			mx = screen.width - (l + 15)
		end
		
		love.graphics.setColor(0,0,0,0.75)
		love.graphics.rectangle("fill",mx+10,my-40, l, boxheight)
		love.graphics.setColor(1,1,1,.5)
		love.graphics.rectangle("line",mx+10,my-40, l, boxheight)
		love.graphics.setColor(1,1,1,1)
		
		self:drawText(mx+15, my-35, item.name, {255/255,240/255,137/255,1})
		
		if str ~= "" then
			self:drawText(mx+15, my-20, str, {1,1,1,1})
		end
		
	end
	
end

function Renderer:showSpellHoverStats(item)
		
	if item and assets.images[item.id] then

		local mx, my = love.mouse.getPosition()

		local str = ""
		for key,value in pairs(item.modifiers) do
			local mod = item.modifiers[key]
			if key == "health" or key == "mana" then
				str = str .. key:upper() .. ": " .. value .. "%  "
			else
				str = str .. key:upper() .. ": " .. value .. "   "
			end
		end

		str = str .. "MANA COST: " .. item.manacost

		local boxheight = str ~= "" and 40 or 25

		local statslen = assets.fonts["main"]:getWidth(str.trim(str))+10
		local namelen = assets.fonts["main"]:getWidth(item.name.trim(item.name))+10

		local l = namelen

		if namelen < statslen then
			l = statslen
		end

		if mx + l + 15 > screen.width then
			mx = screen.width - (l + 15)
		end
		
		love.graphics.setColor(0,0,0,0.75)
		love.graphics.rectangle("fill",mx+10,my-40, l, boxheight)
		love.graphics.setColor(1,1,1,.5)
		love.graphics.rectangle("line",mx+10,my-40, l, boxheight)
		love.graphics.setColor(1,1,1,1)
		
		self:drawText(mx+15, my-35, item.name, {255/255,240/255,137/255,1})
		
		if str ~= "" then
			self:drawText(mx+15, my-20, str, {1,1,1,1})
		end
		
	end
	
end

function Renderer:drawAutomapper()

	local mx, my = love.mouse.getPosition()

	local cellsize = 6
	local offsetx = 162+2
	local offsety = 59+2

	love.graphics.draw(assets.images["automapper-background"], 162, 59)
	
	self.buttons["close-map"]:isOver(mx, my)
	
	love.graphics.draw(self.buttons["close-map"]:getImage(),  self.buttons["close-map"].x, self.buttons["close-map"].y)
	
	for y = 1, level.data.mapSize do
		for x = 1, level.data.mapSize do

			local dx = offsetx + ((x-1) * cellsize)
			local dy = offsety + ((y-1) * cellsize)

			if party:seenSquare(x, y) then
			
				if level.data.walls[x] and level.data.walls[x][y] then
					love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[1], dx, dy)
				end

				if level.data.boundarywalls[x] and level.data.boundarywalls[x][y] then
					love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[0], dx, dy)
				end
			else
				love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[17], dx, dy)
			end
		
		end
	end

	-- doors

	for key,value in pairs(level.data.doors) do
		local door = level.data.doors[key]
		if party:seenSquare(door.x, door.y) then
			local dx = offsetx + ((door.x-1) * cellsize)
			local dy = offsety + ((door.y-1) * cellsize)
			if door.properties.type == 1 then
				love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[2 + door.properties.direction], dx, dy)
				if door.properties.vendor ~= "" then
					love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[18], dx, dy)
				end
			else
				love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[6], dx, dy)
			end
		end
	end
	
	-- levelexits

	for key,value in pairs(level.data.levelexits) do
		local levelexit = level.data.levelexits[key]
		if party:seenSquare(levelexit.x, levelexit.y) then
			local dx = offsetx + ((levelexit.x-1) * cellsize)
			local dy = offsety + ((levelexit.y-1) * cellsize)
			love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[6], dx, dy)
		end
	end	
	
	-- bossgates
	
	for key,value in pairs(level.data.bossgates) do
		local bossgate = level.data.bossgates[key]
		if party:seenSquare(bossgate.x, bossgate.y) then
			local dx = offsetx + ((bossgate.x-1) * cellsize)
			local dy = offsety + ((bossgate.y-1) * cellsize)
			love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[19], dx, dy)
		end
	end	
	
	-- npcs

	for key,value in pairs(level.data.npcs) do
		local npc = level.data.npcs[key]
		if party:seenSquare(npc.x, npc.y) then
			local dx = offsetx + ((npc.x-1) * cellsize)
			local dy = offsety + ((npc.y-1) * cellsize)
			love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[7], dx, dy)
		end
	end

	-- wells

	for key,value in pairs(level.data.wells) do
		local well = level.data.wells[key]
		if party:seenSquare(well.x, well.y) then
			local dx = offsetx + ((well.x-1) * cellsize)
			local dy = offsety + ((well.y-1) * cellsize)
			love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[9], dx, dy)
		end
	end
	
	-- props

	for key,value in pairs(level.data.staticprops) do
		local prop = level.data.staticprops[key]
		if party:seenSquare(prop.x, prop.y) then
			if prop.properties.visible == 1 then
				local dx = offsetx + ((prop.x-1) * cellsize)
				local dy = offsety + ((prop.y-1) * cellsize)
				love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[10], dx, dy)
			end
		end
	end
	
	-- portals

	for key,value in pairs(level.data.portals) do
		local portal = level.data.portals[key]
		if party:seenSquare(portal.x, portal.y) then
			if portal.properties.state == 1 then
				local dx = offsetx + ((portal.x-1) * cellsize)
				local dy = offsety + ((portal.y-1) * cellsize)
				love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[12], dx, dy)
			end
		end
	end
	
	-- chest

	for key,value in pairs(level.data.chests) do
		local chest = level.data.chests[key]
		if party:seenSquare(chest.x, chest.y) then
			local dx = offsetx + ((chest.x-1) * cellsize)
			local dy = offsety + ((chest.y-1) * cellsize)
			love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[11], dx, dy)
		end	
	end	
	
	-- player
	
	local dx = offsetx + ((party.x-1) * cellsize)
	local dy = offsety + ((party.y-1) * cellsize)
	love.graphics.draw(assets.images["automapper-sprites"], assets.automapper_quads[13 + party.direction], dx, dy)
	

end

function Renderer:drawUI()

	love.graphics.setColor(1,1,1,1)

	-- main ui

	love.graphics.draw(assets.images["main-ui"], 0,0)
	
	-- compass

	if party:hasCompass() then
		love.graphics.draw(assets.images["compass-letters"], assets.compass_quads[party.direction], 286, 0)
	end
	
	-- map

	if party:hasMap() then
		love.graphics.draw(assets.images["button-map"], 541, 322)
	end
	
	-- left hand

	local leftHand = party:getLeftHand()
	
	if leftHand then
		love.graphics.draw(assets.images[leftHand.id], 282,321)
	end
	
	if party:hasCooldown(1) then
		love.graphics.draw(assets.images["cooldown-overlay"], 283,322)
	end
	
	-- right hand
	
	local rightHand = party:getrightHand()

	if rightHand then
		love.graphics.draw(assets.images[rightHand.id], 329,321)
	end

	if party:hasCooldown(2) then
		love.graphics.draw(assets.images["cooldown-overlay"], 330,322)
	end

	-- healing potions

	if party.healing_potions > 0 then
		love.graphics.draw(assets.images["healing-potion"], 239,325)
		local x,y = 262, 347
		if party.healing_potions < 10 then
			love.graphics.draw(assets.images["digits"], assets.digit_quads[party.healing_potions], x, y)
		else
			self:drawDigits(party.healing_potions, 262, 347)
		end
		
		if party:hasCooldown(3) then
			love.graphics.draw(assets.images["cooldown-overlay"], 240,326)
		end
		
	end

	-- mana potions

	if party.mana_potions > 0 then
		love.graphics.draw(assets.images["mana-potion"], 372,325)
		local x,y = 395, 347
		if party.mana_potions < 10 then
			love.graphics.draw(assets.images["digits"], assets.digit_quads[party.mana_potions], x, y)
		else
			local str = tostring(party.mana_potions)
			local x,y = 395 - (#str*6), 347
			for i = 1, #str do
				local c = tonumber(string.sub(str,i,i))
				love.graphics.draw(assets.images["digits"], assets.digit_quads[c], x + (i*6), y)
			end
		end
		
		if party:hasCooldown(4) then
			love.graphics.draw(assets.images["cooldown-overlay"], 373,326)
		end
		
	end

	-- health and mana bars
	
	self:drawBar(164-2, 348-2, party.stats.health, party.stats.health_max, 62, 1)
	self:drawBar(413-2, 348-2, party.stats.mana, party.stats.mana_max, 62, 2)
	

end

function Renderer:drawEnemyStats(enemy)

	self:drawText(0, 10+50, enemy.properties.name, {1,1,1,1}, "center")
	
	local x = math.floor(screen.width/2 - assets.images["enemy-hit-bar-background"]:getWidth()/2)
	local y = 30+50
	
	love.graphics.draw(assets.images["enemy-hit-bar-background"], x, y)

	if enemy.properties.health > 0 then
		self:drawBar(x, y, enemy.properties.health, enemy.properties.health_max, 143, 1)
	end

end

function Renderer:drawDigits(value, x, y)

	local str = tostring(value)
	local x,y = x - (#str*6), y
	for i = 1, #str do
		local c = tonumber(string.sub(str,i,i))
		love.graphics.draw(assets.images["digits"], assets.digit_quads[c], x + (i*6), y)
	end

end

function Renderer:drawBar(x, y, maxval, minval, maxbarsize, bartype)

	local f = maxval/minval
	local barsize = math.floor(maxbarsize * f)
	local quad = nil

	if barsize <= 0 then
		return
	end

	local offs = 3

	local img = assets.images["bar-type-1"]

	if bartype == 2 then
		img = assets.images["bar-type-2"]
	end

	
	-- bar body
	quad = love.graphics.newQuad(1, 0, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, x + offs, y + offs, 0, barsize, 1)

	-- left edge
	
	quad = love.graphics.newQuad(0, 0, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, x + offs, y + offs)

	-- right edge
	
	quad = love.graphics.newQuad(2, 2, 1, 5, img:getWidth(), img:getHeight())
	love.graphics.draw(img, quad, (x + offs) + (barsize-1), y + offs)
	
end

function Renderer:drawObject(atlasId, layerId, x, z)

	local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
	
	local xx = bothsides and x - (x * 2) or 0
	local tile = self:getTile(atlasId, layerId, "object", xx, z);

	if tile then

		local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())

		if bothsides then
			love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x, tile.screen.y)
		else
			local tx = tile.screen.x + (x * tile.coords.w)
			love.graphics.draw(atlases.images[atlasId], quad, tx, tile.screen.y)
		end

	end
	
end

function Renderer:drawDecal(atlasId, layerId, x, z)

	local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
	
	local xx = bothsides and x - (x * 2) or 0
	
	-- front
	
	if x > 0 then
	
		local tile = self:getTile(atlasId, layerId, "decal-front", x, z);
		
		if tile then
			local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())
			love.graphics.draw(atlases.images[atlasId], quad, screen.width - tile.screen.x, tile.screen.y, math.pi, 1, -1)
		end

	end
	
	if x <= 0 then
	
		local tile = self:getTile(atlasId, layerId, "decal-front", x - (x * 2), z);
		
		if tile then
			local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())
			love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x , tile.screen.y)
		end

	end
	
	-- side
	
	if x >= 0 then
	
		local tile = self:getTile(atlasId, layerId, "decal-side", x, z);
		
		if tile then
			local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())
			local tx = tile.screen.x + (x * tile.coords.w)
			love.graphics.draw(atlases.images[atlasId], quad, screen.width - tile.screen.x, tile.screen.y, math.pi, 1, -1)
		end	

	end	
	
	-- side

	if x <= 0 then
	
		local tile = self:getTile(atlasId, layerId, "decal-side", x - (x * 2), z);
		
		if tile then
			local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())
			love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x , tile.screen.y)
		end		

	end
		
end

function Renderer:drawGround()

	local atlasId = level.data.tileset .. "-environment"

    for z = -self.dungeonDepth, 0 do
		
		for x = -self.dungeonWidth, self.dungeonWidth do

			local p = self:getPlayerDirectionVectorOffsets(x, z);

			if p.x >= 1 and p.y >= 1 and p.x <= level.data.mapSize and p.y <= level.data.mapSize then
			
				local layerId = self.backgroundIndex == 1 and level.data.tileset.."-ground-1" or level.data.tileset.."-ground-2"
				local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
				local xx = bothsides and x - (x * 2) or 0
				local tile = self:getTile(atlasId, layerId, "ground", xx, z);
				
				if tile then

					local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())

					if bothsides then
						love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x, tile.screen.y)
					else
						local tx = tile.screen.x + (x * tile.coords.w)
						love.graphics.draw(atlases.images[atlasId], quad, tx, tile.screen.y)
					end

				end		
				
			end
			
		end		

	end
	
end

function Renderer:drawCeiling()

	local atlasId = level.data.tileset .. "-environment"

    for z = -self.dungeonDepth, 0 do
		
		for x = -self.dungeonWidth, self.dungeonWidth do

			local p = self:getPlayerDirectionVectorOffsets(x, z);

			if p.x >= 1 and p.y >= 1 and p.x <= level.data.mapSize and p.y <= level.data.mapSize then
			
				local layerId = self.backgroundIndex == 1 and level.data.tileset.."-ceiling-1" or level.data.tileset.."-ceiling-2"
				local bothsides = atlases.jsondata[atlasId].layer[layerId] and atlases.jsondata[atlasId].layer[layerId].mode == 2
				local xx = bothsides and x - (x * 2) or 0
				local tile = self:getTile(atlasId, layerId, "ceiling", xx, z);

				if tile then

					local quad = love.graphics.newQuad(tile.coords.x, tile.coords.y, tile.coords.w, tile.coords.h, atlases.images[atlasId]:getWidth(), atlases.images[atlasId]:getHeight())

					if bothsides then
						love.graphics.draw(atlases.images[atlasId], quad, tile.screen.x, tile.screen.y)
					else
						local tx = tile.screen.x + (x * tile.coords.w)
						love.graphics.draw(atlases.images[atlasId], quad, tx, tile.screen.y)
					end

				end		
				
			end
			
		end		

	end
	
end

function Renderer:drawSky()

	if self.skyIndex == 1 then
		love.graphics.draw(assets.images["sky"], 0, 0)
	else
		love.graphics.draw(assets.images["sky"], 640, 0, 0, -1, 1)
	end
	
end

function Renderer:drawSquare(x, z)

    local p = self:getPlayerDirectionVectorOffsets(x, z);

    if p.x >= 1 and p.y >= 1 and p.x <= level.data.mapSize and p.y <= level.data.mapSize then

		if level.data.walls[p.x] and level.data.walls[p.x][p.y] then
			local wall = level.data.walls[p.x][p.y]
			if wall.type ~= 3 then
				self:drawObject(level.data.tileset .. "-environment", "walls", x, z)
			end
		end
		
		if level.data.boundarywalls[p.x] and level.data.boundarywalls[p.x][p.y] then
			local wall = level.data.boundarywalls[p.x][p.y]
			if wall.type == 3 then
				self:drawObject(level.data.tileset .. "-environment", "boundarywalls", x, z)
			end
		end
		
		for key,value in pairs(level.data.staticprops) do
			local prop = level.data.staticprops[key]
			if prop.properties.visible == 1 then
				if prop.x == p.x and prop.y == p.y then
					self:drawObject(prop.properties.atlasid, self:getObjectDirectionID(prop.properties.name, prop.properties.direction), x, z)
				end
			end
		end
		
		for key,value in pairs(level.data.levelexits) do
			local levelexit = level.data.levelexits[key]
			if levelexit.x == p.x and levelexit.y == p.y then
				self:drawObject(levelexit.properties.atlasid, self:getObjectDirectionID(levelexit.properties.imageid, levelexit.properties.direction), x, z)
			end
		end		
		
		for key,value in pairs(level.data.bossgates) do
			local bossgate = level.data.bossgates[key]
			if bossgate.x == p.x and bossgate.y == p.y then
				local imageid = bossgate.properties.state == 1 and "boss-gate-open" or "boss-gate-closed"
				self:drawObject("forest-environment", self:getObjectDirectionID(imageid, bossgate.properties.direction), x, z)
			end
		end			
		
		for key,value in pairs(level.data.enemies) do
			local enemy = level.data.enemies[key]
			if enemy.x == p.x and enemy.y == p.y then
				local imageid = enemy.properties.imageid
				if enemy.highlight and enemy.highlight == 1 then
					highlightshader:send("WhiteFactor", 0.5)
				end
				if enemy.properties.state == 1 then
					if enemy.properties.attacking == 1 then
						self:drawObject("enemies", self:getObjectDirectionID(imageid .. "-attack", enemy.properties.direction), x, z)
					else 
						self:drawObject("enemies", self:getObjectDirectionID(imageid, enemy.properties.direction), x, z)
					end
				elseif enemy.properties.state == 3 then
					self:drawObject("enemies", self:getObjectDirectionID(imageid .. "-dead", enemy.properties.direction), x, z)
				end			
				highlightshader:send("WhiteFactor", 0)
			end
		end
		
		for key,value in pairs(level.data.npcs) do
			local npc = level.data.npcs[key]
			if npc.properties.visible == 1 and npc.x == p.x and npc.y == p.y then
				self:drawObject("npc", npc.properties.imageid, x, z)			
			end
		end		

		for key,value in pairs(level.data.chests) do
			local chest = level.data.chests[key]
			if chest.x == p.x and chest.y == p.y then
				local imageid = chest.properties.state == 1 and "chest-closed" or "chest-open"
				if chest.properties.state == 3 then imageid = "chest-closed" end
				self:drawObject("common-props", imageid, x, z)			
			end
		end

		for key,value in pairs(level.data.wells) do
			local well = level.data.wells[key]
			if well.x == p.x and well.y == p.y then
				self:drawObject("common-props", self:getObjectDirectionID("well", well.properties.direction), x, z)			
			end
		end
		
		for key,value in pairs(level.data.doors) do
			local door = level.data.doors[key]
			if door.x == p.x and door.y == p.y then
				if door.properties.type == 1 then
					self:drawObject(level.data.tileset .. "-environment", "door", x, z)			
				elseif door.properties.type == 2 then
					local objId = self:getObjectDirectionID("gate", door.properties.direction)
					self:drawObject(level.data.tileset .. "-environment", objId and objId or "gate", x, z)			
				end
			end
		end
		
		for key,value in pairs(level.data.portals) do
			local portal = level.data.portals[key]
			if portal.properties.visible == 1 then
				if portal.x == p.x and portal.y == p.y then
					self:drawObject(level.data.tileset .. "-props", self:getObjectDirectionID("portal", portal.properties.direction), x, z)			
				end
			end
		end	

		for key,value in pairs(level.data.buttons) do
			local button = level.data.buttons[key]
			if button.x == p.x and button.y == p.y then
				if button.properties.state == 1 then
					self:drawObject(level.data.tileset .. "-props", self:getObjectDirectionID("secret-button-out", 1), x, z)
				else
					self:drawObject(level.data.tileset .. "-props", self:getObjectDirectionID("secret-button-in", 1), x, z)
				end
			end
		end	
		
	end

end

function Renderer:drawViewport()

	if not level.loaded then 
		return
	end	

	if level.data.tileset ~= "dungeon" then
		self:drawSky()
	end
	self:drawGround()
	self:drawCeiling()

    for z = -self.dungeonDepth, 0 do
		
		for x = -self.dungeonWidth, -1 do
			self:drawSquare(x, z)
		end		

		for x = self.dungeonWidth, 1, -1 do
			self:drawSquare(x, z)
		end		
		
		self:drawSquare(0, z)
	
	end

end

function Renderer:isDraggingItem()

	return inventoryDragSource.item ~= nil
	
end

function Renderer:showInventory(value)

	assets:playSound("window-open")

	self.currentHoverItem = nuil

	inventoryDragSource = {}

	self.doShowInventory = value

	if not value then
		subState = SubStates.IDLE
	else
		subState = SubStates.INVENTORY
	end
	
end

function Renderer:showAutomapper(value)

	assets:playSound("window-open")

	self.doShowAutomapper = value

	if not value then
		subState = SubStates.IDLE
	else
		subState = SubStates.AUTOMAPPER
	end
					
end

function Renderer:showSystemMenu(value)

	assets:playSound("window-open")

	self.currentHoverItem = nuil

	self.doShowSystemMenu = value

	if not value then
		subState = SubStates.IDLE
	else
		subState = SubStates.SYSTEM_MENU
	end
	
end

function Renderer:inventoryShowing()

	return self.doShowInventory

end

function Renderer:systemMenuShowing()

	return self.doShowSystemMenu

end

function Renderer:automapperShowing()

	return self.doShowAutomapper

end

function Renderer:onCloseButtonClick()

	renderer:showInventory(false)

end

function Renderer:onStartButtonClick()
	
	Game:startGame()
	
end

function Renderer:onContinueGameButtonClick()

	Game:continueGame()

end

function Renderer:onSettingsButtonClick()

	self:showSystemMenu(true)

end

function Renderer:onCreditsButtonClick()

	gameState = GameStates.CREDITS

end

function Renderer:onAboutButtonClick()

	gameState = GameStates.ABOUT

end

function Renderer:onQuitButtonClick()

	Game:quitGame()

end

function Renderer:onBackToMenuButtonClick()

	settings.canContinue = settings.savegameSlots[savedsettings.lastSavegameSlot]
	self:showSystemMenu(false)
	fadeMusicVolume.v = savedsettings.musicVolume
	assets:stopMusic(level.data.tileset)
	assets:setMusicVolume("mainmenu", savedsettings.musicVolume)
	assets:playMusic("mainmenu")
	
	gameState = GameStates.MAIN_MENU
	subState = SubStates.IDLE

end

function Renderer:onCloseVendorButtonClick()

	subState = SubStates.IDLE

end

function Renderer:onCloseTavernButtonClick()

	subState = SubStates.IDLE
	renderer.showTavern = false
	
end

function Renderer:onCloseSystemMenuButtonClick()

	subState = SubStates.IDLE
	self.doShowSystemMenu = false

end

function Renderer:onCloseMapButtonClick()

	renderer:showAutomapper(false)

end

function Renderer:showPopup(text, sound)
	
	if sound or sound == nil then
		assets:playSound("popup")
	end

	self.popupText = text
	subState = SubStates.POPUP
	
end

function Renderer:showSpellList()

	subState = SubStates.SELECT_SPELL

end

function Renderer:showNPC(npc)

	self.currentNPC = npc
	subState = SubStates.NPC

end

function Renderer:showVendor(id)

	if id == "antsacs" then
		if party.antsacs > 0 then
			assets:playSound("gold-coins")
		else
			assets:playSound("vendor-"..id)
		end
		subState = SubStates.VENDOR_ANTSACS
	elseif id == "tavern" then
		assets:playSound("welcome-1")
		self.showTavern = true
		subState = SubStates.TAVERN
	else
		self.currentVendor = vendors.vendor[id]
		assets:playSound("vendor-"..id)
		subState = SubStates.VENDOR
	end

end

function Renderer:showFoundLoot(gold, items, antsacs)

	assets:playSound("loot")

	self.foundloot = {gold = gold, items = items, antsacs = antsacs}
	
	subState = SubStates.FOUND_LOOT

end

return Renderer
