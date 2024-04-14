--this is used for the player pool in the sound buffer
local pool = {}

local tick = false

minetest.register_on_joinplayer(function(player)
	local name
	name = player:get_player_name()
	pool[name] = 0
end)

minetest.register_on_leaveplayer(function(player)
	local name
	name = player:get_player_name()
	pool[name] = nil
end)


local has_awards = minetest.get_modpath("awards")

mcl_item_entity = {}

local MULTIPLE_AWARDS_DELAY = 3 --Delay when picking up 1 item prouces multiple awards.

--basic settings
local item_drop_settings                 = {} --settings table
item_drop_settings.dug_buffer            = 0.65 -- the warm up period before a dug item can be collected
item_drop_settings.age                   = 1.0 --how old a dropped item (_insta_collect==false) has to be before collecting
item_drop_settings.radius_magnet         = 2.0 --radius of item magnet. MUST BE LARGER THAN radius_collect!
item_drop_settings.xp_radius_magnet      = 7.25 --radius of xp magnet. MUST BE LARGER THAN radius_collect!
item_drop_settings.radius_collect        = 0.2 --radius of collection
item_drop_settings.player_collect_height = 0.8 --added to their pos y value
item_drop_settings.collection_safety     = false --do this to prevent items from flying away on laggy servers
item_drop_settings.random_item_velocity  = true --this sets random item velocity if velocity is 0
item_drop_settings.drop_single_item      = false --if true, the drop control drops 1 item instead of the entire stack, and sneak+drop drops the stack
-- drop_single_item is disabled by default because it is annoying to throw away items from the intentory screen

item_drop_settings.magnet_time           = 0.75 -- how many seconds an item follows the player before giving up

local function get_gravity()
	return tonumber(minetest.settings:get("movement_gravity")) or 9.81
end
mcl_item_entity.get_gravity = get_gravity

local registered_pickup_achievement = {}

function mcl_item_entity.register_pickup_achievement(itemname, award)
	if not has_awards then
		minetest.log("warning", "[mcl_item_entity] Trying to register pickup achievement ["..award.."] for ["..itemname.."] while awards missing")
	else
		if not registered_pickup_achievement[itemname] then
			registered_pickup_achievement[itemname] = {}
		end
		table.insert(registered_pickup_achievement[itemname], award)
	end
end

mcl_item_entity.register_pickup_achievement("tree", "mcl:mineWood")
mcl_item_entity.register_pickup_achievement("mcl_mobitems:blaze_rod", "mcl:blazeRod")
mcl_item_entity.register_pickup_achievement("mcl_mobitems:leather", "mcl:killCow")
mcl_item_entity.register_pickup_achievement("mcl_core:diamond", "mcl:diamonds")
mcl_item_entity.register_pickup_achievement("mcl_core:crying_obsidian", "mcl:whosCuttingOnions")
mcl_item_entity.register_pickup_achievement("mcl_nether:ancient_debris", "mcl:hiddenInTheDepths")
mcl_item_entity.register_pickup_achievement("mcl_end:dragon_egg", "mcl:PickUpDragonEgg")
mcl_item_entity.register_pickup_achievement("mcl_armor:elytra", "mcl:skysTheLimit")

local function check_pickup_achievements(object, player)
	if has_awards then
		local itemname = ItemStack(object:get_luaentity().itemstring):get_name()
		local playername = player:get_player_name()
		for name,awardstable in pairs(registered_pickup_achievement) do
			for k,award in pairs(awardstable) do
				if itemname == name or minetest.get_item_group(itemname, name) ~= 0 then
					minetest.after((k-1) * MULTIPLE_AWARDS_DELAY, function(playername,award)
						awards.unlock(playername, award)
					end,playername,award)
				end
			end
		end
	end
end

local function enable_physics(object, luaentity, ignore_check)
	if luaentity.physical_state == false or ignore_check == true then
		luaentity.physical_state = true
		object:set_properties({
			physical = true
		})
		object:set_acceleration({x=0,y=-get_gravity(),z=0})
	end
end

local function disable_physics(object, luaentity, ignore_check, reset_movement)
	if luaentity.physical_state == true or ignore_check == true then
		luaentity.physical_state = false
		object:set_properties({
			physical = false
		})
		if reset_movement ~= false then
			object:set_velocity({x=0,y=0,z=0})
			object:set_acceleration({x=0,y=0,z=0})
		end
	end
end


minetest.register_globalstep(function(dtime)
	tick = not tick

	for _,player in pairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 or not minetest.settings:get_bool("enable_damage") then

			local name = player:get_player_name()

			local pos = player:get_pos()

			if tick == true and pool[name] > 0 then
				minetest.sound_play("item_drop_pickup", {
					pos = pos,
					gain = 0.3,
					max_hear_distance = 16,
					pitch = math.random(70,110)/100
				})
				if pool[name] > 6 then
					pool[name] = 6
				else
					pool[name] = pool[name] - 1
				end
			end



			local inv = player:get_inventory()
			local checkpos = {x=pos.x,y=pos.y + item_drop_settings.player_collect_height,z=pos.z}

			--magnet and collection
			for _,object in pairs(minetest.get_objects_inside_radius(checkpos, item_drop_settings.xp_radius_magnet)) do
				if not object:is_player() and vector.distance(checkpos, object:get_pos()) < item_drop_settings.radius_magnet and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" and object:get_luaentity()._magnet_timer and (object:get_luaentity()._insta_collect or (object:get_luaentity().age > item_drop_settings.age)) then

					if object:get_luaentity()._magnet_timer >= 0 and object:get_luaentity()._magnet_timer < item_drop_settings.magnet_time and inv and inv:room_for_item("main", ItemStack(object:get_luaentity().itemstring)) then

						-- Collection
						if not object:get_luaentity()._removed then
							-- Ignore if itemstring is not set yet
							if object:get_luaentity().itemstring ~= "" then
								inv:add_item("main", ItemStack(object:get_luaentity().itemstring))

								check_pickup_achievements(object, player)

								-- Destroy entity
								-- This just prevents this section to be run again because object:remove() doesn't remove the item immediately.
								object:get_luaentity().target = checkpos
								object:get_luaentity()._removed = true

								object:set_velocity({x=0,y=0,z=0})
								object:set_acceleration({x=0,y=0,z=0})

								object:move_to(checkpos)

								pool[name] = pool[name] + 1

								minetest.after(0.25, function()
									--safety check
									if object and object:get_luaentity() then
										object:remove()
									end
								end)
							end
						end
					end

				elseif not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "mcl_experience:orb" then
					local entity = object:get_luaentity()
					entity.collector = player:get_player_name()
					entity.collected = true

				end
			end

		end
	end
end)

-- Stupid workaround to get drops from a drop table:
-- Create a temporary table in minetest.registered_nodes that contains the proper drops,
-- because unfortunately minetest.get_node_drops needs the drop table to be inside a registered node definition
-- (very ugly)

local tmp_id = 0

local function get_drops(drop, toolname, param2, paramtype2)
	tmp_id = tmp_id + 1
	local tmp_node_name = "mcl_item_entity:" .. tmp_id
	minetest.registered_nodes[tmp_node_name] = {
		name = tmp_node_name,
		drop = drop,
		paramtype2 = paramtype2
	}
	local drops = minetest.get_node_drops({name = tmp_node_name, param2 = param2}, toolname)
	minetest.registered_nodes[tmp_node_name] = nil
	return drops
end

local function discrete_uniform_distribution(drops, min_count, max_count, cap)
	local new_drops = table.copy(drops)
	for i, item in ipairs(drops) do
		local new_item = ItemStack(item)
		local multiplier = math.random(min_count, max_count)
		if cap then
			multiplier = math.min(cap, multiplier)
		end
		new_item:set_count(multiplier * new_item:get_count())
		new_drops[i] = new_item
	end
	return new_drops
end

local function get_fortune_drops(fortune_drops, fortune_level)
	local drop
	local i = fortune_level
	repeat
		drop = fortune_drops[i]
		i = i - 1
	until drop or i < 1
	return drop or {}
end

local doTileDrops = minetest.settings:get_bool("mcl_doTileDrops", true)

function minetest.handle_node_drops(pos, drops, digger)
	-- NOTE: This function override allows digger to be nil.
	-- This means there is no digger. This is a special case which allows this function to be called
	-- by hand. Creative Mode is intentionally ignored in this case.
	if digger and digger:is_player() and minetest.is_creative_enabled(digger:get_player_name()) then
		local inv = digger:get_inventory()
		if inv then
			for _, item in ipairs(drops) do
				if not inv:contains_item("main", item, true) then
					inv:add_item("main", item)
				end
			end
		end
		return
	elseif not doTileDrops then return end

	-- Check if node will yield its useful drop by the digger's tool
	local dug_node = minetest.get_node(pos)
	local tooldef
	local tool
	if digger and digger:is_player() then
		tool = digger:get_wielded_item()
		tooldef = minetest.registered_items[tool:get_name()]

		if not mcl_autogroup.can_harvest(dug_node.name, tool:get_name(), digger) then
			return
		end
	end

	local diggroups = tooldef and tooldef._mcl_diggroups
	local shearsy_level = diggroups and diggroups.shearsy and diggroups.shearsy.level

	--[[ Special node drops when dug by shears by reading _mcl_shears_drop or with a silk touch tool reading _mcl_silk_touch_drop
	from the node definition.
	Definition of _mcl_shears_drop / _mcl_silk_touch_drop:
	* true: Drop itself when dug by shears / silk touch tool
	* table: Drop every itemstring in this table when dug by shears _mcl_silk_touch_drop
	]]

	local enchantments = tool and mcl_enchanting.get_enchantments(tool, "silk_touch")

	local silk_touch_drop = false
	local nodedef = minetest.registered_nodes[dug_node.name]
	if not nodedef then return end

	if shearsy_level and shearsy_level > 0 and nodedef._mcl_shears_drop then
		if nodedef._mcl_shears_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_shears_drop
		end
	elseif tool and enchantments.silk_touch and nodedef._mcl_silk_touch_drop then
		silk_touch_drop = true
		if nodedef._mcl_silk_touch_drop == true then
			drops = { dug_node.name }
		else
			drops = nodedef._mcl_silk_touch_drop
		end
	end

	if tool and nodedef._mcl_fortune_drop and enchantments.fortune then
		local fortune_level = enchantments.fortune
		local fortune_drop = nodedef._mcl_fortune_drop
		if fortune_drop.discrete_uniform_distribution then
			local min_count = fortune_drop.min_count
			local max_count = fortune_drop.max_count + fortune_level * (fortune_drop.factor or 1)
			local chance = fortune_drop.chance or fortune_drop.get_chance and fortune_drop.get_chance(fortune_level)
			if not chance or math.random() < chance then
				drops = discrete_uniform_distribution(fortune_drop.multiply and drops or fortune_drop.items, min_count, max_count, fortune_drop.cap)
			elseif fortune_drop.override then
				drops = {}
			end
		else
			-- Fixed Behavior
			local drop = get_fortune_drops(fortune_drop, fortune_level)
			drops = get_drops(drop, tool:get_name(), dug_node.param2, nodedef.paramtype2)
		end
	end

	if digger and mcl_experience.throw_xp and not silk_touch_drop then
		local experience_amount = minetest.get_item_group(dug_node.name,"xp")
		if experience_amount > 0 then
			mcl_experience.throw_xp(pos, experience_amount)
		end
	end

	for _,item in ipairs(drops) do
		local count
		if type(item) == "string" then
			count = ItemStack(item):get_count()
		else
			count = item:get_count()
		end
		local drop_item = ItemStack(item)
		drop_item:set_count(1)
		for i=1,count do
			local dpos = table.copy(pos)
			-- Apply offset for plantlike_rooted nodes because of their special shape
			if nodedef and nodedef.drawtype == "plantlike_rooted" and nodedef.walkable then
				dpos.y = dpos.y + 1
			end
			-- Spawn item and apply random speed
			local obj = minetest.add_item(dpos, drop_item)
			if obj then
				-- set the velocity multiplier to the stored amount or if the game dug this node, apply a bigger velocity
				if digger and digger:is_player() then
					obj:get_luaentity().random_velocity = 1
				else
					obj:get_luaentity().random_velocity = 1.6
				end
				obj:get_luaentity().age = item_drop_settings.dug_buffer
				obj:get_luaentity()._insta_collect = false
			end
		end
	end
end

-- Drop single items by default
function minetest.item_drop(itemstack, dropper, pos)
	if dropper and dropper:is_player() then
		local v = dropper:get_look_dir()
		local p = {x=pos.x, y=pos.y+1.2, z=pos.z}
		local cs = itemstack:get_count()
		if dropper:get_player_control().sneak then
			cs = 1
		end
		local item = itemstack:take_item(cs)
		local obj = minetest.add_item(p, item)
		if obj then
			v.x = v.x*4
			v.y = v.y*4 + 2
			v.z = v.z*4
			obj:set_velocity(v)
			-- Force collection delay
			obj:get_luaentity()._insta_collect = false
			return itemstack
		end
	end
end

-- TODO: remove this workaround if this gets fixed in minetest
-- Do an additional node_drop here if the tool is about to break
-- The point here is to do an addtional minetest.handle_node_drops
-- before calling the original function since that one does it
-- *after* adding the wear and hence breaking the tool on last use
-- before dropping things.
local old_mt_node_dig = minetest.node_dig
function minetest.node_dig(pos, node, digger)
	local wielded = digger and digger:is_player() and digger:get_wielded_item()
	local def = core.registered_nodes[node.name]
	if wielded and def then
		local wdef = wielded:get_definition()
		local tp = wielded:get_tool_capabilities()
		local dp = minetest.get_dig_params(def and def.groups, tp, wielded:get_wear())
		if wdef and not wdef.after_use then
			if not minetest.is_creative_enabled(digger:get_player_name()) then
				if wielded:get_wear() + dp.wear >= 65535 then
					minetest.handle_node_drops(pos, minetest.get_node_drops(node, wielded and wielded:get_name()), digger)
				end
			end
		end
	end
	return old_mt_node_dig(pos, node, digger)
end

--modify builtin:item

local time_to_live = tonumber(minetest.settings:get("item_entity_ttl"))
if not time_to_live then
	time_to_live = 300
end

local function cxcz(o, cw, one, zero)
	if cw < 0 then
		table.insert(o, { [one]=1, y=0, [zero]=0 })
		table.insert(o, { [one]=-1, y=0, [zero]=0 })
	else
		table.insert(o, { [one]=-1, y=0, [zero]=0 })
		table.insert(o, { [one]=1, y=0, [zero]=0 })
	end
	return o
end

minetest.register_entity(":__builtin:item", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.3, -0.3, -0.3, 0.3, 0.3, 0.3},
		pointable = false,
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		infotext = "",
	},

	-- Itemstring of dropped item. The empty string is used when the item is not yet initialized yet.
	-- The itemstring MUST be set immediately to a non-empty string after creating the entity.
	-- The hand is NOT permitted as dropped item. ;-)
	-- Item entities will be deleted if they still have an empty itemstring on their first on_step tick.
	itemstring = "",

	-- If true, item will fall
	physical_state = true,

	-- If item entity is currently flowing in water
	_flowing = false,

	-- Number of seconds this item entity has existed so far
	age = 0,

	-- Multiplier for initial random velocity when the item is spawned
	random_velocity = 1,

	-- How old it has become in the collection animation
	collection_age = 0,

	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,

	-- Function to apply a random velocity
	apply_random_vel = function(self, speed)
		if not self or not self.object or not self.object:get_luaentity() then
			return
		end
		-- if you passed a value then use that for the velocity multiplier
		if speed ~= nil then self.random_velocity = speed end

		local vel = self.object:get_velocity()

		-- There is perhaps a cleverer way of making this physical so it bounces off the wall like swords.
		local max_vel = 6.5 -- Faster than this and it throws it into the wall / floor and turns black because of clipping.

		if vel and vel.x == 0 and vel.z == 0 and self.random_velocity > 0 then
			local v = self.random_velocity

			local x = math.random(5, max_vel) / 10 * v
			if math.random(0, 10) < 5 then x = -x end
			local z = math.random(5, max_vel) / 10 * v
			if math.random(0, 10) < 5 then z = -z end
			local y = math.random(1, 2)
			self.object:set_velocity(vector.new(x, y, z))
		end
		self.random_velocity = 0
	end,

	set_item = function(self, itemstring)
		self.itemstring = itemstring
		if self.itemstring == "" then
			-- item not yet known
			return
		end
		local stack = ItemStack(itemstring)
		if minetest.get_item_group(stack:get_name(), "compass") > 0 then
			if string.find(stack:get_name(), "_lodestone") then
				stack:set_name("mcl_compass:18_lodestone")
			else
				stack:set_name("mcl_compass:18")
			end
			itemstring = stack:to_string()
			self.itemstring = itemstring
		end
		if minetest.get_item_group(stack:get_name(), "clock") > 0 then
			self.is_clock = true
		end
		local count = stack:get_count()
		local max_count = stack:get_stack_max()
		if count > max_count then
			count = max_count
			self.itemstring = stack:get_name().." "..max_count
		end
		local itemtable = stack:to_table()
		local itemname = nil
		local description = ""
		if itemtable then
			itemname = stack:to_table().name
		end
		local glow
		local def = minetest.registered_items[itemname]
		if def then
			description = def.description
			glow = def.light_source
		end
		local s = 0.2 + 0.1 * (count / max_count)
		local wield_scale = (def and type(def.wield_scale) == "table" and tonumber(def.wield_scale.x)) or 1
		local c = s
		s = s / wield_scale
		local prop = {
			is_visible = true,
			visual = "wielditem",
			textures = {itemname},
			visual_size = {x = s, y = s},
			collisionbox = {-c, -c, -c, c, c, c},
			automatic_rotate = math.pi * 0.5,
			infotext = description,
			glow = glow,
		}
		self.object:set_properties(prop)
		if item_drop_settings.random_item_velocity == true and self.age < 1 then
			minetest.after(0, self.apply_random_vel, self)
		end
	end,

	get_staticdata = function(self)
		local data = minetest.serialize({
			itemstring = self.itemstring,
			always_collect = self.always_collect,
			age = self.age,
			_insta_collect = self._insta_collect,
			_flowing = self._flowing,
			_removed = self._removed,
		})
		-- sfan5 guessed that the biggest serializable item
		-- entity would have a size of 65530 bytes. This has
		-- been experimentally verified to be still too large.
		--
		-- anon5 has calculated that the biggest serializable
		-- item entity has a size of exactly 65487 bytes:
		--
		-- 1. serializeString16 can handle max. 65535 bytes.
		-- 2. The following engine metadata is always saved:
		--    • 1 byte (version)
		--    • 2 byte (length prefix)
		--    • 14 byte “__builtin:item”
		--    • 4 byte (length prefix)
		--    • 2 byte (health)
		--    • 3 × 4 byte = 12 byte (position)
		--    • 4 byte (yaw)
		--    • 1 byte (version 2)
		--    • 2 × 4 byte = 8 byte (pitch and roll)
		-- 3. This leaves 65487 bytes for the serialization.
		if #data > 65487 then -- would crash the engine
			local stack = ItemStack(self.itemstring)
			stack:get_meta():from_table(nil)
			self.itemstring = stack:to_string()
			minetest.log(
				"warning",
				"Overlong item entity metadata removed: “" ..
				self.itemstring ..
				"” had serialized length of " ..
				#data
			)
			return self:get_staticdata()
		end
		return data
	end,

	on_activate = function(self, staticdata, dtime_s)
		if string.sub(tostring(staticdata), 1, string.len("return")) == "return" then
			local data = minetest.deserialize(staticdata)
			if data and type(data) == "table" then
				self.itemstring = data.itemstring
				self.always_collect = data.always_collect
				if data.age then
					self.age = data.age
				else
					self.age = self.age
				end
				--remember collection data
				-- If true, can collect item without delay
				self._insta_collect = data._insta_collect
				self._flowing = data._flowing
				self._removed = data._removed
			end
		else
			self.itemstring = staticdata
		end
		if self._removed then
			self._removed = true
			self.object:remove()
			return
		end
		if self._insta_collect == nil then
			-- Intentionally default, since delayed collection is rare
			self._insta_collect = true
		end
		if self._flowing == nil then
			self._flowing = false
		end
		self._magnet_timer = 0
		self._magnet_active = false
		-- How long ago the last possible collector was detected. nil = none in this session
		self._collector_timer = nil
		-- Used to apply additional force
		self._force = nil
		self._forcestart = nil
		self._forcetimer = 0

		self.object:set_armor_groups({immortal = 1})
		-- self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration({x = 0, y = -get_gravity(), z = 0})
		self:set_item(self.itemstring)
	end,

	try_merge_with = function(self, own_stack, object, entity)
		if self.age == entity.age or entity._removed then
			-- Can not merge with itself and remove entity
			return false
		end

		local stack = ItemStack(entity.itemstring)
		local name = stack:get_name()
		if own_stack:get_name() ~= name or
				own_stack:get_meta() ~= stack:get_meta() or
				own_stack:get_wear() ~= stack:get_wear() or
				own_stack:get_free_space() == 0 then
			-- Can not merge different or full stack
			return false
		end

		local count = own_stack:get_count()
		local total_count = stack:get_count() + count
		local max_count = stack:get_stack_max()

		if total_count > max_count then
			return false
		end

		-- Merge the remote stack into this one
		local self_pos = self.object:get_pos()
		local pos = object:get_pos()

		--local y = pos.y + ((total_count - count) / max_count) * 0.15
		local x_diff = (self_pos.x - pos.x) / 2
		local z_diff = (self_pos.z - pos.z) / 2

		local new_pos = vector.offset(pos, x_diff, 0, z_diff)
		new_pos.y = math.max(self_pos.y, pos.y) + 0.1

		self.object:move_to(new_pos)

		self.age = 0 -- Handle as new entity
		own_stack:set_count(total_count)
		self.random_velocity = 0
		self:set_item(own_stack:to_string())

		entity._removed = true
		object:remove()
		return true
	end,

	on_step = function(self, dtime, moveresult)
		if self._removed then
			self.object:set_properties({
				physical = false
			})
			self.object:set_velocity({x=0,y=0,z=0})
			self.object:set_acceleration({x=0,y=0,z=0})
			return
		end

		self.age = self.age + dtime
		if self._collector_timer then
			self._collector_timer = self._collector_timer + dtime
		end
		if time_to_live > 0 and self.age > time_to_live then
			self._removed = true
			self.object:remove()
			return
		end
		-- Delete corrupted item entities. The itemstring MUST be non-empty on its first step,
		-- otherwise there might have some data corruption.
		if self.itemstring == "" then
			minetest.log("warning", "Item entity with empty itemstring found at "..minetest.pos_to_string(self.object:get_pos()).. "! Deleting it now.")
			self._removed = true
			self.object:remove()
			return
		end

		local p = self.object:get_pos()

		local node = minetest.get_node(p)
		local in_unloaded = node.name == "ignore"


		if in_unloaded then
			-- Don't infinetly fall into unloaded map
			disable_physics(self.object, self)
			return
		end




		if self.is_clock then
			self.object:set_properties({
				textures = {"mcl_clock:clock_" .. (mcl_worlds.clock_works(p) and mcl_clock.old_time or mcl_clock.random_frame)}
			})
		end

		local nn = node.name
		local is_in_water = (minetest.get_item_group(nn, "liquid") ~= 0)
		local nn_above = minetest.get_node({x=p.x, y=p.y+0.1, z=p.z}).name
		--  make sure it's more or less stationary and is at water level
		local sleep_threshold = 0.3
		local is_floating = false
		local is_stationary = math.abs(self.object:get_velocity().x) < sleep_threshold
		and math.abs(self.object:get_velocity().y) < sleep_threshold
		and math.abs(self.object:get_velocity().z) < sleep_threshold
		if is_in_water and is_stationary then
			is_floating = (is_in_water
				and (minetest.get_item_group(nn_above, "liquid") == 0))
		end

		if is_floating and self.physical_state == true then
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			disable_physics(self.object, self)
		end
		-- If no collector was found for a long enough time, declare the magnet as disabled
		if self._magnet_active and (self._collector_timer == nil or (self._collector_timer > item_drop_settings.magnet_time)) then
			self._magnet_active = false
			enable_physics(self.object, self)
			return
		end

		-- Destroy item in lava, fire or special nodes

		local def = minetest.registered_nodes[nn]
		local lg = minetest.get_item_group(nn, "lava")
		local fg = minetest.get_item_group(nn, "fire")
		local dg = minetest.get_item_group(nn, "destroys_items")
		if (def and (lg ~= 0 or fg ~= 0 or dg == 1)) then
			local item_name = ItemStack(self.itemstring):get_name()

			--Wait 2 seconds to allow mob drops to be cooked, & picked up instead of instantly destroyed.
			if self.age > 2 and minetest.get_item_group(item_name, "fire_immune") == 0 then
				if dg ~= 2 then
					minetest.sound_play("builtin_item_lava", {pos = self.object:get_pos(), gain = 0.5})
				end
				self._removed = true
				self.object:remove()
				return
			end
		end

		-- Destroy item when it collides with a cactus
		if moveresult and moveresult.collides then
			for _, collision in pairs(moveresult.collisions) do
				local pos = collision.node_pos
				if collision.type == "node" and minetest.get_node(pos).name == "mcl_core:cactus" then
					self._removed = true
					self.object:remove()
					return
				end
			end
		end

		-- Push item out when stuck inside solid opaque node
		if not is_in_water and def and def.walkable and def.groups and def.groups.opaque == 1 then
			local shootdir
			local cx = (p.x % 1) - 0.5
			local cz = (p.z % 1) - 0.5
			local order = {}

			-- First prepare the order in which the 4 sides are to be checked.
			-- 1st: closest
			-- 2nd: other direction
			-- 3rd and 4th: other axis
			if math.abs(cx) < math.abs(cz) then
				order = cxcz(order, cx, "x", "z")
				order = cxcz(order, cz, "z", "x")
			else
				order = cxcz(order, cz, "z", "x")
				order = cxcz(order, cx, "x", "z")
			end

			-- Check which one of the 4 sides is free
			for o=1, #order do
				local nn = minetest.get_node(vector.add(p, order[o])).name
				local def = minetest.registered_nodes[nn]
				if def and def.walkable == false and nn ~= "ignore" then
					shootdir = order[o]
					break
				end
			end
			-- If none of the 4 sides is free, shoot upwards
			if shootdir == nil then
				shootdir = { x=0, y=1, z=0 }
				local nn = minetest.get_node(vector.add(p, shootdir)).name
				if nn == "ignore" then
					-- Do not push into ignore
					return
				end
			end

			-- Set new item moving speed accordingly
			local newv = vector.multiply(shootdir, 3)
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.object:set_velocity(newv)
			disable_physics(self.object, self, false, false)


			if shootdir.y == 0 then
				self._force = newv
				p.x = math.floor(p.x)
				p.y = math.floor(p.y)
				p.z = math.floor(p.z)
				self._forcestart = p
				self._forcetimer = 1
			end
			return
		end

		-- This code is run after the entity got a push from above “push away” code.
		-- It is responsible for making sure the entity is entirely outside the solid node
		-- (with its full collision box), not just its center.
		if self._forcetimer > 0 then
			local cbox = self.object:get_properties().collisionbox
			local ok = false
			if self._force.x > 0 and (p.x > (self._forcestart.x + 0.5 + (cbox[4] - cbox[1])/2)) then ok = true
			elseif self._force.x < 0 and (p.x < (self._forcestart.x + 0.5 - (cbox[4] - cbox[1])/2)) then ok = true
			elseif self._force.z > 0 and (p.z > (self._forcestart.z + 0.5 + (cbox[6] - cbox[3])/2)) then ok = true
			elseif self._force.z < 0 and (p.z < (self._forcestart.z + 0.5 - (cbox[6] - cbox[3])/2)) then ok = true end
			-- Item was successfully forced out. No more pushing
			if ok then
				self._forcetimer = -1
				self._force = nil
				enable_physics(self.object, self)
			else
				self._forcetimer = self._forcetimer - dtime
			end
			return
		elseif self._force then
			self._force = nil
			enable_physics(self.object, self)
			return
		end

		-- Move item around on flowing liquids; add 'source' check to allow items to continue flowing a bit in the source block of flowing water.
		if def and not is_floating and (def.liquidtype == "flowing" or def.liquidtype == "source") then
			self._flowing = true

			--[[ Get flowing direction (function call from flowlib), if there's a liquid.
			NOTE: According to Qwertymine, flowlib.quickflow is only reliable for liquids with a flowing distance of 7.
			Luckily, this is exactly what we need if we only care about water, which has this flowing distance. ]]
			local vec = flowlib.quick_flow(p, node)
			-- Just to make sure we don't manipulate the speed for no reason
			if vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0 then
				-- Minecraft Wiki: Flowing speed is "about 1.39 meters per second"
				local f = 1.2
				-- Set new item moving speed into the direciton of the liquid
				local newv = vector.multiply(vec, f)
				-- Swap to acceleration instead of a static speed to better mimic MC mechanics.
				self.object:set_acceleration({x = newv.x, y = -0.22, z = newv.z})

				self.physical_state = true
				self._flowing = true
				self.object:set_properties({
					physical = true
				})
				return
			end
			if is_in_water and def.liquidtype == "source" then
				local cur_vec = self.object:get_velocity()
				-- apply some acceleration in the opposite direction so it doesn't slide forever
				local vec = {
					x = 0 -cur_vec.x*0.9,
					y = 3 -cur_vec.y*0.9,
					z = 0 -cur_vec.z*0.9}
				self.object:set_acceleration(vec)
				-- slow down the item in water
				local vel = self.object:get_velocity()
				if vel.y < 0 then
					vel.y = vel.y * 0.9
				end
				self.object:set_velocity(vel)
				if self.physical_state ~= false or self._flowing ~= true then
					self.physical_state = true
					self._flowing = true
					self.object:set_properties({
						physical = true
					})
				end
			end
		elseif self._flowing == true and not is_in_water and not is_floating then
			-- Disable flowing physics if not on/in flowing liquid
			self._flowing = false
			enable_physics(self.object, self, true)
			return
		end

		-- If node is not registered or node is walkably solid and resting on nodebox
		local nn = minetest.get_node({x=p.x, y=p.y-0.5, z=p.z}).name
		local def = minetest.registered_nodes[nn]
		local v = self.object:get_velocity()
		local is_on_floor = def and (def.walkable
			and not def.groups.slippery and v.y == 0)

		if not minetest.registered_nodes[nn] or is_floating or is_on_floor then

			local own_stack = ItemStack(self.object:get_luaentity().itemstring)
			-- Merge with close entities of the same item
			for _, object in pairs(minetest.get_objects_inside_radius(p, 0.8)) do
				local obj = object:get_luaentity()

				if obj and obj.name == "__builtin:item" and obj.physical_state == false then
					if self:try_merge_with(own_stack, object, obj) then
						return
					end
				end
				-- don't disable if underwater
				if not is_in_water then
					disable_physics(self.object, self)
				end
			end
		else
			if self._magnet_active == false and not is_floating then
				enable_physics(self.object, self)
			end
		end

	end,

	-- Note: on_punch intentionally left out. The player should *not* be able to collect items by punching
})
