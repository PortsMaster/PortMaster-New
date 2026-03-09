local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class
local is_valid = mcl_util.is_valid_objectref

local function attach_driver(self, clicker)
	mcl_title.set(clicker, "actionbar", {
		text=S("Sneak to dismount"),
		color="white", stay = 60,
	})
	self:attach(clicker)
end

local function detach_driver(self)
	if self.driver then
		self:detach (self.driver, {x=0, y=0, z=0})
	end

	if self._selectionbox_overloaded then
		self._selectionbox_overloaded = false
		self.object:set_properties ({
			selectionbox = self.collisionbox,
		})
	end
end

local function can_equip_horse_armor (entity_id)
	return entity_id == "mobs_mc:horse"
		or entity_id == "mobs_mc:skeleton_horse"
		or entity_id == "mobs_mc:zombie_horse"
end

local horse_base = {
	"mobs_mc_horse_brown.png",
	"mobs_mc_horse_darkbrown.png",
	"mobs_mc_horse_white.png",
	"mobs_mc_horse_gray.png",
	"mobs_mc_horse_black.png",
	"mobs_mc_horse_chestnut.png",
	"mobs_mc_horse_creamy.png",
}

local horse_markings = {
	"", -- no markings
	"mobs_mc_horse_markings_whitedots.png", -- snowflake appaloosa
	"mobs_mc_horse_markings_blackdots.png", -- sooty
	"mobs_mc_horse_markings_whitefield.png", -- paint
	"mobs_mc_horse_markings_white.png", -- stockings and blaze
}

local horse_textures = {}
for b=1, #horse_base do
	for m=1, #horse_markings do
		local fur = horse_base[b]
		if horse_markings[m] ~= "" then
			fur = fur .. "^" .. horse_markings[m]
		end
		table.insert(horse_textures, {
			"blank.png", -- chest
			fur, -- base texture + markings and optional armor
			"blank.png", -- saddle
		})
	end
end

-- Horse
local horse = {
	description = S("Horse"),
	type = "animal",
	_spawn_category = "creature",
	visual = "mesh",
	mesh = "mobs_mc_horse.b3d",
	visual_size = {x=3.0, y=3.0},
	collisionbox = {-0.69825, 0, -0.69825, 0.69825, 1.6, 0.69825},
	runaway = true,
	movement_speed = 6.75,
	animation = {
		stand_start = 0, stand_end = 0, stand_speed = 25,
		walk_start = 0, walk_end = 40, walk_speed = 25,
		run_start = 0, run_end = 40, run_speed = 50,
	},
	follow = {
		"mcl_farming:carrot_item_gold",
		"mcl_core:apple_gold",
		"mcl_core:apple_gold_enchanted",
	},
	textures = horse_textures,
	sounds = {
		random = "mobs_mc_horse_random",
		-- TODO: Separate damage sound
		damage = "mobs_mc_horse_death",
		death = "mobs_mc_horse_death",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	steer_class = "controls",
	_food_items = {
		["mcl_farming:wheat_item"] = {
			2.0, -- Health.
			20, -- Age delta in MC ticks.
			3, -- Temper.
		},
		["mcl_core:sugar"] = {
			1.0, -- Health.
			30, -- Age delta in MC ticks.
			3, -- Temper.
		},
		["mcl_farming:hay_block"] = {
			2.0, -- Health.
			20, -- Age delta in MC ticks.
			3, -- Temper.
		},
		["mcl_core:apple"] = {
			3.0,
			60,
			3,
		},
		["mcl_farming:carrot_item_gold"] = {
			4.0,
			60,
			5,
			true -- Breed.
		},
		["mcl_core:apple_gold"] = {
			10.0,
			240,
			10,
			true -- Breed.
		},
		["mcl_core:apple_gold_enchanted"] = {
			10.0,
			240,
			10,
			true -- Breed.
		},
	},
	hp_min = 30,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
	floats = 1,
	makes_footstep_sound = true,
	can_ride_boat = false,
	jump = true,
	drops = {
		{
			name = "mcl_mobitems:leather",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
	},
	jump_height = 14,
	fall_damage_multiplier = 0.5,
	-- Values of 1.0 precisely trigger engine bugs.
	stepheight = 1.02,
	head_eye_height = 1.52,
	_temper = 0,
	_max_temper = 120,
	pace_bonus = 0.7,
	follow_bonus = 1.25,
	follow_herd_bonus = 1.0,
	_saddle = "",
	_horse_armor_stack = "",
	_eats = true,
	_csm_driving_enabled = true,
}

function horse:on_spawn ()
	if not self._props_initialized then
		self:initial_movement_properties ()
	end
	local tex = self:extra_textures ()
	self:set_textures (tex)
end

function horse:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item ()
	local wield_food = self._food_items[wielditem:get_name ()] ~= nil
	return self.tamed or wield_food
end

------------------------------------------------------------------------
-- Horse AI.
------------------------------------------------------------------------

local pr = PcgRandom (os.time () + 343)

function horse:breeding_possible ()
	local entity_id = self.name
	return (entity_id == "mobs_mc:horse"
		or entity_id == "mobs_mc:donkey")
		and self.tamed
end

function horse:enrage ()
	-- TODO: angry noises.
end

local SOLID_PACING_GROUPS = mcl_mobs.SOLID_PACING_GROUPS

local function horse_maybe_tame (self, self_pos, dtime)
	local driver = self.driver

	if self._evaluating_handler then
		if not driver or not is_valid (driver) or self.tamed then
			self:cancel_navigation ()
			self:halt_in_tracks ()
			self._evaluating_handler = false
			return false
		end

		if self:navigation_finished () then
			self._evaluating_handler = false
			return false
		end

		-- Evaluate this handler every (on average) 50 ticks.
		local delay = math.round (50 * (dtime / 0.05))
		if pr:next (1, delay) == 1 then
			if pr:next (1, self._max_temper)
				<= self._temper + 1 then
				self:just_tame (self_pos, driver)
				self._evaluating_handler = false
				self:post_attach (driver)
				return false
			end

			self._temper = math.min (self._temper + 5,
						self._max_temper)
			detach_driver (self)
			self:enrage ()
			self._evaluating_handler = false
			return false
		end
		return true
	elseif driver and not self.tamed then
		local target = self:pacing_target (self_pos, 5, 4, SOLID_PACING_GROUPS)
		if target then
			self:gopath (target, 1.2)
			self._evaluating_handler = true
			return "_evaluating_handler"
		end
		return false
	end
end

-- local function horse_cancel_rearing (self, self_pos, dtime)
-- 	-- TODO: rearing animations.
-- end

function horse:begin_eating (dtime)
	-- TODO: eating animation.
	self._eating = dtime
end

function horse:stop_eating ()
	self._eating = nil
end

function horse:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	-- Regenerate health when idle.
	if pr:next (1, math.round (900 * dtime / 0.05)) == 1 then
		self.health = self.health + 1
		local maxhp = self.object:get_properties ().hp_max
		if self.health > maxhp then
			self.health = maxhp
		end
	end

	if self._eats then
		if not self._eating
			and not self.driver
			and pr:next (1, math.round (300 * dtime / 0.05))
			and self.standing_on == "mcl_core:dirt_with_grass" then
			self:begin_eating (2.5)
		end
		if self._eating then
			self._eating = self._eating - dtime
			if self._eating <= 0 then
				self:stop_eating ()
			end
		end
	end
end

function horse:set_animation_speed (custom_speed)
	local anim = self._current_animation
	if not anim then
		return
	end
	local name = anim .. "_speed"
	local normal_speed = self.animation[name]
		or self.animation.speed_normal
		or 25
	local speed = custom_speed or normal_speed
	local v = self:get_velocity ()
	local scaled_speed = speed * self.frame_speed_multiplier
	self.object:set_animation_frame_speed (scaled_speed * math.max (1, v / 2))
end

horse.check_tame = horse_maybe_tame

horse.ai_functions = {
	mob_class.check_frightened,
	horse_maybe_tame,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	mob_class.check_pace,
	-- horse_cancel_rearing,
}

------------------------------------------------------------------------
-- Horse armor.
------------------------------------------------------------------------

function horse:extra_textures (cstring)
	local horse = self
	local base = horse._naked_texture or horse.base_texture[2]
	local saddle = ItemStack (horse._saddle)
	local chest = horse._chest
	local armor = ItemStack (horse._horse_armor_stack)
	local armor_name = armor:get_name ()
	local textures = {}
	if not armor:is_empty ()
		and core.get_item_group (armor_name, "horse_armor") > 0 then
		if cstring then
			textures[2] = base
				.. "^("
				.. core.registered_items[armor_name]._horse_overlay_image:gsub(".png$", "_desat.png")
				.. "^[multiply:" .. cstring .. ")"
		else
			textures[2] = base .. "^"
				.. core.registered_items[armor_name]._horse_overlay_image
		end
	else
		textures[2] = base
	end
	if not saddle:is_empty () then
		textures[3] = base
	else
		textures[3] = "blank.png"
	end
	if chest then
		textures[1] = base
	else
		textures[1] = "blank.png"
	end
	return textures
end

function horse:set_armor_1 (iname, w)
	local cstring
	if core.get_item_group(iname, "armor_leather") > 0 then
		local m = w:get_meta()
		local cs = m:get_string("mcl_armor:color")
		cstring = cs ~= "" and cs or nil
	end
	local armor = core.get_item_group(iname, "horse_armor")
	self._horse_armor_stack = w:to_string ()
	self.armor = armor
	local agroups = self.object:get_armor_groups()
	agroups.fleshy = self.armor
	self.object:set_armor_groups(agroups)
	if not self._naked_texture then
		self._naked_texture = self.base_texture[2]
	end
	local tex = self:extra_textures (cstring)
	self.base_texture = tex
	self:set_textures (tex)
	local def = w:get_definition()
	if def.sounds and def.sounds._mcl_armor_equip then
		core.sound_play({name = def.sounds._mcl_armor_equip},
			{gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)
	end
end

function horse:set_armor (clicker)
	local w = clicker:get_wielded_item ()
	local iname = w:get_name ()
	if self._horse_armor_stack == "" then
		self:set_armor_1 (iname, w)
		self:update_armor_inv ()
		if not core.is_creative_enabled(clicker:get_player_name()) then
			w:take_item()
			clicker:set_wielded_item(w)
		end
		return true
	end
end

function horse:remove_armor (stack)
	self._horse_armor_stack = ""
	local def = stack:get_definition ()
	if def.sounds and def.sounds._mcl_armor_unequip then
		core.sound_play ({name = def.sounds._mcl_armor_unequip},
			{gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)
	end
	local tex = self:extra_textures ()
	self.base_texture = tex
	self:set_textures (tex)

	-- Restore initial armor values.
	self.armor = 100
	local agroups = self.object:get_armor_groups()
	agroups.fleshy = 100
	self.object:set_armor_groups(agroups)
end

------------------------------------------------------------------------
-- Horse inventories.
------------------------------------------------------------------------

local SADDLE_SLOT = 1
local ARMOR_SLOT = 2

function horse:is_saddle_item (stack)
	return stack:get_name () == "mcl_mobitems:saddle"
end

local function armor_allow_move (inv, from_list, from_index, to_list, to_index, count, player)
	return 0
end

local function armor_allow_put (horse, inv, listname, index, stack, player)
	if index == ARMOR_SLOT then
		local armor = core.get_item_group (stack:get_name (),
						       "horse_armor")
		return armor > 1 and 1 or 0
	elseif index == SADDLE_SLOT then
		local saddle = horse:is_saddle_item (stack)
		return saddle and 1 or 0
	end
	return 1
end

local function armor_on_put (horse, inv, listname, index, stack, player)
	if index == SADDLE_SLOT then
		horse:set_saddle (stack, nil)
	elseif index == ARMOR_SLOT then
		horse:set_armor_1 (stack:get_name (), stack)
	end
end

local function armor_on_take (horse, inv, listname, index, stack, player)
	if index == SADDLE_SLOT then
		horse:remove_saddle ()
	elseif index == ARMOR_SLOT then
		horse:remove_armor (stack)
	end
end

local horse_inventory_counter = 0

function horse:get_staticdata_table ()
	local supertable = mob_class.get_staticdata_table (self)
	if supertable then
		supertable._armor_inv = nil
		supertable._armor_inv_name = nil
	end
	return supertable
end

function horse:post_load_staticdata ()
	mob_class.post_load_staticdata (self)
	-- Update old horses.
	if self._horse_armor and self._wearing_armor then
		self._horse_armor_stack
			= ItemStack (self._horse_armor):to_string ()
	end
	if self._saddle and type (self._saddle) ~= "string" then
		self._saddle
			= ItemStack ("mcl_mobitems:saddle"):to_string ()
	end
	if not self._saddle then
		self._saddle = ""
	end
	if not self._horse_armor_stack then
		self._horse_armor_stack = ""
	end
	self._horse_armor = nil
end

function horse:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	-- Erase obsolete drop lists.
	self.drops = nil
	-- Reconfigure maximum HP.
	if self.hp_max then
		self.object:set_properties ({
				hp_max = self.hp_max,
		})
		self.health = math.min (self.health, self.hp_max)
	end
	self._selectionbox_overloaded = false
	self:init_attachment_position ()
	return true
end

function horse:on_deactivate (removal)
	if self.driver then
		mcl_player.set_inventory_formspec (self.driver, nil, 100)
	end

	mob_class.on_deactivate (self, removal)

	if self._armor_inv_name then
		core.remove_detached_inventory (self._armor_inv_name)
		self._armor_inv_name = nil
		self._armor_inv = nil
	end
end

function horse:update_armor_inv ()
	if not self._armor_inv then
		return
	end
	local stack = ItemStack (self._saddle)
	self._armor_inv:set_stack ("main", SADDLE_SLOT, stack)
	stack = ItemStack (self._horse_armor_stack)
	self._armor_inv:set_stack ("main", ARMOR_SLOT, stack)
end

function horse:generate_inventory_formspec ()
	if not self._armor_inv_name then
		return "formspec_version[6]"
	end
	local objectname = mcl_util.get_object_name (self.object)
	objectname = core.formspec_escape (objectname)
	local armorname = self._armor_inv_name
	armorname = core.formspec_escape ("detached:" .. armorname)
	local chest_itemslots
	if self._chest then
		chest_itemslots = string.format ("list[detached:%s;main;5.375,0.875;5,3;]",
					 self._inv_id)
	else
		chest_itemslots = "image[5.375,0.825;6.10,3.625;mcl_formspec_itemslot.png;2]"
	end
	local nslots
	if can_equip_horse_armor (self.name) then
		nslots = 2
	else
		nslots = 1
	end
	return table.concat ({
		"formspec_version[6]",
		"size[11.75,10.45]",
		"position[0.5,0.5]",
		string.format ("label[0.375,0.5;%s]", objectname),
		mcl_formspec.get_itemslot_bg_v4 (0.375, 0.875, 1, nslots),
		string.format ("list[%s;main;0.375,0.875;1,%d;]", armorname, nslots),
		"image[1.55,0.825;3.625,3.625;mcl_inventory_background9.png;2]",
		string.format ("model[1.55,0.875;3.625,3.5;horse;mobs_mc_horse.b3d;%s;%s]",
			       table.concat (self.base_texture, ","), "0,45,0"),
		self._chest and mcl_formspec.get_itemslot_bg_v4 (5.375, 0.875, 5, 3) or "",
		chest_itemslots,
		-- Main inventory.
		mcl_formspec.get_itemslot_bg_v4 (0.375, 5, 9, 3),
		"list[current_player;main;0.375,5;9,3;9]",
		-- Hotbar.
		mcl_formspec.get_itemslot_bg_v4 (0.375, 8.95, 9, 1),
		"list[current_player;main;0.375,8.95;9,1;]",
		string.format ("listring[%s;main]", armorname),
		self._chest and string.format ("listring[detached:%s;main]",
					self._inv_id) or "",
		"listring[current_player;main]",
	})
end

function horse:post_attach (player)
	if not self._armor_inv then
		-- Create a temporary inventory that holds armor and
		-- saddles and populate it with any such items already
		-- present.
		local name = self.name .. ":" .. horse_inventory_counter
		horse_inventory_counter = horse_inventory_counter + 1
		local inventory = core.create_detached_inventory (name, {
			allow_move = armor_allow_move,
			allow_put = function (inv, listname, index, stack, player)
				return armor_allow_put (self, inv, listname, index, stack, player)
			end,
			on_put = function (inv, listname, index, stack, player)
				return armor_on_put (self, inv, listname, index, stack, player)
			end,
			on_take = function (inv, listname, index, stack, player)
				return armor_on_take (self, inv, listname, index, stack, player)
			end,
		})
		self._armor_inv_name = name
		self._armor_inv = inventory
		if can_equip_horse_armor (self.name) then
			inventory:set_size ("main", 2)
		else
			inventory:set_size ("main", 1)
		end
		self:update_armor_inv ()
	end
	local formspec = self:generate_inventory_formspec ()
	mcl_player.set_inventory_formspec (player, formspec, 100)
	mcl_entity_invs.load_inv (self, 15)
	self.object:set_properties ({
		selectionbox = {0,0,0,0,0,0},
	})
	self._selectionbox_overloaded = true
end

function horse:attach (player, server_side)
	if mob_class.attach (self, player, server_side) then
		if self.tamed then
			self:post_attach (player)
		end
		return true
	end
	return false
end

function horse:complete_attachment (player, state)
	mob_class.complete_attachment (self, player, state)
	if self.tamed then
		self:post_attach (player)
	end
end

function horse:detach (player)
	mob_class.detach (self, player)
	if not self.tamed then
		return
	end
	mcl_player.set_inventory_formspec (player, nil, 100)
	mcl_entity_invs.save_inv (self)
	if self._armor_inv_name then
		core.remove_detached_inventory (self._armor_inv_name)
		self._armor_inv_name = nil
		self._armor_inv = nil
	end
end

function horse:set_textures (texturelist)
	mob_class.set_textures (self, texturelist)
	if not self.tamed then
		return
	end
	if self.driver then
		local formspec = self:generate_inventory_formspec ()
		mcl_player.set_inventory_formspec (self.driver, formspec, 100)
	end
end

function horse:drop_armor (bonus)
	local self_pos = self.object:get_pos ()
	if self._saddle ~= "" then
		local stack = ItemStack (self._saddle)
		mcl_util.drop_item_stack (self_pos, stack)
	end
	if self._horse_armor_stack ~= "" then
		local stack = ItemStack (self._horse_armor_stack)
		mcl_util.drop_item_stack (self_pos, stack)
	end
	if self._chest then
		local stack = ItemStack ("mcl_chests:chest")
		mcl_util.drop_item_stack (self_pos, stack)
	end
	self._horse_armor_stack = ""
	self._saddle = ""
	self._chest = false
end

------------------------------------------------------------------------
-- Horse mounting.
------------------------------------------------------------------------

function horse:should_drive ()
	return self._saddle ~= "" and mob_class.should_drive (self)
end

function horse:apply_driver_input (velocity, self_pos, moveresult, dtime)
	mob_class.apply_driver_input (self, velocity, self_pos, moveresult, dtime)

	self._jump = false
	local controls = self.driver:get_player_control ()
	if controls.jump then
		if self._jump_charge == nil then
			self._jump_charge = 0.0
		end
		local charge = self._jump_charge
		self._jump_charge = charge + dtime
	end
end

function horse:post_apply_driver_input (velocity, self_pos, moveresult, dtime)
	local controls = self.driver:get_player_control ()
	if not controls.jump
		and self._jump_charge and self._jump_charge > 0.0 then
		if not moveresult.touching_ground
			or moveresult.standing_on_object then
			return
		end

		local mc_ticks = math.floor (self._jump_charge * 20)
		local scale

		if mc_ticks >= 10 then
			scale = 0.8 + 2.0 / (mc_ticks - 9) * 0.1
		else
			scale = mc_ticks * 0.1
		end
		if scale >= 0.9 then
			scale = 1.0
		else
			scale = 0.4 + 0.4 * scale / 0.9
		end

		-- TODO: horses should rear up after jumping.
		local v = self.object:get_velocity ()
		v.y = scale * self.jump_height
		self.object:set_velocity (v)
		self._jump_charge = 0
	end
end

function horse:init_attachment_position ()
	local vsize = self.object:get_properties().visual_size
	self.driver_attach_at = {x = 0, y = 4.17, z = -1.75}
	self.driver_eye_offset = {x = 0, y = 3, z = 0}
	self.driver_scale = {x = 1/vsize.x, y = 1/vsize.y}
end

function horse:do_custom (dtime)
	if self.driver then
		local ctrl = self.driver:get_player_control ()
		if ctrl and ctrl.sneak then
			detach_driver (self)
		end
	else
		detach_driver (self)
		self._jump_charge = nil

		if self._armor_inv_name then
			core.remove_detached_inventory (self._armor_inv_name)
			self._armor_inv_name = nil
			self._armor_inv = nil
		end
	end

	return true
end

function horse:on_die ()
	if self.driver then
		detach_driver(self)
	end
end

function horse:allow_mount (clicker)
	return true
end

function horse:on_rightclick (clicker)
	if not clicker or not clicker:is_player() then
		return
	end

	local item = clicker:get_wielded_item()
	local iname = item:get_name()
	local creative = core.is_creative_enabled (clicker:get_player_name())

	if self.child and not self._food_items[iname] then
		return
	end

	if self._inv_id then
		if not self._chest and iname == "mcl_chests:chest" then
			item:take_item()
			clicker:set_wielded_item(item)
			self._chest = true
			-- Update texture
			if not self._naked_texture then
				-- Base horse texture without chest or saddle
				self._naked_texture = self.base_texture[2]
			end
			local tex = self:extra_textures ()
			self.base_texture = tex
			self:set_textures (tex)
			return
		elseif self._chest and clicker:get_player_control().sneak then
			mcl_entity_invs.show_inv_form(self,clicker)
			return
		end
	end

	-- Feed on and potentially consume food items.
	local food_desc = self._food_items[iname]
	if food_desc then
		local heal, age, temper, breed = unpack (food_desc)
		local consume

		-- Heal and/or age mob if necessary.
		local maxhp = self.object:get_properties ().hp_max
		if heal and self.health < maxhp then
			self.health = math.min (maxhp, self.health + heal)
			consume = true
		end
		if self.child and age > 0 then
			self.hornytimer = self.hornytimer + age
			consume = true
		end
		if temper and not self.child then
			if self._temper < self._max_temper then
				self._temper = self._temper + temper
				if self._temper > self._max_temper then
					self._temper = self._max_temper
				end
				consume = true
			end
		end
		if breed and not self.child
			and self:feed_tame (clicker, 0, true, false) then
			consume = true
		end
		if consume and not creative then
			item:take_item ()
			clicker:set_wielded_item (item)
		end
		return
	end

	local saddle = self._saddle ~= "" and ItemStack(self._saddle)
	local armor = self._horse_armor_stack ~= "" and ItemStack(self._horse_armor_stack)

	if self.tamed and not self.child and self.owner == clicker:get_player_name() then
		if not self.driver and clicker:get_player_control().sneak then
			return
		elseif not self.driver
			and self:is_saddle_item (item)
			and self:set_saddle (item, clicker) then
			return
		elseif core.get_item_group(iname, "horse_armor") > 0
			and can_equip_horse_armor(self.name)
			and not self.driver and self:set_armor(clicker) then
			return
		elseif core.get_item_group(iname, "shears") > 0 and
			not self.driver and (armor or saddle) then
			local pos = self.object:get_pos()
			if armor then
				self:remove_armor(armor)
				if not creative then core.add_item(pos, armor) end
			elseif saddle then
				self:remove_saddle()
				if not creative then core.add_item(pos, saddle) end
			end
			core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
			if not creative then
				local wear = mcl_autogroup.get_wear(iname, "shearsy")
				item:add_wear(wear)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
			return
		end
	end

	-- It shouldn't be possible to mount an untamed horse without
	-- an empty hand.
	if not item:is_empty () and not self.tamed then
		self:enrage ()
		return
	end

	if not self.driver and self:allow_mount (clicker) then
		self._jump_charge = nil
		attach_driver (self, clicker)
	end
end

function horse:set_saddle (stack, clicker)
	if self._saddle == "" then
		self._saddle = stack:peek_item ():to_string ()
		if clicker then
			local name = clicker:get_player_name ()
			if not core.is_creative_enabled (name) then
				stack:take_item ()
				clicker:set_wielded_item (stack)
			end
			self:update_armor_inv ()
		end
		if not self._naked_texture then
			self._naked_texture = self.base_texture[2]
		end
		local tex = self:extra_textures ()
		self.base_texture = tex
		self:set_textures (tex)
		core.sound_play({name = "mcl_armor_equip_leather"},
			{gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)
		return true
	end
end

function horse:remove_saddle ()
	self._saddle = ""
	if not self._naked_texture then
		self._naked_texture = self.base_texture[2]
	end
	local tex = self:extra_textures ()
	self.base_texture = tex
	self:set_textures (tex)
	core.sound_play ({name = "mcl_armor_unequip_leather"},
		{gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)
end

------------------------------------------------------------------------
-- Horse breeding and attributes.
------------------------------------------------------------------------

function horse:generate_hp_max (rand, rand1)
	return 15.0 + (rand or pr:next (0, 8)) + (rand1 or pr:next (0, 9))
end

local r = 1 / 2147483647

function horse:generate_jump_height (rand)
	local t1, t2, t3
	t1 = (rand or pr:next (0, 2147483647) * r) * 0.2
	t2 = (rand or pr:next (0, 2147483647) * r) * 0.2
	t3 = (rand or pr:next (0, 2147483647) * r) * 0.2

	return (0.4 + t1 + t2 + t3) * 20
end

function horse:generate_movement_speed (rand)
	local t1, t2, t3
	t1 = (rand or pr:next (0, 2147483647) * r) * 0.3
	t2 = (rand or pr:next (0, 2147483647) * r) * 0.3
	t3 = (rand or pr:next (0, 2147483647) * r) * 0.3

	return (0.45 + t1 + t2 + t3) * 20 * 0.25
end

function horse:initial_movement_properties ()
	local hp_max = self:generate_hp_max ()
	local jump_height = self:generate_jump_height ()
	local speed = self:generate_movement_speed ()

	self.object:set_properties ({
			hp_max = hp_max,
	})
	self.jump_height = jump_height
	self.movement_speed = speed
	self.health = hp_max
	self.hp_max = hp_max
end

function horse:derive_child_properties (p1, p2)
	local hp_max = self:generate_hp_max (8, 9)
	local jump_max = self:generate_jump_height (1.0)
	local speed_max = self:generate_movement_speed (1.0)
	local hp_min = self:generate_hp_max (0, 0)
	local jump_min = self:generate_jump_height (0.0)
	local speed_min = self:generate_movement_speed (0.0)
	local props_p1 = p1.object:get_properties ()
	local props_p2 = p2.object:get_properties ()
	local value = self:child_properties (props_p1.hp_max,
					     props_p2.hp_max,
					     hp_min, hp_max)
	self.object:set_properties ({
		hp_max = value,
	})
	self.hp_max = hp_max
	self.health = value
	value = self:child_properties (p1:stock_value ("jump_height"),
				       p2:stock_value ("jump_height"),
				       jump_min, jump_max)
	self.jump_height = value
	value = self:child_properties (p1:stock_value ("movement_speed"),
				       p2:stock_value ("movement_speed"),
				       speed_min, speed_max)
	self.movement_speed = value
end

-- https://old.reddit.com/r/Minecraft/comments/14zdge0/statistics_and_psuedocode_for_the_new_horse/
function horse:child_properties (p1, p2, min, max)
	p1 = math.min (math.max (p1, min), max)
	p2 = math.min (math.max (p2, min), max)
	local t1 = 0.15 * (max - min)
	local t2 = math.abs (p1 - p2) + t1 * 2
	local t3 = (p1 + p2) / 2
	local t4 = pr:next (0, 2147483647) * r
	local t5 = pr:next (0, 2147483647) * r
	local t6 = pr:next (0, 2147483647) * r
	local t7 = (t4 + t5 + t6) / 3
	local t8 = t3 + t2 * t7
	if t8 > max then
		return max - (t8 - max)
	elseif t8 < min then
		return min + (min - t8)
	end
	return t8
end

function horse:on_grown ()
	self:init_attachment_position ()
	self.can_ride_boat = false
	self.object:set_detach ()
end

function horse:on_breed (parent1, parent2)
	local pos = parent1.object:get_pos()
	local child = mcl_mobs.spawn_child(pos, parent1.name)
	if child then
		local ent_c = child:get_luaentity()
		local p = math.random(1, 2)
		local child_texture
		if p == 1 then
			if parent1._naked_texture then
				child_texture = parent1._naked_texture
			else
				child_texture = parent1.base_texture[2]
			end
		else
			if parent2._naked_texture then
				child_texture = parent2._naked_texture
			else
				child_texture = parent2.base_texture[2]
			end
		end
		local splt = string.split(child_texture, "^")
		if #splt >= 2 then
			local base = splt[1]
			local markings = splt[2]
			local mutate_base = pr:next (1, 9)
			local mutate_markings = pr:next (1, 9)
			if mutate_base == 1 then
				local b = math.random(1, #horse_base)
				base = horse_base[b]
			end
			if mutate_markings == 1 then
				local m = math.random(1, #horse_markings)
				markings = horse_markings[m]
			end
			child_texture = base
			if markings ~= "" then
				child_texture = child_texture .. "^" .. markings
			end
		end
		ent_c.base_texture = { "blank.png", child_texture, "blank.png" }
		ent_c._naked_texture = child_texture
		ent_c:set_textures (ent_c.base_texture)
		ent_c:derive_child_properties (parent1, parent2)
		ent_c.can_ride_boat = true

		return false
	end
end

mcl_mobs.register_mob ("mobs_mc:horse", horse)
mobs_mc.horse = horse

------------------------------------------------------------------------
-- Skeleton & Zombie Horse
------------------------------------------------------------------------

local skeleton_horse = table.merge(horse, {
	description = S("Skeleton Horse"),
	breath_max = -1,
	armor = {undead = 100, fleshy = 100},
	textures = {{"blank.png", "mobs_mc_horse_skeleton.png", "blank.png"}},
	drops = {
		{
			name = "mcl_mobitems:bone",
			chance = 1,
			min = 0,
			max = 2,
		},
	},
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		eat = "mobs_mc_animal_eat_generic",
		base_pitch = 0.95,
		distance = 16,
	},
	movement_speed = 4.0,
	harmed_by_heal = true,
	_trap_age = 0,
	_is_trap = false,
	_eats = false,
	floats = 0,
})

function skeleton_horse:_on_lightning_strike ()
	-- Immune to lightning.
	return true
end

function skeleton_horse:do_custom (dtime, moveresult)
	horse.do_custom (self, dtime, moveresult)
	if not self._is_trap then
		return
	end
	self._trap_age = self._trap_age + dtime
	if self._trap_age > 900 then
		self:safe_remove ()
		return false
	end
end

local function get_helmet (skeleton)
	if skeleton.armor_list.head ~= "" then
		local stack = ItemStack (skeleton.armor_list.head)
		stack:get_meta ():set_string ("mcl_enchanting:enchantments", "")
		return stack
	end
	return ItemStack ("mcl_armor:helmet_iron")
end

local function check_skeleton_trap (self, self_pos, dtime)
	if not self._is_trap then
		return false
	end
	if not self:check_timer ("skeleton_trap", 0.15) then
		return false
	end
	for player in mcl_util.connected_players (self_pos, 10) do
		self._is_trap = false
		mcl_lightning.strike (self_pos, true)
		self.tamed = true

		-- Spawn three horses.
		local horses = { self.object, }
		for _ = 1, 3 do
			local horse = core.add_entity (self_pos, self.name)
			if horse then
				table.insert (horses, horse)
				local entity = horse:get_luaentity ()
				entity.tamed = true
				entity.persistent = true
			end
		end

		local mob_factor = mcl_worlds.get_special_difficulty (self_pos)
		-- Spawn skeletons for each horse.
		for _, horse in pairs (horses) do
			local skelly = core.add_entity (self_pos, "mobs_mc:skeleton")
			if skelly then
				local entity = skelly:get_luaentity ()
				entity:jock_to_existing (horse, "", {
					x = 0,
					y = 1.6,
					z = 0,
				}, vector.zero ())
				-- Equip it with an enchanted iron
				-- helmet and bow (or whatever it
				-- generated with) between levels 5.0
				-- and 23.
				local helmet = get_helmet (entity)
				local level = 5.0 + math.random (18) * mob_factor
				mcl_enchanting.enchant_randomly (helmet, level, false, false, true)
				entity.persistent = true
				entity.armor_list.head = helmet:to_string ()
				entity:set_armor_texture ()

				local bow = ItemStack ("mcl_bows:bow")
				local level = 5.0 + math.random (18) * mob_factor
				mcl_enchanting.enchant_randomly (bow, level, false, false, true)
				entity:set_wielditem (bow)
			end
		end
		return false
	end
end

function skeleton_horse:initial_movement_properties ()
	local jump_height = self:generate_jump_height ()
	self.jump_height = jump_height
end

skeleton_horse.follow = {}
skeleton_horse._food_items = {}

function skeleton_horse:on_rightclick (clicker)
	if self.tamed then
		return horse.on_rightclick (self, clicker)
	end
end

skeleton_horse.ai_functions = {
	check_skeleton_trap,
	mob_class.check_frightened,
	mob_class.check_pace,
	-- horse_cancel_rearing,
}

mcl_mobs.register_mob("mobs_mc:skeleton_horse", skeleton_horse)

mcl_mobs.register_mob("mobs_mc:zombie_horse", table.merge(skeleton_horse, {
	description = S("Zombie Horse"),
	textures = {{"blank.png", "mobs_mc_horse_zombie.png", "blank.png"}},
	drops = {
		{
			name = "mcl_mobitems:rotten_flesh",
			chance = 1,
			min = 0,
			max = 2,
		},
	},
	sounds = {
		random = "mobs_mc_horse_random",
		-- TODO: Separate damage sound
		damage = "mobs_mc_horse_death",
		death = "mobs_mc_horse_death",
		eat = "mobs_mc_animal_eat_generic",
		base_pitch = 0.5,
		distance = 16,
	},
	ai_functions = {
		mob_class.check_frightened,
		mob_class.check_pace,
	},
}))

------------------------------------------------------------------------
-- Donkeys.
------------------------------------------------------------------------

local d = 0.86
local donkey = table.merge (horse, {
	description = S("Donkey"),
	textures = {{"blank.png", "mobs_mc_donkey.png", "blank.png"}},
	movement_speed = 3.5,
	head_eye_height = 1.425,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40,
		run_speed = 50
	},
	sounds = {
		random = "mobs_mc_donkey_random",
		damage = "mobs_mc_donkey_hurt",
		death = "mobs_mc_donkey_death",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	visual_size = { x=horse.visual_size.x*d, y=horse.visual_size.y*d },
	collisionbox = {
		horse.collisionbox[1] * d,
		horse.collisionbox[2] * d,
		horse.collisionbox[3] * d,
		horse.collisionbox[4] * d,
		horse.collisionbox[5] * d,
		horse.collisionbox[6] * d,
	},
	-- MC Wiki is completely wrong: the Minecraft value is 0.5
	-- (not 0.4), not 0.175, and which multiplied by 20 yields
	-- 10.0.
	jump_height = 10.0,
})

function donkey:initial_movement_properties ()
	local hp_max = self:generate_hp_max ()

	self.object:set_properties ({
			hp_max = hp_max,
	})
	self.hp_max = hp_max
	self.health = hp_max
end

function donkey:same_species (ent)
	return ent.name == self.name
		or ent.name == "mobs_mc:horse"
end

function donkey:on_breed (parent1, parent2)
	-- parent1 (self) is guaranteed to be a donkey, because only
	-- `same_species' is only overridden for them.

	local name = parent2.name == "mobs_mc:horse"
		and "mobs_mc:mule" or parent1.name
	local pos = parent1.object:get_pos ()
	local child = mcl_mobs.spawn_child (pos, name)
	if child then
		local ent_c = child:get_luaentity ()
		ent_c:derive_child_properties (parent1, parent2)
		return false
	end
end

mcl_mobs.register_mob ("mobs_mc:donkey", donkey)
mcl_entity_invs.register_inv ("mobs_mc:donkey", "Donkey", 15, true)

------------------------------------------------------------------------
-- Mules.
------------------------------------------------------------------------

local m = 0.94
local mule = table.merge(donkey, {
	description = S("Mule"),
	textures = {{"blank.png", "mobs_mc_mule.png", "blank.png"}},
	visual_size = { x=horse.visual_size.x*m, y=horse.visual_size.y*m },
	sounds = table.merge(donkey.sounds, {
		base_pitch = 1.15,
	}),
	head_eye_height = 1.52,
	collisionbox = {
		horse.collisionbox[1] * m,
		horse.collisionbox[2] * m,
		horse.collisionbox[3] * m,
		horse.collisionbox[4] * m,
		horse.collisionbox[5] * m,
		horse.collisionbox[6] * m,
	},
})
mule.ai_functions = {
	mob_class.check_frightened,
	horse_maybe_tame,
	mob_class.check_pace,
}

mcl_mobs.register_mob ("mobs_mc:mule", mule)
mcl_entity_invs.register_inv ("mobs_mc:mule", "Mule", 15, true)

------------------------------------------------------------------------
-- Horse Spawning.
------------------------------------------------------------------------

mcl_mobs.register_egg("mobs_mc:horse", S("Horse"), "#c09e7d", "#eee500", 0)
mcl_mobs.register_egg("mobs_mc:skeleton_horse", S("Skeleton Horse"), "#68684f", "#e5e5d8", 0)
mcl_mobs.register_egg("mobs_mc:zombie_horse", S("Zombie Horse"), "#2a5a37", "#84d080", 0)
mcl_mobs.register_egg("mobs_mc:donkey", S("Donkey"), "#534539", "#867566", 0)
mcl_mobs.register_egg("mobs_mc:mule", S("Mule"), "#1b0200", "#51331d", 0)

------------------------------------------------------------------------
-- Modern Horse & Donkey Spawning.
------------------------------------------------------------------------

local horse_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:horse",
	weight = 5,
	pack_min = 2,
	pack_max = 6,
	biomes = {
		"Plains",
		"SunflowerPlains",
	},
})

local horse_spawner_savannah = table.merge (horse_spawner, {
	weight = 1,
	biomes = {
		"#is_savannah",
	},
})

local donkey_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:donkey",
	weight = 1,
	pack_min = 1,
	pack_max = 3,
	biomes = {
		"#is_savannah",
	},
})

local donkey_spawner_meadow = table.merge (donkey_spawner, {
	pack_max = 1,
	biomes = {
		"Meadow",
	},
})

mcl_mobs.register_spawner (horse_spawner)
mcl_mobs.register_spawner (horse_spawner_savannah)
mcl_mobs.register_spawner (donkey_spawner)
mcl_mobs.register_spawner (donkey_spawner_meadow)
