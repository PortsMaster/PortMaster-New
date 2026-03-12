playerphysics = {}

local function calculate_attribute_product(player, attribute)
	local a = core.deserialize(player:get_meta():get_string("playerphysics:physics"))
	local product = 1
	if a == nil or a[attribute] == nil then
		return product
	end
	local factors = a[attribute]
	if type(factors) == "table" then
		for _, factor in pairs(factors) do
			product = product * factor
		end
	end
	return product
end

function playerphysics.set_absolute_fov(player, fov)
	local meta = player:get_meta()
	local a = core.deserialize(meta:get_string("playerphysics:physics"))

	if fov == 0 then
		if a == nil then return end
		a.fov_absolute = nil

		local factor = calculate_attribute_product(player, "fov")
		player:set_fov(factor, true, 0.1)
	else
		if a == nil then
			a = { fov_absolute = fov }
		else
			if a.fov_absolute == fov then return end
			a.fov_absolute = fov
		end
	end

	meta:set_string("playerphysics:physics", core.serialize(a))

	player:set_fov(fov, false, 0.1)
end

function playerphysics.add_physics_factor(player, attribute, id, value)
	local meta = player:get_meta()
	local a = core.deserialize(meta:get_string("playerphysics:physics"))
	if a == nil then
		a = { [attribute] = { [id] = value } }
	elseif a[attribute] == nil then
		a[attribute] = { [id] = value }
	else
		a[attribute][id] = value
	end
	meta:set_string("playerphysics:physics", core.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	if attribute == "fov" then
		if player:is_player() and not a.fov_absolute then
			player:set_fov(raw_value, true, 0.1)
		end
	elseif not mcl_serverplayer.is_csm_capable (player) then
		player:set_physics_override({[attribute] = raw_value})
	end
end

function playerphysics.remove_physics_factor(player, attribute, id)
	local meta = player:get_meta()
	local a = core.deserialize(meta:get_string("playerphysics:physics"))
	if a == nil or a[attribute] == nil then
		-- Nothing to remove
		return
	else
		a[attribute][id] = nil
	end
	meta:set_string("playerphysics:physics", core.serialize(a))
	local raw_value = calculate_attribute_product(player, attribute)
	if attribute == "fov" then
		if player:is_player() and not a.fov_absolute then
			player:set_fov(raw_value, true, 0.1)
		end
	elseif not mcl_serverplayer.is_csm_capable (player) then
		player:set_physics_override({[attribute] = raw_value})
	end
end

function playerphysics.get_physics_factor(player, attribute, id)
	local meta = player:get_meta()
	local a = core.deserialize(meta:get_string("playerphysics:physics"))
	if a == nil then
		return nil
	elseif a[attribute] == nil then
		return nil
	else
		return a[attribute][id]
	end
end

dofile(core.get_modpath(core.get_current_modname()).."/elytra.lua")
