--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- tooltip clas
local newobject = loveframes.NewObject("tooltip", "loveframes_object_tooltip", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(object, text)
	
	self.type = "tooltip"
	self.parent = loveframes.base
	self.object = object or nil
	self.width = 0
	self.height = 0
	self.padding = 5
	self.xoffset = 10
	self.yoffset = -10
	self.internal = true
	self.followcursor = true
	self.followobject = false
	self.alwaysupdate = true
	self.internals = {}
	
	-- create the object's text
	local textobject = loveframes.Create("text")
	textobject:Remove()
	textobject.parent = self
	textobject:SetText(text or "")
	textobject:SetPos(0, 0)
	table.insert(self.internals, textobject)
	
	-- apply template properties to the object
	loveframes.ApplyTemplatesToObject(self)
	table.insert(loveframes.base.internals, self)
	
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
	local textobject = internals[1]
	local padding = self.padding
	local object = self.object
	local draworder = self.draworder
	local update = self.Update
	
	self.width = textobject.width + padding * 2
	self.height = textobject.height + padding * 2
	
	if object then
		if object == loveframes.base then
			self:Remove()
			return
		end
		--local ovisible = object.visible
		local ohover = object.hover
		local ostate = object.state
		if ostate ~= state then
			self.visible = false
			return
		end
		self.visible = ohover
		if ohover then
			local top = self:IsTopInternal()
			local followcursor = self.followcursor
			local followobject = self.followobject
			local xoffset = self.xoffset
			local yoffset = self.yoffset
			if followcursor then
				local height = self.height
				local mx, my = love.mouse.getPosition()
				self.x = mx + xoffset
				self.y = my - height + yoffset
			elseif followobject then
				local ox = object.x
				local oy = object.y
				self.x = ox + xoffset
				self.y = oy + yoffset
			end
			if not top then
				self:MoveToTop()
			end
			textobject:SetPos(padding, padding)
		end
	end
	
	--textobject:SetVisible(self.show)
	textobject:SetState(selfstate)
	textobject:update(dt)
	
	if update then
		update(self, dt)
	end

end

--[[---------------------------------------------------------
	- func: SetFollowCursor(bool)
	- desc: sets whether or not the tooltip should follow the
			cursor
--]]---------------------------------------------------------
function newobject:SetFollowCursor(bool)

	self.followcursor = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetFollowCursor()
	- desc: gets whether or not the tooltip should follow the
			cursor
--]]---------------------------------------------------------
function newobject:GetFollowCursor()

	return self.followcursor
	
end

--[[---------------------------------------------------------
	- func: SetObject(object)
	- desc: sets the tooltip's object
--]]---------------------------------------------------------
function newobject:SetObject(object)

	self.object = object
	self.x = object.x
	self.y = object.y
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetObject()
	- desc: gets the tooltip's object
--]]---------------------------------------------------------
function newobject:GetObject()

	return self.object
	
end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the tooltip's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	local internals = self.internals
	local textobject = internals[1]
	
	textobject:SetText(text)
	return self
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the tooltip's text
--]]---------------------------------------------------------
function newobject:GetText()

	local internals = self.internals
	local textobject = internals[1]
	local text = textobject:GetText()
	
	return text
	
end

--[[---------------------------------------------------------
	- func: SetTextMaxWidth(text)
	- desc: sets the tooltip's text max width
--]]---------------------------------------------------------
function newobject:SetTextMaxWidth(width)

	local internals = self.internals
	local textobject = internals[1]
	
	textobject:SetMaxWidth(width)
	return self
	
end

--[[---------------------------------------------------------
	- func: SetOffsetX(xoffset)
	- desc: sets the tooltip's x offset
--]]---------------------------------------------------------
function newobject:SetOffsetX(xoffset)

	self.xoffset = xoffset
	return self
	
end

--[[---------------------------------------------------------
	- func: GetOffsetX()
	- desc: gets the tooltip's x offset
--]]---------------------------------------------------------
function newobject:GetOffsetX()

	return self.xoffset
	
end

--[[---------------------------------------------------------
	- func: SetOffsetY(yoffset)
	- desc: sets the tooltip's y offset
--]]---------------------------------------------------------
function newobject:SetOffsetY(yoffset)

	self.yoffset = yoffset
	return self
	
end

--[[---------------------------------------------------------
	- func: GetOffsetY()
	- desc: gets the tooltip's y offset
--]]---------------------------------------------------------
function newobject:GetOffsetY()

	return self.yoffset
	
end

--[[---------------------------------------------------------
	- func: SetOffsets(xoffset, yoffset)
	- desc: sets the tooltip's x and y offset
--]]---------------------------------------------------------
function newobject:SetOffsets(xoffset, yoffset)

	self.xoffset = xoffset
	self.yoffset = yoffset
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetOffsets()
	- desc: gets the tooltip's x and y offset
--]]---------------------------------------------------------
function newobject:GetOffsets()

	return self.xoffset, self.yoffset
	
end

--[[---------------------------------------------------------
	- func: SetPadding(padding)
	- desc: sets the tooltip's padding
--]]---------------------------------------------------------
function newobject:SetPadding(padding)

	self.padding = padding
	return self
	
end

--[[---------------------------------------------------------
	- func: GetPadding()
	- desc: gets the tooltip's padding
--]]---------------------------------------------------------
function newobject:GetPadding()

	return self.padding
	
end

--[[---------------------------------------------------------
	- func: SetFont(font)
	- desc: sets the tooltip's font
--]]---------------------------------------------------------
function newobject:SetFont(font)

	local internals = self.internals
	local textobject = internals[1]
	
	textobject:SetFont(font)
	return self
	
end

--[[---------------------------------------------------------
	- func: GetFont()
	- desc: gets the tooltip's font
--]]---------------------------------------------------------
function newobject:GetFont()

	local internals = self.internals
	local textobject = internals[1]
	
	return textobject:GetFont()
	
end

--[[---------------------------------------------------------
	- func: SetFollowObject(bool)
	- desc: sets whether or not the tooltip should follow
			its assigned object
--]]---------------------------------------------------------
function newobject:SetFollowObject(bool)

	self.followobject = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetFollowObject()
	- desc: gets whether or not the tooltip should follow
			its assigned object
--]]---------------------------------------------------------
function newobject:GetFollowObject()

	return self.followobject
	
end

---------- module end ----------
end
