--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mod_bows = minetest.get_modpath("mcl_bows") ~= nil

mcl_mobs.register_mob("mobs_mc:illusioner", {
	description = S("Illusioner"),
	type = "monster",
	spawn_class = "hostile",
	attack_type = "shoot",
	shoot_interval = 2.5,
	shoot_offset = 1.5,
	arrow = "mcl_bows:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			-- 1-4 damage per arrow
			local dmg = math.random(1, 4)
			mcl_bows.shoot_arrow("mcl_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)
		end
	end,
	hp_min = 32,
	hp_max = 32,
	xp_min = 6,
	xp_max = 6,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_illusioner.b3d",
	textures = { {
		"mobs_mc_illusionist.png",
		"mobs_mc_illusionist.png", --hat
		"mcl_bows_bow.png",
	}, },
	head_swivel = "head.control",
	bone_eye_height = 2.2,
	head_eye_height = 2.2,
	curiosity = 10,
	sounds = {
		-- TODO: more sounds
		distance = 16,
	},
	visual_size = {x=2.75, y=2.75},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	animation = {
		stand_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 25,
		shoot_start = 150,
		shoot_end = 170,
		die_speed = 15,
		die_start = 170,
		die_end = 180,
		die_loop = false,
		-- 120-140 magic arm swinging, 140-150 transition between magic to bow shooting
	},
	view_range = 16,
	fear_height = 4,
})

mcl_mobs.register_egg("mobs_mc:illusioner", S("Illusioner"), "#3f5cbb", "#8a8686", 0)
