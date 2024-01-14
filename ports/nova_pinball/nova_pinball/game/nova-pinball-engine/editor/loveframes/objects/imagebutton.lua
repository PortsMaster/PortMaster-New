--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- imagebutton object
local newobject = loveframes.NewObject("imagebutton", "loveframes_object_imagebutton", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize()

	self.type = "imagebutton"
	self.text = "Image Button"
	self.width = 50
	self.height = 50
	self.internal = false
	self.down = false
	self.clickable = true
	self.enabled = true
	self.image = nil
	self.imagecolor = {1, 1, 1, 1}
	self.OnClick = nil
	self.groupIndex	= 0
	self.checked = false
	
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
	local downobject = loveframes.downobject
	local down = self.down
	local parent = self.parent
	local base = loveframes.base
	local update = self.Update
	
	if not hover then
		self.down = false
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
		self.x = self.parent.x + self.staticx
		self.y = self.parent.y + self.staticy
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
	local down = self.down
	local clickable = self.clickable
	local enabled = self.enabled
	local onclick = self.OnClick

	if hover and down and clickable and button == 1 then
		if enabled then
			if self.groupIndex ~= 0 then
				local baseparent = self.parent
				if baseparent then
					for k, v in ipairs(baseparent.children) do
						if v.groupIndex then
							if v.groupIndex == self.groupIndex then
								v.checked = false
							end
						end
					end
				end
				self.checked = true
			end
			if onclick then
				onclick(self, x, y)
			end
		end
	end
	
	self.down = false

end

--[[---------------------------------------------------------
	- func: SetText(text)
	- desc: sets the object's text
--]]---------------------------------------------------------
function newobject:SetText(text)

	self.text = text
	return self
	
end

--[[---------------------------------------------------------
	- func: GetText()
	- desc: gets the object's text
--]]---------------------------------------------------------
function newobject:GetText()

	return self.text
	
end

--[[---------------------------------------------------------
	- func: SetClickable(bool)
	- desc: sets whether the object can be clicked or not
--]]---------------------------------------------------------
function newobject:SetClickable(bool)

	self.clickable = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetClickable(bool)
	- desc: gets whether the object can be clicked or not
--]]---------------------------------------------------------
function newobject:GetClickable()

	return self.clickable
	
end

--[[---------------------------------------------------------
	- func: SetClickable(bool)
	- desc: sets whether the object is enabled or not
--]]---------------------------------------------------------
function newobject:SetEnabled(bool)

	self.enabled = bool
	return self
	
end

--[[---------------------------------------------------------
	- func: GetEnabled()
	- desc: gets whether the object is enabled or not
--]]---------------------------------------------------------
function newobject:GetEnabled()

	return self.enabled
	
end

--[[---------------------------------------------------------
	- func: SetImage(image)
	- desc: sets the object's image
--]]---------------------------------------------------------
function newobject:SetImage(image)

	if type(image) == "string" then
		self.image = love.graphics.newImage(image)
		self.image:setFilter("nearest", "nearest")
	else
		self.image = image
	end
	
	return self

end

--[[---------------------------------------------------------
	- func: GetImage()
	- desc: gets whether the object is enabled or not
--]]---------------------------------------------------------
function newobject:GetImage()

	return self.image

end

--[[---------------------------------------------------------
	- func: SizeToImage()
	- desc: makes the object the same size as its image
--]]---------------------------------------------------------
function newobject:SizeToImage()

	local image = self.image
	
	if image then
		self.width = image:getWidth()
		self.height = image:getHeight()
	end
	
	return self
	
end

--[[---------------------------------------------------------
	- func: GetImageSize()
	- desc: gets the size of the object's image
--]]---------------------------------------------------------
function newobject:GetImageSize()

	local image = self.image
	
	if image then
		return image:getWidth(), image:getHeight()
	end
	
end

--[[---------------------------------------------------------
	- func: GetImageWidth()
	- desc: gets the width of the object's image
--]]---------------------------------------------------------
function newobject:GetImageWidth()

	local image = self.image
	
	if image then
		return image:getWidth()
	end
	
end

--[[---------------------------------------------------------
	- func: GetImageWidth()
	- desc: gets the height of the object's image
--]]---------------------------------------------------------
function newobject:GetImageHeight()

	local image = self.image
	
	if image then
		return image:getHeight()
	end
	
end

--[[---------------------------------------------------------
	- func: SetColor(r, g, b, a)
	- desc: sets the object's color 
--]]---------------------------------------------------------
function newobject:SetColor(r, g, b, a)

	self.imagecolor = {r, g, b, a}
	return self
	
end

--[[---------------------------------------------------------
	- func: GetColor()
	- desc: gets the object's color 
--]]---------------------------------------------------------
function newobject:GetColor()

	return unpack(self.imagecolor)
	
end

---------- module end ----------
end
