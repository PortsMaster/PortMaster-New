--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	spawn_class = "passive",
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	passive = true,
	reach = 1,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.49, 0.2},
	head_swivel = "head.control",
	bone_eye_height = 2,
	head_eye_height = 0.5,
	horizontal_head_height = -.3,
	curiosity = 20,
	head_yaw="z",
	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = {
        {"mobs_mc_rabbit_brown.png"},
        {"mobs_mc_rabbit_gold.png"},
        {"mobs_mc_rabbit_white.png"},
        {"mobs_mc_rabbit_white_splotched.png"},
        {"mobs_mc_rabbit_salt.png"},
        {"mobs_mc_rabbit_black.png"},
	},
	sounds = {
		random = "mobs_mc_rabbit_random",
		damage = "mobs_mc_rabbit_hurt",
		death = "mobs_mc_rabbit_death",
		attack = "mobs_mc_rabbit_attack",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 3.7,
	avoid_from = {"mobs_mc:wolf"},
	follow_velocity = 1.1,
	floats = 1,
	runaway = true,
	jump = true,
	drops = {
		{name = "mcl_mobitems:rabbit", chance = 1, min = 0, max = 1, looting = "common",},
		{name = "mcl_mobitems:rabbit_hide", chance = 1, min = 0, max = 1, looting = "common",},
		{name = "mcl_mobitems:rabbit_foot", chance = 10, min = 0, max = 1, looting = "rare", looting_factor = 0.03,},
	},
	fear_height = 4,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 20,
		run_start = 0, run_end = 20, run_speed = 30,
	},
	child_animations = {
		stand_start = 21, stand_end = 21,
		walk_start = 21, walk_end = 41, walk_speed = 30,
		run_start = 21, run_end = 41, run_speed = 45,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = {
		"mcl_flowers:dandelion",
		"mcl_farming:carrot_item",
		"mcl_farming:carrot_item_gold",
	},
	view_range = 8,
	-- Eat carrots and reduce their growth stage by 1
	replace_rate = 10,
	replace_what = {
		{"mcl_farming:carrot", "mcl_farming:carrot_7", 0},
		{"mcl_farming:carrot_7", "mcl_farming:carrot_6", 0},
		{"mcl_farming:carrot_6", "mcl_farming:carrot_5", 0},
		{"mcl_farming:carrot_5", "mcl_farming:carrot_4", 0},
		{"mcl_farming:carrot_4", "mcl_farming:carrot_3", 0},
		{"mcl_farming:carrot_3", "mcl_farming:carrot_2", 0},
		{"mcl_farming:carrot_2", "mcl_farming:carrot_1", 0},
		{"mcl_farming:carrot_1", "air", 0},
	},
	on_rightclick = function(self, clicker)
		-- Feed, tame protect or capture
		if self:feed_tame(clicker, 1, true, false) then return end
		if mcl_mobs.protect(self, clicker) then return end
		if mcl_mobs.capture_mob(self, clicker, 0, 50, 80, false, nil) then return end
	end,
	do_custom = function(self)
		-- Easter egg: Change texture if rabbit is named “Toast”
		local nametag = self.object:get_properties().nametag
		if nametag == "Toast" and not self._has_toast_texture then
			self._original_rabbit_texture = self.base_texture
			self.base_texture = { "mobs_mc_rabbit_toast.png" }
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = true
		elseif nametag ~= "Toast" and self._has_toast_texture then
			self.base_texture = self._original_rabbit_texture
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = false
		end
	end,
}

mcl_mobs.register_mob("mobs_mc:rabbit", rabbit)

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.copy(rabbit)
killer_bunny.description = S("Killer Bunny")
killer_bunny.type = "monster"
killer_bunny.spawn_class = "hostile"
killer_bunny.attack_type = "dogfight"
killer_bunny.specific_attack = { "player", "mobs_mc:wolf", "mobs_mc:dog" }
killer_bunny.damage = 8
killer_bunny.passive = false
killer_bunny.does_not_prevent_sleep = true
-- 8 armor points
killer_bunny.armor = 50
killer_bunny.textures = { "mobs_mc_rabbit_caerbannog.png" }
killer_bunny.view_range = 16
killer_bunny.replace_rate = nil
killer_bunny.replace_what = nil
killer_bunny.on_rightclick = nil
killer_bunny.run_velocity = 6
killer_bunny.do_custom = function(self)
	if self.nametag ~= "The Killer Bunny" then
		self:set_nametag("The Killer Bunny")
	end
end

mcl_mobs.register_mob("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
-- Different skins depending on spawn location <- we'll get to this when the spawning algorithm is fleshed out

mcl_mobs.spawn_setup({
	name = "mobs_mc:rabbit",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 8,
	min_light = 9,
	biomes = {
		"flat",
		"Desert",
		"FlowerForest",
		"Taiga",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ColdTaiga",
		"CherryGrove",
	},
	chance = 40,
})

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:rabbit", S("Rabbit"), "#995f40", "#734831", 0)

-- Note: This spawn egg does not exist in Minecraft
mcl_mobs.register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "#f2f2f2", "#ff0000", 0)
