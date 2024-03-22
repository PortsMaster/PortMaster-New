local Class = require "class"
local Actor = require "actor"
local images = require "data.images"

local Bullet = Actor:inherit()

function Bullet:init(gun, player, x, y, w, h, vx, vy)
	local x, y = x-w/2, y-h/2
	self:init_actor(x, y, w, h, gun.bullet_spr or images.bullet)
	self.gun = gun
	self.player = player
	self.is_enemy_bul = player.is_enemy
	self.is_bullet = true

	self.friction = gun.bullet_friction - random_range(0, gun.random_friction_offset)
	self.friction_x = self.friction
	self.friction_y = self.friction
	self.gravity = 0

	self.speed = 1--300
	self.dir = 0
	
	self.vx = vx or 0
	self.vy = vy or 0
	self.speed_floor = gun.speed_floor

	self.life = 5

	self.damage = gun.damage
	self.knockback = gun.knockback or 500
end

function Bullet:update(dt)
	self:update_actor(dt)

	self.rot = atan2(self.vy, self.vx)

	self.life = self.life - dt
	if self.life < 0 then
		self:remove()
	end

	local v_sq = distsqr(self.vx, self.vy)
	if v_sq <= self.speed_floor then
		self:kill()
	end 
end

function Bullet:draw()
	self:draw_actor()
	--gfx.draw(self.spr, self.x, self.y)
end

function Bullet:on_collision(col)
	if col.other == self.player then    return   end
	
	if not self.is_removed and col.other.is_solid then
		local s = "metalfootstep_0"..tostring(love.math.random(0,4))
		audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
		self:kill()
	end
	
	if col.other.on_hit_bullet and col.other.is_enemy ~= self.is_enemy_bul then
		col.other:on_hit_bullet(self, col)
		if col.other.destroy_bullet_on_impact then
			local s = "metalfootstep_0"..tostring(love.math.random(0,4))
			audio:play_var(s, 0.3, 1, {pitch=0.7, volume=0.5})
			self:kill()
		end

		if col.other.is_bouncy_to_bullets then
			-- TODO: actual bounce that makes sense in the laws of physics (angle mirror)
			local bounce_x = (self.mid_x - col.other.mid_x)
			local bounce_y = (self.mid_y - col.other.mid_y)
			local bounce_a = atan2(bounce_y, bounce_x)

			local vel_r = dist(self.vx, self.vy)
			local vel_a = atan2(-self.vy, -self.vx)

			local new_a = bounce_a + vel_a
			local new_vx, new_vy = cos(new_a) * vel_r, sin(new_a) * vel_r 

			local spd_slow = 1
			-- self.friction_x = spd_slow
			-- self.friction_y = spd_slow
			self.vx = new_vx * spd_slow
			self.vy = new_vy * spd_slow
		end
	end
	
	self:after_collision(col)
end

function Bullet:kill()
	particles:smoke(self.x + self.w/2, self.y + self.h/2)
	self:remove()
end

function Bullet:after_collision(col)
	local other = col.other
	--[[
	if other.type == "tile" then
		game.map:set_tile(other.ix, other.iy, 0)
	end
	--]]
end

return Bullet