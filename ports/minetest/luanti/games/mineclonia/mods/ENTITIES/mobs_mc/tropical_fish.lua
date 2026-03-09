--Tropical Fish by cora
local S = core.get_translator(core.get_current_modname())
local mob_class = mcl_mobs.mob_class

local tropical_fish = {
	description = S("Tropical Fish"),
	type = "animal",
	_spawn_category = "water_ambient",
	can_despawn = true,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	head_eye_height = 0.26,
	_school_size = 9,
	tilt_swim = true,
	movement_speed = 14,
	collisionbox = { -0.15, 0.0, -0.15, 0.15, 0.75, 0.15 },
	visual = "mesh",
	mesh = "extra_mobs_tropical_fish_a.b3d",
	textures = { "extra_mobs_tropical_fish_a.png" }, -- to be populated on_spawn
	sounds = {},
	animation = {
		stand_start = 0, stand_end = 20,
		walk_start = 20, walk_end = 40, walk_speed = 50,
		run_start = 20, run_end = 40, run_speed = 50,
	},
	drops = {
		{name = "mcl_fishing:clownfish_raw",
		chance = 1,
		min = 1,
		max = 1,},
		{name = "mcl_bone_meal:bone_meal",
		chance = 20,
		min = 1,
		max = 1,},
	},
	runaway_from = {"players"},
	runaway_bonus_near = 1.6,
	runaway_bonus_far = 1.4,
	runaway_view_range = 8,
	initialize_group = mob_class.school_init_group,
	ai_functions = {
		mob_class.check_schooling,
		mob_class.check_avoid,
		mob_class.check_frightened,
		mob_class.check_pace,
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	can_ride_boat = false,
	swims = true,
	pace_height = 1.0,
	do_go_pos = mcl_mobs.mob_class.fish_do_go_pos,
	breathes_in_water = true,
	flops = true,
	runaway = true,
	pace_chance = 40,
}

------------------------------------------------------------------------
-- Tropical Fish visuals.
------------------------------------------------------------------------

local base_colors = {
	"#FF3855",
	"#FFF700",
	"#A7F432",
	"#FF5470",
	"#5DADEC",
	"#A83731",
	"#87FF2A",
	"#E936A7",
	"#FF007C",
	"#9C51B6",
	"#66FF66",
	"#AAF0D1",
	"#50BFE6",
	"#FFFF66",
	"#FF9966",
	"#FF00CC",
}
local pattern_colors = {
	"#FF3855",
	"#FFF700",
	"#A7F432",
	"#FF5470",
	"#5DADEC",
	"#A83731",
	"#87FF2A",
	"#E936A7",
	"#FF007C",
	"#9C51B6",
	"#66FF66",
	"#AAF0D1",
	"#50BFE6",
	"#FFFF66",
	"#FF9966",
	"#FF00CC",
}

function tropical_fish:update_textures ()
	self._type = self._type or (math.random(2) == 1 and "b" or "a")
	if self._type == "b" then
		self.object:set_properties({})
	end

	self._base_color = self._base_color or base_colors[math.random(#base_colors)]
	self._pattern_color = self._pattern_color or pattern_colors[math.random(#pattern_colors)]
	self._pattern = self._pattern or table.concat ({
		"extra_mobs_tropical_fish_pattern_",
		self._type,
		"_",
		math.random(6),
		".png",
	})

	self._default_mesh = self._default_mesh or table.concat ({
		"extra_mobs_tropical_fish_",
		self._type,
		".b3d",
	})
	self._default_texture = self._default_texture or table.concat ({
		"(extra_mobs_tropical_fish_",
		self._type,
		".png^[colorize:",
		self._base_color,
		":127)^(",
		self._pattern,
		"^[colorize:",
		self._pattern_color..")",
	})

	self.base_texture = {
		self._default_texture,
	}
	self.object:set_properties ({
		mesh = self._default_mesh,
	})
	self:set_textures (self.base_texture)
	self.base_mesh = self._default_mesh
	self.base_size = self.initial_properties.visual_size
	self.base_colbox = self.initial_properties.collisionbox
	self.base_selbox = self.initial_properties.selectionbox
end

------------------------------------------------------------------------
-- Tropical Fish interaction.
------------------------------------------------------------------------

function tropical_fish:on_rightclick (clicker)
	local bn = clicker:get_wielded_item():get_name()
	if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
		if clicker:set_wielded_item("mcl_buckets:bucket_tropical_fish") then
			local it = clicker:get_wielded_item()
			local m = it:get_meta()
			m:set_string("properties",core.serialize({
				nametag = self:get_nametag (),
				_default_mesh = self._default_mesh,
				_default_texture = self._default_texture,
				_base_color = self._base_color,
				_pattern = self._pattern,
				_pattern_color = self._pattern_color,
				_type = self._type,
			}))
			clicker:set_wielded_item(it)
			self:safe_remove()
		end
		awards.unlock(clicker:get_player_name(), "mcl:tacticalFishing")
	end
end

function tropical_fish:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self:update_tag ()
	return true
end

------------------------------------------------------------------------
-- Tropical Fish AI.
------------------------------------------------------------------------

tropical_fish.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_avoid,
	mob_class.check_schooling,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:tropical_fish", tropical_fish)

------------------------------------------------------------------------
-- Tropical Fish spawning.
------------------------------------------------------------------------

--spawn egg
mcl_mobs.register_egg("mobs_mc:tropical_fish", S("Tropical Fish"), "#ef6915", "#fff9ef", 0)

------------------------------------------------------------------------
-- Modern Tropical Fish spawning.
------------------------------------------------------------------------

local aquatic_animal_spawner = mobs_mc.aquatic_animal_spawner
local tropical_fish_spawner = table.merge (aquatic_animal_spawner, {
	name = "mobs_mc:tropical_fish",
	biomes = {
		"WarmOcean",
		"LukewarmOcean",
		"MangroveSwamp",
		"LushCaves",
	},
	weight = 25,
	pack_min = 8,
	pack_max = 8,
})

function tropical_fish_spawner:init_group (list, sdata)
	mob_class.school_init_group (list)
end

function tropical_fish_spawner:describe_criteria (tbl, omit_group_details)
	aquatic_animal_spawner.describe_criteria (self, tbl, omit_group_details)
	if not omit_group_details then
		table.insert (tbl, S ("Each mob spawned will form a school with the remainder of the mobs in the group."))
	end
end

mcl_mobs.register_spawner (tropical_fish_spawner)
