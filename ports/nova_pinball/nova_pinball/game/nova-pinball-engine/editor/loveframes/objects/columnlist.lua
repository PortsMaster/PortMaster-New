--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- columnlist object
local newobject = loveframes.NewObject("columnlist", "loveframes_object_columnlist", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: intializes the element
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "columnlist"
	self.width = 300
	self.height = 100
	self.defaultcolumnwidth = 100
	self.columnheight = 16
	self.buttonscrollamount = 200
	self.mousewheelscrollamount = 1500
	self.autoscroll = false
	self.dtscrolling = true
	self.internal = false
	self.selectionenabled = true
	self.multiselect = false
	self.startadjustment = false
	self.canresizecolumns = true
	self.children = {}
	self.internals = {}
	self.resizecolumn = nil
	self.OnRowClicked = nil
	self.OnRowRightClicked = nil
	self.OnRowSelected = nil
	self.OnScroll = nil

	local list = loveframes.objects["columnlistarea"]:new(self)
	table.insert(self.internals, list)
	
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
	
	local parent = self.parent
	local base = loveframes.base
	local children = self.children
	local internals = self.internals
	local update = self.Update
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	for k, v in ipairs(children) do
		v.columnid = k
		v:update(dt)
	end
	
	self.startadjustment = false
	
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
	
	local vbody = self.internals[1]:GetVerticalScrollBody()
	local hbody = self.internals[1]:GetHorizontalScrollBody()
	local width = self.width
	local height = self.height
	
	if vbody then
		width = width - vbody.width
	end
	
	if hbody then
		height = height - hbody.height
	end
	
	local stencilfunc = function()
		love.graphics.rectangle("fill", self.x, self.y, width, height)
	end
	
	-- set the object's draw order
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
			v:draw()
		end
	end
	
	local drawfunc = self.DrawOver or self.drawoverfunc
	if drawfunc then
		drawfunc(self)
	end
	love.graphics.setStencilTest()

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
	
	local hover = self.hover
	local children  = self.children
	local internals = self.internals
	
	if hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
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
	
	local children = self.children
	local internals = self.internals
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: PositionColumns()
	- desc: positions the object's columns
--]]---------------------------------------------------------
function newobject:PositionColumns()
	
	local x = 0
	
	for k, v in ipairs(self.children) do
		v:SetPos(x, 0)
		x = x + v.width
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: AddColumn(name)
	- desc: gives the object a new column with the specified
			name
--]]---------------------------------------------------------
function newobject:AddColumn(name)

	local internals = self.internals
	local list = internals[1]
	local width = self.width
	local height = self.height
	
	loveframes.objects["columnlistheader"]:new(name, self)
	self:PositionColumns()
	
	list:SetSize(width, height)
	list:SetPos(0, 0)
	
	return self
	
end

--[[---------------------------------------------------------
	- func: AddRow(...)
	- desc: adds a row of data to the object's list
--]]---------------------------------------------------------
function newobject:AddRow(...)

	local arg = {...}
	local internals = self.internals
	local list = internals[1]
	
	list:AddRow(arg)
	return self
	
end

--[[---------------------------------------------------------
	- func: Getchildrenize()
	- desc: gets the size of the object's children
--]]---------------------------------------------------------
function newobject:GetColumnSize()

	local children = self.children
	local numchildren = #self.children
	
	if numchildren > 0 then
		local column    = self.children[1]
		local colwidth  = column.width
		local colheight = column.height
		return colwidth, colheight
	else
		return 0, 0
	end
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height, r1, r2)
	- desc: sets the object's size
--]]---------------------------------------------------------
function newobject:SetSize(width, height, r1, r2)
	
	local internals = self.internals
	local list = internals[1]
	
	if r1 then
		self.width = self.parent.width * width
	else
		self.width = width
	end
	
	if r2 then
		self.height = self.parent.height * height
	else
		self.height = height
	end
	
	self:PositionColumns()
	
	list:SetSize(width, height)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width, relative)
	- desc: sets the object's width
--]]---------------------------------------------------------
function newobject:SetWidth(width, relative)
	
	local internals = self.internals
	local list = internals[1]
	
	if relative then
		self.width = self.parent.width * width
	else
		self.width = width
	end
	
	self:PositionColumns()
	
	list:SetSize(width)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height, relative)
	- desc: sets the object's height
--]]---------------------------------------------------------
function newobject:SetHeight(height, relative)
	
	local internals = self.internals
	local list = internals[1]
	
	if relative then
		self.height = self.parent.height * height
	else
		self.height = height
	end
	
	self:PositionColumns()
	
	list:SetSize(height)
	list:SetPos(0, 0)
	list:CalculateSize()
	list:RedoLayout()
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetMaxColorIndex(num)
	- desc: sets the object's max color index for
			alternating row colors
--]]---------------------------------------------------------
function newobject:SetMaxColorIndex(num)

	local internals = self.internals
	local list = internals[1]
	
	list.colorindexmax = num
	return self
	
end

--[[---------------------------------------------------------
	- func: Clear()
	- desc: removes all items from the object's list
--]]---------------------------------------------------------
function newobject:Clear()

	local internals = self.internals
	local list = internals[1]
	
	list:Clear()
	return self
	
end

--[[---------------------------------------------------------
	- func: SetAutoScroll(bool)
	- desc: sets whether or not the list's scrollbar should
			auto scroll to the bottom when a new object is
			added to the list
--]]---------------------------------------------------------
function newobject:SetAutoScroll(bool)

	local internals = self.internals
	local list = internals[1]
	local scrollbar = list:GetScrollBar()
	
	self.autoscroll = bool
	
	if list then
		if scrollbar then
			scrollbar.autoscroll = bool
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetButtonScrollAmount(speed)
	- desc: sets the scroll amount of the object's scrollbar
			buttons
--]]---------------------------------------------------------
function newobject:SetButtonScrollAmount(amount)

	self.buttonscrollamount = amount
	self.internals[1].buttonscrollamount = amount
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
	self.internals[1].mousewheelscrollamount = amount
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
	- func: SetColumnHeight(height)
	- desc: sets the height of the object's columns
--]]---------------------------------------------------------
function newobject:SetColumnHeight(height)

	local children = self.children
	local internals = self.internals
	local list = internals[1]
	
	self.columnheight = height
	
	for k, v in ipairs(children) do
		v:SetHeight(height)
	end
	
	list:CalculateSize()
	list:RedoLayout()
	return self
	
end

--[[---------------------------------------------------------
	- func: SetDTScrolling(bool)
	- desc: sets whether or not the object should use delta
			time when scrolling
--]]---------------------------------------------------------
function newobject:SetDTScrolling(bool)

	self.dtscrolling = bool
	self.internals[1].dtscrolling = bool
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
	- func: SelectRow(row, ctrl)
	- desc: selects the specfied row in the object's list
			of rows
--]]---------------------------------------------------------
function newobject:SelectRow(row, ctrl)

	local selectionenabled = self.selectionenabled
	
	if not selectionenabled then
		return
	end
	
	local list = self.internals[1]
	local children = list.children
	local multiselect = self.multiselect
	local onrowselected = self.OnRowSelected
	
	for k, v in ipairs(children) do
		if v == row then
			if v.selected and ctrl then
				v.selected = false
			else
				v.selected = true
				if onrowselected then
					onrowselected(self, row, row:GetColumnData())
				end
			end
		elseif v ~= row then
			if not (multiselect and ctrl) then
				v.selected = false
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: DeselectRow(row)
	- desc: deselects the specfied row in the object's list
			of rows
--]]---------------------------------------------------------
function newobject:DeselectRow(row)

	row.selected = false
	return self
	
end

--[[---------------------------------------------------------
	- func: GetSelectedRows()
	- desc: gets the object's selected rows
--]]---------------------------------------------------------
function newobject:GetSelectedRows()
	
	local rows = {}
	local list = self.internals[1]
	local children = list.children
	
	for k, v in ipairs(children) do
		if v.selected then
			table.insert(rows, v)
		end
	end
	
	return rows
	
end

--[[---------------------------------------------------------
	- func: SetSelectionEnabled(bool)
	- desc: sets whether or not the object's rows can be
			selected
--]]---------------------------------------------------------
function newobject:SetSelectionEnabled(bool)

	self.selectionenabled = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetSelectionEnabled()
	- desc: gets whether or not the object's rows can be
			selected
--]]---------------------------------------------------------
function newobject:GetSelectionEnabled()

	return self.selectionenabled
	
end

--[[---------------------------------------------------------
	- func: SetMultiselectEnabled(bool)
	- desc: sets whether or not the object can have more
			than one row selected
--]]---------------------------------------------------------
function newobject:SetMultiselectEnabled(bool)

	self.multiselect = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMultiselectEnabled()
	- desc: gets whether or not the object can have more
			than one row selected
--]]---------------------------------------------------------
function newobject:GetMultiselectEnabled()

	return self.multiselect
	
end

--[[---------------------------------------------------------
	- func: RemoveColumn(id)
	- desc: removes a column
--]]---------------------------------------------------------
function newobject:RemoveColumn(id)

	local children = self.children
	
	for k, v in ipairs(children) do
		if k == id then
			v:Remove()
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetColumnName(id, name)
	- desc: sets a column's name
--]]---------------------------------------------------------
function newobject:SetColumnName(id, name)

	local children = self.children
	
	for k, v in ipairs(children) do
		if k == id then
			v.name = name
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetColumnName(id)
	- desc: gets a column's name
--]]---------------------------------------------------------
function newobject:GetColumnName(id)

	local children = self.children
	
	for k, v in ipairs(children) do
		if k == id then
			return v.name
		end
	end
	
	return false
	
end

--[[---------------------------------------------------------
	- func: SizeToChildren(max)
	- desc: sizes the object to match the combined height
			of its children
	- note: Credit to retupmoc258, the original author of
			this method. This version has a few slight
			modifications.
--]]---------------------------------------------------------
function newobject:SizeToChildren(max)
	
	local oldheight = self.height
	local list = self.internals[1]
	local listchildren = list.children
	local children = self.children
	local width = self.width
	local buf = children[1].height
	local h = listchildren[1].height
	local c = #listchildren
	local height = buf + h*c
	
	if max then
		height = math.min(max, oldheight) 
	end
	
	self:SetSize(width, height)
	self:PositionColumns()
	return self
	
end

--[[---------------------------------------------------------
	- func: RemoveRow(id)
	- desc: removes a row from the object's list
--]]---------------------------------------------------------
function newobject:RemoveRow(id)

	local list = self.internals[1]
	local listchildren = list.children
	local row = listchildren[id]
	
	if row then
		row:Remove()
	end
	
	list:CalculateSize()
	list:RedoLayout()
	return self

end

--[[---------------------------------------------------------
	- func: SetCellText(text, rowid, columnid)
	- desc: sets a cell's text
--]]---------------------------------------------------------
function newobject:SetCellText(text, rowid, columnid)
	
	local list = self.internals[1]
	local listchildren = list.children
	local row = listchildren[rowid]
	
	if row and row.columndata[columnid]then
		row.columndata[columnid] = text
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetCellText(rowid, columnid)
	- desc: gets a cell's text
--]]---------------------------------------------------------
function newobject:GetCellText(rowid, columnid)
	
	local row = self.internals[1].children[rowid]
	
	if row and row.columndata[columnid] then
		return row.columndata[columnid]
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: SetRowColumnData(rowid, columndata)
	- desc: sets the columndata of the specified row
--]]---------------------------------------------------------
function newobject:SetRowColumnData(rowid, columndata)

	local list = self.internals[1]
	local listchildren = list.children
	local row = listchildren[rowid]
	
	if row then
		for k, v in ipairs(columndata) do
			row.columndata[k] = tostring(v)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetTotalColumnWidth()
	- desc: gets the combined width of the object's columns
--]]---------------------------------------------------------
function newobject:GetTotalColumnWidth()

	local width = 0
	
	for k, v in ipairs(self.children) do
		width = width + v.width
	end
	
	return width
	
end

--[[---------------------------------------------------------
	- func: SetColumnWidth(id, width)
	- desc: sets the width of the specified column
--]]---------------------------------------------------------
function newobject:SetColumnWidth(id, width)

	local column = self.children[id]
	if column then
		column.width = width
		local x = 0
		for k, v in ipairs(self.children) do
			v:SetPos(x)
			x = x + v.width
		end
		self.internals[1]:CalculateSize()
		self.internals[1]:RedoLayout()
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetColumnWidth(id)
	- desc: gets the width of the specified column
--]]---------------------------------------------------------
function newobject:GetColumnWidth(id)

	local column = self.children[id]
	if column then
		return column.width
	end
	
	return false
	
end

--[[---------------------------------------------------------
	- func: ResizeColumns()
	- desc: resizes the object's columns to fit within the
	        width of the object's list area
--]]---------------------------------------------------------
function newobject:ResizeColumns()

	local children = self.children
	local width = 0
	local vbody = self.internals[1]:GetVerticalScrollBody()
	
	if vbody then
		width = (self:GetWidth() - vbody:GetWidth())/#children
	else
		width = self:GetWidth()/#children
	end
	
	for k, v in ipairs(children) do
		v:SetWidth(width)
		self:PositionColumns()
		self.internals[1]:CalculateSize()
		self.internals[1]:RedoLayout()
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetDefaultColumnWidth(width)
	- desc: sets the object's default column width
--]]---------------------------------------------------------
function newobject:SetDefaultColumnWidth(width)

	self.defaultcolumnwidth = width
	return self
	
end

--[[---------------------------------------------------------
	- func: GetDefaultColumnWidth()
	- desc: gets the object's default column width
--]]---------------------------------------------------------
function newobject:GetDefaultColumnWidth()

	return self.defaultcolumnwidth
	
end

--[[---------------------------------------------------------
	- func: SetColumnResizeEnabled(bool)
	- desc: sets whether or not the object's columns can
			be resized
--]]---------------------------------------------------------
function newobject:SetColumnResizeEnabled(bool)

	self.canresizecolumns = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetColumnResizeEnabled()
	- desc: gets whether or not the object's columns can
			be resized
--]]---------------------------------------------------------
function newobject:GetColumnResizeEnabled()

	return self.canresizecolumns
	
end

--[[---------------------------------------------------------
	- func: SizeColumnToData(columnid)
	- desc: sizes a column to the width of its largest data
			string
--]]---------------------------------------------------------
function newobject:SizeColumnToData(columnid)

	local column = self.children[columnid]
	local list = self.internals[1]
	local largest = 0
	
	for k, v in ipairs(list.children) do
		local width = v:GetFont():getWidth(self:GetCellText(k, columnid))
		if width > largest then
			largest = width + v.textx
		end
	end
	
	if largest <= 0 then
		largest = 10
	end
	
	self:SetColumnWidth(columnid, largest)
	return self
	
end

--[[---------------------------------------------------------
	- func: SetColumnOrder(curid, newid)
	- desc: sets the order of the specified column
--]]---------------------------------------------------------
function newobject:SetColumnOrder(curid, newid)

	local column = self.children[curid]
	local totalcolumns = #self.children
	
	if column and totalcolumns > 1 and newid <= totalcolumns and newid >= 1 then
		column:Remove()
		table.insert(self.children, newid, column)
		self:PositionColumns()
	end
	
	return self
	
end

---------- module end ----------
end
