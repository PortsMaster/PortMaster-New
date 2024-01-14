--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- linenumberspanel class
local newobject = loveframes.NewObject("linenumberspanel", "loveframes_object_linenumberspanel", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent)
	
	self.parent = parent
	self.type = "linenumberspanel"
	self.width = 5
	self.height = 5
	self.offsety = 0
	self.staticx = 0
	self.staticy = 0
	self.internal = true
	
	-- apply template properties to the object
	loveframes.ApplyTemplatesToObject(self)
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the element
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	local height = self.parent.height
	local parentinternals = parent.internals
	
	self.height = height
	self.offsety = self.parent.offsety - self.parent.textoffsety
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if parentinternals[1] ~= self then
		self:Remove()
		table.insert(parentinternals, 1, self)
		return
	end
	
	self:CheckHover()
	
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
	local stencilfunc = function() love.graphics.rectangle("fill", self.parent.x, self.parent.y, width, height) end
	
	if self.parent.hbar then
		stencilfunc = function() love.graphics.rectangle("fill", self.parent.x, self.parent.y, self.width, self.parent.height - 16) end
	end
	
	self:SetDrawOrder()
	
	love.graphics.stencil(stencilfunc)
	love.graphics.setStencilTest("greater", 0)
	
	local drawfunc = self.Draw or self.drawfunc
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

	local visible = self.visible
	
	if not visible then
		return
	end
	
	local hover = self.hover
	
	if hover and button == 1 then
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
	end
	
end

--[[---------------------------------------------------------
	- func: mousereleased(x, y, button)
	- desc: called when the player releases a mouse button
--]]---------------------------------------------------------
function newobject:mousereleased(x, y, button)

	local visible = self.visible
	
	if not visible then
		return
	end
	
end

--[[---------------------------------------------------------
	- func: GetOffsetY()
	- desc: gets the object's y offset
--]]---------------------------------------------------------
function newobject:GetOffsetY()

	return self.offsety
	
end

---------- module end ----------
end
