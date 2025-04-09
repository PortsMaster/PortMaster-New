local ModsState = State:extend("ModsState")
local ModCard = require "funkin.ui.mods.card"

function ModsState:enter(pre)
	Mods.loadMods()
	self.prevMods = nil
	self.previousState = pre
	self.switchingMods = false
	self.curColor = Color.WHITE

	self.bg = Sprite()
	self.bg:loadTexture(paths.getImage('menus/menuDesat'))
	self.bg:setGraphicSize(math.floor(
		self.bg.width * (game.width / self.bg.width)))
	self.bg:updateHitbox()
	self.bg:screenCenter()
	self:add(self.bg)

	self.bd = BackDrop(0, 0, game.width, game.height, 72, nil, {0, 0, 0, 0}, 26)
	self.bd:setScrollFactor()
	self.bd.alpha = 0.5
	self:add(self.bd)

	self.cards = MenuList(paths.getSound("scrollMenu"), false, "horizontal")
	self.cards.curSelected = table.find(Mods.mods, Mods.currentMod) or 1
	self.cards.changeCallback = bind(self, self.changeSelection)
	self:add(self.cards)

	if #Mods.mods == 0 then
		self.noModsTxt = AtlasText(0, 0, 'No mods here', "bold")
		self.noModsTxt:screenCenter()
		self:add(self.noModsTxt)
	end

	if #Mods.mods > 0 then
		for i = 1, #Mods.mods do
			local card = ModCard(0, 0, Mods.mods[i])
			self.cards:add(card)
			card.xAdd = (game.width - 432) / 2
			card.xMult = 400
		end
	end

	self.infoTxt = Text(6, game.height * 0.96, 'Select the current mod to disable it',
		paths.getFont('phantommuff.ttf', 24))
	self.infoTxt:screenCenter('x')
	self.infoTxt:setScrollFactor()
	self.infoTxt.visible = (Mods.currentMod ~= nil)
	self:add(self.infoTxt)

	-- Update Presence
	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Mods Menu"})
	end

	if love.system.getDevice() == "Mobile" then
		self.buttons = VirtualPadGroup()
		local w = 134

		local left = VirtualPad("left", 0, game.height - w)
		local right = VirtualPad("right", w, left.y)

		local enter = VirtualPad("return", game.width - w, left.y)
		enter.color = Color.GREEN
		local back = VirtualPad("escape", enter.x - w, left.y, w, w)
		back.color = Color.RED

		self.buttons:add(left)
		self.buttons:add(right)
		self.buttons:add(enter)
		self.buttons:add(back)

		self:add(self.buttons)
	end

	self.bg.color = self.curColor
	self.bd.color = Color.saturate(self.bg.color, 0.4)

	if #Mods.mods > 0 then
		self.cards:changeSelection()
		self:changeSelection()
		self.bg.color = self.curColor
		self.bd.color = Color.saturate(self.bg.color, 0.4)
	end

	ModsState.super.enter(self)
end

function ModsState:update(dt)
	ModsState.super.update(self, dt)

	for _, mod in pairs(self.cards.members) do
		local yPos = self.cards.curSelected == mod.ID and 50 or 502
		mod.y = util.coolLerp(mod.y, yPos, 12, dt)
	end

	if not self.switchingMods then
		if #Mods.mods > 0 then
			if controls:pressed('accept') then self:selectMods() end
		end

		if controls:pressed('back') then
			game.switchState(self.previousState)
		end
	end

	self.bg.color = Color.lerpDelta(self.bg.color, self.curColor, 3, dt)
	self.bd.color = Color.saturate(self.bg.color, 0.4)
end

function ModsState:selectMods()
	local card = self.cards.members[self.cards.curSelected]
	local selectedMods = Mods.mods[self.cards.curSelected]
	if selectedMods == Mods.currentMod then
		Mods.currentMod = nil

		Timer.tween(0.5, card.enableCheck.color, {[1] = 1, [2] = 0, [3] = 0}, "out-circ", function()
			Timer.tween(1, game.camera, {zoom = 1.15, alpha = 0}, "in-sine", function()
				game.sound.music:stop()
				Timer.after(1, function() game.switchState(TitleState(), true) end)
			end)
		end)
	else
		Mods.currentMod = selectedMods

		Timer.tween(0.5, card.enableCheck.color, {[1] = 0, [2] = 1, [3] = 0}, "out-circ")
		if self.prevMods then
			local prevCard = self.cards.members[self.prevMods]
			Timer.tween(0.5, prevCard.enableCheck.color, {[1] = 1, [2] = 0, [3] = 0}, "out-circ")
		end

		Timer.tween(0.5, game.camera, {zoom = 1.05}, "out-circ", function()
			Timer.tween(1, game.camera, {zoom = 1.15, alpha = 0}, "in-sine", function()
				game.sound.music:stop()
				Timer.after(1, function() game.switchState(TitleState(), true) end)
			end)
		end)
	end

	util.playSfx(paths.getSound('confirmMenu'))
	game.sound.music:fade(1.5, 1, 0)

	game.save.data.currentMod = Mods.currentMod
	self.switchingMods = true

	self.cards.lock = true

	TitleState.initialized = false
end

function ModsState:changeSelection(change)
	local color = Color.fromString(Mods.getMetadata(
		Mods.mods[self.cards.curSelected]).color or "#1F1F1F")
	self.curColor = {color[1] or 1, color[2] or 1, color[3] or 1}
end

return ModsState
