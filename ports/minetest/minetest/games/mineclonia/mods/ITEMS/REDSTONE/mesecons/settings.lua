-- SETTINGS
function mesecon.setting(setting, default)
	if type(default) == "boolean" then
		local read = minetest.settings:get_bool("mesecon."..setting)
		if read == nil then
			return default
		else
			return read
		end
	elseif type(default) == "string" then
		return minetest.settings:get("mesecon."..setting) or default
	elseif type(default) == "number" then
		return tonumber(minetest.settings:get("mesecon."..setting) or default)
	end
end
