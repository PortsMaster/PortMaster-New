--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

--###################
--################### STRIDER
--###################


local strider = {
	description = S("Strider"),
	type = "animal",
	_spawn_category = "creature",
	runaway = true,
	hp_min = 20,
	hp_max = 20,
	xp_min = 9,
	xp_max = 9,
	armor = {
		fleshy = 90,
		water_vulnerable = 90,
	},
	collisionbox = {
		-0.45, -0.01, -0.45,
		0.45, 1.69, 0.45,
	},
	visual = "mesh",
	mesh = "extra_mobs_strider.b3d",
	textures = {
		{
			"extra_mobs_strider.png",
		},
	},
	visual_size = {
		x = 3,
		y = 3,
	},
	sounds = {
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = true,
	movement_speed = 3.5,
	drops = {
		{
			name = "mcl_mobitems:string",
			chance = 1,
			min = 2,
			max = 5,
		},
	},
	animation = {
		stand_speed = 15,
		walk_speed = 15,
		stand_start = 5,
		stand_end = 5,
		walk_start = 1,
		walk_end = 20,
	},
	follow = {
		"mcl_crimson:warped_fungus",
		"mcl_mobitems:warped_fungus_on_a_stick",
		"mcl_mobitems:warped_fungus_on_a_stick_enchanted",
	},
	lava_damage = 0,
	fire_damage = 0,
	water_damage = 5,
	_mcl_freeze_damage = 5,
	fire_resistant = true,
	floats_on_lava = true,
	floats = 0,
	steer_class = "follow_item",
	steer_item = "group:controls_strider",
	run_bonus = 1.65,
	follow_herd_bonus = 1.0,
	follow_bonus = 1.4,
	drive_bonus = 0.55,
	view_range = 16.0,
	tracking_distance = 16.0,
}

------------------------------------------------------------------------
-- Strider mechanics.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () - 74)

function strider:on_spawn ()
	if not self.child then
		if pr:next (1, 30) == 1 then
			local self_pos = self.object:get_pos ()
			local no_jockeys = core.serialize ({
				_no_chicken_jockeys = true,
			})
			local rider = core.add_entity (self_pos, "mobs_mc:zombified_piglin",
							   no_jockeys)
			if rider then
				local entity = rider:get_luaentity ()
				local pos = {
					x = 0,
					y = entity.child and 4.3 or 3.0,
					z = 0,
				}
				entity:jock_to_existing (self.object, "", pos)
				entity:set_wielditem (ItemStack ("mcl_mobitems:warped_fungus_on_a_stick"))
			end
		elseif pr:next (1, 10) == 1 then
			local self_pos = self.object:get_pos ()
			local child = core.serialize ({
				child = true,
			})
			local rider = core.add_entity (self_pos, self.name, child)
			if rider then
				local entity = rider:get_luaentity ()
				local pos = {
					x = 0,
					y = 5.0,
					z = 0,
				}
				entity:jock_to_existing (self.object, "", pos)
			end
		end
	end
end

function strider:actionable_on_rightclick (player)
	return self.saddle == "yes"
end

------------------------------------------------------------------------
-- Strider mounting.
------------------------------------------------------------------------

function mobs_mc.is_riding_strider (obj)
	local obj = obj:get_attach ()
	if obj and is_valid (obj) then
		local entity = obj:get_luaentity ()
		return entity and entity.name == "mobs_mc:strider"
	end
	return false
end

-- Nullify all lava damage for players mounted on striders.  This is
-- not optimal at all, but the server is unaware of attachment points
-- and would otherwise regard riders as in contact with lava below.
mcl_damage.register_modifier (function (obj, damage, reason)
	if reason.type == "lava" and obj:is_player ()
		and mobs_mc.is_riding_strider (obj) then
		return 0
	end
	return damage
end, -1000)

function strider:detach (driver, pos)
	local thing = mcl_util.get_pointed_thing (driver, false, false, {})
	if thing and thing.type == "node" then
		local self_pos = self.object:get_pos ()
		local node_pos = vector.offset (thing.under, 0, 1, 0)
		local node = core.get_node (node_pos)
		local def = core.registered_nodes[node.name]
		local node_1 = core.get_node (vector.offset (node_pos, 0, 1, 0))
		local def_1 = core.registered_nodes[node_1.name]

		if vector.distance (self_pos, node_pos) <= 4
			and not def.walkable and not def_1.walkable then
			mob_class.detach (self, driver, vector.zero ())
			core.after (0.1, function ()
				if is_valid (driver) then
					driver:set_pos (vector.offset (node_pos, 0, -0.5, 0))
				end
			end)
			return
		end
	end
	mob_class.detach (self, driver, pos)
end

function strider:do_custom (dtime)
	if self.driver then
		local controls = self.driver:get_player_control ()
		if not controls.sneak then
			return
		end
		self:detach (self.driver, {x = 1, y = 0, z = 1})
	end
end

function strider:on_rightclick (clicker)
	local item = clicker:get_wielded_item ()
	local name = item:get_name ()

	if name == "mcl_crimson:warped_fungus" then
		self:mob_sound ("eat")
		if self:feed_tame (clicker, nil, true, false) then
			return
		end
	end

	if self.child then
		return
	end

	if name == "mcl_mobitems:saddle" and self.saddle ~= "yes" then
		self.base_texture = {
			"extra_mobs_strider.png",
			"mobs_mc_pig_saddle.png",
		}
		self:set_textures (self.base_texture)
		self.saddle = "yes"
		self.drops = {
			{
				name = "mcl_mobitems:string",
				chance = 1,
				min = 1,
				max = 3,
			},
			{
				name = "mcl_mobitems:saddle",
				chance = 1,
				min = 1,
				max = 1,
			},
		}
		local clicker_name = clicker:get_player_name ()
		if not core.is_creative_enabled (clicker_name) then
			item:take_item ()
			clicker:set_wielded_item (item)
			core.sound_play ({name = "mcl_armor_equip_leather"},
				{gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
		end
	elseif core.get_item_group(name, "shears") > 0 and self.saddle == "yes" and not self.driver then
		self.base_texture = {"extra_mobs_strider.png", "blank.png"}
		self:set_textures(self.base_texture)
		self.saddle = "false"
		self.drops = {
			{
				name = "mcl_mobitems:string",
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
			local wear = mcl_autogroup.get_wear(name, "shearsy")
			item:add_wear(wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
	elseif not self.driver
		and not self._jockey_rider
		and self.saddle == "yes" then
		local vsize = self.object:get_properties ().visual_size
		self.driver_attach_at = {x = 0, y = 5.1, z = -1.75}
		self.driver_eye_offset = {x = 0, y = 10, z = 0}
		self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}
		self:attach (clicker)
	elseif self.driver and clicker == self.driver then
		if mcl_util.is_item_or_in_group(name, self.steer_item) then
			if self:hog_boost () and not core.is_creative_enabled(clicker:get_player_name()) then
				local inv = clicker:get_inventory()
				local wielditem = clicker:get_wielded_item()
				if wielditem:get_wear() > 62865 then
					-- Break carrot on a stick
					local def = wielditem:get_definition()
					if def.sounds and def.sounds.breaks then
						core.sound_play(def.sounds.breaks, {pos = clicker:get_pos(), max_hear_distance = 8, gain = 0.5}, true)
					end
					wielditem = {name = "mcl_fishing:fishing_rod", count = 1}
				else
					wielditem:add_wear(635)
				end
				inv:set_stack("main",self.driver:get_wield_index(), wielditem)
			end
		else
			self:detach (clicker, {x = 1, y = 0, z = 0})
		end
	end
end

------------------------------------------------------------------------
-- Strider AI.
------------------------------------------------------------------------

function strider:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._aground = false
	return true
end

-- The default breeding routine is unsuitable as it is apt to
-- propagate the textures of saddled striders to their offspring.
function strider:on_breed (parent1, parent2)
	local pos = parent1.object:get_pos ()
	local child = mcl_mobs.spawn_child (pos, parent1.name)
	if child then
		local ent_c = child:get_luaentity ()
		ent_c.persistent = true
		return false
	end
end

function strider:ai_step (dtime)
	mob_class.ai_step (self, dtime)

	local was_aground = self._aground
	self._aground = false

	if core.get_item_group (self.standing_on, "lava") == 0
		and core.get_item_group (self.standing_in, "lava") == 0 then
		self._aground = true
	end
	if self.jockey_vehicle then
		local vehicle = self.jockey_vehicle:get_luaentity ()
		if vehicle and vehicle.name == "mobs_mc:strider" then
			self._aground = vehicle._aground
		end
	end

	if self._aground and not was_aground then
		self:add_physics_factor ("movement_speed", "mobs_mc:strider_out_of_water", 0.66)
		local textures = table.copy (self.base_texture)
		textures[0] = "extra_mobs_strider_cold.png"
		self:set_textures (textures)
		self.shaking = true
		self.drive_bonus = 0.35
	elseif not self._aground and was_aground then
		self:remove_physics_factor ("movement_speed", "mobs_mc:strider_out_of_water")
		self:set_textures (self.base_texture)
		self.shaking = false
		self.drive_bonus = 0.55
	end
end

function strider:pacing_target (pos, width, height, groups)
	local lava = mob_class.pacing_target (self, pos, width, height, {
		"group:lava",
	})
	if lava then
		return lava
	end
	return mob_class.pacing_target (self, pos, width, height, groups)
end

local function manhattan3d (v1, v2)
	return math.abs (v1.x - v2.x)
		+ math.abs (v1.y - v2.y)
		+ math.abs (v1.z - v2.z)
end

local function strider_go_to_lava (self, self_pos, dtime)
	if self._heading_to_lava then
		local t = self._heading_to_lava_time + dtime
		self._heading_to_lava_time = t
		if vector.distance (self_pos, self._heading_to_lava) < 1.0
			or self:navigation_finished () or t > 60 then
			if not self:navigation_finished () then
				self:cancel_navigation ()
				self:halt_in_tracks ()
			end
			self._heading_to_lava = nil
			return true
		end
		if self:check_timer ("strider_repath", 1.0) then
			self:gopath (self._heading_to_lava)
		end
		return true
	elseif self._aground then
		if not self:check_timer ("strider_locate_lava", 0.5) then
			return false
		end
		local nodepos = mcl_util.get_nodepos (self_pos)
		local aa = vector.offset (nodepos, -8, -2, -8)
		local bb = vector.offset (nodepos, 8, 2, 8)
		local lava = core.find_nodes_in_area_under_air (aa, bb, {
			"group:lava",
		})
		if #lava == 0 then
			return false
		end
		table.sort (lava, function (a, b)
			return manhattan3d (a, nodepos)
				< manhattan3d (b, nodepos)
		end)
		for _, node in ipairs (lava) do
			local offset = vector.offset (node, 0, 1, 0)

			if self:gwp_classify_for_movement (offset)
				== "WALKABLE" then
				self._heading_to_lava = node
				self._heading_to_lava_time = 0.0
				self:gopath (node)
				return "_heading_to_lava"
			end
		end
		return false
	end
	return false
end

strider.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	strider_go_to_lava,
	mob_class.follow_herd,
	mob_class.check_pace,
}

------------------------------------------------------------------------
-- Strider pathfinding.
------------------------------------------------------------------------

local gwp_ej_scratch = vector.zero ()
local gwp_basic_classify = mcl_mobs.gwp_basic_classify

function strider:gwp_essay_jump (context, target, parent, floor)
	-- Striders cannot jump from lava onto a normal walkable
	-- surface.

	local v = gwp_ej_scratch
	local surface_class = nil
	local target_class = nil
	local width = context.mob_width
	local floortypes = self.gwp_floortypes

	for z = 1, width do
		for x = 1, width do
			v.x = parent.x + x - 1
			v.y = parent.y - 1
			v.z = parent.z + z - 1

			local class = gwp_basic_classify (v)
			if (not surface_class or class ~= "LAVA")
				and not floortypes[class] then
				surface_class = class
			end

			v.x = target.x + x - 1
			v.y = target.y - 1
			v.z = target.z + z - 1
			local class = gwp_basic_classify (v)
			if (not target_class or class ~= "LAVA")
				and not floortypes[class] then
				target_class = class
			end
		end
	end

	if target_class ~= surface_class
		and surface_class == "LAVA" then
		return nil
	end
	return mob_class.gwp_essay_jump (self, context, target, parent, floor)
end

strider.gwp_floortypes = table.copy (mob_class.gwp_floortypes)
strider.gwp_floortypes.LAVA = nil

strider.gwp_penalties = table.merge (mob_class.gwp_penalties, {
	WATER = -1.0,
	LAVA = 0.0,
	DANGER_FIRE = 0.0,
	DAMAGE_FIRE = 0.0,
})

------------------------------------------------------------------------
-- Strider spawning.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:strider", strider)

mcl_mobs.register_egg ("mobs_mc:strider", S("Strider"), "#000000", "#FF0000", 0)

------------------------------------------------------------------------
-- Modern Strider spawning.
------------------------------------------------------------------------

local default_spawner = mcl_mobs.default_spawner
local strider_spawner = {
	name = "mobs_mc:strider",
	spawn_category = "creature",
	spawn_placement = "lava",
	weight = 60,
	pack_min = 1,
	pack_max = 2,
	biomes = {
		"CrimsonForest",
		"WarpedForest",
		"NetherWastes",
		"BasaltDeltas",
		"SoulSandValley",
	},
}

function strider_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					      spawn_flag)
	local above = self:get_node (node_cache, 1, node_pos)
	return above.name == "air"
		and default_spawner.test_spawn_position (self, spawn_pos, node_pos,
							 sdata, node_cache,
							 spawn_flag)
end

mcl_mobs.register_spawner (strider_spawner)

-----------------------------------------------------------------------
-- Legacy baby strider.
-----------------------------------------------------------------------

local old_baby_strider = table.merge (strider, {
	description = S("Baby Strider"),
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 13,
	xp_max = 13,
	textures = {
		{
			"extra_mobs_strider.png",
			"blank.png",
		},
	},
	child = true,
})

function old_baby_strider:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self:replace_with ("mobs_mc:strider", true)
	return true
end

mcl_mobs.register_mob ("mobs_mc:baby_strider", old_baby_strider)

