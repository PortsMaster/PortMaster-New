---@class Options:SpriteGroup
local Options = SpriteGroup:extend("Options")

local settings = table.new(0, 3)
settings.Gameplay = require "funkin.ui.options.gameplay"
settings.Display = require "funkin.ui.options.display"
settings.Controls = require "funkin.ui.options.controls"

function Options:new(showBG, completionCallback)
	Options.super.new(self)

	self.settingsNames = {"Gameplay", "Display", "Controls"}

	self.showBG = showBG
	self.completionCallback = completionCallback

	self.curTab = 1
	self.curSelect = 1
	self.onTab = false
	self.changingOption = false
	self.blockInput = false
	self.prevVal = nil
	self.dontPlaySound = false

	self.focus = 0

	self.bg = Graphic(0, 0, game.width, game.height, Color.BLACK)
	self.bg:setScrollFactor()
	self:add(self.bg)

	self.tabBGHeight = game.height - 125
	self.tabBG = Graphic(0, 105, game.height * 1.45, self.tabBGHeight, Color.BLACK)
	self.tabBG:screenCenter("x")
	self.tabBG.alpha = 0.7
	self:add(self.tabBG)

	self.tabx, self.taby = self.tabBG.x, self.tabBG.y
	self.tabGroup = SpriteGroup(self.tabx, self.taby)
	self.selectedTab = nil
	self:add(self.tabGroup)

	self.optionsCursor = Graphic(0, 0, 0, 0, Color.WHITE)
	self.optionsCursor.alpha = 0.1
	self.optionsCursor.visible = false
	self:add(self.optionsCursor)

	self.titleTabBG = Graphic(0, 20, game.height * 1.45, 65, Color.BLACK)
	self.titleTabBG:screenCenter("x")
	self.titleTabBG.alpha = 0.7
	self:add(self.titleTabBG)

	self.titleTxt = Text(0, 30, "", paths.getFont("phantommuff.ttf", 40), Color.WHITE, "center", game.width)
	self:add(self.titleTxt)

	if love.system.getDevice() == "Mobile" then
		local camButtons = Camera()
		game.cameras.add(camButtons, false)

		self.buttons = VirtualPadGroup()
		local w = 134

		local left = VirtualPad("left", 0, game.height - w)
		local up = VirtualPad("up", left.x + w, left.y - w)
		local down = VirtualPad("down", up.x, left.y)
		local right = VirtualPad("right", down.x + w, left.y)

		local enter = VirtualPad("return", game.width - w, left.y)
		enter.color = Color.GREEN
		local back = VirtualPad("escape", enter.x - w, left.y)
		back.color = Color.RED

		self.buttons:add(left)
		self.buttons:add(up)
		self.buttons:add(down)
		self.buttons:add(right)

		self.buttons:add(enter)
		self.buttons:add(back)
		self.buttons:set({cameras = {camButtons}})

		self:add(self.buttons)
	end

	self:getWidth()
	self:resetTabs()
end

function Options:enter(parent)
	self.parent = parent

	self.throttles = self.throttles or {}
	self.throttles.left = Throttle:make({controls.down, controls, "ui_left"})
	self.throttles.right = Throttle:make({controls.down, controls, "ui_right"})
	self.throttles.up = Throttle:make({controls.down, controls, "ui_up"})
	self.throttles.down = Throttle:make({controls.down, controls, "ui_down"})

	if Discord then
		Discord.changePresence({details = "In the Menus", state = "Options Menu"})
	end

	if self.buttons then
		self.buttons:enable()
	end

	self:revive()
	self:changeTab()
	self.visible = true

	self.bg.alpha = self.showBG and 0.5 or 0
end

function Options:resetTabs()
	self.tabGroup:destroy()
	self.tabGroup:revive()
	self.curTab = 1

	for _, name in ipairs(self.settingsNames) do
		self.tabGroup:add(settings[name]:make(self))
	end
end

function Options:enterTab()
	self.curSelect = 1
	self.selectedTab = self.tabGroup.members[self.curTab]
	self.onTab = true

	local name = self.settingsNames[self.curTab]
	self.titleTxt.content = name

	self:changeSelection()
	self.optionsCursor.visible = true

	if self.selectedTab.data.binds > 1 then
		self:changeBind(1 - self.selectedTab.data.curBind, true)
	end
end

function Options:exitTab()
	self.optionsCursor.visible = false

	if self.selectedTab.data.onLeaveTab then
		self.selectedTab.data:onLeaveTab(self.curSelect)
	end

	self.selectedTab = nil
	self.onTab = false

	self:changeTab(0, true)
	util.playSfx(paths.getSound("cancelMenu"))
	self.dontPlaySound = false
end

function Options:changeTab(add, dont)
	self.curTab = math.wrap(self.curTab + (add or 0), 1, #self.settingsNames + 1)

	if not dont then util.playSfx(paths.getSound("scrollMenu")) end

	local name = self.settingsNames[self.curTab]
	self.titleTxt.content = "< " .. name .. " >"

	local height = self.tabGroup.members[self.curTab]:getHeight()
	self.tabBG.height = height > self.tabBGHeight and height or self.tabBGHeight

	for _, tab in ipairs(self.tabGroup.members) do
		tab.visible = tab.name == name
	end
end

function Options:changeSelection(add, dont)
	local tab = self.selectedTab
	local prev = self.curSelect
	self.curSelect = math.wrap(self.curSelect + (add or 0), 1, #tab.items + 1)
	while tab.items[self.curSelect].isTitle do
		self.curSelect = math.wrap(self.curSelect + ((add and add < 0) and -1 or 1), 1, #tab.items + 1)
	end

	if not dont then util.playSfx(paths.getSound("scrollMenu")) end
	self.dontPlaySound = false

	self.optionsCursor.x = self.tabBG.x
	self.optionsCursor.width = self.tabBG.width
	self.optionsCursor.height = tab.data:getSize()

	if self.selectedTab.data.onChangeSelection then
		self.selectedTab.data:onChangeSelection(self.curSelect, prev)
	end
end

function Options:enterOption()
	self.changingOption = true
	self.prevVal = self.selectedTab.data:getOption(self.curSelect)

	self.selectedTab.data:enterOption(self.curSelect, self)
end

function Options:changeOption(add, dont)
	if self.selectedTab.data:changeOption(self.curSelect, add, self) and self.applySettings then
		self.applySettings(self.settingsNames[self.curTab]:lower(),
			self.selectedTab.data.settings[self.curSelect][1])
	end
	if not dont and not self.dontPlaySound then util.playSfx(paths.getSound("scrollMenu")) end
	self.dontPlaySound = false
end

function Options:acceptOption(dont)
	if self.selectedTab.data:acceptOption(self.curSelect, self) and self.applySettings then
		self.applySettings(self.settingsNames[self.curTab]:lower(),
			self.selectedTab.data.settings[self.curSelect][1])
	end

	self.prevVal = nil
	self.changingOption = false

	if not dont and not self.dontPlaySound then util.playSfx(paths.getSound("scrollMenu")) end
	self.dontPlaySound = false
end

function Options:cancelChanges()
	self.selectedTab.data:cancel(self.curSelect, self.prevVal)
	if self.applySettings then
		self.applySettings(self.settingsNames[self.curTab]:lower(),
			self.selectedTab.data.settings[self.curSelect][1])
	end

	self.changingOption = false
	self.prevVal = nil

	if not self.dontPlaySound then util.playSfx(paths.getSound("cancelMenu")) end
	self.dontPlaySound = false
end

function Options:changeBind(add, dont)
	self.selectedTab.data:changeBind(self.curSelect, add, dont)
	if not dont and not self.dontPlaySound then util.playSfx(paths.getSound("scrollMenu")) end
	self.dontPlaySound = false
end

function Options:update(dt)
	Options.super.update(self, dt)

	local shift = game.keys.pressed.SHIFT or controls:down("reset")
	local selecty = 0
	if self.onTab then
		if self.selectedTab.data.update and self.selectedTab.data:update(dt, self) then
			return
		end
		if not self.blockInput then
			if not self.changingOption then
				if self.selectedTab.data.binds > 1 then
					if self.throttles.left:check() then self:changeBind(shift and -2 or -1) end
					if self.throttles.right:check() then self:changeBind(shift and 2 or 1) end
				end
				if self.throttles.up:check() then self:changeSelection(shift and -2 or -1) end
				if self.throttles.down:check() then self:changeSelection(shift and 2 or 1) end
				if controls:pressed("accept") then self:enterOption() end
				if controls:pressed("back") and not self.blockInput then return self:exitTab() end
			else
				self.throttles.left.step = 0.02
				self.throttles.right.step = 0.02
				if self.throttles.left:check() then self:changeOption(shift and -2 or -1) end
				if self.throttles.right:check() then self:changeOption(shift and 2 or 1) end
				if controls:pressed("accept") then self:acceptOption() end
				if controls:pressed("back") and not self.blockInput then return self:cancelChanges() end
			end
		end

		selecty = self.selectedTab.data:getY(self.curSelect)
		if self.tabBG.height ~= self.tabBGHeight then
			local size = self.selectedTab.data:getSize()
			local max, bottom, top = self.tabBG.height - game.height + self.taby + size, size * 9, size * 2
			while selecty - self.focus > bottom and self.focus < max do self.focus = self.focus + size end
			while selecty - self.focus < top and self.focus > 0 do self.focus = self.focus - size end
			self.focus = math.clamp(self.focus, 0, max)
		end
	else
		self.focus = 0

		self.throttles.left.step = 1 / 18
		self.throttles.right.step = 1 / 18
		if self.throttles.left:check() then self:changeTab(-1) end
		if self.throttles.right:check() then self:changeTab(1) end
		if controls:pressed("accept") then self:enterTab() end
		if controls:pressed("back") then
			util.playSfx(paths.getSound("cancelMenu"))
			return self.parent:remove(self)
		end
	end

	self.tabGroup.y = util.coolLerp(self.tabGroup.y, self.taby - self.focus, 12, dt)
	self.tabBG.y = self.tabGroup.y
	self.optionsCursor.y = self.tabBG.y + selecty
end

function Options:leave()
	if self.buttons then
		self.buttons:disable()
	end

	if self.throttles then
		for i, v in ipairs(self.throttles) do
			v:destroy()
			self.throttles[i] = nil
		end
	end
	table.clear(self.throttles)

	self:kill()
	self.visible = false
	self.parent = nil

	if self.completionCallback then
		self.completionCallback()
	end
	ClientPrefs.saveData()
end

function Options:destroy()
	Options.super.destroy(self)

	if self.throttles then
		for _, v in ipairs(self.throttles) do v:destroy() end
	end
	self.throttles = nil

	if self.tabGroup then
		self.tabGroup:destroy()
	end
	self.tabGroup = nil

	if self.buttons then
		self.buttons:destroy()
		self:remove(self.buttons)
	end
	self.buttons = nil
	self.applySettings = nil
end

function Options:getWidth()
	self.width, self.height = game.width, game.height
	return self.width
end

function Options:getHeight()
	self.width, self.height = game.width, game.height
	return self.height
end

return Options
