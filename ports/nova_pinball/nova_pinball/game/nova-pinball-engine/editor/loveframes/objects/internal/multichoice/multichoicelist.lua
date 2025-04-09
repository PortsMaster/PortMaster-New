--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- multichoicelist class
local newobject = loveframes.NewObject("multichoicelist", "loveframes_object_multichoicelist", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(object)
	
	self.type = "multichoicelist"
	self.parent = loveframes.base
	self.list = object
	self.x = object.x
	self.y = object.y + self.list.height
	self.width = self.list.width
	self.height = 0
	self.clickx = 0
	self.clicky = 0
	self.padding = self.list.listpadding
	self.spacing = self.list.listspacing
	self.buttonscrollamount = object.buttonscrollamount
	self.mousewheelscrollamount = object.mousewheelscrollamount
	self.offsety = 0
	self.offsetx = 0
	self.extrawidth = 0
	self.extraheight = 0
	self.canremove = false
	self.dtscrolling = self.list.dtscrolling
	self.internal = true
	self.vbar = false
	self.children = {}
	self.internals = {}
	
	for k, v in ipairs(object.choices) do
		local row = loveframes.objects["multichoicerow"]:new()
		row:SetText(v)
		self:AddItem(row)
	end
	
	table.insert(loveframes.base.internals, self)
	
	-- apply template properties to the object
	loveframes.ApplyTemplatesToObject(self)
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
	
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local x, y = love.mouse.getPosition()
	local selfcol = loveframes.BoundingBox(x, self.x, y, self.y, 1, self.width, 1, self.height)
	local parent = self.parent
	local base = loveframes.base
	local upadte = self.Update
	local internals = self.internals
	local children = self.children
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
		
	if self.x < 0 then
		self.x = 0
	end
	
	if self.x + self.width > width then
		self.x = width - self.width
	end
	
	if self.y < 0 then
		self.y = 0
	end
	
	if self.y + self.height > height then
		self.y = height - self.height
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
		v:SetClickBounds(self.x, self.y, self.width, self.height)
		v.y = (v.parent.y + v.staticy) - self.offsety
		v.x = (v.parent.x + v.staticx) - self.offsetx
	end
	
	if upadte then
		upadte(self, dt)
	end
	
end

--[[---------------------------------------------------------
	- func: draw()
	- desc: draws the object
--]]---------------------------------------------------------
--[[
function newobject:draw()
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	self:SetDrawOrder()
	
	local drawfunc = self.Draw or self.drawfunc
	if drawfunc then
		drawfunc(self)
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:draw()
		end
	end
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			local col = loveframes.BoundingBox(self.x, v.x, self.y, v.y, self.width, v.width, self.height, v.height)
			if col then
				v:draw()
			end
		end
	end
	
	love.graphics.setStencilTest()
	
	drawfunc = self.DrawOver or self.drawoverfunc
	if drawfunc then
		drawfunc(self)
	end
	
end
--]]
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
	
	local selfcol = loveframes.BoundingBox(x, self.x, y, self.y, 1, self.width, 1, self.height)
	local internals = self.internals
	local children = self.children
	
	if not selfcol and self.canremove and button == 1 then
		self:Close()
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousepressed(x, y, button)
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
	local children = self.children
	
	self.canremove = true
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: wheelmoved(x, y)
	- desc: called when the player moves a mouse wheel
--]]---------------------------------------------------------
function newobject:wheelmoved(x, y)

	local toplist = self:IsTopList()
	local internals = self.internals
	local scrollamount = self.mousewheelscrollamount

	if self.vbar and toplist then
		local bar = internals[1].internals[1].internals[1]
		local dtscrolling = self.dtscrolling
		if dtscrolling then
			local dt = love.timer.getDelta()
			bar:Scroll(-y * scrollamount * dt)
		else
			bar:Scroll(-y * scrollamount)
		end
	end

end

--[[---------------------------------------------------------
	- func: AddItem(object)
	- desc: adds an item to the object
--]]---------------------------------------------------------
function newobject:AddItem(object)
	
	if object.type ~= "multichoicerow" then
		return
	end
	
	object.parent = self
	table.insert(self.children, object)
	
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: RemoveItem(object)
	- desc: removes an item from the object
--]]---------------------------------------------------------
function newobject:RemoveItem(object)

	local children = self.children
	
	for k, v in ipairs(children) do
		if v == object then
			table.remove(children, k)
		end
	end
	
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: CalculateSize()
	- desc: calculates the size of the object's children
--]]---------------------------------------------------------
function newobject:CalculateSize()

	self.height = self.padding
	
	if self.list.listheight then
		self.height = self.list.listheight
	else
		for k, v in ipairs(self.children) do
			self.height = self.height + (v.height + self.spacing)
		end
	end

	if self.height > love.graphics.getHeight() then
		self.height = love.graphics.getHeight()
	end
	
	local numitems = #self.children
	local height = self.height
	local padding = self.padding
	local spacing = self.spacing
	local itemheight = self.padding
	local vbar = self.vbar
	local children = self.children
	
	for k, v in ipairs(children) do
		itemheight = itemheight + v.height + spacing
	end
		
	self.itemheight = (itemheight - spacing) + padding
		
	if self.itemheight > height then
		self.extraheight = self.itemheight - height
		if not vbar then
			local scroll = loveframes.objects["scrollbody"]:new(self, "vertical")
			table.insert(self.internals, scroll)
			self.vbar = true
		end
	else
		if vbar then
			self.internals[1]:Remove()
			self.vbar = false
			self.offsety = 0
		end
	end
	
end

--[[---------------------------------------------------------
	- func: RedoLayout()
	- desc: used to redo the layour of the object
--]]---------------------------------------------------------
function newobject:RedoLayout()

	local children = self.children
	local padding = self.padding
	local spacing = self.spacing
	local starty = padding
	local vbar = self.vbar
	
	if #children > 0 then
		for k, v in ipairs(children) do
			v.staticx = padding
			v.staticy = starty
			if vbar then
				v.width = (self.width - self.internals[1].width) - padding * 2
				self.internals[1].staticx = self.width - self.internals[1].width
				self.internals[1].height = self.height
			else
				v.width = self.width - padding * 2
			end
			starty = starty + v.height
			starty = starty + spacing
		end
	end
	
end

--[[---------------------------------------------------------
	- func: SetPadding(amount)
	- desc: sets the object's padding
--]]---------------------------------------------------------
function newobject:SetPadding(amount)

	self.padding = amount
	
end

--[[---------------------------------------------------------
	- func: SetSpacing(amount)
	- desc: sets the object's spacing
--]]---------------------------------------------------------
function newobject:SetSpacing(amount)

	self.spacing = amount
	
end

--[[---------------------------------------------------------
	- func: Close()
	- desc: closes the object
--]]---------------------------------------------------------
function newobject:Close()

	self:Remove()
	self.list.haslist = false
	
end

---------- module end ----------
end
