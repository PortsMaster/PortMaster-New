--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator(core.get_current_modname())
local mob_class = mcl_mobs.mob_class

--###################
--################### cod
--###################

local cod = {
	description = S("Cod"),
	type = "animal",
	_spawn_category = "water_ambient",
	can_despawn = true,
	can_ride_boat = false,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	rotate = 180,
	_school_size = 8,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.79, 0.3},
	head_eye_height = 0.195,
	visual = "mesh",
	mesh = "extra_mobs_cod.b3d",
	textures = {
		{"extra_mobs_cod.png"}
	},
	sounds = {
	},
	animation = {
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
	},
	drops = {
		{
			name = "mcl_fishing:fish_raw",
			chance = 1,
			min = 1,
			max = 1,
		},
		{
			name = "mcl_bone_meal:bone_meal",
			chance = 20,
			min = 1,
			max = 1,
		},
	},
	initialize_group = mob_class.school_init_group,
	runaway_from = {"players"},
	runaway_bonus_near = 1.6,
	runaway_bonus_far = 1.4,
	runaway_view_range = 8,
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swims = true,
	pace_height = 1.0,
	do_go_pos = mcl_mobs.mob_class.fish_do_go_pos,
	flops = true,
	breathes_in_water = true,
	movement_speed = 14.0,
	runaway = true,
	pace_chance = 40,
}

------------------------------------------------------------------------
-- Cod interaction.
------------------------------------------------------------------------

function cod:on_rightclick (clicker)
	local bn = clicker:get_wielded_item():get_name()
	if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
		self:safe_remove()
		clicker:set_wielded_item("mcl_buckets:bucket_cod")
		awards.unlock(clicker:get_player_name(), "mcl:tacticalFishing")
	end
end

------------------------------------------------------------------------
-- Cod AI.
------------------------------------------------------------------------

cod.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_avoid,
	mob_class.check_schooling,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:cod", cod)

------------------------------------------------------------------------
-- Cod spawning.
------------------------------------------------------------------------

--spawn egg
mcl_mobs.register_egg("mobs_mc:cod", S("Cod"), "#c1a76a", "#e5c48b", 0)

------------------------------------------------------------------------
-- Modern Cod spawning.
------------------------------------------------------------------------

local aquatic_animal_spawner = mobs_mc.aquatic_animal_spawner
local cod_spawner = table.merge (aquatic_animal_spawner, {
	name = "mobs_mc:cod",
	biomes = {
		"Ocean",
		"DeepOcean",
	},
	weight = 10,
	pack_min = 3,
	pack_max = 6,
})

function cod_spawner:init_group (list, sdata)
	mob_class.school_init_group (list)
end

function cod_spawner:describe_criteria (tbl, omit_group_details)
	aquatic_animal_spawner.describe_criteria (self, tbl, omit_group_details)
	if not omit_group_details then
		table.insert (tbl, S ("Each mob spawned will form a school with the remainder of the mobs in the group."))
	end
end

local cod_spawner_cold_ocean = table.merge (cod_spawner, {
	weight = 15,
	biomes = {
		"ColdOcean",
		"DeepColdOcean",
	},
})

local cod_spawner_lukewarm_ocean = table.merge (cod_spawner, {
	weight = 8,
	biomes = {
		"LukewarmOcean",
	},
})

local cod_spawner_deep_lukewarm_ocean = table.merge (cod_spawner, {
	weight = 15,
	biomes = {
		"DeepLukewarmOcean",
	},
})

mcl_mobs.register_spawner (cod_spawner)
mcl_mobs.register_spawner (cod_spawner_cold_ocean)
mcl_mobs.register_spawner (cod_spawner_lukewarm_ocean)
mcl_mobs.register_spawner (cod_spawner_deep_lukewarm_ocean)
