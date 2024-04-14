minetest.register_entity("mcl_wieldview:wieldview", {
	initial_properties = {
		hp_max           = 1,
		visual           = "wielditem",
		physical         = false,
		is_visible       = false,
		pointable        = false,
		collide_with_objects = false,
		static_save = false,
		collisionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		selectionbox = {-0.21, -0.21, -0.21, 0.21, 0.21, 0.21},
		visual_size  = {x = 0.21, y = 0.21},
	}
})

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

local wieldview_luaentites = {
	Wield_Item = {},
	Arm_Left = {},
}

local offhand_huds = {}

local function offhand_hud(player, texture)
	return player:hud_add({
		[hud_elem_type_field] = "image",
		position = {x = 0.1, y = 0.90},
		scale = {x = 25, y = 25},
		z_index = -200,
		text = texture or "blank.png",
	})
end

local function update_offhand_hud(player, texture)
	local hud = offhand_huds[player]
	local stack = mcl_offhand.get_offhand(player)
	local empty = stack:is_empty()
	local shield = minetest.get_item_group(stack:get_name(), "shield") > 0 --shields implement their own hud

	if hud and ( empty or shield ) then
		player:hud_change(hud, "text", "blank.png")
		player:hud_remove(hud)
		offhand_huds[player] = nil
	elseif empty or shield then
		return
	elseif texture then
		if not hud then
			offhand_huds[player] = offhand_hud(player, texture)
		end
		player:hud_change(offhand_huds[player], "text", texture)
	end
end

local function remove_wieldview(player)
	for bone,_ in pairs(wieldview_luaentites) do
		if wieldview_luaentites[bone][player] then
			wieldview_luaentites[bone][player].object:remove()
		end
		wieldview_luaentites[bone][player] = nil
	end
end

local function update_wieldview_entity(player, bone, position, rotation, get_item)
	local luaentity = wieldview_luaentites[bone][player]

	if luaentity and luaentity.object:get_yaw() then
		local item = get_item(player):get_name()

		if item == luaentity._item then return end
		if minetest.get_item_group(item, "shield") > 0  then return end
		luaentity._item = item

		local def = get_item(player):get_definition()
		if def and def._mcl_wieldview_item then
			item = def._mcl_wieldview_item
		end

		local item_def = minetest.registered_items[item]
		if bone == "Arm_Left" then
			update_offhand_hud(player, item_def and item_def.wield_image or "")
		end
		luaentity.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	else
		-- If the player is running through an unloaded area,
		-- the wieldview entity will sometimes get unloaded.
		-- This code path is also used to initalize the wieldview.
		-- Creating entites from minetest.register_on_joinplayer
		-- is unreliable as of Minetest 5.6
		local obj_ref = minetest.add_entity(player:get_pos(), "mcl_wieldview:wieldview")
		if not obj_ref then return end
		obj_ref:set_attach(player, bone, position, rotation)
		obj_ref:set_armor_groups({ immortal = 1 })
		wieldview_luaentites[bone][player] = obj_ref:get_luaentity()
	end
end

minetest.register_on_leaveplayer(remove_wieldview)

minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	for i, player in pairs(players) do
		update_wieldview_entity(player, "Wield_Item", nil, nil, player.get_wielded_item)
		update_wieldview_entity(player, "Arm_Left", vector.new(0, 4.5, 2), vector.new(120, 0, 0), mcl_offhand.get_offhand)
	end
end)
