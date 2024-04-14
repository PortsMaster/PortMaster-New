--###################
--################### SILVERFISH
--###################

local S = minetest.get_translator("mobs_mc")

local function check_light(pos, environmental_light, artificial_light, sky_light)
	if artificial_light > 11 then
		return false, "To bright"
	end
	return true, ""
end

mcl_mobs.register_mob("mobs_mc:silverfish", {
	description = S("Silverfish"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	group_attack = true,
	reach = 1,
	hp_min = 8,
	hp_max = 8,
	xp_min = 5,
	xp_max = 5,
	armor = {fleshy = 100, arthropod = 100},
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 0.44, 0.4},
	visual = "mesh",
	mesh = "mobs_mc_silverfish.b3d",
	textures = {
		{"mobs_mc_silverfish.png"},
	},
	pathfinding = 1,
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_silverfish_idle",
		death = "mobs_mc_silverfish_death",
		damage = "mobs_mc_silverfish_hurt",
		distance = 16,
	},
	makes_footstep_sound = false,
	walk_velocity = 0.6,
	run_velocity = 1,
	jump = true,
	fear_height = 4,
	replace_what = {
		{"mcl_core:stone", "mcl_monster_eggs:monster_egg_stone", -1},
		{"mcl_core:cobble", "mcl_monster_eggs:monster_egg_cobble", -1},
		{"mcl_core:stonebrick", "mcl_monster_eggs:monster_egg_stonebrick", -1},
		{"mcl_core:stonebrickmossy", "mcl_monster_eggs:monster_egg_stonebrickmossy", -1},
		{"mcl_core:stonebrickcracked", "mcl_monster_eggs:monster_egg_stonebrickcracked", -1},
		{"mcl_core:stonebrickcarved", "mcl_monster_eggs:monster_egg_stonebrickcarved", -1},
	},
	replace_rate = 2,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	view_range = 16,
	attack_type = "dogfight",
	damage = 1,
	check_light = check_light,
})

mcl_mobs.register_egg("mobs_mc:silverfish", S("Silverfish"), "#6d6d6d", "#313131", 0)
