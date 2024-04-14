-- v1.1

--###################
--################### SQUID
--###################

local S = minetest.get_translator("mobs_mc")

mcl_mobs.register_mob("mobs_mc:squid", {
	description = S("Squid"),
    type = "animal",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 10,
    hp_max = 10,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
    spawn_in_group_min = 2,
    spawn_in_group = 4,
    -- FIXME: If the squid is near the floor, it turns black
    collisionbox = {-0.4, 0.0, -0.4, 0.4, 0.9, 0.4},
    visual = "mesh",
    mesh = "mobs_mc_squid.b3d",
    textures = {
        {"mobs_mc_squid.png"}
    },
    sounds = {
		damage = {name="mobs_mc_squid_hurt", gain=0.3},
		death = {name="mobs_mc_squid_death", gain=0.4},
		flop = "mobs_mc_squid_flop",
		-- TODO: sounds: random
		distance = 16,
    },
    animation = {
		stand_start = 1,
		stand_end = 60,
		walk_start = 1,
		walk_end = 60,
		run_start = 1,
		run_end = 60,
	},
    drops = {
		{name = "mcl_mobitems:ink_sac",
		chance = 1,
		min = 1,
		max = 3,
		looting = "common",},
	},
    visual_size = {x=3, y=3},
    makes_footstep_sound = false,
    fly = true,
    fly_in = { "mcl_core:water_source", "mclx_core:river_water_source" },
    breathes_in_water = true,
    jump = false,
    view_range = 16,
    runaway = true,
    fear_height = 4,
})

-- TODO: Behaviour: squirt

-- Spawn near the water surface

mcl_mobs.spawn_setup({
	name = "mobs_mc:squid",
	type_of_spawning = "water",
	dimension = "overworld",
	min_height = mobs_mc.water_level - 16,
	max_height = mobs_mc.water_level + 1,
	min_light = 0,
	max_light = minetest.LIGHT_MAX + 1,
	aoc = 7,
	chance = 80,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:squid", S("Squid"), "#223b4d", "#708999", 0)
