local S = core.get_translator(core.get_current_modname())

local hud_totem = {}

core.register_on_leaveplayer(function(player)
	hud_totem[player] = nil
end)

core.register_craftitem("mcl_totems:totem", {
	description = S("Totem of Undying"),
	_tt_help = core.colorize(mcl_colors.GREEN, S("Protects you from death while wielding it")),
	_doc_items_longdesc = S("A totem of undying is a rare artifact which may safe you from certain death."),
	_doc_items_usagehelp = S("The totem only works while you hold it in your hand. If you receive fatal damage, you are saved from death and you get a second chance with 1 HP. The totem is destroyed in the process, however."),
	inventory_image = "mcl_totems_totem.png",
	wield_image = "mcl_totems_totem.png",
	stack_max = 1,
	groups = {combat_item = 1, offhand_item = 1, rarity = 1},
	_mcl_wieldview_item = "mcl_totems:totem_wielded",
})
core.register_alias("mobs_mc:totem", "mcl_totems:totem")

core.register_craftitem("mcl_totems:totem_wielded", {
	inventory_image = "mcl_totems_totem.png",
	wield_image = "mcl_totems_totem_wieldview.png",
	groups = { not_in_creative_inventory = 1 },
	stack_max = 1,
})

local particle_colors = {"98BF22", "C49E09", "337D0B", "B0B021", "1E9200"} -- TODO: real MC colors

-- Save the player from death when holding totem of undying in hand
mcl_damage.register_modifier(function(obj, damage, reason)
	if not reason.flags.bypasses_totem then
		local hp = mcl_util.get_hp (obj)
		local entity = obj:get_luaentity ()
		if hp - damage <= 0 and (obj:is_player () or (entity and entity.is_mob)) then
			local wield = mcl_util.get_wielditem (obj)
			local in_offhand = false
			if wield:get_name() ~= "mcl_totems:totem" then
				local inv = obj:get_inventory()
				if inv then
					wield = obj:get_inventory():get_stack("offhand", 1)
					in_offhand = true
				end
			end
			if wield:get_name() == "mcl_totems:totem" then
				local ppos = obj:get_pos()

				if obj:is_player () then
					if obj:get_breath() < 11 then
						obj:set_breath(10)
					end
					if not core.is_creative_enabled(obj:get_player_name()) then
						wield:take_item()
						if in_offhand then
							obj:get_inventory():set_stack("offhand", 1, wield)
							mcl_inventory.update_inventory_formspec(obj)
						else
							obj:set_wielded_item(wield)
						end
					end
					awards.unlock(obj:get_player_name(), "mcl:postMortal")
				else
					entity.breath = math.max (entity.breath, 10)
					entity:set_wielditem (ItemStack ())
				end

				-- Effects
				core.sound_play({name = "mcl_totems_totem", gain = 1}, {pos=ppos, max_hear_distance = 16}, true)

				for i = 1, 4 do
					for c = 1, #particle_colors do
						core.add_particlespawner({
								amount = math.floor(100 / (4 * #particle_colors)),
								time = 1,
								minpos = vector.offset(ppos, 0, -1, 0),
								maxpos = vector.offset(ppos, 0, 1, 0),
								minvel = vector.new(-1.5, 0, -1.5),
								maxvel = vector.new(1.5, 1.5, 1.5),
								minacc = vector.new(0, -0.1, 0),
								maxacc = vector.new(0, -1, 0),
								minexptime = 1,
								maxexptime = 3,
								minsize = 1,
								maxsize = 2,
								collisiondetection = true,
								collision_removal = true,
								object_collision = false,
								vertical = false,
								texture = "mcl_particles_totem" .. i .. ".png^[colorize:#" .. particle_colors[c],
								glow = 10,
							})
					end
				end

				-- Status effects; see
				-- https://minecraft.wiki/w/Totem_of_Undying
				--
				-- Totems also clear all effects
				-- before applying theirs.
				mcl_potions._reset_effects (obj, true)
				mcl_potions.give_effect_by_level ("regeneration", obj, 2, 45);
				mcl_potions.give_effect ("fire_resistance", obj, 1, 40);
				mcl_potions.give_effect_by_level ("absorption", obj, 2, 5);

				-- Big totem overlay
				if obj:is_player () and not hud_totem[obj] then
					hud_totem[obj] = obj:hud_add({
						type = "image",
						text = "mcl_totems_totem.png",
						position = {x = 0.5, y = 1},
						scale = {x = 17, y = 17},
						offset = {x = 0, y = -178},
						z_index = 100,
					})
					core.after(3, function()
						if obj:is_player() then
							obj:hud_remove(hud_totem[obj])
							hud_totem[obj] = nil
						end
					end)
				end

				-- Set HP to exactly 1
				return math.max (0, hp - 1)
			end
		end
	end
end, 1000)
