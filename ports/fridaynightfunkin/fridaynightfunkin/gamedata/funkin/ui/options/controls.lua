local Settings = require "funkin.ui.options.settings"

local data = {
	{"NOTES"},
	{"note_left",    "Left"},
	{"note_down",    "Down"},
	{"note_up",      "Up"},
	{"note_right",   "Right"},

	{"UI"},
	{"ui_left",      "Left"},
	{"ui_down",      "Down"},
	{"ui_up",        "Up"},
	{"ui_right",     "Right"},
	{"reset",        "Reset"},
	{"accept",       "Accept"},
	{"back",         "Back"},
	{"pause",        "Pause"},

	{"VOLUME"},
	{"volume_up",    "Volume +"},
	{"volume_down",  "Volume -"},
	{"volume_mute",  "Mute"},

	{"MISCELLANEOUS"},
	{"fullscreen",   "Fullscreen"},
	{"pick_mods",    "Mods"},
	{"asyncInput", "Asynchronous input", "boolean", function()
		love.asyncInput = not ClientPrefs.data.asyncInput
		ClientPrefs.data.asyncInput = love.asyncInput
	end, nil, 0.5},

	{"DEBUG"},
	{"debug_1", "Charting"},
	{"debug_2", "Character"}
}

local Controls = Settings:base("Controls", data)
Controls.binds = 2 --3
Controls.titleWidth = 1 / 3

function Controls:onLeaveTab(id)
	if self.binds > 1 then
		for bind = 1, self.binds do
			local item = self.tab.items[id]
			if item and item.texts then
				local obj = item.texts[bind]
				if obj then obj.content = self:getOptionString(id, bind) end
			end
		end
	end
end

function Controls:onChangeSelection(id, prevID)
	if self.binds > 1 then
		for bind = 1, self.binds do
			local item = self.tab.items[prevID]
			if item and item.texts then
				local obj = item.texts[bind]
				if obj then obj.content = self:getOptionString(prevID, bind) end
			end
		end
	end
	self:changeBind(id, 0)
	self.curSelect = id
end

function Controls:getOptionString(id, bind)
	local option = self.settings[id]
	if option[1] == "asyncInput" then return Settings.getOptionString(self, id, 1) end
	local str = ClientPrefs.controls[option[1]][bind]
	return str and str:sub(5):capitalize() or "None"
end

function Controls:enterOption(id, optionsUI)
	local option = self.settings[id]
	if option[1] == "asyncInput" then
		self.curBind = 1
		return Settings.enterOption(self, id)
	end
	optionsUI.blockInput = true
	optionsUI.changingOption = false
	self.onBinding = true
	self.dontAcceptYet, self.dontBackYet = true, true

	if not self.bg then
		self.bg = Graphic(0, 0, game.width, game.height, Color.BLACK)
		self.bg:setScrollFactor()
		self.bg.alpha = 0.5

		self.waitInputTxt = Text(0, 0, "Rebinding...", paths.getFont("phantommuff.ttf", 40),
			Color.WHITE, "center", game.width)
		self.waitInputTxt:screenCenter('y')
		self.waitInputTxt:setScrollFactor()
	end
	optionsUI:add(self.bg)
	optionsUI:add(self.waitInputTxt)
end

function Controls:changeOption(id, add, optionsUI, bind)
	local option = self.settings[id]
	if option[1] == "asyncInput" then return Settings.changeOption(self, id, add, optionsUI, 1) end
	return false
end

function Controls:changeBind(id, add, dont)
	local option = self.settings[id]
	if option[1] ~= "asyncInput" then return Settings.changeBind(self, id, add, dont) end
end

function Controls:setNewBind(key, optionsUI)
	util.playSfx(paths.getSound('confirmMenu'))
	optionsUI:remove(self.bg)
	optionsUI:remove(self.waitInputTxt)
	self.onBinding = false

	local controlsTable = table.clone(ClientPrefs.controls)

	local id = self.curSelect
	local option = self.settings[id]
	local keyName = option[1]

	local secBind = self.curBind == 1 and 2 or 1
	local oldBind = controlsTable[keyName][self.curBind]

	controlsTable[keyName][self.curBind] = key and ("key:" .. key:lower()) or nil

	if controlsTable[keyName][self.curBind] == controlsTable[keyName][secBind] then
		controlsTable[keyName][secBind] = oldBind
	end

	ClientPrefs.controls = controlsTable

	local config = {controls = table.clone(ClientPrefs.controls)}
	controls:reset(config)

	if self.binds > 1 then
		for bind = 1, self.binds do
			local item = self.tab.items[id]
			if item and item.texts then
				local obj = item.texts[bind]
				if obj then obj.content = self:getOptionString(id, bind) end
			end
		end
	end
	self:changeBind(id, 0)

	return true
end

function Controls:update(dt, optionsUI)
	if not self.onBinding then
		if optionsUI.blockInput then
			optionsUI.blockInput = false
			return true
		end
		return
	end

	local key = next(game.keys.loveInput.justReleased)
	local apprKey = key and "key:" .. key:lower() or nil

	if controls:released("back") then
		if table.find(controls.config.controls.back, apprKey) and self.dontBackYet then
			self.dontBackYet = nil
			return
		end

		optionsUI:remove(self.bg)
		optionsUI:remove(self.waitInputTxt)
		optionsUI.blockInput = false
		self.onBinding = false

		return true
	end

	self.debounceEscape = math.max((self.debounceEscape or 0) - dt, 0) + (game.keys.justPressed.ESCAPE and 1 or 0)
	if self.debounceEscape >= 1.5 then return self:setNewBind("escape", optionsUI) end

	local BACKKEY = game.keys.pressed.ESCAPE
	if #controls.config.controls.back > 0 then BACKKEY = controls:down("back") end
	self.holdingBackKey = BACKKEY and (self.holdingBackKey or 0) + dt or 0
	if self.holdingBackKey >= 1 then return self:setNewBind(nil, optionsUI) end

	-- keybind softlock prevention
	if table.find(controls.config.controls.accept, apprKey) and self.dontAcceptYet then
		self.dontAcceptYet = nil
		return
	end

	if apprKey then return self:setNewBind(key, optionsUI) end
end

return Controls
