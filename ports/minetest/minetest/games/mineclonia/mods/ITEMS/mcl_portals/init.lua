-- Load files

mcl_portals = {
	storage = core.get_mod_storage(),
}

------------------------------------------------------------------------
-- Utility functions.
------------------------------------------------------------------------

local function object_teleport_allowed_1 (obj)
	for _, object in ipairs (obj:get_children ()) do
		if object:is_player ()
			or not object_teleport_allowed_1 (object) then
			return false
		end
	end
	return true
end

function mcl_portals.object_teleport_allowed (obj)
	if obj:get_attach () or obj:get_hp () <= 0 then
		return false
	end
	local luaentity = obj:get_luaentity ()
	if luaentity and luaentity._forbid_portal_teleportation then
		return false
	end

	-- Do not permit objects to which players are directly or
	-- indirectly attached to be transported across dimensions.
	return object_teleport_allowed_1 (obj)
end

local modpath = core.get_modpath(core.get_current_modname())

dofile(modpath.."/portal_nether.lua")
dofile(modpath.."/portal_end.lua")
dofile(modpath.."/portal_gateway.lua")
