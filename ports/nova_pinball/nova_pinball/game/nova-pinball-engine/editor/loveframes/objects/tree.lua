--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- tree object
local newobject = loveframes.NewObject("tree", "loveframes_object_tree", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()
	
	self.type = "tree"
	self.width = 200
	self.height = 200
	self.offsetx = 0
	self.offsety = 0
	self.itemwidth = 0
	self.itemheight = 0
	self.extrawidth = 0
	self.extraheight = 0
	self.buttonscrollamount = 0.10
	self.vbar = false
	self.hbar = false
	self.internal = false
	self.selectednode = false
	self.OnSelectNode = nil
	self.children = {}
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
	
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	self.itemwidth = 0
	self.itemheight = 0
	
	for k, v in ipairs(self.children) do
		v.x = (v.parent.x + v.staticx) - self.offsetx
		v.y = (self.y + self.itemheight) - self.offsety
		if v.width > self.itemwidth then
			self.itemwidth = v.width
		end
		self.itemheight = self.itemheight + v.height
		v:update(dt)
	end
	
	if self.vbar then
		self.itemwidth = self.itemwidth + 16 + 5
	end
	
	self.extrawidth = self.itemwidth - self.width
	self.extraheight = self.itemheight - self.height
	
	if self.itemheight > self.height then
		if not self.vbar then
			local scrollbody = loveframes.objects["scrollbody"]:new(self, "vertical")
			table.insert(self.internals, scrollbody)
			self.vbar = true
			if self.hbar then
				local vbody = self:GetVerticalScrollBody()
				local vbodyheight = vbody:GetHeight() - 15
				local hbody = self:GetHorizontalScrollBody()
				local hbodywidth = hbody:GetWidth() - 15
				vbody:SetHeight(vbodyheight)
				hbody:SetWidth(hbodywidth)
			end
		end
	else
		if self.vbar then
			self:GetVerticalScrollBody():Remove()
			self.vbar = false
			self.offsety = 0
			if self.hbar then
				local hbody = self:GetHorizontalScrollBody()
				local hbodywidth = hbody:GetWidth() - 15
				hbody:SetWidth(hbodywidth)
			end
		end
	end
	
	if self.itemwidth > self.width then
		if not self.hbar then
			local scrollbody = loveframes.objects["scrollbody"]:new(self, "horizontal")
			table.insert(self.internals, scrollbody)
			self.hbar = true
			if self.vbar then
				local vbody = self:GetVerticalScrollBody()
				local hbody = self:GetHorizontalScrollBody()
				vbody:SetHeight(vbody:GetHeight() - 15)
				hbody:SetWidth(hbody:GetWidth() - 15)
			end
		end
	else
		if self.hbar then
			self:GetHorizontalScrollBody():Remove()
			self.hbar = false
			self.offsetx = 0
			if self.vbar then
				local vbody = self:GetVerticalScrollBody()
				if vbody then
					vbody:SetHeight(vbody:GetHeight() + 15)
				end
			end
		end
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
	
	local stencilfunc
	
	if self.vbar and not self.hbar then
		stencilfunc = function() love.graphics.rectangle("fill", self.x, self.y, self.width - 16, self.height) end
	elseif self.hbar and not self.vbar then
		stencilfunc = function() love.graphics.rectangle("fill", self.x, self.y, self.width, self.height - 16) end
	elseif self.vbar and self.hbar then
		stencilfunc = function() love.graphics.rectangle("fill", self.x, self.y, self.width - 16, self.height - 16) end
	end
	
	self:SetDrawOrder()
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
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
	
	love.graphics.setStencilTest()
	
	local internals = self.internals
	if internals then
		for k, v in ipairs(internals) do
			v:draw()
		end
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
	
	local state = loveframes.state
	local selfstate = self.state
	
	if state ~= selfstate then
		return
	end
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	for k, v in ipairs(self.internals) do
		v:mousereleased(x, y, button)
	end
	
	for k, v in ipairs(self.children) do
		v:mousereleased(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: AddNode(text)
	- desc: adds a node to the object
--]]---------------------------------------------------------
function newobject:AddNode(text)

	local node = loveframes.objects["treenode"]:new()
	node.parent = self
	node.tree = self
	node.text = text
	node.staticx = 0
	node.staticy = self.itemheight
	table.insert(self.children, node)
	return node
	
end

--[[---------------------------------------------------------
	- func: RemoveNode(id)
	- desc: removes a node from the object
--]]---------------------------------------------------------
function newobject:RemoveNode(id)
	
	for k, v in ipairs(self.children) do
		if k == id then
			v:Remove()
			break
		end
	end
	
end

--[[---------------------------------------------------------
	- func: GetVerticalScrollBody()
	- desc: gets the object's vertical scroll body
--]]---------------------------------------------------------
function newobject:GetVerticalScrollBody()

	local vbar = self.vbar
	local internals = self.internals
	local item = false
	
	if vbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "vertical" then
				item = v
			end
		end
	end
	
	return item

end

--[[---------------------------------------------------------
	- func: GetHorizontalScrollBody()
	- desc: gets the object's horizontal scroll body
--]]---------------------------------------------------------
function newobject:GetHorizontalScrollBody()

	local hbar = self.hbar
	local internals = self.internals
	local item = false
	
	if hbar then
		for k, v in ipairs(internals) do
			if v.type == "scrollbody" and v.bartype == "horizontal" then
				item = v
			end
		end
	end
	
	return item

end

---------- module end ----------
end
