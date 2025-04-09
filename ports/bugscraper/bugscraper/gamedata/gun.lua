require "util"
local Class = require "class"
local Bullet = require "bullet"
local sounds = require "data.sounds"
local images = require "data.images"

local Gun = Class:inherit()

function Gun:init_gun(user)
	self.spr = images.gun_machinegun
	self.x, self.y = 0, 0
	self.rot = 0
	
	self.is_lootable = true
	self.user = user -- The actor using the gun
	
	self.is_auto = true
	
	-- Bullet
	self.bul_w = 12
	self.bul_h = 12
	
	self.bullet_speed = 600
	self.bullet_number = 1
	self.bullet_spread = 0.2
	self.bullet_friction = 1
	self.random_angle_offset = 0.1
	self.random_speed_offset = 40
	self.random_friction_offset = 0
	
	self.knockback = 500
	
	self.speed_floor = 3 -- min speed before it despawns
	
	--
	self.damage = 2
	
	-- Ammo
	self.max_ammo = 100
	self.ammo = math.huge
	self.is_reloading = false
	self.reload_timer = 0
	self.max_reload_timer = 1
	
	-- Cooldown
	self.cooldown = 0.3
	self.cooldown_timer = 0
	
	-- Burst
	self.is_burst = false
	self.burst_count = 1
	self.burst_delay = 0
	
	self.burst_counter = 0
	self.burst_delay_timer = 0
	
	-- Jetpack
	self.default_jetpack_force = 340
	self.jetpack_force = self.default_jetpack_force
	
	-- Sounds
	self.sfx = "shot1"
	self.sfx_pitch_var = 1.15
	self.sfx_pitch = 1
	
	self.screenshake = 0
end

function Gun:update(dt)
	if not self.recoil_force then self.recoil_force = self.default_jetpack_force*0.25 end
	
	self.dt = dt
	self.cooldown_timer = max(self.cooldown_timer - dt, 0)
	self.reload_timer = max(self.reload_timer - dt, 0)
	if self.reload_timer <= 0 and self.is_reloading then
		self.is_reloading = false
		self.ammo = self.max_ammo
	end
	self.ammo = clamp(self.ammo, 0, self.max_ammo)

	-- Burst
	self.burst_delay_timer = max(0, self.burst_delay_timer - dt)

	if self.is_burst and   self.burst_counter > 0 and self.burst_delay_timer <= 0 then
		self.burst_delay_timer = self.burst_delay

		-- Force shoot
		self.user:shoot(dt, true)
	end
end

function Gun:draw(flip_x, flip_y, rot)
	local ox, oy = floor(self.spr:getWidth()/2), floor(self.spr:getHeight()/2)
	flip_x, flip_y = bool_to_dir(flip_x), bool_to_dir(flip_y)

	gfx.draw(self.spr, floor(self.x), floor(self.y), self.rot, flip_x, flip_y, ox, oy)
	-- gfx.print(concat("cooldown_timer", self.cooldown_timer), self.x, self.y-64)
	-- gfx.print(concat("burst_count", self.burst_count), self.x, self.y-64+16)
	-- gfx.print(concat("burst_counter", self.burst_counter), self.x, self.y-64+32)
end

function Gun:shoot(dt, player, x, y, dx, dy, is_burst)
	dx = dx or 0
	dy = dy or 0
	-- Normalize direction vector
	local d = dist(dx, dy)
	dx = dx/d
	dy = dy/d
	local is_first_fire = not is_burst

	-- Sanity checks
	-- + reloading
	if self.ammo <= 0 then
		return false
	end

	-- If first shot but cooldown too big, escape
	if is_first_fire and self.cooldown_timer > 0 then    return false    end
	if is_first_fire and self.reload_timer > 0 then    return false    end

	-- If first fire, reset burst timer & cooldown
	if is_first_fire and self.is_burst then
		self.burst_counter = self.burst_count
	end
	
	-- Now, FIRE!!
	-- SFX & Particles
	audio:play_var(self.sfx, 0.2, 1.2, {pitch=self.sfx_pitch})
	if self.sfx2 then
		audio:play_var(self.sfx2, 0.2, 1.2, {pitch=self.sfx_pitch})
	end
	particles:image(x , y, 1, images.ptc_bullet_casing, 4, nil, nil, nil, {
		vx1 = -dx * 40,
		vx2 = -dx * 100,

		vy1 = -40,
		vy2 = -80,
	})

	if is_first_fire then    self.cooldown_timer = self.cooldown    end
	self.ammo = self.ammo - 1
	-- self.ammo = self.ammo - self.bullet_number

	local ang = atan2(dy, dx)
	local gunw = max(0, self.spr:getWidth() - 8)
	local x = floor(x + cos(ang) * gunw)
	local y = floor(y + sin(ang) * gunw)

	-- Update Burst timer
	if self.is_burst then
		self.burst_counter = self.burst_counter - 1
	end

	if self.bullet_number == 1 then
		-- If only fire 1 bullet 
		local ang = ang + random_neighbor(self.random_angle_offset)
		dx, dy = cos(ang), sin(ang)
		particles:flash(x, y)
		self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, dx, dy)
	else
		-- If fire multiple bullets
		local step = (self.bullet_spread*2) / (self.bullet_number-1)
		for i = 0, self.bullet_number-1 do
			-- Compute fire angle
			local rand_o = random_neighbor(self.random_angle_offset)
			local a = ang-self.bullet_spread + i*step + rand_o
			local dx = cos(a)
			local dy = sin(a)
			particles:flash(x, y)
			self:fire_bullet(dt, player, x, y, self.bul_w, self.bul_h, dx, dy)
		end
	end

	self:on_shoot()

	-- Reload if ammo is 0
	if self.ammo == 0 and not self.is_reloading then
		self:reload()
	end

	return true
end
function Gun:on_shoot()
end

function Gun:reload()
	self.is_reloading = true
	self.reload_timer = self.max_reload_timer
end

function Gun:fire_bullet(dt, player, x, y, bul_w, bul_h, dx, dy)
	local spd = self.bullet_speed + random_neighbor(self.random_speed_offset)
	local spd_x = dx * spd
	local spd_y = dy * spd 
	game:new_actor(Bullet:new(self, player, x, y, bul_w, bul_h, spd_x, spd_y))
end

function Gun:add_ammo(quantity)
	local overflow = self.max_ammo - (self.ammo + quantity)
	if overflow >= 0 then
		self.ammo = self.ammo + quantity
		return true
	else
		self.ammo = self.max_ammo
		return false, -overflow
	end
end

return Gun