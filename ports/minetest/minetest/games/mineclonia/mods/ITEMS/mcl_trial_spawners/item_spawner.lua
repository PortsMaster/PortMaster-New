local registered_item_spawners = {}

function mcl_trial_spawners.spawn_item_spawner_above_object(obj)
	local obj_pos = obj:get_pos()
	local ray_destination = vector.offset(obj_pos, 0, mcl_util.float_random(2, 6), 0)

	local ray = core.raycast(vector.offset(obj_pos, 0, 0.5, 0), ray_destination, 0, 0)
	local final_pos = ray_destination

	for pointed_thing in ray do
		if pointed_thing.type == "node" then
			final_pos = pointed_thing.above
			break
		end
	end

	local random_item_spawner, random_item_spawner_name = table.random_element(registered_item_spawners)
	local spawn_time = mcl_util.float_random(3, 6)

	core.add_particlespawner({
		texture = "trialspawner_blue_dot_particle.png",
		attract = {
			kind = "point",
			origin = final_pos,
			strength = {min = 0.75, max = 2.5}
		},
		size = {min = 0.2, max = 0.75},
		exptime = 2,
		amount = 40,
		time = spawn_time,
		glow = 15,
		pos = final_pos,
		radius = {min = 0.6, max = 0.8, bias = 1}
	})

	local spawned_obj = core.add_entity(
		final_pos,
		"mcl_trial_spawners:ominous_item_spawner",
		core.serialize({
			type = random_item_spawner_name,
			spawn_time = core.get_gametime() + spawn_time
		})
	)
	spawned_obj:set_properties({wield_item = random_item_spawner.entity_item})
end


local function register_item_spawner(name, def)
	registered_item_spawners[name] = def
end

register_item_spawner("wind charged splash", {
	entity_item = "mcl_potions:wind_charged_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:wind_charged_lingering_flying")
		obj:set_acceleration(vector.new(0, -9.8, 0))
	end
})

register_item_spawner("oozing splash", {
	entity_item = "mcl_potions:oozing_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:oozing_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("weaving splash", {
	entity_item = "mcl_potions:weaving_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:weaving_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("infestation splash", {
	entity_item = "mcl_potions:infestation_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:infestation_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("strength splash", {
	entity_item = "mcl_potions:strength_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:strength_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("swiftness splash", {
	entity_item = "mcl_potions:swiftness_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:swiftness_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("slow falling splash", {
	entity_item = "mcl_potions:slow_falling_lingering",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_potions:slow_falling_lingering_flying")
		obj:set_acceleration(vector.new(0, -20, 0))
	end
})

register_item_spawner("wind charge", {
	entity_item = "mcl_charges:wind_charge",
	func = function(pos)
		local obj = core.add_entity(pos, "mcl_charges:wind_charge_flying")
		obj:set_velocity(vector.new(0, -15, 0))
	end
})

register_item_spawner("small fire charge", {
	entity_item = "mcl_fire:fire_charge",
	func = function(pos)
		local obj = core.add_entity(pos, "mobs_mc:blaze_fireball")
		local l = obj:get_luaentity()
		l._shot_from_dispenser = true
		l.switch = 1
		obj:set_velocity(vector.new(0, -15, 0))
	end
})

register_item_spawner("arrow", {
	entity_item = "mcl_bows:arrow",
	func = function(pos)
		mcl_bows.shoot_arrow ("mcl_bows:arrow", pos, vector.new(0, -1, 0), 0, "mcl_trial_spawners:ominous_item_spawner", 1)
	end
})

register_item_spawner("slowness arrow", {
	entity_item = "mcl_potions:slowness_arrow",
	func = function(pos)
		local stack = ItemStack("mcl_potions:slowness_arrow")
		local meta = stack:get_meta()
		meta:set_int("mcl_potions:potion_potent", 4)
		mcl_bows.shoot_arrow (stack:get_name(), pos, vector.new(0, -1, 0), 0, "mcl_trial_spawners:ominous_item_spawner", 1)
	end
})

register_item_spawner("poison arrow", {
	entity_item = "mcl_potions:poison_arrow",
	func = function(pos)
		mcl_bows.shoot_arrow ("mcl_potions:poison_arrow", pos, vector.new(0, -1, 0), 0, "mcl_trial_spawners:ominous_item_spawner", 1)
	end
})

core.register_entity("mcl_trial_spawners:ominous_item_spawner", {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = "wielditem",
		visual_size = {x = 0.2, y = 0.2, z = 0.2},
		automatic_rotate = 1,
		static_save = true
	},
	on_activate = function(self, staticdata)
		local data = core.deserialize(staticdata)
		self.type = data.type
		self.spawn_time = data.spawn_time
	end,
	get_staticdata = function(self)
		return core.serialize({
			type = self.type,
			spawn_time = self.spawn_time
		})
	end,
	on_step = function(self)
		if core.get_gametime() < self.spawn_time then return end

		local obj_pos = self.object:get_pos()
		mcl_trial_spawners.spawn_spawning_particles(obj_pos, true)
		registered_item_spawners[self.type].func(obj_pos)
		self.object:remove()
	end
})
