--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

------------------------------------------------------------------------
-- Shulker.
------------------------------------------------------------------------

local shulker = {
	description = S("Shulker"),
	type = "monster",
	_spawn_category = "monster",
	persist_in_peaceful = true,
	attack_type = "null",
	hp_min = 30,
	hp_max = 30,
	xp_min = 5,
	xp_max = 5,
	armor = 20,
	collisionbox = {
		-0.5, -0, -0.5, 0.5, 1.0, 0.5,
	},
	visual = "mesh",
	mesh = "mobs_mc_shulker.b3d",
	textures = {
		"mobs_mc_endergolem.png",
	},
	pushable = false,
	visual_size = {
		x = 3,
		y = 3,
	},
	physical = true,
	collide_with_objects = true,
	knockback_resistance = 1.0,
	can_despawn = false,
	fall_speed = 0,
	does_not_prevent_sleep = true,
	drops = {
		{
			name = "mcl_mobitems:shulker_shell",
			chance = 2,
			min = 1,
			max = 1,
			looting = "rare",
			looting_factor = 0.0625,
		},
	},
	animation = {},
	movement_speed = 0,
	_color = "purple",
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = false,
	fire_damage = 0,
	lava_damage = 0,
	sounds = {
		teleport = "mcl_end_teleport",
	},
	_cbox_extension = 0,
	_cbox_animation = 0,
	_cbox_delta = 0,
	_cbox_length = 0,
	_cbox_duration = 0,
	_face = "up",
	_levitation_immune = true,
	head_eye_height = 0.5,
}

------------------------------------------------------------------------
-- Shulker attachment physics.
------------------------------------------------------------------------

function shulker:set_yaw (yaw)
	return
end

function shulker:set_pitch (pitch)
	return
end

function shulker:rotate_step (dtime)
	return
end

local shulker_attachment_parameters = {
	north = {
		rotation = {
			vec = vector.new (math.pi / 2, 0, math.pi),
			absolute = true,
		},
	},
	west = {
		rotation = {
			vec = vector.new (0, 0, math.pi / 2),
			absolute = true,
		},
	},
	south = {
		rotation = {
			vec = vector.new (math.pi / 2 * 3, 0, 0),
			absolute = true,
		},
	},
	east = {
		rotation = {
			vec = vector.new (0, 0, math.pi / 2 * 3),
			absolute = true,
		},
	},
	up = {
		rotation = {
			vec = vector.zero (),
			absolute = true,
		},
	},
	down = {
		rotation = {
			vec = vector.new (0, 0, math.pi),
			absolute = true,
		},
	},
}

local shulker_open_direction = {
	north = vector.new (0, 0, 1),
	west = vector.new (-1, 0, 0),
	south = vector.new (0, 0, -1),
	east = vector.new (1, 0, 0),
	up = vector.new (0, 1, 0),
	down = vector.new (0, -1, 0),
}

function shulker:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	self._cbox_extension = 0
	self._cbox_animation = 0
	self._cbox_delta = 0
	self._cbox_length = 0
	self._cbox_duration = 0
	self:attach_to_face (self._face)
	self._look_target = nil
	return true
end

function shulker:extend_cbox_to (extend)
	local direction = shulker_open_direction [self._face]
	local cbox = table.copy (self.base_colbox)
	if direction.x < 0 then
		cbox[1] = cbox[1] + direction.x * extend
	else
		cbox[4] = cbox[4] + direction.x * extend
	end
	if direction.y < 0 then
		cbox[2] = cbox[2] + direction.y * extend
	else
		cbox[5] = cbox[5] + direction.y * extend
	end
	if direction.z < 0 then
		cbox[3] = cbox[3] + direction.z * extend
	else
		cbox[6] = cbox[6] + direction.z * extend
	end
	self.object:set_properties ({
		collisionbox = cbox
	})
	self.collisionbox = cbox
	self._cbox_length = extend
	if extend < 1.0e-4 then
		self.object:set_armor_groups ({fleshy = 20})
	else
		self.object:set_armor_groups ({fleshy = 100})
	end
end

function shulker:animate_cbox (dtime)
	if self._cbox_animation == 0 then
		if self._cbox_delta ~= self._cbox_delta then
			self:extend_cbox_to (self._cbox_extension)
		end
		return
	end
	if self._cbox_extension >= self._cbox_duration then
		return
	end
	self._cbox_extension = self._cbox_extension + dtime
	local amount = self._cbox_extension / self._cbox_animation
	local extend = self._cbox_fn (amount) * self._cbox_delta
	self._cbox_length = extend
	self:extend_cbox_to (extend)
	if self._cbox_extension >= self._cbox_animation then
		self._cbox_animation = 0
	end
end

function shulker:attach_to_face (facedir)
	local override = shulker_attachment_parameters[facedir]
	if self.object.set_bone_override then
		self.object:set_bone_override ("root", override)
	else
		local pos = override.position
			and override.position.vec
			or vector.zero ()
		local rot = vector.apply (override.rotation.vec, math.deg)
		self.object:set_bone_position ("root", pos, rot)
	end
	self._face = facedir
	self:extend_cbox_to (0)
	self._cbox_retract_delay = 0
	self._cbox_extension = 0
	self._cbox_delta = 0
	self._cbox_animation = 0
	self._cbox_duration = 0
	self._look_target = nil
end

function shulker:do_custom (dtime)
	self:animate_cbox (dtime)
end

local function interpolate_lid_for_attack (d)
	local frame_no = d * 90
	local min, max, min_value, max_value

	if frame_no < 5 then
		return 0.0
	elseif frame_no < 10 then
		min = 5
		max = 10
		min_value = 0.0
		max_value = 0.319
	elseif frame_no < 15 then
		min = 10
		max = 15
		min_value = 0.319
		max_value = 0.709
	elseif frame_no < 20 then
		min = 15
		max = 20
		min_value = 0.709
		max_value = 1.167
	elseif frame_no < 25 then
		min = 20
		max = 25
		min_value = 1.167
		max_value = 2.336
	elseif frame_no < 30 then
		min = 25
		max = 30
		min_value = 2.336
		max_value = 2.884
	elseif frame_no < 40 then
		min = 30
		max = 40
		min_value = 2.884
		max_value = 2.835
	elseif frame_no < 50 then
		min = 40
		max = 50
		min_value = 2.835
		max_value = 2.884
	elseif frame_no < 55 then
		min = 50
		max = 55
		min_value = 2.884
		max_value = 2.336
	elseif frame_no < 60 then
		min = 55
		max = 60
		min_value = 2.336
		max_value = 1.167
	elseif frame_no < 65 then
		min = 60
		max = 65
		min_value = 1.167
		max_value = 0.709
	elseif frame_no < 70 then
		min = 65
		max = 70
		min_value = 0.709
		max_value = 0.319
	elseif frame_no < 75 then
		min = 70
		max = 75
		min_value = 0.319
		max_value = 0.0
	else -- frame_no > 75
		return 0.0
	end

	local frame = (frame_no - min) / (max - min)
	local diff = max_value - min_value
	return (min_value + diff * frame) / 2.884
end

local function interpolate_linearly (delta)
	if delta * 2 <= 1.0 then
		return delta * 2
	else
		return 1.0 - (delta * 2 - 1.0)
	end
end

function shulker:animate_with_collisionbox (cbox_height, frame_start, frame_end, frame_speed,
						fn, offset_start, offset_end)
	local anim_length = (frame_end - frame_start) / frame_speed
	offset_start = offset_start or frame_start
	offset_end = offset_end or frame_end
	local initial_offset = (offset_start - frame_start) / frame_speed
	local anim_duration = (offset_end - offset_start) / frame_speed

	self._cbox_animation = anim_length
	self._cbox_duration = anim_duration + initial_offset
	self._cbox_extension = initial_offset
	self._cbox_delta = cbox_height
	self._cbox_fn = fn or interpolate_linearly
	local anim = {
		x = offset_start,
		y = offset_end,
	}
	self.object:set_animation (anim, frame_speed, 0.1, false)
end

function shulker:set_animation (anim)
	return
end

function shulker:set_animation_speed (custom_speed)
	return
end

-- Attribution: https://github.com/appgurueu/modlib/blob/master/vector.lua
local function box_box_collision (diff, box, other_box)
	for index, diff in pairs (diff) do
		if box[index] + diff > other_box[index + 3]
			or other_box[index] > box[index + 3] + diff then
			return false
		end
	end
	return true
end

local function box_intersection (box, other_box)
	for index = 1, 3 do
		if box[index] > other_box[index + 3]
			or other_box[index] > box[index + 3] then
			return false
		end
	end
	return true
end

local function is_clear (self, nodepos, objpos, dir, cbox)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	if def and not def.walkable and def.liquidtype == "none" then
		local cbox = table.copy (cbox)
		local x1 = dir.x < 0 and dir.x or 0
		local y1 = dir.y < 0 and dir.y or 0
		local z1 = dir.z < 0 and dir.z or 0
		local x2 = dir.x > 0 and dir.x or 0
		local y2 = dir.y > 0 and dir.y or 0
		local z2 = dir.z > 0 and dir.z or 0
		-- Move this collisionbox to NODEPOS, and extend its
		-- height by 0.8.
		cbox[1] = cbox[1] + objpos.x + 1.0e-5 + x1 * 0.8
		cbox[2] = cbox[2] + objpos.y - 0.5 + 1.0e-5 + y1 * 0.8
		cbox[3] = cbox[3] + objpos.z + 1.0e-5 + z1 * 0.8
		cbox[4] = cbox[4] + objpos.x - 1.0e-5 + x2 * 0.8
		cbox[5] = cbox[5] + objpos.y - 0.5 - 1.0e-5 + y2 * 0.8
		cbox[6] = cbox[6] + objpos.z - 1.0e-5 + z2 * 0.8

		-- Locate intersecting shulkers.
		local aa = vector.offset (objpos, -1.5, -1.5, -1.5)
		local bb = vector.offset (objpos, 1.5, 1.5, 1.5)
		for object in core.objects_in_area (aa, bb) do
			if object ~= self.object then
				local entity = object:get_luaentity ()
				if entity and entity.name == "mobs_mc:shulker" then
					local cbox1 = entity.collisionbox
					local pos = object:get_pos ()
					cbox1[1] = cbox1[1] + pos.x + 1.0e-5
					cbox1[2] = cbox1[2] + pos.y - 0.5 + 1.0e-5
					cbox1[3] = cbox1[3] + pos.z + 1.0e-5
					cbox1[4] = cbox1[4] + pos.x - 1.0e-5
					cbox1[5] = cbox1[5] + pos.y - 1.0e-5
					cbox1[6] = cbox1[6] + pos.z - 1.0e-5

					if box_intersection (cbox, cbox1) then
						return false
					end
				end
			end
		end
		return true
	end
	return false
end

local function is_solid (nodepos)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and def.walkable and def.groups.opaque
end

local function is_full_node (node_below)
	local boxes = core.get_node_boxes ("collision_box", node_below)
	if #boxes ~= 1 then
		return false
	end
	local box = boxes[1]
	return (box[1] <= -0.5
		and box[2] <= -0.5
		and box[3] <= -0.5
		and box[4] >= 0.5
		and box[5] >= 0.5
		and box[6] >= 0.5)
end

function shulker:attachment_valid (face, node_pos, obj_pos)
	local forward = shulker_open_direction[face]
	local node_above = vector.add (node_pos, forward)
	local node_below = vector.subtract (node_pos, forward)

	if not is_solid (node_below) then
		return false
	end
	if not is_full_node (node_below) then
		return false
	end
	if core.get_node (node_pos).name ~= "air" then
		return false
	end
	if not is_clear (self, node_above, obj_pos, forward, self.base_colbox) then
		return false
	end
	return true
end

local Z_AXIS = vector.new (0, 0, 1)
local Y_AXIS = vector.new (0, 1, 0)
local HEAD_POS = vector.new (0, 0.25213, 0)

-- N.B.: this identity transform only exists to circumvent an engine
-- bug.
local SHULKER_HEAD_SCALE = {
	vec = vector.new (1, 1, 1),
	absolute = true,
}
local TWO_HUNDERED_AND_SEVENTY_DEG = math.rad (270)

function shulker:shulker_look_at (self_pos, target_pos)
	local face_dir = shulker_open_direction[self._face]
	local axis = face_dir.z ~= 0 and Y_AXIS or Z_AXIS
	local opposite = vector.rotate_around_axis (face_dir, axis, math.pi / 2)
	local orthogonal = vector.cross (face_dir, opposite)
	local dir = vector.subtract (target_pos, self_pos)
	local proj_orth = vector.dot (orthogonal, dir)
	local proj_opposite = vector.dot (opposite, dir)
	local yaw = math.atan2 (proj_orth, proj_opposite)
		- TWO_HUNDERED_AND_SEVENTY_DEG
	local rot = vector.new (0, yaw, 0)

	if self.object.set_bone_override then
		self.object:set_bone_override ("head", {
		       position = {
			       vec = HEAD_POS,
			       absolute = true,
		       },
		       rotation = {
			       vec = rot,
			       absolute = true,
			       interpolation = 0.2,
		       },
		       scale = SHULKER_HEAD_SCALE,
		})
	else
		rot.y = math.deg (rot.y)
		self.object:set_bone_position ("head", HEAD_POS, rot)
	end
end

function shulker:stop_looking ()
	if self.object.set_bone_override then
		self.object:set_bone_override ("head", {
		       position = {
			       vec = HEAD_POS,
			       absolute = true,
		       },
		       rotation = {
			       vec = vector.zero (),
			       absolute = true,
			       interpolation = 0.2,
		       },
		})
	else
		self.object:set_bone_position ("head", HEAD_POS, vector.zero ())
	end
end

------------------------------------------------------------------------
-- Shulker visuals.
------------------------------------------------------------------------

function shulker:check_head_swivel (self_pos, dtime, clear)
	if clear then
		self._locked_object = nil
	else
		self:who_are_you_looking_at ()
	end

	local locked_object = self._locked_object
	if locked_object and is_valid (locked_object) then
		local target_pos = mcl_util.target_eye_pos (locked_object)
		if self._look_target
			and vector.equals (self._look_target, target_pos) then
			return
		end
		self_pos.y = self_pos.y + self:get_eye_height ()
		self:shulker_look_at (self_pos, target_pos)
		self._look_target = target_pos
	elseif self._look_target then
		self:stop_looking ()
	end
end

function shulker:open ()
	self:animate_with_collisionbox (0.85, 45, 145, 24,
					interpolate_lid_for_attack,
					45, 90)
end

function shulker:close ()
	self:animate_with_collisionbox (0.85, 45, 145, 24,
					interpolate_lid_for_attack,
					90, 145)
end

function shulker:peek ()
	self:animate_with_collisionbox (0.24, 25, 45, 45, nil, 25, 35)
end

function shulker:retract ()
	self:animate_with_collisionbox (0.24, 25, 45, 45, nil, 35, 45)
end

local messy_textures = {
	grey = "mobs_mc_shulker_gray.png",
}

local function set_shulker_color(self, color)
	local tx = "mobs_mc_shulker_"..color..".png"
	if messy_textures[color] then tx = messy_textures[color] end
	self:set_textures ({tx})
	self._color = color
end

function shulker:after_activate ()
	if self._color then
		set_shulker_color(self, self._color)
	end
end

function shulker:on_rightclick (clicker)
	if clicker:is_player() then
		local wstack = clicker:get_wielded_item()
		if core.get_item_group(wstack:get_name(),"dye") > 0 then
			set_shulker_color(self, core.registered_items[wstack:get_name()]._color)
			if not core.is_creative_enabled(clicker:get_player_name()) then
				wstack:take_item()
				clicker:set_wielded_item(wstack)
			end
		end
	end
end

------------------------------------------------------------------------
-- Shulker AI.
------------------------------------------------------------------------

function shulker:attack_null (self_pos, dtime, target_pos, line_of_sight)
	if not self.attacking then
		self._attack_cooldown = 1.0
		self:open ()
		self.attacking = true
	end

	self._attack_cooldown = self._attack_cooldown - dtime

	if mcl_vars.difficulty > 0 then
		local distance = vector.distance (self_pos, target_pos)
		if distance < 20 then
			if self._attack_cooldown <= 0 then
				local next_cooldown
					= 20 + math.random (9) * 20 / 2
				self._attack_cooldown
					= next_cooldown / 20

				local dir = vector.direction (self_pos, target_pos)
				local shoot_pos = vector.copy (self_pos)
				if self._face == "up" or self._face == "down" then
					local yaw = math.atan2 (dir.z, dir.x) - math.pi / 2
					local x, z = mcl_util.get_2d_block_direction (yaw)
					if self._face == "up" then
						shoot_pos.y = shoot_pos.y + 1.0 + 0.3125 * 0.5
					else
						shoot_pos.y = shoot_pos.y - 0.3125 * 0.5
					end
					dir = vector.new (x, 0, z)
				elseif self._face == "north" or self._face == "south" then
					local rot = math.atan2 (dir.y, dir.x) - math.pi / 2
					local x, y = mcl_util.get_2d_block_direction (rot)
					if self._face == "south" then
						shoot_pos.z = shoot_pos.z - 0.5 - 0.3125 * 0.5
						shoot_pos.y = shoot_pos.y + 0.5
					else
						shoot_pos.z = shoot_pos.z + 0.5 + 0.3125 * 0.5
						shoot_pos.y = shoot_pos.y + 0.5
					end
					dir = vector.new (x, y, 0)
				else -- if self._face == "west" or self._face == "east" then
					local rot = math.atan2 (dir.y, dir.z) - math.pi / 2
					local z, y = mcl_util.get_2d_block_direction (rot)
					if self._face == "west" then
						shoot_pos.x = shoot_pos.x - 0.5 - 0.3125 * 0.5
						shoot_pos.y = shoot_pos.y + 0.5
					else
						shoot_pos.x = shoot_pos.x + 0.5 + 0.3125 * 0.5
						shoot_pos.y = shoot_pos.y + 0.5
					end
					dir = vector.new (0, y, z)
				end

				local bullet
					= core.add_entity (shoot_pos, "mobs_mc:shulkerbullet")
				if bullet then
					local entity = bullet:get_luaentity ()
					entity._target = self.attack
					entity._dir = dir
					entity._dir_accel = vector.multiply (entity._dir, 3.0)
					entity._shooter = self.object
				end
			end
		else
			self.attack = nil
			self:attack_end ()
			return
		end
	end
end

function shulker:attack_end ()
	mob_class.attack_end (self)
	self:close ()
end

local shulker_faces = {
	"up",
	"north",
	"west",
	"south",
	"east",
	"down",
}

function shulker:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local self_pos = self.object:get_pos ()
	local node_pos = mcl_util.get_nodepos (self_pos)

	if not self:attachment_valid (self._face, node_pos, self_pos) then
		-- Try to attach to a different surface at the same
		-- position.
		table.shuffle (shulker_faces)
		for _, face in pairs (shulker_faces) do
			if self:attachment_valid (face, node_pos, self_pos) then
				self:attach_to_face (face)
				return
			end
		end

		-- If that is impossible, attempt to teleport to a
		-- suitable location.
		self:attempt_teleport (node_pos)
	end
end

local pr = PcgRandom (os.time ())

function shulker:attempt_teleport (node_pos)
	if not node_pos then
		node_pos = mcl_util.get_nodepos (self.object:get_pos ())
	end
	for i = 1, 5 do
		local dx = pr:next (-8, 8)
		local dy = pr:next (-8, 8)
		local dz = pr:next (-8, 8)
		local node = vector.offset (node_pos, dx, dy, dz)
		local data = core.get_node (node)
		if data.name == "air" then
			table.shuffle (shulker_faces)
			for _, face in ipairs (shulker_faces) do
				local objpos = vector.offset (node, 0, -0.5, 0)
				if self:attachment_valid (face, node, objpos) then
					if self.attack then
						self.attack = nil
						if self.attacking then
							self:attack_end ()
						end
					end
					self:mob_sound ("teleport")
					self.object:move_to (objpos)
					self:attach_to_face (face)
					return true
				end
			end
		end
	end

	return false
end

local r = 1 / 2147483647

function shulker:maybe_duplicate ()
	local old_pos = self.object:get_pos ()
	local node_pos = mcl_util.get_nodepos (old_pos)

	if self:attempt_teleport (node_pos) then
		local surviving_shulkers = 0
		local aa = vector.offset (node_pos, -8, -8, -8)
		local bb = vector.offset (node_pos, 8, 8, 8)
		for object in core.objects_in_area (aa, bb) do
			local entity = object:get_luaentity ()
			if entity and entity.name == self.name then
				surviving_shulkers
					= surviving_shulkers + 1
			end
		end
		local chance = (surviving_shulkers - 1) / 5.0
		if pr:next (0, 2147483647) * r >= chance then
			local staticdata = {
				_color = self._color,
			}
			local data = core.serialize (staticdata)
			core.add_entity (old_pos, self.name, data)
		end
	end
end

function shulker:receive_damage (mcl_reason, damage)
	-- Absorb arrow damage if shell is sealed.
	if not self._peek_time and not self.attack then
		if mcl_reason.direct then
			local ent = mcl_reason.direct:get_luaentity ()
			if ent and (ent._is_arrow
				    or ent.name == "mcl_tridents:trident") then
				return false
			end
		end
	end
	if mob_class.receive_damage (self, mcl_reason, damage) then
		if self.health < self.initial_properties.hp_max * 0.5
			and pr:next (4) == 1 then
			self:attempt_teleport ()
		elseif mcl_reason.flags.is_projectile
			and mcl_reason.direct
			and mcl_reason.direct:get_luaentity ()
			and mcl_reason.direct:get_luaentity ().name
				== "mobs_mc:shulkerbullet" then
			self:maybe_duplicate ()
		end
		return true
	end
	return false
end

local scale_chance = mcl_mobs.scale_chance

local function shulker_peek (self, self_pos, dtime)
	if self._peek_time then
		self._peek_time = self._peek_time - dtime
		if self._peek_time < 0 then
			self._peek_time = nil
			self:retract ()
			return false
		end
		return true
	elseif pr:next (1, scale_chance (40, dtime)) == 1 then
		self._peek_time = 1.0 + pr:next (2, 3) / 20
		self:peek ()
		return true
	end
	return false
end

shulker.ai_functions = {
	mob_class.check_attack,
	shulker_peek,
}

local function player_in_search_area_p (self, self_pos, obj, entity)
	local pos = obj:get_pos ()
	local dir = shulker_open_direction[self._face]

	-- Shulkers have a reduced detection range on their axis of
	-- attachment.
	if dir.x ~= 0 then
		return pos.x >= self_pos.x - 4
			and pos.y >= self_pos.y - 16
			and pos.z >= self_pos.z - 16
			and pos.x <= self_pos.x + 4
			and pos.y <= self_pos.y + 16
			and pos.z <= self_pos.z + 16
	elseif dir.y ~= 0 then
		return pos.x >= self_pos.x - 16
			and pos.y >= self_pos.y - 4
			and pos.z >= self_pos.z - 16
			and pos.x <= self_pos.x + 16
			and pos.y <= self_pos.y + 4
			and pos.z <= self_pos.z + 16
	else -- if dir.z ~= 0 then
		return pos.x >= self_pos.x - 16
			and pos.y >= self_pos.y - 16
			and pos.z >= self_pos.z - 4
			and pos.x <= self_pos.x + 16
			and pos.y <= self_pos.y + 16
			and pos.z <= self_pos.z + 4
	end
end

shulker._targeting_rules = {
	mcl_mobs.build_retaliation_target_rule (nil, false, nil),
	mcl_mobs.build_nearest_target_rule ("player", player_in_search_area_p,
					    nil, nil, nil),
}

------------------------------------------------------------------------
-- Shulker spawning.
------------------------------------------------------------------------

mcl_mobs.register_mob ("mobs_mc:shulker", shulker)
mcl_mobs.register_egg ("mobs_mc:shulker", S("Shulker"), "#946694", "#4d3852", 0)

------------------------------------------------------------------------
-- Shulker bullet.
------------------------------------------------------------------------

local shulker_bullet = {
	initial_properties = {
		visual = "mesh",
		mesh = "mobs_mc_shulkerbullet.b3d",
		textures = {
			"mobs_mc_shulkerbullet.png",
			"mobs_mc_shulkerbullet.png^[opacity:50",
			"mobs_mc_shulkerbullet.png^[opacity:50",
		},
		visual_size = {
			x = 0.3125,
			y = 0.3125,
		},
		collisionbox = {
			-0.15625,
			-0.15625,
			-0.15625,
			0.15625,
			0.15625,
			0.15625,
		},
		physical = true,
		collide_with_objects = false,
		static_save = false,
		use_texture_alpha = true,
	},
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	_dir = vector.zero (),
	_dir_accel = vector.zero (),
	_time_to_switch = 0,
	_shooter = nil,
	_target = nil,
	_lifetime = 0,
}

function shulker_bullet:on_activate ()
	self.object:set_animation ({
			x = 0, y = 120,
	}, 30)
	self._time_to_switch = (10 + pr:next (0, 4) * 10) / 20
end

local function is_walkable (nodepos)
	local node = core.get_node (nodepos)
	local def = core.registered_nodes[node.name]
	return def and def.walkable
end

local random_dirs = {
	vector.new (-1, 0, 0),
	vector.new (1, 0, 0),
	vector.new (0, -1, 0),
	vector.new (0, 1, 0),
	vector.new (0, 0, -1),
	vector.new (0, 0, 1),
}

function shulker_bullet:switch_dir (self_pos, target_pos)
	local node_pos = mcl_util.get_nodepos (self_pos)
	local dx = target_pos.x - self_pos.x
	local dy = target_pos.y - self_pos.y
	local dz = target_pos.z - self_pos.z
	local directions = {}
	local dir = nil

	if self._dir.x == 0 then
		local dir = nil
		if dx < 0 then
			dir = vector.new (-1, 0, 0)
		elseif dx > 0 then
			dir = vector.new (1, 0, 0)
		end
		if dir then
			local node = vector.add (node_pos, dir)
			if not is_walkable (node) then
				table.insert (directions, dir)
			end
		end
	end

	if self._dir.y == 0 then
		local dir = nil
		if dy < 0 then
			dir = vector.new (0, -1, 0)
		elseif dy > 0 then
			dir = vector.new (0, 1, 0)
		end
		table.insert (directions, dir)
		if dir then
			local node = vector.add (node_pos, dir)
			if not is_walkable (node) then
				table.insert (directions, dir)
			end
		end
	end

	if self._dir.z == 0 then
		local dir = nil
		if dz < 0 then
			dir = vector.new (0, 0, -1)
		elseif dz > 0 then
			dir = vector.new (0, 0, 1)
		end
		if dir then
			local node = vector.add (node_pos, dir)
			if not is_walkable (node) then
				table.insert (directions, dir)
			end
		end
	end

	if #directions > 0 then
		dir = directions[pr:next (1, #directions)]
	end

	if not dir then
		table.shuffle (random_dirs)
		for _, potential_dir in pairs (random_dirs) do
			local node = vector.add (node_pos, potential_dir)
			if not is_walkable (node) then
				dir = potential_dir
				break
			end
		end
	end

	if dir then
		self._dir = dir
		self._dir_accel = vector.multiply (dir, 3.0)
	end
end

function shulker_bullet:attack_allowed (object)
	return not object:is_player ()
		or not core.is_creative_enabled (object:get_player_name ())
end

function shulker_bullet:hit_object (object)
	mcl_potions.give_effect_by_level ("levitation", object, 1, 10)
	mcl_mobs.get_arrow_damage_func (4) (self, object)
end

function shulker_bullet:check_hit (self_pos, moveresult, v, dtime)
	for _, item in pairs (moveresult.collisions) do
		if item.type == "node" then
			core.sound_play("tnt_explode", {
				pos = self_pos, gain = 1.0,
				max_hear_distance = 16,
			}, true)
			mcl_explosions.add_particles (self_pos, 2)
			self.object:remove ()
			return true
		end
	end

	-- Unhappily, non-colliding mobs are not included in collision
	-- processing or collision data provided in moveresults...
	local aa = vector.offset (self_pos, -3, -3, -3)
	local bb = vector.offset (self_pos, 3, 3, 3)
	local cbox
		= table.copy (shulker_bullet.initial_properties.collisionbox)
	cbox[1] = cbox[1] + self_pos.x - v.x * dtime
	cbox[2] = cbox[2] + self_pos.y - v.y * dtime
	cbox[3] = cbox[3] + self_pos.z - v.z * dtime
	cbox[4] = cbox[4] + self_pos.x - v.x * dtime
	cbox[5] = cbox[5] + self_pos.y - v.y * dtime
	cbox[6] = cbox[6] + self_pos.z - v.z * dtime
	for object in core.objects_in_area (aa, bb) do
		local entity = object:get_luaentity ()
		if ((entity and entity.is_mob) or object:is_player ())
			and (self._lifetime > 1.0 or object ~= self._shooter) then
			local cbox1 = object:get_properties ().collisionbox
			local pos = object:get_pos ()

			cbox1[1] = cbox1[1] + pos.x
			cbox1[2] = cbox1[2] + pos.y
			cbox1[3] = cbox1[3] + pos.z
			cbox1[4] = cbox1[4] + pos.x
			cbox1[5] = cbox1[5] + pos.y
			cbox1[6] = cbox1[6] + pos.z

			local movement = {
				v.x * dtime,
				v.y * dtime,
				v.z * dtime,
			}
			if box_box_collision (movement, cbox, cbox1) then
				self:hit_object (object)
				self.object:remove ()
				return true
			end
		end
	end

	return false
end

local pow_by_step = mcl_mobs.pow_by_step

function shulker_bullet:on_step (dtime, moveresult)
	local v = self.object:get_velocity ()
	local self_pos = self.object:get_pos ()
	local t = math.max (0, self._time_to_switch - dtime)
	self._time_to_switch = t
	self._lifetime = self._lifetime + dtime

	if math.random (2) == 1 then
		local particle_pos
			= vector.offset (self_pos, v.x * dtime,
					 v.y * dtime, v.z * dtime)
		core.add_particle ({
			pos = particle_pos,
			expirationtime = 5.0,
			texture = "mcl_particles_smoke_anim.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 8,
				aspect_h = 8,
				length = 5.0,
			},
			size = mcl_util.float_random (1, 4),
		})
	end

	if self:check_hit (self_pos, moveresult, v, dtime) then
		return
	end

	if not self._target or not is_valid (self._target)
		or not self:attack_allowed (self._target) then
		v.y = v.y - 0.8 * dtime / 0.05
		self.object:set_velocity (v)
		return
	end

	local target_pos = mcl_util.target_eye_pos (self._target)
	if self._time_to_switch == 0 then
		self:switch_dir (self_pos, target_pos)
		self._time_to_switch = (10 + pr:next (0, 4) * 10) / 20
	end

	local node_pos = mcl_util.get_nodepos (self_pos)
	local next_node = vector.add (node_pos, self._dir)
	local target_nodepos = mcl_util.get_nodepos (target_pos)

	if is_walkable (next_node)
		or (node_pos.x == target_nodepos.x and self._dir.x ~= 0)
		or (node_pos.y == target_nodepos.y and self._dir.y ~= 0)
		or (node_pos.z == target_nodepos.z and self._dir.z ~= 0) then
		self:switch_dir (self_pos, target_pos)
		self._time_to_switch = (10 + pr:next (0, 4) * 10) / 20
	end

	local accel = self._dir_accel
	local friction = pow_by_step (0.2, dtime)
	local h_scale = (1 - friction) / (1 - 0.2)

	local target = {
		x = v.x + (accel.x - v.x) * h_scale * friction,
		y = v.y + (accel.y - v.y) * h_scale * friction,
		z = v.z + (accel.z - v.z) * h_scale * friction,
	}
	self.object:set_velocity (target)
end

function shulker_bullet:on_punch (_, _, _, _, _)
	core.sound_play ("mcl_criticals_hit", {
		object = self.object,
	}, true)
	local pos = self.object:get_pos ()
	core.add_particlespawner ({
		amount = 15,
		time = 0.1,
		minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
		maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
		minvel = {x=-0.1, y=-0.1, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=0, y=0, z=0},
		maxacc = {x=0, y=0, z=0},
		minexptime = 1,
		maxexptime = 2,
		minsize = 1.5,
		maxsize = 1.5,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
	})
	self.object:remove ()
	return true
end

core.register_entity ("mobs_mc:shulkerbullet", shulker_bullet)
