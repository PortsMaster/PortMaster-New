local S = core.get_translator(core.get_current_modname())
local GRAVITY = tonumber(core.settings:get("movement_gravity"))

local function splash_image(colorstring)
	return "mcl_potions_splash_overlay.png^[multiply:"..colorstring.."^mcl_potions_splash_bottle.png"
end


function mcl_potions.register_splash(name, descr, color, def)
	local id = def._id_override or "mcl_potions:"..name
	id = id.."_splash"
	local longdesc = def._longdesc
	if not def.no_effect then
		longdesc = S("A throwable potion that will shatter on impact, where it gives all nearby players and mobs a status effect or a set of status effects.")
		if def._longdesc then
			longdesc = longdesc .. "\n" .. def._longdesc
		end
	end
	local groups = {brewitem=1, not_in_creative_inventory=0,
			bottle=1, splash_potion=1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end

	local function on_use(item, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(item, placer, pointed_thing)
		if rc then return rc end

		local dir = placer:get_look_dir()
		local pos = placer:get_pos()
		local potency = item:get_meta():get_int("mcl_potions:potion_potent")
		local plus = item:get_meta():get_int("mcl_potions:potion_plus")
		local name = placer:get_player_name()
		pos.y = pos.y + placer:get_properties().eye_height
		mcl_potions.throw_splash(id, dir, pos, name, potency, plus)
		if not core.is_creative_enabled(name) then
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
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		_base_potion = def.base_potion,
		inventory_image = splash_image(color),
		groups = groups,
		on_place = on_use,
		on_secondary_use = on_use,
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

	core.register_entity(":" ..id.."_flying",{
		initial_properties = {
			textures = {splash_image(color)},
			hp_max = 1,
			visual_size = {x=w/2,y=w/2},
			collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
			pointable = false,
			physical = true,
			collide_with_objects = false,
		},
		on_step = function(self, dtime, moveresult)
			local pos = self.object:get_pos()
			local d = 0.1
			local redux_map = {7/8,0.5,0.25}
			local velocity = self.object:get_velocity ()
			local val = mcl_potions.detect_hit (self.object,
								pos,
								moveresult,
								velocity)

			if val then
				if val.target then
					mcl_target.hit (val.target)
				end
				core.sound_play("mcl_potions_breaking_glass",
						{pos = pos, max_hear_distance = 16, gain = 1})
				local texture, acc
				if name == "water" then
				texture = "mcl_particles_droplet_bottle.png"
				acc = {x=0, y=-GRAVITY, z=0}
				else
				if def.instant then
					texture = "mcl_particles_instant_effect.png"
				else
					texture = "mcl_particles_effect.png"
				end
				acc = {x=0, y=0, z=0}
				end
				core.add_particlespawner({
					amount = 50,
					time = 0.1,
					minpos = {x=pos.x-d, y=pos.y, z=pos.z-d},
					maxpos = {x=pos.x+d, y=pos.y+d, z=pos.z+d},
					minvel = {x=-2, y=0, z=-2},
					maxvel = {x=2, y=2, z=2},
					minacc = acc,
					maxacc = acc,
					minexptime = 0.5,
					maxexptime = 1.25,
					minsize = 1,
					maxsize = 2,
					collisiondetection = true,
					vertical = false,
					texture = texture.."^[colorize:"..color..":127"
				})

				local potency = self._potency or 0
				local plus = self._plus or 0

				if def.on_splash then def.on_splash(pos, potency+1) end
				for obj in core.objects_inside_radius(pos, 4) do

					local entity = obj:get_luaentity()
					if obj:is_player() or entity and entity.is_mob then

						local pos2 = obj:get_pos()
						local rad = math.floor(math.sqrt((pos2.x-pos.x)^2 + (pos2.y-pos.y)^2 + (pos2.z-pos.z)^2))

						if def._effect_list then
							local ef_level
							local dur
							for name, details in pairs(def._effect_list) do
								ef_level = mcl_potions.level_from_details (details, potency)
								dur = mcl_potions.duration_from_details (details, potency, plus)
								if rad > 0 then
									mcl_potions.give_effect_by_level(name, obj, ef_level, redux_map[rad]*dur)
								else
									mcl_potions.give_effect_by_level(name, obj, ef_level, dur)
								end
							end
						end

						if def.custom_effect then
							local power = potency + 1
							local thrower = self._thrower
							if type (thrower) == "string" then
								thrower = core.get_player_by_name (thrower)
							end
							if rad > 0 then
								def.custom_effect (obj, redux_map[rad] * power, plus, thrower)
							else
								def.custom_effect (obj, power, plus, thrower)
							end
						end
					end
				end
				self.object:remove()
			end
		end,
	})
end

-- `thrower' may be an ObjectRef but must be a player name if it is a
-- player and is to be serialized properly.
function mcl_potions.throw_splash (potionname, dir, pos, thrower,
				   potency, plus)
	if not core.registered_items[potionname] then
	core.log ("action", "Throwing nonexistent potion " .. potionname)
	return
	end
	local obj
	= core.add_entity ({x=pos.x+dir.x,y=pos.y+dir.y,z=pos.z+dir.z},
						   potionname .. "_flying")
	if not obj then
	return
	end
	local velocity = 12
	obj:set_velocity ({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
	obj:set_acceleration ({x=dir.x*-3, y=-9.8, z=dir.z*-3})
	local ent = obj:get_luaentity ()
	ent._thrower = thrower
	ent._potency = potency
	ent._plus = plus
	ent._effect_list = core.registered_items[potionname]._effect_list
	core.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
end
