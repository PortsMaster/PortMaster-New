-- v1.4

--###################
--################### GUARDIAN
--###################

local S = minetest.get_translator("mobs_mc")

mcl_mobs.register_mob("mobs_mc:guardian_elder", {
	description = S("Elder Guardian"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 80,
	hp_max = 80,
	xp_min = 10,
	xp_max = 10,
	breath_max = -1,
	passive = false,
	attack_type = "dogfight",
	pathfinding = 1,
	view_range = 16,
	walk_velocity = 2,
	run_velocity = 4,
	damage = 8,
	reach = 3,
	collisionbox = {-0.99875, 0.5, -0.99875, 0.99875, 2.4975, 0.99875},
	doll_size_override = { x = 0.72, y = 0.72 },
	visual = "mesh",
	mesh = "mobs_mc_guardian.b3d",
	textures = {
		{"mobs_mc_guardian_elder.png"},
	},
	visual_size = {x=7, y=7},
	sounds = {
		random = "mobs_mc_guardian_random",
		war_cry = "mobs_mc_guardian_random",
		damage = {name="mobs_mc_guardian_hurt", gain=0.3},
		death = "mobs_mc_guardian_death",
		flop = "mobs_mc_squid_flop",
		base_pitch = 0.6,
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	drops = {
		{name = "mcl_ocean:prismarine_shard",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- TODO: Only drop if killed by player
		{name = "mcl_sponges:sponge_wet",
		chance = 1,
		min = 1,
		max = 1,},

		-- The following drops are approximations
		-- Fish / prismarine crystal
		{name = "mcl_fishing:fish_raw",
		chance = 4,
		min = 1,
		max = 1,
		looting = "common",},
		{name = "mcl_ocean:prismarine_crystals",
		chance = 1,
		min = 1,
		max = 10,
		looting = "common",},

		-- Rare drop: fish
		{name = "mcl_fishing:fish_raw",
		chance = 160, -- 2.5% / 4
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:salmon_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:clownfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:pufferfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
	},
	fly = true,
	makes_footstep_sound = false,
	fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
	jump = false,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "#ceccba", "#747693", 0)


