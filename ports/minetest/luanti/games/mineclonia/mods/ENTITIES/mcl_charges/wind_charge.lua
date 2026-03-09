local S = core.get_translator("mcl_charges")
local RADIUS = 4
local damage_radius = (RADIUS / math.max(1, RADIUS)) * RADIUS
local radius = 2

mcl_charges.register_charge("wind_charge", S("Wind Charge"), {
	hit_player = mcl_mobs.get_arrow_damage_func(0, "fireball"),
	hit_mob = mcl_mobs.get_arrow_damage_func(6, "fireball"),
	hit_node = function(self, pos, node)
		mcl_charges.wind_burst(pos, damage_radius)
		local pr = PcgRandom(math.ceil(os.time() / 60 / 10)) -- make particles change direction every 10 minutes
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		core.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		core.sound_play("tnt_explode", { pos = pos, gain = 0.4, max_hear_distance = 30, pitch = 2.5 }, true)

		if core.get_item_group (node.name, "bell") >= 1 then
			mcl_bells.ring_once(pos)
		end
		if node.name == "mcl_end:chorus_flower" then
			core.dig_node(pos)
			mcl_charges.chorus_flower_effects(pos, radius)
		end
		if node.name == "mcl_end:chorus_flower_dead" then
			core.swap_node(pos, {name = "air"})
			core.add_item(pos, {name = "mcl_end:chorus_flower"})
			mcl_charges.chorus_flower_effects(pos, radius)
		end
		if node.name == "mcl_pottery_sherds:pot" then
			core.swap_node(pos, {name = "air"})
			core.add_item(pos, {name = "mcl_core:brick"})
			core.add_item(pos, {name = "mcl_core:brick"})
			core.add_item(pos, {name = "mcl_core:brick"})
			core.add_item(pos, {name = "mcl_core:brick"})
			mcl_charges.pot_effects(pos, radius)
		end
	end,
	hit_player_alt = function(_, pos)
		mcl_charges.wind_burst(pos, damage_radius)
		local pr = PcgRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		core.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		core.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
	end,
	hit_mob_alt = function(_, pos)
		mcl_charges.wind_burst(pos, damage_radius)
		local pr = PcgRandom(math.ceil(os.time() / 60 / 10))
		local v = vector.new(pr:next(-2, 2)/10, 0, pr:next(-2, 2)/10)
		v.y = pr:next(-9, -4) / 10
		core.add_particlespawner(table.merge(mcl_charges.wind_burst_spawner, {
			minacc = v,
			maxacc = v,
			minpos = vector.offset(pos, -0.8, 0.6, -0.8),
			maxpos = vector.offset(pos, 0.8, 0.8, 0.8),
		}))
		core.sound_play("tnt_explode", { pos = pos, gain = 0.5, max_hear_distance = 30, pitch = 2.5 }, true)
	end,
	on_activate = function(self, _)
		self.object:set_armor_groups({immortal = 1})
		core.after(3, function()
			if self.object:get_luaentity() then
				self.object:remove()
			end
		end)
	end,
})
