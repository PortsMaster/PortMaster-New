--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### CREEPER
--###################




mcl_mobs.register_mob("mobs_mc:creeper", {
	type = "monster",
	description = S("Creeper"),
	spawn_class = "hostile",
	spawn_in_group = 1,
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	pathfinding = 1,
	visual = "mesh",
	mesh = "mobs_mc_creeper.b3d",
	head_swivel = "Head_Control",
	bone_eye_height = 2.35,
	head_eye_height = 1.8;
	curiosity = 2,
	textures = {
		{"mobs_mc_creeper.png",
		"mobs_mc_empty.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = .8,
	run_velocity = 1.3, -- not dead yet slow, imagine fast crepeer...
	runaway = true,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",

	--hssssssssssss

	explosion_strength = 3,
	explosion_radius = 3.5,
	explosion_damage_radius = 3.5,
	explosiontimer_reset_radius = 6,
	reach = 3,
	explosion_timer = 2.5, -- (was 1.5) This was way too fast compare to mc,
	allow_fuse_reset = true,
	stop_to_explode = true,

	-- Force-ignite creeper with flint and steel and explode after 1.5 seconds.
	-- TODO: Make creeper flash after doing this as well.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if minetest.get_item_group(item:get_name(), "flint_and_steel") > 0 then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5}, true)
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = self.explosion_timer
			minetest.sound_play(self.sounds.attack, {pos = self.object:get_pos(), gain = 1, max_hear_distance = 16}, true)
		end
	end,
	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				self:boom(mcl_util.get_object_center(self.object), self.explosion_strength)
			end
		end
	end,
	on_die = function(self, pos, cmi_cause)
		-- Drop a random music disc when killed by skeleton or stray
		if cmi_cause and cmi_cause.type == "punch" then
			local luaentity = cmi_cause.puncher and cmi_cause.puncher:get_luaentity()
			if luaentity and luaentity.name:find("arrow") then
				local shooter_luaentity = luaentity._shooter and luaentity._shooter:get_luaentity()
				if shooter_luaentity and (shooter_luaentity.name == "mobs_mc:skeleton" or shooter_luaentity.name == "mobs_mc:stray") then
					local loot = mcl_jukebox.get_random_creeper_loot()
					if loot then
						minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, loot)
					end
				end
			end
		end
	end,
	maxdrops = 2,
	drops = {
		{name = "mcl_mobitems:gunpowder",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		-- TODO: Only drop if killed by charged creeper
		{name = "mcl_heads:creeper",
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 110,
		hurt_end = 139,
		death_start = 140,
		death_end = 189,
		look_start = 50,
		look_end = 108,
	},
	floats = 1,
	fear_height = 4,
	view_range = 16,
})

mcl_mobs.register_mob("mobs_mc:creeper_charged", {
	description = S("Creeper"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.69, 0.3},
	pathfinding = 1,
	visual = "mesh",
	mesh = "mobs_mc_creeper.b3d",

	--BOOM

	textures = {
		{"mobs_mc_creeper.png",
		"mobs_mc_creeper_charge.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		attack = "tnt_ignite",
		death = "mobs_mc_creeper_death",
		damage = "mobs_mc_creeper_hurt",
		fuse = "tnt_ignite",
		explode = "tnt_explode",
		distance = 16,
	},
	makes_footstep_sound = true,
	walk_velocity = 1.05,
	run_velocity = 2.1,
	runaway_from = { "mobs_mc:ocelot", "mobs_mc:cat" },
	attack_type = "explode",

	explosion_strength = 6,
	explosion_radius = 8,
	explosion_damage_radius = 8,
	explosiontimer_reset_radius = 6,
	reach = 3,
	explosion_timer = 1.5,
	allow_fuse_reset = true,
	stop_to_explode = true,

	-- Force-ignite creeper with flint and steel and explode after 1.5 seconds.
	-- TODO: Make creeper flash after doing this as well.
	on_rightclick = function(self, clicker)
		if self._forced_explosion_countdown_timer ~= nil then
			return
		end
		local item = clicker:get_wielded_item()
		if minetest.get_item_group(item:get_name(), "flint_and_steel") > 0 then
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				-- Wear tool
				local wdef = item:get_definition()
				item:add_wear(1000)
				-- Tool break sound
				if item:get_count() == 0 and wdef.sound and wdef.sound.breaks then
					minetest.sound_play(wdef.sound.breaks, {pos = clicker:get_pos(), gain = 0.5}, true)
				end
				clicker:set_wielded_item(item)
			end
			self._forced_explosion_countdown_timer = self.explosion_timer
			minetest.sound_play(self.sounds.attack, {pos = self.object:get_pos(), gain = 1, max_hear_distance = 16}, true)
		end
	end,
	do_custom = function(self, dtime)
		if self._forced_explosion_countdown_timer ~= nil then
			self._forced_explosion_countdown_timer = self._forced_explosion_countdown_timer - dtime
			if self._forced_explosion_countdown_timer <= 0 then
				self:boom(mcl_util.get_object_center(self.object), self.explosion_strength)
			end
		end
	end,
	on_die = function(self, pos, cmi_cause)
		-- Drop a random music disc when killed by skeleton or stray
		if cmi_cause and cmi_cause.type == "punch" then
			local luaentity = cmi_cause.puncher and cmi_cause.puncher:get_luaentity()
			if luaentity and luaentity.name:find("arrow") then
				local shooter_luaentity = luaentity._shooter and luaentity._shooter:get_luaentity()
				if shooter_luaentity and (shooter_luaentity.name == "mobs_mc:skeleton" or shooter_luaentity.name == "mobs_mc:stray") then
					local loot = mcl_jukebox.get_random_creeper_loot()
					if loot then
						minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, loot)
					end
				end
			end
		end
	end,
	on_lightning_strike = function(self, pos, pos2, objects)
		 mcl_util.replace_mob(self.object, "mobs_mc:creeper_charged")
		 return true
	end,
	maxdrops = 2,
	drops = {
		{name = "mcl_mobitems:gunpowder",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- Head
		-- TODO: Only drop if killed by charged creeper
		{name = "mcl_heads:creeper",
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 110,
		hurt_end = 139,
		death_start = 140,
		death_end = 189,
		look_start = 50,
		look_end = 108,
	},
	floats = 1,
	fear_height = 4,
	view_range = 16,
	--Having trouble when fire is placed with lightning
	fire_resistant = true,
	glow = 3,
})

mcl_mobs.spawn_setup({
	name = "mobs_mc:creeper",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 2,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 1000,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:creeper", S("Creeper"), "#0da70a", "#000000", 0)
