--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITHER SKELETON
--###################

mcl_mobs.register_mob("mobs_mc:witherskeleton", {
	description = S("Wither Skeleton"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	pathfinding = 1,
	group_attack = true,
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 2.39, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_witherskeleton.b3d",
	head_swivel = "head.control",
	bone_eye_height = 2.38,
	curiosity = 60,
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"default_tool_stonesword.png", -- sword
			"mobs_mc_wither_skeleton.png", -- wither skeleton
		}
	},
	visual_size = {x=1.2, y=1.2},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	walk_velocity = 1,
	run_velocity = 1.3,
	runaway_from = {"mobs_mc:wolf"},
	damage = 7,
	reach = 2,
	drops = {
		{name = "mcl_core:coal_lump",
		chance = 1,
		min = 0,
		max = 1,
		looting = "common",},
		{name = "mcl_mobitems:bone",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		{name = "mcl_heads:wither_skeleton",
		chance = 40, -- 2.5% chance
		min = 1,
		max = 1,
		looting = "rare",},
	},
	animation = {
		stand_start = 0,
		stand_end = 40,
		stand_speed = 15,
		walk_start = 40,
		walk_end = 60,
		walk_speed = 15,
		run_start = 40,
		run_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		punch_start = 110,
		punch_end = 130,
		punch_speed = 25,
		die_start = 160,
		die_end = 170,
		die_speed = 15,
		die_loop = false,
	},
	water_damage = 0,
	lava_damage = 0,
	fire_damage = 0,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	dogshoot_switch = 1,
	dogshoot_count_max =0.5,
	fear_height = 4,
	harmed_by_heal = true,
	fire_resistant = true,
	dealt_effect = {
		name = "withering",
		factor = 1,
		dur = 10,
	},
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:witherskeleton", S("Wither Skeleton"), "#141414", "#474d4d", 0)
