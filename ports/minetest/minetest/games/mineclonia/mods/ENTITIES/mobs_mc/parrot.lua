--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### PARROT
--###################

local parrot = {
	description = S("Parrot"),
	type = "animal",
	_spawn_category = "creature",
	pathfinding = 1,
	hp_min = 6,
	hp_max = 6,
	xp_min = 1,
	xp_max = 3,
	head_swivel = "head.control",
	bone_eye_height = 1.1,
	horizontal_head_height=0,
	head_eye_height = 0.54,
	curiosity = 10,
	collisionbox = {-0.25, 0, -0.25, 0.25, 0.9, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_parrot.b3d",
	textures = {
		{"mobs_mc_parrot_blue.png"},
		{"mobs_mc_parrot_green.png"},
		{"mobs_mc_parrot_grey.png"},
		{"mobs_mc_parrot_red_blue.png"},
		{"mobs_mc_parrot_yellow_blue.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_parrot_random",
		damage = {name="mobs_mc_parrot_hurt", gain=0.3},
		death = {name="mobs_mc_parrot_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	drops = {
		{
			name = "mcl_mobitems:feather",
			chance = 1,
			min = 1,
			max = 2,
			looting = "common",
		},
	},
	animation = {
		stand_start = 0, stand_end = 0, stand_speed = 50,
		fly_start = 130, fly_end = 150, fly_speed = 50,
		walk_start = 20, walk_end = 40, walk_speed = 50,
		sit_start = 160, sit_end = 160,
		dance_start = 161, dance_end = 201, dance_speed = 80,
	},
	fall_damage = 0,
	gravity_drag = 0.6,
	floats = 1,
	physical = true,
	movement_speed = 4.0,
	airborne = true,
	makes_footstep_sound = false,
	chase_owner_distance = 5.0,
	stop_chasing_distance = 1.0,
	pace_height = 7,
	pace_width = 8,
	_is_party_parrot = false,
}

------------------------------------------------------------------------
-- Parrot interaction.
------------------------------------------------------------------------

local parrot_foods = {
	"mcl_farming:wheat_seeds",
	"mcl_farming:melon_seeds",
	"mcl_farming:pumpkin_seeds",
	"mcl_farming:beetroot_seeds",
}

function parrot:actionable_on_rightclick (clicker)
	local item = clicker:get_wielded_item ()
	local wield_food = table.indexof(parrot_foods, item:get_name ()) ~= -1
	return item:get_name () == "mcl_farming:cookie" or self.tamed or wield_food
end

function parrot:on_rightclick (clicker)
	local item = clicker:get_wielded_item ()
	if not item then
		return
	end
	local name = item:get_name()
	-- Kill parrot if fed with cookie
	if item and name == "mcl_farming:cookie" then
		core.sound_play ("mobs_mc_animal_eat_generic", {
			object = self.object,
			max_hear_distance = 16,
		}, true)

		local mcl_reason = {
			type = "player",
			source = clicker,
		}
		mcl_damage.finish_reason (mcl_reason)
		self:receive_damage (mcl_reason, 65535.0)
		mcl_potions.give_effect_by_level ("poison", self.object, 900, 10)
		if not core.is_creative_enabled (clicker:get_player_name()) then
			item:take_item ()
			clicker:set_wielded_item (item)
		end
		return
	end

	-- Feed to tame, but not breed
	if not self.tamed and table.indexof (parrot_foods, name) ~= -1 then
		self:feed_tame (clicker, 4, false, true, false, 0.1)
		return
	end

	if self.tamed then
		-- Otherwise, toggle sitting.
		if self.order == "sit" then
			self.order = ""
		else
			self:stay ()
		end
	end
end

------------------------------------------------------------------------
-- Parrot AI.
------------------------------------------------------------------------

local shoulders = {
	left = vector.new(-3.75,10.5,0),
	right = vector.new(3.75,10.5,0),
}

local function is_valid_mob_sound (_, v)
	return v.is_mob and v.sounds and type (v.sounds) == "table"
end

local function get_random_mob_sound()
	local random_mob_sound
		= table.random_element (core.registered_entities, is_valid_mob_sound)
	return random_mob_sound and random_mob_sound.sounds.random
end

local function imitate_mob_sound(self,mob)
	local snd = mob.sounds.random
	if not snd or mob.name == "mobs_mc:parrot" or math.random(20) == 1 then
		snd = get_random_mob_sound()
		if not snd then
			return
		end
	end
	return core.sound_play(snd, {
		pos = self.object:get_pos(),
		gain = 1.0,
		pitch = 2.5,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
end

local function check_mobimitate(self,dtime)
	if not self:check_timer("mobimitate", 30) then return end

	for o in core.objects_inside_radius(self.object:get_pos(), 20) do
		local l = o:get_luaentity()
		if l and l.is_mob and l.name ~= "mobs_mc:parrot" then
			imitate_mob_sound(self,l)
			return
		end
	end

end

--find a free shoulder or return nil
local function get_shoulder(player)
	local sh = "left"
	for _,o in pairs(player:get_children()) do
		local l = o:get_luaentity()
		if l and l.name == "mobs_mc:parrot" then
			local _,_,a = l.object:get_attach()
			for _,s in pairs(shoulders) do
				if a and vector.equals(a,s) then
					if sh == "left" then
						sh = "right"
					else
						return
					end

				end
			end
		end
	end
	return shoulders[sh]
end

local function perch(self,player)
	if self.tamed and player:get_player_name() == self.owner and not self.object:get_attach() then
		local shoulder = get_shoulder(player)
		if not shoulder then return true end
		self.object:set_attach(player,"",shoulder,vector.new(0,0,0),true)
		self:set_animation ("stand")
	end
end

function parrot:check_perch (self_pos, dtime)
	local attach = self.object:get_attach ()
	if self.perch_cooldown then
		self.perch_cooldown
			= math.max (0, self.perch_cooldown - dtime)
	else
		self.perch_cooldown = 0
	end
	if attach then
		if not self.perching then
			-- Perching was interrupted, and therefore
			-- this object must be detached.
			self.object:set_detach ()
			return false
		end
		local n1 = core.get_node (vector.offset (self_pos, 0, -0.6, 0)).name
		local n2 = core.get_node (vector.offset (self_pos, 0, 0, 0)).name
		if n1 == "air" or core.get_item_group (n2,"water") > 0
			or core.get_item_group (n2,"lava") > 0 then
			self.object:set_detach()
			self.perching = false
			self.perch_cooldown = 1.0
			return false
		end
		return true
	elseif self.owner and self.perch_cooldown == 0 then
		local owner = core.get_player_by_name (self.owner)
		if not owner then
			return false
		end
		if vector.distance (self_pos, owner:get_pos ()) < 0.5 then
			perch (self, owner)
			self.perching = true
			return "perching"
		end
	end
	return false
end

function parrot:airborne_pacing_target (pos, width, height, groups)
	if math.random (100) <= 99 then
		local aa = vector.offset (pos, -3, -6, -3)
		local bb = vector.offset (pos, 3, 6, 3)
		local nodes
			= core.find_nodes_in_area_under_air (aa, bb, {"group:leaves"})
		if #nodes > 0 then
			return vector.offset (nodes[math.random (#nodes)], 0, 1, 0)
		end
	end
	return mob_class.airborne_pacing_target (self, pos, width, height, groups)
end

function parrot:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	check_mobimitate (self, dtime)
	-- Lest sit_if_ordered should interrupt perching.
	if self.object:get_attach () and not self.perching then
		self.object:set_detach ()
	end
end

function parrot:set_animation (anim, custom_frame)
	if self._is_party_parrot then
		mob_class.set_animation (self, "dance")
	else
		mob_class.set_animation (self, anim, custom_frame)
	end
end

function parrot:set_party_parrot (is_party_parrot, moveresult)
	local touching_ground = moveresult.touching_ground
		or moveresult.standing_on_object

	self._is_party_parrot = is_party_parrot

	if is_party_parrot then
		self:set_animation ("dance")
	elseif self._active_activity == "sit_if_ordered" then
		self:set_animation ("sit")
	elseif self.movement_goal and touching_ground then
		self:set_animation ("walk")
	elseif self.movement_goal then
		self:set_animation ("fly")
	else
		self:set_animation ("stand")
	end
end

local function parrot_check_dance (self, self_pos, dtime, moveresult)
	local is_party_parrot = false
	-- Search for playing jukeboxes nearby.
	for hash, track in pairs (mcl_jukebox.active_tracks) do
		if track then
			local node = core.get_position_from_hash (hash)
			if vector.distance (self_pos, node) <= 3.0 then
				is_party_parrot = true
			end
		end
	end

	if is_party_parrot and not self._party_parrot then
		self:set_party_parrot (true, moveresult)
	elseif self._is_party_parrot then
		self:set_party_parrot (false, moveresult)
	end
end

function parrot:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._is_party_parrot = nil
	end
	return supertable
end

parrot.ai_functions = {
	parrot_check_dance,
	mob_class.sit_if_ordered,
	mob_class.check_travel_to_owner,
	parrot.check_perch,
	mob_class.check_frightened,
	mob_class.check_pace,
}

parrot.gwp_penalties = table.copy (mob_class.gwp_penalties)
parrot.gwp_penalties.DANGER_FIRE = -1.0
parrot.gwp_penalties.DAMAGE_FIRE = -1.0

mcl_mobs.register_mob ("mobs_mc:parrot", parrot)

------------------------------------------------------------------------
-- Parrot spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:parrot", S("Parrot"), "#0da70a", "#ff0000", 0)

------------------------------------------------------------------------
-- Modern Parrot spawning.
-----------------------------------------------------------------------

local parrot_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:parrot",
	weight = 40,
	pack_min = 1,
	pack_max = 2,
	biomes = {
		"#is_jungle",
	},
})

function parrot_spawner:describe_supporting_nodes ()
	return S ("on grass, leaves, or logs")
end

function parrot_spawner:test_supporting_node (node)
	return  core.get_item_group (node.name, "grass_block") > 0
		or core.get_item_group (node.name, "leaves") > 0
		or core.get_item_group (node.name, "tree") > 0
end

mcl_mobs.register_spawner (parrot_spawner)
