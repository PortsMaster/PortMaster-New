local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

-- Cooldown time and global storing of cooldown
local cooldown_time = 1
mcl_charges = {}
mcl_charges_cooldown = {}

--Wind Charge Particle effects
mcl_charges.wind_burst_spawner = {
	texture = "mcl_charges_wind_burst_1.png",
	texpool = {},
	amount = 6,
	time = 0.2,
	minvel = vector.zero(),
	maxvel = vector.zero(),
	minacc = vector.new(-0.2, 0.0, -0.2),
	maxacc = vector.new(0.2, 0.1, 0.2),
	minexptime = 0.95,
	maxexptime = 0.95,
	minsize = 12.0,
	maxsize= 18.0,
	glow = 100,
	collisiondetection = true,
	collision_removal = true,
}
for i=1,2 do
	table.insert(mcl_charges.wind_burst_spawner.texpool, {
		name = "mcl_charges_wind_burst_"..i..".png",
		animation={type="vertical_frames", aspect_w=8, aspect_h=8, length=1},
	})
end
-- Chorus flower destruction effects
function mcl_charges.chorus_flower_effects(pos, radius)
	core.add_particlespawner({
		amount = 10,
		time = 0.3,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = vector.new(-5, 0, -5),
		maxvel = vector.new(5, 3, 5),
		minacc = vector.new(0, -10, 0),
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 1.00,
		texpool = {"mcl_end_chorus_flower_1.png", "mcl_end_chorus_flower_2.png", "mcl_end_chorus_flower_3.png", "mcl_end_chorus_flower_4.png", "mcl_end_chorus_flower_5.png", "mcl_end_chorus_flower_6.png", "mcl_end_chorus_flower_7.png", "mcl_end_chorus_flower_8.png", "mcl_end_chorus_flower_9.png", "mcl_end_chorus_flower_10.png"},
		collisiondetection = true,
	})
end
-- decorated pot destruction effects
function mcl_charges.pot_effects(pos, radius)
	core.add_particlespawner({
		amount = 10,
		time = 0.3,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = vector.new(-5, 0, -5),
		maxvel = vector.new(5, 3, 5),
		minacc = vector.new(0, -10, 0),
		minexptime = 0.8,
		maxexptime = 2.0,
		minsize = radius * 0.66,
		maxsize = radius * 1.00,
		texpool = {"mcl_pottery_sherds_pot_1.png", "mcl_pottery_sherds_pot_2.png", "mcl_pottery_sherds_pot_3.png", "mcl_pottery_sherds_pot_4.png", "mcl_pottery_sherds_pot_5.png", "mcl_pottery_sherds_pot_6.png", "mcl_pottery_sherds_pot_7.png", "mcl_pottery_sherds_pot_8.png", "mcl_pottery_sherds_pot_9.png", "mcl_pottery_sherds_pot_10.png"},
		collisiondetection = true,
	})
end
-- knockback function
function mcl_charges.wind_burst_velocity(pos1, pos2, old_vel, power)
	if vector.equals(pos1, pos2) then
		return old_vel
	end

	local vel = vector.multiply(vector.normalize(vector.direction(pos1, pos2)), power)
	vel = vector.add(vel, old_vel)
	vel = vector.add(vel, {x = math.random() - 0.5, y = math.random() - 0.5, z = math.random() - 0.5})

	if vector.length(vel) > 250 then
		vel = vector.normalize(vel)
		vel = vector.multiply(vel, 250)
	end

	return vel
end

local RADIUS = 4

function mcl_charges.wind_burst(pos, radius)
	for obj in core.objects_inside_radius(pos, radius) do
		local obj_pos = obj:get_pos()
		local dist = math.max(1, vector.distance(pos, obj_pos))

		if obj:is_player() then
			obj:add_velocity(vector.multiply(vector.normalize(vector.subtract(obj_pos, pos)), mcl_util.float_random(1.8, 2.0) / dist * RADIUS))
		else
			local luaobj = obj:get_luaentity()
			if luaobj then
				local is_builtin_item = luaobj.name == "__builtin:item"
				if luaobj.is_mob or is_builtin_item then
					obj:set_velocity(mcl_charges.wind_burst_velocity(pos, obj_pos, obj:get_velocity(), radius * 3))
				end
			end
		end
	end
end

--throwable charge registry
function mcl_charges.register_charge(name, descr, def)
	core.register_craftitem("mcl_charges:" .. name, {
		description = descr,
		inventory_image = "mcl_charges_" .. name .. ".png",

		on_place = function(itemstack, placer, _)
			local playername = placer:get_player_name()
			if mcl_charges_cooldown[playername] == nil then
				mcl_charges_cooldown[playername] = 0
			end
			local current_time = core.get_gametime()
			if current_time - mcl_charges_cooldown[playername] >= cooldown_time then
				mcl_charges_cooldown[playername] = current_time
				local velocity = 30
				local dir = placer:get_look_dir()
				local playerpos = placer:get_pos()
				local obj = core.add_entity({
					x = playerpos.x + dir.x,
					y = playerpos.y + 1.3 + dir.y,
					z = playerpos.z + dir.z
				}, "mcl_charges:" .. name .. "_flying")
				local vec = {x = dir.x * velocity, y = dir.y * velocity, z = dir.z * velocity}
				local acc = {x = 0, y = 0, z = 0}
				obj:set_velocity(vec)
				obj:set_acceleration(acc)
				local ent = obj:get_luaentity() ; ent.posthrow = playerpos
				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end,
		on_secondary_use = function(itemstack, placer, _)
			local playername = placer:get_player_name()
			if mcl_charges_cooldown[playername] == nil then
				mcl_charges_cooldown[playername] = 0
			end
			local current_time = core.get_gametime()
			if current_time - mcl_charges_cooldown[playername] >= cooldown_time then
				mcl_charges_cooldown[playername] = current_time
				local velocity = 30
				local dir = placer:get_look_dir()
				local playerpos = placer:get_pos()
				local obj = core.add_entity({
					x = playerpos.x + dir.x,
					y = playerpos.y + 2 + dir.y,
					z = playerpos.z + dir.z
				}, "mcl_charges:" .. name .. "_flying")
				local vec = {x = dir.x * velocity, y = dir.y * velocity, z = dir.z * velocity}
				local acc = {x = 0, y = 0, z = 0}
				obj:set_velocity(vec)
				obj:set_acceleration(acc)
				local ent = obj:get_luaentity() ; ent.posthrow = playerpos
				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				return itemstack
			end
		end,
		_on_dispense = function(stack, pos, _, _, dropdir)
			local shootpos = vector.add(pos, vector.multiply(dropdir, 0.51))
			local charge = core.add_entity(shootpos, "mcl_charges:" .. name .. "_flying")
			if charge and charge:get_pos() then
				local ent_charge = charge:get_luaentity()
				ent_charge._shot_from_dispenser = true
				local v = ent_charge.velocity or 20
				charge:set_velocity(vector.multiply(dropdir, v))
				ent_charge.switch = 1
			end
			stack:take_item()
		end,
	})

	core.register_entity("mcl_charges:" .. name .. "_flying", {
		initial_properties = {
			visual = "mesh",
			mesh = name..".obj",
			visual_size = {x=2, y=1.5},
			textures = {"mcl_charges_" .. name .. "_entity.png"},
			hp_max = 20,
			collisionbox = {-0.1,-0.1,-0.1, 0.1,0.0,0.1},
			collide_with_objects = true,
		},
		hit_player = def.hit_player,
		hit_mob = def.hit_mob,
		on_activate = def.on_activate,
		on_step = function(self, _)
			local pos = self.object:get_pos()
			local node = core.get_node(pos)
			local n = node.name
			local dpos = vector.round(vector.new(pos)) -- digital pos
			if n ~= "air" then
				def.hit_node(self, pos, node)
				self.object:remove()
			end
			local bdef = core.registered_nodes[node.name]
			if (bdef and bdef._on_wind_charge_hit) then
				bdef._on_wind_charge_hit(dpos, self)
			end
			if self.hit_player or self.hit_mob or self.hit_object then
				for player in core.objects_inside_radius(pos, 0.6) do
					if self.hit_player and player:is_player() then
						self.hit_player(self, player)
						def.hit_player_alt(self, pos)
						core.after(0.01, function()
							if self.object:get_luaentity() then
								self.object:remove()
							end
						end)
						return
					end
					local entity = player:get_luaentity()
					if entity then
						if self.hit_mob	and entity.is_mob then
							self.hit_mob(self, player)
							def.hit_mob_alt(self, pos)
							self.object:remove()
							return
						end
						if self.hit_object and (not entity.is_mob) and tostring(player) ~= self.owner_id and entity.name ~= self.object:get_luaentity().name then
							self.hit_object(self, player)
							def.hit_player_alt(self, pos)
							self.object:remove()
							return
						end
					end
				end
			end
			self.lastpos = pos
		end,
	})
end

dofile(modpath.."/wind_charge.lua")
