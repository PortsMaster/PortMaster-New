mcl_fishing = {}
--Fishing Rod, Bobber, and Flying Bobber mechanics and Bobber artwork by Rootyjr.
local S = core.get_translator(core.get_current_modname())

mcl_fishing.loot_fish = {
	{ itemstring = "mcl_fishing:fish_raw", weight = 60 },
	{ itemstring = "mcl_fishing:salmon_raw", weight = 25 },
	{ itemstring = "mcl_fishing:clownfish_raw", weight = 2 },
	{ itemstring = "mcl_fishing:pufferfish_raw", weight = 13 },
}

mcl_fishing.loot_junk = {
	{ itemstring = "mcl_core:bowl", weight = 10 },
	{ itemstring = "mcl_fishing:fishing_rod", weight = 2, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
	{ itemstring = "mcl_mobitems:leather", weight = 10 },
	{ itemstring = "mcl_armor:boots_leather", weight = 10, wear_min = 6554, wear_max = 65535 }, -- 10%-100% damage
	{ itemstring = "mcl_mobitems:rotten_flesh", weight = 10 },
	{ itemstring = "mcl_core:stick", weight = 5 },
	{ itemstring = "mcl_mobitems:string", weight = 5 },
	{ itemstring = "mcl_potions:water", weight = 10 },
	{ itemstring = "mcl_mobitems:bone", weight = 10 },
	{ itemstring = "mcl_mobitems:ink_sac", weight = 1, amount_min = 10, amount_max = 10 },
	{ itemstring = "mcl_mobitems:string", weight = 10 }, -- TODO: Tripwire Hook
}

mcl_fishing.loot_treasure = {
	{ itemstring = "mcl_bows:bow", wear_min = 49144, wear_max = 65535, func = function(stack, pr)
		mcl_enchanting.enchant_randomly(stack, 30, true, false, false, pr)
	end }, -- 75%-100% damage
	{ itemstring = "mcl_books:book", func = function(stack, pr)
		mcl_enchanting.enchant_randomly(stack, 30, true, true, false, pr)
	end },
	{ itemstring = "mcl_fishing:fishing_rod", wear_min = 49144, wear_max = 65535, func = function(stack, pr)
		mcl_enchanting.enchant_randomly(stack, 30, true, false, false, pr)
	end }, -- 75%-100% damage
	{ itemstring = "mcl_mobitems:nametag", },
	{ itemstring = "mcl_mobitems:saddle", },
	{ itemstring = "mcl_flowers:waterlily", },
	{ itemstring = "mcl_mobitems:nautilus_shell", },
}

local bobbers = {}

local bobber_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_fishing_bobber.png"},
		visual_size = {x=0.5, y=0.5},
		collisionbox = {0.45,0.45,0.45,0.45,0.45,0.45},
		pointable = false,
		static_save = false,
	},
	timer=0,

	_lastpos={},
	_dive = false,
	_waittime = nil,
	_time = 0,
	player=nil,
	_oldy = nil,
	objtype="fishing",
}

local function remove_bobber(player, object)
	if player and bobbers[player] and bobbers[player].remove then
		local ent = bobbers[player]:get_luaentity()
		if ent and ent._reeling and ent._hooked and ent._hooked:get_pos() then
			ent._hooked:set_acceleration(vector.new(0, -mcl_item_entity.get_gravity(), 0))
		end
		bobbers[player]:remove()
		bobbers[player] = nil
		return
	end
	if object and object.remove then
		object:remove()
	end
end

local function fish(itemstack, player, pointed_thing)
	if pointed_thing and pointed_thing.type == "node" then
		-- Call on_rightclick if the pointed node defines it
		local rc = mcl_util.call_on_rightclick(itemstack, player, pointed_thing)
		if rc then return rc end
	end
	local pos = player:get_pos()

	local durability = 65
	local unbreaking = mcl_enchanting.get_enchantment(itemstack, "unbreaking")
	if unbreaking > 0 then
		durability = durability * (unbreaking + 1)
	end

	--Check for bobber if so handle.
	if bobbers[player] then
		local ent = bobbers[player]:get_luaentity()
		if not ent then
			remove_bobber(player)
			return
		end
		if ent._hooked and ent._hooked:get_pos() then
			local hent = ent._hooked:get_luaentity()
			if not ent._reeling and hent and hent._mcl_fishing_reelable then
				ent.timer = 0 --restart timer for reeling time limit
				ent._reeling = true
			else
				remove_bobber(player)
			end
			return
		end
		if ent and ent._dive == true then
			local items
			local pr = PcgRandom(os.time() * math.random(1, 100))
			local r = pr:next(1, 100)
			local fish_values = {85, 84.8, 84.7, 84.5}
			local junk_values = {10, 8.1, 6.1, 4.2}
			local luck_of_the_sea = math.min(mcl_enchanting.get_enchantment(itemstack, "luck_of_the_sea"), 3)
			local index = luck_of_the_sea + 1
			local fish_value = fish_values[index]
			local junk_value = junk_values[index] + fish_value
			if r <= fish_value then
				items = mcl_loot.get_loot({ items = mcl_fishing.loot_fish, stacks_min = 1, stacks_max = 1 }, pr)
				awards.unlock(player:get_player_name(), "mcl:fishyBusiness")
			elseif r <= junk_value then
				items = mcl_loot.get_loot({ items = mcl_fishing.loot_junk, stacks_min = 1, stacks_max = 1 }, pr)
			else
				items = mcl_loot.get_loot({ items = mcl_fishing.loot_treasure, stacks_min = 1, stacks_max = 1 }, pr)
			end
			local item
			if #items >= 1 then
				item = ItemStack(items[1])
			else
				item = ItemStack()
			end
			local inv = player:get_inventory()
			if inv:room_for_item("main", item) then
				inv:add_item("main", item)
				if item:get_name() == "mcl_mobitems:leather" then
					awards.unlock(player:get_player_name(), "mcl:killCow")
				end
			else
				core.add_item(pos, item)
			end

			mcl_experience.throw_xp(pos, math.random(1,6))

			if not core.is_creative_enabled(player:get_player_name()) then
				local idef = itemstack:get_definition()
				itemstack:add_wear(65535/durability) -- 65 uses
				if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
					core.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
				end
			end
		end
		--Check if object is on land.
		local epos = ent.object:get_pos()
		epos.y = math.floor(epos.y)
		local node = core.get_node(epos)
		local def = core.registered_nodes[node.name]
		if def and def.walkable then
			if not core.is_creative_enabled(player:get_player_name()) then
				local idef = itemstack:get_definition()
				itemstack:add_wear((65535/durability)*2) -- if so and not creative then wear double like in MC.
				if itemstack:get_count() == 0 and idef.sound and idef.sound.breaks then
					core.sound_play(idef.sound.breaks, {pos=player:get_pos(), gain=0.5}, true)
				end
			end
		end
		--Destroy bobber.
		remove_bobber(player)
		core.sound_play("reel", {object=player, gain=0.1, max_hear_distance=16}, true)
		return itemstack
	--If no bobber or flying_bobber exists then throw bobber.
	else
		local playerpos = player:get_pos()
		local dir = player:get_look_dir()
		bobbers[player] = mcl_throwing.throw("mcl_fishing:flying_bobber", vector.offset(playerpos, 0, 1.5, 0), dir, 15, player:get_player_name())
	end
end

function bobber_ENTITY:check_player()
	local player
	if self.player and self.player ~= "" then
		player = core.get_player_by_name(self.player)
		if player and player:get_pos() and vector.distance(player:get_pos(), self.object:get_pos()) <= 33 and
			core.get_item_group(player:get_wielded_item():get_name(), "fishing_rod") > 0 then
			return true
		end
	end
	remove_bobber(player, self.object)
end

-- Movement function of bobber
function bobber_ENTITY:on_step(dtime)
	self.timer=self.timer+dtime
	local epos = self.object:get_pos()
	epos.y = math.floor(epos.y)
	local node = core.get_node(epos)
	local def = core.registered_nodes[node.name]

	--If we have no player, remove self.
	if not self:check_player() then return end
	local player = core.get_player_by_name(self.player)

	if self._hooked and self._reeling then
		local dst = vector.distance(player:get_pos(), self.object:get_pos())
		if dst < 0.3 or self.timer > 10 then
			remove_bobber(player, self.object)
			return
		end
		self.object:add_velocity(vector.direction(self.object:get_pos(), player:get_pos()) * dst / 10)
	end

	-- If in water, then bob.
	if def and (def.liquidtype == "source" and core.get_item_group(def.name, "water") ~= 0) then
		if self._oldy == nil then
			self.object:set_pos({x=self.object:get_pos().x,y=math.floor(self.object:get_pos().y)+.5,z=self.object:get_pos().z})
			self._oldy = self.object:get_pos().y
			core.sound_play("watersplash", {pos=epos, gain=0.25}, true)
		end
		-- reset to original position after dive.
		if self.object:get_pos().y > self._oldy then
			self.object:set_pos({x=self.object:get_pos().x,y=self._oldy,z=self.object:get_pos().z})
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_acceleration({x=0,y=0,z=0})
		end
		if self._dive then
			for _ = 1, 2 do
					-- Spray bubbles when there's a fish.
					core.add_particle({
						pos = {x=epos["x"]+math.random(-1,1)*math.random()/2,y=epos["y"]+0.1,z=epos["z"]+math.random(-1,1)*math.random()/2},
						velocity = {x=0, y=4, z=0},
						acceleration = {x=0, y=-5, z=0},
						expirationtime = math.random() * 0.5,
						size = math.random(),
						collisiondetection = true,
						vertical = false,
						texture = "mcl_particles_bubble.png",
					})
			end
			if self._time < self._waittime then
				self._time = self._time + dtime
			else
				self._waittime = 0
				self._time = 0
				self._dive = false
			end
		elseif not self._waittime or self._waittime <= 0 then
			-- wait for random number of ticks.
			local lure_enchantment = mcl_enchanting.get_enchantment(player:get_wielded_item(), "lure") or 0
			local rain_mod = mcl_weather.rain.raining and mcl_weather.has_rain(self.object:get_pos()) and 0.75 or 1
			local reduced = lure_enchantment * 5
			self._waittime = math.random(math.max(0, 5 - reduced), 30 - reduced) * rain_mod
		else
			if self._time < self._waittime then
				self._time = self._time + dtime
			else
				-- wait time is over time to dive.
				core.sound_play("bloop", {pos=epos, gain=0.4}, true)
				self._dive = true
				self.object:set_velocity({x=0,y=-2,z=0})
				self.object:set_acceleration({x=0,y=5,z=0})
				self._waittime = 0.8
				self._time = 0
			end
		end
	end
end

core.register_entity("mcl_fishing:bobber_entity", bobber_ENTITY)

local flying_bobber_ENTITY={
	initial_properties = {
		physical = false,
		textures = {"mcl_fishing_bobber.png"}, --FIXME: Replace with correct texture.
		visual_size = {x=0.5, y=0.5},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
		static_save = false,
	},
	timer=0,

	_lastpos={},
	_thrower = nil,
	objtype="fishing",
}

-- Movement function of flying bobber
local function flying_bobber_on_step(self, dtime)
	if not self._thrower then
		self.object:remove()
		return
	end
	self.timer=self.timer+dtime
	local pos = self.object:get_pos()
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	local player = core.get_player_by_name(self._thrower)

	if not player or not player:get_pos() or vector.distance(player:get_pos(), self.object:get_pos()) > 33 then
		remove_bobber(player, self.object)
		return
	end

	for obj in core.objects_inside_radius(pos, 0.4) do
		local ent = obj:get_luaentity()
		if ent and ent._mcl_fishing_hookable then
			bobbers[player] = core.add_entity(ent.object:get_pos(), "mcl_fishing:bobber_entity")
			ent.object:set_attach(bobbers[player])
			local bent = bobbers[player]:get_luaentity()
			if bent then
				bent.player = self._thrower
				bent._hooked = ent.object
				self.object:remove()
				return
			end
		end
	end

	-- Destroy when hitting a solid node
	if self._lastpos.x~=nil then
		if (def and (def.walkable or def.liquidtype == "flowing" or def.liquidtype == "source")) or not def then
			if core.get_item_group(node.name, "water") > 0 then
				bobbers[player] = core.add_entity(self._lastpos, "mcl_fishing:bobber_entity")
				local ent = bobbers[player]:get_luaentity()
				if ent then
					ent.player = self._thrower
					self.object:remove()
					return
				end
			end
			remove_bobber(player, self.object)
		end
	end
	self._lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Node will be added at last pos outside the node
end

flying_bobber_ENTITY.on_step = flying_bobber_on_step

core.register_entity("mcl_fishing:flying_bobber_entity", flying_bobber_ENTITY)

mcl_throwing.register_throwable_object("mcl_fishing:flying_bobber", "mcl_fishing:flying_bobber_entity", 5)

core.register_on_dieplayer(function(player) remove_bobber(player) end)
core.register_on_leaveplayer(function(player) remove_bobber(player) end)

-- Fishing Rod
core.register_tool("mcl_fishing:fishing_rod", {
	description = S("Fishing Rod"),
	_tt_help = S("Catches fish in water"),
	_doc_items_longdesc = S("Fishing rods can be used to catch fish."),
	_doc_items_usagehelp = S("Rightclick to launch the bobber. When it sinks right-click again to reel in an item. Who knows what you're going to catch?"),
	groups = { tool = 2, fishing_rod = 1, enchantability = 1, offhand_item = 1 },
	inventory_image = "mcl_fishing_fishing_rod.png",
	wield_image = "mcl_fishing_fishing_rod.png^[transformFY^[transformR90",
	wield_scale = { x = 1.5, y = 1.5, z = 1 },
	stack_max = 1,
	on_place = fish,
	on_secondary_use = fish,
	sound = { breaks = "default_tool_breaks" },
	_mcl_uses = 65,
	_mcl_toollike_wield = true,
	_mcl_burntime = 15
})

dofile(core.get_modpath(core.get_current_modname()).."/items.lua")
