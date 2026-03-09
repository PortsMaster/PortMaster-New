mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "player" then
		local hitter = reason.direct
		if mcl_sprint.is_sprinting(hitter:get_player_name()) then
			obj:add_velocity(hitter:get_velocity())
		elseif (hitter:get_velocity() or hitter:get_player_velocity()).y < 0 and damage > 0 then
			local pos = mcl_util.get_object_center(obj)
			core.add_particlespawner({
				amount = 15,
				time = 0.1,
				minpos = {x=pos.x-0.5, y=pos.y-0.5, z=pos.z-0.5},
				maxpos = {x=pos.x+0.5, y=pos.y+0.5, z=pos.z+0.5},
				minvel = {x=-0.1, y=-0.1, z=-0.1},
				maxvel = {x=0.1, y=0.1, z=0.1},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 2,
				minsize = 1.5,
				maxsize = 1.5,
				collisiondetection = false,
				vertical = false,
				texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
			})
			core.sound_play("mcl_criticals_hit", {object = obj})
			-- the minecraft wiki is actually wrong about a crit dealing 150% damage, see minecraft source code
			return damage + math.random(0, math.floor(damage * 1.5 + 2))
		end
	end
end, -100)
