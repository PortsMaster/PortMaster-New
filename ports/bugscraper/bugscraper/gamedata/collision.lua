local bump = require "lib.bump.bump"
local Class = require "class"
require "constants"

local Collision = Class:inherit()

function Collision:init()
	self.world = bump.newWorld(BLOCK_WIDTH*2)
end

function Collision:add(o, x, y, w, h)
	if not x then
		x, y, w, h = o.x, o.y, o.w, o.h
	end
	self.world:add(o, x,y,w,h)
end

--[[
function Collision:add(self, o)
	local x, y = o.x - o.w, o.y - o.h
	local w, h = o.w * 2, o.h * 2
	self.world:add(o, x,y,w,h)
end
--]]

function Collision:remove(o)
	self.world:remove(o)
end

function Collision:update(o,x,y,w,h)
	-- Move to pos without changing position
	x = x or o.x
	y = y or o.y
	w = w or o.w
	h = h or o.h
	self.world:update(o,x,y,w,h)
end

local maxd = 0
function Collision:move(o, goal_x, goal_y, filter)
	-- Attempts to move object `o` and returns data about the collision
	filter = filter or self.filter
	goal_x = goal_x
	goal_y = goal_y
	
	local d = dist(o.x, o.y, goal_x, goal_y)
	if maxd < d then
		maxd = d
		-- print("maxd ", d)
	end
	local cap = 10000
	if d > cap then
		print("/!\\ Collision object '", o.name,"'' moved ", d, " units, larger than cap of ", cap)
		local move_x, move_y = goal_x - o.x, goal_y - o.y
		local norm_x, norm_y = move_x / d, move_y / d
		goal_x = o.x + norm_x * cap
		goal_y = o.y + norm_y * cap
	end

	local actual_x, actual_y, cols, len = self.world:move(o, goal_x, goal_y, filter)
	return actual_x, actual_y, cols, len
end 

function Collision:check(o, goal_x, goal_y, filter)
	-- Attempts to move object `o` and returns data about the collision
	filter = filter or self.filter
	goal_x = goal_x
	goal_y = goal_y

	local actual_x, actual_y, cols, len = self.world:check(o, goal_x, goal_y, filter)
	return actual_x, actual_y, cols, len
end 

function Collision.filter(item, other)
	-- By default, do not react to collisions
	local type = "cross"

	if not other.is_active then
		type = "cross"
	end
	if other.is_solid then
		type = "slide"
	end

	return type
end

return Collision