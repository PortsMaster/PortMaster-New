local S = minetest.get_translator(minetest.get_current_modname())

local mod_target = minetest.get_modpath("mcl_target")

-- The snowball entity
local snowball_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_throwing_snowball.png"},
		visual_size = {x=0.5, y=0.5},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},

	timer=0,
	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
	_thrower = nil,

	_lastpos={},
}

local egg_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_throwing_egg.png"},
		visual_size = {x=0.45, y=0.45},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},
	timer=0,
	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,
	_thrower = nil,

	_lastpos={},
}

-- Ender pearl entity
local pearl_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_throwing_ender_pearl.png"},
		visual_size = {x=0.9, y=0.9},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},

	timer=0,
	get_staticdata = mcl_throwing.get_staticdata,
	on_activate = mcl_throwing.on_activate,

	_lastpos={},
	_thrower = nil,		-- Player ObjectRef of the player who threw the ender pearl
}

local function check_object_hit(self, pos, dmg)
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do

		local entity = object:get_luaentity()

		if entity
		and entity.name ~= self.object:get_luaentity().name then

			if object:is_player() and self._thrower ~= object:get_player_name() then
				self.object:remove()
				return true
			elseif (entity.is_mob == true or entity._hittable_by_projectile) and (self._thrower ~= object) then
				object:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = dmg,
				}, nil)
				return true
			end
		end
	end
	return false
end

local function snowball_particles(pos, vel)
	local vel = vector.normalize(vector.multiply(vel, -1))
	minetest.add_particlespawner({
		amount = 20,
		time = 0.001,
		minpos = pos,
		maxpos = pos,
		minvel = vector.add({x=-2, y=3, z=-2}, vel),
		maxvel = vector.add({x=2, y=5, z=2}, vel),
		minacc = {x=0, y=-9.81, z=0},
		maxacc = {x=0, y=-9.81, z=0},
		minexptime = 1,
		maxexptime = 3,
		minsize = 0.7,
		maxsize = 0.7,
		collisiondetection = true,
		collision_removal = true,
		object_collision = false,
		texture = "weather_pack_snow_snowflake"..math.random(1,2)..".png",
	})
end

-- Snowball on_step()--> called when snowball is moving.
local function snowball_on_step(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		if (def and def.walkable) or not def then
			minetest.sound_play("mcl_throwing_snowball_impact_hard", { pos = pos, max_hear_distance=16, gain=0.7 }, true)
			snowball_particles(self._lastpos, vel)
			self.object:remove()
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			return
		end
	end
	if check_object_hit(self, pos, {snowball_vulnerable = 3}) then
		minetest.sound_play("mcl_throwing_snowball_impact_soft", { pos = pos, max_hear_distance=16, gain=0.7 }, true)
		snowball_particles(pos, vel)
		self.object:remove()
		return
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set _lastpos-->Node will be added at last pos outside the node
end

-- Movement function of egg
local function egg_on_step(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node with chance to spawn chicks
	if self._lastpos.x then
		if (def and def.walkable) or not def then
			-- 1/8 chance to spawn a chick
			-- FIXME: Chicks have a quite good chance to spawn in walls
			local r = math.random(1,8)

			if r == 1 then
				mcl_mobs.spawn_child(self._lastpos, "mobs_mc:chicken")

				-- BONUS ROUND: 1/32 chance to spawn 3 additional chicks
				local r = math.random(1,32)
				if r == 1 then
					local offsets = {
						{ x=0.7, y=0, z=0 },
						{ x=-0.7, y=0, z=-0.7 },
						{ x=-0.7, y=0, z=0.7 },
					}
					for o=1, 3 do
						local pos = vector.add(self._lastpos, offsets[o])
						mcl_mobs.spawn_child(pos, "mobs_mc:chicken")
					end
				end
			end
			minetest.sound_play("mcl_throwing_egg_impact", { pos = self.object:get_pos(), max_hear_distance=10, gain=0.5 }, true)
			self.object:remove()
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			return
		end
	end

	-- Destroy when hitting a mob or player (no chick spawning)
	if check_object_hit(self, pos, 0) then
		minetest.sound_play("mcl_throwing_egg_impact", { pos = self.object:get_pos(), max_hear_distance=10, gain=0.5 }, true)
		self.object:remove()
		return
	end

	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

-- Movement function of ender pearl
local function pearl_on_step(self, dtime)
	self.timer = self.timer + dtime
	local pos = self.object:get_pos()
	pos.y = math.floor(pos.y)
	local node = minetest.get_node(pos)
	local nn = node.name
	local def = minetest.registered_nodes[node.name]

	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		local walkable = (def and def.walkable)

		-- No teleport for hitting ignore for now. Otherwise the player could get stuck.
		-- FIXME: This also means the player loses an ender pearl for throwing into unloaded areas
		if node.name == "ignore" then
			self.object:remove()
		-- Activate when hitting a solid node or a plant
		elseif walkable or nn == "mcl_core:vine" or nn == "mcl_core:deadbush" or minetest.get_item_group(nn, "flower") ~= 0 or minetest.get_item_group(nn, "sapling") ~= 0 or minetest.get_item_group(nn, "plant") ~= 0 or minetest.get_item_group(nn, "mushroom") ~= 0 or not def then
			local player = self._thrower and minetest.get_player_by_name(self._thrower)
			if player then
				-- Teleport and hurt player

				-- First determine good teleport position
				local dir = {x=0, y=0, z=0}

				local v = self.object:get_velocity()
				if walkable then
					local vc = table.copy(v) -- vector for calculating
					-- Node is walkable, we have to find a place somewhere outside of that node
					vc = vector.normalize(vc)

					-- Zero-out the two axes with a lower absolute value than
					-- the axis with the strongest force
					local lv, ld
					lv, ld = math.abs(vc.y), "y"
					if math.abs(vc.x) > lv then
						lv, ld = math.abs(vc.x), "x"
					end
					if math.abs(vc.z) > lv then
						ld = "z" --math.abs(vc.z)
					end
					if ld ~= "x" then vc.x = 0 end
					if ld ~= "y" then vc.y = 0 end
					if ld ~= "z" then vc.z = 0 end

					-- Final tweaks to the teleporting pos, based on direction
					-- Impact from the side
					dir.x = vc.x * -1
					dir.z = vc.z * -1

					-- Special case: top or bottom of node
					if vc.y > 0 then
						-- We need more space when impact is from below
						dir.y = -2.3
					elseif vc.y < 0 then
						-- Standing on top
						dir.y = 0.5
					end
				end
				-- If node was not walkable, no modification to pos is made.

				-- Final teleportation position
				local telepos = vector.add(pos, dir)
				local telenode = minetest.get_node(telepos)

				--[[ It may be possible that telepos is walkable due to the algorithm.
				Especially when the ender pearl is faster horizontally than vertical.
				This applies final fixing, just to be sure we're not in a walkable node ]]
				if not minetest.registered_nodes[telenode.name] or minetest.registered_nodes[telenode.name].walkable then
					if v.y < 0 then
						telepos.y = telepos.y + 0.5
					else
						telepos.y = telepos.y - 2.3
					end
				end

				local oldpos = player:get_pos()
				-- Teleport and hurt player
				player:set_pos(telepos)
				player:set_hp(player:get_hp() - 5, { type = "fall", from = "mod" })

				-- 10% chance to spawn endermite at the player's origin
				local r = math.random(1,10)
				if r == 1 then
					minetest.add_entity(oldpos, "mobs_mc:endermite")
				end

			end
			self.object:remove()
			if mod_target and node.name == "mcl_target:target_off" then
				mcl_target.hit(vector.round(pos), 0.4) --4 redstone ticks
			end
			return
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

snowball_ENTITY.on_step = snowball_on_step
egg_ENTITY.on_step = egg_on_step
pearl_ENTITY.on_step = pearl_on_step

minetest.register_entity("mcl_throwing:snowball_entity", snowball_ENTITY)
minetest.register_entity("mcl_throwing:egg_entity", egg_ENTITY)
minetest.register_entity("mcl_throwing:ender_pearl_entity", pearl_ENTITY)


local how_to_throw = S("Use the punch key to throw.")

-- Snowball
minetest.register_craftitem("mcl_throwing:snowball", {
	description = S("Snowball"),
	_tt_help = S("Throwable"),
	_doc_items_longdesc = S("Snowballs can be thrown or launched from a dispenser for fun. Hitting something with a snowball does nothing."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_snowball.png",
	stack_max = 16,
	groups = { weapon_ranged = 1 },
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:snowball_entity"),
	_on_dispense = mcl_throwing.dispense_function,
})

-- Egg
minetest.register_craftitem("mcl_throwing:egg", {
	description = S("Egg"),
	_tt_help = S("Throwable").."\n"..S("Chance to hatch chicks when broken"),
	_doc_items_longdesc = S("Eggs can be thrown or launched from a dispenser and breaks on impact. There is a small chance that 1 or even 4 chicks will pop out of the egg."),
	_doc_items_usagehelp = how_to_throw,
	inventory_image = "mcl_throwing_egg.png",
	stack_max = 16,
	on_use = mcl_throwing.get_player_throw_function("mcl_throwing:egg_entity"),
	_on_dispense = mcl_throwing.dispense_function,
	_dispense_into_walkable = true,
	groups = { craftitem = 1 },
})

-- Ender Pearl
minetest.register_craftitem("mcl_throwing:ender_pearl", {
	description = S("Ender Pearl"),
	_tt_help = S("Throwable").."\n"..minetest.colorize(mcl_colors.YELLOW, S("Teleports you on impact for cost of 5 HP")),
	_doc_items_longdesc = S("An ender pearl is an item which can be used for teleportation at the cost of health. It can be thrown and teleport the thrower to its impact location when it hits a solid block or a plant. Each teleportation hurts the user by 5 hit points."),
	_doc_items_usagehelp =  S("Use the place/use key to throw."),
	wield_image = "mcl_throwing_ender_pearl.png",
	inventory_image = "mcl_throwing_ender_pearl.png",
	stack_max = 16,
	on_place = mcl_throwing.get_player_throw_function("mcl_throwing:ender_pearl_entity"),
	on_secondary_use = mcl_throwing.get_player_throw_function("mcl_throwing:ender_pearl_entity"),
	groups = { transport = 1 },
})

mcl_throwing.register_throwable_object("mcl_throwing:snowball", "mcl_throwing:snowball_entity", 22)
mcl_throwing.register_throwable_object("mcl_throwing:egg", "mcl_throwing:egg_entity", 22)
mcl_throwing.register_throwable_object("mcl_throwing:ender_pearl", "mcl_throwing:ender_pearl_entity", 22)
