local Settings = {}
Settings.__index = Settings

function Settings:base(name, settings)
	local cls = {}
	cls.name = name
	cls.settings = settings
	cls.curBind = 1
	cls.binds = 1
	cls.size = 30
	cls.margin = 15
	cls.titleWidth = 0.5
	cls.selected = false

	return setmetatable(cls, self)
end

function Settings:getSize()
	return self.size + self.margin
end

function Settings:getY(i)
	local size = self:getSize()
	local v = (i - 1) * size
	for _, off in ipairs(self.offsets) do if i >= off then v = v + size end end
	return v
end

function Settings:makeLine(x, starti, endi)
	if starti > endi then return end
	local start = self:getY(starti)
	local line = Graphic(x - 1, start, 2, self:getSize() + self:getY(endi) - start, Color.WHITE)
	line.alpha = 0.5
	self.tab.linesGroup:add(line)
end

function Settings:makeLines(width, offset, lines, starti, endi)
	if lines < 1 or starti > endi then return end

	local s = 1 / (lines + 1)
	for i = s, 1, s do
		if i == 1 then break end
		self:makeLine(width * i + offset, starti, endi)
	end
end

function Settings:getOption(id)
	local option = self.settings[id]
	local bind = self.curBind
	if type(option[3]) == "table" then return option[bind][3] and option[bind][3]() or nil end
	return ClientPrefs.data[option[1]]
end

function Settings:getOptionString(id)
	local option, value = self.settings[id], self:getOption(id)
	local bind = self.curBind
	if type(option[3]) == "table" then return option[bind][2](value) end
	if type(option[5]) == "function" then return option[5](value) end

	local optiontype = option[3]
	if optiontype == "boolean" then
		return value and "On" or "Off"
	elseif optiontype == "string" then
		return value:capitalize()
	end

	return value or "Unknown"
end

function Settings:enterOption(id, optionsUI)
	local bind = self.curBind

	if type(self.settings[id][3]) == "function" then
		return self.settings[id][3](optionsUI)
	end

	if self.tab then
		local selectedStr = "< " .. self:getOptionString(id, bind) .. " >"
		self.tab.items[id].texts[bind].content = selectedStr
		self.selected = true
		if self.binds > 1 then self:changeBind(id, 0) end
	end
end

function Settings:leaveOption(id)
	local bind = self.curBind
	if self.tab then
		self.tab.items[id].texts[bind].content = self:getOptionString(id, bind)
		self.selected = false
	end
end

function Settings:cancel(id, oldValue)
	local bind = self.curBind
	local func = self.settings[id][4]
	local functype, ret = type(func)

	if ClientPrefs.data[self.settings[id][1]] ~= oldValue then
		if func and functype == "function" then func(0) end
		ClientPrefs.data[self.settings[id][1]] = oldValue
	end

	if self.tab then
		self.tab.items[id].texts[bind].content = self:getOptionString(id, bind)
	end
end

function Settings:changeOption(id, add, optionsUI)
	local option, value = self.settings[id], self:getOption(id)
	local bind = self.curBind
	local prev = value

	local optiontype, func = option[3], option[4]
	local functype, ret, dont = type(func)
	if optiontype == "boolean" then
		if functype == "function" then
			ret, dont = func(add, optionsUI)
			value = self:getOption(id)
		else
			value = not value
		end
	elseif optiontype == "string" then
		if functype == "function" then
			ret, dont = func(add, optionsUI)
			value = self:getOption(id)
		elseif functype == "table" then
			value = func[math.wrap(table.find(func, value) + add, 1, #func + 1)]
		else
			-- TODO: input
		end
	elseif optiontype == "number" then
		if functype == "function" then
			ret, dont = func(add, optionsUI)
			value = self:getOption(id)
		elseif functype == "table" then
			value = func[math.wrap(value + add, 1, #func + 1)]
		else
			value = value + add
		end
	elseif type(optiontype) == "table" or bind then
		if not bind then return false end
		ret, dont = option[3][bind][1](add, value, optionsUI)
		value = self:getOption(id, bind)
	end

	if functype ~= "function" then ClientPrefs.data[option[1]] = value end
	if self.tab then
		local selectedStr = self:getOptionString(id, bind)
		if self.selected then selectedStr = "< " .. selectedStr .. " >" end
		self.tab.items[id].texts[bind].content = selectedStr
	end
	if dont then optionsUI.dontPlaySound = true end
	if ret ~= nil then return ret end
	return value ~= prev
end

function Settings:acceptOption(id, optionsUI)
	local option = self.settings[id]
	local bind = self.curBind
	local optiontype = option[3]

	self:leaveOption(id, bind)
	if type(optiontype) == "table" or #self.tab.items[id].texts > 1 then
		if bind then
			local ret = option[3][bind][1](0, value, optionsUI, bind)
			if ret ~= nil then return ret end
			return true
		end

		optionsUI.blockInput = true
		self.curBind = 1
		self.onBinding = true
	end
	return false
end

function Settings:makeOption(group, i, font, tabWidth, titleWidth, binds)
	local margin, option = self.margin, self.settings[i]
	local optiontype = type(option[3])
	local align = "left"

	if optiontype == "table" then
		binds = #option[3]
	elseif optiontype == "number" then
		binds = options[3]
	elseif optiontype == "string" then
		binds = 1
	elseif optiontype == "function" then
		binds = 0
		titleWidth = tabWidth - margin
		align = "center"
	end

	group:add(Text(margin, margin / 2, option[2], font, Color.WHITE, align, titleWidth - margin))
	group.texts = {}

	local width = tabWidth - titleWidth
	for i2 = 1, binds do
		local text = Text(width * (i2 - 1) / binds + margin + titleWidth, margin / 2,
			self:getOptionString(i, i2), font, Color.WHITE, "center", width / binds - margin * 2)

		table.insert(group.texts, text)
		group:add(text)
	end

	return binds
end

function Settings:changeBind(id, add, dont)
	if self.tab then
		local prevBind = self.curBind
		local prevTxt = self.tab.items[id].texts[self.curBind]
		self.curBind = math.wrap(self.curBind + add, 1, self.binds + 1)
		local newTxt = self.tab.items[id].texts[self.curBind]

		prevTxt.content = self:getOptionString(id, prevBind)
		newTxt.content = "> " .. self:getOptionString(id, self.curBind) .. " <"
	end
end

function Settings:make(optionsUI)
	local size, margin, tabWidth = self.size, self.margin, optionsUI.tabBG.width
	local font = paths.getFont('phantommuff.ttf', size)

	local tab = SpriteGroup()
	self.tab = tab
	tab.name = self.name
	tab.items = {}

	tab.linesGroup = Group()

	self.offsets = {}
	local binds, lastbinds, lastcategoryi, lastlinesi, lastwidth, titlewidth = self.binds, 0, 0, 0, 0
	for i, option in ipairs(self.settings) do
		local group, length = SpriteGroup(), #option
		titlewidth = tabWidth * (option[6] or self.titleWidth)

		group.isTitle = length < 2 or type(option[2]) == "number"
		if group.isTitle then -- Category
			local bg = Graphic(0, 0, tabWidth, self:getSize(), Color.BLACK)
			bg.alpha = 1 / 3

			group:add(bg)
			group:add(Text(0, margin / 2, option[1], font, Color.WHITE, "center", tabWidth))

			if i ~= 1 then
				self:makeLine(lastwidth, lastcategoryi + 1, i - 1)
				self:makeLines(tabWidth - lastwidth, lastwidth, lastbinds - 1, lastlinesi + 1, i - 1)
				table.insert(self.offsets, i)
			end
			binds, lastcategoryi, lastlinesi = option[2] or self.binds, i, i
			lastbinds, lastwidth = binds, titlewidth
		else
			local v = self:makeOption(group, i, font, tabWidth, titlewidth, binds)
			local change = titlewidth ~= lastwidth or v == 0 or lastbinds == 0
			if not v and lastbinds ~= binds then v = binds end
			if (v and v ~= lastbinds) or change then
				if change then
					if lastbinds ~= 0 then self:makeLine(lastwidth, lastcategoryi + 1, i - 1) end
					lastcategoryi = i - 1
				end
				self:makeLines(tabWidth - lastwidth, lastwidth, lastbinds - 1, lastlinesi + 1, i - 1)
				lastwidth, lastbinds, lastlinesi = titlewidth, v, i - 1
			end
		end

		group.y = self:getY(i)
		if next(group.members) then tab:add(group) end
		table.insert(tab.items, group)
	end

	local i = #self.settings
	titlewidth = tabWidth * (self.settings[i][6] or self.titleWidth)
	if lastbinds ~= 0 then self:makeLine(titlewidth, lastcategoryi + 1, i) end
	self:makeLines(tabWidth - titlewidth, titlewidth, lastbinds - 1, lastlinesi + 1, i)

	tab:add(tab.linesGroup)
	tab.data = self

	return tab
end

return Settings
