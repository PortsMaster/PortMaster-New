local S = core.get_translator(core.get_current_modname())
mcl_campfires = {}

local PARTICLE_DISTANCE = 75

local player_particlespawners = {}
local food_entities = {}

local campfire_spots = {
	vector.new(-0.25, -0.04, -0.25),
	vector.new( 0.25, -0.04, -0.25),
	vector.new( 0.25, -0.04,  0.25),
	vector.new(-0.25, -0.04,  0.25),
}

local function count_table(tbl)
	local count = 0
	if type(tbl) == "table" then for _,_ in pairs(tbl) do count = count + 1 end end
	return count
end

local function drop_items(pos)
	local ph = core.hash_node_position(vector.round(pos))
	if food_entities[ph] then
		for _, v in pairs(food_entities[ph]) do
			if v and v.object and v.object:get_pos() then
				v.object:remove()
				core.add_item(pos, v._item)
			end
		end
		food_entities[ph] = nil
	end
end

local function campfire_drops(pos, digger, drops, nodename)
	local wield_item = digger:get_wielded_item()
	local inv = digger:get_inventory()
	if not core.is_creative_enabled(digger:get_player_name()) then
		local is_book = wield_item:get_name() == "mcl_enchanting:book_enchanted"
		if mcl_enchanting.has_enchantment(wield_item, "silk_touch") and not is_book then
			core.add_item(pos, nodename)
		else
			core.add_item(pos, drops)
		end
	elseif inv:room_for_item("main", nodename) and not inv:contains_item("main", nodename) then
		inv:add_item("main", nodename)
	end
end

local function on_blast(pos)
	drop_items(pos)
	core.remove_node(pos)
end

function mcl_campfires.light_campfire(pos)
	local campfire = core.get_node(pos)
	local name = campfire.name .. "_lit"
	core.set_node(pos, {name = name, param2 = campfire.param2})
end

local function delete_entities(ph)
	if not food_entities[ph] then return end
	for _, v in pairs(food_entities[ph]) do
		if v and v.object then
			v:remove()
		end
	end
	food_entities[ph] = nil
end

local function get_free_spot(ph)
	if not food_entities[ph] then
		food_entities[ph] = {}
		return 1
	end
	for i = 1,4 do
		local v = food_entities[ph][i]
		if not v or not v.object or not v.object:get_pos() then
			food_entities[ph][i] = nil
			return i
		end
	end
end

-- on_rightclick function to take items that are cookable in a campfire, and put them in the campfire inventory
function mcl_campfires.take_item(pos, _, player, itemstack)
	if core.get_item_group(itemstack:get_name(), "campfire_cookable") ~= 0 then
		mcl_hunger.prevent_eating (player)
		local cookable = core.get_craft_result({method = "cooking", width = 1, items = {itemstack}})
		if cookable then
			local ph = core.hash_node_position(vector.round(pos))
			local spot = get_free_spot(ph)
			if not spot then return end

			local o = core.add_entity(pos + campfire_spots[spot], "mcl_campfires:food_entity")
			o:set_properties({
				wield_item = itemstack:get_name(),
			})
			local l = o:get_luaentity()
			l._campfire_poshash = ph
			l._start_time = core.get_gametime()
			l._cook_time = cookable.time * 3 --apparently it always takes 30 secs in mc?
			l._item = itemstack:get_name()
			l._drop = cookable.item:get_name()
			l._spot = spot
			food_entities[ph][spot] = l
			if not core.is_creative_enabled(player:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
	end
end

function mcl_campfires.register_campfire(name, def)
	-- Define Campfire
	core.register_node(name, {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire.obj",
		tiles = {{name="mcl_campfires_log.png"},},
		use_texture_alpha = "clip",
		groups = table.merge (def.groups or {}, {
			handy = 1,
			axey = 1,
			material_wood = 1,
			not_in_creative_inventory = 1,
			campfire = 1,
			unmovable_by_piston = 1,
		}),
		paramtype = "light",
		paramtype2 = "4dir",
		_on_ignite = function(_, node)
			mcl_campfires.light_campfire(node.under)
			return true
		end,
		_on_arrow_hit = function(pos, arrowent)
			if mcl_burning.is_burning(arrowent.object) then
				mcl_campfires.light_campfire(pos)
			end
		end,
		drop = "",
		sounds = mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = 'fixed',
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_mcl_hardness = 2,
		after_dig_node = function(pos, _, _, digger)
			campfire_drops(pos, digger, def.drops, name.."_lit")
		end,
	})

	--Define Lit Campfire
	core.register_node(name.."_lit", {
		description = def.description,
		_tt_help = S("Cooks food and keeps bees happy."),
		_doc_items_longdesc = S("Campfires have multiple uses, including keeping bees happy, cooking raw meat and fish, and as a trap."),
		inventory_image = def.inv_texture,
		wield_image = def.inv_texture,
		drawtype = "mesh",
		mesh = "mcl_campfires_campfire.obj",
		tiles = {{
			name=def.fire_texture,
			animation={
				type="vertical_frames",
				aspect_w=32,
				aspect_h=16,
				length=2.0
			 }}
		},
		overlay_tiles = {{
			 name=def.lit_logs_texture,
			 animation = {
				 type = "vertical_frames",
				 aspect_w = 32,
				 aspect_h = 16,
				 length = 2.0,
			 }}
		},
		use_texture_alpha = "clip",
		groups = table.merge (def.groups or {}, {
			handy = 1,
			axey = 1,
			material_wood = 1,
			lit_campfire = 1,
			deco_block = 1,
			unmovable_by_piston = 1,
		}),
		paramtype = "light",
		paramtype2 = "4dir",
		on_destruct = function(pos)
			local ph = core.hash_node_position(vector.round(pos))
			for k,v in pairs(player_particlespawners) do
				if v[ph] then
					core.delete_particlespawner(v[ph])
					player_particlespawners[k][ph] = nil
				end
			end
		end,
		on_rightclick = function (pos, node, player, itemstack, pointed_thing)
			if core.get_item_group(itemstack:get_name(), "shovel") ~= 0 then
				local protected = mcl_util.check_position_protection(pos, player)
				if not protected then
					if not core.is_creative_enabled(player:get_player_name()) then
						-- Add wear (as if digging a shovely node)
						local toolname = itemstack:get_name()
						local wear = mcl_autogroup.get_wear(toolname, "shovely")
						if wear then
							itemstack:add_wear(wear)
						end
					end
					node.name = name
					core.set_node(pos, node)
					core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
				end
			elseif core.get_item_group(itemstack:get_name(), "campfire_cookable") ~= 0 then
				mcl_campfires.take_item(pos, node, player, itemstack)
			elseif itemstack and player and pointed_thing then
				core.item_place_node(itemstack, player, pointed_thing)
			end

			return itemstack
		end,
		drop = "",
		light_source = def.lightlevel,
		sounds = mcl_sounds.node_sound_wood_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5}, --left, bottom, front, right, top
		},
		collision_box = {
			type = "fixed",
			fixed = {-.5, -.5, -.5, .5, -.05, .5},
		},
		_mcl_hardness = 2,
		on_blast = on_blast,
		after_dig_node = function(pos, _, _, digger)
			drop_items(pos)
			campfire_drops(pos, digger, def.drops, name.."_lit")
		end,
		_mcl_campfires_smothered_form = name,
		_pathfinding_class = "DAMAGE_FIRE",
		damage_per_second = def.damage * 2,
	})
end

function mcl_campfires.generate_smoke(pos)
	local smoke_timer

	if core.get_node(vector.offset(pos, 0, -1, 0)).name == "mcl_farming:hay_block" then
		smoke_timer = 11.5
	else
		smoke_timer = 7.25
	end

	local ph = core.hash_node_position(pos)
	for pl in mcl_util.connected_players() do
		if not player_particlespawners[pl] then player_particlespawners[pl] = {} end
		if not player_particlespawners[pl][ph] and vector.distance(pos, pl:get_pos()) < PARTICLE_DISTANCE then
			player_particlespawners[pl][ph] = core.add_particlespawner({
				amount = 4,
				time = 0,
				minpos = vector.offset(pos, -0.1, 0.25, -0.1),
				maxpos = vector.offset(pos, 0.1, 0.25, 0.1),
				minvel = vector.new(-0.04, 0.7, -0.04),
				maxvel = vector.new(0.04, 1.0, 0.04),
				minacc = vector.new(-0.04, 0.2, -0.04),
				maxacc = vector.new(0.04, 0.4, 0.04),
				minexptime = smoke_timer - 2,
				maxexptime = smoke_timer,
				minsize = 4.0,
				maxsize = 4.5,
				collisiondetection = true,
				playername = pl:get_player_name(),
				texpool = {
					{ name = "mcl_campfires_particle_1.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_2.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_3.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_4.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_5.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_6.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_7.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_8.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_9.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_10.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_11.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_11.png", scale = 2, alpha_tween = {1, 0.25} },
					{ name = "mcl_campfires_particle_12.png", scale = 2, alpha_tween = {1, 0.25} },
				}
			})
		end
	end

	for pl,pt in pairs(player_particlespawners) do
		for _,sp in pairs(pt) do
			if not pl or not pl:get_pos() then
				core.delete_particlespawner(sp)
			elseif player_particlespawners[pl][ph] and vector.distance(pos, pl:get_pos()) > PARTICLE_DISTANCE then
				core.delete_particlespawner(player_particlespawners[pl][ph])
				player_particlespawners[pl][ph] = nil
			end
		end
		if not pl or not pl:get_pos() then
			player_particlespawners[pl] = nil
		end
	end
end

core.register_on_leaveplayer(function(player)
	if player_particlespawners[player] then
		for _,v in pairs(player_particlespawners[player]) do
			core.delete_particlespawner(v)
		end
		player_particlespawners[player] = nil
	end
end)

-- Register Visual Food Entity
core.register_entity("mcl_campfires:food_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},
	on_step = function(self,dtime)
		self._timer = (self._timer or 1) - dtime
		if self._timer > 0 then return end
		if not self._start_time or not self._campfire_poshash then
			--if self._poshash isn't set that essentially means this campfire entity was migrated. Remove it to let a new one spawn.
			self.object:remove()
		end
		if core.get_gametime() - self._start_time > (self._cook_time or 1) then
			if food_entities[self._campfire_poshash] then
				food_entities[self._campfire_poshash][self._spot] = nil
			end
			if count_table(food_entities[self._campfire_poshash]) == 0 then
				delete_entities(self._campfire_poshash or "")
			end
			core.add_item(self.object:get_pos() + ( campfire_spots[self._spot] / 1.5 ), self._drop) --divide by 1.5 since otherwise items easily clip through walls next to the fire
			self.object:remove()
		end
	end,
	get_staticdata = function(self)
		local d = {}
		for k,v in pairs(self) do
			local t = type(v)
			if  t ~= "function"	and t ~= "nil" and t ~= "userdata" then
				d[k] = self[k]
			end
		end
		return core.serialize(d)
	end,
	on_activate = function(self, staticdata)
		if type(staticdata) == "userdata" then return end
		local s = core.deserialize(staticdata)
		if type(s) == "table" then
			for k,v in pairs(s) do self[k] = v end
			self.object:set_properties({ wield_item = self._item })
			if self._campfire_poshash and ( not food_entities[self._campfire_poshash] or not food_entities[self._campfire_poshash][self._spot] ) then
				local spot = self._spot or get_free_spot(self._campfire_poshash)
				if spot and self._campfire_poshash then
					food_entities[self._campfire_poshash] = food_entities[self._campfire_poshash] or {}
					food_entities[self._campfire_poshash][spot] = self
					self._spot = spot
				else
					self.object:remove()
					return
				end
			else
				self.object:remove()
				return
			end
		end
		self._start_time = self._start_time or core.get_gametime()
		self.object:set_rotation({x = math.pi / -2, y = 0, z = 0})
		self.object:set_armor_groups({ immortal = 1 })
	end,
})

core.register_abm({
	label = "Campfire Smoke",
	nodenames = {"group:lit_campfire"},
	interval = 4,
	chance = 1,
	action = mcl_campfires.generate_smoke,
})
