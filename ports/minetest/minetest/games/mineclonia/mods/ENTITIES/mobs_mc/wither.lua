--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local follow_spawner = minetest.settings:get_bool("wither_follow_spawner") ~= false
local w_strafes = minetest.settings:get_bool("wither_strafes") ~= false

local WITHER_INIT_BOOM = 7
local WITHER_MELEE_COOLDOWN = 3

local function atan(x)
	if not x or x ~= x then
		return 0
	else
		return math.atan(x)
	end
end

--###################
--################### WITHER
--###################

local function wither_unstuck(self)
	local pos = self.object:get_pos()
	if mobs_griefing then
		local col = self.object:get_properties().collisionbox or mcl_mobs.registered_mobs["mobs_mc:wither"].initial_properties.collisionbox
		local pos1 = vector.offset(pos, col[1], col[2], col[3])
		local pos2 = vector.offset(pos, col[4], col[5], col[6])
		for z = pos1.z, pos2.z do for y = pos1.y, pos2.y do for x = pos1.x, pos2.x do
			local npos = vector.new(x,y,z)
			local name = minetest.get_node(npos).name
			if name ~= "air" then
				local ndef = minetest.registered_nodes[name]
				if ndef and ndef._mcl_hardness and ndef._mcl_hardness >= 0 then
					local drops = minetest.get_node_drops(name, "")
					if minetest.dig_node(npos) then
						for _, item in ipairs(drops) do
							if type(item) ~= "string" then
								item = item:get_name() .. item:get_count()
							end
							minetest.add_item(npos, item)
						end
					end
				end
			end
		end end end
	end
	mcl_mobs.mob_class.safe_boom(self, pos, 2)
end

local function get_dim_relative_y(pos)
		if (pos.y >= mcl_vars.mg_realm_barrier_overworld_end_max) then
			return pos.y
		elseif (pos.y <= mcl_vars.mg_nether_max + 200) then
			return (pos.y - mcl_vars.mg_nether_min - 20)
		else
			return (pos.y - mcl_vars.mg_end_min - 50)
		end
end

mcl_mobs.register_mob("mobs_mc:wither", {
	description = S("Wither"),
	type = "monster",
	spawn_class = "hostile",
	hp_max = 300,
	hp_min = 300,
	xp_min = 50,
	xp_max = 50,
	armor = {undead = 80, fleshy = 100},
	-- This deviates from MC Wiki's size, which makes no sense
	collisionbox = {-0.9, 0.4, -0.9, 0.9, 2.45, 0.9},
	doll_size_override = { x = 1.2, y = 1.2 },
	visual = "mesh",
	mesh = "mobs_mc_wither.b3d",
	textures = {
		{"mobs_mc_wither.png"},
	},
	visual_size = {x=4, y=4},
	view_range = 50,
	fear_height = 4,
	walk_velocity = 2,
	run_velocity = 4,
	strafes = w_strafes,
	sounds = {
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		-- TODO: sounds
		distance = 60,
	},
	jump = true,
	jump_height = 10,
	fly = true,
	makes_footstep_sound = false,
	dogshoot_switch = 1, -- unused
	dogshoot_count_max = 1, -- unused
	can_despawn = false,
	drops = {
		{name = "mcl_mobitems:nether_star",
		chance = 1,
		min = 1,
		max = 1},
	},
	lava_damage = 0,
	fire_damage = 0,
	attack_type = "custom",
	explosion_strength = 8,
	dogshoot_stop = true,
	arrow = "mobs_mc:wither_skull",
	reach = 5,
	shoot_interval = 1,
	shoot_offset = -0.5,
	animation = {
		walk_speed = 12, run_speed = 12, stand_speed = 12,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	harmed_by_heal = true,
	is_boss = true,
	extra_hostile = true,
	attack_exception = function(p)
		local ent = p:get_luaentity()
		if p:is_player() then return false end
		if not ent or not ent.is_mob or ent.harmed_by_heal or string.find(ent.name, "ghast") then return true
		else return false end
	end,

	do_custom = function(self, dtime)
		if self._spawning then
			if not self._spw_max then self._spw_max = self._spawning end
			self._spawning = self._spawning - dtime
			local bardef = {
				color = "dark_purple",
				text = "Wither spawning",
				percentage = math.floor((self._spw_max - self._spawning) / self._spw_max * 100),
			}

			local pos = self.object:get_pos()
			for _, player in pairs(minetest.get_connected_players()) do
				local d = vector.distance(pos, player:get_pos())
				if d <= 80 then
					mcl_bossbars.add_bar(player, bardef, true, d)
				end
			end
			self.object:set_yaw(self._spawning*10)

			local factor = math.floor((math.sin(self._spawning*10)+1.5) * 85)
			local str = minetest.colorspec_to_colorstring({r=factor, g=factor, b=factor})
			self.object:set_texture_mod("^[brighten^[multiply:"..str)

			if self._spawning <= 0 then
				if mobs_griefing and not minetest.is_protected(pos, "") then
					mcl_explosions.explode(pos, WITHER_INIT_BOOM, { drop_chance = 1.0 }, self.object)
				else
					mcl_mobs.mob_class.safe_boom(self, pos, WITHER_INIT_BOOM)
				end
				self.object:set_texture_mod("")
				self._spawning = nil
				self._spw_max = nil
			else
				return false
			end
		end

		self._custom_timer = self._custom_timer + dtime
		if self._custom_timer > 1 then
			self.health = math.min(self.health + 1, self.object:get_properties().hp_max)
			self._custom_timer = self._custom_timer - 1
		end
		if self._spawner then
			local spawner = minetest.get_player_by_name(self._spawner)
			if spawner then
				self._death_timer = 0
				local pos = self.object:get_pos()
				local spw = spawner:get_pos()
				local dist = vector.distance(pos, spw)
				if dist > 60 and follow_spawner then -- teleport to the player who spawned the wither
					local R = 10
					pos.x = spw.x + math.random(-R, R)
					pos.y = spw.y + math.random(-R, R)
					pos.z = spw.z + math.random(-R, R)
					self.object:set_pos(pos)
				end
			else
				self._death_timer = self._death_timer + self.health - self._health_old
				if self.health == self._health_old then self._death_timer = self._death_timer + dtime end
				if self._death_timer > 100 then
					self.object:remove()
					return false
				end
				self._health_old = self.health
			end
		end

		local rand_factor
		if self.health < (self.object:get_properties().hp_max / 2) then
			self.base_texture = "mobs_mc_wither_half_health.png"
			self.fly = false
			self._arrow_resistant = true
			rand_factor = 3
		else
			self.base_texture = "mobs_mc_wither.png"
			self.fly = true
			self._arrow_resistant = false
			rand_factor = 10
		end
		if not self.attack then
			local y = get_dim_relative_y(self.object:get_pos())
			if y > 0 then
				self.fly = false
			else
				self.fly = true
				local vel = self.object:get_velocity()
				self.object:set_velocity(vector.new(vel.x, self.walk_velocity, vel.z))
			end
		end
		self.object:set_properties({textures={self.base_texture}})
		mcl_bossbars.update_boss(self.object, "Wither", "dark_purple")
		if math.random(1, rand_factor) < 2 then
			self.arrow = "mobs_mc:wither_skull_strong"
		else
			self.arrow = "mobs_mc:wither_skull"
		end
	end,

	attack_state = function(self, dtime)
		local s = self.object:get_pos()
		local p = self.attack:get_pos() or s

		p.y = p.y - .5
		s.y = s.y + .5

		local dist = vector.distance(p, s)
		local vec = {
			x = p.x - s.x,
			y = p.y - s.y,
			z = p.z - s.z
		}

		local yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate
		if p.x > s.x then yaw = yaw +math.pi end
		yaw = self:set_yaw( yaw, 0, dtime)

		local stay_away_from_player = vector.zero()

		--strafe back and fourth

		--stay away from player so as to shoot them
		if dist < self.avoid_distance and self.shooter_avoid_enemy then
			self:set_animation( "shoot")
			stay_away_from_player=vector.multiply(vector.direction(p, s), 0.33)
		end

		if self.fly then
			local vel = self.object:get_velocity()
			local diff = s.y - p.y
			local FLY_FACTOR = self.walk_velocity
			if diff < 10 then
				self.object:set_velocity({x=vel.x, y= FLY_FACTOR, z=vel.z})
			elseif diff > 15 then
				self.object:set_velocity({x=vel.x, y=-FLY_FACTOR, z=vel.z})
			end
			for i=1, 15 do
				if minetest.get_node(vector.offset(s, 0, -i, 0)).name ~= "air" then
					self.object:set_velocity({x=vel.x, y= FLY_FACTOR,   z=vel.z})
					break
				elseif minetest.get_node(vector.offset(s, 0, i, 0)).name ~= "air" then
					self.object:set_velocity({x=vel.x, y=-FLY_FACTOR/i, z=vel.z})
					break
				end
			end
		end

		if self.strafes then
			if not self.strafe_direction then
				self.strafe_direction = 1.57
			end
			if math.random(40) == 1 then
				self.strafe_direction = self.strafe_direction*-1
			end

			local dir = vector.rotate_around_axis(vector.direction(s, p), vector.new(0,1,0), self.strafe_direction)
			local dir2 = vector.multiply(dir, 0.3 * self.walk_velocity)

			if dir2 and stay_away_from_player then
				self.acc = vector.add(dir2, stay_away_from_player)
			end
		else
			self:set_velocity(0)
		end

		if dist > 30 then self.acc = vector.add(self.acc, vector.direction(s, p)*0.01) end

		local side_cor = vector.new(0.7*math.cos(yaw), 0, 0.7*math.sin(yaw))
		local m = self.object:get_pos() -- position of the middle head
		local sr = self.object:get_pos() + side_cor -- position of side right head
		local sl = self.object:get_pos() - side_cor -- position of side left head
		-- height corrections
		local cb = self.object:get_properties().collisionbox
		m.y = m.y + cb[5]
		sr.y = sr.y + cb[5] - 0.3
		sl.y = sl.y + cb[5] - 0.3
		local rand_pos = math.random(1,3)
		if rand_pos == 1 then m = sr
		elseif rand_pos == 2 then m = sl end

		-- melee attack
		if not self._melee_timer then
			self._melee_timer = 0
		end
		if self._melee_timer < WITHER_MELEE_COOLDOWN then
			self._melee_timer = self._melee_timer + dtime
		else
			self._melee_timer = 0
			local pos = table.copy(s)
			pos.y = pos.y + 2
			local objs = minetest.get_objects_inside_radius(pos, self.reach)
			local hit_some = false
			for n = 1, #objs do
				objs[n]:punch(objs[n], 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 4},
				}, pos)
				local ent = objs[n]:get_luaentity()
				if objs[n]:is_player() or (ent and ent ~= self and (not ent._shooter or ent._shooter ~= self)) then
					mcl_util.deal_damage(objs[n], 8, {type = "magic"})
					hit_some = true
				end
				mcl_mobs.effect_functions["withering"](objs[n], 0.5, 10)
			end
			if hit_some then
				mcl_mobs.effect(pos, 32, "mcl_particles_soul_fire_flame.png", 5, 10, self.reach, 1, 0)
			end
		end

		if dist < self.reach then
			self.shoot_interval = 3
		else
			self.shoot_interval = 1
		end

		if self.shoot_interval
				and self.timer > self.shoot_interval
				and not minetest.raycast(vector.add(m, vector.new(0,self.shoot_offset,0)), vector.add(self.attack:get_pos(), vector.new(0,1.5,0)), false, false):next()
				and math.random(1, 100) <= 60 then

			self.timer = 0
			self:set_animation( "shoot")

			-- play shoot attack sound
			self:mob_sound("shoot_attack")

			-- Shoot arrow
			if minetest.registered_entities[self.arrow] then

				local arrow, ent
				local v = 1
				if not self.shoot_arrow then
					self.firing = true
					minetest.after(1, function()
						self.firing = false
					end)
					arrow = minetest.add_entity(m, self.arrow)
					ent = arrow:get_luaentity()
					if ent.velocity then
						v = ent.velocity
					end
					ent.switch = 1
					ent.owner_id = tostring(self.object) -- add unique owner id to arrow

					-- important for mcl_shields
					ent._shooter = self.object
					ent._saved_shooter_pos = self.object:get_pos()
				end

				local amount = (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
				-- offset makes shoot aim accurate
				vec.y = vec.y + self.shoot_offset
				vec.x = vec.x * (v / amount)
				vec.y = vec.y * (v / amount)
				vec.z = vec.z * (v / amount)
				if self.shoot_arrow then
					vec = vector.normalize(vec)
					self:shoot_arrow(m, vec)
				else
					arrow:set_velocity(vec)
				end
			end
		end
	end,

	do_punch = function(self, hitter, tflp, tool_capabilities, dir)
		if self._spawning or hitter == self.object then return false end
		local ent = hitter:get_luaentity()
		if ent and self._arrow_resistant and (string.find(ent.name, "arrow") or string.find(ent.name, "rocket")) then return false end
		wither_unstuck(self)
		return true
	end,
	deal_damage = function(self, damage, mcl_reason)
		if self._spawning then return end
		if self._arrow_resistant and mcl_reason.type == "magic" then return end
		wither_unstuck(self)
		self.health = self.health - damage
	end,

	on_spawn = function(self)
		minetest.sound_play("mobs_mc_wither_spawn", {object=self.object, gain=1.0, max_hear_distance=64})
		self._custom_timer = 0.0
		self._death_timer = 0.0
		self._health_old = self.object:get_properties().hp_max
		self._spawning = 10
		return true
	end,

})

local wither_rose_soil = { "group:grass_block", "mcl_core:dirt", "mcl_core:coarse_dirt", "mcl_nether:netherrack", "group:soul_block", "mcl_mud:mud", "mcl_lush_caves:moss" }
local function spawn_wither_rose(obj)
	local n = minetest.find_node_near(obj:get_pos(),2,wither_rose_soil)
	if n then
		local p = vector.offset(n,0,1,0)
		if minetest.get_node(p).name == "air" then
			if not ( mobs_griefing and minetest.place_node(p,{name="mcl_flowers:wither_rose"}) ) then
				minetest.add_item(p,"mcl_flowers:wither_rose")
			end
		end
	end
end

mcl_mobs.register_arrow("mobs_mc:wither_skull", {
	visual = "cube",
	visual_size = {x = 0.3, y = 0.3},
	textures = {
		"mobs_mc_wither_projectile.png^[verticalframe:6:0", -- top
		"mobs_mc_wither_projectile.png^[verticalframe:6:1", -- bottom
		"mobs_mc_wither_projectile.png^[verticalframe:6:2", -- left
		"mobs_mc_wither_projectile.png^[verticalframe:6:3", -- right
		"mobs_mc_wither_projectile.png^[verticalframe:6:4", -- back
		"mobs_mc_wither_projectile.png^[verticalframe:6:5", -- front
	},
	velocity = 7,
	rotate = 90,
	_lifetime = 350,
	on_punch = function(self) end,

	-- direct hit
	hit_player = function(self, player)
		mcl_mobs.effect_functions["withering"](player, 0.5, 10)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1, false, true)
		mcl_mobs.get_arrow_damage_func(8, "wither_skull")(self, player)
		if player:get_hp() <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(player)
		end
	end,

	hit_mob = function(self, mob)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		mcl_mobs.get_arrow_damage_func(8, "wither_skull")(self, mob)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1, false, true)
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(mob)
		end
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self,pos, 1, false, true)
	end
})

mcl_mobs.register_arrow("mobs_mc:wither_skull_strong", {
	visual = "cube",
	visual_size = {x = 0.35, y = 0.35},
	textures = {
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:0", -- top
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:1", -- bottom
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:2", -- left
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:3", -- right
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:4", -- back
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:5", -- front
	},
	velocity = 4,
	rotate = 90,
	_lifetime = 500,
	on_punch = function(self) end,

	-- direct hit
	hit_player = function(self, player)
		mcl_mobs.effect_functions["withering"](player, 0.5, 10)
		mcl_mobs.get_arrow_damage_func(12, "wither_skull")(self, player)
		if player:get_hp() <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(player)
		end
	end,

	hit_mob = function(self, mob)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		mcl_mobs.get_arrow_damage_func(12, "wither_skull")(self, mob)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		local pos = self.object:get_pos()
		if mobs_griefing and not minetest.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, { drop_chance = 1.0, max_blast_resistance = 0, }, self.object)
		else
			mcl_mobs.mob_class.safe_boom(self, pos, 1, true) --need to call it this way bc self is the "arrow" object here
		end
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
			local shooter = self._shooter:get_luaentity()
			if shooter then shooter.health = shooter.health + 5 end
			spawn_wither_rose(mob)
		end
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		if mobs_griefing and not minetest.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, { drop_chance = 1.0, max_blast_resistance = 0, }, self.object)
		else
			mcl_mobs.mob_class.safe_boom(self, pos, 1, true) --need to call it this way bc self is the "arrow" object here
		end
	end
})

--Spawn egg
mcl_mobs.register_egg("mobs_mc:wither", S("Wither"), "#4f4f4f", "#4f4f4f", 0, true)

mcl_wip.register_wip_item("mobs_mc:wither")
