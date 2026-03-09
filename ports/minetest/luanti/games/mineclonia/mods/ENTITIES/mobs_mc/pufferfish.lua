local S = core.get_translator ("mobs_mc")

------------------------------------------------------------------------
-- Pufferfish.
------------------------------------------------------------------------

local pufferfish_ignored_mobs = {
	-- TODO: "mobs_mc:turtle",
	-- TODO: "mobs_mc:tadpole",
	"mobs_mc:cod",
	"mobs_mc:dolphin",
	"mobs_mc:glow_squid",
	"mobs_mc:guardian",
	"mobs_mc:guardian_elder",
	"mobs_mc:pufferfish",
	"mobs_mc:salmon",
	"mobs_mc:squid",
	"mobs_mc:tropical_fish",
}

local small_collision_box = {
	-0.175, 0, -0.175,
	0.175, 0.35, 0.175,
}

local medium_collision_box = {
	-0.245, 0, -0.245,
	0.245, 0.49, 0.245,
}

local large_collision_box = {
	-0.45, 0, -0.45,
	0.45, 0.7, 0.45,
}

local pufferfish = {
	description = S ("Pufferfish"),
	type = "animal",
	_spawn_category = "water_ambient",
	can_despawn = true,
	hp_min = 3,
	hp_max = 3,
	xp_min = 1,
	xp_max = 3,
	armor = 100,
	rotate = 0,
	collisionbox = large_collision_box,
	visual_size = { x = 1, y = 1, },
	visual = "mesh",
	head_eye_height = 0.455,
	mesh = "mobs_mc_pufferfish_small.b3d",
	textures = {
		{"mobs_mc_pufferfish.png",},
	},
	sounds = {
	},
	animation = {
		stand_start = 10,
		stand_end = 530,
	},
	drops = {
		{
			name = "mcl_fishing:pufferfish_raw",
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
	runaway_from = {"players"},
	runaway_bonus_near = 1.6,
	runaway_bonus_far = 1.4,
	runaway_view_range = 8,
	makes_footstep_sound = false,
	swims = true,
	pace_height = 1.0,
	do_go_pos = mcl_mobs.mob_class.fish_do_go_pos,
	flops = true,
	breathes_in_water = true,
	runaway = true,
	_puff_state = 0,
	_puff_time = 0,
	_unpuff_time = 0,
}

------------------------------------------------------------------------
-- Pufferfish interaction.
------------------------------------------------------------------------

function pufferfish:on_rightclick (clicker)
	local bn = clicker:get_wielded_item ():get_name ()
	if bn == "mcl_buckets:bucket_water" or bn == "mcl_buckets:bucket_river_water" then
		self:safe_remove ()
		clicker:set_wielded_item ("mcl_buckets:bucket_pufferfish")
		awards.unlock (clicker:get_player_name (), "mcl:tacticalFishing")
	end
end

------------------------------------------------------------------------
-- Pufferfish visuals.
------------------------------------------------------------------------

local mob_class = mcl_mobs.mob_class

function pufferfish:apply_puff_state (puff_state)
	local cbox, mesh
	if puff_state == 0 then
		cbox = small_collision_box
		mesh = "mobs_mc_pufferfish_small.b3d"
	elseif puff_state == 1 then
		cbox = medium_collision_box
		mesh = "mobs_mc_pufferfish_medium.b3d"
	elseif puff_state == 2 then
		cbox = large_collision_box
		mesh = "mobs_mc_pufferfish_big.b3d"
	end
	self.object:set_properties ({
		collisionbox = cbox,
		mesh = mesh,
	})
	self.collisionbox = cbox
	self.base_colbox = cbox
	self.base_mesh = mesh
end

function pufferfish:update_textures ()
	self:apply_puff_state (self._puff_state)
	self.base_texture = {
		"mobs_mc_pufferfish.png",
	}
	self:set_textures (self.base_texture)
end

function pufferfish:do_custom (dtime)
	if self.dead then
		return
	end

	local puff = self._puff_time
	if puff > 0 then
		local next_state = 1
		if self._puff_time > 2.0 then
			next_state = 2
		end
		if next_state ~= self._puff_state then
			self._puff_state = next_state
			self:apply_puff_state (next_state)
		end
		self._puff_time = puff + dtime
	else
		local state = self._puff_state
		if state > 0 then
			local unpuff = self._unpuff_time
			local next_state = state
			if unpuff > 5.0 then
				next_state = 0
			elseif unpuff > 3.0 then
				next_state = 1
			end
			if next_state ~= self._puff_state then
				self._puff_state = next_state
				self:apply_puff_state (next_state)
			end
			self._unpuff_time = unpuff + dtime
		end
	end
end

function pufferfish:get_staticdata_table ()
	local tbl = mob_class.get_staticdata_table (self)
	if tbl then
		tbl._puff_time = 0
		tbl._unpuff_time = 0
	end
	return tbl
end

------------------------------------------------------------------------
-- Pufferfish AI.
------------------------------------------------------------------------

local indexof = table.indexof

local function valid_pufferish_target_p (self, object)
	if object == self.object then
		return false
	elseif object:is_player () then
		local name = object:get_player_name ()
		return not core.is_creative_enabled (name)
	else
		local entity = object:get_luaentity ()
		return entity and entity.is_mob
			and indexof (pufferfish_ignored_mobs, entity.name) == -1
	end
end

function pufferfish:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	if self._puff_state >= 1
		and self:check_timer ("check_damage", 0.5) then
		local damage = self._puff_state + 1
		local duration = 3 * self._puff_state
		local self_pos = self.object:get_pos ()
		for object in core.objects_inside_radius (self_pos, 1.5) do
			if valid_pufferish_target_p (self, object) then
				local reason = {
					source = self.object,
					type = "mob",
				}
				mcl_damage.finish_reason (reason)
				mcl_util.deal_damage (object, damage, reason)
				mcl_potions.give_effect_by_level ("poison", object, 1, duration)
			end
		end
	end
end

local mathmax = math.max

local function pufferfish_defend_self (self, self_pos, dtime)
	if self:check_timer ("pufferfish_survey", 0.5) then
		local located = false
		for object in core.objects_inside_radius (self_pos, 2.5) do
			if valid_pufferish_target_p (self, object) then
				located = true
				break
			end
		end

		if located then
			self._puff_time = mathmax (self._puff_time, 0.05)
			self._unpuff_time = 0.0
		else
			self._puff_time = 0.0
		end
	end
end

pufferfish.ai_functions = {
	pufferfish_defend_self,
	mob_class.check_frightened,
	mob_class.check_avoid,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:pufferfish", pufferfish)

------------------------------------------------------------------------
-- Modern Pufferfish spawning.
------------------------------------------------------------------------

local pufferfish_spawner_warm_ocean = table.merge (mobs_mc.aquatic_animal_spawner, {
	name = "mobs_mc:pufferfish",
	biomes = {
		"WarmOcean",
	},
	weight = 15,
	pack_min = 1,
	pack_max = 3,
})

local pufferfish_spawner_lukewarm_ocean = table.merge (mobs_mc.aquatic_animal_spawner, {
	name = "mobs_mc:pufferfish",
	biomes = {
		"LukewarmOcean",
		"DeepLukewarmOcean",
	},
	weight = 5,
	pack_min = 1,
	pack_max = 3,
})

mcl_mobs.register_spawner (pufferfish_spawner_warm_ocean)
mcl_mobs.register_spawner (pufferfish_spawner_lukewarm_ocean)

-- Spawn egg.
mcl_mobs.register_egg ("mobs_mc:pufferfish", S ("Pufferfish"), "#f6b201", "#37c3f2", 0)
