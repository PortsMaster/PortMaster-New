-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models -hi 22i ~jordan4ibanez
-- blaze.lua partial copy of mobs_mc/ghast.lua

local S = minetest.get_translator("mobs_mc")

local mod_target = minetest.get_modpath("mcl_target")

--###################
--################### BLAZE
--###################

local function check_light(pos, environmental_light, artificial_light, sky_light)
	if artificial_light > 11 then
		return false, "To bright"
	end
	return true, ""
end

mcl_mobs.register_mob("mobs_mc:blaze", {
	description = S("Blaze"),
	type = "monster",
	spawn_class = "hostile",
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	hp_min = 20,
	hp_max = 20,
	xp_min = 10,
	xp_max = 10,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.79, 0.3},
	rotate = -180,
	visual = "mesh",
	mesh = "mobs_mc_blaze.b3d",
	head_swivel = "head.control",
	bone_eye_height = 4,
	head_eye_height = 3.5,
	curiosity = 10,
	head_yaw_offset = 180,
	head_pitch_multiplier=-1,
	textures = {
		{"mobs_mc_blaze.png"},
	},
	armor = { fleshy = 100, snowball_vulnerable = 100, water_vulnerable = 100 },
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_blaze_breath",
		death = "mobs_mc_blaze_died",
		damage = "mobs_mc_blaze_hurt",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 6,
	reach = 2,
	pathfinding = 1,
	drops = {
		{name = "mcl_mobitems:blaze_rod",
		chance = 1,
		min = 0,
		max = 1,
		looting = "common",},
	},
	animation = {
		stand_speed = 25,
		stand_start = 0,
	        stand_end = 100,
	        walk_speed = 25,
		walk_start = 0,
		walk_end = 100,
		run_speed = 50,
		run_start = 0,
		run_end = 100,
	},
	-- MC Wiki: takes 1 damage every half second while in water
	water_damage = 2,
	lava_damage = 0,
	fire_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs_mc:blaze_fireball",
	shoot_interval = 3.5,
	shoot_offset = 1.0,
	passive = false,
	jump = true,
	jump_height = 4,
	fly = true,
	makes_footstep_sound = false,
	fear_height = 0,
	glow = 14,
	fire_resistant = true,
	do_custom = function(self)
		if self.state == "attack" and self.attack:get_pos() and vector.distance(self.object:get_pos(), self.attack:get_pos()) < 1.2 then
			mcl_burning.set_on_fire(self.attack, 5)
		end
		local pos = self.object:get_pos()
		minetest.add_particle({
			pos = {x=pos.x+math.random(-0.7,0.7)*math.random()/2,y=pos.y+math.random(0.7,1.2),z=pos.z+math.random(-0.7,0.7)*math.random()/2},
			velocity = {x=0, y=math.random(1,1), z=0},
			expirationtime = math.random(),
			size = math.random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#2c2c2c:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
		})
		minetest.add_particle({
			pos = {x=pos.x+math.random(-0.7,0.7)*math.random()/2,y=pos.y+math.random(0.7,1.2),z=pos.z+math.random(-0.7,0.7)*math.random()/2},
			velocity = {x=0, y=math.random(1,1), z=0},
			expirationtime = math.random(),
			size = math.random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#424242:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
		})
		minetest.add_particle({
			pos = {x=pos.x+math.random(-0.7,0.7)*math.random()/2,y=pos.y+math.random(0.7,1.2),z=pos.z+math.random(-0.7,0.7)*math.random()/2},
			velocity = {x=0, y=math.random(1,1), z=0},
			expirationtime = math.random(),
			size = math.random(1, 4),
			collisiondetection = true,
			vertical = false,
			texture = "mcl_particles_smoke_anim.png^[colorize:#0f0f0f:255",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 2.05,
			},
		})
	end,
	check_light = check_light,
})

-- Blaze fireball
mcl_mobs.register_arrow("mobs_mc:blaze_fireball", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 15,
	_is_fireball = true,

	-- Direct hit, no fire... just plenty of pain
	hit_player = mcl_mobs.get_arrow_damage_func(5, "fireball"),
	hit_mob = mcl_mobs.get_arrow_damage_func(5, "fireball"),

	hit_object = function(self, object)
		local lua = object:get_luaentity()
		if lua then
			if lua.name == "mcl_minecarts:tnt_minecart" then
				lua:on_activate_by_rail(2)
			end
		end
	end,

	-- Node hit, make fire
	hit_node = function(self, pos, node)
		if node == "air" then
			minetest.set_node(pos, {name = "mcl_fire:fire"})
		else
			if self._shot_from_dispenser and mod_target and node == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			local v = vector.normalize(self.object:get_velocity())
			local crashpos = vector.subtract(pos, v)
			local crashnode = minetest.get_node(crashpos)
			local cndef = minetest.registered_nodes[crashnode.name]
			-- Set fire if node is air, or a replacable flammable node (e.g. a plant)
			if crashnode.name == "air" or
					(cndef and cndef.buildable_to and minetest.get_item_group(crashnode.name, "flammable") >= 1) then
				minetest.set_node(crashpos, {name = "mcl_fire:fire"})
			end
		end
	end
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:blaze", S("Blaze"), "#f6b201", "#fff87e", 0)
