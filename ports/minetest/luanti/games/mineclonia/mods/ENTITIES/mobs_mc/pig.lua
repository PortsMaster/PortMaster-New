--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local pig = {
	description = S("Pig"),
	type = "animal",
	_spawn_category = "creature",
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.45, 0.0, -0.45, 0.45, 0.865, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_pig.b3d",
	textures = {{
		"mobs_mc_pig.png", -- base
		"blank.png", -- saddle
	}},
	head_swivel = "head.control",
	bone_eye_height = 7.5,
	head_eye_height = 0.8,
	horizontal_head_height = -1,
	curiosity = 3,
	head_yaw = "z",
	makes_footstep_sound = true,
	movement_speed = 5.0,
	drive_bonus = 0.225,
	drops = {
		{
			name = "mcl_mobitems:porkchop",
			chance = 1,
			min = 1,
			max = 3,
			looting = "common",
		},
	},
	sounds = {
		random = {name="mobs_pig", gain=0.5},
		death = {name="mobs_pig_angry", gain=0.75},
		damage = {name="mobs_pig", gain=0.5},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 55,
		run_start = 0, run_end = 40, run_speed = 55,
	},
	_child_animations = {
		stand_start = 41, stand_end = 41,
		walk_start = 41, walk_end = 81, walk_speed = 90,
		run_start = 41, run_end = 81, run_speed = 90,
	},
	follow = {
		"mcl_farming:potato_item",
		"mcl_farming:carrot_item",
		"mcl_farming:beetroot_item",
		"mcl_mobitems:carrot_on_a_stick",
		"mcl_mobitems:carrot_on_a_stick_enchanted"
	},
	steer_class = "follow_item",
	steer_item = "group:controls_pig",
	follow_herd_bonus = 1.1,
	_csm_driving_enabled = true,
}

------------------------------------------------------------------------
-- Pig mechanics.
------------------------------------------------------------------------

function pig:_on_lightning_strike ()
	mcl_util.replace_mob (self.object, "mobs_mc:zombified_piglin")
	return true
end

function pig:on_breed (parent1, parent2)
	local pos = parent1.object:get_pos ()
	local child = mcl_mobs.spawn_child (pos, parent1.name)
	if child then
		local ent_c = child:get_luaentity ()
		ent_c.persistent = true
		return false
	end
end

function pig:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item ()
	local wield_follow = table.indexof(self.follow, wielditem:get_name()) ~= -1
	return self.saddle == "yes" or wield_follow
end

------------------------------------------------------------------------
-- Pig steering.
------------------------------------------------------------------------

function pig:on_die ()
	-- drop saddle when horse is killed while riding
	-- also detach from horse properly
	if self.driver then
		self:detach(self.driver, {x = 1, y = 0, z = 1})
	end
end

function pig:on_rightclick (clicker)
	if not clicker or not clicker:is_player() then
		return
	end

	local item = clicker:get_wielded_item()
	local item_name = item:get_name()

	-- Feed pig
	if self:follow_holding (clicker) then
		if item_name ~= "mcl_mobitems:carrot_on_a_stick" and
			item_name ~= "mcl_mobitems:carrot_on_a_stick_enchanted" and
			self:feed_tame(clicker, 4, true, false) then
			return
		end
	end

	if self.child then return end

	-- Put saddle on pig
	if item_name == "mcl_mobitems:saddle" and self.saddle ~= "yes" then
		self.base_texture = {
			"mobs_mc_pig.png", -- base
			"mobs_mc_pig_saddle.png", -- saddle
		}
		self:set_textures (self.base_texture)
		self.saddle = "yes"
		self.tamed = true
		self.drops = {
			{name = "mcl_mobitems:porkchop",
			 chance = 1,
			 min = 1,
			 max = 3,},
			{name = "mcl_mobitems:saddle",
			 chance = 1,
			 min = 1,
			 max = 1,},
		}
		if not core.is_creative_enabled(clicker:get_player_name()) then
			local inv = clicker:get_inventory()
			local stack = inv:get_stack("main", clicker:get_wield_index())
			stack:take_item()
			inv:set_stack("main", clicker:get_wield_index(), stack)
		end
		core.sound_play({name = "mcl_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
		return
	elseif core.get_item_group(item_name, "shears") > 0 and self.saddle == "yes" and not self.driver then
		self.base_texture = {"mobs_mc_pig.png", "blank.png"}
		self:set_textures(self.base_texture)
		self.saddle = "false"
		self.drops = {
			{
				name = "mcl_mobitems:porkchop",
				chance = 1,
				min = 1,
				max = 3
			}
		}
		local pos = self.object:get_pos()
		core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
		core.sound_play("mcl_armor_unequip_leather", {gain = 0.5, max_hear_distance = 8, pos = pos}, true)
		if not core.is_creative_enabled(clicker:get_player_name()) then
			core.add_item(pos, ItemStack("mcl_mobitems:saddle"))
			local wear = mcl_autogroup.get_wear(item_name, "shearsy")
			item:add_wear(wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
	end

	-- Accelerate pig when right clicked with carrot on a stick.
	if self.driver and clicker == self.driver and
	mcl_util.is_item_or_in_group(self.driver:get_wielded_item():get_name(), self.steer_item) then
		if self:hog_boost () and not core.is_creative_enabled(clicker:get_player_name()) then
			local inv = self.driver:get_inventory()
			local wielditem = clicker:get_wielded_item ()
			-- 26 uses
			if wielditem:get_wear() > 63000 then
				-- Break carrot on a stick
				local def = wielditem:get_definition()
				if def.sounds and def.sounds.breaks then
					core.sound_play(def.sounds.breaks, {pos = clicker:get_pos(), max_hear_distance = 8, gain = 0.5}, true)
				end
				wielditem = {name = "mcl_fishing:fishing_rod", count = 1}
			else
				wielditem:add_wear(2521)
			end
			inv:set_stack("main",self.driver:get_wield_index(), wielditem)
		end
		return
	end

	-- Mount or detach player
	if self.driver and clicker == self.driver then -- and self.driver:get_wielded_item():get_name() ~= "mcl_mobitems:carrot_on_a_stick" then -- Note: This is for when the ability to make the pig go faster is implemented
		-- Detach if already attached
		self:detach(clicker, {x=1, y=0, z=0})
		return

	elseif not self.driver and self.saddle == "yes" then
		-- Initialize attachment properties.
		local vsize = self.object:get_properties ().visual_size
		self.driver_attach_at = {x = 0.0, y = 6.5, z = -3.75}
		self.driver_eye_offset = {x = 0, y = 3, z = 0}
		self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}

		-- Ride pig if it has a saddle
		self:attach (clicker)
		return
	end
end

function pig:after_activate ()
	if self.saddle == "yes" then -- Make saddle load upon rejoin
		self.base_texture = {
			"mobs_mc_pig.png", -- base
			"mobs_mc_pig_saddle.png", -- saddle
		}
		self:set_textures (self.base_texture)
	end
end

function pig:do_custom ()
	if self.driver then
		local controls = self.driver:get_player_control ()
		if not controls.sneak then
			return
		end
		self:detach (self.driver, {x = 1, y = 0, z = 1})
	end
end

------------------------------------------------------------------------
-- Pig AI.
------------------------------------------------------------------------

pig.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:pig", pig)

------------------------------------------------------------------------
-- Pig spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:pig", S("Pig"), "#f0a5a2", "#db635f", 0)

------------------------------------------------------------------------
-- Modern Pig spawning.
------------------------------------------------------------------------

local pig_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:pig",
	biomes = mobs_mc.farm_animal_biomes,
	weight = 10,
})
mcl_mobs.register_spawner (pig_spawner)
