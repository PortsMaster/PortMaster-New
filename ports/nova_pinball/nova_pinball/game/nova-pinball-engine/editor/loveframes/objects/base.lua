--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- base object
local newobject = loveframes.NewObject("base", "loveframes_object_base")

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the element
--]]---------------------------------------------------------
function newobject:initialize()
	self.type = "base"
	self.width, self.height = love.graphics.getDimensions()
	self.internal = true
	self.children = {}
	self.internals = {}
	
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	if loveframes.state ~= self.state then
		return
	end
	
	local width, height = love.graphics.getDimensions()
	
	if self.width ~= width then
		self.width = width
	end
	
	if self.height ~= height then
		self.height = height
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:update(dt)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:update(dt)
		end
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
	
	self:SetDrawOrder()
	
	local drawfunc = self.Draw or self.drawfunc
	if drawfunc then
		drawfunc(self)
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:draw()
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:draw()
		end
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
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:mousepressed(x, y, button)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:mousepressed(x, y, button)
		end
	end
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:mousereleased(x, y, button)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:mousereleased(x, y, button)
		end
	end
end

--[[---------------------------------------------------------
	- func: wheelmoved(x, y)
	- desc: called when the player moves a mouse wheel
--]]---------------------------------------------------------
function newobject:wheelmoved(x, y)
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:wheelmoved(x, y)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:wheelmoved(x, y)
		end
	end
end

--[[---------------------------------------------------------
	- func: keypressed(key, isrepeat)
	- desc: called when the player presses a key
--]]---------------------------------------------------------
function newobject:keypressed(key, isrepeat)
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:keypressed(key, isrepeat)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:keypressed(key, isrepeat)
		end
	end
end

--[[---------------------------------------------------------
	- func: keyreleased(key)
	- desc: called when the player releases a key
--]]---------------------------------------------------------
function newobject:keyreleased(key)
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:keyreleased(key)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:keyreleased(key)
		end
	end
end


--[[---------------------------------------------------------
	- func: textinput(text)
	- desc: called when the user inputs text
--]]---------------------------------------------------------
function newobject:textinput(text)
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	local children = self.children
	if children then
		for k, v in ipairs(children) do
			v:textinput(text)
		end
	end
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:textinput(text)
		end
	end
end


--[[---------------------------------------------------------
	- func: SetPos(x, y, center)
	- desc: sets the object's position
--]]---------------------------------------------------------
function newobject:SetPos(x, y, center)
	
	local base = loveframes.base
	local parent = self.parent
	
	if center then
		local width = self.width
		local height = self.height
		x = x - width/2
		y = y - height/2
	end
	
	if parent == base then
		self.x = x
		self.y = y
	else
		self.staticx = x
		self.staticy = y
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetX(x, center)
	- desc: sets the object's x position
--]]---------------------------------------------------------
function newobject:SetX(x, center)

	local base = loveframes.base
	local parent = self.parent
	
	if center then
		local width = self.width
		x = x - width/2
	end
	
	if parent == base then
		self.x = x
	else
		self.staticx = x
	end
	
	return self

end

--[[---------------------------------------------------------
	- func: SetY(y, center)
	- desc: sets the object's y position
--]]---------------------------------------------------------
function newobject:SetY(y, center)

	local base = loveframes.base
	local parent = self.parent
	
	if center then
		local height = self.height
		y = y - height/2
	end
	
	if parent == base then
		self.y = y
	else
		self.staticy = y
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetPos()
	- desc: gets the object's position
--]]---------------------------------------------------------
function newobject:GetPos()

	return self.x, self.y
	
end

--[[---------------------------------------------------------
	- func: GetX()
	- desc: gets the object's x position
--]]---------------------------------------------------------
function newobject:GetX()

	return self.x
	
end

--[[---------------------------------------------------------
	- func: GetY()
	- desc: gets the object's y position
--]]---------------------------------------------------------
function newobject:GetY()

	return self.y
	
end

--[[---------------------------------------------------------
	- func: GetStaticPos()
	- desc: gets the object's static position
--]]---------------------------------------------------------
function newobject:GetStaticPos()

	return self.staticx, self.staticy
	
end

--[[---------------------------------------------------------
	- func: GetStaticX()
	- desc: gets the object's static x position
--]]---------------------------------------------------------
function newobject:GetStaticX()

	return self.staticx
	
end

--[[---------------------------------------------------------
	- func: GetStaticY()
	- desc: gets the object's static y position
--]]---------------------------------------------------------
function newobject:GetStaticY()

	return self.staticy
	
end

--[[---------------------------------------------------------
	- func: Center()
	- desc: centers the object in the game window or in
			its parent if it has one
--]]---------------------------------------------------------
function newobject:Center()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		self.x = width/2 - self.width * (self.scalex or 1)/2
		self.y = height/2 - self.height * (self.scaley or 1)/2
	else
		local width = parent.width
		local height = parent.height
		self.staticx = width/2 - self.width * (self.scalex or 1)/2
		self.staticy = height/2 - self.height * (self.scaley or 1)/2
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: CenterX()
	- desc: centers the object by its x value
--]]---------------------------------------------------------
function newobject:CenterX()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local width = love.graphics.getWidth()
		self.x = width/2 - self.width * (self.scalex or 1)/2
	else
		local width = parent.width
		self.staticx = width/2 - self.width * (self.scalex or 1)/2
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: CenterY()
	- desc: centers the object by its y value
--]]---------------------------------------------------------
function newobject:CenterY()

	local base = loveframes.base
	local parent = self.parent
	
	if parent == base then
		local height = love.graphics.getHeight()
		self.y = height/2 - self.height * (self.scaley or 1)/2
	else
		local height = parent.height
		self.staticy = height/2 - self.height * (self.scaley or 1)/2
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: CenterWithinArea()
	- desc: centers the object within the given area
--]]---------------------------------------------------------
function newobject:CenterWithinArea(x, y, width, height)

	local selfwidth = self.width
	local selfheight = self.height
	
	self.x = x + width/2 - selfwidth/2
	self.y = y + height/2 - selfheight/2
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height, r1, r2)
	- desc: sets the object's size
--]]---------------------------------------------------------
function newobject:SetSize(width, height, r1, r2)

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
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width, relative)
	- desc: sets the object's width
--]]---------------------------------------------------------
function newobject:SetWidth(width, relative)

	if relative then
		self.width = self.parent.width * width
	else
		self.width = width
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height, relative)
	- desc: sets the object's height
--]]---------------------------------------------------------
function newobject:SetHeight(height, relative)

	if relative then
		self.height = self.parent.height * height
	else
		self.height = height
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetSize()
	- desc: gets the object's size
--]]---------------------------------------------------------
function newobject:GetSize()

	return self.width, self.height
	
end

--[[---------------------------------------------------------
	- func: GetWidth()
	- desc: gets the object's width
--]]---------------------------------------------------------
function newobject:GetWidth()

	return self.width
	
end

--[[---------------------------------------------------------
	- func: GetHeight()
	- desc: gets the object's height
--]]---------------------------------------------------------
function newobject:GetHeight()

	return self.height
	
end

--[[---------------------------------------------------------
	- func: SetVisible(bool)
	- desc: sets the object's visibility
--]]---------------------------------------------------------
function newobject:SetVisible(bool)

	local children = self.children
	local internals = self.internals
	
	self.visible = bool

	if children then
		for k, v in ipairs(children) do
			v:SetVisible(bool)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetVisible(bool)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetVisible()
	- desc: gets the object's visibility
--]]---------------------------------------------------------
function newobject:GetVisible()

	return self.visible
	
end

--[[---------------------------------------------------------
	- func: SetParent(parent)
	- desc: sets the object's parent
--]]---------------------------------------------------------
function newobject:SetParent(parent)

	local tparent = parent
	local cparent = self.parent
	local ptype = tparent.type
	local stype = self.type
	
	if ptype ~= "frame" and ptype ~= "panel" and ptype ~= "list" then
		return
	end
	
	self:Remove()
	self.parent = tparent
	self:SetState(tparent.state)
	
	table.insert(tparent.children, self)
	return self

end

--[[---------------------------------------------------------
	- func: GetParent()
	- desc: gets the object's parent
--]]---------------------------------------------------------
function newobject:GetParent()

	local parent = self.parent
	return parent
	
end

--[[---------------------------------------------------------
	- func: Remove()
	- desc: removes the object
--]]---------------------------------------------------------
function newobject:Remove()
	
	local pinternals = self.parent.internals
	local pchildren = self.parent.children
	
	if pinternals then
		for k, v in ipairs(pinternals) do
			if v == self then
				table.remove(pinternals, k)
			end
		end
	end
	
	if pchildren then
		for k, v in ipairs(pchildren) do
			if v == self then
				table.remove(pchildren, k)
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetClickBounds(x, y, width, height)
	- desc: sets a boundary box for the object's collision
			detection
--]]---------------------------------------------------------
function newobject:SetClickBounds(x, y, width, height)

	local internals = self.internals
	local children = self.children
	
	self.clickbounds = {x = x, y = y, width = width, height = height}
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetClickBounds(x, y, width, height)
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			v:SetClickBounds(x, y, width, height)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetClickBounds()
	- desc: gets the boundary box for the object's collision
			detection
--]]---------------------------------------------------------
function newobject:GetClickBounds()

	return self.clickbounds
	
end

--[[---------------------------------------------------------
	- func: RemoveClickBounds()
	- desc: removes the collision detection boundary for the 
			object 
--]]---------------------------------------------------------
function newobject:RemoveClickBounds()

	local internals = self.internals
	local children = self.children
	
	self.clickbounds = nil
	
	if internals then
		for k, v in ipairs(internals) do
			v:RemoveClickBounds()
		end
	end
	
	if children then
		for k, v in ipairs(children) do
			v:RemoveClickBounds()
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: InClickBounds()
	- desc: checks if the mouse is inside the object's
			collision detection boundaries
--]]---------------------------------------------------------
function newobject:InClickBounds()

	local x, y = love.mouse.getPosition()
	local bounds = self.clickbounds
	
	if bounds then
		local col = loveframes.BoundingBox(x, bounds.x, y, bounds.y, 1, bounds.width, 1, bounds.height)
		return col
	else
		return false
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetBaseParent(object, t)
	- desc: finds the object's base parent
--]]---------------------------------------------------------
function newobject:GetBaseParent(t)
	
	local t = t or {}
	local base = loveframes.base
	local parent = self.parent
	
	if parent ~= base then
		table.insert(t, parent)
		parent:GetBaseParent(t)
	end
	
	return t[#t]
	
end

--[[---------------------------------------------------------
	- func: CheckHover()
	- desc: checks to see if the object should be in a
			hover state
--]]---------------------------------------------------------
function newobject:CheckHover()
	
	local x = self.x
	local y = self.y
	local width = self.width
	local height = self.height
	local mx, my = love.mouse.getPosition()
	local selfcol = loveframes.BoundingBox(mx, x, my, y, 1, width, 1, height)
	local collisioncount = loveframes.collisioncount
	local curstate = loveframes.state
	local state = self.state
	local visible = self.visible
	local type = self.type
	local hoverobject = loveframes.hoverobject
	
	-- check if the mouse is colliding with the object
	if state == curstate and visible then
		local collide = self.collide
		if selfcol and collide then
			loveframes.collisioncount = collisioncount + 1
			local clickbounds = self.clickbounds
			if clickbounds then
				local cx = clickbounds.x
				local cy = clickbounds.y
				local cwidth = clickbounds.width
				local cheight = clickbounds.height
				local clickcol = loveframes.BoundingBox(mx, cx, my, cy, 1, cwidth, 1, cheight)
				if clickcol then
					table.insert(loveframes.collisions, self)
				end
			else
				table.insert(loveframes.collisions, self)
			end
		end
	end
	
	-- check if the object is being hovered
	if hoverobject == self and type ~= "base" then
		self.hover = true
	else
		self.hover = false
	end
	
	local hover = self.hover
	local calledmousefunc = self.calledmousefunc
	
	-- check for mouse enter and exit events
	if hover then
		loveframes.hover = true
		if not calledmousefunc then
			local on_mouse_enter = self.OnMouseEnter
			if on_mouse_enter then
				on_mouse_enter(self)
				self.calledmousefunc = true
			else
				self.calledmousefunc = true
			end
		end
	else
		if calledmousefunc then
			local on_mouse_exit = self.OnMouseExit
			if on_mouse_exit then
				on_mouse_exit(self)
				self.calledmousefunc = false
			else
				self.calledmousefunc = false
			end
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetHover()
	- desc: return if the object is in a hover state or not
--]]---------------------------------------------------------
function newobject:GetHover()

	return self.hover

end

--[[---------------------------------------------------------
	- func: GetChildren()
	- desc: returns the object's children
--]]---------------------------------------------------------
function newobject:GetChildren()

	local children = self.children
	
	if children then
		return children
	end
	
end

--[[---------------------------------------------------------
	- func: GetInternals()
	- desc: returns the object's internals
--]]---------------------------------------------------------
function newobject:GetInternals()

	local internals = self.internals
	
	if internals then
		return internals
	end
	
end


--[[---------------------------------------------------------
	- func: IsTopList()
	- desc: returns true if the object is the top most list
			object or false if not
--]]---------------------------------------------------------
function newobject:IsTopList()

	local cols = loveframes.GetCollisions()
	local children = self:GetChildren()
	local order = self.draworder
	local top = true
	local found = false
	
	local function IsChild(object)
		local parents = object:GetParents()
		for k, v in ipairs(parents) do
			if v == self then
				return true
			end
		end
		return false
	end
	
	for k, v in ipairs(cols) do
		if v == self then
			found = true
		else
			if v.draworder > order then
				if IsChild(v) ~= true then
					top = false
					break
				end
			end
		end
	end
	
	if found == false then
		top = false
	end
	
	return top
	
end

--[[---------------------------------------------------------
	- func: IsTopChild()
	- desc: returns true if the object is the top most child
			in its parent's children table or false if not
--]]---------------------------------------------------------
function newobject:IsTopChild()

	local children = self.parent.children
	local num = #children
	
	if children[num] == self then
		return true
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: MoveToTop()
	- desc: moves the object to the top of its parent's
			children table
--]]---------------------------------------------------------
function newobject:MoveToTop()

	local pchildren = self.parent.children
	local pinternals = self.parent.internals
	
	local internal = false
	
	if pinternals then
		for k, v in ipairs(pinternals) do
			if v == self then
				internal = true
			end
		end
	end
	
	self:Remove()
	
	if internal then
		table.insert(pinternals, self)
	else
		table.insert(pchildren, self)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetDrawFunc()
	- desc: sets the objects skin based draw function
--]]---------------------------------------------------------
function newobject:SetDrawFunc()
	local skins = loveframes.skins
	local activeskin  = skins[loveframes.config["ACTIVESKIN"]]
	--local defaultskin = skins[loveframes.config["DEFAULTSKIN"]]
	
	local funcname = self.type
	self.drawfunc = activeskin[funcname] -- or defaultskin[funcname]
	
	funcname = self.type .. "_over"
	self.drawoverfunc = activeskin[funcname] -- or defaultskin[funcname]
end

--[[---------------------------------------------------------
	- func: SetSkin(name)
	- desc: sets the object's skin
--]]---------------------------------------------------------
function newobject:SetSkin(name)

	local children = self.children
	local internals = self.internals
	
	self.skin = name
	
	local selfskin = loveframes.skins[name]
	
	local funcname = self.type

	self.drawfunc = selfskin[funcname]
	self.drawoverfunc = selfskin[funcname.."_over"]
	
	if children then
		for k, v in ipairs(children) do
			v:SetSkin(name)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetSkin(name)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetSkin()
	- desc: gets the object's skin
--]]---------------------------------------------------------
function newobject:GetSkin()
	
	local skins = loveframes.skins
	local skinindex = loveframes.config["ACTIVESKIN"]
	local defaultskin = loveframes.config["DEFAULTSKIN"]
	local selfskin = self.skin
	local skin = skins[selfskin] or skins[skinindex]
	
	return skin
	
end

--[[---------------------------------------------------------
	- func: GetSkinName()
	- desc: gets the name of the object's skin
--]]---------------------------------------------------------
function newobject:GetSkinName()

	return self.skin
	
end

--[[---------------------------------------------------------
	- func: SetAlwaysUpdate(bool)
	- desc: sets the object's skin
--]]---------------------------------------------------------
function newobject:SetAlwaysUpdate(bool)

	self.alwaysupdate = bool
	return self

end

--[[---------------------------------------------------------
	- func: GetAlwaysUpdate()
	- desc: gets whether or not the object will always update
--]]---------------------------------------------------------
function newobject:GetAlwaysUpdate()

	return self.alwaysupdate

end

--[[---------------------------------------------------------
	- func: SetRetainSize(bool)
	- desc: sets whether or not the object should retain its
			size when another object tries to resize it
--]]---------------------------------------------------------
function newobject:SetRetainSize(bool)

	self.retainsize = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetRetainSize()
	- desc: gets whether or not the object should retain its
			size when another object tries to resize it
--]]---------------------------------------------------------
function newobject:GetRetainSize()
	
	return self.retainsize
	
end

--[[---------------------------------------------------------
	- func: IsActive()
	- desc: gets whether or not the object is active within
			its parent's child table
--]]---------------------------------------------------------
function newobject:IsActive()

	local parent = self.parent
	local pchildren = parent.children
	local valid = false
	
	for k, v in ipairs(pchildren) do
		if v == self then
			valid = true
		end
	end
	
	return valid
	
end

--[[---------------------------------------------------------
	- func: GetParents()
	- desc: returns a table of the object's parents and its
			sub-parents
--]]---------------------------------------------------------
function newobject:GetParents()
	
	local function GetParents(object, t)
		local t = t or {}
		local type = object.type
		local parent = object.parent
		if type ~= "base" then
			table.insert(t, parent)
			GetParents(parent, t)
		end
		return t
	end
	
	local parents = GetParents(self)
	return parents
	
end

--[[---------------------------------------------------------
	- func: IsTopInternal()
	- desc: returns true if the object is the top most 
			internal in its parent's internals table or 
			false if not
--]]---------------------------------------------------------
function newobject:IsTopInternal()

	local parent = self.parent
	local internals = parent.internals
	local topitem = internals[#internals]
	
	if topitem ~= self then
		return false
	else
		return true
	end
	
end

--[[---------------------------------------------------------
	- func: IsInternal()
	- desc: returns true if the object is internal or 
			false if not
--]]---------------------------------------------------------
function newobject:IsInternal()

	return self.internal
	
end

--[[---------------------------------------------------------
	- func: GetType()
	- desc: gets the type of the object
--]]---------------------------------------------------------
function newobject:GetType()

	return self.type

end

--[[---------------------------------------------------------
	- func: SetDrawOrder()
	- desc: sets the object's draw order
--]]---------------------------------------------------------
function newobject:SetDrawOrder()

	loveframes.drawcount = loveframes.drawcount + 1
	self.draworder = loveframes.drawcount
	return self

end

--[[---------------------------------------------------------
	- func: GetDrawOrder()
	- desc: sets the object's draw order
--]]---------------------------------------------------------
function newobject:GetDrawOrder()

	return self.draworder
	
end

--[[---------------------------------------------------------
	- func: SetProperty(name, value)
	- desc: sets a property on the object
--]]---------------------------------------------------------
function newobject:SetProperty(name, value)

	self[name] = value
	return self
	
end

--[[---------------------------------------------------------
	- func: GetProperty(name)
	- desc: gets the value of an object's property
--]]---------------------------------------------------------
function newobject:GetProperty(name)

	return self[name]
	
end

--[[---------------------------------------------------------
	- func: IsInList()
	- desc: checks to see if an object is in a list
--]]---------------------------------------------------------
function newobject:IsInList()
	
	local parents = self:GetParents()
	
	for k, v in ipairs(parents) do
		if v.type == "list" then
			return true, v
		end
	end
	
	return false, false
	
end

--[[---------------------------------------------------------
	- func: SetState(name)
	- desc: sets the object's state
--]]---------------------------------------------------------
function newobject:SetState(name)

	local children = self.children
	local internals = self.internals
	
	self.state = name
	
	if children then
		for k, v in ipairs(children) do
			v:SetState(name)
		end
	end
	
	if internals then
		for k, v in ipairs(internals) do
			v:SetState(name)
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetState()
	- desc: gets the object's state
--]]---------------------------------------------------------
function newobject:GetState()

	return self.state
	
end

---------- module end ----------
end
