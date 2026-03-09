-- v1.4

--###################
--################### GUARDIAN
--###################

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

local guardian_elder = table.merge (mobs_mc.guardian, {
	description = S("Elder Guardian"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 80,
	hp_max = 80,
	xp_min = 10,
	xp_max = 10,
	breath_max = -1,
	can_ride_boat = false,
	damage = 8,
	movement_speed = 6.0,
	_default_laser_delay = 3.0,
	head_eye_height = 0.99875,
	collisionbox = {-0.99875, 0, -0.99875, 0.99875, 1.9975, 0.99875},
	doll_size_override = { x = 0.72, y = 0.72 },
	visual = "mesh",
	mesh = "mobs_mc_guardian.b3d",
	textures = {
		{"mobs_mc_guardian_elder.png"},
	},
	visual_size = {x=7, y=7},
	drops = {
		{name = "mcl_ocean:prismarine_shard",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},

		-- TODO: Only drop if killed by player
		{name = "mcl_sponges:sponge_wet",
		chance = 1,
		min = 1,
		max = 1,},

		-- The following drops are approximations
		-- Fish / prismarine crystal
		{name = "mcl_fishing:fish_raw",
		chance = 4,
		min = 1,
		max = 1,
		looting = "common",},
		{name = "mcl_ocean:prismarine_crystals",
		chance = 1,
		min = 1,
		max = 10,
		looting = "common",},

		-- Rare drop: fish
		{name = "mcl_fishing:fish_raw",
		chance = 160, -- 2.5% / 4
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:salmon_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:clownfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
		{name = "mcl_fishing:pufferfish_raw",
		chance = 160,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 4,},
	},
})

------------------------------------------------------------------------
-- Elder Guardian AI.
------------------------------------------------------------------------

function guardian_elder:on_spawn ()
	-- Restrict to a 16 node radius around spawn point.
	self:restrict_to (self.object:get_pos (), 16)
end

function guardian_elder:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local self_pos
	-- See:
	-- https://minecraft.wiki/w/Elder_Guardian#Inflicting_Mining_Fatigue
	self._fatigue_counter = (self._fatigue_counter or 60) + dtime
	self_pos = self.object:get_pos ()
	if self._fatigue_counter > 60 then
		self._fatigue_counter = self._fatigue_counter - 60

		for player in mcl_util.connected_players() do
			local pos = player:get_pos ()
			if vector.distance (pos, self_pos) <= 50 then
				-- Inflict Mining Fatigue III for 5 minutes.
				mcl_potions.give_effect_by_level ("fatigue", player, 3, 300)
				-- TODO: display an apparition and play eerie noises.
			end
		end
	end
end

guardian_elder.ai_functions = {
	mob_class.return_to_restriction,
	mob_class.check_attack,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:guardian_elder", guardian_elder)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "#ceccba", "#747693", 0)


