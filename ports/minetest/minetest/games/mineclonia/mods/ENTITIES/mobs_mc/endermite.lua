--###################
--################### ENDERMITE
--###################

local S = minetest.get_translator("mobs_mc")

mcl_mobs.register_mob("mobs_mc:endermite", {
	description = S("Endermite"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	hp_min = 8,
	hp_max = 8,
	xp_min = 3,
	xp_max = 3,
	armor = {fleshy = 100, arthropod = 100},
	group_attack = true,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.29, 0.2},
	visual = "mesh",
	mesh = "mobs_mc_endermite.b3d",
	textures = {
		{"mobs_mc_endermite.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_endermite_random",
		damage = "mobs_mc_endermite_hurt",
		death = "mobs_mc_endermite_death",
		distance = 16,
	},
	walk_velocity = 1,
	run_velocity = 2,
	jump = true,
	fear_height = 4,
	view_range = 16,
	damage = 2,
	reach = 1,
})

mcl_mobs.register_egg("mobs_mc:endermite", S("Endermite"), "#161616", "#6d6d6d", 0)
