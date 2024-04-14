-- Eye of Ender
local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_entity("mcl_end:ender_eye", {
	initial_properties = {
		physical = false,
		textures = {"mcl_end_ender_eye.png"},
		visual_size = {x=1.5, y=1.5},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},

	-- Save and restore age
	get_staticdata = function(self)
		return tostring(self._age)
	end,
	on_activate = function(self, staticdata, dtime_s)
		local age = tonumber(staticdata)
		if type(age) == "number" then
			self._age = age
			if self._age >= 2 then
				self._phase = 1
			else
				self._phase = 0
			end
		end
	end,

	on_step = function(self, dtime)
		self._age = self._age + dtime
		if self._age >= 3 then
			-- End of life
			local r = math.random(1,5)
			if r == 1 then
				-- 20% chance to get destroyed completely.
				-- 100% if in Creative Mode
				self.object:remove()
				return
			else
				-- 80% to drop as an item
				local pos = self.object:get_pos()
				local v = self.object:get_velocity()
				self.object:remove()
				local item = minetest.add_item(pos, "mcl_end:ender_eye")
				item:set_velocity(v)
				return
			end
		elseif self._age >= 2 then
			if self._phase == 0 then
				self._phase = 1
				-- Stop the eye and wait for another second.
				-- The vertical speed changes are just eye candy.
				self.object:set_acceleration({x=0, y=-3, z=0})
				self.object:set_velocity({x=0, y=self.object:get_velocity().y*0.2, z=0})
			end
		else
			-- Fly normally and generate particles
			local pos = self.object:get_pos()
			pos.x = pos.x + math.random(-1, 1)*0.5
			pos.y = pos.y + math.random(-1, 0)*0.5
			pos.z = pos.z + math.random(-1, 1)*0.5
			minetest.add_particle({
				pos = pos,
				texture = "mcl_particles_teleport.png",
				expirationtime = 1,
				velocity = {x=math.random(-1, 1)*0.1, y=math.random(-30, 0)*0.1, z=math.random(-1, 1)*0.1},
				acceleration = {x=0, y=0, z=0},
				size = 2.5,
			})
		end
	end,

	_age = 0, -- age in seconds
	_phase = 0, -- phase 0: flying. phase 1: idling in mid air, about to drop or shatter
})

-- Throw eye of ender to make it fly to the closest stronghold
local function throw_eye(itemstack, user, pointed_thing)
	if user == nil then return end
	local origin = user:get_pos()
	origin.y = origin.y + 1.5
	local strongholds = mcl_structures.registered_structures["end_shrine"].static_pos
	local dim = mcl_worlds.pos_to_dimension(origin)
	local is_creative = minetest.is_creative_enabled(user:get_player_name())

	-- Just drop the eye of ender if there are no strongholds
	if #strongholds <= 0 or dim ~= "overworld" then
		if not is_creative then
			minetest.item_drop(ItemStack("mcl_end:ender_eye"), user, user:get_pos())
			itemstack:take_item()
		end
		return itemstack
	end

	-- Find closest stronghold.
	-- Note: Only the horizontal axes are taken into account.
	local closest_stronghold
	local lowest_dist
	for s=1, #strongholds do
		local h_pos = table.copy(strongholds[s])
		local h_origin = table.copy(origin)
		h_pos.y = 0
		h_origin.y = 0
		local dist = vector.distance(h_origin, h_pos)
		if not closest_stronghold then
			closest_stronghold = strongholds[s]
			lowest_dist = dist
		else
			if dist < lowest_dist then
				closest_stronghold = strongholds[s]
				lowest_dist = dist
			end
		end
	end

	-- Throw it!
	local obj = minetest.add_entity(origin, "mcl_end:ender_eye")
	if not obj or not obj:get_pos() then return end
	local dir

	if lowest_dist <= 25 then
		local velocity = 4
		-- Stronghold is close: Fly directly to stronghold and take Y into account.
		dir = vector.normalize(vector.direction(origin, closest_stronghold))
		obj:set_velocity({x=dir.x*velocity, y=dir.y*velocity, z=dir.z*velocity})
	else
		local velocity = 12
		-- Don't care about Y if stronghold is still far away.
		-- Fly to direction of X/Z, and always upwards so it can be seen easily.
		local o = {x=origin.x, y=0, z=origin.z}
		local s = {x=closest_stronghold.x, y=0, z=closest_stronghold.z}
		dir = vector.normalize(vector.direction(o, s))
		obj:set_acceleration({x=dir.x*-3, y=4, z=dir.z*-3})
		obj:set_velocity({x=dir.x*velocity, y=3, z=dir.z*velocity})
	end


	if not is_creative then
		itemstack:take_item()
	end
	return itemstack
end

minetest.register_craftitem("mcl_end:ender_eye", {
	description = S("Eye of Ender"),
	_tt_help = S("Guides the way to the mysterious End dimension"),
	_doc_items_longdesc = S("This item is used to locate End portal shrines in the Overworld and to activate End portals.") .. "\n" .. S("NOTE: The End dimension is currently incomplete and might change in future versions."),
	_doc_items_usagehelp = S("Use the attack key to release the eye of ender. It will rise and fly in the horizontal direction of the closest end portal shrine. If you're very close, the eye of ender will take the direct path to the End portal shrine instead. After a few seconds, it stops. It may drop as an item, but there's a 20% chance it shatters.") .. "\n" .. S("To activate an End portal, eyes of ender need to be placed into each block of an intact End portal frame."),
	wield_image = "mcl_end_ender_eye.png",
	inventory_image = "mcl_end_ender_eye.png",
	on_place = throw_eye,
	on_secondary_use = throw_eye,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_end:ender_eye",
	recipe = {"mcl_mobitems:blaze_powder", "mcl_throwing:ender_pearl"},
})
