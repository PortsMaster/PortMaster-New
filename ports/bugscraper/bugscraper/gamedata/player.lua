local Class = require "class"
local Actor = require "actor"
local Guns = require "data.guns"
local Bullet = require "bullet"
local images = require "data.images"
local sounds = require "data.sounds"
local ui = require "ui"
require "util"
require "constants"

local Player = Actor:inherit()

function Player:init(n, x, y, spr, controls)
	n = n or 1
	x = x or 0
	y = y or 0
	spr = spr or images.ant1
	self:init_actor(x, y, 14, 14, spr)
	self.is_player = true
	self.is_being = true
	self.name = concat("player", n)
	self.player_type = "ant"

	-- Life
	self.max_life = 4
	self.life = self.max_life
	
	-- Death
	self.is_dead = false
	
	-- Meta
	self.n = n
	self.is_enemy = false
	self.controls = controls
	self:init_last_input_state()
	
	-- Animation
	self.spr_idle = images.ant1
	self.spr_jump = images.ant2
	self.spr_dead = images.ant_dead
	self.spr = self.spr_idle
	self.is_walking = false
	self.squash = 1
	self.jump_squash = 1
	self.walkbounce_oy = 0
	self.walkbounce_t = 0
	self.walkbounce_squash = 0
	self.bounce_vy = 0
	self.old_bounce_vy = 0

	self.walk_timer = 0

	self.mid_x = self.x + floor(self.w / 2)
	self.mid_y = self.y + floor(self.h / 2)
	self.dir_x = 1
	self.dir_y = 0
	
	-- Speed 
	self.speed = 50 --This is acceleration not speed but I'm too lazy to change now

	-- Jump
	self.jump_speed = 450--450
	self.buffer_jump_timer = 0
	self.coyote_time = 0
	self.default_coyote_time = 6
	self.stomp_jump_speed = 500

	-- Air time
	self.air_time = 0
	self.jump_air_time = 0.3
	self.air_jump_force = 22

	self.frames_since_land = 0

	-- Wall sliding & jumping
	self.is_walled = false
	self.wall_jump_kick_speed = 300
	self.wall_slide_speed = 30
	self.is_wall_sliding = false
	self.wall_slide_particle_timer = 0

	self.wall_jump_margin = 8
	self.wall_collision_box = { --Move this to a seperate class if needed
		x = self.x,
		y = self.y,
		w = self.w + self.wall_jump_margin*2,
		h = self.h,
	}
	collision:add(self.wall_collision_box)

	-- Visuals
	self.color = ({COL_RED, COL_GREEN, COL_DARK_RED, COL_YELLOW})[self.n]
	self.color = self.color or COL_RED
	-- Loot & drops
	self.min_loot_dist = BLOCK_WIDTH*5

	-- Cursor
	self.cu_x = 0
	self.cu_y = 0
	self.mine_timer = 0
	self.cu_target = nil

	-- Invicibility
	self.is_invincible = false
	self.iframes = 0
	self.max_iframes = 3
	self.iframe_blink_freq = 0.1
	self.iframe_blink_timer = 0

	-- Shooting & guns (keep it or ditch for family friendliness?)	
	self.is_shooting = false
	self.shoot_dir_x = 1
	self.shoot_dir_y = 0
	self.shoot_ang = 0
	
	self:equip_gun(Guns.Machinegun:new())
	-- self:equip_gun(Guns.unlootable.DebugGun:new())
	-- FOR DEBUGGING
	self.guns = {
		Guns.Machinegun:new(self),
		Guns.unlootable.DebugGun:new(self),
		Guns.Triple:new(self),
		Guns.Burst:new(self),
		Guns.Shotgun:new(self),
		Guns.Minigun:new(self),
		Guns.MushroomCannon:new(self),
	}
	self.gun_number = 1

	self.is_dead = false
	self.gameoveranim_a = 0
	self.gameoveranim_y = 0
	self.timer_before_death = 0
	self.max_timer_before_death = 3.3

	-- UI
	self.ui_x = self.x
	self.ui_y = self.y
	self.ui_col_gradient = 0

	-- SFX
	self.sfx_wall_slide = sounds.sliding_wall_metal[1]
	self.sfx_wall_slide:play()
	self.sfx_wall_slide_volume = 0
	self.sfx_wall_slide_max_volume = 0.1

	-- Combo
	self.combo = 0
	self.max_combo = 0

	-- Debug 
	self.dt = 1
end

function Player:update(dt)
	self.dt = dt
	if self.is_dead then
		self:do_death_anim(dt)
		return
	end

	-- if self:button_pressed("up") then
	-- 	-- game.floor = 16
	-- 	for i,e in pairs(game.actors) do
	-- 		if e.is_enemy then
	-- 			e:kill()
	-- 		end
	-- 	end
	-- end
	-- if self:button_pressed("select") then
	-- 	game.floor = game.floor + 1
	-- end

	-- Movement
	self:move(dt)
	self:do_wall_sliding(dt)
	self:do_jumping(dt)
	self:do_gravity(dt)
	self:update_actor(dt)
	self:do_aiming(dt)
	self.mid_x = self.x + floor(self.w/2)
	self.mid_y = self.y + floor(self.h/2)
	self.is_walking = self.is_grounded and abs(self.vx) > 50
	self:do_invincibility(dt)
	self:animate_walk(dt)
	self:update_sprite(dt)
	self:do_particles(dt)

	if self.life <= 0 then
		self:kill()
	end
	
	if self.is_grounded then
		self.frames_since_land = self.frames_since_land + 1
	else
		self.frames_since_land = 0
	end

	-- Stop combo if landed for more than a few frames
	if self.frames_since_land > 3 then
		if self.combo > self.max_combo then
			game.max_combo = self.combo
			self.max_combo = self.combo
		end
		
		if self.combo >= 4 then
			particles:word(self.mid_x, self.mid_y, concat("COMBO ", self.combo, "!"), COL_LIGHT_BLUE)
		end
		self.combo = 0
	end

	-- Gun switchgun
	-- if self:button_pressed("up") then
	-- 	self.gun_number = mod_plus_1((self.gun_number + 1), #self.guns)
	-- 	self:equip_gun(self.guns[self.gun_number])
	-- end

	self.gun:update(dt)
	self:shoot(dt, false)
	self:update_gun_pos(dt)

	--self:do_snowballing()

	-- self:update_button_state() --> moved to Game

	self.ui_x = lerp(self.ui_x, game.cam_x + floor(self.mid_x), 0.2)
	self.ui_y = lerp(self.ui_y, game.cam_y + floor(self.y), 0.2)

	
	--Visuals
	if self:button_pressed("select") then
		self:flip_player_type()
		self.spr = self.spr_idle
	end
	self:update_visuals()
end

function Player:draw()
	if self.is_removed then   return   end
	if self.is_dead then    return    end
	
	if self.is_invincible then
		local v = 1 - (self.iframes / self.max_iframes)
		local a = 1
		if self.iframe_blink_timer < self.iframe_blink_freq/2 then
			a = 0.5
		end
		gfx.setColor(1, v, v, a)
	end

	-- Draw gun
	self.gun:draw(1, self.dir_x)

	-- Draw self
	self:draw_player()

	gfx.setColor(COL_WHITE)
end

function Player:draw_hud()
	if self.is_removed or self.is_dead then    return    end

	-- Life
	-- local ui_y = floor(self.y - self.spr:getHeight() - 6)
	-- ui:draw_icon_bar(self.mid_x, ui_y, self.life, self.max_life, images.heart, images.heart_empty)
	local ui_x = floor(self.ui_x)
	local ui_y = floor(self.ui_y) - self.spr:getHeight() - 6
	ui:draw_icon_bar(ui_x, ui_y, self.life, self.max_life, images.heart, images.heart_empty)
	-- Ammo bar
	local bar_w = 32
	local x = floor(ui_x) - floor(bar_w/2)
	local y = floor(ui_y) + 8
	local ammo_w = images.ammo:getWidth()
	gfx.draw(images.ammo, x, y)
	
	local text = self.gun.ammo
	local col_shad = COL_DARK_BLUE
	local col_fill = COL_MID_BLUE
	local val, maxval = self.gun.ammo, self.gun.max_ammo
	if self.gun.is_reloading then
		text = ""
		col_fill = COL_WHITE
		col_shad = COL_LIGHT_GRAY
		val, maxval = self.gun.max_reload_timer - self.gun.reload_timer, self.gun.max_reload_timer
	end

	-- /!\ Doing calculations like these in draw is a BAD idea! Too bad!
	self.ui_col_gradient = self.ui_col_gradient * 0.9
	if self.ui_col_gradient >= 0.02 then
		col_fill = lerp_color(col_fill, COL_WHITE, self.ui_col_gradient)
		col_shad = lerp_color(col_fill, COL_LIGHT_GRAY, self.ui_col_gradient)
	end

	ui:draw_progress_bar(x+ammo_w+2, y, bar_w-ammo_w-2, ammo_w, val, maxval, 
						col_fill, COL_BLACK_BLUE, col_shad, text)

	-- x, y, w, h, val, max_val, col_fill, col_out, col_fill_shadow, text, text_col, font
	-- rect_color(COL_GREEN, "fill", self.mid_x, self.y-32, 1, 60)

	if game.debug_mode then
	end

end

function Player:draw_player()
	local fx = self.dir_x * self.sx
	local fy = 				self.sy
	
	local spr_w2 = floor(self.spr:getWidth() / 2)
	local spr_h2 = floor(self.spr:getHeight() / 2)

	local x = self.x + spr_w2 - self.spr_ox
	local y = self.y + spr_h2 - self.spr_oy - self.walkbounce_oy
	if self.spr then
		local old_col = {gfx.getColor()}

		-- if self.draw_shadow then
		-- 	local o = ((self.x / CANVAS_WIDTH)-.5) * 6
		-- 	love.graphics.setColor(0, 0, 0, 0.5)
		-- 	love.graphics.draw(self.spr, x+o, y+3, 0, fx, fy, spr_w2, spr_h2)
		-- end
		
		-- Draw
		love.graphics.setColor(old_col)
		gfx.draw(self.spr, x, y, self.rot, fx, fy, spr_w2, spr_h2)
	end
end

function Player:heal(val)
	local overflow = self.max_life - (self.life + val)
	if overflow >= 0 then
		self.life = self.life + val
		return true
	else
		self.life = self.max_life
		return false, -overflow
	end
end

function Player:move(dt)
	-- compute movement dir
	local dir = {x=0, y=0}
	if self:button_down('left') then   dir.x = dir.x - 1   end
	if self:button_down('right') then   dir.x = dir.x + 1   end

	if dir.x ~= 0 then
		self.dir_x = dir.x

		-- If not shooting, update shooting direction
		if not self.is_shooting then
			-- self.shoot_dir_x = dir.x
			-- self.shoot_dir
		end
	end

	-- Apply velocity 
	self.vx = self.vx + dir.x * self.speed
	self.vy = self.vy + dir.y * self.speed
end

function Player:do_invincibility(dt)
	self.iframes = max(0, self.iframes - dt)

	self.is_invincible = false
	if self.iframes > 0 and game.frames_to_skip <= 0 then
		self.is_invincible = true
		self.iframe_blink_timer = (self.iframe_blink_timer + dt) % self.iframe_blink_freq
	end
end

function Player:set_invincibility(n)
	self.iframes = n
end

function Player:do_wall_sliding(dt)
	-- Check if wall sliding
	self.is_wall_sliding = false
	self.is_walled = false

	self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, 0, 0.3)
	self.sfx_wall_slide:setVolume(self.sfx_wall_slide_volume)

	if self.wall_col then
		local col_normal = self.wall_col.normal
		local is_walled = (col_normal.y == 0)
		local is_falling = (self.vy > 0)
		local holding_left = self:button_down('left') and col_normal.x == 1
		local holding_right = self:button_down('right') and col_normal.x == -1
		
		local is_wall_sliding = is_walled and is_falling and (holding_left or holding_right) 
			and not self.wall_col.other.is_not_slidable
		self.is_wall_sliding = is_wall_sliding
		self.is_walled = is_walled
	end

	
	-- Perform wall sliding
	if self.is_wall_sliding then
		-- Orient player opposite if wall sliding
		self.dir_x = self.wall_col.normal.x
		self.shoot_dir_x = self.wall_col.normal.x
	
		-- Slow down descent
		self.gravity = 0
		self.vy = self.wall_slide_speed

		-- Particles
		self.wall_slide_particle_timer = self.wall_slide_particle_timer + 1
		if self.wall_slide_particle_timer % 1 == 0 then
			particles:dust(self.mid_x + (self.w/2) * -self.dir_x, self.y)
		end

		-- SFX
		self.sfx_wall_slide_volume = lerp(self.sfx_wall_slide_volume, self.sfx_wall_slide_max_volume, 0.3)
		self.sfx_wall_slide:setVolume(self.sfx_wall_slide_volume)
	else
		self.gravity = self.default_gravity
	end
end

function Player:do_jumping(dt)
	-- This buffer is so that you still jump even if you're a few frames behind
	self.buffer_jump_timer = self.buffer_jump_timer - 1
	if self:button_pressed("jump") then
		self.buffer_jump_timer = 12
	end

	-- Update air time 
	self.air_time = self.air_time + dt
	if self.is_grounded then self.air_time = 0 end
	if self.air_time < self.jump_air_time and not self.is_grounded then
		if self:button_down("jump") then
			self.vy = self.vy - self.air_jump_force
		end
	end

	-- Coyote time
	--FIXME: if you press jump really fast, you can exploit coyote time and double jump 
	self.coyote_time = self.coyote_time - 1
	
	if self.buffer_jump_timer > 0 then
		-- Detect nearby walls using a collision box
		local wall_normal = self:get_nearby_wall()

		if self.is_grounded or self.coyote_time > 0 then 
			-- Regular jump
			self:jump(dt)
			self:on_jump()

		elseif wall_normal then
			-- Conditions for a wall jump ("wall kick")
			local left_jump  = (wall_normal.x == 1) and self:button_down("right")
			local right_jump = (wall_normal.x == -1) and self:button_down("left")
			
			-- Conditions for a wall jump used for climbing, while sliding ("wall climb")
			local wall_climb = self.is_wall_sliding

			if left_jump or right_jump or wall_climb then
				self:wall_jump(wall_normal)
			end
			self:on_jump()
		end
	end
end

function Player:get_nearby_wall()
	-- Returns whether the player is near a wall on its side
	-- This does not count floor and ceilings
	local null_filter = function()
		return "cross"
	end
	
	local box = self.wall_collision_box
	box.x = self.x - self.wall_jump_margin
	box.y = self.y - self.wall_jump_margin
	box.w = self.w + self.wall_jump_margin*2
	box.h = self.h + self.wall_jump_margin*2
	collision:update(box)
	
	local x,y, cols, len = collision:move(box, box.x, box.y, null_filter)
	for _,col in pairs(cols) do
		if col.other.is_solid and col.normal.y == 0 then 
			return col.normal	
		end
	end

	return false
end

function Player:jump(dt)
	self.vy = -self.jump_speed
	
	particles:smoke(self.mid_x, self.y+self.h)
	audio:play_var("jump", 0, 1.2)
	self.jump_squash = 1/4
end

function Player:wall_jump(normal)
	self.vx = normal.x * self.wall_jump_kick_speed
	self.vy = -self.jump_speed
	
	audio:play_var("jump", 0, 1.2)
	self.jump_squash = 1/4
end

function Player:on_jump()
	self.buffer_jump_timer = 0
	self.coyote_time = 0
end

function Player:on_leaving_ground()
	self.coyote_time = self.default_coyote_time
end

function Player:on_leaving_collision()
	self.coyote_time = self.default_coyote_time
end

function Player:kill()
	self.is_dead = true
	
	game:screenshake(10)
	particles:dead_player(self.spr_x, self.spr_y, self.spr_dead, self.dir_x)
	game:frameskip(30)

	self:on_death()
	game:on_kill(self)
	
	self.timer_before_death = self.max_timer_before_death
	audio:play("game_over_1")
end

function Player:on_death()
	
end

function Player:do_death_anim(dt)
	if not self.is_dead then   return   end
	self.timer_before_death = self.timer_before_death - dt
	
	if self.timer_before_death <= 0 then
		game:on_game_over()
		audio:play("game_over_2")
	end
end

function Player:shoot(dt, is_burst)
	if is_burst == nil then     is_burst = false    end
	-- Update aiming direction
	local dx, dy = self.dir_x, self.dir_y
	local aim_horizontal = (self:button_down("left") or self:button_down("right"))
	-- Allow aiming upwards 
	if self.dir_y ~= 0 and not aim_horizontal then    dx = 0    end

	-- Update shoot dir
	self.shoot_ang = atan2(dy, dx)
	self.shoot_dir_x = cos(self.shoot_ang)
	self.shoot_dir_y = sin(self.shoot_ang)

	local btn_auto = (self.gun.is_auto and self:button_down("shoot"))
	local btn_manu = (not self.gun.is_auto and self:button_pressed("shoot"))
	if btn_auto or btn_manu or is_burst then
		self.is_shooting = true

		local ox = dx * self.gun.bul_w
		local oy = dy * self.gun.bul_h
		local success = self.gun:shoot(dt, self, self.mid_x + ox, self.y + oy, dx, dy, is_burst)

		if success then
			-- screenshake
			if game.screenshake_q <= self.gun.screenshake * 3 then
				game:screenshake(self.gun.screenshake)
			end 
			-- if self.gun.screenshake >= 1 then
			-- else
			-- 	if love.math.random() <= self.gun.screenshake then game:screenshake(1) end
			-- end
			if dx ~= 0 then
				self.vx = self.vx - self.dir_x * self.gun.recoil_force
			end
		end

		if self.is_flying then
			-- (When elevator is going down)
			if success then
				self.vx = (self.vx - dx*self.gun.jetpack_force) * self.friction_x
				self.vy = (self.vy - dy*self.gun.jetpack_force) * self.friction_x
			end
		else
			-- (Normal behaviour) If shooting downwards, then go up like a jetpack
			if self:button_down("down") and success then
				self.vy = self.vy - self.gun.jetpack_force
				self.vy = self.vy * self.friction_x
			end
		end
	else
		self.is_shooting = false
	end
end

function Player:update_gun_pos(dt, lerpval)
	-- Why do I keep overcomplicating these things
	-- TODO: move to Gun?
	-- Gun is drawn at its center
	lerpval = lerpval or 0.5
	 
	local gunw = self.gun.spr:getWidth()
	local gunh = self.gun.spr:getHeight()
	local top_y = self.y + self.h - self.spr:getHeight()
	local hand_oy = 15

	-- x pos is player sprite width minus a bit, plus gun width 
	local w = (self.spr:getWidth()/2-5 + gunw/2)
	
	local hand_y = top_y + hand_oy - self.walkbounce_oy

	local tar_x = self.mid_x + self.shoot_dir_x * w
	local tar_y = hand_y - gunh/2 + self.shoot_dir_y * gunh
	local ang = self.shoot_ang
	
	self.gun.x = lerp(self.gun.x, tar_x, lerpval)
	self.gun.y = lerp(self.gun.y, tar_y, lerpval)

--[[	local rot_offset = ang - atan2(-self.vy, -self.vx)
	local d = dist(self.vx, self.vy)
	rot_offset = rot_offset * 0.2
	if abs(d) < 0.01 then    rot_offset = 0    end
--]]
	self.gun.rot = lerp_angle(self.gun.rot, ang, 0.3)
end

function Player:button_down(btn)
	-- TODO: move this to some input.lua or something
	local keys = self.controls[btn]
	if not keys then   error(concat("Attempt to access button '",concat(btn),"'"))   end

	for i, k in pairs(keys) do
		if love.keyboard.isScancodeDown(k) then
			return true
		end
	end
	return false
end

function Player:init_last_input_state()
	self.last_input_state = {}
	for btn, _ in pairs(self.controls) do
		if btn ~= "type" then
			self.last_input_state[btn] = false
		end
	end
end

function Player:button_pressed(btn)
	-- This makes sure that the button state table assigns "true" to buttons
	-- that have been just pressed 
	local last = self.last_input_state[btn]
	local now = self:button_down(btn)
	return not last and now
end

function Player:update_button_state()
	for btn, v in pairs(self.controls) do
		if type(v) == "table" then
			self.last_input_state[btn] = self:button_down(btn)
		else
			if btn ~= "type" then
				print(concat("update_button_state not a table:", btn, ", ", table_to_str(v)))
			end
		end
	end
end

function Player:set_controls(button, value)
	if not value then
		local controls = button
		self.controls = controls
		return
	end

	if not self.controls[button] then
		print(concat("Tried to set btn '", button,"'"))
		return
	end
	if type(value) ~= "table" then
		print(concat("Val '",value,"' for p:set_controls not table"))
	end
	self.controls[button] = value
end

function Player:on_collision(col, other)
	
end

function Player:on_stomp(enemy)
	local spd = -self.stomp_jump_speed
	if self:button_down("jump") or self.buffer_jump_timer > 0 then
		spd = spd * 1.3
	end
	self.vy = spd
	self:set_invincibility(0.2)

	self.combo = self.combo + 1
	if self.combo >= 4 then
		particles:word(self.mid_x, self.mid_y, tostring(self.combo), COL_LIGHT_BLUE)
	end
	
	self.ui_col_gradient = 1
	self.gun.ammo = self.gun.ammo + floor(self.gun.max_ammo*.25)
	self.gun.reload_timer = 0
end

function Player:do_damage(n, source)
	if self.iframes > 0 then    return    end
	if n <= 0 then    return    end

	game:frameskip(8)
	audio:play("hurt")
	game:screenshake(5)
	particles:word(self.mid_x, self.mid_y, concat("-",n))
	-- self:do_knockback(source.knockback, source)--, 0, source.h/2)
	--source:do_knockback(source.knockback*0.75, self)
	if self.is_knockbackable then
		self.vx = self.vx + sign(self.mid_x - source.mid_x)*source.knockback
		self.vy = self.vy - 50
	end

	self.life = self.life - n
	self.life = clamp(self.life, 0, self.max_life)

	self.iframes = self.max_iframes

	if self.life <= 0 then
		self:die()
	end
end

function Player:die()
	self.life = 0
end

function Player:on_hit_bullet(bul, col)
	if bul.player == self then   return   end

	self:do_damage(bul.damage, bul)
	self.vx = self.vx + sign(bul.vx) * bul.knockback
end

function Player:update_visuals()
	self.jump_squash       = lerp(self.jump_squash,       1, 0.2)
	self.walkbounce_squash = lerp(self.walkbounce_squash, 1, 0.2)
	self.squash = self.jump_squash * self.walkbounce_squash

	self.sx = self.squash
	self.sy = 1/self.squash
end

function Player:on_grounded()
	-- On land
	local s = "metalfootstep_0"..tostring(love.math.random(0,4))
	if self.grounded_col and self.grounded_col.other.name == "rubble" then
		s = "gravel_footstep_"..tostring(love.math.random(1,6))
	end
	audio:play_var(s, 0.3, 1, {pitch=0.5, volume=0.5})

	self.jump_squash = 2
	self.spr = self.spr_idle
	particles:smoke(self.mid_x, self.y+self.h, 10, COL_WHITE, 8, 4, 2)

	self.air_time = 0
end

function Player:do_aiming(dt)
	self.dir_y = 0
	if self:button_down("up") then      self.dir_y = -1    end
	if self:button_down("down") then    self.dir_y = 1     end
end

function Player:do_snowballing()
	local moving = self:button_down("left") or self:button_down("right")
	if self.is_grounded and self:button_down("down") and moving then
		self.snowball_size = self.snowball_size + 0.1
	end

	if self:button_down("shoot") then
		local spd = self.snowball_speed * self.dir_x
		game:new_actor(Bullet:new(self, self.mid_x, self.mid_y, 10, 10, spd, -self.snowball_speed))
	end
end

function Player:equip_gun(gun)
	self.gun = gun
	self.gun.user = self

	self:update_gun_pos(1)
end

function Player:animate_walk(dt)
	-- Ridiculously overengineered bounce + squash & stretch while walking
	local old_bounce = self.walkbounce_oy

	local t_speed = 15
	local bounce_height = 5
	local squash_amount = 0.17
	
	self.walkbounce_t = self.walkbounce_t + dt * t_speed

	if self.is_walking then
		self.walkbounce_t = self.walkbounce_t % pi
	end

	if self.walkbounce_t < pi + 0.001 then
		self.is_doing_walksquash = true

		--- Compute bounce height
		local sin_a = sin(self.walkbounce_t)
		self.walkbounce_y = abs(sin_a) * bounce_height
		self.walkbounce_oy = self.walkbounce_y
		
		--- Bounce squash
		--cos is the derivative, aka rate of change ("speed") of sin
		local speed_t = math.cos(self.walkbounce_t)
		self.walkbounce_squash = speed_t*squash_amount + 1

		--- Jump sprite
		local old_spr = self.spr
		self.spr = self.spr_idle
		if self.is_walking and self.walkbounce_y > 4 then
			self.spr = self.spr_jump
		end
	else
		-- If not walking and close enough to ground, reset
		self.walkbounce_squash = 1
		self.walkbounce_oy = 0
		self.walkbounce_t = pi
	end

	self.old_bounce_vy = self.bounce_vy
	self.bounce_vy = old_bounce - self.walkbounce_y
	
	-- Walk SFX
	if sign(self.old_bounce_vy) == 1 and sign(self.bounce_vy) == -1 then
		local s = "metalfootstep_0"..tostring(love.math.random(0,4))
		if self.grounded_col and self.grounded_col.other.name == "rubble" then
			s = "gravel_footstep_"..tostring(love.math.random(1,6))
		end
		audio:play_var(s, 0.3, 1.1, {pitch=0.4, volume=0.5})
	end
end

function Player:update_sprite(dt)
	if not self.is_grounded then
		self.spr = self.spr_jump
	end
end

function Player:do_particles(dt)
	local flr_y = self.y + self.h
	if self.is_walking then
		self.walk_timer = self.walk_timer + 1
		if self.walk_timer % 10 == 0 then
			particles:dust(self.mid_x, flr_y)
		end
	end
end

function Player:flip_player_type()
	if self.player_type == "ant" then
		self.player_type = "caterpillar"
		self.spr_idle = images.caterpillar_1
		self.spr_jump = images.caterpillar_2
		self.spr_dead = images.caterpillar_dead
	else
		self.player_type = "ant"
		self.spr_idle = images.ant1
		self.spr_jump = images.ant2
		self.spr_dead = images.ant_dead
	end
end

return Player