--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- slider object
local newobject = loveframes.NewObject("slider", "loveframes_object_slider", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "slider"
	self.text = "Slider"
	self.slidetype = "horizontal"
	self.width = 5
	self.height = 5
	self.max = 10
	self.min = 0
	self.value = 0
	self.decimals = 5
	self.scrollincrease = 1
	self.scrolldecrease = 1
	self.scrollable = true
	self.enabled = true
	self.internal = false
	self.internals = {}
	self.OnValueChanged	= nil
	self.OnRelease = nil
	
	-- create the slider button
	local sliderbutton = loveframes.objects["sliderbutton"]:new(self)
	sliderbutton.state = self.state
	table.insert(self.internals, sliderbutton)
	
	-- set initial value to minimum
	self:SetValue(self.min)
	
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
	
	local internals = self.internals
	local sliderbutton 	= internals[1]
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	self:CheckHover()
	
	-- move to parent if there is a parent
	if parent ~= base and parent.type ~= "list" then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if sliderbutton then
		local slidetype = self.slidetype
		local buttonwidth = sliderbutton.width
		local buttonheight = sliderbutton.height
		if slidetype == "horizontal" then
			self.height = buttonheight
		elseif slidetype == "vertical" then
			self.width = buttonwidth
		end
	end
	
	-- update internals
	for k, v in ipairs(self.internals) do
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
		
	local enabled = self.enabled
	
	if not enabled then
		return
	end
	
	local internals = self.internals
	local hover = self.hover
	local slidetype = self.slidetype
	local scrollable = self.scrollable
	
	if hover and button == 1 then
		if slidetype == "horizontal" then
			local xpos = x - self.x
			local button = internals[1]
			local baseparent = self:GetBaseParent()
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
			button:MoveToX(xpos)
			button.down = true
			button.dragging = true
			button.startx = button.staticx
			button.clickx = x
		elseif slidetype == "vertical" then
			local ypos = y - self.y
			local button = internals[1]
			local baseparent = self:GetBaseParent()
			if baseparent and baseparent.type == "frame" then
				baseparent:MakeTop()
			end
			button:MoveToY(ypos)
			button.down = true
			button.dragging = true
			button.starty = button.staticy
			button.clicky = y
		end
	elseif hover and scrollable and button == "wu" then
		local value = self.value
		local increase = self.scrollincrease
		local newvalue = value + increase
		self:SetValue(newvalue)
	elseif hover and scrollable and button == "wd" then
		local value = self.value
		local decrease = self.scrolldecrease
		local newvalue = value - decrease
		self:SetValue(newvalue)
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
	end
	
end

--[[---------------------------------------------------------
	- func: SetValue(value)
	- desc: sets the object's value
--]]---------------------------------------------------------
function newobject:SetValue(value)

	if value > self.max then
		return
	end
	
	if value < self.min then
		return
	end
	
	local decimals = self.decimals
	local newval = loveframes.Round(value, decimals)
	local internals = self.internals
	local onvaluechanged = self.OnValueChanged
	
	-- set the new value
	self.value = newval
	
	-- slider button object
	local sliderbutton = internals[1]
	local slidetype = self.slidetype
	local width = self.width
	local height = self.height
	local min = self.min
	local max = self.max
	
	-- move the slider button to the new position
	if slidetype == "horizontal" then
		local xpos = width * ((newval - min) / (max - min))
		sliderbutton:MoveToX(xpos)
	elseif slidetype == "vertical" then
		local ypos = height - height * ((newval - min) / (max - min))
		sliderbutton:MoveToY(ypos)
	end
	
	-- call OnValueChanged
	if onvaluechanged then
		onvaluechanged(self, newval)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetValue()
	- desc: gets the object's value
--]]---------------------------------------------------------
function newobject:GetValue()

	return self.value
	
end

--[[---------------------------------------------------------
	- func: SetMax(max)
	- desc: sets the object's maximum value
--]]---------------------------------------------------------
function newobject:SetMax(max)

	self.max = max
	
	if self.value > self.max then
		self.value = self.max
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMax()
	- desc: gets the object's maximum value
--]]---------------------------------------------------------
function newobject:GetMax()

	return self.max
	
end

--[[---------------------------------------------------------
	- func: SetMin(min)
	- desc: sets the object's minimum value
--]]---------------------------------------------------------
function newobject:SetMin(min)

	self.min = min
	
	if self.value < self.min then
		self.value = self.min
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMin()
	- desc: gets the object's minimum value
--]]---------------------------------------------------------
function newobject:GetMin()

	return self.min
	
end

--[[---------------------------------------------------------
	- func: SetMinMax()
	- desc: sets the object's minimum and maximum values
--]]---------------------------------------------------------
function newobject:SetMinMax(min, max)

	self.min = min
	self.max = max
	
	if self.value > self.max then
		self.value = self.max
	end
	
	if self.value < self.min then
		self.value = self.min
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetMinMax()
	- desc: gets the object's minimum and maximum values
--]]---------------------------------------------------------
function newobject:GetMinMax()

	return self.min, self.max
	
end

--[[---------------------------------------------------------
	- func: SetText(name)
	- desc: sets the objects's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	self.text = text
	return self
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the objects's text
--]]---------------------------------------------------------
function newobject:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetDecimals(decimals)
	- desc: sets how many decimals the object's value 
			can have
--]]---------------------------------------------------------
function newobject:SetDecimals(decimals)

	self.decimals = decimals
	return self
	
end

--[[---------------------------------------------------------
	- func: GetDecimals()
	- desc: gets how many decimals the object's value 
			can have
--]]---------------------------------------------------------
function newobject:GetDecimals()

	return self.decimals
	
end

--[[---------------------------------------------------------
	- func: SetButtonSize(width, height)
	- desc: sets the objects's button size
--]]---------------------------------------------------------
function newobject:SetButtonSize(width, height)
	
	local internals = self.internals
	local sliderbutton = internals[1]
	
	if sliderbutton then
		sliderbutton.width = width
		sliderbutton.height = height
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetButtonSize()
	- desc: gets the objects's button size
--]]---------------------------------------------------------
function newobject:GetButtonSize()

	local internals = self.internals
	local sliderbutton = internals[1]
	
	if sliderbutton then
		return sliderbutton.width, sliderbutton.height
	end
	
end

--[[---------------------------------------------------------
	- func: SetSlideType(slidetype)
	- desc: sets the objects's slide type
--]]---------------------------------------------------------
function newobject:SetSlideType(slidetype)

	self.slidetype = slidetype
	
	if slidetype == "vertical" then
		self:SetValue(self.min)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetSlideType()
	- desc: gets the objects's slide type
--]]---------------------------------------------------------
function newobject:GetSlideType()

	return self.slidetype
	
end

--[[---------------------------------------------------------
	- func: SetScrollable(bool)
	- desc: sets whether or not the object can be scrolled
			via the mouse wheel
--]]---------------------------------------------------------
function newobject:SetScrollable(bool)

	self.scrollable = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetScrollable()
	- desc: gets whether or not the object can be scrolled
			via the mouse wheel
--]]---------------------------------------------------------
function newobject:GetScrollable()

	return self.scrollable
	
end

--[[---------------------------------------------------------
	- func: SetScrollIncrease(increase)
	- desc: sets the amount to increase the object's value
			by when scrolling with the mouse wheel
--]]---------------------------------------------------------
function newobject:SetScrollIncrease(increase)

	self.scrollincrease = increase
	return self
	
end

--[[---------------------------------------------------------
	- func: GetScrollIncrease()
	- desc: gets the amount to increase the object's value
			by when scrolling with the mouse wheel
--]]---------------------------------------------------------
function newobject:GetScrollIncrease()

	return self.scrollincrease
	
end

--[[---------------------------------------------------------
	- func: SetScrollDecrease(decrease)
	- desc: sets the amount to decrease the object's value
			by when scrolling with the mouse wheel
--]]---------------------------------------------------------
function newobject:SetScrollDecrease(decrease)

	self.scrolldecrease = decrease
	return self
	
end

--[[---------------------------------------------------------
	- func: GetScrollDecrease()
	- desc: gets the amount to decrease the object's value
			by when scrolling with the mouse wheel
--]]---------------------------------------------------------
function newobject:GetScrollDecrease()

	return self.scrolldecrease
	
end

--[[---------------------------------------------------------
	- func: SetEnabled(bool)
	- desc: sets whether or not the object is enabled
--]]---------------------------------------------------------
function newobject:SetEnabled(bool)

	self.enabled = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetEnabled()
	- desc: gets whether or not the object is enabled
--]]---------------------------------------------------------
function newobject:GetEnabled()

	return self.enabled
	
end

---------- module end ----------
end
