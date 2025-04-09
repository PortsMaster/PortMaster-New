--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- menu object
local newobject = loveframes.NewObject("menu", "loveframes_object_menu", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(menu)
	
	self.type = "menu"
	self.width = 80
	self.height = 25
	self.largest_item_width = 0
	self.largest_item_height = 0
	self.is_sub_menu = false
	self.internal = false
	self.parentmenu = nil
	self.options = {}
	self.internals = {}
	
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	self:CheckHover()
	
	local hover = self.hover
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	for k, v in ipairs(self.internals) do
		local width = v.contentwidth
		local height = v.contentheight
		if width > self.largest_item_width then
			self.largest_item_width = width
		end
		if height > self.largest_item_height then
			self.largest_item_height = height
		end
	end
	
	local y = 0
	self.height = 0
	
	for k, v in ipairs(self.internals) do
		v:SetWidth(self.largest_item_width)
		if v.option_type ~= "divider" then
			v:SetHeight(self.largest_item_height)
		else
			v:SetHeight(5)
		end
		v:SetY(y)
		self.height = self.height + v.height
		y = y + v.height
		v:update(dt)
	end
	
	self.width = self.largest_item_width
	self.largest_item_width = 0
	self.largest_item_height = 0
	
	local screen_width = love.graphics.getWidth()
	local screen_height = love.graphics.getHeight()
	local sx = self.x
	local sy = self.y
	local width = self.width
	local height = self.height
	local x1 = sx + width
	if sx + width > screen_width then
		self.x = screen_width - width
	end
	if sy + self.height > screen_height then
		self.y = screen_height - self.height
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local internals = self.internals
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: AddOption(text, icon, func)
	- desc: adds an option to the object
--]]---------------------------------------------------------
function newobject:AddOption(text, icon, func)

	local menuoption = loveframes.objects["menuoption"]:new(self)
	menuoption:SetText(text)
	menuoption:SetIcon(icon)
	menuoption:SetFunction(func)
	
	table.insert(self.internals, menuoption)
	return self
	
end

--[[---------------------------------------------------------
	- func: RemoveOption(id)
	- desc: removes an option
--]]---------------------------------------------------------
function newobject:RemoveOption(id)

	for k, v in ipairs(self.internals) do
		if k == id then
			table.remove(self.internals, k)
			return
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: AddSubMenu(text, icon, menu)
	- desc: adds a submenu to the object
--]]---------------------------------------------------------
function newobject:AddSubMenu(text, icon, menu)

	local function activatorFunc(object)
		if menu:GetVisible() then
			local hoverobject = loveframes.hoverobject
			if hoverobject ~= object and hoverobject:GetBaseParent() ~= menu then
				menu:SetVisible(false)
			end
		else
			menu:SetVisible(true)
			menu:SetPos(object:GetX() + object:GetWidth(), object:GetY())
		end
	end
	
	menu:SetVisible(false)
	
	local menuoption = loveframes.objects["menuoption"]:new(self, "submenu_activator", menu)
	menuoption:SetText(text)
	menuoption:SetIcon(icon)
	
	if menu then
		menu.is_sub_menu = true
		menu.parentmenu = self
	end
	
	table.insert(self.internals, menuoption)
	return self
	
end

--[[---------------------------------------------------------
	- func: AddDivider()
	- desc: adds a divider to the object
--]]---------------------------------------------------------
function newobject:AddDivider()

	local menuoption = loveframes.objects["menuoption"]:new(self, "divider")
	
	table.insert(self.internals, menuoption)
	return self
	
end

--[[---------------------------------------------------------
	- func: GetBaseMenu(t)
	- desc: gets the object's base menu
--]]---------------------------------------------------------
function newobject:GetBaseMenu(t)
	
	local t = t or {}
	
	if self.parentmenu then
		table.insert(t, self.parentmenu)
		self.parentmenu:GetBaseMenu(t)
	else
		return self
	end
	
	return t[#t]
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: sets the object's visibility
--]]---------------------------------------------------------
function newobject:SetVisible(bool)

	self.visible = bool
	
	if not bool then
		local internals = self.internals
		for k, v in ipairs(internals) do
			if v.menu then
				v.activated = false
				v.menu:SetVisible(bool)
			end
		end
	end
	
	return self
	
end

---------- module end ----------
end
