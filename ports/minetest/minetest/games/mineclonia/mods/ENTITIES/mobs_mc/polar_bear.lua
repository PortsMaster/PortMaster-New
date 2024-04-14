--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### POLARBEAR
--###################


mcl_mobs.register_mob("mobs_mc:polar_bear", {
	description = S("Polar Bear"),
	type = "animal",
	spawn_class = "passive",
	runaway = false,
	passive = false,
	hp_min = 30,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
        breath_max = -1,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 1.39, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_polarbear.b3d",
	textures = {
		{"mobs_mc_polarbear.png"},
	},
	head_swivel = "head.control",
	bone_eye_height = 2.6,
	head_eye_height = 1,
	horizontal_head_height = 0,
	curiosity = 20,
	head_yaw="z",
	visual_size = {x=3.0, y=3.0},
	makes_footstep_sound = true,
	damage = 6,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	group_attack = true,
	attack_type = "dogfight",
	drops = {
		-- 3/4 chance to drop raw fish (poor approximation)
		{name = "mcl_fishing:fish_raw",
		chance = 2,
		min = 0,
		max = 2,
		looting = "common",},
		-- 1/4 to drop raw salmon
		{name = "mcl_fishing:salmon_raw",
		chance = 4,
		min = 0,
		max = 2,
		looting = "common",},

	},
	floats = 1,
	fear_height = 4,
	sounds = {
		random = "mobs_mc_bear_random",
		attack = "mobs_mc_bear_attack",
		damage = "mobs_mc_bear_hurt",
		death = "mobs_mc_bear_death",
		war_cry = "mobs_mc_bear_growl",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	view_range = 16,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:polar_bear",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 3,
	biomes = {
		"ColdTaiga",
		"IcePlainsSpikes",
		"IcePlains",
	},
	chance = 50,
})

-- spawn egg
mcl_mobs.register_egg("mobs_mc:polar_bear", S("Polar Bear"), "#f2f2f2", "#959590", 0)
