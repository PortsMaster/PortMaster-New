--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- columnlistheader class
local newobject = loveframes.NewObject("columnlistheader", "loveframes_object_columnlistheader", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function newobject:initialize(name, parent)
	
	self.type = "columnlistheader"
	self.parent = parent
	self.name = name
	self.state = parent.state
	self.width = parent.defaultcolumnwidth
	self.height = parent.columnheight
	self.columnid = 0
	self.hover = false
	self.down = false
	self.clickable = true
	self.enabled = true
	self.descending = true
	self.resizebox = nil
	self.internal = true

	table.insert(parent.children, self)
		
	local key = 0
	
	for k, v in ipairs(parent.children) do
		if v == self then
			key = k
		end
	end
	
	self.OnClick = function(object)
		local descending = object.descending
		local parent = object.parent
		local pinternals = parent.internals
		local list = pinternals[1]
		if descending then
			object.descending = false
		else
			object.descending = true
		end
		list:Sort(key, object.descending)
	end
	
	-- apply template properties to the object
	loveframes.ApplyTemplatesToObject(self)
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	if not self.visible then
		if not self.alwaysupdate then
			return
		end
	end
	
	local update = self.Update
	local parent = self.parent
	local list = parent.internals[1]
	local vbody = list:GetVerticalScrollBody()
	local width = list.width
	if vbody then
		width = width - vbody.width
	end
	
	self.clickbounds = {x = list.x, y = list.y, width = width, height = list.height}
	self:CheckHover()
	
	if not self.hover then
		self.down = false
	else
		if loveframes.downobject == self then
			self.down = true
		end
	end
	
	-- move to parent if there is a parent
	if parent ~= loveframes.base then
		self.x = (parent.x + self.staticx) - parent.internals[1].offsetx
		self.y = parent.y + self.staticy
	end
	
	local resizecolumn = parent.resizecolumn
	
	if resizecolumn and resizecolumn == self then
		local x, y = love.mouse.getPosition()
		local start = false
		self.width = x - self.x
		if self.width < 20 then
			self.width = 20
		end
		parent.startadjustment = true
		parent.internals[1]:CalculateSize()
		parent.internals[1]:RedoLayout()
	elseif resizecolumn and parent.startadjustment then
		local header = parent.children[self.columnid - 1]
		self.staticx = header.staticx + header.width
	end
	
	self.resizebox = {x = self.x + (self.width - 2), y = self.y, width = 4, height = self.height}
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)
	
	if not self.parent.resizecolumn and self.parent.canresizecolumns then
		local box = self.resizebox
		local col = loveframes.BoundingBox(x, box.x, y, box.y, 1, box.width, 1, box.height)
		if col then
			self.resizing = true
			self.parent.resizecolumn = self
		end
	end
	
	if self.hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" and button == 1 then
			baseparent:MakeTop()
		end
		self.down = true
		loveframes.downobject = self
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	if not self.visible then
		return
	end
	
	local hover = self.hover
	local down = self.down
	local clickable = self.clickable
	local enabled = self.enabled
	local onclick = self.OnClick
	
	if hover and down and clickable and button == 1 then
		if enabled then
			onclick(self, x, y)
		end
	end
	
	local resizecolumn = self.parent.resizecolumn
	if resizecolumn and resizecolumn == self then
		self.parent.resizecolumn = nil
	end
	
	self.down = false
	
end

--[[---------------------------------------------------------
	- func: SetName(name)
	- desc: sets the object's name
--]]---------------------------------------------------------
function newobject:SetName(name)

	self.name = name
	return self
	
end

--[[---------------------------------------------------------
	- func: GetName()
	- desc: gets the object's name
--]]---------------------------------------------------------
function newobject:GetName()

	return self.name
	
end

---------- module end ----------
end
