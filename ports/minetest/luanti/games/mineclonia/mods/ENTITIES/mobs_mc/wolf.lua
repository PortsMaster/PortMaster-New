--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local pr = PcgRandom (os.time () *10)
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Wolf.
------------------------------------------------------------------------

local wolf = {
	description = S("Wolf"),
	type = "animal",
	_spawn_category = "creature",
	hp_min = 8,
	hp_max = 8,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 0.85, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_wolf.b3d",
	_child_mesh = "mobs_mc_baby_wolf.b3d",
	-- Textures are actually set by update_textures.
	textures = {},
	makes_footstep_sound = true,
	head_swivel = "head.control",
	bone_eye_height = 3.5,
	head_eye_height = 0.68,
	horizontal_head_height = 0,
	curiosity = 3,
	head_yaw = "z",
	sounds = {
		attack = "mobs_mc_wolf_bark",
		war_cry = "mobs_mc_wolf_growl",
		damage = {
			name = "mobs_mc_wolf_hurt",
			gain = 0.6,
		},
		death = {
			name = "mobs_mc_wolf_death",
			gain = 0.6,
		},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	floats = 1,
	movement_speed = 6.0,
	damage = 4,
	reach = 2,
	attack_type = "melee",
	_melee_esp = true,
	animation = {
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		walk_speed = 30,
		sit_start = 41,
		sit_end = 41,
		interest_begin_start = 41,
		interest_begin_end = 44,
		interest_begin_loop = false,
		interest_end_start = 44,
		interest_end_end = 47,
		interest_end_loop = false,
		shake_start = 48,
		shake_end = 71,
		shake_speed = 23,
		shake_loop = false,
	},
	runaway_from = {
		"mobs_mc:llama",
		"mobs_mc:trader_llama",
	},
	_collar_color = "#FF0000",
	run_bonus = 1.5,
	_is_wet = false,
	_owner_attacked_serial = 0,
	_owner_target_serial = 0,
}

------------------------------------------------------------------------
-- Wolf visuals & mechanics.
------------------------------------------------------------------------

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

local function wolf_variant (prefix, biomes)
	return {
		wild_texture = "mobs_mc_" .. prefix .. ".png",
		tame_texture = "mobs_mc_" .. prefix .. "_tame.png",
		angry_texture = "mobs_mc_" .. prefix .. "_angry.png",
		biomes = biomes,
	}
end

local wolf_variants = {
	pale = wolf_variant ("wolf", nil),
	spotted = wolf_variant ("wolf_spotted", {
		"#is_savannah",
	}),
	snowy = wolf_variant ("wolf_snowy", {
		"Grove",
	}),
	black = wolf_variant ("wolf_black", {
		"OldGrowthPineTaiga",
	}),
	ashen = wolf_variant ("wolf_ashen", {
		"SnowyTaiga",
	}),
	rusty = wolf_variant ("wolf_rusty", {
		"#is_jungle",
	}),
	woods = wolf_variant ("wolf_woods", {
		"Forest",
	}),
	chestnut = wolf_variant ("wolf_chestnut", {
		"OldGrowthSpruceTaiga",
	}),
	striped = wolf_variant ("wolf_striped", {
		"#is_badlands",
	}),
}

local variant_by_biome = {}

core.register_on_mods_loaded (function ()
	for name, variant in pairs (wolf_variants) do
		if variant.biomes then
			local biomes = mcl_biome_dispatch.build_biome_list (variant.biomes)
			for _, biome in ipairs (biomes) do
				variant_by_biome[biome] = name
			end
		end
	end
end)

function wolf:on_breed (parent1, parent2)
	local self_pos = self.object:get_pos ()
	local child = mcl_mobs.spawn_child (self_pos, self.name)
	if child then
		local ent_c = child:get_luaentity ()
		-- Use texture of one of the parents
		local p = math.random (1, 2)
		if p == 1 then
			ent_c._wolf_variant = parent1._wolf_variant
			ent_c._collar_color = parent1._collar_color
		else
			ent_c._wolf_variant = parent2._wolf_variant
			ent_c._collar_color = parent2._collar_color
		end
		ent_c.tamed = true
		ent_c.owner = self.owner
		ent_c.base_texture = ent_c:compute_textures ()
		ent_c:set_textures (ent_c.base_texture)
		ent_c:after_tame ()
		return false
	end
end

function wolf:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	if self.tamed then
		self.object:set_properties ({
			hp_max = 40.0,
		})
	end
	return true
end

function wolf:after_tame ()
	self.object:set_properties ({
		hp_max = 40.0,
	})
	self.health = 40
end

function wolf:wetness_modifier ()
	if not self._is_wet then
		return nil
	else
		return "^[colorize:#000000:65"
	end
end

function wolf:compute_textures ()
	if not self._wolf_variant then
		self._wolf_variant = "pale"
	end
	local variant = wolf_variants[self._wolf_variant]
	assert (variant)
	if self.tamed then
		return {
			table.concat ({
				variant.tame_texture,
				"^",
				"(mobs_mc_wolf_collar.png",
				"^[colorize:",
				self._collar_color,
				":192)",
				self:wetness_modifier (),
			}),
			"blank.png", -- Wolf armor.
			"blank.png", -- Wolf armor overlay.
		}
	elseif self.attack then
		return {
			table.concat ({
				variant.angry_texture,
				self:wetness_modifier (),
			}),
			"blank.png",
			"blank.png",
		}
	else
		return {
			table.concat ({
				variant.wild_texture,
				self:wetness_modifier (),
			}),
			"blank.png",
			"blank.png",
		}
	end
end

function wolf:update_textures ()
	if not self._wolf_variant then
		-- Establish which variant to spawn.
		local self_pos = self.object:get_pos ()
		local biome = mcl_biome_dispatch.get_biome_name (self_pos)
		local variant
			= (biome and variant_by_biome[biome]) or "pale"
		self._wolf_variant = variant
	end

	self.base_texture = self:compute_textures ()
	self.base_mesh = self.initial_properties.mesh
	self.base_size = self.initial_properties.visual_size
	self.base_colbox = self.initial_properties.collisionbox
	self.base_selbox = self.initial_properties.selectionbox
end

local SIXTY_FIVE_DEG = math.rad (65)

function wolf:get_tail_height ()
	local health_max = 40 -- get_properties as always is far too expensive.
	return self.health / health_max * SIXTY_FIVE_DEG
end

function wolf:update_tail ()
	local anim = self._current_animation
	if self.tamed and (anim == "stand" or anim == "walk"
				or anim == "shake")
		and self.object.set_bone_override then
		-- Update tail height.
		self.object:set_bone_override ("tail", {
			rotation = {
				vec = vector.new (-self:get_tail_height (), 0, 0),
				absolute = false,
			},
		})
	end
end

function wolf:do_custom (dtime)
	if self.health ~= self._old_health then
		self._old_health = self.health
		self:update_tail ()
	end
end

function wolf:set_animation (anim, custom_frame)
	if self._shaking and anim == "stand" then
		anim = "shake"
	end

	if (anim == "stand" or anim == "walk" or anim == "shake")
		and self._current_animation ~= anim
		and self.tamed
		and self.object.set_bone_override then
		self.object:set_bone_override ("tail", {
		       rotation = {
			       vec = vector.new (-self:get_tail_height (), 0, 0),
			       absolute = false,
		       },
		})
	elseif anim ~= self._current_animation
		and self.object.set_bone_override then
		self.object:set_bone_override ("tail", nil)
	end

	mob_class.set_animation (self, anim, custom_frame)
end

function wolf:add_shake_particles ()
	local start = self.child and 0.15 or 0.3
	core.add_particlespawner ({
		time = 1.0,
		amount = 180,
		exptime = 100,
		vel = {
			min = vector.new (-1.0, 4.0, -1.0),
			max = vector.new (1.0, 4.0, 1.0),
		},
		acc = {
			min = vector.new (0, -9.81, 0),
			max = vector.new (0, -9.81, 0),
		},
		pos = {
			min = vector.new (-0.3, start, -0.3),
			max = vector.new (0.3, start, 0.3),
		},
		size = {
			min = 1.5,
			max = 2.1,
		},
		collisiondetection = true,
		collision_removal = true,
		texpool = {
			"mobs_mc_wolf_splash_0.png",
			"mobs_mc_wolf_splash_1.png",
			"mobs_mc_wolf_splash_2.png",
			"mobs_mc_wolf_splash_3.png",
		},
		attached = self.object,
	})
end

function wolf:check_head_swivel (self_pos, dtime, clear)
	if not self._interested_in then
		mob_class.check_head_swivel (self, self_pos, dtime, clear)
	end
end

local TWENTY_SEVEN_DEG = math.rad (27)
local SIXTY_DEG = math.rad (60)

local function visually_display_interest_1 (self, yaw, dx, dy, dz)
	local yaw = math.atan2 (dz, dx) - math.pi / 2 - yaw
	local pitch = math.atan2 (dy, math.sqrt (dz * dz + dx * dx))
	local head_pitch = math.min (math.max (-SIXTY_DEG, pitch), SIXTY_DEG)
	local norm_yaw = mcl_util.norm_radians (yaw)
	local head_yaw = math.min (math.max (-SIXTY_DEG, norm_yaw), SIXTY_DEG)
	self.object:set_bone_override ("body.head", {
		rotation = {
			vec = vector.new (0, TWENTY_SEVEN_DEG, 0),
			absolute = false,
			interpolate = 0.15,
		},
	})
	self.object:set_bone_override ("head.control", {
		rotation = {
			vec = vector.new (-head_pitch, 0, head_yaw),
			absolute = false,
			interpolate = 0.15,
		},
	})
	self._old_head_swivel_vector = nil
end

function wolf:visually_display_interest (dtime, self_pos, target_pos)
	if self.object.set_bone_override then
		local dz = target_pos.z - self_pos.z
		local dx = target_pos.x - self_pos.x
		local dy = target_pos.y - (self_pos.y + self:get_eye_height ())
		local yaw = self.object:get_yaw ()

		if not self._beg_vector
			or self._beg_yaw ~= yaw
			or self._beg_vector.x ~= dx
			or self._beg_vector.y ~= dy
			or self._beg_vector.z ~= dz then
			self._beg_vector = vector.new (dx, dy, dz)
			self._beg_yaw = yaw
			visually_display_interest_1 (self, yaw, dx, dy, dz)
			self._beg_rotate_time = nil
		elseif not self._active_activity
			or self._active_activity == "sit_if_ordered" then
			if not self._beg_rotate_time then
				self._beg_rotate_time = 0.0
			elseif self._beg_rotate_time then
				local t = self._beg_rotate_time + dtime

				if t > 0.5 then
					self:look_at (target_pos)
					t = 0
				end
				self._beg_rotate_time = t
			end
		else
			self._beg_rotate_time = nil
		end
	end
end

function wolf:visually_cancel_interest ()
	if self.object.set_bone_override then
		self.object:set_bone_override ("body.head", nil)
		self.object:set_bone_override ("head.control", nil)
		self._old_head_swivel_vector = nil
	end
	self._beg_rotate_time = nil
	self._beg_vector = nil
end

function wolf:is_interested_in (player)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()
	if name == "mcl_mobitems:bone" then
		return true
	elseif self.tamed and self:is_food (name) then
		return true
	end
	return false
end

------------------------------------------------------------------------
-- Wolf interaction.
------------------------------------------------------------------------

local wolf_food = {
	["mcl_fishing:pufferfish_raw"] = 1,
	["mcl_fishing:clownfish_raw"] = 1,
	["mcl_mobitems:chicken"] = 2,
	["mcl_mobitems:mutton"] = 2,
	["mcl_fishing:fish_raw"] = 2,
	["mcl_fishing:salmon_raw"] = 2,
	["mcl_mobitems:porkchop"] = 3,
	["mcl_mobitems:beef"] = 3,
	["mcl_mobitems:rabbit"] = 3,
	["mcl_mobitems:rotten_flesh"] = 4,
	["mcl_mobitems:cooked_rabbit"] = 5,
	["mcl_fishing:fish_cooked"] = 5,
	["mcl_mobitems:cooked_mutton"] = 6,
	["mcl_mobitems:cooked_chicken"] = 6,
	["mcl_fishing:salmon_cooked"] = 6,
	["mcl_mobitems:cooked_porkchop"] = 8,
	["mcl_mobitems:cooked_beef"] = 8,
	["mcl_mobitems:rabbit_stew"] = 10,
}

function wolf:is_food (name)
	return wolf_food[name] ~= nil
end

function wolf:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item ()
	local wield_food = wolf:is_food (wielditem:get_name())
	return self.tamed or wield_food
end

function wolf:on_rightclick (clicker)
	if not clicker:is_player () then
		return
	end

	local playername = clicker:get_player_name ()
	local creative = core.is_creative_enabled (playername)
	local stack = clicker:get_wielded_item ()
	local name = stack:get_name ()
	local self_pos = self.object:get_pos ()

	if self.tamed then
		local heal = wolf_food[name]
		local props = self.object:get_properties ()
		if heal and self.health < props.hp_max then
			local hp_max = props.hp_max
			self.health = math.min (hp_max, self.health + heal)

			if not creative then
				stack:take_item ()
				clicker:set_wielded_item (stack)
			end
			return
		end

		if playername == self.owner
			and core.get_item_group (name, "dye") == 1 then
			local consumed = false
			-- Dye if possible.
			for group, color in pairs (colors) do
				-- Check if color is supported
				if core.get_item_group (name, group) == 1 then
					if color ~= self._collar_color then
						self._collar_color = color
						consumed = true
						break
					end
				end
			end

			if consumed then
				if not creative then
					stack:take_item ()
					clicker:set_wielded_item (stack)
				end
				self.base_texture = self:compute_textures ()
				self:set_textures (self.base_texture)
			end
			return
		end

		--------------------------------------------------------
		-- TODO: wolf armor.
		--------------------------------------------------------

		if heal and self:feed_tame (clicker, nil, true, false, false, false) then
			return
		end

		if self.owner and self.owner == playername then
			if self.order == "sit" then
				self.order = ""
			else
				self.order = "sit"
			end
		end
	elseif name == "mcl_mobitems:bone" and not self.attack then
		local r = pr:next (1, 3)
		if r == 1 then
			self:just_tame (self_pos, clicker)
			self.base_texture = self:compute_textures ()
			self:set_textures (self.base_texture)
			self.order = "sit"
			self:after_tame ()
		else
			mcl_mobs.effect (vector.offset (self_pos, 0, 0.7, 0),
					5, "mcl_particles_mob_death.png^[colorize:#000000:255",
					2, 4, 2.0, 0.1)
		end
		if not creative then
			stack:take_item ()
			clicker:set_wielded_item (stack)
		end
	end
end

------------------------------------------------------------------------
-- Wolf player damage accounting.
------------------------------------------------------------------------

local player_damage_sources = {}
local mobs_damaged_by_player = {}
local serials = {}

mcl_damage.register_modifier (function (obj, damage, reason)
	if obj:is_player () then
		if reason.source then
			local name = obj:get_player_name ()
			local serial = (serials[name] or 0) + 1
			player_damage_sources[name] = {
				reason.source, serial, 5.0,
			}
			serials[name] = serial
		end
	else
		local entity = obj:get_luaentity ()
		if entity.is_mob then
			local source = reason.source
			if source and source:is_player () then
				local name = source:get_player_name ()
				local serial = (serials[name] or 0) + 1
				mobs_damaged_by_player[name] = {
					obj, serial, 5.0,
				}
				serials[name] = serial
			end
		end
	end
	return damage
end)

core.register_globalstep (function (dtime)
	for key, value in pairs (player_damage_sources) do
		local ttl = value[3]
		ttl = ttl - dtime
		if ttl > 0 then
			value[3] = ttl
		else
			player_damage_sources[key] = nil
		end
	end

	for key, value in pairs (mobs_damaged_by_player) do
		local ttl = value[3]
		ttl = ttl - dtime
		if ttl > 0 then
			value[3] = ttl
		else
			mobs_damaged_by_player[key] = nil
		end
	end
end)

------------------------------------------------------------------------
-- Wolf AI.
------------------------------------------------------------------------

function wolf:ai_step (dtime)
	local moveresult = self._moveresult
	mob_class.ai_step (self, dtime)

	if (self._immersion_depth and self._immersion_depth > 0)
		or mcl_weather.is_exposed_to_rain (self:get_nodepos ()) then
		if not self._is_wet then
			self._is_wet = true
			self.base_texture = self:compute_textures ()
			self:set_textures (self.base_texture)
		end
		if self._shaking then
			self._shaking = nil
			if self._current_animation == "shake" then
				self:set_animation ("stand")
			end
		end
	elseif self._is_wet and not self._active_activity
		and not self._shaking
		and (moveresult.touching_ground
			or moveresult.standing_on_object) then
		self._shaking = 1.0
		self:set_animation ("shake")
		self:add_shake_particles ()
	end

	if self._shaking then
		local t = self._shaking - dtime
		if t <= 0 then
			self._shaking = nil
			if self._current_animation == "shake" then
				if self:navigation_finished () then
					self:set_animation ("stand")
				else
					self:set_animation ("walk")
				end
			end
			self._is_wet = false
			self.base_texture = self:compute_textures ()
			self:set_textures (self.base_texture)
		else
			self._shaking = t
		end
	end

	if (not self.attack and self._was_attacking)
		or (not self._was_attacking and self.attack) then
		self._was_attacking = self.attack
		self.base_texture = self:compute_textures ()
		self:set_textures (self.base_texture)
	end

end

function wolf:is_frightened ()
	return self._frozen_for > 0
		or mcl_burning.is_burning (self.object)
end

function wolf:should_attack_owner_assailant_or_target (object)
	local entity = object:get_luaentity ()
	if entity then
		local obj_pos = object:get_pos ()
		return entity.is_mob
			and entity.name ~= "mobs_mc:creeper"
			and entity.name ~= "mobs_mc:creeper_charged"
			and entity.name ~= "mobs_mc:ghast"
			and (entity.name ~= "mobs_mc:wolf"
				or not self.owner or entity.owner ~= self.owner)
			and not entity.tamed
			and self:test_object_and_restriction (object, obj_pos)
	elseif object:is_player () then
		local obj_pos = object:get_pos ()
		return object:get_player_name () ~= self.owner
			and self:test_object_and_restriction (object, obj_pos)
	end
	return false
end

function wolf:breeding_possible ()
	return self.tamed and self._active_activity ~= "sit_if_ordered"
end

function wolf:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._owner_attacked_serial = nil
		supertable._owner_target_serial = nil
		supertable._was_attacking = nil
		supertable._old_health = nil
	end
	return supertable
end

local function unpack3 (tem)
	return tem[1], tem[2], tem[3]
end

function wolf:get_wolf_owner_assailant ()
	if self.owner then
		local data = player_damage_sources[self.owner]
		local source, serial, _ = unpack3 (data or {})

		if serial and serial > self._owner_attacked_serial
			and is_valid (source)
			and self:should_attack_owner_assailant_or_target (source) then
			self._owner_attacked_serial = serial
			return source
		end
	end

	return nil
end

function wolf:get_wolf_owner_target ()
	if self.owner then
		local data = mobs_damaged_by_player[self.owner]
		local target, serial, _ = unpack3 (data or {})

		if serial and serial > self._owner_target_serial
			and is_valid (target)
			and self:should_attack_owner_assailant_or_target (target) then
			self._owner_target_serial = serial
			return target
		end
	end

	return nil
end

function wolf:attack_melee (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._leaping = false
	end

	local moveresult = self._moveresult
	if self._leaping then
		if moveresult.touching_ground
			or moveresult.standing_on_object then
			self._leaping = false
		end
		-- Trigger a repath after leaping.
		self._target_pos = nil
		self._attack_delay = 0
		return
	end

	-- Possibly leap at the target.
	local dist = vector.distance (self_pos, target_pos)
	local chance = math.round (5 * dtime / 0.05)
	local r = math.random (chance)

	if self.attacking
		and dist > 2 and dist < 4 and r == 1
		and moveresult.touching_ground
			or moveresult.standing_on_object then
		self._leaping = true
		self:cancel_navigation ()
		self:halt_in_tracks ()
		local leap = vector.direction (self_pos, target_pos)
		local v = self.object:get_velocity ()
		leap.x = leap.x * 8.0 + v.x * 0.2
		leap.y = 8.0
		leap.z = leap.z * 8.0 + v.z * 0.2
		self:set_yaw (math.atan2 (leap.z, leap.x) - math.pi / 2)
		self.object:set_velocity (leap)
		return
	end

	mob_class.attack_melee (self, self_pos, dtime, target_pos, line_of_sight)
end

local function wolf_check_beg (self, self_pos, dtime)
	if self._interested_in then
		local target = self._interested_in
		if not is_valid (target)
			or self.attack or self._avoiding_llama
			or not self:is_interested_in (target) then
			self:visually_cancel_interest ()
			self._interested_in = nil
			return false
		end
		local pos = mcl_util.target_eye_pos (target)
		self:visually_display_interest (dtime, self_pos, pos)
		return false
	elseif not self.attack and not self._avoiding_llama
		and self:check_timer ("interest", 0.25) then
		local nearest, dist
		for player in mcl_util.connected_players (self_pos, 8.0) do
			if self:is_interested_in (player) then
				local player_pos = player:get_pos ()
				local distance = vector.distance (self_pos, player_pos)
				if not nearest or dist > distance then
					nearest = player
					dist = distance
				end
			end
		end
		self._interested_in = nearest
	end
	return false
end

function wolf:should_runaway_from_mob (entity)
	return (entity.name == "mobs_mc:llama"
			or entity.name == "mobs_mc:trader_llama")
		and entity._llama_strength
		and entity._llama_strength >= pr:next (0, 4)
end

wolf.ai_functions = {
	wolf_check_beg,
	mob_class.check_frightened,
	mob_class.sit_if_ordered,
	mob_class.check_avoid,
	mob_class.check_attack,
	mob_class.check_travel_to_owner,
	mob_class.check_breeding,
	mob_class.check_pace,
}

local function wolf_wild_p (self)
	return not self.tamed
end

local function wolf_defend_owner_rule (self, self_pos, dtime, obj, is_current)
	if obj and is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, nil)
	end

	local obj1 = self:get_wolf_owner_assailant ()
	if obj1 and (vector.distance (obj1:get_pos (), self_pos)
		     <= self.tracking_distance) then
		return obj1
	end
	return nil
end

local function wolf_support_owner_rule (self, self_pos, dtime, obj, is_current)
	if obj and is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, nil)
	end

	local obj1 = self:get_wolf_owner_target ()
	if obj1 and (vector.distance (obj1:get_pos (), self_pos)
		     <= self.tracking_distance) then
		return obj1
	end
	return nil
end

wolf._targeting_rules = {
	mcl_mobs.build_target_rule ({
		fn = wolf_defend_owner_rule,
		on_complete = nil,
	}),
	mcl_mobs.build_target_rule ({
		fn = wolf_support_owner_rule,
		on_complete = nil,
	}),
	mcl_mobs.build_retaliation_target_rule (nil, true, {
		"mobs_mc:wolf",
	}),
	mcl_mobs.build_nearest_target_rule ("animal", {
		"mobs_mc:sheep",
		"mobs_mc:rabbit",
	}, wolf_wild_p, nil, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:skeleton", {
		"mobs_mc:skeleton",
		"mobs_mc:witherskeleton",
		"mobs_mc:stray",
	}, nil, nil, nil),
	mcl_mobs.build_alert_receiver_rule (),
}

mcl_mobs.register_mob ("mobs_mc:wolf", wolf)

------------------------------------------------------------------------
-- Wolf spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:wolf", S("Wolf"), "#d7d3d3", "#ceaf96", 0)

------------------------------------------------------------------------
-- Modern Wolf spawning.
------------------------------------------------------------------------

local wolf_spawner_taiga = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:wolf",
	weight = 8,
	pack_min = 4,
	pack_max = 4,
	biomes = {
		"#is_taiga",
	},
})

function wolf_spawner_taiga:test_supporting_node (node)
	return core.get_item_group (node.name, "grass_block") > 0
		or node.name == "mcl_core:snowblock"
		or node.name == "mcl_core:coarse_dirt"
		or node.name == "mcl_core:podzol"
end

function wolf_spawner_taiga:describe_supporting_nodes ()
	return S ("on grass, snow blocks, coarse dirt, or podzol")
end

function wolf_spawner_taiga:prepare_to_spawn (pack_size, center)
	local biome = mcl_biome_dispatch.get_biome_name (center)
	local variant
		= (biome and variant_by_biome[biome]) or "pale"
	return {
		_wolf_variant = variant,
	}
end

local wolf_spawner_sparse_jungle = table.merge (wolf_spawner_taiga, {
	pack_min = 2,
	pack_max = 4,
	biomes = {
		"SparseJungle",
	},
})

local wolf_spawner_savannah = table.merge (wolf_spawner_taiga, {
	pack_min = 4,
	pack_max = 8,
	biomes = {
		"#is_savannah",
	},
})

local wolf_spawner_mesa = table.merge (wolf_spawner_taiga, {
	weight = 2,
	pack_min = 4,
	pack_max = 8,
	biomes = {
		"#is_badlands",
	},
})

local wolf_spawner_forest = table.merge (wolf_spawner_taiga, {
	weight = 5,
	pack_min = 4,
	pack_max = 4,
	biomes = {
		"Forest",
	},
})

local wolf_spawner_grove = table.merge (wolf_spawner_taiga, {
	weight = 1,
	pack_min = 1,
	pack_max = 1,
	biomes = {
		"Grove",
	},
})

mcl_mobs.register_spawner (wolf_spawner_taiga)
mcl_mobs.register_spawner (wolf_spawner_sparse_jungle)
mcl_mobs.register_spawner (wolf_spawner_savannah)
mcl_mobs.register_spawner (wolf_spawner_mesa)
mcl_mobs.register_spawner (wolf_spawner_forest)
mcl_mobs.register_spawner (wolf_spawner_grove)

------------------------------------------------------------------------
-- Legacy tamed Wolf (``dog'').
------------------------------------------------------------------------

local dog = table.copy (wolf)

function dog:mob_activate (self_pos)
	local staticdata = {
		owner = self.owner,
		_collar_color = self._collar_color,
		tamed = true,
		order = self.order,
	}
	local wolf = self:replace_with ("mobs_mc:wolf", false, staticdata)
	if wolf then
		local entity = wolf:get_luaentity ()
		entity:after_tame ()
	end
	self.object:remove ()
end

mcl_mobs.register_mob ("mobs_mc:dog", dog)
