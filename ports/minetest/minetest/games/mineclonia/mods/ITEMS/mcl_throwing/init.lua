mcl_throwing = {}

local modpath = minetest.get_modpath(minetest.get_current_modname())

--
-- Snowballs and other throwable items
--

local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))

local entity_mapping = {}
local velocities = {}

function mcl_throwing.register_throwable_object(name, entity, velocity)
	entity_mapping[name] = entity
	velocities[name] = velocity
end

function mcl_throwing.throw(throw_item, pos, dir, velocity, thrower)
	if velocity == nil then
		velocity = velocities[throw_item]
	end
	if velocity == nil then
		velocity = 22
	end
	minetest.sound_play("mcl_throwing_throw", {pos=pos, gain=0.4, max_hear_distance=16}, true)

	local itemstring = ItemStack(throw_item):get_name()
	local obj = minetest.add_entity(pos, entity_mapping[itemstring])
	if not obj or not obj:get_pos() then return end
	obj:set_velocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
	obj:set_acceleration({x=dir.x*-3, y=-GRAVITY, z=dir.z*-3})
	if thrower then
		obj:get_luaentity()._thrower = thrower
	end
	return obj
end

-- Throw item
function mcl_throwing.get_player_throw_function(entity_name, velocity)
	local function func(item, player, pointed_thing)
		local playerpos = player:get_pos()
		local dir = player:get_look_dir()
		mcl_throwing.throw(item, {x=playerpos.x, y=playerpos.y+1.5, z=playerpos.z}, dir, velocity, player:get_player_name())
		if not minetest.is_creative_enabled(player:get_player_name()) then
			item:take_item()
		end
		return item
	end
	return func
end

function mcl_throwing.dispense_function(stack, dispenserpos, droppos, dropnode, dropdir)
	-- Launch throwable item
	local shootpos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
	mcl_throwing.throw(stack:get_name(), shootpos, dropdir)
end

-- Staticdata handling because objects may want to be reloaded
function mcl_throwing.get_staticdata(self)
	local thrower
	-- Only save thrower if it's a player name
	if type(self._thrower) == "string" then
		thrower = self._thrower
	end
	local data = {
		_lastpos = self._lastpos,
		_thrower = thrower,
	}
	return minetest.serialize(data)
end

function mcl_throwing.on_activate(self, staticdata, dtime_s)
	local data = minetest.deserialize(staticdata)
	if data then
		self._lastpos = data._lastpos
		self._thrower = data._thrower
	end
end

dofile(modpath.."/register.lua")