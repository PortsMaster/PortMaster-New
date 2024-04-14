--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local default_walk_chance = 50

local pr = PseudoRandom(os.time()*10)

-- Wolf
local wolf = {
	description = S("Wolf"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	hp_min = 8,
	hp_max = 8,
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = true,
	spawn_in_group = 8,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	textures = {
		{"mobs_mc_wolf.png"},
	},
	makes_footstep_sound = true,
	head_swivel = "head.control",
	bone_eye_height = 3.5,
	head_eye_height = 1.1,
	horizontal_head_height=0,
	curiosity = 3,
	head_yaw="z",
	sounds = {
		attack = "mobs_mc_wolf_bark",
		war_cry = "mobs_mc_wolf_growl",
		damage = {name = "mobs_mc_wolf_hurt", gain=0.6},
		death = {name = "mobs_mc_wolf_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = default_walk_chance,
	walk_velocity = 2,
	run_velocity = 3,
	damage = 4,
	reach = 2,
	attack_type = "dogfight",
	fear_height = 4,
	follow = { "mcl_mobitems:bone" },
	on_rightclick = function(self, clicker)
		-- Try to tame wolf (intentionally does NOT use mcl_mobs.feed_tame)
		local tool = clicker:get_wielded_item()

		local dog, ent
		if tool:get_name() == "mcl_mobitems:bone" then

			minetest.sound_play("mobs_mc_wolf_take_bone", {object=self.object, max_hear_distance=16}, true)
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				tool:take_item()
				clicker:set_wielded_item(tool)
			end
			-- 1/3 chance of getting tamed
			if pr:next(1, 3) == 1 then
				local yaw = self.object:get_yaw()
				dog = mcl_util.replace_mob(self.object, "mobs_mc:dog")
				if dog and dog:get_pos() then
					dog:set_yaw(yaw)
					ent = dog:get_luaentity()
					ent.owner = clicker:get_player_name()
					ent.tamed = true
					ent:set_animation("sit")
					ent.walk_chance = 0
					ent.jump = false
					ent.health = self.health
					-- cornfirm taming
					minetest.sound_play("mobs_mc_wolf_bark", {object=dog, max_hear_distance=16}, true)
					-- Replace wolf
				end
			end
		end
	end,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 50,
		run_start = 0, run_end = 40, run_speed = 100,
		sit_start = 45, sit_end = 45,
	},
	child_animations = {
		stand_start = 46, stand_end = 46,
		walk_start = 46, walk_end = 86, walk_speed = 75,
		run_start = 46, run_end = 86, run_speed = 150,
		sit_start = 91, sit_end = 91,
	},
	jump = true,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = {
		"player",
		"mobs_mc:sheep",
		"mobs_mc:rabbit",
		"mobs_mc:skeleton",
		"mobs_mc:stray",
		"mobs_mc:witherskeleton",
	},
	avoid_from = { "mobs_mc:llama" },
}

mcl_mobs.register_mob("mobs_mc:wolf", wolf)

-- Tamed wolf

-- Collar colors
local colors = {
	["unicolor_black"] = "#000000",
	["unicolor_blue"] = "#0000BB",
	["unicolor_dark_orange"] = "#663300", -- brown
	["unicolor_cyan"] = "#01FFD8",
	["unicolor_dark_green"] = "#005B00",
	["unicolor_grey"] = "#C0C0C0",
	["unicolor_darkgrey"] = "#303030",
	["unicolor_green"] = "#00FF01",
	["unicolor_red_violet"] = "#FF05BB", -- magenta
	["unicolor_orange"] = "#FF8401",
	["unicolor_light_red"] = "#FF65B5", -- pink
	["unicolor_red"] = "#FF0000",
	["unicolor_violet"] = "#5000CC",
	["unicolor_white"] = "#FFFFFF",
	["unicolor_yellow"] = "#FFFF00",

	["unicolor_light_blue"] = "#B0B0FF",
}

local get_dog_textures = function(color)
	if colors[color] then
		return {"mobs_mc_wolf_tame.png^(mobs_mc_wolf_collar.png^[colorize:"..colors[color]..":192)"}
	else
		return nil
	end
end

-- Tamed wolf (aka “dog”)
local dog = table.copy(wolf)
dog.can_despawn = false
dog.passive = true
dog.hp_min = 20
dog.hp_max = 20
-- Tamed wolf texture + red collar
dog.textures = get_dog_textures("unicolor_red")
dog.owner = ""
dog.order = "sit"
dog.state = "stand"
dog.owner_loyal = true
dog.follow_velocity = 3.2
-- Automatically teleport dog to owner
dog.do_custom = mobs_mc.make_owner_teleport_function(12)
dog.follow = {
	"mcl_mobitems:rabbit", "mcl_mobitems:cooked_rabbit",
	"mcl_mobitems:mutton", "mcl_mobitems:cooked_mutton",
	"mcl_mobitems:beef", "mcl_mobitems:cooked_beef",
	"mcl_mobitems:chicken", "mcl_mobitems:cooked_chicken",
	"mcl_mobitems:porkchop", "mcl_mobitems:cooked_porkchop",
	"mcl_mobitems:rotten_flesh",
}
dog.attack_animals = nil
dog.specific_attack = nil

dog.on_rightclick = function(self, clicker)
	local item = clicker:get_wielded_item()

	if self:feed_tame(clicker, 1, true, false) then
		return
	elseif mcl_mobs.protect(self, clicker) then
		return
	elseif item:get_name() ~= "" and mcl_mobs.capture_mob(self, clicker, 0, 2, 80, false, nil) then
		return
	elseif minetest.get_item_group(item:get_name(), "dye") == 1 then
		-- Dye (if possible)
		for group, _ in pairs(colors) do
			-- Check if color is supported
			if minetest.get_item_group(item:get_name(), group) == 1 then
				-- Dye collar
				local tex = get_dog_textures(group)
				if tex then
					self.base_texture = tex
					self.object:set_properties({
						textures = self.base_texture
					})
					if not minetest.is_creative_enabled(clicker:get_player_name()) then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					break
				end
			end
		end
	else
		if not self.owner or self.owner == "" then
		-- Huh? This dog has no owner? Let's fix this! This should never happen.
			self.owner = clicker:get_player_name()
		end
		if not minetest.settings:get_bool("mcl_extended_pet_control",false) then
			self:toggle_sit(clicker,-0.4)
		end
	end
end

mcl_mobs.register_mob("mobs_mc:dog", dog)

mcl_mobs.spawn_setup({
	name = "mobs_mc:wolf",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 7,
	min_height = mobs_mc.water_level + 3,
	biomes = {
		"flat",
		"Taiga",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"Forest",
		"ColdTaiga",
		"Forest_beach",
		"ColdTaiga_beach_water",
		"Taiga_beach",
		"ColdTaiga_beach",
	},
	chance = 80,
})

mcl_mobs.register_egg("mobs_mc:wolf", S("Wolf"), "#d7d3d3", "#ceaf96", 0)
