--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- sliderbutton class
local newobject = loveframes.NewObject("sliderbutton", "loveframes_object_sliderbutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent)

	self.type = "sliderbutton"
	self.width = 10
	self.height = 20
	self.staticx = 0
	self.staticy = 0
	self.startx = 0
	self.clickx = 0
	self.starty = 0
	self.clicky = 0
	self.intervals = true
	self.internal = true
	self.down = false
	self.dragging = false
	self.parent = parent
	
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
	
	local x, y = love.mouse.getPosition()
	local intervals = self.intervals
	local progress = 0
	local nvalue = 0
	local pvalue = self.parent.value
	local hover = self.hover
	local down = self.down
	local downobject = loveframes.downobject
	local parent = self.parent
	local slidetype = parent.slidetype
	local dragging = self.dragging
	local base = loveframes.base
	local update = self.Update
	
	if not hover then
		self.down = false
		if downobject == self then
			self.hover = true
		end
	else
		if downobject == self then
			self.down = true
		end
	end
	
	if not down and downobject == self then
		self.hover = true
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	-- start calculations if the button is being dragged
	if dragging then
		-- calculations for horizontal sliders
		if slidetype == "horizontal" then
			self.staticx = self.startx + (x - self.clickx)
			progress = self.staticx/(self.parent.width - self.width)
			nvalue = self.parent.min + (self.parent.max - self.parent.min) * progress
			nvalue = loveframes.Round(nvalue, self.parent.decimals)
		-- calculations for vertical sliders
		elseif slidetype == "vertical" then
			self.staticy = self.starty + (y - self.clicky)
			local space = self.parent.height - self.height
			local remaining = (self.parent.height - self.height) - self.staticy
			local percent =  remaining/space
			nvalue = self.parent.min + (self.parent.max - self.parent.min) * percent
			nvalue = loveframes.Round(nvalue, self.parent.decimals)
		end
		if nvalue > self.parent.max then
			nvalue = self.parent.max
		end
		if nvalue < self.parent.min then
			nvalue = self.parent.min
		end
		self.parent.value = nvalue
		if self.parent.value == -0 then
			self.parent.value = math.abs(self.parent.value)
		end
		if nvalue ~= pvalue and nvalue >= self.parent.min and nvalue <= self.parent.max then
			if self.parent.OnValueChanged then
				self.parent.OnValueChanged(self.parent, self.parent.value)
			end
		end
		loveframes.downobject = self
	end
	
	if slidetype == "horizontal" then
		if (self.staticx + self.width) > self.parent.width then
			self.staticx = self.parent.width - self.width
		end
		if self.staticx < 0 then
			self.staticx = 0
		end
	end
	
	if slidetype == "vertical" then
		if (self.staticy + self.height) > self.parent.height then
			self.staticy = self.parent.height - self.height
		end		
		if self.staticy < 0 then
			self.staticy = 0
		end
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
		self.dragging = true
		self.startx = self.staticx
		self.clickx = x
		self.starty = self.staticy
		self.clicky = y
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
	
	local down = self.down
	local dragging = self.dragging
	
	if dragging then
		local parent = self.parent
		local onrelease = parent.OnRelease
		if onrelease then
			onrelease(parent)
		end
	end
	
	self.down = false
	self.dragging = false

end

--[[---------------------------------------------------------
	- func: MoveToX(x)
	- desc: moves the object to the specified x position
--]]---------------------------------------------------------
function newobject:MoveToX(x)

	self.staticx = x
	
end

--[[---------------------------------------------------------
	- func: MoveToY(y)
	- desc: moves the object to the specified y position
--]]---------------------------------------------------------
function newobject:MoveToY(y)

	self.staticy = y
	
end

---------- module end ----------
end
