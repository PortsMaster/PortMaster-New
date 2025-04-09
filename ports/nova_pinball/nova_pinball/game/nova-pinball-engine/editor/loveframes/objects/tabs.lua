--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- tabs object
local newobject = loveframes.NewObject("tabs", "loveframes_object_tabs", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "tabs"
	self.width = 100
	self.height = 50
	self.clickx = 0
	self.clicky = 0
	self.offsetx = 0
	self.tab = 1
	self.tabnumber = 1
	self.padding = 5
	self.tabheight = 25
	self.previoustabheight = 25
	self.buttonscrollamount = 200
	self.mousewheelscrollamount = 1500
	self.buttonareax = 0
	self.buttonareawidth = self.width
	self.autosize = true
	self.autobuttonareawidth = true
	self.dtscrolling = true
	self.internal = false
	self.tooltipfont = loveframes.basicfontsmall
	self.internals = {}
	self.children = {}
	
	self:AddScrollButtons()
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
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
	
	local x, y = love.mouse.getPosition()
	local tabheight = self.tabheight
	local padding = self.padding
	local autosize = self.autosize
	local autobuttonareawidth = self.autobuttonareawidth
	local padding = self.padding
	local children = self.children
	local numchildren = #children
	local internals = self.internals
	local tab = self.tab
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	self:CheckHover()
	
	if numchildren > 0 and tab == 0 then
		self.tab = 1
	end
	
	if autobuttonareawidth then
		local width = self.width
		self.buttonareawidth = width
	end
	
	local pos = 0
	
	for k, v in ipairs(internals) do
		v:update(dt)
		if v.type == "tabbutton" then
			v.x = (v.parent.x + v.staticx) + pos + self.offsetx + self.buttonareax
			v.y = (v.parent.y + v.staticy)
			pos = pos + v.width - 1
		end
	end
	
	if #self.children > 0 then
		self.children[self.tab]:update(dt)
		self.children[self.tab]:SetPos(padding, tabheight + padding)
	end
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
function newobject:draw()
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local tabheight = self:GetHeightOfButtons()
	local stencilfunc = function() love.graphics.rectangle("fill", x + self.buttonareax, y, self.buttonareawidth, height) end
	
	self:SetDrawOrder()
	
	local drawfunc = self.Draw or self.drawfunc
	if drawfunc then
		drawfunc(self)
	end
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			local col = loveframes.BoundingBox(x + self.buttonareax, v.x, self.y, v.y, self.buttonareawidth, v.width, tabheight, v.height)
			if col or v.type == "scrollbutton" then
				v:draw()
			end
		end
	end
	
	love.graphics.setStencilTest()
	
	local children = self.children
	if #children > 0 then
		children[self.tab]:draw()
	end
	
	drawfunc = self.DrawOver or self.drawoverfunc
	if drawfunc then
		drawfunc(self)
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
	
	local children = self.children
	local internals = self.internals
	local numchildren = #children
	local numinternals = #internals
	local tab = self.tab
	local hover = self.hover
	
	if hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousepressed(x, y, button)
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
	local children = self.children
	local numchildren = #children
	local tab = self.tab
	local internals = self.internals
	
	if not visible then
		return
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	if numchildren > 0 then
		children[tab]:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: wheelmoved(x, y)
	- desc: called when the player moves a mouse wheel
--]]---------------------------------------------------------
function newobject:wheelmoved(x, y)

	local internals = self.internals
	local numinternals = #internals

	if y < 0 then
		local buttonheight = self:GetHeightOfButtons()
		local col = loveframes.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible = internals[numinternals - 1]:GetVisible()
		if col and visible then
			local scrollamount = -y * self.mousewheelscrollamount
			local dtscrolling = self.dtscrolling
			if dtscrolling then
				local dt = love.timer.getDelta()
				self.offsetx = self.offsetx + scrollamount * dt
			else
				self.offsetx = self.offsetx + scrollamount
			end
			if self.offsetx > 0 then
				self.offsetx = 0
			end
		end
	elseif y > 0 then
		local buttonheight = self:GetHeightOfButtons()
		local col = loveframes.BoundingBox(self.x, x, self.y, y, self.width, 1, buttonheight, 1)
		local visible = internals[numinternals]:GetVisible()
		if col and visible then
			local bwidth = self:GetWidthOfButtons()
			local scrollamount = y * self.mousewheelscrollamount
			local dtscrolling = self.dtscrolling
			if dtscrolling then
				local dt = love.timer.getDelta()
				self.offsetx = self.offsetx - scrollamount * dt
			else
				self.offsetx = self.offsetx - scrollamount
			end
			if ((self.offsetx + bwidth) + self.width) < self.width then
				self.offsetx = -(bwidth + 10)
			end
		end
	end

end

--[[---------------------------------------------------------
	- func: AddTab(name, object, tip, image)
	- desc: adds a new tab to the tab panel
--]]---------------------------------------------------------
function newobject:AddTab(name, object, tip, image, onopened, onclosed)

	local padding = self.padding
	local autosize = self.autosize
	local retainsize = self.retainsize
	local tabnumber = self.tabnumber
	local tabheight = self.tabheight
	local internals = self.internals
	local state = self.state
	
	object:Remove()
	object.parent = self
	object:SetState(state)
	object.staticx = 0
	object.staticy = 0
	
	if tabnumber ~= 1 then
		object.visible = false
	end
	
	local tab = loveframes.objects["tabbutton"]:new(self, name, tabnumber, tip, image, onopened, onclosed)
	
	table.insert(self.children, object)
	table.insert(self.internals, #self.internals - 1, tab)
	self.tabnumber = tabnumber + 1
	
	if autosize and not retainsize then
		object:SetSize(self.width - padding * 2, (self.height - tabheight) - padding * 2)
	end
	
	return tab
	
end

--[[---------------------------------------------------------
	- func: AddScrollButtons()
	- desc: creates scroll buttons fot the tab panel
	- note: for internal use only
--]]---------------------------------------------------------
function newobject:AddScrollButtons()

	local internals = self.internals
	local state = self.state
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			table.remove(internals, k)
		end
	end
	
	local leftbutton = loveframes.objects["scrollbutton"]:new("left")
	leftbutton.parent = self
	leftbutton:SetPos(0, 0)
	leftbutton:SetSize(15, 25)
	leftbutton:SetAlwaysUpdate(true)
	leftbutton.Update = function(object, dt)
		object.staticx = 0
		object.staticy = 0
		if self.offsetx ~= 0 then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		if object.down then
			if self.offsetx > 0 then
				self.offsetx = 0
			elseif self.offsetx ~= 0 then
				local scrollamount = self.buttonscrollamount
				local dtscrolling = self.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					self.offsetx = self.offsetx + scrollamount * dt
				else
					self.offsetx = self.offsetx + scrollamount
				end
			end
		end
	end
	
	local rightbutton = loveframes.objects["scrollbutton"]:new("right")
	rightbutton.parent = self
	rightbutton:SetPos(self.width - 15, 0)
	rightbutton:SetSize(15, 25)
	rightbutton:SetAlwaysUpdate(true)
	rightbutton.Update = function(object, dt)
		object.staticx = self.width - object.width
		object.staticy = 0
		local bwidth = self:GetWidthOfButtons()
		if (self.offsetx + bwidth) - (self.buttonareax * 2 - 1) > self.width then
			object.visible = true
		else
			object.visible = false
			object.down = false
			object.hover = false
		end
		if object.down then
			if ((self.x + self.offsetx) + bwidth) ~= (self.x + self.width) then
				local scrollamount = self.buttonscrollamount
				local dtscrolling = self.dtscrolling
				if dtscrolling then
					local dt = love.timer.getDelta()
					self.offsetx = self.offsetx - scrollamount * dt
				else
					self.offsetx = self.offsetx - scrollamount
				end
			end
		end
	end
	
	leftbutton.state = state
	rightbutton.state = state
	
	table.insert(internals, leftbutton)
	table.insert(internals, rightbutton)

end

--[[---------------------------------------------------------
	- func: GetWidthOfButtons()
	- desc: gets the total width of all of the tab buttons
--]]---------------------------------------------------------
function newobject:GetWidthOfButtons()

	local width = 0
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			width = width + v.width
		end
	end
	
	return width
	
end

--[[---------------------------------------------------------
	- func: GetHeightOfButtons()
	- desc: gets the height of one tab button
--]]---------------------------------------------------------
function newobject:GetHeightOfButtons()
	
	return self.tabheight
	
end

--[[---------------------------------------------------------
	- func: SwitchToTab(tabnumber)
	- desc: makes the specified tab the active tab
--]]---------------------------------------------------------
function newobject:SwitchToTab(tabnumber)
	
	local children = self.children
	
	for k, v in ipairs(children) do
		v.visible = false
	end
	
	self.tab = tabnumber
	self.children[tabnumber].visible = true
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetScrollButtonSize(width, height)
	- desc: sets the size of the scroll buttons
--]]---------------------------------------------------------
function newobject:SetScrollButtonSize(width, height)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "scrollbutton" then
			v:SetSize(width, height)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: sets the padding for the tab panel
--]]---------------------------------------------------------
function newobject:SetPadding(padding)

	self.padding = padding
	return self
	
end

--[[---------------------------------------------------------
	- func: SetPadding(paddint)
	- desc: gets the padding of the tab panel
--]]---------------------------------------------------------
function newobject:GetPadding()

	return self.padding
	
end

--[[---------------------------------------------------------
	- func: SetTabHeight(height)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function newobject:SetTabHeight(height)

	local autosize = self.autosize
	local padding = self.padding
	local previoustabheight = self.previoustabheight
	local children = self.children
	local internals = self.internals
	
	self.tabheight = height
	
	local tabheight = self.tabheight
	
	if tabheight ~= previoustabheight then
		for k, v in ipairs(children) do
			local retainsize = v.retainsize
			if autosize and not retainsize then
				v:SetSize(self.width - padding*2, (self.height - tabheight) - padding*2)
			end
		end
		self.previoustabheight = tabheight
	end
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			v:SetHeight(self.tabheight)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetToolTipFont(font)
	- desc: sets the height of the tab buttons
--]]---------------------------------------------------------
function newobject:SetToolTipFont(font)

	local internals = self.internals
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" and v.tooltip then
			v.tooltip:SetFont(font)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetTabNumber()
	- desc: gets the object's tab number
--]]---------------------------------------------------------
function newobject:GetTabNumber()

	return self.tab
	
end

--[[---------------------------------------------------------
	- func: RemoveTab(id)
	- desc: removes a tab from the object
--]]---------------------------------------------------------
function newobject:RemoveTab(id)

	local children = self.children
	local internals = self.internals
	local tab = children[id]
	
	if tab then
		tab:Remove()
	end
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			if v.tabnumber == id then
				v:Remove()
			end
		end
	end
	
	local tabnumber = 1
	
	for k, v in ipairs(internals) do
		if v.type == "tabbutton" then
			v.tabnumber = tabnumber
			tabnumber = tabnumber + 1
		end
	end
	
	self.tabnumber = tabnumber
	return self
	
end

--[[---------------------------------------------------------
	- func: SetButtonScrollAmount(speed)
	- desc: sets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:SetButtonScrollAmount(amount)

	self.buttonscrollamount = amount
	return self
	
end

--[[---------------------------------------------------------
	- func: GetButtonScrollAmount()
	- desc: gets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.buttonscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetMouseWheelScrollAmount(amount)
	- desc: sets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:SetMouseWheelScrollAmount(amount)

	self.mousewheelscrollamount = amount
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMouseWheelScrollAmount()
	- desc: gets the scroll amount of the mouse wheel
--]]---------------------------------------------------------
function newobject:GetButtonScrollAmount()

	return self.mousewheelscrollamount
	
end

--[[---------------------------------------------------------
	- func: SetDTScrolling(bool)
	- desc: sets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:SetDTScrolling(bool)

	self.dtscrolling = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetDTScrolling()
	- desc: gets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:GetDTScrolling()

	return self.dtscrolling
	
end

--[[---------------------------------------------------------
	- func: SetTabObject(id, object)
	- desc: sets the object of a tab
--]]---------------------------------------------------------
function newobject:SetTabObject(id, object)

	local children = self.children
	local internals = self.internals
	local tab = children[id]
	local state = self.state
	
	if tab then
		tab:Remove()
		object:Remove()
		object.parent = self
		object:SetState(state)
		object.staticx = 0
		object.staticy = 0
		children[id] = object
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetButtonAreaX(x)
	- desc: sets the x position of the object's button area
--]]---------------------------------------------------------
function newobject:SetButtonAreaX(x)

	self.buttonareax = x
	return self
	
end

--[[---------------------------------------------------------
	- func: GetButtonAreaX()
	- desc: gets the x position of the object's button area
--]]---------------------------------------------------------
function newobject:GetButtonAreaX()

	return self.buttonareax
	
end

--[[---------------------------------------------------------
	- func: SetButtonAreaWidth(width)
	- desc: sets the width of the object's button area
--]]---------------------------------------------------------
function newobject:SetButtonAreaWidth(width)

	self.buttonareawidth = width
	return self
	
end

--[[---------------------------------------------------------
	- func: GetButtonAreaWidth()
	- desc: gets the width of the object's button area
--]]---------------------------------------------------------
function newobject:GetButtonAreaWidth()

	return self.buttonareawidth
	
end

--[[---------------------------------------------------------
	- func: SetAutoButtonAreaWidth(bool)
	- desc: sets whether or not the width of the object's
			button area should be adjusted automatically
--]]---------------------------------------------------------
function newobject:SetAutoButtonAreaWidth(bool)

	self.autobuttonareawidth = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetAutoButtonAreaWidth()
	- desc: gets whether or not the width of the object's
			button area should be adjusted automatically
--]]---------------------------------------------------------
function newobject:GetAutoButtonAreaWidth()

	return self.autobuttonareawidth
	
end

---------- module end ----------
end
