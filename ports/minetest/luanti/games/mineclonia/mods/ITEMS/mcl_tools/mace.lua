local S = core.get_translator("mcl_tools")
mcl_tools.mace_cooldown = {}

--Mace Cooldown
local cooldown_time = 1.6
local heavy_core_longdesc = S("Solid Blocks of Steel. These are only forged if those that are brave enough can defeat the trials that await them.")
local mace_longdesc = S("The mace is a slow melee weapon that deals incredible damage. “dig” key to use it. This weapon has a cooldown of 1.6 seconds, but if you fall the mace will deal more damage than if you are on the ground. The further you fall the more damage done. If you hit a mob or player then you will receive no fall damage, but beware. If you miss you will die. ")

core.register_node("mcl_tools:heavy_core", {
    description = S("Heavy Core"),
	paramtype = "light",
    _doc_items_longdesc = heavy_core_longdesc,
    tiles = {"mcl_tools_heavy_core_top.png", "mcl_tools_heavy_core_bottom.png", "mcl_tools_heavy_core_side.png"},
    is_ground_content = false,
    groups = {pickaxey = 1, deco_block = 1, rarity = 3},
    sounds = mcl_sounds.node_sound_stone_defaults(),
    paramtype2 = "facedir",
    drawtype = "nodebox",
    use_texture_alpha = "clip",
    node_box = {
        type = "fixed",
            fixed = {
              {-0.25, -0.5, -0.25, 0.25, 0.0, 0.25},
        },
    },
    _mcl_hardness = 10,
    _mcl_blast_resistance = 30,
})

local WIND_BURST_BOUNCE_MULTIPLIER = 8

--Mace
core.register_tool("mcl_tools:mace", {
	description = S("Mace"),
	_doc_items_longdesc = mace_longdesc,
	inventory_image = "mcl_tools_mace.png",
	groups = { weapon=1, mace=1, dig_speed_class=1, enchantability=10, sword=1, rarity = 3 },
	wield_scale = mcl_vars.tool_wield_scale,
	tool_capabilities = {
		full_punch_interval = 1.6,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {1.5, 0.9, 0.4}, uses = 50, maxlevel = 3},
		},
		damage_groups = {fleshy = 5},
	},
	_repair_material = "mcl_mobitems:breeze_rod",
	_mcl_toollike_wield = true,

	on_use = function(itemstack, user, pointed_thing)
		local user_velocity = user:get_velocity()
		mcl_tools.entity = pointed_thing.ref
		if pointed_thing.type == "object" then
			local current_time = core.get_gametime()
			mcl_tools.mace_cooldown[user] = mcl_tools.mace_cooldown[user] or 0
			if current_time - mcl_tools.mace_cooldown[user] >= cooldown_time then
				mcl_tools.mace_cooldown[user] = current_time
				-- Define blocks based on laws of physics (an non-perfect solution for defining "blocks" based on velocity):
				-- E(h) = mgh
				-- E(k) = (mv^2)/2
				-- E(h) = E(k) so:
				-- mgh = (mv^2)/2
				-- h = (v^2)/2g
				-- based on experiment g = 20
				local blocks = -1*math.abs(user_velocity.y)*user_velocity.y/40
				local enchantments = mcl_enchanting.get_enchantments(itemstack)
				if mcl_tools.entity:is_player() or mcl_tools.entity:get_luaentity() then
					if blocks > 1 then
						user:add_velocity(vector.new(0, -user_velocity.y, 0))
						if enchantments.wind_burst then
							local pos = core.get_pointed_thing_position(pointed_thing)
							local user_pos = user:get_pos()
							if vector.distance(user_pos, pos) < 3 then
								user:add_velocity(vector.new(0, WIND_BURST_BOUNCE_MULTIPLIER * enchantments.wind_burst, 0))
							end
						core.sound_play("tnt_explode", { pos = pos, gain = 0.4, max_hear_distance = 30, pitch = 2.5 }, true)
						core.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
							minpos = vector.offset(pos, -0.8, 0.6, -0.8),
							maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
						}))
						end
					end
					--damage calculation from https://minecraft.wiki/w/Mace
					local damage = 0
					local enchantments = mcl_enchanting.get_enchantments(itemstack)
					if blocks > 1.5 and enchantments.density then
						damage =  damage + enchantments.density * blocks/2
					end
					if blocks > 8 then
						damage = damage + 23 + blocks
					elseif blocks > 3 then
						damage = damage + blocks * 2 + 18
					elseif blocks > 1.5 then
						damage = damage + blocks * 4 + 9
					elseif blocks > 0 then
						damage = damage + 9
					else
						damage = 6
					end

					mcl_tools.entity:punch(user, 1.6, {
						full_punch_interval = 1.6,
						damage_groups = {fleshy = damage},
					}, nil)

					if not core.is_creative_enabled(user:get_player_name()) then
						itemstack:add_wear(65535 / 500)
						return itemstack
					end
				end
			end
		end
	end,
})

core.register_on_leaveplayer(function(player)
	mcl_tools.mace_cooldown[player] = nil
end)

-- By Cora
mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" and mcl_tools.mace_cooldown[obj] and core.get_gametime() - mcl_tools.mace_cooldown[obj] < 2 then
			return 0
	end
end)

--Crafting recipe for mace
core.register_craft({
	output = "mcl_tools:mace",
	recipe = {
		{ "", "mcl_tools:heavy_core" },
		{ "", "mcl_mobitems:breeze_rod" },
	}
})
