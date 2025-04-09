require "util"
local Class = require "class"
local Enemy = require "enemy"
local Loot = require "loot"
local Bullet = require "bullet"
local Guns = require "data.guns"
local sounds = require "data.sounds"

local images = require "data.images"

local Enemies = Class:inherit()

function Enemies:init()
	------------------------------------------------------------

	self.Fly = Enemy:inherit()
	
	function self.Fly:init(x, y)
		self:init_enemy(x,y, images.fly1)
		self.name = "fly"
		self.is_flying = true
		self.life = 10
		--self.speed_y = 0--self.speed * 0.5
		
		self.speed = random_range(7,13) --10
		self.speed_x = self.speed
		self.speed_y = self.speed

		self.gravity = 0
		self.friction_y = self.friction_x

		self.anim_frame_len = 0.05
		self.anim_frames = {images.fly1, images.fly2}

		self.buzz_source = sounds.fly_buzz[1]:clone()
		self.buzz_source:seek(random_range(0, self.buzz_source:getDuration()))
		self.buzz_is_started = false
	end
	
	function self.Fly:update(dt)
		self:update_enemy(dt)

		if not self.buzz_is_started then  self.buzz_source:play() self.buzz_is_started = true end
		local spd = dist(0, 0, self.vx, self.vy)
		if spd >= 0.001 then
			self.buzz_source:setVolume(1)
		else
			self.buzz_source:setVolume(0)
		end
		-- audio:set_source_position_relative_to_object(self.buzz_source, self)
	end
	
	function self.Fly:pause_repeating_sounds()
		self.buzz_source:setVolume(0)
	end
	function self.Fly:play_repeating_sounds()
		self.buzz_source:setVolume(1)
	end

	function self.Fly:on_death()
		self.buzz_source:stop()
	end

	-------------

		
	self.SpikedFly = Enemy:inherit()
	
	function self.SpikedFly:init(x, y)
		self:init_enemy(x,y, images.spiked_fly, 15,15)
		self.name = "fly"
		self.is_flying = true
		self.life = 5

		self.is_stompable = false
		--self.speed_y = 0--self.speed * 0.5
		
		self.speed = random_range(7,13)
		self.speed_x = self.speed
		self.speed_y = self.speed*0.5

		self.gravity = 0
		self.friction_y = self.friction_x
	end

	-------------

	self.Larva = Enemy:inherit()
	
	function self.Larva:init(x, y)
		self:init_enemy(x,y, images.larva1, 14, 6)
		self.name = "larva"
		self.follow_player = false
		
		self.life = random_range(2, 3)
		self.friction_x = 1
		self.speed = 40
		self.walk_dir_x = random_sample{-1, 1}

		-- self.sound_damage = {"larva_damage1", "larva_damage2", "larva_damage3"}
		-- self.sound_death = "larva_death"
		self.anim_frame_len = 0.2
		self.anim_frames = {images.larva1, images.larva2}
		self.audio_delay = love.math.random(0.3, 1)
	end

	function self.Larva:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed * self.walk_dir_x
		
		-- self.audio_delay = self.audio_delay - dt
		-- if self.audio_delay <= 0 then
		-- 	self.audio_delay = love.math.random(0.3, 1.5)
		-- 	audio:play({
		-- 		"larva_damage1",
		-- 		"larva_damage2",
		-- 		"larva_damage3",
		-- 		"larva_death"
		-- 	})
		-- end
	end

	function self.Larva:after_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.walk_dir_x = col.normal.x
			end
		end
	end

	-------------

	self.Grasshopper = Enemy:inherit()
	
	function self.Grasshopper:init(x, y)
		self:init_enemy(x,y, images.grasshopper, 12, 12)
		self.name = "grasshopper"
		self.life = 7
		self.follow_player = false
		
		self.speed = 100
		self.vx = self.speed
		self.friction = 1
		self.friction_x = 1
		self.friction_y = 1
		self.walk_dir_x = random_sample{-1, 1}
		self.is_knockbackable = true

		self.gravity = self.gravity * 0.5

		self.jump_speed = 300
	end

	function self.Grasshopper:update(dt)
		self:update_enemy(dt)
		self.vx = self.speed * self.walk_dir_x
	end

	function self.Grasshopper:draw()
		self:draw_enemy()
	end

	function self.Grasshopper:after_collision(col, other)
		if other.is_solid then
			if col.normal.y == 0 then
				self.walk_dir_x = col.normal.x
			end
		end
	end

	function self.Grasshopper:on_grounded()
		self.vy = -self.jump_speed
		audio:play_var("jump_short", 0.2, 1.2, {pitch=0.4})
	end

	--------

	self.Slug = Enemy:inherit()

	function self.Slug:init(x, y) 
		self:init_enemy(x, y, images.slug1, 14, 9)
		self.name = "slug"
		self.follow_player = true

		self.gravity = self.default_gravity * 0.5

		self.anim_frame_len = 0.4
		self.anim_frames = {images.slug1, images.slug2}
	end

	
	------------------

	self.SnailShelled = Enemy:inherit()

	function self.SnailShelled:init(x, y)
		self:init_enemy(x,y, images.snail_shell, 16, 16)
		self.name = "snail_shelled"
		self.is_flying = true
		self.follow_player = false
		self.do_stomp_animation = false

		self.destroy_bullet_on_impact = false
		self.is_bouncy_to_bullets = true
		self.is_immune_to_bullets = true

		self.rot_speed = 3

		self.gravity = 0
		self.friction_y = self.friction_x 

		self.pong_speed = 40
		self.dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
		-- self.dir = love.math.random() * pi2
		self.pong_vx = cos(self.dir) * self.pong_speed
		self.pong_vy = sin(self.dir) * self.pong_speed

		self.spr_oy = floor((self.spr_h - self.h) / 2)
		self.sound_death = "snail_shell_crack"
		self.sound_stomp = "snail_shell_crack"
	end

	function self.SnailShelled:update(dt)
		self:update_enemy(dt)
		self.rot = self.rot + self.rot_speed * dt 

		self.vx = self.vx + (self.pong_vx or 0)
		self.vy = self.vy + (self.pong_vy or 0)
	end

	function self.SnailShelled:after_collision(col, other)
		-- Pong-like bounce
		if col.other.is_solid or col.other.name == "" then
			local s = "metalfootstep_0"..tostring(love.math.random(0,4))
			audio:play_var(s, 0.3, 1.1, {pitch=0.8, volume=0.5})

			particles:smoke(col.touch.x, col.touch.y)

			if col.normal.x ~= 0 then    self.pong_vx = sign(col.normal.x) * abs(self.pong_vx)    end
			if col.normal.y ~= 0 then    self.pong_vy = sign(col.normal.y) * abs(self.pong_vy)    end
		end
	end

	function self.SnailShelled:draw()
		self:draw_enemy()
	end

	local Slug = self.Slug
	function self.SnailShelled:on_death()
		particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_fragment, 13, nil, 0, 10)
		local slug = Slug:new(self.x, self.y)
		slug.vy = -200
		game:new_actor(slug)
	end

	------- 

	self.DummyTarget = Enemy:inherit()
	
	function self.DummyTarget:init(x, y)
		self:init_enemy(x,y, images.dummy_target, 15, 26)
		self.name = "dummy_target"
		self.follow_player = false

		self.life = 7
		self.damage = 0
		self.self_knockback_mult = 0.1

		self.knockback = 0
		
		self.is_pushable = false
		self.is_knockbackable = false
		self.loot = {}

		self.sound_damage = {"cloth1", "cloth2", "cloth3"}
		self.sound_death = "cloth_drop"
		self.sound_stomp = "cloth_drop"
	end

	function self.DummyTarget:update(dt)
		self:update_enemy(dt)
	end

	function self.DummyTarget:on_death()
		particles:image(self.mid_x, self.mid_y, 20, {images.dummy_target_ptc1, images.dummy_target_ptc2}, self.w, nil, nil, 0.5)
		--number, spr, spw_rad, life, vs, g
	end

	------- 

	self.MushroomAnt = Enemy:inherit()

	-- This ant will walk around corners, but this code will not work for "ledges".
	-- Please look at the code of my old project (gameaweek1) if needed
	function self.MushroomAnt:init(x, y) 
		-- this hitbox is too big, but it works for walls
		-- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
		self:init_enemy(x, y, images.mushroom_ant1, 20, 20)
		self.name = "mushroom_ant"
		self.follow_player = false

		self.is_on_wall = false

		self.up_vect = {x=0, y=-1}
		self.walk_dir = random_sample{-1, 1}
		self.walk_speed = 70
		self.is_knockbackable = false

		self.flip = 1
		self.gun = Guns.unlootable.MushroomAntGun:new(self)

		self.rot = 0
		self.target_rot = 0

		self.shoot_cooldown_range = {2, 3}
		self.shoot_timer = random_range(unpack(self.shoot_cooldown_range))

		self.anim_frames = {images.mushroom_ant1, images.mushroom_ant2}
		self.anim_frame_len = 0.3
	end
	
	function self.MushroomAnt:update(dt)
		self:update_enemy(dt)
		
		if self.is_on_wall then
			local walk_x, walk_y = get_orthogonal(self.up_vect.x, self.up_vect.y, self.walk_dir)
			self.vx = walk_x * self.walk_speed
			self.vy = walk_y * self.walk_speed
			
			self.target_rot = atan2(self.up_vect.y, self.up_vect.x) + pi/2
		end

		self.rot = lerp_angle(self.rot, self.target_rot, 0.4)

		self.shoot_timer = self.shoot_timer - dt
		if self.shoot_timer <= 0 then
			local r1, r2 = unpack(self.shoot_cooldown_range)
			self.shoot_timer = random_range(r1, r2)

			local vx, vy = cos(self.rot - pi/2), sin(self.rot - pi/2)

			self.gun:shoot(dt, self, self.mid_x, self.mid_y, vx, vy)
		end
	end

	function self.MushroomAnt:after_collision(col, other)
		if other.is_solid then
			self.is_on_wall = true

			self.up_vect.x = col.normal.x
			self.up_vect.y = col.normal.y
		end
	end

	function self.MushroomAnt:draw()
		local f = (self.damaged_flash_timer > 0) and draw_white or gfx.draw
		self:draw_actor(self.walk_dir, _, f)
	end

	function self.MushroomAnt:on_grounded()
		-- After gounded, reset to floating
		self.gravity = 0
		self.friction_x = 1
		self.friction_y = 1
	end

	--------

	self.Spider = Enemy:inherit()

	function self.Spider:init(x, y) 
		self:init_enemy(x, y, images.spider1, 21, 15)
		self.name = "spider"
		self.follow_player = false

		self.gravity = -self.default_gravity

		self.anim_frame_len = 0.4
		self.anim_frames = {images.spider1, images.spider2}

		self.time_before_flip = 0
		self.move_dir_x = random_sample{-1, 1}
		self.speed = 5

		self.is_on_ceiling = false
		self.ceiling_y = 0
		self.string_len = 0
		self.max_string_len = random_range(100, 150)
		self.string_grow_dir = 1
		self.string_growth_speed = random_range(30,55)

		self.dt = 0
	end

	function self.Spider:update(dt)
		self:update_enemy(dt)
		self.dt = dt

		self.time_before_flip = self.time_before_flip - dt
		if self.time_before_flip <= 0 or random_range(0,1) <= 0.01 then
			self.time_before_flip = random_range(0.5, 2)
			
			self.move_dir_x = -self.move_dir_x
		end
		
		self.vx = self.vx + self.move_dir_x * self.speed
	
		if self.is_on_ceiling then
			self.vy = self.string_grow_dir * self.string_growth_speed
			
			self.string_len = self.y - self.ceiling_y
			if self.string_len > self.max_string_len then
				self.string_grow_dir = -1
			end
			if self.string_len <= 60 then
				self.string_grow_dir = 1
			end
		end
	end

	function self.Spider:draw()
		self:draw_enemy()
		if self.is_on_ceiling then
			line_color(COL_WHITE, self.mid_x, self.y, self.mid_x - self.vx*self.dt*3, self.ceiling_y)
		end
	end

	function self.Spider:after_collision(col, other)
		if other.is_solid then
			if col.normal.x == 0 and col.normal.y == 1 then
				self.is_on_ceiling = true
				self.gravity = 0
				self.gravity_y = 0
				self.ceiling_y = self.y
			end
			if col.normal.y == 0 then
				self.time_before_flip = random_range(0.5, 2)
				self.walk_dir_x = col.normal.x
			end
		end
	end

	-----------------------
	-----------------------
	-----------------------

	self.Bug = Enemy:inherit()
	function self.Bug:init(x, y)
		self:init_enemy(x,y)
		self.name = "bug"
		self.life = 10
		self.color = rgb(0,50,190)
	end

	----------------

	self.ButtonPressed = Enemy:inherit()
	function self.ButtonPressed:init(x, y)
		-- x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH 
		-- x = floor(x - 34/2)
		y = game.door_by - 40
		self:init_enemy(x,y, images.big_red_button_pressed, 34, 40)
		self.name = "button_pressed"
		self.follow_player = false

		self.max_life = 999999
		self.life = self.max_life
		
		self.knockback = 0
		self.is_solid = false
		self.is_stompable = false
		self.is_pushable = false
		self.is_knockbackable = false
		self.loot = {}

		self.gravity = 0
		self.gravity_y = 0
		self.squash = 2

		self.damage = 0
	end

	function self.ButtonPressed:update(dt)
		self:update_enemy(dt)
		-- self.squash = lerp(self.squash, 1, 0.2)
		-- self.sx = self.squash
		-- self.sy = 1/self.squash
	end

	----------------

	self.Button = Enemy:inherit()
	function self.Button:init(x, y)
		-- We can reuse this for other stuff
		self:init_enemy(x,y, images.big_red_button, 34, 40)
		self.name = "button"
		self.follow_player = false

		self.max_life = 40
		self.life = self.max_life
		
		self.knockback = 0
		self.is_solid = false
		self.is_stompable = true
		self.do_stomp_animation = false
		self.is_pushable = false
		self.is_knockbackable = false
		self.play_sfx = false
		self.loot = {}

		self.damage = 0
	end

	function self.Button:update(dt)
		self:update_enemy(dt)
	end
	
	function self.Button:draw()
		self:draw_enemy()
	end

	local ButtonPressed = self.ButtonPressed
	function self.Button:on_stomped(damager)
		game:screenshake(10)
		game:on_red_button_pressed()
		audio:play("button_press")
		
		-- TODO: smoke particles
		-- local b = ButtonPressed:new(CANVAS_WIDTH/2, game.world_generator.box_rby)
		local b = ButtonPressed:new(self.x, self.y)
		game:new_actor(b)
	end

	function self.Button:on_death(damager, reason)
		if reason ~= "stomped" then
			game:screenshake(15)
			audio:play("glass_fracture", nil, 0.2)
			game:enable_endless_mode()
			-- particles:image(self.mid_x, self.mid_y, 100, images.ptc_glass_shard, self.h)
			particles:image(self.mid_x, self.mid_y, 300, {
				images.btnfrag_1,
				images.btnfrag_2,
				images.btnfrag_3,
				images.btnfrag_4,
				images.btnfrag_5,
			}, self.h, 6, 0.05, 0, parms)
			particles:word(self.mid_x, self.mid_y, "ENDLESS MODE!")
		end
	end

	-----------------
	
	self.ButtonGlass = Enemy:inherit()

	function self.ButtonGlass:init(x, y)
		-- We can reuse this for other stuff
		x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH 
		y = game.door_by - 45
		x = floor(x - 58/2)
		-- y = floor(y - 45/2)
		self:init_enemy(x,y, images.big_red_button_crack3, 58, 45)
		self.name = "button_glass"
		self.follow_player = false

		self.max_life = 80
		self.life = self.max_life
		self.activ_thresh = 40
		self.break_range = self.life - self.activ_thresh
		self.knockback = 0

		self.is_solid = true
		self.is_stompable = false
		self.is_pushable = false
		self.is_knockbackable = false

		self.damage = 0
		self.screenshake = 0
		self.max_screenshake = 4

		self.break_state = 3
		self.loot = {}

		self.play_sfx = false
	end

	function self.ButtonGlass:update(dt)
		self:update_enemy(dt)

		if self.life < self.activ_thresh then
			--self.spr = images.big_red_button
		end
	end
	
	function self.ButtonGlass:on_damage(n, old_life)
		local k = 4
		local old_state = self.break_state
		local part = self.max_life / k
		local new_state = floor(self.life / part)

		local sndname = "impactglass_light_00"..random_str(1,4)
		local pitch = random_range(1/1.1, 1.1) - .5*self.life/self.max_life
		audio:play(sndname, random_range(1-0.2, 1), pitch)
		
		if old_state ~= new_state then
			self.break_state = new_state
			local spr = images["big_red_button_crack"..tostring(self.break_state)]
			spr = spr or images.big_red_button_crack3

			self.spr = spr
			game:screenshake(10)
			particles:image(self.mid_x, self.mid_y, 100, images.ptc_glass_shard, self.h)
			local pitch = max(0.1, lerp(0.5, 1, self.life/self.max_life))
			audio:play("glass_fracture", nil, pitch)
		end

		if game.screenshake_q < 5 then
			game:screenshake(2)
		end
	end

	local Button = self.Button
	function self.ButtonGlass:on_death()
		audio:play("glass_break")
		game:screenshake(15)
		particles:image(self.mid_x, self.mid_y, 300, images.ptc_glass_shard, self.h)

		local b = create_actor_centered(Button, CANVAS_WIDTH/2, game.world_generator.box_rby)
		game:new_actor(b)
	end
	
end

return Enemies:new()