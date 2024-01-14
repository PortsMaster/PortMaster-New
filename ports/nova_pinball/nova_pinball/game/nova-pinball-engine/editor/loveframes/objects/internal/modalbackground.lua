--[[------------------------------------------------
	-- Love Frames - A GUI library for LOVE --
	-- Copyright (c) 2012-2014 Kenny Shields --
--]]------------------------------------------------

return function(loveframes)
---------- module start ----------

-- modalbackground class
local newobject = loveframes.NewObject("modalbackground", "loveframes_object_modalbackground", true)

--[[---------------------------------------------------------
	- func: initialize()
	- desc: initializes the object
--]]---------------------------------------------------------
function newobject:initialize(object)
	
	self.type = "modalbackground"
	self.width = love.graphics.getWidth()
	self.height = love.graphics.getHeight()
	self.x = 0
	self.y = 0
	self.internal = true
	self.parent = loveframes.base
	self.object = object
	
	table.insert(loveframes.base.children, self)
	
	if self.object.type ~= "frame" then
		self:Remove()
	end
	
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
	
	local object = self.object
	local update = self.Update
	local base = loveframes.base
	local basechildren = base.children
	
	self:CheckHover()
	
	if #basechildren > 1 then
		if basechildren[#basechildren - 1] ~= self then
			self:Remove()
			table.insert(basechildren, self)
		end
	end
	
	if not object:IsActive() then
		self:Remove()
		loveframes.modalobject = false
	end
	
	if update then
		update(self, dt)
	end

end

---------- module end ----------
end
