--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local illager = mobs_mc.illager
local evoker = mobs_mc.evoker
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Illusioner.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () * 666)

local illusioner = table.merge (evoker, {
	description = S("Illusioner"),
	type = "monster",
	_spawn_category = "monster",
	attack_type = "bowshoot",
	shoot_interval = 0.5,
	hp_min = 32,
	hp_max = 32,
	xp_min = 6,
	xp_max = 6,
	collisionbox = {-0.4, 0, -0.4, 0.4, 1.95, 0.4},
	visual = "mesh",
	mesh = "mobs_mc_illusioner.b3d",
	textures = {
		{
			"mobs_mc_illusionist.png",
			"mobs_mc_illusionist.png",
		},
	},
	drops = {
	},
	shoot_offset = 1.25,
	head_swivel = "head.control",
	bone_eye_height = 6.61948,
	head_eye_height = 2.2,
	curiosity = 10,
	tracking_distance = 18.0,
	view_range = 18.0,
	sounds = {
		distance = 16,
	},
	visual_size = {
		x = 1.0,
		y = 1.0,
	},
	movement_speed = 5.0,
	can_wield_items = "no_pickup",
	wielditem_info = {
		toollike_position = vector.new (-1.0, 2.0, 0) * 2.75,
		toollike_rotation = vector.new (-180, 0, -135),
		bow_position = vector.new (0, 2.1, 0) * 2.75,
		bow_rotation = vector.new (-7, 7, -45),
		crossbow_position = vector.new (-0.45, 2.0, 0) * 2.75,
		crossbow_rotation = vector.new (90, 135, 90),
		blocklike_position = vector.new (-0.8, 2.0, -0.3) * 2.75,
		blocklike_rotation = vector.new (135, 0, 0),
		position = vector.new (-0.6, 2.0, 0) * 2.75,
		rotation = vector.new (-90, 0, 0),
		bone = "bow",
		rotate_bone = true,
	},
	wielditem_drop_probability = 0.085,
	_decoys = {},
	_banner_bone = "head",
	_banner_bone_position = vector.new (0, 0, -2.556729),
	_decoy_wielditems = {},
})

------------------------------------------------------------------------
-- Illusioner mechanics.
------------------------------------------------------------------------

function illusioner:on_spawn ()
	local stack = ItemStack ("mcl_bows:bow")
	local self_pos = self.object:get_pos ()
	local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
	evoker.on_spawn (self)
	self:set_wielditem (stack)
	self:enchant_default_weapon (mob_factor, pr)
end

------------------------------------------------------------------------
-- Illusioner visuals.
------------------------------------------------------------------------

local illusioner_poses = {
	default = {
		["arm"] = {},
		["magic.arm.left"] = {
			nil,
			nil,
			vector.zero (),
		},
		["magic.arm.right"] = {
			nil,
			nil,
			vector.zero (),
		},
	},
	shoot = {
		["arm"] = {
			nil,
			nil,
			vector.zero (),
		},
		["magic.arm.right"] = {
			vector.new (1.0, 1.9, 0) * 2.75,
			vector.new (90, 0, -90),
			vector.new (1, 1, 1),
		},
		["magic.arm.left"] = {
			vector.new (-1.0, 1.9, 0) * 2.75,
			vector.new (85, 28, -47),
			vector.new (1, 1, 1),
		},
	},
	spellcast = {
		["arm"] = {
			nil,
			nil,
			vector.zero (),
		},
		["magic.arm.left"] = {
			nil,
			nil,
			vector.new (1, 1, 1),
		},
		["magic.arm.right"] = {
			nil,
			nil,
			vector.new (1, 1, 1),
		},
	},
}

local illusioner_poses_with_decoys = {}
for key, pose in pairs (illusioner_poses) do
	local list = {}
	for bone, override in pairs (pose) do
		list[bone] = override
		list[bone .. ".001"] = override
		list[bone .. ".002"] = override
		list[bone .. ".003"] = override
		list[bone .. ".004"] = override
	end
	illusioner_poses_with_decoys[key] = list
end

function illusioner:select_arm_pose ()
	if not self.attack then
		return "default"
	elseif self._casting_spell
		and self._cast_particle then
		return "spellcast"
	else
		return "shoot"
	end
end

illusioner._arm_poses = illusioner_poses

function illusioner:apply_arm_pose (pose)
	local decoys = self._decoy_wielditems
	evoker.apply_arm_pose (self, pose)

	if pose ~= "default" then
		if self._wielditem_object then
			self._wielditem_object:set_properties ({
				visual_size = {
					x = 0.21,
					y = 0.21,
				},
			})
		end

		for _, decoy in pairs (decoys) do
			if is_valid (decoy) then
				decoy:set_properties ({
					visual_size = {
						x = 0.21,
						y = 0.21,
					},
				})
			end
		end
	else
		if self._wielditem_object then
			self._wielditem_object:set_properties ({
				visual_size = {
					x = 0,
					y = 0,
				},
			})
		end

		for _, decoy in pairs (decoys) do
			if is_valid (decoy) then
				decoy:set_properties ({
					visual_size = {
						x = 0,
						y = 0,
					},
				})
			end
		end
	end
end

function illusioner:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	if self._arm_pose == "default" then
		size.x = 0
		size.y = 0
	else
		size.x = 0.21
		size.y = 0.21
	end
	return rot, pos, size
end

function illusioner:is_armor_texture_slot (i)
	return i > 1
end

function illusioner:set_bone_override (name, rot)
	local object = self.object
	if object.set_bone_override then
		object:set_bone_override (name, {
			  rotation = {
				  vec = rot,
				  absolute = true,
				  interpolation = 0.1,
			  },
		})
	else
		local rot = vector.apply (rot, math.deg)
		self.object:set_bone_position (name, nil, rot)
	end
end

function illusioner:set_bone_position (name, pos, yaw)
	local object = self.object
	if object.set_bone_override then
		local rotation = vector.new (0, -yaw, 0)
		object:set_bone_override (name, {
			  position = {
				  vec = pos,
				  absolute = true,
				  interpolation = 0.1,
			  },
			  rotation = {
				  vec = rotation,
				  absolute = true,
				  interpolation = 0.1,
			  },
		})
	else
		local rotation = vector.new (0, -math.deg (yaw), 0)
		self.object:set_bone_position (name, pos, rotation)
	end
end

local ZERO = vector.new (0, 6.61948, 0)

function illusioner:refresh_illusion (offsets, yaw)
	self:set_bone_position ("body", ZERO, yaw)
	self:set_bone_position ("body.001", offsets[1], yaw)
	self:set_bone_position ("body.002", offsets[2], yaw)
	self:set_bone_position ("body.003", offsets[3], yaw)
	self:set_bone_position ("body.004", offsets[4], yaw)
end

function illusioner:receive_damage (mcl_reason, damage)
	if mob_class.receive_damage (self, mcl_reason, damage)
		and self._illusion_offsets then
		self._timers.illusion = 0.5

		local offsets = {
			ZERO, ZERO, ZERO, ZERO,
		}
		local yaw = self:get_yaw ()
		self._illusion_offsets = offsets
		self:refresh_illusion (offsets, yaw)
		return true
	end
	return false
end

function illusioner:configure_illusion (dtime)
	if self:check_timer ("illusion", 60) or not self._illusion_offsets then
		local offsets = {
			{
				x = pr:next (-60, 60),
				y = 6.61948,
				z = pr:next (-60, 60),
			},
			{
				x = pr:next (-60, 60),
				y = 6.61948,
				z = pr:next (-60, 60),
			},
			{
				x = pr:next (-60, 60),
				y = 6.61948,
				z = pr:next (-60, 60),
			},
			{
				x = pr:next (-60, 60),
				y = 6.61948,
				z = pr:next (-60, 60),
			},
		}
		local yaw = self:get_yaw ()
		self._illusion_offsets = offsets
		self:refresh_illusion (offsets, yaw)
	end
end

function illusioner:do_custom (dtime)
	evoker.do_custom (self, dtime)

	if self._illusion_offsets then
		self:configure_illusion (dtime)
	end
end

function illusioner:set_yaw (yaw)
	if not self._illusion_offsets then
		mob_class.set_yaw (self, yaw)
	else
		local offsets = self._illusion_offsets
		self._target_yaw = yaw
		self:refresh_illusion (offsets, yaw)
	end
end

function illusioner:rotate_step (dtime)
	if not self._illusion_offsets then
		mob_class.rotate_step (self, dtime)
	end
end

function illusioner:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)

	if supertable then
		supertable._illusion_offsets = nil
		supertable._arm_poses = nil
		supertable._decoy_wielditems = nil
	end
	return supertable
end

function illusioner:adjust_head_swivel (mob_yaw, mob_pitch, out_of_view)
	if self._illusion_offsets then
		local yaw = mob_yaw and self:get_yaw () + mob_yaw or 0
		local rot = vector.new (mob_pitch or 0, yaw, 0)
		if out_of_view then
			rot.y = 0
			rot.x = 0
		end
		self:set_bone_override ("head.001", rot)
		self:set_bone_override ("head.002", rot)
		self:set_bone_override ("head.003", rot)
		self:set_bone_override ("head.004", rot)
		mob_yaw = yaw
	end
	return mob_yaw, mob_pitch, out_of_view
end

function illusioner:mob_activate (staticdata, dtime)
	if not evoker.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._decoy_wielditems = {}
	return true
end

function illusioner:wielditem_step (dtime)
	if self._using_wielditem then
		self._using_wielditem
			= self._using_wielditem + dtime

		local stack = ItemStack (self._wielditem)
		local name = self:get_visual_wielditem (stack)
		local object = self._wielditem_object
		if object and is_valid (object) then
			object:set_properties ({
				wield_item = name,
			})
		end
		local decoys = self._decoy_wielditems
		for i, decoy in pairs (decoys) do
			if is_valid (decoy) then
				decoy:set_properties ({
					wield_item = name,
				})
			end
		end
	end
end

function illusioner:release_wielditem ()
	if self._using_wielditem then
		self._using_wielditem = nil

		local stack = ItemStack (self._wielditem)
		local name = self:get_visual_wielditem (stack)
		local object = self._wielditem_object
		if object and is_valid (object) then
			object:set_properties ({
				wield_item = name,
			})
		end
		local decoys = self._decoy_wielditems
		for i, decoy in pairs (decoys) do
			if is_valid (decoy) then
				decoy:set_properties ({
					wield_item = name,
				})
			end
		end
	end
end

function illusioner:display_wielditem (offhand)
	local decoys = self._decoy_wielditems
	if #decoys == 0 or offhand then
		mob_class.display_wielditem (self, offhand)
	else
		local stack = ItemStack (self._wielditem)
		if stack:is_empty () then
			self:remove_wielditems ()
			return
		end
		self:create_wielditems ()
		local info = self.wielditem_info
		local decoys = self._decoy_wielditems
		local rot, pos, size = self:wielditem_transform (info, stack)
		local name = self:get_visual_wielditem (stack)

		for i, decoy in pairs (decoys) do
			if is_valid (decoy) then
				local bone = "bow.00" .. i
				decoy:set_attach (self.object, bone)
				mcl_util.set_bone_position (self.object, bone, pos, rot)
				decoy:set_properties ({
					wield_item = name,
					visual_size = size,
				})
			end
		end
	end
end

function illusioner:create_wielditems ()
	local stack = ItemStack (self._wielditem)

	if not stack:is_empty () then
		local info = self.wielditem_info
		local self_pos = self.object:get_pos ()
		local new_wielditems = self._decoy_wielditems
		local rot, pos, size = self:wielditem_transform (info, stack)
		local name = self:get_visual_wielditem (stack)

		if self._wielditem_object
			and is_valid (self._wielditem_object) then
			new_wielditems[1] = self._wielditem_object
			new_wielditems[1]:set_attach (self.object, "bow.001")
			mcl_util.set_bone_position (self.object, "bow.001", pos, rot)
			new_wielditems[1]:set_properties ({
				wield_item = name,
				visual_size = size,
			})
		end
		self._wielditem_object = nil
		for i = #new_wielditems + 1, 4 do
			local bone = "bow.00" .. i
			new_wielditems[i]
				= core.add_entity (self_pos, "mcl_mobs:wielditem")

			if not new_wielditems[i] then
				return
			end
			new_wielditems[i]:set_attach (self.object, bone)
			mcl_util.set_bone_position (self.object, bone, pos, rot)
			new_wielditems[i]:set_properties ({
				wield_item = name,
				visual_size = size,
			})
		end
	end
end

function illusioner:remove_wielditems ()
	for _, decoy in pairs (self._decoy_wielditems) do
		decoy:remove ()
	end
	self._decoy_wielditems = {}
end

function illusioner:set_invisible (hide)
	mob_class.set_invisible (self, hide)

	if hide then
		self.object:set_yaw (0)
		self.object:set_properties ({
			mesh = "mobs_mc_illusioner_with_decoys.b3d",
		})
		self._arm_poses = illusioner_poses_with_decoys

		-- Move the current wielditem object to the first
		-- decoy, and create a number of additional
		-- wielditems.
		self:create_wielditems ()
		self:configure_illusion ()
		self:apply_arm_pose (self._arm_pose or "default")
	else
		self:set_bone_position ("body", ZERO, 0)
		self.object:set_properties ({
			mesh = "mobs_mc_illusioner.b3d",
		})
		local yaw = self:get_yaw ()
		self.object:set_yaw (yaw)
		if self._rotation_info then
			self._rotation_info.current = yaw
			self._rotation_info.remaining_turn = 0
		end
		self:remove_wielditems ()
		self._arm_poses = illusioner_poses
		self._illusion_offsets = nil
		self:apply_arm_pose (self._arm_pose or "default")
	end
end

------------------------------------------------------------------------
-- Illusioner AI & spells.
------------------------------------------------------------------------

function illusioner:ai_step (dtime)
	evoker.ai_step (self, dtime)
	if self._last_blinded and not is_valid (self._last_blinded) then
		self._last_blinded = nil
	end
end

local illusioner_mirror_spell = evoker.define_spell ({
	activity_name = "_mirror",
	particle_color = "#4c4c4c",
	arm_time = 1.0,
	duration = 1.0,
	interval = 17,
	check_activate = function (self, self_pos, dtime)
		return not mcl_potions.has_effect (self.object, "invisibility")
	end,
	step = function (self, self_pos, dtime, rem)
		if not mcl_potions.has_effect (self.object, "invisibility") then
			mcl_potions.give_effect ("invisibility", self.object, 0, 60)
		end
		return rem > 0
	end,
})

local illusioner_blindness_spell = evoker.define_spell ({
	activity_name = "_blindness",
	particle_color = "#191933",
	arm_time = 1.0,
	duration = 2.0,
	interval = 9,
	check_activate = function (self, self_pos, dtime)
		if self._last_blinded ~= self.attack and self.attack then
			local difficulty
				= mcl_worlds.get_regional_difficulty (self_pos)
			return difficulty >= 2.0
		end
		return false
	end,
	step = function (self, self_pos, dtime, rem)
		if self.attack and is_valid (self.attack)
			and not mcl_potions.has_effect (self.attack, "blindness") then
			mcl_potions.give_effect ("blindness", self.attack, 0, 60)
		end
		self._last_blinded = self.attack
		return rem > 0
	end,
})

illusioner._combat_spells = {
	illusioner_mirror_spell,
	illusioner_blindness_spell,
}

function illusioner:attack_bowshoot (self_pos, dtime, target_pos, line_of_sight)
	if not self._casting_spell then
		mob_class.attack_bowshoot (self, self_pos, dtime, target_pos, line_of_sight)
	else
		-- Halt for the duration of the spell.
		self:release_wielditem ()

		if not self:navigation_finished () then
			self:cancel_navigation ()
			self:halt_in_tracks ()
		end

		-- Reset attack state.
		self._target_visible_time = 0
		self._strafe_time = -1
		self._z_strafe = 1
		self._x_strafe = 1
		self._shoot_timer = 0
	end
end

function illusioner:shoot_arrow (pos, dir)
	local wielditem = self:get_wielditem ()
	mcl_bows.shoot_arrow ("mcl_bows:arrow", pos, dir,
			self:get_yaw (), self.object, 0.5333333, nil,
			false, wielditem)
end

illusioner.ai_functions = {
	mob_class.check_attack,
	illager.check_recover_banner,
	illager.check_pathfind_to_raid,
	illager.check_navigate_village,
	illager.check_distant_patrol,
	illager.check_celebrate,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:illusioner", illusioner)

------------------------------------------------------------------------
-- Illusioner spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg ("mobs_mc:illusioner", S("Illusioner"), "#3f5cbb", "#8a8686", 0)
