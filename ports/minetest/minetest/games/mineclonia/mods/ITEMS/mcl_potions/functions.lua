local EF = {}
EF.invisible = {}
EF.poisoned = {}
EF.regenerating = {}
EF.strong = {}
EF.weak = {}
EF.water_breathing = {}
EF.leaping = {}
EF.swift = {} -- for swiftness AND slowness
EF.night_vision = {}
EF.fire_proof = {}
EF.bad_omen = {}
EF.withering = {}

local EFFECT_TYPES = 0
for _,_ in pairs(EF) do
	EFFECT_TYPES = EFFECT_TYPES + 1
end

-- TODO: when < minetest 5.9 isn't supported anymore, remove this variable check and replace all occurences of [hud_elem_type_field] with type
local hud_elem_type_field = "type"
if not minetest.features.hud_def_type_field then
	hud_elem_type_field = "hud_elem_type"
end

local icon_ids = {}

local function potions_set_hudbar(player)
	if EF.withering[player] and EF.regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "mcl_potions_icon_regen_wither.png", nil, "hudbars_bar_health.png")
	elseif EF.withering[player] then
		hb.change_hudbar(player, "health", nil, nil, "mcl_potions_icon_wither.png", nil, "hudbars_bar_health.png")
	elseif EF.poisoned[player] and EF.regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_regen_poison.png", nil, "hudbars_bar_health.png")
	elseif EF.poisoned[player] then
		hb.change_hudbar(player, "health", nil, nil, "hbhunger_icon_health_poison.png", nil, "hudbars_bar_health.png")
	elseif EF.regenerating[player] then
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_regenerate.png", nil, "hudbars_bar_health.png")
	else
		hb.change_hudbar(player, "health", nil, nil, "hudbars_icon_health.png", nil, "hudbars_bar_health.png")
	end

end

local function potions_init_icons(player)
	local name = player:get_player_name()
	icon_ids[name] = {}
	for e=1, EFFECT_TYPES do
		local x = -52 * e - 2
		local id = player:hud_add({
			[hud_elem_type_field] = "image",
			text = "blank.png",
			position = { x = 1, y = 0 },
			offset = { x = x, y = 3 },
			scale = { x = 0.375, y = 0.375 },
			alignment = { x = 1, y = 1 },
			z_index = 100,
		})
		table.insert(icon_ids[name], id)
	end
end

local function potions_set_icons(player)
	local name = player:get_player_name()
	if not icon_ids[name] then
		return
	end
	local active_effects = {}
	for effect_name, effect in pairs(EF) do
		if effect[player] then
			table.insert(active_effects, effect_name)
		end
	end

	for i=1, EFFECT_TYPES do
		local icon = icon_ids[name][i]
		local effect_name = active_effects[i]
		if effect_name == "swift" and EF.swift[player].is_slow then
			effect_name = "slow"
		end
		if effect_name == nil then
			player:hud_change(icon, "text", "blank.png")
		else
			player:hud_change(icon, "text", "mcl_potions_effect_"..effect_name..".png^[resize:128x128")
		end
	end

end

local function potions_set_hud(player)

	potions_set_hudbar(player)
	potions_set_icons(player)

end


-- ███╗░░░███╗░█████╗░██╗███╗░░██╗  ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ████╗░████║██╔══██╗██║████╗░██║  ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- ██╔████╔██║███████║██║██╔██╗██║  █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██║╚██╔╝██║██╔══██║██║██║╚████║  ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ██║░╚═╝░██║██║░░██║██║██║░╚███║  ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚═╝░░░░░╚═╝╚═╝░░╚═╝╚═╝╚═╝░░╚══╝  ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ░█████╗░██╗░░██╗███████╗░█████╗░██╗░░██╗███████╗██████╗░
-- ██╔══██╗██║░░██║██╔════╝██╔══██╗██║░██╔╝██╔════╝██╔══██╗
-- ██║░░╚═╝███████║█████╗░░██║░░╚═╝█████═╝░█████╗░░██████╔╝
-- ██║░░██╗██╔══██║██╔══╝░░██║░░██╗██╔═██╗░██╔══╝░░██╔══██╗
-- ╚█████╔╝██║░░██║███████╗╚█████╔╝██║░╚██╗███████╗██║░░██║
-- ░╚════╝░╚═╝░░╚═╝╚══════╝░╚════╝░╚═╝░░╚═╝╚══════╝╚═╝░░╚═╝

local is_player, entity, meta

minetest.register_globalstep(function(dtime)

	-- Check for invisible players
	for player, vals in pairs(EF.invisible) do

		EF.invisible[player].timer = EF.invisible[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#7F8392") end

		if EF.invisible[player].timer >= EF.invisible[player].dur then
			mcl_potions.make_invisible(player, false)
			EF.invisible[player] = nil
			if player:is_player() then
				meta = player:get_meta()
				meta:set_string("_is_invisible", minetest.serialize(EF.invisible[player]))
			end
			potions_set_hud(player)

		end

	end

	-- Check for withering players
	for player, vals in pairs(EF.withering) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.withering[player].timer = EF.withering[player].timer + dtime
		EF.withering[player].hit_timer = (EF.withering[player].hit_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#000000") end

		if EF.withering[player].hit_timer >= EF.withering[player].step then
			if is_player or entity then mcl_util.deal_damage(player, 1, {type = "magic"}) end
			if EF.withering[player] then EF.withering[player].hit_timer = 0 end
		end

		if EF.withering[player] and EF.withering[player].timer >= EF.withering[player].dur then
			EF.withering[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_withering", minetest.serialize(EF.withering[player]))
				potions_set_hud(player)
			end
		end

	end

	-- Check for poisoned players
	for player, vals in pairs(EF.poisoned) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.poisoned[player].timer = EF.poisoned[player].timer + dtime
		EF.poisoned[player].hit_timer = (EF.poisoned[player].hit_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#4E9331") end

		if EF.poisoned[player].hit_timer >= EF.poisoned[player].step then
			if mcl_util.get_hp(player) - 1 > 0 then
				mcl_util.deal_damage(player, 1, {type = "magic"})
			end
			EF.poisoned[player].hit_timer = 0
		end

		if EF.poisoned[player] and EF.poisoned[player].timer >= EF.poisoned[player].dur then
			EF.poisoned[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_poisoned", minetest.serialize(EF.poisoned[player]))
				potions_set_hud(player)
			end
		end

	end

	-- Check for regenerating players
	for player, vals in pairs(EF.regenerating) do

		is_player = player:is_player()
		entity = player:get_luaentity()

		EF.regenerating[player].timer = EF.regenerating[player].timer + dtime
		EF.regenerating[player].heal_timer = (EF.regenerating[player].heal_timer or 0) + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#CD5CAB") end

		if EF.regenerating[player].heal_timer >= EF.regenerating[player].step then

			if is_player then
				player:set_hp(math.min(player:get_properties().hp_max or 20, player:get_hp() + 1), { type = "set_hp", other = "regeneration" })
				EF.regenerating[player].heal_timer = 0
			elseif entity and entity.is_mob then
				entity.health = math.min(entity.object:get_properties().hp_max, entity.health + 1)
				EF.regenerating[player].heal_timer = 0
			else -- stop regenerating if not a player or mob
				EF.regenerating[player] = nil
			end

		end

		if EF.regenerating[player] and EF.regenerating[player].timer >= EF.regenerating[player].dur then
			EF.regenerating[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_is_regenerating", minetest.serialize(EF.regenerating[player]))
				potions_set_hud(player)
			end
		end

	end

	-- Check for water breathing players
	for player, vals in pairs(EF.water_breathing) do

		if player:is_player() then

			EF.water_breathing[player].timer = EF.water_breathing[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#2E5299") end

			if player:get_breath() then
				hb.hide_hudbar(player, "breath")
				if player:get_breath() < 10 then player:set_breath(10) end
			end

			if EF.water_breathing[player].timer >= EF.water_breathing[player].dur then
				meta = player:get_meta()
				meta:set_string("_is_water_breathing", minetest.serialize(EF.water_breathing[player]))
				EF.water_breathing[player] = nil
			end
			potions_set_hud(player)

		else
			EF.water_breathing[player] = nil
		end

	end

	-- Check for leaping players
	for player, vals in pairs(EF.leaping) do

		if player:is_player() then

			EF.leaping[player].timer = EF.leaping[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#22FF4C") end

			if EF.leaping[player].timer >= EF.leaping[player].dur then
				playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")
				EF.leaping[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_leaping", minetest.serialize(EF.leaping[player]))
			end
			potions_set_hud(player)

		else
			EF.leaping[player] = nil
		end

	end

	-- Check for swift players
	for player, vals in pairs(EF.swift) do

		if player:is_player() then

			EF.swift[player].timer = EF.swift[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#7CAFC6") end

			if EF.swift[player].timer >= EF.swift[player].dur then
				playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")
				EF.swift[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_swift", minetest.serialize(EF.swift[player]))
			end
			potions_set_hud(player)

		else
			EF.swift[player] = nil
		end

	end

	-- Check for Night Vision equipped players
	for player, vals in pairs(EF.night_vision) do

		if player:is_player() then

			EF.night_vision[player].timer = EF.night_vision[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#1F1FA1") end

			if EF.night_vision[player].timer >= EF.night_vision[player].dur then
				EF.night_vision[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_cat", minetest.serialize(EF.night_vision[player]))
				meta:set_int("night_vision", 0)
			end
			mcl_weather.skycolor.update_sky_color({player})
			potions_set_hud(player)

		else
			EF.night_vision[player] = nil
		end

	end

	-- Check for Fire Proof players
	for player, vals in pairs(EF.fire_proof) do

		if player:is_player() then

			player = player or player:get_luaentity()

			EF.fire_proof[player].timer = EF.fire_proof[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#E49A3A") end

			if EF.fire_proof[player].timer >= EF.fire_proof[player].dur then
				EF.fire_proof[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_fire_proof", minetest.serialize(EF.fire_proof[player]))
			end
			potions_set_hud(player)

		else
			EF.fire_proof[player] = nil
		end

	end

	-- Check for Weak players
	for player, vals in pairs(EF.weak) do

		if player:is_player() then

			EF.weak[player].timer = EF.weak[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#484D48") end

			if EF.weak[player].timer >= EF.weak[player].dur then
				EF.weak[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_weak", minetest.serialize(EF.weak[player]))
			end

		else
			EF.weak[player] = nil
		end

	end

	-- Check for Strong players
	for player, vals in pairs(EF.strong) do

		if player:is_player() then

			EF.strong[player].timer = EF.strong[player].timer + dtime

			if player:get_pos() then mcl_potions._add_spawner(player, "#932423") end

			if EF.strong[player].timer >= EF.strong[player].dur then
				EF.strong[player] = nil
				meta = player:get_meta()
				meta:set_string("_is_strong", minetest.serialize(EF.strong[player]))
			end

		else
			EF.strong[player] = nil
		end

	end

		-- Check for Bad Omen
	for player, vals in pairs(EF.bad_omen) do

		is_player = player:is_player()

		EF.bad_omen[player].timer = EF.bad_omen[player].timer + dtime

		if player:get_pos() then mcl_potions._add_spawner(player, "#0b6138") end

		if EF.bad_omen[player] and EF.bad_omen[player].timer >= EF.bad_omen[player].dur then
			EF.bad_omen[player] = nil
			if is_player then
				meta = player:get_meta()
				meta:set_string("_has_bad_omen", minetest.serialize(EF.bad_omen[player]))
				potions_set_hud(player)
			end
		end

	end

end)

-- Prevent damage to player with Fire Resistance enabled
mcl_damage.register_modifier(function(obj, damage, reason)
	if EF.fire_proof[obj] and not reason.flags.bypasses_magic and reason.flags.is_fire then
		return 0
	end
end, -50)



-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ██╗░░░░░░█████╗░░█████╗░██████╗░░░░░██╗░██████╗░█████╗░██╗░░░██╗███████╗
-- ██║░░░░░██╔══██╗██╔══██╗██╔══██╗░░░██╔╝██╔════╝██╔══██╗██║░░░██║██╔════╝
-- ██║░░░░░██║░░██║███████║██║░░██║░░██╔╝░╚█████╗░███████║╚██╗░██╔╝█████╗░░
-- ██║░░░░░██║░░██║██╔══██║██║░░██║░██╔╝░░░╚═══██╗██╔══██║░╚████╔╝░██╔══╝░░
-- ███████╗╚█████╔╝██║░░██║██████╔╝██╔╝░░░██████╔╝██║░░██║░░╚██╔╝░░███████╗
-- ╚══════╝░╚════╝░╚═╝░░╚═╝╚═════╝░╚═╝░░░░╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚══════╝

function mcl_potions._clear_cached_player_data(player)
	EF.invisible[player] = nil
	EF.poisoned[player] = nil
	EF.regenerating[player] = nil
	EF.strong[player] = nil
	EF.weak[player] = nil
	EF.water_breathing[player] = nil
	EF.leaping[player] = nil
	EF.swift[player] = nil
	EF.night_vision[player] = nil
	EF.fire_proof[player] = nil
	EF.bad_omen[player] = nil
	EF.withering[player] = nil

	meta = player:get_meta()
	meta:set_int("night_vision", 0)
end

function mcl_potions._reset_player_effects(player, set_hud)

	if not player:is_player() then
		return
	end

	mcl_potions.make_invisible(player, false)

	playerphysics.remove_physics_factor(player, "jump", "mcl_potions:leaping")

	playerphysics.remove_physics_factor(player, "speed", "mcl_potions:swiftness")

	mcl_weather.skycolor.update_sky_color({player})

	mcl_potions._clear_cached_player_data(player)

	if set_hud ~= false then
		potions_set_hud(player)
	end
end

function mcl_potions._save_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	meta:set_string("_is_invisible", minetest.serialize(EF.invisible[player]))
	meta:set_string("_is_poisoned", minetest.serialize(EF.poisoned[player]))
	meta:set_string("_is_regenerating", minetest.serialize(EF.regenerating[player]))
	meta:set_string("_is_strong", minetest.serialize(EF.strong[player]))
	meta:set_string("_is_weak", minetest.serialize(EF.weak[player]))
	meta:set_string("_is_water_breathing", minetest.serialize(EF.water_breathing[player]))
	meta:set_string("_is_leaping", minetest.serialize(EF.leaping[player]))
	meta:set_string("_is_swift", minetest.serialize(EF.swift[player]))
	meta:set_string("_is_cat", minetest.serialize(EF.night_vision[player]))
	meta:set_string("_is_fire_proof", minetest.serialize(EF.fire_proof[player]))
	meta:set_string("_has_bad_omen", minetest.serialize(EF.bad_omen[player]))
	meta:set_string("_is_withering", minetest.serialize(EF.withering[player]))

end

function mcl_potions._load_player_effects(player)

	if not player:is_player() then
		return
	end
	meta = player:get_meta()

	if minetest.deserialize(meta:get_string("_is_invisible")) then
		EF.invisible[player] = minetest.deserialize(meta:get_string("_is_invisible"))
		mcl_potions.make_invisible(player, true)
	end

	if minetest.deserialize(meta:get_string("_is_poisoned")) then
		EF.poisoned[player] = minetest.deserialize(meta:get_string("_is_poisoned"))
	end

	if minetest.deserialize(meta:get_string("_is_regenerating")) then
		EF.regenerating[player] = minetest.deserialize(meta:get_string("_is_regenerating"))
	end

	if minetest.deserialize(meta:get_string("_is_strong")) then
		EF.strong[player] = minetest.deserialize(meta:get_string("_is_strong"))
	end

	if minetest.deserialize(meta:get_string("_is_weak")) then
		EF.weak[player] = minetest.deserialize(meta:get_string("_is_weak"))
	end

	if minetest.deserialize(meta:get_string("_is_water_breathing")) then
		EF.water_breathing[player] = minetest.deserialize(meta:get_string("_is_water_breathing"))
	end

	if minetest.deserialize(meta:get_string("_is_leaping")) then
		EF.leaping[player] = minetest.deserialize(meta:get_string("_is_leaping"))
	end

	if minetest.deserialize(meta:get_string("_is_swift")) then
		EF.swift[player] = minetest.deserialize(meta:get_string("_is_swift"))
	end

	if minetest.deserialize(meta:get_string("_is_cat")) then
		EF.night_vision[player] = minetest.deserialize(meta:get_string("_is_cat"))
	end

	if minetest.deserialize(meta:get_string("_is_fire_proof")) then
		EF.fire_proof[player] = minetest.deserialize(meta:get_string("_is_fire_proof"))
	end

	if minetest.deserialize(meta:get_string("_has_bad_omen")) then
		EF.bad_omen[player] = minetest.deserialize(meta:get_string("_has_bad_omen"))
	end

	if minetest.deserialize(meta:get_string("_is_withering")) then
		EF.withering[player] = minetest.deserialize(meta:get_string("_is_withering"))
	end

end

-- Returns true if player has given effect
function mcl_potions.player_has_effect(player, effect_name)
	if not EF[effect_name] then
		return false
	end
	return EF[effect_name][player] ~= nil
end

function mcl_potions.player_get_effect(player, effect_name)
	if not EF[effect_name] or not EF[effect_name][player] then
		return false
	end
	return EF[effect_name][player]
end

function mcl_potions.player_clear_effect(player,effect)
	EF[effect][player] = nil
	potions_set_icons(player)
end

minetest.register_on_leaveplayer( function(player)
	mcl_potions._save_player_effects(player)
	mcl_potions._clear_cached_player_data(player) -- clearout the buffer to prevent looking for a player not there
	icon_ids[player:get_player_name()] = nil
end)

minetest.register_on_dieplayer( function(player)
	mcl_potions._reset_player_effects(player)
	potions_set_hud(player)
end)

minetest.register_on_joinplayer( function(player)
	mcl_potions._reset_player_effects(player, false) -- make sure there are no wierd holdover effects
	mcl_potions._load_player_effects(player)
	potions_init_icons(player)
	potions_set_hud(player)
end)

minetest.register_on_shutdown(function()
	-- save player effects on server shutdown
	for _,player in pairs(minetest.get_connected_players()) do
		mcl_potions._save_player_effects(player)
	end

end)


-- ░██████╗██╗░░░██╗██████╗░██████╗░░█████╗░██████╗░████████╗██╗███╗░░██╗░██████╗░
-- ██╔════╝██║░░░██║██╔══██╗██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██║████╗░██║██╔════╝░
-- ╚█████╗░██║░░░██║██████╔╝██████╔╝██║░░██║██████╔╝░░░██║░░░██║██╔██╗██║██║░░██╗░
-- ░╚═══██╗██║░░░██║██╔═══╝░██╔═══╝░██║░░██║██╔══██╗░░░██║░░░██║██║╚████║██║░░╚██╗
-- ██████╔╝╚██████╔╝██║░░░░░██║░░░░░╚█████╔╝██║░░██║░░░██║░░░██║██║░╚███║╚██████╔╝
-- ╚═════╝░░╚═════╝░╚═╝░░░░░╚═╝░░░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░╚══╝░╚═════╝░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

function mcl_potions.is_obj_hit(self, pos)

	local entity
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.1)) do

		entity = object:get_luaentity()

		if entity and entity.name ~= self.object:get_luaentity().name then

			if entity.is_mob then
				return true
			end

		elseif object:is_player() and self._thrower ~= object:get_player_name() then
			return true
		end

	end
	return false
end


function mcl_potions.make_invisible(obj_ref, hide)
	if obj_ref:is_player() then
		if hide then
			mcl_player.player_set_visibility(obj_ref, false)
			obj_ref:set_nametag_attributes({ color = { a = 0 } })
		else
			mcl_player.player_set_visibility(obj_ref, true)
			obj_ref:set_nametag_attributes({ color = { r = 255, g = 255, b = 255, a = 255 } })
		end
	else
		if hide then
			local luaentity = obj_ref:get_luaentity()
			EF.invisible[obj_ref].old_size = luaentity.visual_size
			obj_ref:set_properties({ visual_size = { x = 0, y = 0 } })
		else
			obj_ref:set_properties({ visual_size = EF.invisible[obj_ref].old_size })
		end
	end
end


function mcl_potions._use_potion(item, obj, color)
	local d = 0.1
	local pos = obj:get_pos()
	minetest.sound_play("mcl_potions_drinking", {pos = pos, max_hear_distance = 6, gain = 1})
	minetest.add_particlespawner({
		amount = 25,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 1,
		maxexptime = 5,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = true,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end


function mcl_potions._add_spawner(obj, color)
	local d = 0.2
	local pos = obj:get_pos()
	minetest.add_particlespawner({
		amount = 1,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+1, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+2, z=pos.z+d},
		minvel = {x=-0.1, y=0, z=-0.1},
		maxvel = {x=0.1, y=0.1, z=0.1},
		minacc = {x=-0.1, y=0, z=-0.1},
		maxacc = {x=0.1, y=.1, z=0.1},
		minexptime = 0.5,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 1,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_effect.png^[colorize:"..color..":127",
	})
end



-- ██████╗░░█████╗░░██████╗███████╗  ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗██╔════╝██╔════╝  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╦╝███████║╚█████╗░█████╗░░  ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔══██╗██╔══██║░╚═══██╗██╔══╝░░  ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██████╦╝██║░░██║██████╔╝███████╗  ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝  ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ███████╗███████╗███████╗███████╗░█████╗░████████╗
-- ██╔════╝██╔════╝██╔════╝██╔════╝██╔══██╗╚══██╔══╝
-- █████╗░░█████╗░░█████╗░░█████╗░░██║░░╚═╝░░░██║░░░
-- ██╔══╝░░██╔══╝░░██╔══╝░░██╔══╝░░██║░░██╗░░░██║░░░
-- ███████╗██║░░░░░██║░░░░░███████╗╚█████╔╝░░░██║░░░
-- ╚══════╝╚═╝░░░░░╚═╝░░░░░╚══════╝░╚════╝░░░░╚═╝░░░
--
-- ███████╗██╗░░░██╗███╗░░██╗░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔════╝██║░░░██║████╗░██║██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- █████╗░░██║░░░██║██╔██╗██║██║░░╚═╝░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔══╝░░██║░░░██║██║╚████║██║░░██╗░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚██████╔╝██║░╚███║╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚═════╝░╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


function mcl_potions.healing_func(player, hp)

	if not player or player:get_hp() <= 0 then return false end

	local obj = player:get_luaentity()

	if obj and obj.harmed_by_heal then hp = -hp end

	if hp > 0 then
		-- at least 1 HP
		if hp < 1 then
			hp = 1
		end

		if obj and obj.is_mob then
			obj.health = math.max(obj.health + hp, obj.object:get_properties().hp_max)
		elseif player:is_player() then
			player:set_hp(math.min(player:get_hp() + hp, player:get_properties().hp_max), { type = "set_hp", other = "healing" })
		end

	elseif hp < 0 then
		if hp > -1 then
			hp = -1
		end

		mcl_util.deal_damage(player, -hp, {type = "magic"})
	end

end

function mcl_potions.swiftness_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not player:get_meta() then
		return false
	end

	if not EF.swift[player] then

		EF.swift[player] = {dur = duration, timer = 0, is_slow = factor < 1}
		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)

	else

		local victim = EF.swift[player]

		playerphysics.add_physics_factor(player, "speed", "mcl_potions:swiftness", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
		victim.is_slow = factor < 1

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions.leaping_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not player:get_meta() then
		return false
	end

	if not EF.leaping[player] then

		EF.leaping[player] = {dur = duration, timer = 0}
		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)

	else

		local victim = EF.leaping[player]

		playerphysics.add_physics_factor(player, "jump", "mcl_potions:leaping", factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.weakness_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not EF.weak[player] then

		EF.weak[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = EF.weak[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.strength_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not EF.strong[player] then

		EF.strong[player] = {dur = duration, timer = 0, factor = factor}

	else

		local victim = EF.strong[player]

		victim.factor = factor
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.withering_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and (entity.is_boss or string.find(entity.name, "wither")) then return false end

	if not EF.withering[player] then

		EF.withering[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.withering[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_hud(player)
	end

end


function mcl_potions.poison_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and (entity.is_boss or entity.harmed_by_heal or string.find(entity.name, "spider")) then return false end

	if not EF.poisoned[player] then

		EF.poisoned[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.poisoned[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_hud(player)
	end

end


function mcl_potions.regeneration_func(player, factor, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and (entity.is_boss or entity.harmed_by_heal) then return false end

	if not EF.regenerating[player] then

		EF.regenerating[player] = {step = factor, dur = duration, timer = 0}

	else

		local victim = EF.regenerating[player]

		victim.step = math.min(victim.step, factor)
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_hud(player)
	end

end


function mcl_potions.invisiblility_func(player, null, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not EF.invisible[player] then

		EF.invisible[player] = {dur = duration, timer = 0}
		mcl_potions.make_invisible(player, true)

	else

		local victim = EF.invisible[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions.water_breathing_func(player, null, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not EF.water_breathing[player] then

		EF.water_breathing[player] = {dur = duration, timer = 0}

	else

		local victim = EF.water_breathing[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.fire_resistance_func(player, null, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	if not EF.fire_proof[player] then

		EF.fire_proof[player] = {dur = duration, timer = 0}

	else

		local victim = EF.fire_proof[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	if player:is_player() then
		potions_set_icons(player)
	end

end


function mcl_potions.night_vision_func(player, null, duration)

	if not player or player:get_hp() <= 0 then return false end

	local entity = player:get_luaentity()
	if entity and entity.is_boss then return false end

	meta = player:get_meta()
	if not EF.night_vision[player] then

		EF.night_vision[player] = {dur = duration, timer = 0}

	else

		local victim = EF.night_vision[player]

		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0

	end

	is_player = player:is_player()
	if is_player then
		meta:set_int("night_vision", 1)
	else
		return -- Do not attempt to set night_vision on mobs
	end
	mcl_weather.skycolor.update_sky_color({player})

	if player:is_player() then
		potions_set_icons(player)
	end

end

function mcl_potions._extinguish_nearby_fire(pos, radius)
	local epos = {x=pos.x, y=pos.y+0.5, z=pos.z}
	local dnode = minetest.get_node({x=pos.x,y=pos.y-0.5,z=pos.z})
	if minetest.get_item_group(dnode.name, "fire") ~= 0 or minetest.get_item_group(dnode.name, "lit_campfire") ~= 0 then
		epos.y = pos.y - 0.5
	end
	local exting = false
	-- No radius: Splash, extinguish epos and 4 nodes around
	if not radius then
		local dirs = {
			{x=0,y=0,z=0},
			{x=0,y=0,z=-1},
			{x=0,y=0,z=1},
			{x=-1,y=0,z=0},
			{x=1,y=0,z=0},
		}
		for d=1, #dirs do
			local tpos = vector.add(epos, dirs[d])
			local node = minetest.get_node(tpos)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				minetest.remove_node(tpos)
				exting = true
			elseif minetest.get_item_group(node.name, "lit_campfire") ~= 0 then
				minetest.sound_play("fire_extinguish_flame", {pos = tpos, gain = 0.25, max_hear_distance = 16}, true)
				local def = minetest.registered_nodes[node.name]
				minetest.set_node(tpos, {name = def._mcl_campfires_smothered_form, param2 = node.param2})
				exting = true
			end
		end
	-- Has radius: lingering, extinguish all nodes in area
	else
		local nodes = minetest.find_nodes_in_area(
			{x=epos.x-radius,y=epos.y,z=epos.z-radius},
			{x=epos.x+radius,y=epos.y,z=epos.z+radius},
			{"group:fire", "group:lit_campfire"})
		for n=1, #nodes do
			local node = minetest.get_node(nodes[n])
			minetest.sound_play("fire_extinguish_flame", {pos = nodes[n], gain = 0.25, max_hear_distance = 16}, true)
			if minetest.get_item_group(node.name, "fire") ~= 0 then
				minetest.remove_node(nodes[n])
			elseif minetest.get_item_group(node.name, "lit_campfire") ~= 0 then
				local def = minetest.registered_nodes[node.name]
				minetest.set_node(nodes[n], {name = def._mcl_campfires_smothered_form, param2 = node.param2})
			end
			exting = true
		end
	end
	return exting
end

function mcl_potions.bad_omen_func(player, factor, duration)
	if not EF.bad_omen[player] then
		EF.bad_omen[player] = {dur = duration, timer = 0, factor = factor}
	else
		local victim = EF.bad_omen[player]
		victim.dur = math.max(duration, victim.dur - victim.timer)
		victim.timer = 0
		victim.factor = factor
	end

	if player:is_player() then
		potions_set_icons(player)
	end
end
