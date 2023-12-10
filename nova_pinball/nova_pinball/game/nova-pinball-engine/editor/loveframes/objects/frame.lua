--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- frame object
local newobject = loveframes.NewObject("frame", "loveframes_object_frame", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "frame"
	self.name = "Frame"
	self.width = 300
	self.height = 150
	self.clickx = 0
	self.clicky = 0
	self.dockx = 0
	self.docky = 0
	self.dockzonesize = 10
	self.resizex = 0
	self.resizey = 0
	self.resizexmod = 0
	self.resizeymod = 0
	self.resizewidth = 0
	self.resizeheight = 0
	self.minwidth = 100
	self.minheight = 30
	self.maxwidth = 500
	self.maxheight = 500
	self.internal = false
	self.draggable = true
	self.screenlocked = false
	self.parentlocked = false
	self.dragging = false
	self.modal = false
	self.modalbackground = false
	self.showclose = true
	self.dockedtop = false
	self.dockedbottom = false
	self.dockedleft = false
	self.dockedright = false
	self.topdockobject = false
	self.bottomdockobject = false
	self.leftdockobject = false
	self.rightdockobject = false
	self.dockable = false
	self.resizing = false
	self.canresize = false
	self.alwaysontop = false
	self.internals = {}
	self.children = {}
	self.icon = nil
	self.OnClose = nil
	self.OnDock = nil
	self.OnResize = nil
	
	-- create docking zones
	self.dockzones = {
		top = {x = 0, y = 0, width = 0, height = 0},
		bottom = {x = 0, y = 0, width = 0, height = 0},
		left = {x = 0, y = 0, width = 0, height = 0},
		right = {x = 0, y = 0, width = 0, height = 0}
	}
	
	-- create the close button for the frame
	local close = loveframes.objects["closebutton"]:new()
	close.parent = self
	close.OnClick = function(x, y, object)
		local onclose = object.parent.OnClose
		if onclose then
			local ret = onclose(object.parent)

			if ret ~= false then
				object.parent:Remove()
			end
		else
			object.parent:Remove()
		end
	end
	
	table.insert(self.internals, close)
	
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
	
	local mx, my = love.mouse.getPosition()
	local showclose = self.showclose
	local close = self.internals[1]
	local dragging = self.dragging
	local screenlocked = self.screenlocked
	local parentlocked = self.parentlocked
	local modal = self.modal
	local base = loveframes.base
	local basechildren = base.children
	local numbasechildren = #basechildren
	local draworder = self.draworder
	local dockedtop = self.dockedtop
	local dockedbottom = self.dockedbottom
	local dockedleft = self.dockedleft
	local dockedright = self.dockedright
	local dockable = self.dockable
	local dockzonesize = self.dockzonesize
	local children = self.children
	local internals = self.internals
	local parent = self.parent
	local update = self.Update
	
	self:CheckHover()
	
	-- update dockzones
	self.dockzones.top = {x = self.x, y = self.y - dockzonesize, width = self.width, height = dockzonesize}
	self.dockzones.bottom = {x = self.x, y = self.y + self.height, width = self.width, height = dockzonesize}
	self.dockzones.left = {x = self.x - dockzonesize, y = self.y, width = dockzonesize, height = self.height}
	self.dockzones.right = {x = self.x + self.width, y = self.y, width = dockzonesize, height = self.height}
	
	-- dragging check
	if dragging then
		if parent == base then
			local width = self.width
			local height = self.height
			if not dockedtop and not dockedbottom then
				self.y = my - self.clicky
			end
			if not dockedleft and not dockedright then
				self.x = mx - self.clickx
			end
			local basechildren = loveframes.base.children
			-- check for frames to dock with
			if dockable then
				local ondock = self.OnDock
				for k, v in ipairs(basechildren) do
					if v.type == "frame" then
						local topcol = loveframes.RectangleCollisionCheck(self.dockzones.bottom, v.dockzones.top)
						local botcol = loveframes.RectangleCollisionCheck(self.dockzones.top, v.dockzones.bottom)
						local leftcol = loveframes.RectangleCollisionCheck(self.dockzones.right, v.dockzones.left)
						local rightcol = loveframes.RectangleCollisionCheck(self.dockzones.left, v.dockzones.right)
						local candockobject = v.dockable
						if candockobject then
							if topcol and not dockedtop then
								self.y = v.y - self.height
								self.docky = my
								self.dockedtop = true
								self.topdockobject = v
								-- FIXME: object?
								-- if ondock then ondock(object, v) end
							elseif botcol and not dockedbottom then
								self.y = v.y + v.height
								self.docky = my
								self.dockedbottom = true
								self.bottomdockobject = v
								-- if ondock then ondock(object, v) end
							elseif leftcol and not dockedleft then
								self.x = v.x - self.width
								self.dockx = mx
								self.dockedleft = true
								self.leftdockobject = v
								-- if ondock then ondock(object, v) end
							elseif rightcol and not dockedright then
								self.x = v.x + v.width
								self.dockx = mx
								self.dockedright = true
								self.rightdockobject = v
								-- if ondock then ondock(object, v) end
							end
						end
					end
				end
			end
			local dockx = self.dockx
			local docky = self.docky
			local x = self.x
			local y = self.y
			-- check to see if the frame should be undocked
			if dockedtop then
				local topdockobject = self.topdockobject
				local tdox = topdockobject.x
				local tdowidth = topdockobject.width
				if my > (docky + 20) or my < (docky - 20) or (x + width) < tdox or x > (tdox + tdowidth) then
					self.dockedtop = false
					self.docky = 0
				end
			end
			if dockedbottom then
				local bottomdockobject = self.bottomdockobject
				local bdox = bottomdockobject.x
				local bdowidth = bottomdockobject.width
				if my > (docky + 20) or my < (docky - 20) or (x + width) < bdox or x > (bdox + bdowidth) then
					self.dockedbottom = false
					self.docky = 0
				end
			end
			if dockedleft then
				local leftdockobject = self.leftdockobject
				local ldoy = leftdockobject.y
				local ldoheight = leftdockobject.height
				if mx > (dockx + 20) or mx < (dockx - 20) or (y + height) < ldoy or y > (ldoy + ldoheight) then
					self.dockedleft = false
					self.dockx = 0
				end
			end
			if dockedright then
				local rightdockobject = self.rightdockobject
				local rdoy = rightdockobject.y
				local rdoheight = rightdockobject.height
				if mx > (dockx + 20) or mx < (dockx - 20) or (y + height) < rdoy or y > (rdoy + rdoheight) then
					self.dockedright = false
					self.dockx = 0
				end
			end
		else
			self.staticx = mx - self.clickx
			self.staticy = my - self.clicky
		end
	elseif self.resizing then
		local width = self.width
		local height = self.height
		if self.resize_mode == "top_left" then
			local new_width = self.resizewidth + (self.resizex - mx)
			local new_height = self.resizeheight + (self.resizey - my)
			if new_width >= self.minwidth and new_width <= self.maxwidth then
				self.width = new_width
				self.x = mx - self.resizexmod
			end
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
				self.y = my - self.resizeymod
			end
		elseif self.resize_mode == "bottom_right" then
			local new_width = (mx - self.x) + self.resizexmod
			local new_height = (my - self.y) + self.resizeymod
			if new_width >= self.minwidth  and new_width <= self.maxwidth then
				self.width = new_width
			end
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
			end
		elseif self.resize_mode == "top_right" then
			local new_width = (mx - self.x) + self.resizexmod
			local new_height = self.resizeheight + (self.resizey - my)
			if new_width >= self.minwidth and new_width <= self.maxwidth then
				self.width = new_width
			end
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
				self.y = my - self.resizeymod
			end
		elseif self.resize_mode == "bottom_left" then
			local new_width = self.resizewidth + (self.resizex - mx)
			local new_height = (my - self.y) + self.resizeymod
			if new_width >= self.minwidth and new_width <= self.maxwidth then
				self.width = new_width
				self.x = mx - self.resizexmod
			end
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
			end
		elseif self.resize_mode == "top" then
			local new_height = self.resizeheight + (self.resizey - my)
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
				self.y = my - self.resizeymod
			end
		elseif self.resize_mode == "bottom" then
			local new_height = (my - self.y) + self.resizeymod
			if new_height >= self.minheight and new_height <= self.maxheight then
				self.height = new_height
			end
		elseif self.resize_mode == "left" then
			local new_width = self.resizewidth + (self.resizex - mx)
			if new_width >= self.minwidth and new_width <= self.maxwidth then
				self.width = new_width
				self.x = mx - self.resizexmod
			end
		elseif self.resize_mode == "right" then
			local new_width = (mx - self.x) + self.resizexmod
			if new_width >= self.minwidth and new_width <= self.maxwidth then
				self.width = new_width
			end
		end
		if self.width ~= width or self.height ~= height then
			local onresize = self.OnResize
			if onresize then
				onresize(self, self.width, self.height)
			end
		end
	end
	
	-- if screenlocked then keep within screen
	if screenlocked then
		local width = self.width
		local height = self.height
		local screenwidth = love.graphics.getWidth()
		local screenheight = love.graphics.getHeight()
		local x = self.x
		local y = self.y
		if x < 0 then
			self.x = 0
		end
		if x + width > screenwidth then
			self.x = screenwidth - width
		end
		if y < 0 then
			self.y = 0
		end
		if y + height > screenheight then
			self.y = screenheight - height
		end
	end
	
	-- keep the frame within its parent's boundaries if parentlocked
	if parentlocked then
		local width = self.width
		local height = self.height
		local parentwidth = self.parent.width
		local parentheight = self.parent.height
		local staticx = self.staticx
		local staticy = self.staticy
		if staticx < 0 then
			self.staticx = 0
		end
		if staticx + width > parentwidth then
			self.staticx = parentwidth - width
		end
		if staticy < 0 then
			self.staticy = 0
		end
		if staticy + height > parentheight then
			self.staticy = parentheight - height
		end
	end
	
	if parent == base and self.alwaysontop and not self:IsTopChild() then
		self:MakeTop()
	end
	
	if modal then
		local tip = false
		local key = 0
		for k, v in ipairs(basechildren) do
			if v.type == "tooltip" and v.show then
				tip = v
				key = k
			end
		end
		if tip then
			self:Remove()
			self.modalbackground:Remove()
			table.insert(basechildren, key - 2, self.modalbackground)
			table.insert(basechildren, key - 1, self)
		end
		if self.modalbackground.draworder > self.draworder then
			self:MakeTop()
		end
		if self.modalbackground.state ~= self.state then
			self.modalbackground:SetState(self.state)
		end
	end
	
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	for k, v in ipairs(internals) do
		v:update(dt)
	end
	
	for k, v in ipairs(children) do
		v:update(dt)
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
	
	local width = self.width
	local height = self.height
	local internals = self.internals
	local children = self.children
	local dragging = self.dragging
	local parent = self.parent
	local base = loveframes.base
	
	if button == 1 then
		-- initiate dragging if not currently dragging
		if not dragging and self.hover and self.draggable  then
			local topcol
			if self.canresize then
				topcol = loveframes.BoundingBox(x, self.x + 2, y, self.y + 2, 1, self.width - 4, 1, 21)
			else
				topcol = loveframes.BoundingBox(x, self.x, y, self.y, 1, self.width, 1, 25)
			end
			if topcol then
				if parent == base then
					self.clickx = x - self.x
					self.clicky = y - self.y
				else
					self.clickx = x - self.staticx
					self.clicky = y - self.staticy
				end
				self.dragging = true
				loveframes.dragobject = self
			end
		end
		if not self.resizing and self.canresize and loveframes.hoverobject == self then
			if loveframes.BoundingBox(self.x, x, self.y, y, 5, 1, 5, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "top_left"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x then
					self.resizexmod = x - self.x
				end
				if y ~= self.y then
					self.resizeymod = y - self.y
				end
			elseif loveframes.BoundingBox(self.x + self.width - 5, x, self.y + self.height - 5, y, 5, 1, 5, 1) then
				self.resizing = true
				self.resize_mode = "bottom_right"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x + self.width then
					self.resizexmod = (self.x + self.width) - x
				end
				if y ~= self.y + self.height then
					self.resizeymod = (self.y + self.height) - y
				end
			elseif loveframes.BoundingBox(self.x + self.width - 5, x, self.y, y, 5, 1, 5, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "top_right"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x + self.width then
					self.resizexmod = (self.x + self.width) - x
				end
				if y ~= self.y then
					self.resizeymod = y - self.y
				end
			elseif loveframes.BoundingBox(self.x, x, self.y + self.height - 5, y, 5, 1, 5, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "bottom_left"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x then
					self.resizexmod = x - self.x
				end
				if y ~= self.y + self.height then
					self.resizeymod = (self.y + self.height) - y
				end
			elseif loveframes.BoundingBox(self.x + 5, x, self.y, y, self.width - 10, 1, 2, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "top"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if y ~= self.y then
					self.resizeymod = y - self.y
				end
			elseif loveframes.BoundingBox(self.x + 5, x, self.y + self.height - 2, y, self.width - 10, 1, 2, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "bottom"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if y ~= self.y then
					self.resizeymod = (self.y + self.height) - y 
				end
			elseif loveframes.BoundingBox(self.x, x, self.y + 5, y, 2, 1, self.height - 10, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "left"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x then
					self.resizexmod = x - self.x
				end
			elseif loveframes.BoundingBox(self.x + self.width - 2, x, self.y + 5, y, 2, 1, self.height - 10, 1) then
				self.resizing = true
				self.dragging = false
				loveframes.dragobject = false
				self.resize_mode = "right"
				self.resizex = x
				self.resizey = y
				self.resizewidth = self.width
				self.resizeheight = self.height
				loveframes.resizeobject = self
				if x ~= self.x + self.width then
					self.resizexmod = (self.x + self.width) - x
				end
			end
		end
		if self.hover and button == 1 then
			self:MakeTop()
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
	
	self.dragging = false
	loveframes.dragobject = false
	
	if self.resizing then
		self.resizex = 0
		self.resizey = 0
		self.resizexmod = 0
		self.resizeymod = 0
		self.resizewidth = 0
		self.resizeheight = 0
		self.resizing = false
		loveframes.resizeobject = false
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(children) do
		v:mousereleased(x, y, button)
	end
	
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

--[[---------------------------------------------------------
	- func: SetDraggable(true/false)
	- desc: sets whether the object can be dragged or not
--]]---------------------------------------------------------
function newobject:SetDraggable(bool)

	self.draggable = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetDraggable()
	- desc: gets whether the object can be dragged ot not
--]]---------------------------------------------------------
function newobject:GetDraggable()

	return self.draggable
	
end


--[[---------------------------------------------------------
	- func: SetScreenLocked(bool)
	- desc: sets whether the object can be moved passed the
			boundaries of the window or not
--]]---------------------------------------------------------
function newobject:SetScreenLocked(bool)

	self.screenlocked = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetScreenLocked()
	- desc: gets whether the object can be moved passed the
			boundaries of window or not
--]]---------------------------------------------------------
function newobject:GetScreenLocked()

	return self.screenlocked
	
end

--[[---------------------------------------------------------
	- func: ShowCloseButton(bool)
	- desc: sets whether the object's close button should 
			be drawn
--]]---------------------------------------------------------
function newobject:ShowCloseButton(bool)

	local close = self.internals[1]

	close.visible = bool
	self.showclose = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: MakeTop()
	- desc: makes the object the top object in the drawing
			order
--]]---------------------------------------------------------
function newobject:MakeTop()
	
	local key = 0
	local base = loveframes.base
	local basechildren = base.children
	local numbasechildren = #basechildren
	
	-- check to see if the object's parent is not the base object
	if self.parent ~= base then
		local baseparent = self:GetBaseParent()
		if baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		return self
	end
	
	-- check to see if the object is the only child of the base object
	if numbasechildren == 1 then
		return self
	end
	
	-- check to see if the object is already at the top
	if basechildren[numbasechildren] == self then
		return self
	end
	
	-- make this the top object
	for k, v in ipairs(basechildren) do
		if v == self then
			table.remove(basechildren, k)
			table.insert(basechildren, self)
			key = k
			break
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetModal(bool)
	- desc: sets whether or not the object is in a modal
			state
--]]---------------------------------------------------------
function newobject:SetModal(bool)

	local modalobject = loveframes.modalobject
	local mbackground = self.modalbackground
	local parent = self.parent
	local base = loveframes.base
	
	if parent ~= base then
		return
	end
	
	self.modal = bool
	
	if bool then
		if modalobject then
			modalobject:SetModal(false)
		end
		loveframes.modalobject = self
		if not mbackground then
			self.modalbackground = loveframes.objects["modalbackground"]:new(self)
			self.modal = true
		end
	else
		if modalobject == self then
			loveframes.modalobject = false
			if mbackground then
				self.modalbackground:Remove()
				self.modalbackground = false
				self.modal = false
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetModal()
	- desc: gets whether or not the object is in a modal
			state
--]]---------------------------------------------------------
function newobject:GetModal()

	return self.modal
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: set's whether the object is visible or not
--]]---------------------------------------------------------
function newobject:SetVisible(bool)

	local children = self.children
	local internals = self.internals
	local closebutton = internals[1]
	
	self.visible = bool
	
	for k, v in ipairs(children) do
		v:SetVisible(bool)
	end

	if self.showclose then
		closebutton.visible = bool
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetParentLocked(bool)
	- desc: sets whether the object can be moved passed the
			boundaries of its parent or not
--]]---------------------------------------------------------
function newobject:SetParentLocked(bool)

	self.parentlocked = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetParentLocked(bool)
	- desc: gets whether the object can be moved passed the
			boundaries of its parent or not
--]]---------------------------------------------------------
function newobject:GetParentLocked()

	return self.parentlocked
	
end

--[[---------------------------------------------------------
	- func: SetIcon(icon)
	- desc: sets the object's icon
--]]---------------------------------------------------------
function newobject:SetIcon(icon)
	
	if type(icon) == "string" then
		self.icon = love.graphics.newImage(icon)
		self.icon:setFilter("nearest", "nearest")
	else
		self.icon = icon
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetIcon()
	- desc: gets the object's icon
--]]---------------------------------------------------------
function newobject:GetIcon()

	local icon = self.icon
	
	if icon then
		return icon
	end
	
	return false
	
end

--[[---------------------------------------------------------
	- func: SetDockable(dockable)
	- desc: sets whether or not the object can dock onto
			another object of its type or be docked 
			by another object of its type
--]]---------------------------------------------------------
function newobject:SetDockable(dockable)

	self.dockable = dockable
	return self

end

--[[---------------------------------------------------------
	- func: GetDockable()
	- desc: gets whether or not the object can dock onto
			another object of its type or be docked 
			by another object of its type
--]]---------------------------------------------------------
function newobject:GetDockable()

	return self.dockable
	
end

--[[---------------------------------------------------------
	- func: SetDockZoneSize(size)
	- desc: sets the size of the object's docking zone
--]]---------------------------------------------------------
function newobject:SetDockZoneSize(size)

	self.dockzonesize = size
	return self
	
end

--[[---------------------------------------------------------
	- func: GetDockZoneSize(size)
	- desc: gets the size of the object's docking zone
--]]---------------------------------------------------------
function newobject:GetDockZoneSize()

	return self.dockzonesize

end

--[[---------------------------------------------------------
	- func: SetResizable(bool)
	- desc: sets whether or not the object can be resized
--]]---------------------------------------------------------
function newobject:SetResizable(bool)

	self.canresize = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetResizable()
	- desc: gets whether or not the object can be resized
--]]---------------------------------------------------------
function newobject:GetResizable()

	return self.canresize
	
end

--[[---------------------------------------------------------
	- func: SetMinWidth(width)
	- desc: sets the object's minimum width
--]]---------------------------------------------------------
function newobject:SetMinWidth(width)

	self.minwidth = width
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMinWidth()
	- desc: gets the object's minimum width
--]]---------------------------------------------------------
function newobject:GetMinWidth()

	return self.minwidth
	
end

--[[---------------------------------------------------------
	- func: SetMaxWidth(width)
	- desc: sets the object's maximum width
--]]---------------------------------------------------------
function newobject:SetMaxWidth(width)

	self.maxwidth = width
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMaxWidth()
	- desc: gets the object's maximum width
--]]---------------------------------------------------------
function newobject:GetMaxWidth()

	return self.maxwidth
	
end

--[[---------------------------------------------------------
	- func: SetMinHeight(height)
	- desc: sets the object's minimum height
--]]---------------------------------------------------------
function newobject:SetMinHeight(height)

	self.minheight = height
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMinHeight()
	- desc: gets the object's minimum height
--]]---------------------------------------------------------
function newobject:GetMinHeight()

	return self.minheight
	
end

--[[---------------------------------------------------------
	- func: SetMaxHeight(height)
	- desc: sets the object's maximum height
--]]---------------------------------------------------------
function newobject:SetMaxHeight(height)

	self.maxheight = height
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMaxHeight()
	- desc: gets the object's maximum height
--]]---------------------------------------------------------
function newobject:GetMaxHeight()

	return self.maxheight
	
end

--[[---------------------------------------------------------
	- func: SetMinSize(width, height)
	- desc: sets the object's minimum size
--]]---------------------------------------------------------
function newobject:SetMinSize(width, height)

	self.minwidth = width
	self.minheight = height
	return self

end

--[[---------------------------------------------------------
	- func: GetMinSize()
	- desc: gets the object's minimum size
--]]---------------------------------------------------------
function newobject:GetMinSize()

	return self.minwidth, self.maxwidth
	
end

--[[---------------------------------------------------------
	- func: SetMaxSize(width, height)
	- desc: sets the object's maximum size
--]]---------------------------------------------------------
function newobject:SetMaxSize(width, height)

	self.maxwidth = width
	self.maxheight = height
	return self

end

--[[---------------------------------------------------------
	- func: GetMaxSize()
	- desc: gets the object's maximum size
--]]---------------------------------------------------------
function newobject:GetMaxSize()

	return self.maxwidth, self.maxheight
	
end

--[[---------------------------------------------------------
	- func: SetAlwaysOnTop(bool)
	- desc: sets whether or not a frame should always be
			drawn on top of other objects
--]]---------------------------------------------------------
function newobject:SetAlwaysOnTop(bool)

	self.alwaysontop = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetAlwaysOnTop()
	- desc: gets whether or not a frame should always be
			drawn on top of other objects
--]]---------------------------------------------------------
function newobject:GetAlwaysOnTop()

	return self.alwaysontop
	
end

---------- module end ----------
end
