mcl_boats = {}
local S = minetest.get_translator(minetest.get_current_modname())

local boat_visual_size = {x = 1, y = 1, z = 1}
local paddling_speed = 22
local boat_y_offset = 0.35
local boat_y_offset_ground = boat_y_offset + 0.6
local boat_side_offset = 1.001
local boat_max_hp = 4

local function is_group(pos, group)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, group) ~= 0
end

local function is_river_water(p)
	local n = minetest.get_node(p).name
	if n == "mclx_core:river_water_source" or n == "mclx_core:river_water_flowing" then
		return true
	end
end

local function is_ice(pos)
	return is_group(pos, "ice")
end

local function is_fire(pos)
	return is_group(pos, "set_on_fire")
end

local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local function check_object(obj)
	return obj and (obj:is_player() or obj:get_luaentity()) and obj
end

local function get_visual_size(obj)
	return obj:is_player() and {x = 1, y = 1, z = 1} or obj:get_luaentity()._old_visual_size or obj:get_properties().visual_size
end

local function set_attach(boat)
	boat._driver:set_attach(boat.object, "",
		{x = 0, y = 1.5, z = 1}, {x = 0, y = 0, z = 0})
end

local function set_double_attach(boat)
	boat._driver:set_attach(boat.object, "",
		{x = 0, y = 0.42, z = 0.8}, {x = 0, y = 0, z = 0})
	if boat._passenger:is_player() then
		boat._passenger:set_attach(boat.object, "",
			{x = 0, y = 0.42, z = -6.2}, {x = 0, y = 0, z = 0})
	else
		boat._passenger:set_attach(boat.object, "",
			{x = 0, y = 0.42, z = -4.5}, {x = 0, y = 270, z = 0})
	end
end
local function set_choat_attach(boat)
	boat._driver:set_attach(boat.object, "",
		{x = 0, y = 1.5, z = 1}, {x = 0, y = 0, z = 0})
end

local function attach_object(self, obj)
	if self._driver and not self._inv_id then
		if self._driver:is_player() then
			self._passenger = obj
		else
			self._passenger = self._driver
			self._driver = obj
		end
		set_double_attach(self)
	else
		self._driver = obj
		if self._inv_id then
			set_choat_attach(self)
		else
			set_attach(self)
		end
	end

	local visual_size = get_visual_size(obj)
	local yaw = self.object:get_yaw()
	obj:set_properties({visual_size = vector.divide(visual_size, boat_visual_size)})

	if obj:is_player() then
		local name = obj:get_player_name()
		mcl_player.players[obj].attached = true
		minetest.after(0.2, function(name)
			local player = minetest.get_player_by_name(name)
			if player then
				mcl_player.player_set_animation(player, "sit" , 30)
			end
		end, name)
		obj:set_look_horizontal(yaw)
		mcl_title.set(obj, "actionbar", {text=S("Sneak to dismount"), color="white", stay=60})
	else
		obj:get_luaentity()._old_visual_size = visual_size
	end
end

local function detach_object(obj, change_pos)
	if not obj or not obj:get_pos() then return end
	obj:set_detach()
	obj:set_properties({visual_size = get_visual_size(obj)})
	if obj:is_player() then
		mcl_player.players[obj].attached = nil
		mcl_player.player_set_animation(obj, "stand" , 30)
	else
		obj:get_luaentity()._old_visual_size = nil
	end
	if change_pos then
		 obj:set_pos(vector.add(obj:get_pos(), vector.new(0, 0.2, 0)))
	end
end

--
-- Boat entity
--

local boat = {
	initial_properties = {
		physical = true,
		pointable = true,
		-- Warning: Do not change the position of the collisionbox top surface,
		-- lowering it causes the boat to fall through the world if underwater
		collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.55, 0.5},
		selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.55, 0.7},
		visual = "mesh",
		mesh = "mcl_boats_boat.b3d",
		textures = { "mcl_boats_texture_oak_boat.png", "blank.png" },
		visual_size = boat_visual_size,
		hp_max = boat_max_hp,
		damage_texture_modifier = "^[colorize:white:0",
	},

	_driver = nil, -- Attached driver (player) or nil if none
	_passenger = nil,
	_v = 0, -- Speed
	_last_v = 0, -- Temporary speed variable
	_removed = false, -- If true, boat entity is considered removed (e.g. after punch) and should be ignored
	_itemstring = "mcl_boats:boat", -- Itemstring of the boat item (implies boat type)
	_animation = 0, -- 0: not animated; 1: paddling forwards; -1: paddling backwards
	_regen_timer = 0,
	_damage_anim = 0,
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	on_detach_child = function(self, child)
		if self._driver and minetest.is_player(child) and minetest.is_player(self._driver) and self._driver == child then
			self._driver = nil
		end
	end,
}

minetest.register_on_respawnplayer(detach_object)

function boat.on_rightclick(self, clicker)
	if self._passenger or not clicker or clicker:get_attach() or (self.name == "mcl_boats:chest_boat" and self._driver) then
		return
	end
	attach_object(self, clicker)
end


function boat.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({fleshy = 125})
	local data = minetest.deserialize(staticdata)
	if type(data) == "table" then
		self._v = data.v
		self._last_v = self._v
		self._itemstring = data.itemstring

		-- Update the texutes for existing old boat entity instances.
		-- Maybe remove this in the future.
		if #data.textures >= 1 and data.textures[1] == "mcl_boats_texture_cherry_boat.png" then
			data.textures[1] = "mcl_boats_texture_cherry_blossom_boat.png"
		end
		if #data.textures ~= 2 then
			local has_chest = self._itemstring:find("chest")
			data.textures = {
				data.textures[1]:gsub("_chest", ""),
				has_chest and "mcl_chests_normal.png" or "blank.png"
			}
		end

		self.object:set_properties({textures = data.textures})
	end
end

function boat.get_staticdata(self)
	return minetest.serialize({
		v = self._v,
		itemstring = self._itemstring,
		textures = self.object:get_properties().textures
	})
end

function boat.on_death(self, killer)
	mcl_burning.extinguish(self.object)

	if killer and killer:is_player() and minetest.is_creative_enabled(killer:get_player_name()) then
		local inv = killer:get_inventory()
		if not inv:contains_item("main", self._itemstring) then
			inv:add_item("main", self._itemstring)
		end
	else
		minetest.add_item(self.object:get_pos(), self._itemstring)
	end
	if self._driver then
		detach_object(self._driver)
	end
	if self._passenger then
		detach_object(self._passenger)
	end
	self._driver = nil
	self._passenger = nil
end

function boat.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
	if damage > 0 then
		self._regen_timer = 0
	end
end

function boat.on_step(self, dtime, moveresult)
	mcl_burning.tick(self.object, dtime, self)
	-- mcl_burning.tick may remove object immediately
	if not self.object:get_pos() then return end

	self._v = get_v(self.object:get_velocity()) * get_sign(self._v)
	local v_factor = 1
	local v_slowdown = 0.02
	local p = self.object:get_pos()
	local on_water = true
	local on_ice = false
	local in_water = flowlib.is_water({x=p.x, y=p.y-boat_y_offset+1, z=p.z})
	local in_river_water = is_river_water({x=p.x, y=p.y-boat_y_offset+1, z=p.z})
	local waterp = {x=p.x, y=p.y-boat_y_offset - 0.1, z=p.z}
	if not flowlib.is_water(waterp) then
		on_water = false
		if not in_water and is_ice(waterp) then
			on_ice = true
		elseif is_fire({x=p.x, y=p.y-boat_y_offset, z=p.z}) then
			boat.on_death(self, nil)
			self.object:remove()
			return
		else
			v_slowdown = 0.04
			v_factor = 0.5
		end
	elseif in_water and not in_river_water then
		on_water = false
		in_water = true
		v_factor = 0.75
		v_slowdown = 0.05
	end

	local hp = self.object:get_hp()
	local regen_timer = self._regen_timer + dtime
	if hp >= boat_max_hp then
		regen_timer = 0
	elseif regen_timer >= 0.5 then
		hp = hp + 1
		self.object:set_hp(hp)
		regen_timer = 0
	end
	self._regen_timer = regen_timer

	if moveresult and moveresult.collides then
		for _, collision in pairs(moveresult.collisions) do
			local pos = collision.node_pos
			if collision.type == "node" and minetest.get_item_group(minetest.get_node(pos).name, "dig_by_boat") > 0 then
				minetest.dig_node(pos)
			end
		end
	end

	local had_passenger = self._passenger

	self._driver = check_object(self._driver)
	self._passenger = check_object(self._passenger)

	if self._passenger then
		if not self._driver then
			self._driver = self._passenger
			self._passenger = nil
		else
			local ctrl = self._passenger:get_player_control()
			if ctrl and ctrl.sneak then
				detach_object(self._passenger, true)
				self._passenger = nil
			end
		end
	end

	if self._driver then
		if had_passenger and not self._passenger then
			set_attach(self)
		end
		local ctrl = self._driver:get_player_control()
		if ctrl and ctrl.sneak then
			detach_object(self._driver, true)
			self._driver = nil
			return
		end
		local yaw = self.object:get_yaw()
		if ctrl and ctrl.up then
			-- Forwards
			self._v = self._v + 0.1 * v_factor

			-- Paddling animation
			if self._animation ~= 1 then
				self.object:set_animation({x=0, y=40}, paddling_speed, 0, true)
				self._animation = 1
			end
		elseif ctrl and ctrl.down then
			-- Backwards
			self._v = self._v - 0.1 * v_factor

			-- Paddling animation, reversed
			if self._animation ~= -1 then
				self.object:set_animation({x=0, y=40}, -paddling_speed, 0, true)
				self._animation = -1
			end
		else
			-- Stop paddling animation if no control pressed
			if self._animation ~= 0 then
				self.object:set_animation({x=0, y=40}, 0, 0, true)
				self._animation = 0
			end
		end
		if ctrl and ctrl.left then
			if self._v < 0 then
				self.object:set_yaw(yaw - (1 + dtime) * 0.03 * v_factor)
			else
				self.object:set_yaw(yaw + (1 + dtime) * 0.03 * v_factor)
			end
		elseif ctrl and ctrl.right then
			if self._v < 0 then
				self.object:set_yaw(yaw + (1 + dtime) * 0.03 * v_factor)
			else
				self.object:set_yaw(yaw - (1 + dtime) * 0.03 * v_factor)
			end
		end
	else
		-- Stop paddling without driver
		if self._animation ~= 0 then
			self.object:set_animation({x=0, y=40}, 0, 0, true)
			self._animation = 0
		end

		for _, obj in pairs(minetest.get_objects_inside_radius(self.object:get_pos(), 1.3)) do
			local entity = obj:get_luaentity()
			if entity and entity.is_mob then
				attach_object(self, obj)
				break
			end
		end
	end
	local s = get_sign(self._v)
	if not on_ice and not on_water and not in_water and math.abs(self._v) > 2.0 then
		v_slowdown = math.min(math.abs(self._v) - 2.0, v_slowdown * 5)
	elseif not on_ice and in_water and math.abs(self._v) > 1.5 then
		v_slowdown = math.min(math.abs(self._v) - 1.5, v_slowdown * 5)
	end
	self._v = self._v - v_slowdown * s
	if s ~= get_sign(self._v) then
		self._v = 0
	end

	p.y = p.y - boat_y_offset
	local new_velo
	local new_acce
	if not flowlib.is_water(p) and not on_ice then
		-- Not on water or inside water: Free fall
		--local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		new_acce = {x = 0, y = -9.8, z = 0}
		new_velo = get_velocity(self._v, self.object:get_yaw(),
			self.object:get_velocity().y)
	else
		p.y = p.y + 1
		if is_river_water(p) then
			local y = self.object:get_velocity().y
			if y >= 5 then
				y = 5
			elseif y < 0 then
				new_acce = {x = 0, y = 10, z = 0}
			else
				new_acce = {x = 0, y = 2, z = 0}
			end
			new_velo = get_velocity(self._v, self.object:get_yaw(), y)
			self.object:set_pos(self.object:get_pos())
		elseif flowlib.is_water(p) and not is_river_water(p) then
			-- Inside water: Slowly sink
			local y = self.object:get_velocity().y
			y = y - 0.01
			if y < -0.2 then
				y = -0.2
			end
			new_acce = {x = 0, y = 0, z = 0}
			new_velo = get_velocity(self._v, self.object:get_yaw(), y)
		else
			-- On top of water
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:get_velocity().y) < 0 then
				new_velo = get_velocity(self._v, self.object:get_yaw(), 0)
			else
				new_velo = get_velocity(self._v, self.object:get_yaw(),
					self.object:get_velocity().y)
			end
		end
	end

	-- Terminal velocity: 8 m/s per axis of travel
	local terminal_velocity = on_ice and 57.1 or 8.0
	for _,axis in pairs({"z","y","x"}) do
		if math.abs(new_velo[axis]) > terminal_velocity then
			new_velo[axis] = terminal_velocity * get_sign(new_velo[axis])
		end
	end

	local yaw = self.object:get_yaw()
	local anim = (boat_max_hp - hp - regen_timer * 2) / boat_max_hp * math.pi / 4

	self.object:set_rotation(vector.new(anim, yaw, anim))
	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
end

-- Register one entity for all boat types
minetest.register_entity("mcl_boats:boat", boat)

local cboat = table.copy(boat)
cboat._itemstring = "mcl_boats:chest_boat"
cboat.initial_properties.textures = { "mcl_boats_texture_oak_chest_boat.png", "mcl_chests_normal.png" }
cboat.initial_properties.collisionbox = {-0.5, -0.15, -0.5, 0.5, 0.75, 0.5}
cboat.initial_properties.selectionbox = {-0.7, -0.15, -0.7, 0.7, 0.75, 0.7}

minetest.register_entity("mcl_boats:chest_boat", cboat)
mcl_entity_invs.register_inv("mcl_boats:chest_boat","Boat",27)

local doc_itemstring_boat
local doc_itemstring_chest_boat

function mcl_boats.register_boat(name,item_def,object_properties,entity_overrides)
	local itemstring = "mcl_boats:boat_"..name
	local id = name.."_boat"

	local longdesc, usagehelp, tt_help, help, helpname
	help = false
	-- Only create one help entry for all boats
	if not doc_itemstring_boat then
		help = true
		longdesc = S("Boats are used to travel on the surface of water.")
		usagehelp = S("Rightclick on a water source to place the boat. Rightclick the boat to enter it. Use [Left] and [Right] to steer, [Forwards] to speed up and [Backwards] to slow down or move backwards. Use [Sneak] to leave the boat, punch the boat to make it drop as an item.")
		helpname = S("Boat")
		doc_itemstring_boat = itemstring
		doc.sub.identifier.register_object("mcl_boats:boat", "craftitems", itemstring)
	else
		doc.add_entry_alias("craftitems", doc_itemstring_boat, "craftitems", itemstring)
	end
	tt_help = S("Water vehicle")

	local inventory_image
	local texture
	if id:find("chest") then
		inventory_image = "mcl_boats_" .. id .. ".png"
		texture = "mcl_boats_texture_" .. id:gsub("chest_", "") .. ".png"
		if not doc_itemstring_chest_boat then
			help = true
			longdesc = S("Chest Boats are used to travel on the surface of water. And transport goods")
			usagehelp = S("Rightclick on a water source to place the boat. Rightclick the boat to enter it. Use [Left] and [Right] to steer, [Forwards] to speed up and [Backwards] to slow down or move backwards. Use [Sneak] to leave the boat, punch the boat to make it drop as an item. Use [Sneak] + [Rightclick] to open the boat's chest")
			helpname = S("Chest Boat")
			doc_itemstring_chest_boat = itemstring
			doc.sub.identifier.register_object("mcl_boats:chest_boat", "craftitems", doc_itemstring_chest_boat)
		else
			doc.add_entry_alias("craftitems", doc_itemstring_chest_boat, "craftitems", itemstring)
		end
	else
		inventory_image = "mcl_boats_" .. name .. "_boat.png"
		texture = "mcl_boats_texture_" .. name .. "_boat.png"
	end

	minetest.register_craftitem(":"..itemstring, table.merge({
		description = S(name.." Boat"),
		_tt_help = tt_help,
		_doc_items_create_entry = help,
		_doc_items_entry_name = helpname,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		inventory_image = inventory_image,
		liquids_pointable = true,
		groups = { boat = 1, transport = 1},
		stack_max = 1,
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			local pos = table.copy(pointed_thing.under)
			local dir = vector.subtract(pointed_thing.above, pointed_thing.under)

			if math.abs(dir.x) > 0.9 or math.abs(dir.z) > 0.9 then
				pos = vector.add(pos, vector.multiply(dir, boat_side_offset))
			elseif flowlib.is_water(pos) then
				pos = vector.add(pos, vector.multiply(dir, boat_y_offset))
			else
				pos = vector.add(pos, vector.multiply(dir, boat_y_offset_ground))
			end
			local boat_ent = "mcl_boats:boat"
			local chest_tex = "blank.png"
			if itemstring:find("chest") then
				boat_ent = "mcl_boats:chest_boat"
				chest_tex = "mcl_chests_normal.png"
			end
			local boat = minetest.add_entity(pos, boat_ent)
			if boat and boat:get_pos() then
				local ent = boat:get_luaentity()
				ent._itemstring = itemstring
				boat:set_properties(table.merge({ textures = { texture, chest_tex }},object_properties or {}))
				boat:set_yaw(placer:get_look_horizontal())
				for k,v in pairs(entity_overrides or {}) do
					ent[k] = v
				end
			end
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end,
		_on_dispense = function(stack, pos, droppos, dropnode, dropdir)
			local below = {x=droppos.x, y=droppos.y-1, z=droppos.z}
			local belownode = minetest.get_node(below)
			-- Place boat as entity on or in water
			if minetest.get_item_group(dropnode.name, "water") ~= 0 or (dropnode.name == "air" and minetest.get_item_group(belownode.name, "water") ~= 0) then
				minetest.add_entity(droppos, "mcl_boats:boat")
			else
				minetest.add_item(droppos, stack)
			end
		end,
	},item_def or {}))

	local c = "mcl_trees:wood_"..name
	if itemstring:find("chest") then
		minetest.register_craft({
			output = itemstring,
			recipe = {
				{"mcl_chests:chest"},
				{"mcl_boats:boat_"..name:gsub("_chest","")},
			},
		})
	elseif minetest.registered_nodes[c] then
		minetest.register_craft({
			output = itemstring,
			recipe = {
				{c, "", c},
				{c, c, c},
			},
		})
	end
end

minetest.register_craft({
	type = "fuel",
	recipe = "group:boat",
	burntime = 20,
})
