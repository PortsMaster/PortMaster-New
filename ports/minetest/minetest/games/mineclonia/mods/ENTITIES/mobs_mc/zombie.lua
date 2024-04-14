--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### ZOMBIE
--###################

local drops_common = {
	{name = "mcl_mobitems:rotten_flesh",
	chance = 1,
	min = 0,
	max = 2,
	looting = "common",},
	{name = "mcl_core:iron_ingot",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
	{name = "mcl_farming:carrot_item",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
	{name = "mcl_farming:potato_item",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
}

local drops_zombie = table.copy(drops_common)
table.insert(drops_zombie, {
	-- Zombie Head
	-- TODO: Only drop if killed by charged creeper
	name = "mcl_heads:zombie",
	chance = 200, -- 0.5%
	min = 1,
	max = 1,
})

local zombie = {
	description = S("Zombie"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 2.2,
	curiosity = 7,
	head_pitch_multiplier=-1,
	breath_max = -1,
	wears_armor = 1,
	armor = {undead = 90, fleshy = 90},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	visual_size = { x = 1, y = 1.1 },
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_zombie.png", -- texture
		}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	sound_params = {
		gain = 0.3
	},
	walk_velocity = .8,
	run_velocity = 1.2,
	damage = 3,
	reach = 2,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	jump_height = 4,
	group_attack = { "mobs_mc:zombie", "mobs_mc:baby_zombie", "mobs_mc:husk", "mobs_mc:baby_husk" },
	drops = drops_zombie,
	animation = {
		stand_start = 40, stand_end = 49, stand_speed = 2,
		walk_start = 0, walk_end = 39, speed_normal = 25,
		run_start = 0, run_end = 39, speed_run = 50,
		punch_start = 50, punch_end = 59, punch_speed = 20,
	},
	ignited_by_sunlight = true,
	sunlight_damage = 2,
	view_range = 16,
	attack_type = "dogfight",
	harmed_by_heal = true,
	attack_npcs = true,
}

mcl_mobs.register_mob("mobs_mc:zombie", zombie)

-- Baby zombie.
-- A smaller and more dangerous variant of the zombie

local baby_zombie = table.merge(zombie, {
	description = S("Baby Zombie"),
	visual_size = { x = 0.5, y = 0.5, z = 0.5 },
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.98, 0.25},
	xp_min = 12,
	xp_max = 12,
	walk_velocity = 1,
	run_velocity = 1.45,
	child = 1,
	reach = 1,
	animation = {
		stand_start = 100, stand_end = 109, stand_speed = 2,
		walk_start = 60, walk_end = 99, speed_normal = 40,
		run_start = 60, run_end = 99, speed_run = 80,
		punch_start = 109, punch_end = 119
	},
})

mcl_mobs.register_mob("mobs_mc:baby_zombie", baby_zombie)

-- Husk.
-- Desert variant of the zombie
local husk = table.copy(zombie)
husk.description = S("Husk")
husk.textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_husk.png", -- texture
		}
	}
husk.ignited_by_sunlight = false
husk.sunlight_damage = 0
husk.drops = drops_common
-- TODO: Husks avoid water

mcl_mobs.register_mob("mobs_mc:husk", husk)

-- Baby husk.
-- A smaller and more dangerous variant of the husk
local baby_husk = table.copy(baby_zombie)
baby_husk.description = S("Baby Husk")
baby_husk.textures = {{
	"mobs_mc_empty.png", -- wielded_item
	"mobs_mc_husk.png", -- texture
}}
baby_husk.ignited_by_sunlight = false
baby_husk.sunlight_damage = 0
baby_husk.drops = drops_common

mcl_mobs.register_mob("mobs_mc:baby_husk", baby_husk)


mcl_mobs.spawn_setup({
	name = "mobs_mc:zombie",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 1000,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:baby_zombie",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 50,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:husk",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes = {
		"Desert",
	},
	chance = 2400,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:baby_husk",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes = {
		"Desert",
	},
	chance = 20,
})

-- Spawn eggs
mcl_mobs.register_egg("mobs_mc:husk", S("Husk"), "#777361", "#ded88f", 0)
mcl_mobs.register_egg("mobs_mc:zombie", S("Zombie"), "#00afaf", "#799c66", 0)
