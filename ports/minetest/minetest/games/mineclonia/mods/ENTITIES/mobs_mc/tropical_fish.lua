--Tropical Fish by cora
local S = minetest.get_translator(minetest.get_current_modname())

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

local function set_textures(self)
	if not self._type then
		self._type = "a"
		if math.random(2) == 1 then
			self.object:set_properties({})
			self._type="b"
		end
		self._base_color = base_colors[math.random(#base_colors)]
		self._pattern_color = pattern_colors[math.random(#pattern_colors)]
		self._pattern = "extra_mobs_tropical_fish_pattern_"..self._type.."_"..math.random(6)..".png"
	end
	self.object:set_properties({
		textures = {
			"(extra_mobs_tropical_fish_"..self._type..".png^[colorize:"..self._base_color..":127)^("..self._pattern.."^[colorize:"..self._pattern_color..")",
		},
		mesh="extra_mobs_tropical_fish_"..self._type..".b3d"
	})
end

local tropical_fish = {
	description = S("Tropical Fish"),
	type = "animal",
	spawn_class = "water_ambient",
	can_despawn = true,
	passive = true,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	spawn_in_group = 9,
	tilt_swim = true,
	collisionbox = {-0.2, 0.0, -0.2, 0.2, 0.1, 0.2},
	visual = "mesh",
	mesh = "extra_mobs_tropical_fish_a.b3d",
	textures = { "extra_mobs_tropical_fish_a.png" }, -- to be populated on_spawn
	sounds = {},
	animation = {
		stand_start = 0,
		stand_end = 20,
		walk_start = 20,
		walk_end = 40,
		run_start = 20,
		run_end = 40,
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
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	swim = true,
	fly = true,
	fly_in = "mcl_core:water_source",
	breathes_in_water = true,
	jump = false,
	view_range = 16,
	runaway = true,
	fear_height = 4,
	on_rightclick = function(self, clicker)
		local bn = clicker:get_wielded_item():get_name()
		if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
			if clicker:set_wielded_item("mcl_buckets:bucket_tropical_fish") then
				local it = clicker:get_wielded_item()
				local m = it:get_meta()
				m:set_string("properties",minetest.serialize(self.object:get_properties()))
				clicker:set_wielded_item(it)
				self:safe_remove()
			end
			awards.unlock(clicker:get_player_name(), "mcl:tacticalFishing")
		end
	end,
	on_spawn = set_textures,
}

mcl_mobs.register_mob("mobs_mc:tropical_fish", tropical_fish)

mcl_mobs.spawn_setup({
	name = "mobs_mc:tropical_fish",
	type_of_spawning = "water",
	dimension = "overworld",
	min_height = mobs_mc.water_level - 16,
	max_height = mobs_mc.water_level + 1,
	min_light = 0,
	max_light = minetest.LIGHT_MAX + 1,
	aoc = 7,
	chance = 750,
	biomes = {
		"Mesa",
		"Jungle",
		"BambooJungle",
		"Savanna",
		"Desert",
		"MesaPlateauFM_grasstop",
		"JungleEdgeM",
		"JungleM",
		"MesaPlateauF",
		"MesaPlateauFM",
		"MesaPlateauF_grasstop",
		"MesaBryce",
		"JungleEdge",
		"SavannaM",
		"Savanna_beach",
		"JungleM_shore",
		"Jungle_shore",
		"MesaPlateauFM_sandlevel",
		"MesaPlateauF_sandlevel",
		"MesaBryce_sandlevel",
		"Mesa_sandlevel",
		"JungleEdgeM_ocean",
		"Jungle_deep_ocean",
		"BambooJungle_ocean",
		"Savanna_ocean",
		"MesaPlateauF_ocean",
		"Savanna_deep_ocean",
		"JungleEdgeM_deep_ocean",
		"SunflowerPlains_deep_ocean",
		"Mesa_ocean",
		"JungleEdge_deep_ocean",
		"SavannaM_deep_ocean",
		"Desert_deep_ocean",
		"Mesa_deep_ocean",
		"MesaPlateauFM_ocean",
		"JungleM_deep_ocean",
		"SavannaM_ocean",
		"MesaPlateauF_deep_ocean",
		"MesaBryce_deep_ocean",
		"JungleEdge_ocean",
		"MesaBryce_ocean",
		"Jungle_ocean",
		"MesaPlateauFM_deep_ocean",
		"Desert_ocean",
		"JungleM_ocean",
		"MesaBryce_underground",
		"Mesa_underground",
		"Jungle_underground",
		"MesaPlateauF_underground",
		"SavannaM_underground",
		"MesaPlateauFM_underground",
		"Desert_underground",
		"Savanna_underground",
		"JungleM_underground",
		"JungleEdgeM_underground",
	},
})

--spawn egg
mcl_mobs.register_egg("mobs_mc:tropical_fish", S("Tropical fish"), "#ef6915", "#fff9ef", 0)
