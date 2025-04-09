--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- columnlistarea class
local newobject = loveframes.NewObject("columnlistarea", "loveframes_object_columnlistarea", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function newobject:initialize(parent)
	
	self.type = "columnlistarea"
	self.display = "vertical"
	self.parent = parent
	self.width = 80
	self.height = 25
	self.clickx = 0
	self.clicky = 0
	self.offsety = 0
	self.offsetx = 0
	self.extrawidth = 0
	self.extraheight = 0
	self.rowcolorindex = 1
	self.rowcolorindexmax = 2
	self.buttonscrollamount = parent.buttonscrollamount
	self.mousewheelscrollamount = parent.mousewheelscrollamount
	self.vbar = false
	self.hbar = false
	self.dtscrolling = parent.dtscrolling
	self.internal = true
	self.internals = {}
	self.children = {}

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
	
	local cwidth, cheight = self.parent:GetColumnSize()
	local parent = self.parent
	local update = self.Update
	local internals = self.internals
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= loveframes.base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	for k, v in ipairs(self.children) do
		local col = loveframes.BoundingBox(self.x, v.x, self.y, v.y, self.width, v.width, self.height, v.height)
		if col then
			v:update(dt)
		end
		v:SetClickBounds(self.x, self.y, self.width, self.height)
		v.y = (v.parent.y + v.staticy) - self.offsety + cheight
		v.x = (v.parent.x + v.staticx) - self.offsetx
	end
	
	for k, v in ipairs(self.internals) do
		v:update(dt)
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
	local swidth = width
	local sheight = height
	
	if self.vbar then
		swidth = swidth - self:GetVerticalScrollBody():GetWidth()
	end
	
	if self.hbar then
		sheight = sheight - self:GetHorizontalScrollBody():GetHeight()
	end
	
	local stencilfunc = function() love.graphics.rectangle("fill", x, y, swidth, sheight) end
	
	self:SetDrawOrder()
	
	local drawfunc = self.Draw or self.drawfunc
	if drawfunc then
		drawfunc(self)
	end
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
	local children = self.children
	if children then
		for k, v in ipairs(self.children) do
			local col = loveframes.BoundingBox(self.x, v.x, self.y, v.y, width, v.width, height, v.height)
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
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(self.internals) do
			v:draw()
		end
	end
end

--[[---------------------------------------------------------
	- func: mousepressed(x, y, button)
	- desc: called when the player presses a mouse button
--]]---------------------------------------------------------
function newobject:mousepressed(x, y, button)

	local scrollamount = self.mousewheelscrollamount
	
	if self.hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
	
	for k, v in ipairs(self.internals) do
		v:mousepressed(x, y, button)
	end
	
	for k, v in ipairs(self.children) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	local internals = self.internals
	local children  = self.children
	
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

	local scrollamount = self.mousewheelscrollamount

	-- FIXME: button is nil
	-- if self.hover and button == 1 then
	if self.hover then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end

	local bar = false
	if self.vbar and self.hbar then
		bar = self:GetVerticalScrollBody():GetScrollBar()
	elseif self.vbar and not self.hbar then
		bar = self:GetVerticalScrollBody():GetScrollBar()
	elseif not self.vbar and self.hbar then
		bar = self:GetHorizontalScrollBody():GetScrollBar()
	end

	if self:IsTopList() and bar then
		if self.dtscrolling then
			local dt = love.timer.getDelta()
			bar:Scroll(-y * scrollamount * dt)
		else
			bar:Scroll(-y * scrollamount)
		end
	end

end

--[[---------------------------------------------------------
	- func: CalculateSize()
	- desc: calculates the size of the object's children
--]]---------------------------------------------------------
function newobject:CalculateSize()
	
	local height = self.height
	local width = self.width
	local parent = self.parent
	local itemheight = parent.columnheight  
	
	for k, v in ipairs(self.children) do
		itemheight = itemheight + v.height
	end
	
	self.itemheight = itemheight
	self.itemwidth = parent:GetTotalColumnWidth()
	
	local hbarheight = 0
	local hbody = self:GetHorizontalScrollBody()
	if hbody then
		hbarheight = hbody.height
	end
	
	if self.itemheight > (height - hbarheight) then
		if hbody then
			self.itemheight = self.itemheight + hbarheight
		end
		self.extraheight = self.itemheight - height
		if not self.vbar then
			local newbar = loveframes.objects["scrollbody"]:new(self, "vertical")
			table.insert(self.internals, newbar)
			self.vbar = true
			newbar:GetScrollBar().autoscroll = parent.autoscroll
			self.itemwidth = self.itemwidth + newbar.width
			self.extrawidth = self.itemwidth - width
		end
	else
		if self.vbar then
			self:GetVerticalScrollBody():Remove()
			self.vbar = false
			self.offsety = 0
		end
	end
	
	local vbarwidth = 0
	local vbody = self:GetVerticalScrollBody()
	if vbody then
		vbarwidth = vbody.width
	end
	
	if self.itemwidth > (width - vbarwidth) then
		if vbody then
			self.itemwidth = self.itemwidth + vbarwidth
		end
		self.extrawidth = self.itemwidth - width
		if not self.hbar then
			local newbar = loveframes.objects["scrollbody"]:new(self, "horizontal")
			table.insert(self.internals, newbar)
			self.hbar = true
			self.itemheight = self.itemheight + newbar.height
			self.extraheight = self.itemheight - height
		end
	else
		if self.hbar then
			local hbar = self:GetHorizontalScrollBody()
			hbar:Remove()
			self.itemheight = self.itemheight - hbar.height
			self.extraheight = self.itemheight - height
			self.hbar = false
			self.offsetx = 0
		end
	end
	
end

--[[---------------------------------------------------------
	- func: RedoLayout()
	- desc: used to redo the layour of the object
--]]---------------------------------------------------------
function newobject:RedoLayout()
	
	local starty = 0
	self.rowcolorindex = 1
	
	for k, v in ipairs(self.children) do
		v:SetWidth(self.parent:GetTotalColumnWidth())
		v.staticx = 0
		v.staticy = starty
		if self.vbar then
			local vbody = self:GetVerticalScrollBody()
			vbody.staticx = self.width - vbody.width
			if self.hbar then
				vbody.height = self.height - self:GetHorizontalScrollBody().height
			else
				vbody.height = self.height
			end
		end
		if self.hbar then
			local hbody = self:GetHorizontalScrollBody()
			hbody.staticy = self.height - hbody.height
			if self.vbar then
				hbody.width = self.width - self:GetVerticalScrollBody().width
			else
				hbody.width = self.width
			end
		end
		starty = starty + v.height
		v.lastheight = v.height
		v.colorindex = self.rowcolorindex
		if self.rowcolorindex == self.rowcolorindexmax then
			self.rowcolorindex = 1
		else
			self.rowcolorindex = self.rowcolorindex + 1
		end
	end
	
end

--[[---------------------------------------------------------
	- func: AddRow(data)
	- desc: adds a row to the object
--]]---------------------------------------------------------
function newobject:AddRow(data)

	local colorindex = self.rowcolorindex
	
	if colorindex == self.rowcolorindexmax then
		self.rowcolorindex = 1
	else
		self.rowcolorindex = colorindex + 1
	end
	
	table.insert(self.children, loveframes.objects["columnlistrow"]:new(self, data))
	self:CalculateSize()
	self:RedoLayout()
	self.parent:PositionColumns()
	
end

--[[---------------------------------------------------------
	- func: GetScrollBar()
	- desc: gets the object's scroll bar
--]]---------------------------------------------------------
function newobject:GetScrollBar()
	
	if self.bar then
		return self.internals[1].internals[1].internals[1]
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: Sort()
	- desc: sorts the object's children
--]]---------------------------------------------------------
function newobject:Sort(column, desc)
	
	local children = self.children
	self.rowcolorindex = 1
	
	table.sort(children, function(a, b)
		if desc then
            return (tostring(a.columndata[column]) or a.columndata[column]) < (tostring(b.columndata[column]) or b.columndata[column])
        else
			return (tostring(a.columndata[column]) or a.columndata[column]) > (tostring(b.columndata[column]) or b.columndata[column])
		end
	end)
	
	for k, v in ipairs(children) do
		local colorindex = self.rowcolorindex
		v.colorindex = colorindex
		if colorindex == self.rowcolorindexmax then
			self.rowcolorindex = 1
		else
			self.rowcolorindex = colorindex + 1
		end
	end
	
	self:CalculateSize()
	self:RedoLayout()
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: removes all items from the object's list
--]]---------------------------------------------------------
function newobject:Clear()

	self.children = {}
	self:CalculateSize()
	self:RedoLayout()
	self.parent:PositionColumns()
	self.rowcolorindex = 1
	
end

--[[---------------------------------------------------------
	- func: GetVerticalScrollBody()
	- desc: gets the object's vertical scroll body
--]]---------------------------------------------------------
function newobject:GetVerticalScrollBody()

	for k, v in ipairs(self.internals) do
		if v.bartype == "vertical" then
			return v
		end
	end
	
	return false
	
end

--[[---------------------------------------------------------
	- func: GetHorizontalScrollBody()
	- desc: gets the object's horizontal scroll body
--]]---------------------------------------------------------
function newobject:GetHorizontalScrollBody()

	for k, v in ipairs(self.internals) do
		if v.bartype == "horizontal" then
			return v
		end
	end
	
	return false
	
end

---------- module end ----------
end
