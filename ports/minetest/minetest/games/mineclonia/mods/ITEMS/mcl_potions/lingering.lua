local S = minetest.get_translator(minetest.get_current_modname())

local mod_target = minetest.get_modpath("mcl_target")

local function lingering_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_splash_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_lingering_bottle.png"
end

local lingering_effect_at = {}

local function add_lingering_effect(pos, color, def, is_water, instant)
	lingering_effect_at[pos] = {color = color, timer = 30, def = def, is_water = is_water}
end

local function linger_particles(pos, d, texture, color)
	minetest.add_particlespawner({
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

local lingering_timer = 0
minetest.register_globalstep(function(dtime)

	lingering_timer = lingering_timer + dtime
	if lingering_timer >= 1 then

		for pos, vals in pairs(lingering_effect_at) do

			vals.timer = vals.timer - lingering_timer
			local d = 4 * (vals.timer / 30.0)
			local texture
			if vals.is_water then
				texture = "mcl_particles_droplet_bottle.png"
			elseif vals.def.instant then
				texture = "mcl_particles_instant_effect.png"
			else
				texture = "mcl_particles_effect.png"
			end
			linger_particles(pos, d, texture, vals.color)

			-- Extinguish fire if water bottle
			if vals.is_water then
				if mcl_potions._extinguish_nearby_fire(pos, d) then
					vals.timer = vals.timer - 3.25
				end
			end

			-- Affect players and mobs
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, d)) do

				local entity = obj:get_luaentity()
				if obj:is_player() or entity.is_mob then

					vals.def.potion_fun(obj)
					-- TODO: Apply timer penalty only if the potion effect was acutally applied
					vals.timer = vals.timer - 3.25

				end
			end

			if vals.timer <= 0 then
				lingering_effect_at[pos] = nil
			end

		end
		lingering_timer = 0
	end
end)



function mcl_potions.register_lingering(name, descr, color, def)

	local id = "mcl_potions:"..name.."_lingering"
	local longdesc = def.longdesc
	if not def.no_effect then
		longdesc = S("A throwable potion that will shatter on impact, where it creates a magic cloud that lingers around for a while. Any player or mob inside the cloud will receive the potion's effect, possibly repeatedly.")
		if def.longdesc then
			longdesc = longdesc .. "\n" .. def.longdesc
		end
	end
	minetest.register_craftitem(id, {
		description = descr,
		_tt_help = def.tt,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = S("Use the “Punch” key to throw it."),
		inventory_image = lingering_image(color),
		groups = {brewitem=1, not_in_creative_inventory=0, potion = 1},
		on_use = function(item, placer, pointed_thing)
			local velocity = 10
			local dir = placer:get_look_dir();
			local pos = placer:getpos();
			minetest.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
			local obj = minetest.add_entity({x=pos.x+dir.x,y=pos.y+2+dir.y,z=pos.z+dir.z}, id.."_flying")
			obj:setvelocity({x=dir.x*velocity,y=dir.y*velocity,z=dir.z*velocity})
			obj:setacceleration({x=dir.x*-3, y=-9.8, z=dir.z*-3})
			obj:get_luaentity()._thrower = placer:get_player_name()
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				item:take_item()
			end
			return item
		end,
		stack_max = 1,
		_on_dispense = function(stack, dispenserpos, droppos, dropnode, dropdir)
			local s_pos = vector.add(dispenserpos, vector.multiply(dropdir, 0.51))
			local pos = {x=s_pos.x+dropdir.x,y=s_pos.y+dropdir.y,z=s_pos.z+dropdir.z}
			minetest.sound_play("mcl_throwing_throw", {pos = pos, gain = 0.4, max_hear_distance = 16}, true)
			local obj = minetest.add_entity(pos, id.."_flying")
			if obj and obj:get_pos() then
				local velocity = 22
				obj:set_velocity({x=dropdir.x*velocity,y=dropdir.y*velocity,z=dropdir.z*velocity})
				obj:set_acceleration({x=dropdir.x*-3, y=-9.8, z=dropdir.z*-3})
			end
		end
	})

	local w = 0.7

	minetest.register_entity(id.."_flying",{
		initial_properties = {
			textures = {lingering_image(color)},
			hp_max = 1,
			visual_size = {x=w/2,y=w/2},
			collisionbox = {-0.1,-0.1,-0.1,0.1,0.1,0.1},
			pointable = false,
		},
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			local node = minetest.get_node(pos)
			local n = node.name
			local g = minetest.get_item_group(n, "liquid")
			local d = 4
			if mod_target and n == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			if n ~= "air" and n ~= "mcl_portals:portal" and n ~= "mcl_portals:portal_end" and g == 0 or mcl_potions.is_obj_hit(self, pos) then
				minetest.sound_play("mcl_potions_breaking_glass", {pos = pos, max_hear_distance = 16, gain = 1})
				add_lingering_effect(pos, color, def, name == "water")
				local texture
				if name == "water" then
					texture = "mcl_particles_droplet_bottle.png"
				else
					if def.instant then
						texture = "mcl_particles_instant_effect.png"
					else
						texture = "mcl_particles_effect.png"
					end
				end
				linger_particles(pos, d, texture, color)
				if name == "water" then
					mcl_potions._extinguish_nearby_fire(pos, d)
				end
				self.object:remove()
			end
		end,
	})
end
