local Class = require "class"

local Actor = Class:inherit()

function Actor:init_actor(x, y, w, h, spr, args)
	if not args then   args = {}   end
	if args.add_collision == nil then   args.add_collision = true   end

	self.is_actor = true
	self.is_active = true
	self.x = x or 0
	self.y = y or 0
	self.w = w or 32
	self.h = h or 32

	self.mid_x = 0
	self.mid_y = 0

	self.sx = 1
	self.sy = 1

	self.dx = 0
	self.dy = 0

	self.vx = 0
	self.vy = 0

	self.rot = 0

	self.default_gravity = 20
	self.gravity = self.default_gravity
	self.gravity_cap = 400
	self.gravity_mult = 1
	
	self.default_friction = 0.8
	self.friction_x = self.default_friction -- !!!!! This assumes that the game is running at 60FPS
	self.friction_y = 1 -- By default we don't apply friction to the Y axis for gravity

	self.speed_cap = 10000
	self.is_solid = false

	self.is_grounded = false
	self.is_walled = false

	self.is_knockbackable = true

	self.wall_col = nil

	self.is_removed = false
	self:add_collision()
	
	-- Visuals
	self.draw_shadow = true
	if spr then
		self.spr = spr
		self.spr_w = self.spr:getWidth()
		self.spr_h = self.spr:getHeight()
		self.spr_ox = floor((self.spr_w - self.w) / 2)
		self.spr_oy = self.spr_h - self.h 
	end

	self.spr_x = 0
	self.spr_y = 0

	self.anim_frame_len = 0.2
	self.anim_t = random_range(0, self.anim_frame_len)
	self.anim_frames = nil
	self.anim_cur_frame = 1

	self:update_sprite_position()
end

function Actor:update()
	error("update not implemented")
end

function Actor:add_collision()
	collision:add(self, self.x, self.y, self.w, self.h)
end

function Actor:do_gravity(dt)
	self.vy = self.vy + self.gravity * self.gravity_mult
	if self.gravity * self.gravity_mult > 0 then
		self.vy = min(self.vy, self.gravity_cap)
	end	
end

function Actor:update_actor(dt)
	if self.is_removed then   return   end
	self:do_gravity(dt)

	-- apply friction
	self.vx = self.vx * self.friction_x
	self.vy = self.vy * self.friction_y
	
	-- apply position
	local goal_x = self.x + self.vx * dt
	local goal_y = self.y + self.vy * dt

	local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
	
	-- react to collisions
	local old_grounded = self.is_grounded
	self.is_grounded = false
	self.wall_col = nil
	for _,col in pairs(cols) do
		self:on_collision(col, col.other)
		self:react_to_collision(col)
	end

	-- Grounding events
	if not old_grounded and self.is_grounded then
		self:on_grounded()
	end
	if old_grounded and not self.is_grounded then
		self:on_leaving_ground()
	end

	-- Cap velocity
	local cap = self.speed_cap
	self.vx = clamp(self.vx, -cap, cap)
	self.vy = clamp(self.vy, -cap, cap)

	self.mid_x = self.x + self.w/2
	self.mid_y = self.y + self.h/2

	-- animation
	if self.anim_frames ~= nil then
		self.anim_t = self.anim_t + dt
		if self.anim_t >= self.anim_frame_len then
			self.anim_t = self.anim_t - self.anim_frame_len
			self.anim_cur_frame = mod_plus_1((self.anim_cur_frame + 1), #self.anim_frames)
		end
		self.spr = self.anim_frames[self.anim_cur_frame]
	end

	self:update_sprite_position()
end

function Actor:update_sprite_position()
	-- Sprite
	local spr_w2 = floor(self.spr:getWidth() / 2)
	local spr_h2 = floor(self.spr:getHeight() / 2)

	local x = self.x + spr_w2 - self.spr_ox
	local y = self.y + spr_h2 - self.spr_oy
	self.spr_x = floor(x)
	self.spr_y = floor(y)
end

function Actor:draw()
	error("draw not implemented")
end

function Actor:draw_actor(fx, fy, custom_draw)
	if self.is_removed then   return   end
	
	-- f : flip
	-- fix this, this is dumb
	if fx == true then   fx = -1   elseif fx == false then   fx = 1 end
	if fy == true then   fy = -1   elseif fy == false then   fy = 1 end

	fx = (fx or 1)*self.sx
	fy = (fy or 1)*self.sy

	local spr_w2 = floor(self.spr:getWidth() / 2)
	local spr_h2 = floor(self.spr:getHeight() / 2)

	local x, y = self.spr_x, self.spr_y
	if self.spr then
		-- local old_col = {gfx.getColor()}
		-- Shadow
		-- if self.draw_shadow then
		-- 	local o = ((self.x / CANVAS_WIDTH)-.5) * 6
		-- 	love.graphics.setColor(0, 0, 0, 0.5)
		-- 	-- (self.spr, floor(x+o), floor(y+3), 0, fx, fy, spr_w2, spr_h2)

		-- 	love.graphics.draw(self.spr, floor(x+o), floor(y+3), self.rot, fx, fy, spr_w2, spr_h2)
		-- end
		
		-- Draw
		-- love.graphics.setColor(old_col)
		
		local drw_func = gfx.draw
		if custom_draw then    drw_func = custom_draw    end
		drw_func(self.spr, x, y, self.rot, fx, fy, spr_w2, spr_h2)
	end
end

function Actor:react_to_collision(col)
	-- wall col
	if col.other.is_solid then
		-- save wall collision
		self.wall_col = col
		
		-- cancel velocity
		if col.normal.x ~= 0 then   self.vx = 0   end
		if col.normal.y ~= 0 then   self.vy = 0   end
		
		-- is grounded
		if col.normal.y == -1 then
			self.is_grounded = true
			self.grounded_col = col
		end
	end
end

function Actor:set_flying(bool)
	if bool then
		self.is_flying = true
		self.friction_x = 1
		self.friction_y = 1
		self.gravity = 0
	else
		self.is_flying = false
		self.friction_x = self.default_friction
		self.friction_y = 1
		self.gravity = self.default_gravity
		
	end
end

function Actor:do_knockback(q, source, ox, oy)
	if not self.is_knockbackable then    return    end

	ox, oy = ox or 0, oy or 0
	--if not source then    return    end
	local ang = atan2(source.y-self.y + oy, source.x-self.x + ox)
	self.vx = self.vx - cos(ang)*q
	self.vy = self.vy - sin(ang)*q
end

function Actor:on_collision(col, other)
	-- Implement on_collision
end

function Actor:on_grounded()
	-- 
end

function Actor:on_leaving_ground()

end


function Actor:remove()
	if not self.is_removed then
		self.is_removed = true
		collision:remove(self)
	end
end

function Actor:move_to(goal_x,goal_y)
	local actual_x, actual_y, cols, len = collision:move(self, goal_x, goal_y)
	self.x = actual_x
	self.y = actual_y
end

function Actor:set_pos(x, y)
	self.x = x
	self.y = y
	collision:update(self, x, y)
end

return Actor