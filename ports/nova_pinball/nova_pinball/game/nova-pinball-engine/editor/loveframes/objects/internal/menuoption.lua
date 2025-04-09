--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- menuoption object
local newobject = loveframes.NewObject("menuoption", "loveframes_object_menuoption", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, option_type, menu)
	
	self.type = "menuoption"
	self.text = "Option"
	self.width = 100
	self.height = 25
	self.contentwidth = 0
	self.contentheight = 0
	self.parent = parent
	self.option_type = option_type or "option"
	self.menu = menu
	self.activated = false
	self.internal = true
	self.icon = false
	self.func = nil
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
	local option_type = self.option_type
	local activated = self.activated
	local base = loveframes.base
	local update = self.Update
	
	if option_type == "submenu_activator" then
		if hover and not activated then
			self.menu:SetVisible(true)
			self.menu:MoveToTop()
			self.activated = true
		elseif not hover and activated then
			local hoverobject = loveframes.hoverobject
			if hoverobject and hoverobject:GetBaseParent() == self.parent then
				self.menu:SetVisible(false)
				self.activated = false
			end
		elseif activated then
			local screen_width = love.graphics.getWidth()
			local screen_height = love.graphics.getHeight()
			local sx = self.x
			local sy = self.y
			local width = self.width
			local height = self.height
			local x1 = sx + width
			if x1 + self.menu.width <= screen_width then
				self.menu.x = x1
			else
				self.menu.x = sx - self.menu.width
			end
			if sy + self.menu.height <= screen_height then
				self.menu.y = sy
			else
				self.menu.y = (sy + height) - self.menu.height
			end
		end
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
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
	
	local hover = self.hover
	local option_type = self.option_type
	if hover and option_type ~= "divider" and button == 1 then
		local func = self.func
		if func then
			local text = self.text
			func(self, text)
		end
		local basemenu = self.parent:GetBaseMenu()
		basemenu:SetVisible(false)
	end

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	self.text = text
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetIcon(icon)
	- desc: sets the object's icon
--]]---------------------------------------------------------
function newobject:SetIcon(icon)

	if type(icon) == "string" then
		self.icon = love.graphics.newImage(icon)
		self.icon:setFilter("nearest", "nearest")
	elseif type(icon) == "userdata" then
		self.icon = icon
	end
end

--[[---------------------------------------------------------
	- func: GetIcon()
	- desc: gets the object's icon
--]]---------------------------------------------------------
function newobject:GetIcon()

	return self.icon
	
end

--[[---------------------------------------------------------
	- func: SetFunction(func)
	- desc: sets the object's function
--]]---------------------------------------------------------
function newobject:SetFunction(func)

	self.func = func
	
end

---------- module end ----------
end
