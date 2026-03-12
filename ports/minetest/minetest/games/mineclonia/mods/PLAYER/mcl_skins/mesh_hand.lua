local function make_texture(base, colorspec)
	local output = ""
	if mcl_skins.masks[base] then
		output = mcl_skins.masks[base] ..
			"^[colorize:" .. core.colorspec_to_colorstring(colorspec) .. ":alpha"
	end
	if #output > 0 then output = output .. "^" end
	output = output .. base
	return output
end

function mcl_skins.get_skin_list()
	local list = {}
	for _, game_mode in pairs({"_crea", "_surv"}) do
		for _, base in pairs(mcl_skins.base) do
			for _, base_color in pairs(mcl_skins.base_color) do
				local id = base:gsub(".png$", "") .. core.colorspec_to_colorstring(base_color):gsub("#", "")
				local female = {
					texture = make_texture(base, base_color),
					slim_arms = true,
					id = id .. "_female" .. game_mode,
					creative = game_mode == "_crea"
				}
				table.insert(list, female)

				local male = {
					texture = make_texture(base, base_color),
					slim_arms = false,
					id = id .. "_male" .. game_mode,
					creative = game_mode == "_crea"
				}
				table.insert(list, male)
			end
		end
		for _, skin in pairs(mcl_skins.simple_skins) do
			table.insert(list, {
				texture = skin.texture,
				slim_arms = skin.slim_arms,
				id = skin.texture:gsub(".png$", "") .. (skin.slim_arms and "_female" or "_male") .. game_mode,
				creative = game_mode == "_crea"
			})
		end
	end
	return list
end

function mcl_skins.get_node_id_by_player(player)
	local skin = mcl_skins.player_skins[player]
	local simple_skin = skin.simple_skins_id
	if simple_skin then
		skin = mcl_skins.texture_to_simple_skin[skin.simple_skins_id]
	end
	local creative = core.is_creative_enabled(player:get_player_name())
	local append = (skin.slim_arms and "_female" or "_male") .. (creative and "_crea" or "_surv")
	if simple_skin then
		return skin.texture:gsub(".png$", "") .. append
	else
		return skin.base:gsub(".png$", "") ..
			core.colorspec_to_colorstring(skin.base_color):gsub("#", "") .. append
	end
end
