mcl_mobs = {}
mcl_mobs.registered_mobs = {}
local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local old_spawn_icons = minetest.settings:get_bool("mcl_old_spawn_icons",false)
local extended_pet_control = minetest.settings:get_bool("mcl_extended_pet_control",false)
local difficulty = tonumber(minetest.settings:get("mob_difficulty")) or 1.0

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
	},
	max_name_length = 30,
	head_yaw_offset = 0,
	head_pitch_multiplier = 1,
	bone_eye_height = 1.4,
	head_eye_height = 0,
	curiosity = 1,
	head_yaw = "y",
	horizontal_head_height = 0,
	fly = false,
	fly_in = {"air", "__airlike"},
	owner = "",
	order = "",
	jump_height = 4, -- was 6
	rotate = 0, --  0=front, 90=side, 180=back, 270=side2
	lifetimer = 57.73,
	xp_min = 0,
	xp_max = 0,
	xp_timestamp = 0,
	breathes_in_water = false,
	view_range = 16,
	walk_velocity = 1,
	run_velocity = 2,
	light_damage = 0,
	sunlight_damage = 0,
	water_damage = 0,
	lava_damage = 8,
	fire_damage = 1,
	suffocation = true,
	fall_damage = 1,
	fall_speed = -9.81 * 1.5,
	drops = {},
	armor = 100,
	sounds = {},
	animation = {},
	jump = true,
	walk_chance = 50,
	attacks_monsters = false,
	group_attack = false,
	passive = false,
	knock_back = true,
	shoot_offset = 0,
	floats = 1,
	floats_on_lava = 0,
	replace_offset = 0,
	replace_delay = 0,
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
	docile_by_day = false,
	time_of_day = 0.5,
	fear_height = 0,
	runaway_timer = 0,
	immune_to = {},
	explosion_timer = 3,
	allow_fuse_reset = true,
	stop_to_explode = true,
	dogfight_interval = 1,
	custom_attack_interval = 1,
	dogshoot_count = 0,
	dogshoot_count_max = 5,
	dogshoot_count2_max = 5,
	attack_animals = false,
	attack_npcs = false,
	facing_fence = false,
	is_mob = true,
	pushable = true,

	avoid_distance = 9,
	ignores_nametag = false,
	rain_damage = 0,
	child = false,
	texture_mods = {},
	suffocation_timer = 0,
	follow_velocity = 2.4,
	instant_death = false,
	fire_resistant = false,
	fire_damage_resistant = false,
	ignited_by_sunlight = false,
	noyaw = false,
	tnt_knockback = true,
	min_light = 7,
	max_light = minetest.LIGHT_MAX + 1,
	does_not_prevent_sleep = false,
	prevents_sleep_when_hostile = false,
	attack_exception = function(p) return false end,
	player_active_range = tonumber(minetest.settings:get("mcl_mob_active_range")) or 48,

	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,

	--internal variables
	blinktimer = 0,
	blinkstatus = false,
	v_start = false,
	standing_in = "ignore",
	standing_on = "ignore",
	jump_sound_cooloff = 0, -- used to prevent jump sound from being played too often in short time
	opinion_sound_cooloff = 0, -- used to prevent sound spam of particular sound types
}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}
mcl_mobs.fallback_node = minetest.registered_aliases["mapgen_dirt"] or "mcl_core:dirt"

function mcl_mobs.check_vector(v)
	return v and v.x and v.y and v.z and not minetest.is_nan(v.x) and not minetest.is_nan(v.y) and not minetest.is_nan(v.z) and tonumber(v.x) and tonumber(v.y) and tonumber(v.z)
end

--api and helpers
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
dofile(path .. "/compat.lua")

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
end

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
	if not clicker:is_player() then return end
	local item = clicker:get_wielded_item()
	if extended_pet_control and self.tamed and self.owner == clicker:get_player_name() then
		self:toggle_sit(clicker)
	end

	local item_name = item:get_name()
	item_name = minetest.registered_aliases[item_name] or item_name

	if not self.ignores_nametag and item_name == "mcl_mobitems:nametag" then
		if self:set_nametag(item:get_meta():get_string("name")) and not minetest.is_creative_enabled(clicker:get_player_name()) then
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

-- check if within physical map limits (-30911 to 30927)
local function within_limits(pos, radius)
	local wmin, wmax = -30912, 30928
	if mcl_vars then
		if mcl_vars.mapgen_edge_min and mcl_vars.mapgen_edge_max then
			wmin, wmax = mcl_vars.mapgen_edge_min, mcl_vars.mapgen_edge_max
		end
	end
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
function mcl_mobs.register_mob(name, def)
	local def = table.copy(def)
	if not def.description then
		minetest.log("warning","[mcl_mobs] Mob "..name.." registered without description field. This is needed for proper death messages.")
	end

	mcl_mobs.spawning_mobs[name] = true
	mcl_mobs.registered_mobs[name] = def

	local can_despawn
	if def.can_despawn ~= nil then
		can_despawn = def.can_despawn
	elseif def.spawn_class == "passive" then
		can_despawn = false
	else
		can_despawn = true
	end

	local function scale_difficulty(value, default, min, special)
		if (not value) or (value == default) or (value == special) then
			return default
		else
			return math.max(min, value * difficulty)
		end
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

	init_props.hp_max = scale_difficulty(init_props.hp_max, 10, 1)
	init_props.collisionbox = init_props.collisionbox or mcl_mobs.mob_class.initial_properties.collisionbox
	init_props.selectionbox = init_props.selectionbox or init_props.collisionbox or mcl_mobs.mob_class.initial_properties.selectionbox

	local final_def = setmetatable(table.merge(def,{
		initial_properties = table.merge(mcl_mobs.mob_class.initial_properties,init_props),
		can_despawn = can_despawn,
		rotate = math.rad(def.rotate or 0), --  0=front, 90=side, 180=back, 270=side2
		hp_min = scale_difficulty(def.hp_min, 5, 1),
		on_rightclick = create_mob_on_rightclick(def.on_rightclick),
		dogshoot_count2_max = def.dogshoot_count2_max or (def.dogshoot_count_max or 5),

		min_light = def.min_light or (def.spawn_class == "hostile" and 0) or 7,
		max_light = def.max_light or (def.spawn_class == "hostile" and 7) or minetest.LIGHT_MAX + 1,
		on_blast = def.on_blast or function(self,damage)
			self.object:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = damage},
			}, nil)
			return false, true, {}
		end,
		on_activate = function(self, staticdata, dtime)
			--this is a temporary hack so mobs stop
			--glitching and acting really weird with the
			--default built in engine collision detection
			self.is_mob = true
			self:set_properties({
				collide_with_objects = false,
			})

			return self:mob_activate(staticdata, dtime)
		end,
	}),mcl_mobs.mob_class_meta)

	mcl_mobs.registered_mobs[name] = final_def
	minetest.register_entity(name, final_def)

	if minetest.get_modpath("doc_identifier") ~= nil then
		doc.sub.identifier.register_object(name, "basics", "mobs")
	end

end

function mcl_mobs.get_arrow_damage_func(damage, typ, shooter)
	local typ = mcl_damage.types[typ] and typ or "arrow"
	return function(projectile, object)
		return mcl_util.deal_damage(object, damage, {type = typ, source = shooter or projectile._shooter})
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
	_lifetime = 150,
	on_punch = function(self)
		local vel = self.object:get_velocity()
		self.object:set_velocity({x=vel.x * -1, y=vel.y * -1, z=vel.z * -1})
	end,
}

mcl_mobs.arrow_class_meta = {__index = mcl_mobs.arrow_class}

-- register arrow for shoot attack
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

	minetest.register_entity(name,  setmetatable(table.merge({
		initial_properties = init_props,
		on_step = function(self, dtime)

			self.timer = self.timer + 1

			local pos = self.object:get_pos()

			if self.switch == 0	or self.timer > self._lifetime or not within_limits(pos, 0) then
				mcl_burning.extinguish(self.object)
				self.object:remove()
				return
			end

			-- does arrow have a tail (fireball)
			if def.tail and def.tail == 1 and def.tail_texture then
				minetest.add_particle({
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

			if self.hit_node then
				local node = node_ok(pos).name
				if minetest.registered_nodes[node].walkable then
					self.hit_node(self, pos, node)
					if self.drop == true then
						pos.y = pos.y + 1
						self.lastpos = (self.lastpos or pos)
						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end
					self.object:remove()
					return
				end
			end

			if self.homing and self._target then
				local p = self._target:get_pos()
				if p then
					if minetest.line_of_sight(self.object:get_pos(), p) then
						self.object:set_velocity(vector.direction(self.object:get_pos(), p) * self.velocity)
					end
				else
					self._target = nil
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then
				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do
					if self.hit_player and player:is_player() then
						self.hit_player(self, player)
						self.object:remove()
						return
					end

					local entity = player:get_luaentity()
					if entity then
						if self.hit_mob	and entity.is_mob and tostring(player) ~= self.owner_id	and entity.name ~= self.object:get_luaentity().name then
							self.hit_mob(self, player)
							self.object:remove()
							return
						end

						if self.hit_object and (not entity.is_mob) and tostring(player) ~= self.owner_id and entity.name ~= self.object:get_luaentity().name then
							self.hit_object(self, player)
							self.object:remove()
							return
						end
					end
				end
			end
			self.lastpos = pos
		end
	}, def), mcl_mobs.arrow_class_meta))
end

-- Register spawn eggs

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
		if mcl_util.file_exists(minetest.get_modpath("mobs_mc").."/textures/"..fn) then
			invimg = fn
		end
	end
	if addegg == 1 then
		invimg = "mobs_chicken_egg.png^(" .. invimg ..
			"^[mask:mobs_chicken_egg_overlay.png)"
	end

	-- register old stackable mob egg
	minetest.register_craftitem(mob, {

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
			and not minetest.is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				if not minetest.registered_entities[mob] then
					return itemstack
				end

				if minetest.settings:get_bool("only_peaceful_mobs", false)
						and minetest.registered_entities[mob].type == "monster" then
					minetest.chat_send_player(name, S("Only peaceful mobs allowed!"))
					return itemstack
				end

				pos.y = pos.y - 0.5

				local mob = minetest.add_entity(pos, mob)
				local entityname = itemstack:get_name()
				minetest.log("action", "Player " ..name.." spawned "..entityname.." at "..minetest.pos_to_string(pos))
				local ent = mob:get_luaentity()

				-- don't set owner if monster or sneak pressed
				if ent.type ~= "monster"
				and not placer:get_player_control().sneak then
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end

				-- set nametag
				ent:set_nametag(itemstack:get_meta():get_string("name"))

				-- if not in creative then take item
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end
