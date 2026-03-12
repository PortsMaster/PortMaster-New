local S = core.get_translator(core.get_current_modname())

local function lingering_image(colorstring)
	return "mcl_potions_splash_overlay.png^[multiply:"..colorstring.."^mcl_potions_lingering_bottle.png"
end

local lingering_effects_at = {}

local function potency_to_level (potency)
	return (potency + 1) * mcl_potions.LINGERING_FACTOR
end

local function add_lingering_effects (pos, color, effects, is_water, texture,
					  duration, custom_effect, potency, plus,
					  initial_radius)
	local tbl = lingering_effects_at[pos]
	if not tbl then
	tbl = { }
	lingering_effects_at[pos] = tbl
	end

	table.insert (tbl, { color = color, lifespan = duration,
			 timer = duration,
			 is_water = is_water,
			 effects = effects,
			 texture = texture,
			 initial_radius = initial_radius,
			 -- The next three fields are only material if
			 -- custom_effect is set.
			 custom_effect = custom_effect,
			 level = (potency
				  and potency_to_level (potency)),
			 plus = plus, })
end

local function def_to_effect_list (def, potency, plus)
	local effects = {}

	-- Calculate factors and lengths for each effect defined.
	if not def._effect_list then
	return effects
	end
	for name, details in pairs (def._effect_list) do
	effects[name] = {}
	effects[name].level = mcl_potions.level_from_details (details,
								  potency)
	effects[name].dur
		= mcl_potions.duration_from_details (details, potency, plus,
						 mcl_potions.LINGERING_FACTOR)
	end
	return effects
end

local function linger_particles(pos, d, texture, color)
	core.add_particlespawner({
		amount = 10 * d^2,
		time = 1,
		minpos = {x=pos.x-d, y=pos.y+0.5, z=pos.z-d},
		maxpos = {x=pos.x+d, y=pos.y+1, z=pos.z+d},
		minvel = {x=-0.5, y=0, z=-0.5},
		maxvel = {x=0.5, y=0.5, z=0.5},
		minacc = {x=-0.2, y=0, z=-0.2},
		maxacc = {x=0.2, y=.05, z=0.2},
		minexptime = 1,
		maxexptime = 2,
		minsize = 2,
		maxsize = 4,
		collisiondetection = true,
		vertical = false,
		texture = texture.."^[colorize:"..color..":127",
	})
end

function mcl_potions.add_lingering_effect (pos, name, duration, level,
					   initial_radius)
	local def = mcl_potions.registered_effects[name]

	if not def then
	return
	end
	add_lingering_effects (pos, def.particle_color,
			   { [name] = { dur = duration,
					level = level, }, },
			   false, "mcl_particles_effect.png", duration,
			   nil, nil, nil, initial_radius)
	linger_particles (pos, initial_radius, "mcl_particles_effect.png",
			  def.particle_color or "#000000")
end

local function particle_texture (name, def)
	if name == "water" then
	return "mcl_particles_droplet_bottle.png"
	else
	if def.instant then
		return "mcl_particles_instant_effect.png"
	else
		return "mcl_particles_effect.png"
	end
	end
end

local lingering_timer = 0
core.register_globalstep(function(dtime)
	lingering_timer = lingering_timer + dtime
	if lingering_timer >= 1 then
		for pos, lists in pairs(lingering_effects_at) do
		local rem = 0
		for i, vals in ipairs (lists) do
			vals.timer = vals.timer - lingering_timer
			local d = (vals.initial_radius
				   * (vals.timer / vals.lifespan))
			local texture = vals.texture
			local deduct_time = false
			linger_particles(pos, d, texture, vals.color)

			-- Extinguish fire if water bottle
			if vals.is_water then
			if mcl_potions._water_effect (pos, d) then
				deduct_time = true
			end
			end

			-- Affect players and mobs
			for obj in core.objects_inside_radius(pos, d) do
				local entity = obj:get_luaentity()
				if obj:is_player() or entity and entity.is_mob then
					if vals.is_water then
						if entity and entity.water_damage then
							obj:punch (obj, 1.0, { full_punch_interval = 1.0,
									   damage_groups = {water_vulnerable=1}, },
								   nil)
							deduct_time = true
						end
					else
						for name, effect in pairs (vals.effects) do
							mcl_potions.give_effect_by_level (name, obj, effect.level,
											  effect.dur)
							deduct_time = true
						end
						if vals.custom_effect
							and vals.custom_effect (obj, vals.level,
										vals.plus) then
							deduct_time = true
						end
					end
				end
			end

			if deduct_time then
			vals.timer = vals.timer - 3.25
			end

			if vals.timer <= 0 then
			lists[i] = nil
			else
			rem = rem + 1
			end
		end

		-- Do no more extant entries exist?
		if rem == 0 then
			lingering_effects_at[pos] = nil
		end
		end
		lingering_timer = 0
	end
end)



function mcl_potions.register_lingering(name, descr, color, def)
	local id = def._id_override or "mcl_potions:"..name
	id = id.."_lingering"
	local longdesc = def._longdesc
	if not def.no_effect then
		longdesc = S("A throwable potion that will shatter on impact, where it creates a magic cloud that lingers around for a while. Any player or mob inside the cloud will receive the potion's effect or set of effects, possibly repeatedly.")
		if def.longdesc then
			longdesc = longdesc .. "\n" .. def._longdesc
		end
	end
	local groups = {brewitem=1, not_in_creative_inventory = 0,
			bottle=1, ling_potion=1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end

	local function on_use(item, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(item, placer, pointed_thing)
		if rc then return rc end

		local velocity = 12
		local dir = placer:get_look_dir();
		local pos = placer:get_pos();
		core.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
		local obj = core.add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
		obj:set_velocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
		obj:set_acceleration({x=dir.x*-3, y=-9.8, z=dir.z*-3})
		local ent = obj:get_luaentity()
		ent._thrower = placer:get_player_name()
		ent._potency = item:get_meta():get_int("mcl_potions:potion_potent")
		ent._plus = item:get_meta():get_int("mcl_potions:potion_plus")
		ent._effect_list = def._effect_list
		if not core.is_creative_enabled(placer:get_player_name()) then
			item:take_item()
		end
		return item
	end
	core.register_craftitem(":" .. id, {
		description = descr,
		_tt_help = def._tt,
		_dynamic_tt = def._dynamic_tt,
		_mcl_filter_description = mcl_potions.filter_potion_description,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = S("Use the “Place” key to throw it."),
		stack_max = def.stack_max,
		_effect_list = def._effect_list,
		uses_level = def.uses_level,
		has_potent = def.has_potent,
		has_plus = def.has_plus,
		_base_potion = def.base_potion,
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		inventory_image = lingering_image(color),
		groups = groups,
		on_secondary_use = on_use,
		on_place = on_use,
		_on_dispense = function(item, dispenserpos, _, _, dropdir)
			local s_pos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
			local pos = {x=s_pos.x+dropdir.x,y=s_pos.y+dropdir.y,z=s_pos.z+dropdir.z}
			core.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
			local obj = core.add_entity(pos, id.."_flying")
			if obj and obj:get_pos() then
				local velocity = 22
				obj:set_velocity({x=dropdir.x*velocity,y=dropdir.y*velocity,z=dropdir.z*velocity})
				obj:set_acceleration({x=dropdir.x*-3, y=-9.8, z=dropdir.z*-3})
				local ent = obj:get_luaentity()
				ent._potency = item:get_meta():get_int("mcl_potions:potion_potent")
				ent._plus = item:get_meta():get_int("mcl_potions:potion_plus")
				ent._effect_list = def._effect_list
			end
		end,
		_get_all_virtual_items = def._get_all_virtual_items
	})

	local w = 0.7

	core.register_entity(":"..id.."_flying",{
		initial_properties = {
			textures = {lingering_image(color)},
			hp_max = 1,
			visual_size = {x=w/2,y=w/2},
			collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
			pointable = false,
			physical = true,
			collide_with_objects = false,
		},
		on_step = function(self, dtime, moveresult)
			local pos = self.object:get_pos()
			local velocity = self.object:get_velocity ()
			local d, val = 4, mcl_potions.detect_hit (self.object,
								  pos,
								  moveresult,
								  velocity)
			if val then
				if val.target then
					mcl_target.hit (val.target)
				end
				core.sound_play("mcl_potions_breaking_glass",
						{pos = pos, max_hear_distance = 16, gain = 1})
				local potency = self._potency or 0
				local plus = self._plus or 0
				local effects = def_to_effect_list (def, potency, plus)
				local texture = particle_texture (name, def)

				add_lingering_effects (pos, color, effects, name == "water",
							   texture, 30, def.custom_effect, potency,
							   plus, d)
				linger_particles (pos, d, texture, color)
				if def.on_splash then def.on_splash (pos, potency+1) end
				self.object:remove()
			end
		end,
	})
end
