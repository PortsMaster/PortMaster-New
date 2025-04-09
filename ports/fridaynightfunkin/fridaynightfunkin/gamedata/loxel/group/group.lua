---@class Group:Basic
local Group = Basic:extend("Group")

function Group:new()
	Group.super.new(self)
	self.members = {}
end

function Group:add(obj)
	table.insert(self.members, obj)
	if obj.enter then obj:enter(self) end
	return obj
end

function Group:insert(idx, obj)
	table.insert(self.members, idx, obj)
	if obj.enter then obj:enter(self) end
	return obj
end

function Group:indexOf(obj)
	return table.find(self.members, obj)
end

function Group:remove(obj)
	table.delete(self.members, obj)
	local last = self.members[#self.members]
	if obj.leave then obj:leave(self) end
	if last and last.resume then last:resume(self) end
	return obj
end

function Group:pop()
	local obj = table.remove(self.members)
	local last = self.members[#self.members]
	if obj.leave then obj:leave(self) end
	if last and last.resume then last:resume(self) end
	return obj
end

function Group:clear() table.clear(self.members) end

function Group:reverse() table.reverse(self.members) end

function Group:sort(func) table.sort(self.members, func) end

function Group:recycle(class, factory, revive)
	if class == nil then class = Sprite end
	if factory == nil then factory = class end
	if revive == nil then revive = true end

	local obj
	for _, member in ipairs(self.members) do
		if not member.exists and member.is and member:is(class) then
			obj = member
			break
		end
	end
	if obj then
		self:remove(obj)
		if revive then obj:revive() end
	else
		obj = factory()
	end
	self:add(obj)

	return obj
end

function Group:_canDraw()
	return self.visible and self.exists and next(self.members)
end

Group.canDraw = Group._canDraw

function Group:draw()
	if not self:_canDraw() then return end
	local oldDefaultCameras = Camera.__defaultCameras
	if self.cameras then Camera.__defaultCameras = self.cameras end

	for _, member in ipairs(self.members) do
		if member:canDraw() then
			member:draw()
		end
	end

	Camera.__defaultCameras = oldDefaultCameras
end

local f

function Group:update(dt)
	if not (self.exists and self.active) then return end
	for _, member in ipairs(self.members) do
		if member.exists and member.active then
			f = member.update
			if f then f(member, dt) end
		end
	end
end

function Group:kill()
	for _, member in ipairs(self.members) do
		f = member.kill
		if f then f(member) end
	end

	Group.super.kill(self)
end

function Group:revive()
	for _, member in ipairs(self.members) do
		f = member.revive
		if f then f(member) end
	end

	Group.super.revive(self)
end

function Group:destroy()
	Group.super.destroy(self)

	for _, member in ipairs(self.members) do
		f = member.destroy
		if f then f(member) end
	end
end

return Group
