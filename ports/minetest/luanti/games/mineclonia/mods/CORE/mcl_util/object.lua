function mcl_util.get_hp(obj)
	local luaentity = obj:get_luaentity()

	if luaentity and luaentity.is_mob then
		return luaentity.health
	elseif obj:is_player () then
	   return mcl_damage.get_hp (obj)
	else
		return obj:get_hp()
	end
end

function mcl_util.get_inventory(object, create)
	if object:is_player() then
		return object:get_inventory()
	else
		local luaentity = object:get_luaentity()
		local inventory = luaentity.inventory

		if luaentity and create and not inventory and luaentity.create_inventory then
			inventory = luaentity:create_inventory()
		end

		return inventory
	end
end

function mcl_util.get_object_name(object)
	if object:is_player() then
		return object:get_player_name()
	else
		local luaentity = object:get_luaentity()

		if not luaentity then
			return tostring(object)
		end

		return luaentity.nametag and luaentity.nametag ~= "" and luaentity.nametag or luaentity.description or luaentity.name
	end
end

function mcl_util.is_creative(object)
	return object and object:is_player() and core.is_creative_enabled(object:get_player_name())
end

function mcl_util.replace_mob(obj, mob_type, propagate_equipment)
	local sacrifice = obj:get_luaentity()
	return sacrifice:replace_with(mob_type, propagate_equipment)
end

local function get_visual_size(obj)
	return obj:is_player() and vector.new(1, 1, 1)
		or obj:get_luaentity()._old_visual_size
		or obj:get_properties().visual_size
end

function mcl_util.detach_object(obj, change_pos, callback)
	if not obj or not obj:get_pos() then return end
	obj:set_detach()
	obj:set_properties({visual_size = get_visual_size(obj)})
	if obj:is_player() then
		-- It is possible for this table to be nil when
		-- invoked from an on_leaveplayer callback.
		if mcl_player.players[obj] then
			mcl_player.players[obj].attached = nil
			obj:set_eye_offset(vector.zero(), vector.zero())
			mcl_player.player_set_animation(obj, "stand", 30)
		end
	else
		obj:get_luaentity()._old_visual_size = nil
	end
	if change_pos then
		 obj:set_pos(vector.add(obj:get_pos(), change_pos))
	end
	if callback then
		core.after(0.1, function(obj)
			if not obj or not obj:get_pos() then return end
			callback(obj)
		end, obj)
	end
end

-- adjust the y level of an object to the center of its collisionbox
-- used to get the origin position of entity explosions
function mcl_util.get_object_center(obj)
	local collisionbox = obj:get_properties().collisionbox
	local pos = obj:get_pos()
	local ymin = collisionbox[2]
	local ymax = collisionbox[5]
	pos.y = pos.y + (ymax - ymin) / 2.0
	return pos
end

function mcl_util.get_wielditem(object)
	local entity = object:get_luaentity()
	if object:is_player() then
		return object:get_wielded_item()
	elseif entity and entity.is_mob then
		return entity:get_wielditem()
	end
	return ItemStack()
end

function mcl_util.get_additional_knockback (object)
	local entity = object:get_luaentity ()
	return entity
		and entity.is_mob
		and entity._attack_knockback
		or 0
end

function mcl_util.target_eye_height (attack)
	local luaentity = attack:get_luaentity ()

	if luaentity and luaentity.is_mob then
		return luaentity:get_eye_height ()
	elseif attack:is_player () then
		return attack:get_properties ().eye_height
	end
	return 0
end

function mcl_util.target_eye_pos (attack)
	local luaentity = attack:get_luaentity ()
	local pos = attack:get_pos ()

	if luaentity and luaentity.is_mob then
		pos.y = pos.y + luaentity:get_eye_height ()
	elseif attack:is_player() then
		pos.y = pos.y + attack:get_properties ().eye_height
	end
	return pos
end

function mcl_util.object_has_mc_physics(object)
	local entity = object:get_luaentity()
	return mcl_serverplayer.is_csm_capable(object)
		or (entity and entity.is_mob)
end

-- This following part is 2 wrapper functions + helpers for
-- object:set_bones
-- and player:set_properties preventing them from being resent on
-- every globalstep when they have not changed.

local function roundN(n, d)
	if type(n) ~= "number" then return n end
	local m = 10 ^ d
	return math.floor(n * m + 0.5) / m
end

local function close_enough(a, b)
	local rt = true
	if type(a) == "table" and type(b) == "table" then
		for k, v in pairs(a) do
			if roundN(v, 2) ~= roundN(b[k], 2) then
				rt = false
				break
			end
		end
	else
		rt = roundN(a, 2) == roundN(b, 2)
	end
	return rt
end

local function props_changed(props, oldprops)
	local props = props or {}
	if not oldprops then return true, props end
	local changed = false
	local p = {}
	for k, v in pairs(props) do
		if not close_enough(v, oldprops[k]) then
			p[k] = v
			changed = true
		end
	end
	return changed, p
end

-- tests for roundN
local test_round1 = 15
local test_round2 = 15.00199999999
local test_round3 = 15.00111111
local test_round4 = 15.00999999

assert(roundN(test_round1, 2) == roundN(test_round1, 2))
assert(roundN(test_round1, 2) == roundN(test_round2, 2))
assert(roundN(test_round1, 2) == roundN(test_round3, 2))
assert(roundN(test_round1, 2) ~= roundN(test_round4, 2))

-- tests for close_enough
local test_cb = {-0.35, 0, -0.35, 0.35, 0.8, 0.35} --collisionboxes
local test_cb_close = {-0.351213, 0, -0.35, 0.35, 0.8, 0.351212}
local test_cb_diff = {-0.35, 0, -1.35, 0.35, 0.8, 0.35}

local test_eh = 1.65 --eye height
local test_eh_close = 1.65123123
local test_eh_diff = 1.35

local test_nt = {r = 225, b = 225, a = 225, g = 225} --nametag
local test_nt_diff = {r = 225, b = 225, a = 0, g = 225}

assert(close_enough(test_cb, test_cb_close))
assert(not close_enough(test_cb, test_cb_diff))
assert(close_enough(test_eh, test_eh_close))
assert(not close_enough(test_eh, test_eh_diff))
assert(not close_enough(test_nt, test_nt_diff)) --no floats involved here

-- tests for properties_changed
local test_properties_set1 = {collisionbox = {-0.35, 0, -0.35, 0.35, 0.8, 0.35}, eye_height = 0.65,
	nametag_color = {r = 225, b = 225, a = 225, g = 225}}
local test_properties_set2 = {collisionbox = {-0.35, 0, -0.35, 0.35, 0.8, 0.35}, eye_height = 1.35,
	nametag_color = {r = 225, b = 225, a = 225, g = 225}}

local test_p1, _ = props_changed(test_properties_set1, test_properties_set1)
local test_p2, _ = props_changed(test_properties_set1, test_properties_set2)

assert(not test_p1)
assert(test_p2)

function mcl_util.set_properties(obj, props)
	local changed, p = props_changed(props, obj:get_properties())
	if changed then
		obj:set_properties(p)
	end
end

function mcl_util.set_bone_position(obj, bone, pos, rot, scale)
	local ov = obj:get_bone_override(bone)
	local current_pos = ov.position.vec
	local current_rot = vector.apply(ov.rotation.vec, math.deg)
	local pos_equal = not pos or vector.equals(vector.round(current_pos), vector.round(pos))
	local rot_equal = not rot or vector.equals(vector.round(current_rot), vector.round(rot))
	if not pos_equal or not rot_equal then
		obj:set_bone_override(bone, {
			position = pos and { vec = pos, absolute = true, interpolation = 0.1, } or nil,
			rotation = rot and { vec = vector.apply(rot, math.rad), absolute = true, interpolation = 0.1, } or nil,
			scale = scale and { vec = scale, absolute = true, interpolation = 0.1, } or nil,
		})
	end
end

function mcl_util.deal_damage(target, damage, mcl_reason)
	if not mcl_reason.flags then
		mcl_damage.finish_reason(mcl_reason)
	end
	local luaentity = target:get_luaentity()
	if luaentity then
		damage = mcl_damage.run_modifiers(target, damage, mcl_reason or {type = "generic"})
		if luaentity.deal_damage then
			if luaentity:deal_damage(damage, mcl_reason or {type = "generic"}) ~= true then
				mcl_damage.run_damage_callbacks(target, damage, mcl_reason or {type = "generic"})
			end
			return damage
		elseif luaentity.is_mob then
			if not luaentity:receive_damage (mcl_reason, damage) then
				damage = 0
				return damage
			end
			if luaentity.health > 0 then
				mcl_damage.run_damage_callbacks(target, damage, mcl_reason or {type = "generic"})
			else
				mcl_damage.run_death_callbacks(target, mcl_reason or {type = "generic"})
			end
			return damage
		else
			local puncher = mcl_reason and mcl_reason.direct or target
			if puncher and puncher.get_pos and puncher:get_pos() and target and target.get_pos and target:get_pos() and target.punch then
				target:punch(puncher, 1.0, {full_punch_interval = 1.0, damage_groups = {fleshy = damage}}, vector.direction(puncher:get_pos(), target:get_pos()), damage)
			end
		end
	else
		local hp = target:get_hp()
		local armorgroups = target:get_armor_groups()

		if hp > 0 and armorgroups and not armorgroups.immortal then
			if target:is_player () then
				mcl_damage.damage_player (target, damage, mcl_reason)
			else
				target:set_hp (hp - damage, {_mcl_reason = mcl_reason})
			end
		end
	end
	return damage
end

-- Convert a Euler rotation X, Y, Z, as accepted by obj:set_rotation,
-- into an equivalent in Irrlicht's intrinsic ZYX format, which is
-- required by bone rotations.  Values are three numbers representing
-- the Irrlicht equivalent of the stated rotation.

local NINETY_DEG = math.pi / 2
local mathcos = math.cos
local mathsin = math.sin
local mathatan2 = math.atan2
local mathasin = math.asin

function mcl_util.rotation_to_irrlicht (x, y, z)
	-- https://www.geometrictools.com/Documentation/EulerAngles.pdf
	local cx, sx = mathcos (x), mathsin (x)
	local cy, sy = mathcos (y), mathsin (y)
	local cz, sz = mathcos (z), mathsin (z)

	-- ZXY intrinsic to ZYX extrinsic.
	-- luacheck: push ignore 211
	local m00, m01, m02 = cy*cz - sx*sy*sz, -cx*sz, cz*sy + cy*sx*sz
	local m10, m11, m12 = cz*sx*sy + cy*sz, cx*cz, -cy*cz*sx + sx*sz
	local m20, m21, m22 = -cx*sy, sx, cx*cy
	-- luacheck: pop
	local tx, ty, tz

	if m20 < 1 then
		if m20 > -1 then
			ty = mathasin (m20)
			tz = mathatan2 (m10, m00)
			tx = mathatan2 (m21, m22)
		else
			ty = -NINETY_DEG
			tz = -mathatan2 (-m12, m11)
			tx = 0
		end
	else
		ty = NINETY_DEG
		tz = mathatan2 (-m12, m11)
		tx = 0
	end
	return tx, ty, tz
end
