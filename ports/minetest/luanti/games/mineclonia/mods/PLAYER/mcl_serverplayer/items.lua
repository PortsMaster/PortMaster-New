------------------------------------------------------------------------
-- Bows and other usable items.
------------------------------------------------------------------------

local glint = mcl_enchanting.overlay

local is_bow = {
	["mcl_bows:bow"] = {
		charge_time_half = mcl_bows.BOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.BOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_bow_0.png",
		texture_0_wielditem = "mcl_bows:bow_0",
		texture_1 = "mcl_bows_bow_1.png",
		texture_1_wielditem = "mcl_bows:bow_1",
		texture_2 = "mcl_bows_bow_2.png",
		texture_2_wielditem = "mcl_bows:bow_2",
	},
	["mcl_bows:bow_enchanted"] = {
		charge_time_half = mcl_bows.BOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.BOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_bow_0.png" .. glint,
		texture_0_wielditem = "mcl_bows:bow_0_enchanted",
		texture_1 = "mcl_bows_bow_1.png" .. glint,
		texture_1_wielditem = "mcl_bows:bow_1_enchanted",
		texture_2 = "mcl_bows_bow_2.png" .. glint,
		texture_2_wielditem = "mcl_bows:bow_2_enchanted",
	},
	["mcl_bows:crossbow"] = {
		charge_time_half = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_crossbow_0.png",
		texture_0_wielditem = "mcl_bows:crossbow_0",
		texture_1 = "mcl_bows_crossbow_1.png",
		texture_1_wielditem = "mcl_bows:crossbow_1",
		texture_2 = "mcl_bows_crossbow_2.png",
		texture_2_wielditem = "mcl_bows:crossbow_2",
		texture_loaded = "mcl_bows_crossbow_3.png",
		texture_loaded_wielditem = "mcl_bows:crossbow_loaded",
	},
	["mcl_bows:crossbow_enchanted"] = {
		charge_time_half = mcl_bows.CROSSBOW_CHARGE_TIME_HALF,
		charge_time_full = mcl_bows.CROSSBOW_CHARGE_TIME_FULL,
		texture_0 = "mcl_bows_crossbow_0.png" .. glint,
		texture_0_wielditem = "mcl_bows:crossbow_0_enchanted",
		texture_1 = "mcl_bows_crossbow_1.png" .. glint,
		texture_1_wielditem = "mcl_bows:crossbow_1_enchanted",
		texture_2 = "mcl_bows_crossbow_2.png" .. glint,
		texture_2_wielditem = "mcl_bows:crossbow_2_enchanted",
		texture_loaded = "mcl_bows_crossbow_3.png" .. glint,
		texture_3_wielditem = "mcl_bows:crossbow_loaded_enchanted",
	},
	is_crossbow = {
		["mcl_bows:crossbow_loaded"] = true,
		["mcl_bows:crossbow_loaded_enchanted"] = true,
	},
}
mcl_serverplayer.bow_info = is_bow

function mcl_serverplayer.update_ammo (state, player, always)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()

	if not is_bow[name] then
		if state.ammo ~= 0 or always then
			local challenge = state.ammo_challenge
			state.ammo = 0
			mcl_serverplayer.send_ammoctrl (player, 0, challenge)
		end
		return
	end

	local ammo = core.get_item_group (name, "crossbow") > 0
		and mcl_bows.get_arrow_stack_for_crossbow (player)
		or mcl_bows.get_arrow_stack_for_bow (player)
	local count = ammo and ammo:get_count () or 0
	if state.ammo ~= count or always then
		local challenge = state.ammo_challenge
		state.ammo = count
		mcl_serverplayer.send_ammoctrl (player, count, challenge)
	end

	local enchantments = mcl_enchanting.get_enchantments (wielditem)
	local infinity = enchantments.infinity and enchantments.infinity > 0
	local quick_charge = enchantments.quick_charge or 0

	-- ???
	if not infinity then
		infinity = false
	end

	if infinity ~= state.bow_cap_infinity
		or quick_charge ~= state.bow_cap_quick_charge then
		local time = mcl_bows.crossbow_charge_time_multiplier (quick_charge)
		state.bow_cap_infinity = infinity
		state.bow_cap_quick_charge = quick_charge
		mcl_serverplayer.send_bow_capabilities (player, {
			challenge = state.ammo_challenge,
			infinity = infinity,
			charge_time = time,
		})
	end
end

function mcl_serverplayer.release_useitem (state, player, usetime, challenge)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()

	if core.get_item_group (name, "bow") > 0 then
		mcl_bows.player_shoot (player, wielditem, usetime * 1.0e+6)
	elseif core.get_item_group (name, "crossbow") > 0 then
		mcl_bows.load_crossbow (player, wielditem, usetime * 1.0e+6)
	end

	state.ammo_challenge = challenge
	mcl_serverplayer.update_ammo (state, player, true)
end

------------------------------------------------------------------------
-- Tridents.
------------------------------------------------------------------------

mcl_serverplayer.trident_info = {
	["mcl_tridents:trident"] = {
		is_trident = true,
	},
	["mcl_tridents:trident_enchanted"] = {
		is_trident = true,
	},
}

function mcl_serverplayer.release_trident_item (player, state)
	local wielditem = player:get_wielded_item ()
	local name = wielditem:get_name ()

	if core.get_item_group (name, "trident") > 0
		and mcl_tridents.remaining_durability (wielditem) > 1 then
		mcl_tridents.player_shoot (player, wielditem)
	end
end

------------------------------------------------------------------------
-- Offhand management.
------------------------------------------------------------------------

core.register_on_player_inventory_action (function (player, action, inv, inventory_info)
	if mcl_serverplayer.is_csm_at_least (player, 1) then
		if (action == "move"
			and (inventory_info.from_list == "offhand"
			     or inventory_info.to_list == "offhand"))
			or inventory_info.listname == "offhand" then
			local stack = inv:get_stack ("offhand", 1)
			mcl_serverplayer.send_offhand_item (player, stack)
		end
	end
end)

------------------------------------------------------------------------
-- Client-side item placement.
------------------------------------------------------------------------


-- This is a list defining how items should be placed when something
-- is being pointed at.

core.register_on_mods_loaded (function ()

local handshake_item_defs = mcl_serverplayer.handshake_item_defs

for name, item in pairs (core.registered_items) do
	-- The following placement classes exist:
	--   food
	--   food_edible_whilst_full
	--   shield
	--   bow
	--
	-- When proto >= 4, the following placement class(es) also
	-- exist:
	--   trident

	if item._placement_def then
		handshake_item_defs[name] = item._placement_def
	elseif item._placement_class then
		local class = item._placement_class

		if class == "shield" then
			handshake_item_defs[name] = "shields"
		end
	elseif core.get_item_group(name, "can_eat_when_full") > 0
		and core.get_item_group(name, "food") > 0 then
		handshake_item_defs[name] = "magic_victuals"
	elseif core.get_item_group(name, "eatable") > 0 and core.get_item_group(name, "food") > 0 then
		if item._mcl_places_plant then
			handshake_item_defs[name] = "farmable_victuals"
		else
			handshake_item_defs[name] = "victuals"
		end
	elseif core.get_item_group(name, "crossbow") > 0 then
		handshake_item_defs[name] = "bows"
	elseif core.get_item_group(name, "bow") > 0 then
		handshake_item_defs[name] = "bows"
	elseif item.on_place and core.registered_nodes[name] then
		-- Probably a node.  Default to being used on nodes.
		handshake_item_defs[name] = "node_defaults"
	elseif rawget (item, "on_secondary_use") then
		handshake_item_defs[name] = "placeable_item"
	elseif item.on_place then
		handshake_item_defs[name] = "placeable_on_any_thing"
	end
end

-- The hand.
local hand = {
	default = "undefined",
}

-- Assign "default" to entities and nodes with
-- right click menus/actions.

for node, def in pairs (core.registered_nodes) do
	if def.on_rightclick
		or def._configures_formspec
		or core.get_item_group(node, "container") > 0 then
		hand[node] = "default"
	end
end

for entity, def in pairs (core.registered_entities) do
	if def.on_rightclick and not def._unplaceable_by_default then
		hand[entity] = "default"
	end
end
handshake_item_defs["default"] = hand
handshake_item_defs[""] = nil -- Remove this hand.

-- Nodes.

local node_defaults = {
}

for node, _ in pairs (core.registered_nodes) do
	node_defaults[node] = "default"
end

for entity, def in pairs (core.registered_entities) do
	if def.on_rightclick and not def._unplaceable_by_default then
		node_defaults[entity] = "default"
	end
end
handshake_item_defs["node_defaults"] = node_defaults

-- Placeable items.
handshake_item_defs["placeable_item"] = {
	default = "default",
}

handshake_item_defs["placeable_on_any_thing"] = {
	inherit = "node_defaults",
}

local placeable_on_any_thing = handshake_item_defs["placeable_on_any_thing"]

-- Add all entities.
for entity, def in pairs (core.registered_entities) do
	placeable_on_any_thing[entity] = "default"
end

local placeable_on_actionable = {
}

-- Assign "default" to entities and nodes with
-- right click menus.
for node, def in pairs (core.registered_nodes) do
	if def.on_rightclick
		or def._configures_formspec
		or core.get_item_group(node, "container") > 0 then
		placeable_on_actionable[node] = "default"
	end
end

for entity, def in pairs (core.registered_entities) do
	if def.on_rightclick and not def._unplaceable_by_default then
		placeable_on_actionable[entity] = "default"
	end
end

handshake_item_defs["placeable_on_actionable"] = placeable_on_actionable

-- Shields.
local shields = {
	default = "shield",
	inherit = "placeable_on_actionable",
}

handshake_item_defs["shields"] = shields

-- Foods.
local foods = {
	default = "food",
	inherit = "placeable_on_actionable",
}

handshake_item_defs["victuals"] = foods

-- Magic foods.
local magic_foods = {
	default = "food_edible_whilst_full",
	inherit = "placeable_on_actionable",
}

handshake_item_defs["magic_victuals"] = magic_foods

-- Foods placeable on farmland.
local magic_foods = {
	inherit = "victuals",
	["mcl_farming:soil"] = "default",
	["mcl_farming:soil_wet"] = "default",
}

handshake_item_defs["farmable_victuals"] = magic_foods

-- Bows.
local bows = {
	default = "bow",
	inherit = "placeable_on_actionable",
}

handshake_item_defs["bows"] = bows

local handshake_item_defs_v4 = mcl_serverplayer.handshake_item_defs_v4

-- Tridents.
local tridents = {
	default = "trident",
	inherit = "placeable_on_actionable",
}
handshake_item_defs_v4["tridents"] = tridents
handshake_item_defs_v4["mcl_tridents:trident"] = "tridents"
handshake_item_defs_v4["mcl_tridents:trident_enchanted"] = "tridents"

end)
