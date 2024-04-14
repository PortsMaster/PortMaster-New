local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

minetest.register_tool("mcl_spyglass:spyglass",{
	description = S("Spyglass"),
	_doc_items_longdesc = S("A spyglass is an item that can be used for zooming in on specific locations."),
	inventory_image = "mcl_spyglass.png",
	stack_max = 1,
	_mcl_toollike_wield = true,
})

minetest.register_craft({
	output = "mcl_spyglass:spyglass",
	recipe = {
		{"mcl_amethyst:amethyst_shard"},
		{"mcl_copper:copper_ingot"},
		{"mcl_copper:copper_ingot"},
	}
})

local spyglass_scope = {}

local function add_scope(player)
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "mcl_spyglass:spyglass" then
		spyglass_scope[player] = player:hud_add({
			[hud_elem_type_field] = "image",
			position = {x = 0.5, y = 0.5},
			scale = {x = -100, y = -100},
			text = "mcl_spyglass_scope.png",
		})
		player:hud_set_flags({wielditem = false})
	end
end

local function remove_scope(player)
	if spyglass_scope[player] then
		player:hud_remove(spyglass_scope[player])
		spyglass_scope[player] = nil
		player:hud_set_flags({wielditem = true})
		player:set_fov(86.1)
	end
end

controls.register_on_press(function(player, key)
	if key ~= "RMB" and key ~= "zoom" then return end
	if spyglass_scope[player] == nil then
		add_scope(player)
	end
end)

controls.register_on_release(function(player, key, time)
	if key ~= "RMB" and key ~= "zoom" then return end
	local ctrl = player:get_player_control()
	if key == "RMB" and ctrl.zoom or key == "zoom" and ctrl.place then return end
	remove_scope(player)
end)

controls.register_on_hold(function(player, key, time)
	if key ~= "RMB" and key ~= "zoom" then return end
	local wielditem = player:get_wielded_item()
	if wielditem:get_name() == "mcl_spyglass:spyglass" then
		player:set_fov(8, false, 0.1)
		if spyglass_scope[player] == nil then
			add_scope(player)
		end
	else
		remove_scope(player)
	end
end)

minetest.register_on_dieplayer(function(player)
	remove_scope(player)
end)

minetest.register_on_leaveplayer(function(player)
	spyglass_scope[player] = nil
end)
