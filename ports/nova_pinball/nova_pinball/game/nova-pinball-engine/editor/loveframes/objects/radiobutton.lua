--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- radiobutton object
local newobject = loveframes.NewObject("radiobutton", "loveframes_object_radiobutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "radiobutton"
	self.width = 0
	self.height = 0
	self.boxwidth = 20
	self.boxheight = 20
	self.font = loveframes.basicfont
	self.checked = false
	self.lastvalue = false
	self.internal = false
	self.down = true
	self.enabled = true
	self.internals = {}
	self.OnChanged = function () end
	self.group = {}

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
	
	local hover = self.hover
	local internals = self.internals
	local boxwidth = self.boxwidth
	local boxheight = self.boxheight
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
	
	if not self.down and loveframes.downobject == self then
		self.hover = true
	end
	
	-- move to parent if there is a parent
	if parent ~= base and parent.type ~= "list" then
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
	end
	
	if internals[1] then
		self.width = boxwidth + 5 + internals[1].width
		if internals[1].height == boxheight then
			self.height = boxheight
		else
			if internals[1].height > boxheight then
				self.height = internals[1].height
			else
				self.height = boxheight
			end
		end
	else
		self.width = boxwidth
		self.height = boxheight
	end
	
	for k, v in ipairs(internals) do
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
	
	if loveframes.state ~= self.state then
		return
	end
	
	if not self.visible then
		return
	end
	
	if self.hover and self.down and self.enabled and button == 1 then
		if not self.checked then
			-- a radio button can only be unchecked by checking another radio button
			self:SetChecked(true)
		end
	end
		
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	local boxwidth = self.boxwidth
	local boxheight = self.boxheight
	
	if text ~= "" then
		self.internals = {}
		local textobject = loveframes.Create("text")
		local skin = loveframes.GetActiveSkin()
		if not skin then
			skin = loveframes.config["DEFAULTSKIN"]
		end
		local directives = skin.directives
		if directives then
			local default_color = directives.radiobutton_text_default_color
			local default_shadowcolor = directives.radiobutton_text_default_shadowcolor
			local default_font = directives.radiobutton_text_default_font
			if default_color then
				textobject.defaultcolor = default_color
			end
			if default_shadowcolor then
				textobject.shadowcolor = default_shadowcolor
			end
			if default_font then
				self.font = default_font
			end
		end
		textobject:Remove()
		textobject.parent = self
		textobject.state = self.state
		textobject.collide = false
		textobject:SetFont(self.font)
		textobject:SetText(text)
		textobject.Update = function(object, dt)
			if object.height > boxheight then
				object:SetPos(boxwidth + 5, 0)
			else
				object:SetPos(boxwidth + 5, boxheight/2 - object.height/2)
			end
		end
		table.insert(self.internals, textobject)
	else
		self.width = boxwidth
		self.height = boxheight
		self.internals = {}
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	local internals = self.internals
	local text = internals[1]
	
	if text then
		return text.text
	else
		return false
	end
	
end

--[[---------------------------------------------------------
	- func: SetSize(width, height, r1, r2)
	- desc: sets the object's size
--]]---------------------------------------------------------
function newobject:SetSize(width, height, r1, r2)

	if r1 then
		self.boxwidth = self.parent.width * width
	else
		self.boxwidth = width
	end
	
	if r2 then
		self.boxheight = self.parent.height * height
	else
		self.boxheight = height
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetWidth(width, relative)
	- desc: sets the object's width
--]]---------------------------------------------------------
function newobject:SetWidth(width, relative)

	if relative then
		self.boxwidth = self.parent.width * width
	else
		self.boxwidth = width
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetHeight(height, relative)
	- desc: sets the object's height
--]]---------------------------------------------------------
function newobject:SetHeight(height, relative)

	if relative then
		self.boxheight = self.parent.height * height
	else
		self.boxheight = height
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: SetChecked(bool)
	- desc: sets whether the object is checked or not
--]]---------------------------------------------------------
function newobject:SetChecked(checked)

	if self.checked ~= checked then
		self.checked = checked
		self:OnChanged(checked)
	end

	if checked then
		for _, button in pairs(self.group) do
			if button ~= self and button.checked then
				button:SetChecked(false)
			end
		end
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetChecked()
	- desc: gets whether the object is checked or not
--]]---------------------------------------------------------
function newobject:GetChecked()

	return self.checked
	
end

--[[---------------------------------------------------------
	- func: SetGroup()
	- desc: set the object's group. only one radio button in a 
					group is checked at a time.
--]]---------------------------------------------------------
function newobject:SetGroup(group)
	
	self.group = group
	self.group[self] = self
	
end

--[[---------------------------------------------------------
	- func: GetGroup()
	- desc: gets the object's group
--]]---------------------------------------------------------
function newobject:GetGroup(group)

	return self.group
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the font of the object's text
--]]---------------------------------------------------------
function newobject:SetFont(font)

	local internals = self.internals
	local text = internals[1]
	
	self.font = font
	
	if text then
		text:SetFont(font)
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: newobject:GetFont()
	- desc: gets the font of the object's text
--]]---------------------------------------------------------
function newobject:GetFont()

	return self.font

end

--[[---------------------------------------------------------
	- func: newobject:GetBoxHeight()
	- desc: gets the object's box size
--]]---------------------------------------------------------
function newobject:GetBoxSize()

	return self.boxwidth, self.boxheight
	
end

--[[---------------------------------------------------------
	- func: newobject:GetBoxWidth()
	- desc: gets the object's box width
--]]---------------------------------------------------------
function newobject:GetBoxWidth()

	return self.boxwidth
	
end

--[[---------------------------------------------------------
	- func: newobject:GetBoxHeight()
	- desc: gets the object's box height
--]]---------------------------------------------------------
function newobject:GetBoxHeight()

	return self.boxheight
	
end

--[[---------------------------------------------------------
	- func: SetClickable(bool)
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
