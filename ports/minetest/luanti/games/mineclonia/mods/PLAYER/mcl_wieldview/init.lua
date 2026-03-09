core.register_entity("mcl_wieldview:wieldview", {
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

local wieldview_luaentites = {
	Wield_Item = {},
	Arm_Left = {},
}

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
		if core.get_item_group(item, "shield") > 0 then
			luaentity.object:remove ()
			wieldview_luaentites[bone][player] = nil
			return
		end
		luaentity._item = item

		local def = get_item(player):get_definition()
		if def and def._mcl_wieldview_item then
			item = def._mcl_wieldview_item
		end

		local item_def = core.registered_items[item]
		luaentity.object:set_properties({
			glow = item_def and item_def.light_source or 0,
			wield_item = item,
			is_visible = item ~= ""
		})
	else
		-- If the player is running through an unloaded area,
		-- the wieldview entity will sometimes get unloaded.
		-- This code path is also used to initalize the wieldview.
		-- Creating entites from core.register_on_joinplayer
		-- is unreliable as of Minetest 5.6
		local obj_ref = core.add_entity(player:get_pos(), "mcl_wieldview:wieldview")
		if not obj_ref then return end
		obj_ref:set_attach(player, bone, position, rotation)
		obj_ref:set_armor_groups({ immortal = 1 })
		wieldview_luaentites[bone][player] = obj_ref:get_luaentity()
	end
end

core.register_on_leaveplayer(remove_wieldview)

mcl_player.register_globalstep(function(player)
	update_wieldview_entity(player, "Wield_Item", nil, nil, mcl_serverplayer.get_visual_wielditem)
	update_wieldview_entity(player, "Arm_Left", vector.new(0, 4.5, 2), vector.new(120, 0, 0), mcl_offhand.get_offhand)
end)
