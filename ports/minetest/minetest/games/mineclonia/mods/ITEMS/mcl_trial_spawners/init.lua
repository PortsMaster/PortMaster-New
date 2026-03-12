local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)

mcl_trial_spawners = {}

local activation_radius = 14
local spawning_radius = 4
local activation_cooldown = 30 * 60
local item_spawner_spawning_interval = 8

local standard_loot_table = {
	stacks_min = 1,
	stacks_max = 1,
	items = {
		{ itemstring = "mcl_farming:bread",             weight = 3, amount_min = 1, amount_max = 3 },
		{ itemstring = "mcl_mobitems:cooked_chicken",   weight = 3, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_farming:potato_item_baked", weight = 2, amount_min = 1, amount_max = 3 },
		{ itemstring = "mcl_potions:regeneration",      weight = 1, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_potions:swiftness",         weight = 1, amount_min = 1, amount_max = 1 },
	}
}

local ominous_loot_table = {
	stacks_min = 1,
	stacks_max = 1,
	items = {
		{ itemstring = "mcl_farming:potato_item_baked", weight = 3, amount_min = 2, amount_max = 4 },
		{ itemstring = "mcl_mobitems:cooked_beef",      weight = 3, amount_min = 1, amount_max = 2 },
		{ itemstring = "mcl_farming:carrot_item_gold",  weight = 2, amount_min = 1, amount_max = 2 },
		{ itemstring = "mcl_potions:regeneration",      weight = 1, amount_min = 1, amount_max = 1 },
		{ itemstring = "mcl_potions:strength",          weight = 1, amount_min = 1, amount_max = 1 },
	}
}

local possible_mob_gear

-- This is stored here and not in node metadata because it uses object references, which can't be serialized
-- TODO: perhaps switch out to GUID's once we drop older versions of luanti
local trial_spawners_spawned_mobs = {}

local function modify_aromr(stack, trim)
	stack = mcl_enchanting.enchant(stack, "protection", 4)
	stack = mcl_enchanting.enchant(stack, "projectile_protection", 4)
	stack = mcl_enchanting.enchant(stack, "fire_protection", 4)
	mcl_armor.trim(stack, trim, ItemStack("mcl_copper:copper_ingot"))
	return stack
end

-- this needs to be initialized so late since mcl_enchanting.enchant can only work after all the mods have loaded
core.register_on_mods_loaded(function()
	possible_mob_gear = {
		chestplates = {
			modify_aromr(ItemStack("mcl_armor:chestplate_diamond"), "flow"),
			modify_aromr(ItemStack("mcl_armor:chestplate_iron"),    "flow"),
			modify_aromr(ItemStack("mcl_armor:chestplate_iron"),    "flow"),
			modify_aromr(ItemStack("mcl_armor:chestplate_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:chestplate_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:chestplate_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:chestplate_chain"),   "bolt"),
		},
		helmets = {
			modify_aromr(ItemStack("mcl_armor:helmet_diamond"), "flow"),
			modify_aromr(ItemStack("mcl_armor:helmet_iron"),    "flow"),
			modify_aromr(ItemStack("mcl_armor:helmet_iron"),    "flow"),
			modify_aromr(ItemStack("mcl_armor:helmet_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:helmet_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:helmet_chain"),   "bolt"),
			modify_aromr(ItemStack("mcl_armor:helmet_chain"),   "bolt"),
		},
		ranged_weapons = {
			ItemStack("mcl_bows:bow"),
			ItemStack("mcl_bows:bow"),
			mcl_enchanting.enchant(ItemStack("mcl_bows:bow"), "power", 1),
			mcl_enchanting.enchant(ItemStack("mcl_bows:bow"), "punch", 1)
		},
		melee_weapons = {
			ItemStack("mcl_tools:sword_iron"),
			ItemStack("mcl_tools:sword_iron"),
			ItemStack("mcl_tools:sword_iron"),
			ItemStack("mcl_tools:sword_iron"),
			mcl_enchanting.enchant(ItemStack("mcl_tools:sword_iron"), "sharpness", 1),
			mcl_enchanting.enchant(ItemStack("mcl_tools:sword_iron"), "knockback", 1),
			ItemStack("mcl_tools:sword_diamond"),
		}
	}
end)

local function spawn_blue_bar_particles(pos)
	core.add_particlespawner({
		texpool = {
			{
				name = "trialspawner_blue_bar_particles.1.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 8,
					aspect_h = 8,
					length = -1
				}
			},
			{
				name = "trialspawner_blue_bar_particles.2.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 8,
					aspect_h = 8,
					length = -1
				}
			},
		},
		vel = {
			min = vector.new(0, 0.1, 0),
			max = vector.new(0, 1.5, 0),
		},
		exptime = {min = 1.1, max = 1.3},
		amount = 50,
		time = 0.1,
		vertical = true,
		glow = 15,
		pos = pos,
		radius = {min = 0.9, max = 1.1, bias = 1}
	})
end

function mcl_trial_spawners.spawn_spawning_particles(pos, is_ominous)
	core.add_particlespawner({
		texture = is_ominous and "mcl_particles_soul_fire_flame.png" or "mcl_particles_fire_flame.png",
		exptime = {min = 0.75, max = 1},
		amount = 25,
		time = 0.01,
		vertical = true,
		glow = 15,
		size = {min = 1, max = 2},
		pos = {
			min = vector.offset(pos, -1, -1, -1),
			max = vector.offset(pos, 1, 1, 1),
		},
	})
end

local function transform_to_ominous_spawner(pos, meta)
	spawn_blue_bar_particles(pos)
	core.swap_node(pos, {name = "mcl_trial_spawners:ominous_trialspawner_on"})
	meta:set_int("last_activation", 0)
	local hash = core.hash_node_position(pos)

	if trial_spawners_spawned_mobs[hash] then
		for _, obj in pairs(trial_spawners_spawned_mobs[hash]) do
			local l = obj:get_luaentity()
			if l and l.is_mob then
				l:safe_remove()
			end
		end
	end
end

local function is_in_eyesight_of_spawner(spawner_pos, destination_pos)
	local ray = core.raycast(spawner_pos, destination_pos, false, false)
	local obstructed = false

	for pointed_thing in ray do
		if pointed_thing.type ~= "node" or not vector.equals(pointed_thing.under, spawner_pos) then
			obstructed = true
			break
		end
	end

	return not obstructed
end

local function attempt_spawning_trial_mob(pos, meta, is_ominous)
	local hash = core.hash_node_position(pos)

	local frustration = 0
	while frustration < 30 do
		local spawn_attempt_pos = pos + vector.multiply(vector.random_direction(), mcl_util.float_random(1, spawning_radius))

		if is_in_eyesight_of_spawner(pos, spawn_attempt_pos) then
			local mob_name = meta:get_string("mob")
			if not mob_name or mob_name == "" then
				core.log ("warning", "[mcl_trial_spawners] Mobs name is invalid")
			end
			local sdata
			if mob_name == "mobs_mc:baby_zombie" then
				mob_name = "mobs_mc:zombie"
				sdata = {_is_baby_zombie = true}
			end
			local spawned_mob = mcl_mobs.spawn_abnormally(spawn_attempt_pos, mob_name, sdata, "trial_spawner")

			if spawned_mob then
				local l = spawned_mob:get_luaentity()
				if l and l.is_mob then
					l.persistent = true
					l._effective_wielditem_drop_probability = 0
					mcl_trial_spawners.spawn_spawning_particles(pos, is_ominous)
					mcl_trial_spawners.spawn_spawning_particles(spawned_mob:get_pos(), is_ominous)

					if is_ominous then
						local mobdef = mcl_mobs.registered_mobs[mob_name]

						if mobdef.wears_armor then
							if math.random() > 0.5 then
								l.armor_list.torso = table.random_element(possible_mob_gear.chestplates):get_name()
							end

							if math.random() > 0.5 then
								l.armor_list.head = table.random_element(possible_mob_gear.helmets):get_name()
							end

							if l.can_wield_items then
								if l.attack_type == "melee" then
									l:set_wielditem(ItemStack(table.random_element(possible_mob_gear.melee_weapons):get_name()))
								elseif l.attack_type == "bowshoot" then
									l:set_wielditem(ItemStack(table.random_element(possible_mob_gear.ranged_weapons):get_name()))
								end
							end

							l:set_armor_texture()
						end
					end

					if not trial_spawners_spawned_mobs[hash] then
						trial_spawners_spawned_mobs[hash] = {}
					end

					table.insert(trial_spawners_spawned_mobs[hash], spawned_mob)

					meta:set_int("total_mobs_spawned", meta:get_int("total_mobs_spawned") + 1)
					meta:set_int("last_spawn", core.get_gametime())

					return
				end
			end
		end

		frustration = frustration + 1
	end
end

-- not optimized as it could be, but should be fine since these tables are so short
local function prune_invalid_objectrefs(list)
	local i = 1
	while #list >= i do
		if not list[i]:is_valid() then
			table.remove(list, i)
		else
			i = i + 1
		end
	end
end

local function is_trial_complete(pos, meta, player_count, is_ominous)
	local total_spawn_limit = (player_count - 1) * math.floor(meta:get_float("total_mobs_added_per_player")) + meta:get_int("base_total_mobs")
	local total_mobs_spawned = meta:get_int("total_mobs_spawned")
	local hash = core.hash_node_position(pos)
	local spawned = trial_spawners_spawned_mobs[hash] or {}

	prune_invalid_objectrefs(spawned)

	if is_ominous and not mcl_mobs.registered_mobs[meta:get_string("mob")].wears_armor then
		total_spawn_limit = total_spawn_limit * 2
	end

	return total_mobs_spawned >= total_spawn_limit and #spawned == 0
end

local function can_trial_spawner_spawn_mobs(pos, meta, player_count, is_ominous)
	local total_spawn_limit = (player_count - 1) * math.floor(meta:get_float("total_mobs_added_per_player")) + meta:get_int("base_total_mobs")
	local total_mobs_spawned = meta:get_int("total_mobs_spawned")

	if is_ominous and not mcl_mobs.registered_mobs[meta:get_string("mob")].wears_armor then
		total_spawn_limit = total_spawn_limit * 2
	end

	if total_mobs_spawned >= total_spawn_limit then
		return false
	end

	local hash = core.hash_node_position(pos)
	local spawned = trial_spawners_spawned_mobs[hash] or {}
	local simultaneous_mobs_limit = (player_count - 1) * meta:get_int("simultaneous_mobs_added_per_player")
		+ meta:get_int("base_simultaneous_mobs")
		+ (is_ominous and 1 or 0)

	prune_invalid_objectrefs(spawned)

	return #spawned < simultaneous_mobs_limit
end

local function complete_trial(pos, meta, is_ominous)
	meta:set_int("last_activation", core.get_gametime())
	meta:set_int("last_spawn", 0)
	meta:set_int("total_mobs_spawned", 0)

	if is_ominous then
		core.swap_node(pos, {name = "mcl_trial_spawners:ominous_trialspawner"})
	else
		core.swap_node(pos, {name = "mcl_trial_spawners:trialspawner"})
	end

	local item_count = #core.deserialize(meta:get_string("active_players"))
	local key_drop_chance = is_ominous and 0.3 or 0.5
	local drop_pos = vector.offset(pos, 0, 1, 0)

	meta:set_string("active_players", core.serialize({}))

	if math.random() > key_drop_chance then
		local loot_table = is_ominous and ominous_loot_table or standard_loot_table

		loot_table.stacks_min = item_count
		loot_table.stacks_max = item_count
		local loot = mcl_loot.get_loot(loot_table, PcgRandom(os.time()))

		local function drop_items()
			local stack = loot[#loot]
			loot[#loot] = nil

			core.add_item(drop_pos, stack)

			if #loot > 0 then
				core.after(2, function()
					drop_items()
				end)
			end
		end

		drop_items()
	else
		local function drop_keys(count)
			core.add_item(drop_pos, is_ominous and ItemStack("mcl_vaults:ominous_trial_key") or ItemStack("mcl_vaults:trial_key"))

			if count > 0 then
				core.after(2, function()
					drop_keys(count - 1)
				end)
			end
		end

		drop_keys(item_count - 1)
	end
end

local function trial_spawner_step(pos, meta)
	local last_activation = meta:get_int("last_activation")
	local timestamp = core.get_gametime()

	local node = core.get_node(pos)
	local is_ominous = core.get_item_group(node.name, "ominous_trial_spawner") > 0
	local is_active = core.get_item_group(node.name, "active_trial_spawner") > 0
	local last_spawn = meta:get_int("last_spawn")
	local players = core.deserialize(meta:get_string("active_players")) or {}
	local new_players = {}
	for obj in core.objects_inside_radius(pos, activation_radius) do
		if core.is_player(obj)
				and table.indexof(players, obj:get_player_name()) == -1
				and is_in_eyesight_of_spawner(pos, vector.offset(obj:get_pos(), 0, 1.5, 0)) then
			table.insert(new_players, obj:get_player_name())
		end
	end

	if #new_players ~= 0 then
		table.insert_all(players, new_players)

		if is_active then
			meta:set_string("active_players", core.serialize(players))
		end
	end

	if not is_ominous then
		local transformed = false
		for _, name in pairs(players) do
			local player = core.get_player_by_name(name)
			local ominous_effect = mcl_potions.get_effect_level(player, "bad_omen") or 0

			if ominous_effect > 0 then
				spawn_blue_bar_particles(vector.offset(player:get_pos(), 0, 1.5, 0))
				mcl_potions.give_effect_by_level("trial_omen", player, 1, 60 * 15 * ominous_effect)
				mcl_potions.clear_effect(player, "bad_omen")
			end

			local trial_omen_effect = mcl_potions.get_effect_level(player, "trial_omen") or 0

			if trial_omen_effect > 0 then
				transformed = true
				transform_to_ominous_spawner(pos, meta)
			end
		end

		if transformed then
			return
		end
	end

	if not is_active
		and last_activation > 0
		and timestamp - last_activation < activation_cooldown then
		return
	end

	if is_active then
		if timestamp - last_spawn >= meta:get_int("spawn_interval") and can_trial_spawner_spawn_mobs(pos, meta, #players, is_ominous) then
			attempt_spawning_trial_mob(pos, meta, is_ominous)
		elseif is_trial_complete(pos, meta, #players, is_ominous) then
			complete_trial(pos, meta, is_ominous)
		end

		if is_ominous and timestamp - meta:get_int("last_item_spawner") >= item_spawner_spawning_interval then
			local spawned = trial_spawners_spawned_mobs[core.hash_node_position(pos)] or {}
			for obj in core.objects_inside_radius(pos, activation_radius) do
				if table.indexof(spawned, obj) ~= -1 or core.is_player(obj) then
					mcl_trial_spawners.spawn_item_spawner_above_object(obj)
					meta:set_int("last_item_spawner", core.get_gametime())
					break
				end
			end
		end
	elseif #players ~= 0 then
		core.swap_node(pos, {name = "mcl_trial_spawners:trialspawner_on"})
		core.add_particlespawner({
			texpool = {
				{
					name = "trialspawner_orange_bar_particles.1.png",
					animation = {
						type = "vertical_frames",
						aspect_w = 8,
						aspect_h = 8,
						length = -1
					}
				},
				{
					name = "trialspawner_orange_bar_particles.2.png",
					animation = {
						type = "vertical_frames",
						aspect_w = 8,
						aspect_h = 8,
						length = -1
					}
				},
			},
			vel = {
				min = vector.new(0, 0.1, 0),
				max = vector.new(0, 1.5, 0),
			},
			exptime = {min = 1.1, max = 1.3},
			amount = 50,
			time = 0.1,
			vertical = true,
			glow = 15,
			pos = pos,
			radius = {min = 0.9, max = 1.1, bias = 1}
		})
	elseif is_ominous then
		core.swap_node(pos, {name = "mcl_trial_spawners:trialspawner"})
	end
end

local tpl = {
	description = S("Trial spawner"),
	_tt_help = S("Spawns mobs when players are nearby"),
	_doc_items_longdesc = S("Spawns mobs when there are players in eyesight, when the player has the ominous trial effect, gets converted to the ominous trial spawner"),
	_doc_items_usagehelp = S("Spawns mobs when there are players in eyesight, when the player has the ominous trial effect, gets converted to the ominous trial spawner"),
	drawtype = "allfaces_optional",
	paramtype2 = "facedir",
	paramtype = "light",
	tiles = {"trialspawner_top.png", "trialspawner_bottom.png", "trialspawner_side.png", "trialspawner_side.png", "trialspawner_side.png", "trialspawner_side.png"},
	groups = {
		deco_block = 1, features_cannot_replace = 1, unmovable_by_piston = 1,
		jigsaw_construct = 1, jigsaw_preserve_meta = 1
	},
	is_ground_content = false,
	drop = "",
	light_source = 4,
	_mcl_hardness = 50,
	_mcl_blast_resitance = 50,
	on_construct = function(pos)
		local timer = core.get_node_timer (pos)
		timer:start (1)

		local meta = core.get_meta(pos)

		meta:set_int("last_activation", 0)
		meta:set_int("last_spawn", 0)
		meta:set_int("last_item_spawner", 0)

		meta:set_int("base_total_mobs", 6)
		meta:set_float("total_mobs_added_per_player", 2)

		meta:set_string("active_players", core.serialize({}))

		meta:set_int("base_simultaneous_mobs", 2)
		meta:set_int("simultaneous_mobs_added_per_player", 1)

		meta:set_int("total_mobs_spawned", 0)

		meta:set_float("spawn_interval", 2)
	end,
	on_timer = function(pos)
		trial_spawner_step(pos, core.get_meta(pos))
		return true
	end,
	on_destruct = function(pos)
		trial_spawners_spawned_mobs[core.hash_node_position(pos)] = nil
	end,
	on_rightclick = function(pos, _, clicker, stack)
		if not clicker:is_player() then return stack end
		if core.get_item_group(stack:get_name(), "spawn_egg") == 0 then return stack end
		if not core.is_creative_enabled(clicker:get_player_name()) then return stack end

		local meta = core.get_meta(pos)
		meta:set_string("mob", stack:get_name())
	end
}

core.register_node("mcl_trial_spawners:trialspawner", tpl)

core.register_node("mcl_trial_spawners:trialspawner_on", table.merge(tpl, {
	tiles = {
		"trialspawner_top_on.png", "trialspawner_bottom_on.png", "trialspawner_side_on.png",
		"trialspawner_side_on.png", "trialspawner_side_on.png", "trialspawner_side_on.png"
	},
	groups = table.merge(tpl.groups, {not_in_creative_inventory = 1, active_trial_spawner = 1}),
	light_source = 8
}))

core.register_node("mcl_trial_spawners:ominous_trialspawner", table.merge(tpl, {
	description = S("Trial spawner"),
	tiles = {
		"trialspawner_top_ominous.png", "trialspawner_bottom_ominous.png", "trialspawner_side_ominous.png",
		"trialspawner_side_ominous.png", "trialspawner_side_ominous.png", "trialspawner_side_ominous.png"
	},
	groups = table.merge(tpl.groups, {not_in_creative_inventory = 1, ominous_trial_spawner = 1}),
	light_source = 8
}))

core.register_node("mcl_trial_spawners:ominous_trialspawner_on", table.merge(tpl, {
	description = S("Trial spawner"),
	tiles = {
		"trialspawner_top_ominous.png", "trialspawner_bottom_ominous.png", "trialspawner_side_ominous.png",
		"trialspawner_side_ominous.png", "trialspawner_side_ominous.png", "trialspawner_side_ominous.png"
	},
	groups = table.merge(tpl.groups, {not_in_creative_inventory = 1, ominous_trial_spawner = 1, active_trial_spawner = 1}),
	light_source = 8
}))

dofile(modpath .. "/item_spawner.lua")
