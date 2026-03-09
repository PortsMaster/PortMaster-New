--TODO: Add sounds for the respawn anchor (charge sounds etc.)

--Nether ends at y -29077
--Nether roof at y -28933
local S = core.get_translator(core.get_current_modname())

local light_level = {3, 7, 11, core.LIGHT_MAX}

local function rightclick(pos, node, clicker, itemstack)
	local charge_level = core.get_item_group(node.name, "charge_level")
	local player_name = clicker:get_player_name()
	if core.is_protected(pos, player_name) then
		core.record_protection_violation(pos, player_name)
		return itemstack
	end
	if itemstack:get_name() == "mcl_nether:glowstone" and charge_level ~= 4 then
		mcl_redstone.swap_node(pos, {name="mcl_beds:respawn_anchor_charged_"..charge_level+1})
		if not core.is_creative_enabled(player_name) then
			itemstack:take_item()
		end
	elseif mcl_worlds.pos_to_dimension(pos) ~= "nether" then
		if node.name ~= "mcl_beds:respawn_anchor" then --only charged respawn anchors are exploding in the overworld & end in minecraft
			core.remove_node(pos)
			mcl_explosions.explode(pos, 5, {fire = true})
		end
	elseif string.match(node.name, "mcl_beds:respawn_anchor_charged_") then
		core.chat_send_player(player_name, S("New respawn position set!"))
		mcl_spawn.set_spawn_pos(clicker, pos, nil)
		if charge_level == 4 then
			awards.unlock(player_name, "mcl:notQuiteNineLives")
		end
	end
	-- returning the old itemstack here would result in it still being in hand *after* death
	return mcl_util.return_itemstack_if_alive(clicker, itemstack)
end

local tpl_anchor = {
	description = S("Respawn Anchor"),
	is_ground_content = false,
	_mcl_blast_resistance = 1200,
	_mcl_hardness = 50,
	_mcl_baseitem = "mcl_beds:respawn_anchor",
	sounds = mcl_sounds.node_sound_stone_defaults(),
	on_rightclick = rightclick
}

core.register_node("mcl_beds:respawn_anchor", table.merge(tpl_anchor, {
	_doc_items_longdesc = S("The respawn anchor is a block that allows the player to set their spawn point in the Nether. It will only work if fueled using glowstone blocks."),
	_doc_items_usagehelp = S("Use a glowstone block to add a charge.") .. " " ..
		S("Respawn anchors can be charged up to four times. Rightclick on a charged anchor to set a new spawn point.") .. " " ..
		S("A respawn anchor only works in the Nether. Attempting to use a charged anchor to set a new spawn point outside the Nether will cause it to explode."),
	tiles = {
		"respawn_anchor_top_off.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side0.png"
	},
	groups = {
		pickaxey = 5, material_stone = 1, deco_block = 1, respawn_anchor = 1, comparator_signal = 0
	}
}))

for i = 1, 4 do
	core.register_node("mcl_beds:respawn_anchor_charged_"..i, table.merge(tpl_anchor, {
		tiles = {
			{
				name = "respawn_anchor_top_on.png",
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 2.0}
			},
			"respawn_anchor_bottom.png",
			"respawn_anchor_side"..i ..".png"
		},
		groups = {
			pickaxey = 5, material_stone = 1, not_in_creative_inventory = 1,
			respawn_anchor = i + 1, comparator_signal = 4 * i - 1, charge_level = i
		},
		drop = {
			items = {
				{items = {"mcl_beds:respawn_anchor"}},
			}
		},
		light_source = light_level[i],
	}))
end

core.register_craft({
	output = "mcl_beds:respawn_anchor",
	recipe = {
		{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"},
		{"mcl_nether:glowstone", "mcl_nether:glowstone", "mcl_nether:glowstone"},
		{"mcl_core:crying_obsidian", "mcl_core:crying_obsidian", "mcl_core:crying_obsidian"}
	}
})
