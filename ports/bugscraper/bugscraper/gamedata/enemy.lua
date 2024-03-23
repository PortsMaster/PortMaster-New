require "util"
local Class = require "class"
local Actor = require "actor"
local Loot = require "loot"
local images = require "data.images"
local sounds = require "data.sounds"

local Enemy = Actor:inherit()

function Enemy:init_enemy(x,y, img, w,h)
	-- TODO: abstract enemies and players into a single "being" class
	-- "Being" means players, enemies, etc, but not bullets, etc
	-- They have life, can take or deal damage, and inherit Actor:
	-- so they have velocity and collision. 
	w,h = w or 12, h or 12
	self:init_actor(x, y, w, h, img or images.duck)
	self.name = "enemy"
	self.counts_as_enemy = true -- don't count in the enemy counter
	self.is_being = true 
	self.is_enemy = true
	self.is_flying = false
	self.is_active = true
	self.follow_player = true

	self.destroy_bullet_on_impact = true
	self.is_bouncy_to_bullets = false
	self.is_immune_to_bullets = false

	self.harmless_frames = 0

	self.max_life = 10
	self.life = self.max_life
	self.color = COL_BLUE
	self.speed = 20
	self.speed_x = self.speed
	self.speed_y = 0

	self.loot = {
		{nil, 80},
		-- {Loot.Ammo, 0, loot_type="ammo", value=20},
		{Loot.Life, 3, loot_type="life", value=1},
		{Loot.Gun, 3, loot_type="gun"},
	}

	self.is_stompable = true
	self.do_stomp_animation = true
	self.is_pushable = true
	self.is_knockbackable = true -- Multiplicator when knockback is applied to

	self.damage = 1
	self.knockback = 1200
	self.self_knockback_mult = 1 -- Basically weight (?)

	self.damaged_flash_timer = 0
	self.damaged_flash_max = 0.07

	self.squash = 1
	self.squash_target = 1
	
	self.play_sfx = true
	self.sound_damage = "enemy_damage"
	self.sound_death = "enemy_death_1"
	self.sound_stomp = "enemy_death_1"
	-- self.sound_stomp = {"enemy_stomp_2", "enemy_stomp_3"}
	--{"crush_bug_1", "crush_bug_2", "crush_bug_3", "crush_bug_4"}
end

function Enemy:update_enemy(dt)
	-- if not self.is_active then    return    end
	self:update_actor(dt)
	
	self:follow_nearest_player(dt)
	self.harmless_frames = max(self.harmless_frames - dt, 0)
	self.damaged_flash_timer = max(self.damaged_flash_timer - dt, 0)

	if self.life <= 0 then
		self:remove()
	end
end
function Enemy:update(dt)
	self:update_enemy(dt)
end

function Enemy:get_nearest_player()
	local shortest_dist = math.huge
	local nearest_player 
	for _, ply in pairs(game.players) do
		local dist = distsqr(self.x, self.y, ply.x, ply.y)
		if dist < shortest_dist then
			shortest_dist = dist
			nearest_player = ply
		end
	end
	return nearest_player
end

function Enemy:follow_nearest_player(dt)
	if not self.follow_player then    return    end

	-- Find closest player
	local nearest_player = self:get_nearest_player()
	if not nearest_player then    return    end
	
	self.speed_x = self.speed_x or self.speed
	if self.is_flying then    self.speed_y = self.speed_y or self.speed 
	else                      self.speed_y = self.speed_y or 0    end 

	self.vx = self.vx + sign0(nearest_player.x - self.x) * self.speed_x
	self.vy = self.vy + sign0(nearest_player.y - self.y) * self.speed_y
end

function Enemy:draw_enemy()
	local f = (self.damaged_flash_timer > 0) and draw_white or gfx.draw
	self:draw_actor(self.vx < 0, _, f)

	if game.debug_mode then
		gfx.draw(images.heart, self.x-7 -2+16, self.y-16)
		print_outline(COL_WHITE, COL_DARK_BLUE, self.life, self.x+16, self.y-16-2)
	end
end

function Enemy:draw()
	self:draw_enemy()
end

function Enemy:on_collision(col, other)
	-- If hit wall, reverse x vel (why is this here?????) TODO: wtf
	if col.other.is_solid and col.normal.y == 0 then 
		self.vx = -self.vx
	end

	-- Player
	if col.other.is_player then
		local player = col.other
		
		-- Being stomped
		local epsilon = 0.01
	
		-- if player.vy > epsilon and self.is_stompable then
		local recently_landed = 0 < player.frames_since_land and player.frames_since_land <= 7
		if (player.vy > 0.0001 or recently_landed) and self.is_stompable then
			player.vy = 0
			player:on_stomp(self)
			if self.do_stomp_animation then
				particles:stomped_enemy(self.spr_x, self.spr_y, self.spr)
			end
			self:on_stomped(player)
			self:kill(player, "stomped")

		else
			-- Damage player
			if self.harmless_frames <= 0 then
				player:do_damage(self.damage, self)
			end
		end

	end
	
	-- Being collider push force
	if col.other.is_being and self.is_pushable then
		self:do_knockback(10, col.other)
		col.other:do_knockback(10, self)
	end

	self:after_collision(col, col.other)
end

function Enemy:after_collision(col, other)  end

function Enemy:do_damage(n, damager)
	self.damaged_flash_timer = self.damaged_flash_max
	
	if self.play_sfx then   audio:play_var(self.sound_damage, 0.3, 1.1)   end
	self.life = self.life - n
	self:on_damage(n, self.life + n)

	if self.life <= 0 then
		self:kill(damager)
	end
end

function Enemy:on_damage()

end

function Enemy:on_stomped(damager)

end

function Enemy:kill(damager, reason)
	if self.is_removed then print(concat("/!\\:", self.name, "(", self, ") was killed while destroyed")) end
	self.death_reason = reason or ""

	game:frameskip(1)
	particles:smoke(self.mid_x, self.mid_y)
	if self.play_sfx then
		if reason == "stomped" then
			audio:play_var(self.sound_stomp, 0.3, 1.1)
		else
			audio:play_var(self.sound_death, 0.3, 1.1)
		end
	end

	game:on_kill(self)
	self:remove()
	
	self:drop_loot()
	self:on_death(damager, reason)
end

function Enemy:drop_loot()
	local loot, parms = random_weighted(self.loot)
	if not loot then            return    end
	
	local instance
	local vx = random_neighbor(300)
	local vy = random_range(-200, -500)
	local loot_type = parms.loot_type
	if loot_type == "ammo" or loot_type == "life" or loot_type == "gun" then
		instance = loot:new(self.mid_x, self.mid_y, parms.value, vx, vy)
	end 

	game:new_actor(instance)
end

function Enemy:on_death()
	
end

function Enemy:on_hit_bullet(bul, col)
	if self.is_immune_to_bullets then    return    end
	self:do_damage(bul.damage, bul)
	
	if self.is_knockbackable then
		-- self:do_knockback(bul.knockback * self.self_knockback_mult, bul)
		local ang = atan2(bul.vy, bul.vx)
		self.vx = self.vx + cos(ang) * bul.knockback
		self.vy = self.vy + sin(ang) * bul.knockback
	end
end

return Enemy