--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### OCELOT AND CAT
--###################

local default_walk_chance = 70

local follow = {
	"mcl_fishing:fish_raw",
	"mcl_fishing:salmon_raw",
	"mcl_fishing:clownfish_raw",
	"mcl_fishing:pufferfish_raw",
}

local function is_food(itemstring)
	return table.indexof(follow, itemstring) ~= -1
end

-- Ocelot
local ocelot = {
	description = S("Ocelot"),
	type = "animal",
	spawn_class = "passive",
	passive = false,
	can_despawn = true,
	spawn_in_group = 3,
	spawn_in_group_min = 1,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	head_swivel = "head.control",
	bone_eye_height = 6.2,
	head_eye_height = 0.4,
	horizontal_head_height=-0,
	head_yaw="z",
	curiosity = 4,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.69, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_cat.b3d",
	textures = {"mobs_mc_cat_ocelot.png"},
	makes_footstep_sound = true,
	walk_chance = default_walk_chance,
	walk_velocity = 1,
	run_velocity = 3,
	follow_velocity = 1,
	floats = 1,
	runaway = true,
	fall_damage = 0,
	fear_height = 4,
	sounds = {
		damage = "mobs_mc_ocelot_hurt",
		death = "mobs_mc_ocelot_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 40,
		run_start = 0, run_end = 40, run_speed = 50,
		sit_start = 50, sit_end = 50,
	},
	child_animations = {
		stand_start = 51, stand_end = 51,
		walk_start = 51, walk_end = 91, walk_speed = 60,
		run_start = 51, run_end = 91, run_speed = 75,
		sit_start = 101, sit_end = 101,
	},
	follow = follow,
	view_range = 12,
	attack_type = "dogfight",
	pathfinding = 1,
	damage = 2,
	reach = 1,
	attack_animals = true,
	specific_attack = { "mobs_mc:chicken" },
	on_rightclick = function(self, clicker)
		if self.child then return end
		-- Try to tame ocelot (mobs:feed_tame is intentionally NOT used)
		local item = clicker:get_wielded_item()
		if is_food(item:get_name()) then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			-- 1/3 chance of getting tamed
			if math.random(3) == 1 then
				local cat = mcl_util.replace_mob(self.object, "mobs_mc:cat")
				if cat and cat:get_pos() then
					local ent = cat:get_luaentity()
					ent.owner = clicker:get_player_name()
					ent.tamed = true
					ent.jump = false
					ent.state = "stand"
					ent.health = self.health
					return
				end
			end
		end

	end,
}

mcl_mobs.register_mob("mobs_mc:ocelot", ocelot)

-- Cat
local cat = table.copy(ocelot)
table.update(cat,{
	description = S("Cat"),
	textures = {{"mobs_mc_cat_black.png"}, {"mobs_mc_cat_red.png"}, {"mobs_mc_cat_siamese.png"}},
	can_despawn = false,
	owner = "",
	order = "roam", -- "sit" or "roam"
	owner_loyal = true,
	tamed = false,
	runaway = false,
	follow_velocity = 2.4,
	visual_size = { x = 0.8, y = 0.8 },
	-- Automatically teleport cat to owner
	do_custom = mobs_mc.make_owner_teleport_function(12),
	sounds = {
		random = "mobs_mc_cat_idle",
		damage = "mobs_mc_cat_hiss",
		death = "mobs_mc_ocelot_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	on_rightclick = function(self, clicker)
		if self:feed_tame(clicker, 1, true, false) then return end
		if mcl_mobs.capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
		if mcl_mobs.protect(self, clicker) then return end

		if self.child then return end

		-- Toggle sitting order

		if not self.owner or self.owner == "" then
			-- Huh? This cat has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end

		if not self.order or self.order == "" or self.order == "sit" then
			self.order = "roam"
			self.walk_chance = default_walk_chance
			self.jump = true
		else
			-- “Sit!”
			-- TODO: Add sitting model
			self.order = "sit"
			self.walk_chance = 0
			self.jump = false
		end
	end,
	on_spawn  = function(self)
		if self.owner == "!witch!" then
			self._texture = {"mobs_mc_cat_black.png"}
		end
		if not self._texture then
			self._texture = cat.textures[math.random(#cat.textures)]
		end
		self.object:set_properties({textures = self._texture})
	end
})

mcl_mobs.register_mob("mobs_mc:cat", cat)

mcl_mobs.spawn_setup({
	name = "mobs_mc:ocelot",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 5,
	min_height = mobs_mc.water_level+15,
	biomes = {
		"Jungle",
		"JungleEdgeM",
		"JungleM",
		"JungleEdge",
		"BambooJungle",
	},
	chance = 300,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:ocelot", S("Ocelot"), "#efde7d", "#564434", 0)
mcl_mobs.register_egg("mobs_mc:cat", S("Cat"), "#AA8755", "#505438", 0)
