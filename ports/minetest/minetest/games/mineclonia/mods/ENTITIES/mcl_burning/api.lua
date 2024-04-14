local enable_damage = minetest.settings:get_bool("enable_damage")

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

function mcl_burning.get_storage(obj)
	return obj:is_player() and mcl_burning.storage[obj] or obj:get_luaentity()
end

function mcl_burning.is_burning(obj)
	local storage = mcl_burning.get_storage(obj)
	if storage then
		return mcl_burning.get_storage(obj).burn_time
	else
		return false
	end
end

function mcl_burning.is_affected_by_rain(obj)
	return mcl_weather.get_weather() == "rain" and mcl_weather.is_outdoor(obj:get_pos())
end

function mcl_burning.get_collisionbox(obj, smaller, storage)
	local cache = storage.collisionbox_cache
	if cache then
		local box = cache[smaller and 2 or 1]
		return box[1], box[2]
	else
		local box = obj:get_properties().collisionbox
		local minp, maxp = vector.new(box[1], box[2], box[3]), vector.new(box[4], box[5], box[6])
		local s_vec = vector.new(0.1, 0.1, 0.1)
		local s_minp = vector.add(minp, s_vec)
		local s_maxp = vector.subtract(maxp, s_vec)
		storage.collisionbox_cache = {{minp, maxp}, {s_minp, s_maxp}}
		return minp, maxp
	end
end

function mcl_burning.get_touching_nodes(obj, nodenames, storage)
	local pos = obj:get_pos()
	local minp, maxp = mcl_burning.get_collisionbox(obj, true, storage)
	local nodes = minetest.find_nodes_in_area(vector.add(pos, minp), vector.add(pos, maxp), nodenames)
	return nodes
end

-- Manages the fire animation on a burning player's HUD
--
-- Parameters:
--   player - a valid player object;
--
-- If the player already has a fire HUD, updates the burning animation.
-- If the fire does not have a fire HUD, initializes the HUD.
--
function mcl_burning.update_hud(player)
	local animation_frames = tonumber(minetest.settings:get("fire_animation_frames")) or 8
	local hud_flame_animated = "mcl_burning_hud_flame_animated.png^[opacity:180^[verticalframe:" .. animation_frames .. ":"

	local storage = mcl_burning.get_storage(player)
	if not storage.fire_hud_id then
		storage.animation_frame = 1
		storage.fire_hud_id = player:hud_add({
			[hud_elem_type_field] = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -100, y = -100},
			text = hud_flame_animated .. storage.animation_frame,
			z_index = 1000,
		})
	else
		storage.animation_frame = storage.animation_frame + 1
		if storage.animation_frame > animation_frames - 1 then
			storage.animation_frame = 0
		end
		player:hud_change(storage.fire_hud_id, "text", hud_flame_animated .. storage.animation_frame)
	end
end

-- Sets and object state as burning and adds a fire animation to the object.
--
-- Parameters:
--   obj - may be a player or a lua_entity;
--   burn_time - sets the object's burn duration;
--
-- If obj is a player, adds a fire animation to the HUD, if obj is a
-- lua_entity, adds an animated fire entity to obj.
-- The effective burn duration is modified by obj's armor protection.
-- If obj was already burning, its burn duration is updated if the current
-- duration is less than burn_time.
-- If obj is dead, fireproof or enable_damage is disabled, this function does nothing.
--
function mcl_burning.set_on_fire(obj, burn_time)
	if obj:get_hp() < 0 then
		return
	end

	local luaentity = obj:get_luaentity()
	if luaentity and luaentity.fire_resistant then
		return
	end

	if obj:is_player() and not enable_damage then
		return
	else
		local max_fire_prot_lvl = 0
		local inv = mcl_util.get_inventory(obj)
		local armor_list = inv and inv:get_list("armor")

		if armor_list then
			for _, stack in pairs(armor_list) do
				local fire_prot_lvl = mcl_enchanting.get_enchantment(stack, "fire_protection")
				if fire_prot_lvl > max_fire_prot_lvl then
					max_fire_prot_lvl = fire_prot_lvl
				end
			end
		end
		if max_fire_prot_lvl > 0 then
			burn_time = burn_time - math.floor(burn_time * max_fire_prot_lvl * 0.15)
		end
	end

	local storage = mcl_burning.get_storage(obj)
	if storage.burn_time then
		if burn_time > storage.burn_time then
			storage.burn_time = burn_time
		end
		return
	end
	storage.burn_time = burn_time
	storage.fire_damage_timer = 0

	local minp, maxp = mcl_burning.get_collisionbox(obj, false, storage)
	local size = vector.subtract(maxp, minp)
	size = vector.multiply(size, vector.new(1.1, 1.2, 1.1))
	size = vector.divide(size, obj:get_properties().visual_size)

	local fire_entity = minetest.add_entity(obj:get_pos(), "mcl_burning:fire")
	if fire_entity and fire_entity:get_pos() then
		fire_entity:set_properties({visual_size = size})
		fire_entity:set_attach(obj, "", vector.new(0, size.y * 5, 0), vector.new(0, 0, 0))
	end

	if obj:is_player() then
		mcl_burning.update_hud(obj)
	end
end

function mcl_burning.extinguish(obj)
	if not obj:get_pos() then return end
	if mcl_burning.is_burning(obj) then
		local storage = mcl_burning.get_storage(obj)
		if obj:is_player() then
			if storage.fire_hud_id then
				obj:hud_remove(storage.fire_hud_id)
			end
			mcl_burning.storage[obj] = {}
		else
			storage.burn_time = nil
			storage.fire_damage_timer = nil
		end
	end
end

function mcl_burning.tick(obj, dtime, storage)
	if storage.burn_time then
		storage.burn_time = storage.burn_time - dtime

		if storage.burn_time <= 0 or mcl_burning.is_affected_by_rain(obj) or #mcl_burning.get_touching_nodes(obj, "group:puts_out_fire", storage) > 0 then
			mcl_burning.extinguish(obj)
			return true
		else
			storage.fire_damage_timer = storage.fire_damage_timer + dtime

			if storage.fire_damage_timer >= 1 then
				storage.fire_damage_timer = 0

				local luaentity = obj:get_luaentity()

				if not luaentity or not luaentity.fire_damage_resistant then
					mcl_util.deal_damage(obj, 1, {type = "on_fire"})
				end
			end
		end
	end
end
