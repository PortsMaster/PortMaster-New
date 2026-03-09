--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- Rootyjr
-----------------------------
-- implemented ability to detect when seen / break eye contact and aggressive response
-- implemented teleport to avoid arrows.
-- implemented teleport to avoid rain.
-- implemented teleport to chase.
-- added enderman particles.
-- drew mcl_portal_particle1.png
-- drew mcl_portal_particle2.png
-- drew mcl_portal_particle3.png
-- drew mcl_portal_particle4.png
-- drew mcl_portal_particle5.png
-- added rain damage.
-- fixed the grass_with_dirt issue.

core.register_entity ("mobs_mc:ender_eyes", {
	initial_properties = {
		visual = "mesh",
		mesh = "mobs_mc_spider.b3d",
		visual_size = {x=1.01/3, y=1.01/3},
		glow = 50,
		textures = {
			"mobs_mc_enderman_eyes.png",
		},
		selectionbox = {
			0, 0, 0, 0, 0, 0,
		},
	},
	on_step = function(self)
		if self and self.object then
			if not self.object:get_attach() then
				self.object:remove()
			end
		end
	end,
})

local S = core.get_translator("mobs_mc")

local telesound = function(pos, is_source)
	local snd
	if is_source then
		snd = "mobs_mc_enderman_teleport_src"
	else
		snd = "mobs_mc_enderman_teleport_dst"
	end
	core.sound_play(snd, {pos=pos, max_hear_distance=16}, true)
end

--###################
--################### ENDERMAN
--###################

local mob_class = mcl_mobs.mob_class
local pr = PcgRandom (os.time () * (-334))

-- Texuture overrides for enderman block. Required for cactus because it's original is a nodebox
-- and the textures have tranparent pixels.
local block_texture_overrides
do
	local cbackground = "mobs_mc_enderman_cactus_background.png"
	local ctiles = core.registered_nodes["mcl_core:cactus"].tiles

	local ctable = {}
	local last
	for i=1, 6 do
		if ctiles[i] then
			last = ctiles[i]
		end
		table.insert(ctable, cbackground .. "^" .. last)
	end

	block_texture_overrides = {
		["mcl_core:cactus"] = ctable,
		-- FIXME: replace colorize colors with colors from palette
		["mcl_core:dirt_with_grass"] =
		{
		"mcl_core_grass_block_top.png^[colorize:green:90",
		"default_dirt.png",
		"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
		"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
		"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
		"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)"}
	}
end

-- Create the textures table for the enderman, depending on which kind of block
-- the enderman holds (if any).
local create_enderman_textures = function(block_type, itemstring)
	local base = "mobs_mc_enderman.png^mobs_mc_enderman_eyes.png"

	--[[ Order of the textures in the texture table:
		Flower, 90 degrees
		Flower, 45 degrees
		Held block, backside
		Held block, bottom
		Held block, front
		Held block, left
		Held block, right
		Held block, top
		Enderman texture (base)
	]]
	-- Regular cube
	if block_type == "cube" then
		local tiles = core.registered_nodes[itemstring].tiles
		local textures = {}
		local last
		if block_texture_overrides[itemstring] then
			-- Texture override available? Use these instead!
			textures = block_texture_overrides[itemstring]
		else
			-- Extract the texture names
			for i = 1, 6 do
				if type(tiles[i]) == "string" then
					last = tiles[i]
				elseif type(tiles[i]) == "table" then
					if tiles[i].name then
						last = tiles[i].name
					end
				end
				table.insert(textures, last)
			end
		end
		return {
			"blank.png",
			"blank.png",
			textures[5],
			textures[2],
			textures[6],
			textures[3],
			textures[4],
			textures[1],
			base, -- Enderman texture
		}
	-- Node of plantlike drawtype, 45° (recommended)
	elseif block_type == "plantlike45" then
		local textures = core.registered_nodes[itemstring].tiles
		return {
			"blank.png",
			textures[1],
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base,
		}
	-- Node of plantlike drawtype, 90°
	elseif block_type == "plantlike90" then
		local textures = core.registered_nodes[itemstring].tiles
		return {
			textures[1],
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base,
		}
	elseif block_type == "unknown" then
		return {
			"blank.png",
			"blank.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			"unknown_node.png",
			base, -- Enderman texture
		}
	-- No block held (for initial texture)
	elseif block_type == "nothing" or block_type == nil then
		return {
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			"blank.png",
			base, -- Enderman texture
		}
	end
end

-- Select a new animation definition.
local select_enderman_animation = function(animation_type)
	-- Enderman holds a block
	if animation_type == "block" then
		return {
			stand_start = 200, stand_end = 200,
			walk_start = 161, walk_end = 200, walk_speed = 25,
			attack_start = 81, attack_end = 120, attack_speed = 50,
		}
	-- Enderman doesn't hold a block
	elseif animation_type == "normal" or animation_type == nil then
		return {
			stand_start = 40, stand_end = 80, stand_speed = 25,
			walk_start = 0, walk_end = 40, walk_speed = 25,
			attack_start = 81, attack_end = 120, attack_speed = 50,
		}
	end
end

local mobs_griefing = mobs_mc.is_mob_griefing_enabled("enderman")
local psdefs = {{
	amount = 5,
	minpos = vector.new(-0.6,0,-0.6),
	maxpos = vector.new(0.6,3,0.6),
	minvel = vector.new(-0.25,-0.25,-0.25),
	maxvel = vector.new(0.25,0.25,0.25),
	minacc = vector.new(-0.5,-0.5,-0.5),
	maxacc = vector.new(0.5,0.5,0.5),
	minexptime = 0.2,
	maxexptime = 3,
	minsize = 0.2,
	maxsize = 1.2,
	collisiondetection = true,
	vertical = false,
	time = 0,
	texture = "mcl_portals_particle"..math.random(1, 5)..".png",
}}

local enderman = {
	description = S("Enderman"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 40,
	hp_max = 40,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, 0, -0.3, 0.3, 2.9, 0.3},
	doll_size_override = { x = 0.8, y = 0.8 },
	visual = "mesh",
	mesh = "mobs_mc_enderman.b3d",
	textures = create_enderman_textures(),
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	can_despawn = true,
	head_eye_height = 2.55,
	sounds = {
		death = {name="mobs_mc_enderman_death", gain=0.7},
		damage = {name="mobs_mc_enderman_hurt", gain=0.5},
		random = {name="mobs_mc_enderman_random", gain=0.5},
		distance = 16,
	},
	movement_speed = 6.0,
	damage = 7,
	stepheight = 1.01,
	reach = 2,
	particlespawners = psdefs,
	drops = {
		{
			name = "mcl_throwing:ender_pearl",
			chance = 1,
			min = 0,
			max = 1,
			looting = "common",
		},
	},
	animation = select_enderman_animation("normal"),
	_taken_node = "",
	armor = {
		fleshy = 100,
		water_vulnerable = 100,
	},
	water_damage = 8,
	rain_damage = 1.0,
	view_range = 64,
	tracking_distance = 64,
	attack_type = "melee",
	pursuit_bonus = 1.15,
}

------------------------------------------------------------------------
-- Enderman visuals and mechanics.
------------------------------------------------------------------------

function enderman:despawn_allowed ()
	return (self._taken_node == "" or not self._taken_node)
		and mob_class.despawn_allowed (self)
end

function enderman:set_animation (anim, custom_speed)
	if self.attack then
		anim = "attack"
	end
	mob_class.set_animation (self, anim, custom_speed)
end

function enderman:mob_activate (staticdata, dtime)
	if not mob_class.mob_activate (self, staticdata, dtime) then
		return false
	end
	core.add_entity (self.object:get_pos(), "mobs_mc:ender_eyes")
		:set_attach(self.object, "head.top", vector.new(0,2.54,-1.99), vector.new(90,0,180))
	core.add_entity (self.object:get_pos(), "mobs_mc:ender_eyes")
		:set_attach(self.object, "head.top", vector.new(1,2.54,-1.99), vector.new(90,0,180))
	return true
end

function enderman:on_die (self_pos)
	-- Drop carried node on death
	if self._taken_node ~= nil and self._taken_node ~= "" then
		core.add_item (self_pos, self._taken_node)
	end
end

function enderman:do_custom (dtime)
	-- ARROW / DAYTIME PEOPLE AVOIDANCE BEHAVIOUR HERE.
	-- Check for arrows and people nearby.

	local enderpos = self.object:get_pos()
	enderpos.y = enderpos.y + 1.5
	for obj in core.objects_inside_radius(enderpos, 2) do
		if not core.is_player(obj) then
			local lua = obj:get_luaentity()
			if lua then
				if lua.name == "mcl_bows:arrow_entity" or lua.name == "mcl_throwing:snowball_entity" then
					self:teleport(nil)
				end
			end
		end
	end
end

function enderman:do_teleport (target)
	if target ~= nil then
		local target_pos = target:get_pos()
		-- Find all solid nodes below air in a 10×10×10 cuboid centered on the target
		local nodes = core.find_nodes_in_area_under_air(vector.subtract(target_pos, 5), vector.add(target_pos, 5), {"group:solid", "group:cracky", "group:crumbly"})
		local telepos
		if nodes ~= nil then
			if #nodes > 0 then
				-- Up to 64 attempts to teleport
				for _ = 1, math.min(64, #nodes) do
					local r = pr:next(1, #nodes)
					local nodepos = nodes[r]
					local node_ok = true
					-- Selected node needs to have 3 nodes of free space above
					for u=1, 3 do
						local node = core.get_node({x=nodepos.x, y=nodepos.y+u, z=nodepos.z})
						local ndef = core.registered_nodes[node.name]
						if ndef and ndef.walkable then
							node_ok = false
							break
						end
					end
					if node_ok then
						telepos = {x=nodepos.x, y=nodepos.y+1, z=nodepos.z}
					end
				end
				if telepos then
					telesound(self.object:get_pos(), false)
					self:halt_in_tracks (true)
					self:cancel_navigation ()
					self.object:set_pos(telepos)
					self.reset_fall_damage = 1
					telesound(telepos, true)
				end
			end
		end
	else
		-- Attempt to randomly teleport enderman
		local pos = self.object:get_pos()
		-- Up to 8 top-level attempts to teleport
		for _ = 1, 8 do
			local node_ok = false
			-- We need to add (or subtract) different random numbers to each vector component, so it couldn't be done with a nice single vector.add() or .subtract():
			local randomCube = vector.new( pos.x + 8*(pr:next(0,8)-4), pos.y + 8*(pr:next(0,8)-4), pos.z + 8*(pr:next(0,8)-4) )
			local nodes = core.find_nodes_in_area_under_air(vector.subtract(randomCube, 4), vector.add(randomCube, 4), {"group:solid", "group:cracky", "group:crumbly"})
			if nodes ~= nil then
				if #nodes > 0 then
					-- Up to 8 low-level (in total up to 8*8 = 64) attempts to teleport
					for _ = 1, math.min(8, #nodes) do
						local r = pr:next(1, #nodes)
						local nodepos = nodes[r]
						node_ok = true
						for u=1, 3 do
							local node = core.get_node({x=nodepos.x, y=nodepos.y+u, z=nodepos.z})
							local ndef = core.registered_nodes[node.name]
							if ndef and ndef.walkable then
								node_ok = false
								break
							end
						end
						if node_ok then
							telesound(self.object:get_pos(), false)
							local telepos = {x=nodepos.x, y=nodepos.y+1, z=nodepos.z}
							self.object:set_pos (telepos)
							self:halt_in_tracks (true)
							self:cancel_navigation ()
							self.reset_fall_damage = 1
							telesound(telepos, true)
							break
						end
					end
				end
			end
			if node_ok then
				break
			end
		end
	end
end

------------------------------------------------------------------------
-- Enderman AI
------------------------------------------------------------------------

local function is_living_damage_source (source)
	if source and source:is_player () then
		return true
	elseif source then
		local entity = source:get_luaentity ()
		return entity and entity.is_mob
	end
	return nil
end

function enderman:receive_damage (mcl_reason, damage)
	local result = mob_class.receive_damage (self, mcl_reason, damage)
	if result and not is_living_damage_source (mcl_reason.source) then
		self:teleport ()
	end
	return result
end

local function enderman_grief (self, self_pos, dtime)
	if not mobs_griefing or (self._taken_node and self._taken_node ~= "") then
		return false
	end

	local chance = math.round (20 * (dtime / 0.05))
	if pr:next (1, math.max (1, chance)) == 1 then
		local self_node_pos = {
			x = math.floor (self_pos.x + 0.5),
			y = math.floor (self_pos.y + 0.5),
			z = math.floor (self_pos.z + 0.5),
		}
		local take_pos = {
			x = math.floor (self_pos.x + 0.5 + pr:next (-2, 2)),
			y = math.floor (self_pos.y + 0.5 + pr:next (0, 3)),
			z = math.floor (self_pos.z + 0.5 + pr:next (-2, 2)),
		}
		local node = core.get_node (take_pos)
		-- Now verify that this is takable and that there is
		-- line of sight.
		if core.get_item_group (node.name, "enderman_takable") == 0 then
			return false
		end
		local los, hit_pos = self:line_of_sight (self_node_pos, take_pos)
		if los or not vector.equals (hit_pos, take_pos) then
			return false
		end
		-- Don't destroy protected stuff.
		if not core.is_protected(take_pos, "") then
			core.remove_node(take_pos)
			local dug = core.get_node_or_nil(take_pos)
			if dug and dug.name == "air" then
				self._taken_node = node.name
				local def = core.registered_nodes[self._taken_node]
				-- Update animation and texture accordingly (adds visibly carried block)
				local block_type
				-- Cube-shaped
				if def.drawtype == "normal" or
					def.drawtype == "nodebox" or
					def.drawtype == "liquid" or
					def.drawtype == "flowingliquid" or
					def.drawtype == "glasslike" or
					def.drawtype == "glasslike_framed" or
					def.drawtype == "glasslike_framed_optional" or
					def.drawtype == "allfaces" or
					def.drawtype == "allfaces_optional" or
					def.drawtype == nil then
					block_type = "cube"
				elseif def.drawtype == "plantlike" then
					-- Flowers and stuff
					block_type = "plantlike45"
				elseif def.drawtype == "airlike" then
					-- Just air
					block_type = nil
				else
					-- Fallback for complex drawtypes
					block_type = "unknown"
				end
				self.base_texture = create_enderman_textures(block_type, self._taken_node)
				self:set_textures (self.base_texture)
				self.animation = select_enderman_animation("block")
				self._current_animation = nil
				self:set_animation ("stand")
				if def.sounds and def.sounds.dug then
					core.sound_play(def.sounds.dug, {pos = take_pos, max_hear_distance = 16}, true)
				end
			end
		end
	end
	return false
end

local function enderman_ungrief (self, self_pos, dtime)
	if not mobs_griefing or not self._taken_node
		or self._taken_node == "" then
		return false
	end

	local chance = math.round (2000 * (dtime / 0.05))
	if pr:next (1, math.max (1, chance)) == 1 then
		-- Select a random position around self_pos in which
		-- to attempt to place the carried block.
		local self_x = math.floor (self_pos.x + 0.5)
		local self_z = math.floor (self_pos.z + 0.5)
		local place_pos
		repeat
			place_pos = {
				x = math.floor (self_pos.x + 0.5 + pr:next (-1, 1)),
				y = math.floor (self_pos.y + 0.5 + pr:next (0, 2)),
				z = math.floor (self_pos.z + 0.5 + pr:next (-1, 1)),
			}
		until place_pos.x ~= self_x or place_pos.z ~= self_z

		local node_below = vector.offset (place_pos, 0, -1, 0)

		-- Also check to see if protected.
		if core.get_node (place_pos).name == "air"
			and not core.is_protected (place_pos, "")
		-- and whether the node below is sturdy.
			and self:is_up_face_sturdy (node_below) then
			-- ... but only if there's a free space
			local success = core.place_node (place_pos, {name = self._taken_node})
			if success then
				local def = core.registered_nodes[self._taken_node]
				-- Update animation accordingly (removes visible block)
				self.persistent = false
				self.animation = select_enderman_animation("normal")
				self._current_animation = nil
				self:set_animation ("stand")
				if def.sounds and def.sounds.place then
					core.sound_play(def.sounds.place, {pos = place_pos, max_hear_distance = 16}, true)
				end
				self._taken_node = ""
			end
		end
	end

	return false
end

function enderman:attack_melee (self_pos, dtime, target_pos, line_of_sight)
	local self_eye_pos = {
		x = self_pos.x,
		y = self_pos.y + self:get_eye_height (),
		z = self_pos.z,
	}
	-- Freeze if the target is looking directly at this enderman.
	if self.attack:is_player ()
		and self:eye_contact (self_eye_pos, self.attack, line_of_sight) then
		self:cancel_navigation ()
		self:halt_in_tracks ()
	else
		mob_class.attack_melee (self, self_pos, dtime, target_pos, line_of_sight)
	end
end

function enderman:check_attack (self_pos, dtime, moveresult)
	local attack = mob_class.check_attack (self, self_pos, dtime, moveresult)
	if attack then
		self:set_animation ("attack")
	end
	if attack and self.attack and self.attack:is_player () then
		local target_pos = self.attack:get_pos ()
		local distance = vector.distance (self_pos, target_pos)
		local self_eye_pos = {
			x = self_pos.x,
			y = self_pos.y + self:get_eye_height (),
			z = self_pos.z,
		}
		-- Attempt to break eye contact.
		if distance < 4 then
			local eye_contact = self:eye_contact (self_eye_pos, self.attack)
			if eye_contact then
				self._time_since_teleport = self._time_since_teleport + dtime
				if self._time_since_teleport > 0.25 then
					self:do_teleport ()
					self._time_since_teleport = 0
				end
			end
		elseif distance > 16 then
			self._time_since_teleport = self._time_since_teleport + dtime
			if self._time_since_teleport >= 1.5 then
				self:do_teleport (self.attack)
				self._time_since_teleport = 0
			end
		end
	end
	return attack
end

enderman.ai_functions = {
	enderman.check_attack,
	mob_class.check_pace,
	enderman_ungrief,
	enderman_grief,
}

------------------------------------------------------------------------
-- Enderman target selection
------------------------------------------------------------------------

function enderman:eye_contact (eye_pos, object, line_of_sight)
	local inventory = object:get_inventory ()
	local stack = inventory:get_stack ("armor", 2)
	if stack:get_name () == "mcl_farming:pumpkin_face" then
		return false
	end

	local player_look_dir = object:get_look_dir ()
	local player_pos = mcl_util.target_eye_pos (object)
	local direction = vector.direction (player_pos, eye_pos)
	local distance = vector.distance (eye_pos, player_pos)

	if line_of_sight == nil then
		line_of_sight = self:line_of_sight (eye_pos, player_pos)
	end

	local dot = vector.dot (player_look_dir, direction)
	return dot > 1.0 - 0.025 / distance and line_of_sight
end

local dist_sqr = mcl_mobs.dist_sqr
local tmp = vector.new ()
local huge = math.huge

local function enderman_player_rule (self, self_pos, dtime, obj, is_current)
	if is_current then
		local dist = self.tracking_distance * self.tracking_distance
		return self:track_current_target (self_pos, dtime, obj, dist, 3.0)
	end

	local eye_pos = tmp
	eye_pos.x = self_pos.x
	eye_pos.y = self_pos.y + self:get_eye_height ()
	eye_pos.z = self_pos.z

	if not self._pending_target then
		local view_range = self.view_range
		local d = huge
		local target = nil
		for player, pos1 in mcl_player.iterate_connected_players () do
			local d1 = dist_sqr (self_pos, pos1)
			local m = self:detection_multiplier_for_object (player)
			if d1 <= view_range * m * m and d1 < d
				and self:target_visible (self_pos, player)
				and self:test_object_and_restriction (player, pos1)
				and self:eye_contact (eye_pos, player, nil) then
				d = d1
				target = player
			end
		end
		if target then
			self._pending_target = target
			self._targeting_delay = 0.25
		end
		return nil
	-- A target has been selected; if the targeting delay has also
	-- elapsed and it continues to maintain eye contact, select
	-- it, or abandon it otherwise.
	elseif not self._pending_target:is_valid ()
		or not self:eye_contact (eye_pos, self._pending_target) then
		self._pending_target = nil
		self._targeting_delay = nil
		return nil
	else
		local t = self._targeting_delay
		if t <= dtime then
			local target = self._pending_target
			self._pending_target = nil
			self._targeting_delay = nil
			return target
		end
		self._targeting_delay = t - dtime
		return nil
	end
end

function enderman:switch_targeting_rule (fn_old, fn_new)
	if not fn_old and fn_new then
		self._time_since_teleport = 0
	end
	mob_class.switch_targeting_rule (self, fn_old, fn_new)
end

enderman._targeting_rules = {
	mcl_mobs.build_target_rule ({
		fn = enderman_player_rule,
		on_complete = nil,
	}),
	mcl_mobs.build_retaliation_target_rule (nil, false, nil),
	mcl_mobs.build_nearest_target_rule ("mobs_mc:endermite", {
		"mobs_mc:endermite",
	}, nil, nil, nil)
}

------------------------------------------------------------------------
-- Enderman sundries
------------------------------------------------------------------------

local function mc_light_value (self, self_pos)
	local brightness, value
	local pos = self_pos
	brightness = (core.get_node_light (pos) or 0) / 15.0
	value = brightness / (4 - 3 * brightness)
	return value
end

function enderman:init_ai ()
	mob_class.init_ai (self)
end

function enderman:ai_step (dtime)
	mob_class.ai_step (self, dtime)
	local self_pos = self.object:get_pos ()
	if mcl_worlds.pos_to_dimension (self_pos) == "overworld"
		and core.get_timeofday () > 0.25 then
		local light = mc_light_value (self, self_pos)
		if light > 0.5 and mcl_weather.is_outdoor (self_pos)
			and math.random () * 30 < (light - 0.4) * 2.0 then
			if self.attack then
				self.attack = nil
				self:replace_activity (nil)
			end
			self:teleport ()
		end
	end
end

-- Prevent endermen from crossing water.
enderman.gwp_penalties = table.copy (mob_class.gwp_penalties)
enderman.gwp_penalties.WATER = -1.0

mcl_mobs.register_mob ("mobs_mc:enderman", enderman)

------------------------------------------------------------------------
-- Enderman spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:enderman", S("Enderman"), "#252525", "#151515", 0)

------------------------------------------------------------------------
-- Modern Enderman spawning.
------------------------------------------------------------------------

local enderman_spawner_overworld = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:enderman",
	spawn_category = "monster",
	pack_min = 1,
	pack_max = 4,
	weight = 1,
	biomes = mobs_mc.monster_biomes,
})

local enderman_spawner_nether = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:enderman",
	spawn_category = "monster",
	pack_min = 1,
	pack_max = 4,
	biomes = {
		"WarpedForest",
		"NetherWastes",
		"SoulSandValley",
	},
	weight = 1,
	max_artificial_light = 15,
})

local enderman_spawner_end = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:enderman",
	spawn_category = "monster",
	pack_min = 4,
	pack_max = 4,
	biomes = {
		"#is_end",
	},
	weight = 10,
	max_artificial_light = 15,
	max_light = 15,
})

mcl_mobs.register_spawner (enderman_spawner_overworld)
mcl_mobs.register_spawner (enderman_spawner_nether)
mcl_mobs.register_spawner (enderman_spawner_end)
