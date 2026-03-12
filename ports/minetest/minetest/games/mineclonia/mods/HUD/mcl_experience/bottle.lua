local S = core.get_translator(core.get_current_modname())

core.register_entity("mcl_experience:bottle",{
	initial_properties = {
		textures = {"mcl_experience_bottle.png^[colorize:purple:50"},
		hp_max = 1,
		visual_size = {x = 0.35, y = 0.35},
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		pointable = false,
	},
	on_step = function(self, _)
		local pos = self.object:get_pos()
		local node = core.get_node(pos)
		local n = node.name
		if n ~= "air" and n ~= "mcl_portals:portal" and n ~= "mcl_portals:portal_end" and core.get_item_group(n, "liquid") == 0 then
			core.sound_play("mcl_potions_breaking_glass", {pos = pos, max_hear_distance = 16, gain = 1})
			mcl_experience.throw_xp(pos, math.random(3, 11))
			core.add_particlespawner({
				amount = 50,
				time = 0.1,
				minpos = vector.add(pos, vector.new(-0.1, 0.5, -0.1)),
				maxpos = vector.add(pos, vector.new( 0.1, 0.6,  0.1)),
				minvel = vector.new(-2, 0, -2),
				maxvel = vector.new( 2, 2,  2),
				minacc = vector.new(0, 0, 0),
				maxacc = vector.new(0, 0, 0),
				minexptime = 0.5,
				maxexptime = 1.25,
				minsize = 1,
				maxsize = 2,
				collisiondetection = true,
				vertical = false,
				texture = "mcl_particles_effect.png^[colorize:blue:127",
			})
			if n == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos))
			end
			self.object:remove()
		end
	end,
})

local function throw_xp_bottle(pos, dir, velocity)
	core.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
	local obj = core.add_entity(pos, "mcl_experience:bottle")
	if not obj or not obj:get_pos() then return end
	obj:set_velocity(vector.multiply(dir, velocity))
	local acceleration = vector.multiply(dir, -3)
	acceleration.y = -9.81
	obj:set_acceleration(acceleration)
end

local function on_use(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc ~= nil then
		return rc
	end
	throw_xp_bottle(vector.add(placer:get_pos(), vector.new(0, 1.5, 0)), placer:get_look_dir(), 10)
	if not core.is_creative_enabled(placer:get_player_name()) then
		itemstack:take_item()
	end
	return itemstack
end

core.register_craftitem("mcl_experience:bottle", {
	description = S("Bottle o' Enchanting"),
	groups = {rarity = 1},
	inventory_image = "mcl_experience_bottle.png^[colorize:purple:50",
	wield_image = "mcl_experience_bottle.png^[colorize:purple:50",
	on_place = on_use,
	on_secondary_use = on_use,
	_on_dispense = function(_, pos, _, _, dir)
		throw_xp_bottle(vector.add(pos, vector.multiply(dir, 0.51)), dir, 10)
	end
})

