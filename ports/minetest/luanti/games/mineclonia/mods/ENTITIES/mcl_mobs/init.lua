mcl_mobs = {}

------------------------------------------------------------------------
-- Temporary performance hacks.
------------------------------------------------------------------------

-- If mcl_mobs is a trusted mod, it may be possible to extract the
-- definition of `get_node_raw' from core.get_node and avoid
-- garbage collection incurred by table allocation in the loop below.

mcl_mobs.get_node_raw = core.get_node_raw
local env = core.request_insecure_environment ()

if env and not mcl_mobs.get_node_raw then
	local get_node = core.get_node
	local i = 1
	while true do
		local name, upvalue = env.debug.getupvalue (get_node, i)
		if not name then
			break
		end

		if name == "get_node_raw" then
			mcl_mobs.get_node_raw = upvalue
			break
		end

		i = i + 1
	end
end

------------------------------------------------------------------------
-- Mob initialization.
------------------------------------------------------------------------

mcl_mobs.registered_mobs = {}
local modname = core.get_current_modname()
local path = core.get_modpath(modname)
local S = core.get_translator(modname)

local old_spawn_icons = core.settings:get_bool("mcl_old_spawn_icons",false)

local object_properties = { "hp_max", "breath_max", "zoom_fov", "eye_height", "physical", "collide_with_objects", "collisionbox", "selectionbox", "pointable", "visual", "visual_size", "mesh", "textures", "colors", "use_texture_alpha", "spritediv", "initial_sprite_basepos", "is_visible", "makes_footstep_sound", "automatic_rotate", "stepheight", "automatic_face_movement_dir", "automatic_face_movement_max_rotation_per_sec", "backface_culling", "glow", "nametag", "nametag_color", "nametag_bgcolor", "infotext", "static_save", "damage_texture_modifier", "shaded", "show_on_minimap", }

--default values
mcl_mobs.mob_class = {
	initial_properties = {
		physical = true,
		collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		selectionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		visual_size = {x = 1, y = 1},
		stepheight = 0.6,
		breath_max = 15,
		makes_footstep_sound = false,
		automatic_face_movement_max_rotation_per_sec = 300,
		hp_max = 20,
		collide_with_objects = false,
	},
	max_name_length = 30,
	head_pitch_multiplier = 1,
	_head_pitch_offset = 0,
	_head_rot_limit = math.pi / 3, -- 60 degrees.
	bone_eye_height = 1.4,
	head_eye_height = 0,
	curiosity = 1,
	head_yaw = "y",
	horizontal_head_height = 0,
	fly = false,
	fly_in = {"air", "__airlike"},
	swims = false,
	swims_in = { "mcl_core:water_source", "mclx_core:river_water_source", 'mcl_core:water_flowing', 'mclx_core:river_water_flowing' },
	ranged_attack_radius = 20,
	owner = "",
	order = "",
	jump_height = 8.4,
	rotate = 0, --  0=front, 90=side, 180=back, 270=side2
	xp_min = 0,
	xp_max = 0,
	breathes_in_water = false,
	water_damage = 0,
	lava_damage = 8,
	fire_damage = 1,
	_mcl_freeze_damage = 2,
	suffocation = true,
	fall_damage = 1,
	fall_speed = -1.6, -- Accelerate by 1.6 m/s per Minecraft tick.
	gravity_drag = nil,
	_apply_gravity_drag_on_ground = false,
	drops = {},
	armor = 100,
	sounds = {},
	animation = {},
	knock_back = true,
	shoot_offset = 0,
	_projectile_gravity = true,
	floats = 1,
	floats_on_lava = false,
	water_friction = 0.8,
	-- This is multiplied by water_friction as in Minecraft.
	water_velocity = 0.4,
	timer = 0,
	env_damage_timer = 0,
	tamed = false,
	pause_timer = 0,
	horny = false,
	hornytimer = 0,
	gotten = false,
	health = 0,
	frame_speed_multiplier = 1,
	reach = 3,
	htimer = 0,
	texture_list = {},
	time_of_day = 0.5,
	runaway_timer = 0,
	runaway_from = nil,
	avoid_range = 6.0,
	melee_interval = 1,
	_melee_esp = false,
	custom_attack_interval = 1,
	ranged_interval_min = 1.0,
	ranged_interval_max = 1.0,
	_crossbow_backoff_threshold = nil,
	attack_animals = false,
	attack_npcs = false,
	_neutral_to_players = false,
	is_mob = true,
	pushable = true,
	ignores_nametag = false,
	rain_damage = 0,
	child = false,
	-- A list unique to each entity is created in on_activate.
	texture_mods = nil,
	suffocation_timer = 0,
	movement_speed = 14, -- https://minecraft.wiki/w/Attribute#movementSpeed
	driver = nil,
	_csm_driving_enabled = false,
	_csm_driving = nil,
	_driving_sent = nil,
	pace_bonus = 1.0,
	run_bonus = 1.25,
	follow_bonus = 1.2,
	follow_herd_bonus = nil, -- Default value is that of follow_bonus.
	drive_bonus = 1.0,
	pursuit_bonus = 1.0,
	breed_bonus = 1.0,
	runaway_bonus_near = 1.25,
	runaway_bonus_far = 1.0,
	restriction_bonus = 1.0,
	runaway_view_range = 16,
	_runaway_player_view_range = nil,
	_runaway_monster_view_range = nil,
	follow_distance = 6.0,
	-- Distance at which targets will be acquired and relinquished
	-- respectively.
	view_range = 16.0,
	tracking_distance = 16.0,
	stop_distance = 2,
	instant_death = false,
	fire_resistant = false,
	fire_damage_resistant = false,
	ignited_by_sunlight = false,
	tnt_knockback = true,
	does_not_prevent_sleep = false,
	prevents_sleep_when_hostile = false,
	persist_in_peaceful = true,
	wears_armor = false,
	_armor_texture_slots = 1,
	_armor_transforms = {},
	steer_class = "controls",
	steer_item = nil,
	swim_max_pitch = 85 * math.pi / 180,
	max_yaw_movement = 10 * math.pi / 180,
	swim_speed_factor = 0.02,
	idle_gravity_in_liquids = false,
	grounded_speed_factor = 0.10,
	fixed_grounded_speed = nil,
	pace_chance = 120,
	pace_interval = 5,
	pace_height = 7,
	pace_width = 10,
	flops = false,
	initialize_group = nil,
	_hovers = false,
	airborne_speed = 8.0,
	_airborne_agile = false,
	chase_owner_distance = 10.0,
	stop_chasing_distance = 2.0,
	_is_idle_activity = {
		pacing = true,
		herd_following = true,
		traveling_to_owner = true,
	},
	can_open_doors = false,
	can_ride_boat = true,
	can_ride_cart = true,
	knockback_resistance = 0.0,
	can_wield_items = false,
	wielditem_type = nil,
	wielditem_drop_probability = 0.0,
	ignite_targets_while_burning = false,
	climb_powder_snow = false,
	breeding_possible = nil,
	acceptable_pacing_target = nil,
	fall_damage_multiplier = 1.0,
	_sprinting = false,
	_crouching = false,
	_dominant_in_jockeys = true,
	_inventory_size = nil,
	_persistent_physics_factors = {},
	_old_head_swivel_vector = vector.zero (),
	_old_head_swivel_pos = vector.zero (),
	_head_axis_scale = nil,

	-- Field consulted by new spawning routines.
	_spawn_category = "misc",

	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,

	--internal variables
	_timers_fired = {},
	_inactivity_timer = 0,
	standing_in = "ignore",
	standing_on = "ignore",
	_last_standing_in = nil,
	_last_standing_on = nil,
	opinion_sound_cooloff = 7, -- used to prevent sound spam of particular sound types
	_frozen_for = 0,
	_restriction_center = nil,
	_restriction_size = 0,
	_direct_sunlight = 0,
	_physics_factors = nil,
	_immersion_depth = 0,
	_activated = false,
	_stuck_in = nil,
	_water_current = vector.zero (),
	_liquidtype = nil,
	_last_liquidtype = nil,
	raidmob = false,
	_depth_strider_level = 0,
	_soul_speed_level = 0,
	_last_soul_speed_bonus = 0,
	_active_targeting_rule = nil,
	_active_target = nil,
	_object_search_lists = {},
}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}
mcl_mobs.fallback_node = core.registered_aliases["mapgen_dirt"] or "mcl_core:dirt"

-- get node but use fallback for nil or unknown
function mcl_mobs.node_ok(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = core.get_node_or_nil(pos)
	if node and core.registered_nodes[node.name] then
		return node
	end
	return { name = fallback, param1 = 0, param2 = 0 }
end

--api and helpers
-- -- profiler
-- dofile (path .. "/profiler.lua")
-- effects: sounds and particles mostly
dofile(path .. "/effects.lua")
-- physics: involuntary mob movement - particularly falling and death
dofile(path .. "/physics.lua")
-- movement: general voluntary mob movement, walking avoiding cliffs etc.
dofile(path .. "/movement.lua")
-- items: item management for mobs
dofile(path .. "/items.lua")
-- pathfinding: pathfinding to target positions
dofile(path .. "/pathfinding.lua")
-- combat: attack logic
dofile(path .. "/combat.lua")
-- the enity functions themselves
dofile(path .. "/api.lua")

--utility functions
dofile(path .. "/breeding.lua")
dofile(path .. "/spawning.lua")
dofile(path .. "/mount.lua")

-- AI functions.  This list must be created after the defaults are
-- initialized above.

-- Default AI functions.  Each function should accept a minimum of
-- three arguments, POS, DTIME.  If such a function returns non-nil,
-- subsequent functions are skipped and its value, if otherwise than
-- `true', is saved into a list of outstanding activities; this value
-- is expected to be a field to be cleared when an activity of a
-- higher priority is activated.  Functions earlier in the list take
-- priority over those which appear later.
local mob_class = mcl_mobs.mob_class
mob_class.ai_functions = {}

-- Default mob targeting functions.
mob_class._targeting_rules = {}

function mcl_mobs.mob_class:set_nametag(name)
	if name ~= "" then
		if string.len(name) > self.max_name_length then
			name = string.sub(name, 1, self.max_name_length)
		end
		self.nametag = name
		self:update_tag()
		return true
	end
end

local on_rightclick_prefix = function(self, clicker)
	if not (clicker and clicker:is_player()) then return end
	if mcl_mobs.maybe_test_pathfinding (self, clicker) then
		return
	end
	local playername = clicker:get_player_name()
	if playername and playername ~= "" then
		doc.mark_entry_as_revealed(playername, "mobs", self.name)
	end
	local item = clicker:get_wielded_item()

	local item_name = item:get_name()
	item_name = core.registered_aliases[item_name] or item_name

	if not self.ignores_nametag and item_name == "mcl_mobitems:nametag" then
		if self:set_nametag(item:get_meta():get_string("name")) and not core.is_creative_enabled(playername) then
			item:take_item()
			clicker:set_wielded_item(item)
		end
		return true
	end
	return false
end

local create_mob_on_rightclick = function(on_rightclick)
	return function(self, clicker)
		local stop = on_rightclick_prefix(self, clicker)
		if (not stop) and (on_rightclick) then
			on_rightclick(self, clicker)
		end
	end
end

-- check if within physical map limits
local function within_limits(pos, radius)
	local wmin, wmax = mcl_vars.mapgen_edge_min, mcl_vars.mapgen_edge_max
	if radius then
		wmin = wmin - radius
		wmax = wmax + radius
	end
	for _,v in pairs({"x","y","z"}) do
		if pos[v] < wmin or pos[v] > wmax then return false end
	end
	return true
end

mcl_mobs.spawning_mobs = {}
-- overwritten in COMPAT for compatbilitiy with old mcl_mobs / mobs_redo
---@diagnostic disable-next-line: duplicate-set-field
function mcl_mobs.register_mob(name, def)
	local def = table.copy(def)
	if not def.description then
		core.log("warning","[mcl_mobs] Mob "..name.." registered without description field. This is needed for proper death messages.")
	end

	mcl_mobs.spawning_mobs[name] = true
	mcl_mobs.registered_mobs[name] = def

	local can_despawn
	if def.can_despawn ~= nil then
		can_despawn = def.can_despawn
	elseif def._spawn_category == "misc"
		or def._spawn_category == "creature" then
		can_despawn = false
	else
		can_despawn = true
	end

	if def.textures then
		def.texture_list = table.copy(def.textures)
		def.textures = nil
	end

	local init_props = {}
	for _,k in pairs(object_properties) do
		if def[k] ~= nil then
			if type(def[k]) == "table" then
				init_props[k] = table.copy(def[k])
			else
				init_props[k] = def[k]
			end
			def[k] = nil
		end
	end

	if def.persist_in_peaceful == nil and def.type == "monster" then
		def.persist_in_peaceful = false
	end

	init_props.collisionbox = init_props.collisionbox or mcl_mobs.mob_class.initial_properties.collisionbox
	init_props.selectionbox = init_props.selectionbox or init_props.collisionbox or mcl_mobs.mob_class.initial_properties.selectionbox
	local eye_height = def.head_eye_height
	if not eye_height then
		eye_height = init_props.collisionbox[5] - init_props.collisionbox[2]
		eye_height = eye_height * 0.75 + init_props.collisionbox[2]
	end

	local gwp_penalties = def.gwp_penalties
		or mcl_mobs.mob_class.gwp_penalties
	local final_def = setmetatable(table.merge(def,{
		initial_properties = table.merge(mob_class.initial_properties,init_props),
		can_despawn = can_despawn,
		rotate = math.rad(def.rotate or 0), --  0=front, 90=side, 180=back, 270=side2
		head_eye_height = eye_height,
		hp_min = def.hp_min,
		on_rightclick = create_mob_on_rightclick(def.on_rightclick),
		_unplaceable_by_default = (def._unplaceable_by_default ~= nil)
			and def._unplaceable_by_default
			or (not def.on_rightclick),
		gwp_penalties = def.can_open_doors
			and table.merge (gwp_penalties, {
						 DOOR_WOOD_CLOSED = 0.0,
					}) or gwp_penalties,

		on_blast = def.on_blast or function(self,damage)
			self.object:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = damage},
			}, nil)
			return false, true, {}
		end,
		on_activate = function(self, staticdata, dtime)
			return self:mob_activate (staticdata, dtime)
		end,
		_spawner = def._spawner,
		_persistent_physics_factors
			= table.merge (mob_class._persistent_physics_factors,
					def._persistent_physics_factors),
	}),mcl_mobs.mob_class_meta)

	mcl_mobs.registered_mobs[name] = final_def
	core.register_entity(":"..name, final_def)

	doc.sub.identifier.register_object(name, "mobs", name)
	doc.add_entry("mobs", name, {
		name = def.description or name,
		data = {
			name = name,
		},
	})
end

function mcl_mobs.get_arrow_damage_func(damage, typ, shooter)
	local typ = mcl_damage.types[typ] and typ or "arrow"
	return function(projectile, object)
		return mcl_util.deal_damage(object, damage, {type = typ, source = shooter or projectile._shooter, direct = projectile.object})
	end
end

mcl_mobs.arrow_class = {
	initial_properties = {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0}, -- remove box around arrows
		automatic_face_movement_dir = false,
	},
	velocity = 1,
	homing = false,
	drop = false, -- drops arrow as registered item when true
	timer = 0,
	switch = 0,
	_lifetime = 1500,
	redirectable = false,
	on_punch = function(self, puncher)
		if self.redirectable then
			local uv -- Direction in which the puncher is staring.
			if puncher:is_player () then
				uv = puncher:get_look_dir ()
			end
			if uv then
				uv = uv * vector.length (self.object:get_velocity ())
				self.object:set_velocity (uv)
				self.owner_id = tostring (puncher)
				self._shooter = puncher
			end
		end
		return true
	end,
}

mcl_mobs.arrow_class_meta = {__index = mcl_mobs.arrow_class}

-- overwritten in COMPAT for compatbilitiy with old mcl_mobs / mobs_redo
---@diagnostic disable-next-line: duplicate-set-field
function mcl_mobs.register_arrow(name, def)
	if not name or not def then return end -- errorcheck

	local init_props = mcl_mobs.arrow_class.initial_properties
	for _,k in pairs(object_properties) do
		if def[k] ~= nil then
			if type(def[k]) == "table" then
				init_props[k] = table.copy(def[k])
			else
				init_props[k] = def[k]
			end
			def[k] = nil
		end
	end

	init_props.automatic_face_movement_dir = def.rotate and (def.rotate - (math.pi / 180))

	core.register_entity(name, setmetatable(table.merge({
		initial_properties = init_props,
		on_step = function(self)

			self.timer = self.timer + 1

			local pos = self.object:get_pos()

			if self.switch == 0	or self.timer > self._lifetime or not within_limits(pos, 0) then
				mcl_burning.extinguish(self.object)
				self.object:remove()
				return
			end

			-- does arrow have a tail (fireball)
			if def.tail and def.tail == 1 and def.tail_texture then
				core.add_particle({
					pos = pos,
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = def.expire or 0.25,
					collisiondetection = false,
					texture = def.tail_texture,
					size = def.tail_size or 5,
					glow = def.glow or 0,
				})
			end

			-- Should this be on fire?
			if self._is_fireball then
				mcl_burning.set_on_fire (self.object, 5)
			end

			if self.hit_node then
				local node =  mcl_mobs.node_ok(pos).name
				if core.registered_nodes[node].walkable then
					self.hit_node(self, pos, node)
					if self.drop == true then
						pos.y = pos.y + 1
						self.lastpos = (self.lastpos or pos)
						core.add_item(self.lastpos, self.object:get_luaentity().name)
					end
					self.object:remove()
					return
				end
			end

			if self.homing and self._target then
				local p = self._target:get_pos()
				if p then
					if core.line_of_sight(self.object:get_pos(), p) then
						self.object:set_velocity(vector.direction(self.object:get_pos(), p) * self.velocity)
					end
				else
					self._target = nil
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then
				local raycast
				= core.raycast (pos, pos + self.object:get_velocity () * 0.04)
				local ok = false
				local closest_object
				local closest_distance
				for hitpoint in raycast do
				if hitpoint.type == "object" and hitpoint.ref ~= self.object then
					local player = hitpoint.ref
					if self.hit_player and player:is_player() then
						ok = true
					else
						local entity = player:get_luaentity()
						if (entity
							and self.hit_mob
							and entity.is_mob
							and tostring(player) ~= self.owner_id
							and entity.name ~= self.object:get_luaentity().name) then
							ok = true
						end

							if (entity
								and self.hit_object
								and (not entity.is_mob)
								and tostring(player) ~= self.owner_id
								and entity.name ~= self.object:get_luaentity().name) then
								ok = true
							end
						end

						if ok then
							local dist = vector.distance (player:get_pos (), pos)
							if not closest_object or dist < closest_distance then
								closest_object = hitpoint.ref
								closest_distance = dist
							end
						end
					end
				end
				-- If an object has been struck, call the
				-- appropriate function.
				if closest_object then
					local entity = closest_object:get_luaentity ()
					if closest_object:is_player () then
						self:hit_player (closest_object)
					elseif entity then
						if entity.is_mob and self.hit_mob then
							self:hit_mob (closest_object)
						elseif self.hit_object then
							self:hit_object (closest_object)
						end
					end
					self.object:remove ()
				end
			end
			self.lastpos = pos
		end
	}, def), mcl_mobs.arrow_class_meta))
end

-- Overwritten in COMPAT for compatibility with old mcl_mobs/mobs_redo
---@diagnostic disable-next-line: duplicate-set-field
function mcl_mobs.register_egg(mob, desc, background_color, overlay_color, addegg, no_creative)
	local grp = {spawn_egg = 1}
	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if no_creative then
		grp.not_in_creative_inventory = 1
	end

	local invimg = "(spawn_egg.png^[multiply:" .. background_color ..")^(spawn_egg_overlay.png^[multiply:" .. overlay_color .. ")"
	if old_spawn_icons then
		local mobname = mob:gsub("mobs_mc:","")
		local fn = "mobs_mc_spawn_icon_"..mobname..".png"
		if mcl_util.file_exists(core.get_modpath("mobs_mc").."/textures/"..fn) then
			invimg = fn
		end
	end
	if addegg == 1 then
		invimg = "mobs_chicken_egg.png^(" .. invimg ..
			"^[mask:mobs_chicken_egg_overlay.png)"
	end

	-- register old stackable mob egg
	core.register_craftitem(mob, {

		description = desc,
		inventory_image = invimg,
		groups = grp,

		_doc_items_longdesc = S("This allows you to place a single mob."),
		_doc_items_usagehelp = S("Just place it where you want the mob to appear. Animals will spawn tamed, unless you hold down the sneak key while placing. If you place this on a mob spawner, you change the mob it spawns."),

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			-- am I clicking on something with existing on_rightclick function?
			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			if pos
			and within_limits(pos, 0)
			and not core.is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				if not core.registered_entities[mob] then
					return itemstack
				end

				pos.y = pos.y - 0.5

				local mob = core.add_entity(pos, mob, core.serialize({ persist_in_peaceful = true }))
				local entityname = itemstack:get_name()
				core.log("action", "Player " ..name.." spawned "..entityname.." at "..core.pos_to_string(pos))
				local ent = mob:get_luaentity()

				-- set nametag
				ent:set_nametag(itemstack:get_meta():get_string("name"))

				-- if not in creative then take item
				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end
