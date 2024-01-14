--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- scrollarea class
local newobject = loveframes.NewObject("scrollarea", "loveframes_object_scrollarea", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(parent, bartype)
	
	self.type = "scroll-area"
	self.bartype = bartype
	self.parent = parent
	self.x = 0
	self.y = 0
	self.scrolldelay = 0
	self.delayamount = 0.05
	self.down = false
	self.internal = true
	self.internals = {}
	
	table.insert(self.internals, loveframes.objects["scrollbar"]:new(self, bartype))
	
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
	
	local base = loveframes.base
	local parent = self.parent
	local pinternals = parent.internals
	local button = pinternals[2]
	local bartype = self.bartype
	local time = love.timer.getTime()
	local x, y = love.mouse.getPosition()
	local listo = parent.parent
	local down = self.down
	local scrolldelay = self.scrolldelay
	local delayamount = self.delayamount
	local internals = self.internals
	local bar = internals[1]
	local hover = self.hover
	local update = self.Update
	
	if button then
		if bartype == "vertical" then
			self.staticx = 0
			self.staticy = button.height - 1
			self.width = parent.width
			self.height = parent.height - button.height*2 + 2
		elseif bartype == "horizontal" then
			self.staticx = button.width - 1
			self.staticy = 0
			self.width = parent.width - button.width*2 + 2
			self.height = parent.height
		end
	end
	
	-- move to parent if there is a parent
	if parent ~= base then
		self.x = parent.x + self.staticx
		self.y = parent.y + self.staticy
	end
	
	if down then
		if scrolldelay < time then
			self.scrolldelay = time + delayamount
			if self.bartype == "vertical" then
				if y > bar.y then
					bar:Scroll(bar.height)
				else
					bar:Scroll(-bar.height)
				end
			elseif self.bartype == "horizontal" then
				if x > bar.x then
					bar:Scroll(bar.width)
				else
					bar:Scroll(-bar.width)
				end
			end
		end
		if not hover then
			self.down = false
		end
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
	
	local visible = self.visible
	
	if not visible then
		return
	end
	
	local listo = self.parent.parent
	local time = love.timer.getTime()
	local internals = self.internals
	local bar = internals[1]
	local hover = self.hover
	local delayamount = self.delayamount
	
	if hover and button == 1 then
		self.down = true
		self.scrolldelay = time + delayamount + 0.5
		local baseparent = self:GetBaseParent()
		if baseparent and baseparent.type == "frame" then
			baseparent:MakeTop()
		end
		if self.bartype == "vertical" then
			if y > self.internals[1].y then
				bar:Scroll(bar.height)
			else
				bar:Scroll(-bar.height)
			end
		elseif self.bartype == "horizontal" then
			if x > bar.x then
				bar:Scroll(bar.width)
			else
				bar:Scroll(-bar.width)
			end
		end
		loveframes.downobject = self
	end
	
	for k, v in ipairs(internals) do
		v:mousepressed(x, y, button)
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
	
	local internals = self.internals
	
	if button == 1 then
		self.down = false
	end
	
	for k, v in ipairs(internals) do
		v:mousereleased(x, y, button)
	end

end

--[[---------------------------------------------------------
	- func: GetBarType()
	- desc: gets the object's bar type
--]]---------------------------------------------------------
function newobject:GetBarType()
	
	return self.bartype
	
end

---------- module end ----------
end
