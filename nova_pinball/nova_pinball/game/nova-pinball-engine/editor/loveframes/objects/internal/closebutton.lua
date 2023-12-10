--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- closebutton class
local newobject = loveframes.NewObject("closebutton", "loveframes_object_closebutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "closebutton"
	self.width = 16
	self.height = 16
	self.internal = true
	self.hover = false
	self.down = false
	self.autoposition = true
	self.OnClick = function() end
	
	-- apply template properties to the object
	loveframes.ApplyTemplatesToObject(self)
	
	self:SetDrawFunc()
end

--[[---------------------------------------------------------
	- func: update(deltatime)
	- desc: updates the object
--]]---------------------------------------------------------
function newobject:update(dt)
	
	local visible = self.visible
	local alwaysupdate = self.alwaysupdate
	
	if not visible then
		if not alwaysupdate then
			return
		end
	end
	
	self:CheckHover()
	
	local hover = self.hover
	local down = self.down
	local downobject = loveframes.downobject
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	if not hover then
		self.down = false
	else
		if loveframes.downobject == self then
			self.down = true
		end
	end
	
	if not down and downobject == self then
		self.hover = true
	end
	
	if self.autoposition then
		self.staticx = self.parent.width - self.width - 4
		self.staticy = 4
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
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
		self.down = true
		loveframes.downobject = self
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
	
	local hover = self.hover
	local onclick = self.OnClick
	
	if hover and self.down then
		if button == 1 then
			onclick(x, y, self)
		end
	end
	
	self.down = false

end

--[[---------------------------------------------------------
	- func: SetAutoPosition(bool)
	- desc: sets whether or not the object should be 
			positioned automatically
--]]---------------------------------------------------------
function newobject:SetAutoPosition(bool)

	self.autoposition = bool
	
end

--[[---------------------------------------------------------
	- func: GetAutoPosition()
	- desc: gets whether or not the object should be 
			positioned automatically
--]]---------------------------------------------------------
function newobject:GetAutoPosition()

	return self.autoposition
	
end

---------- module end ----------
end
