--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local snow_trail_frequency = 0.5 -- Time in seconds between depositions of snow trails
local mob_class = mcl_mobs.mob_class
local mobs_griefing = mobs_mc.is_mob_griefing_enabled("snowman")

local sheared_textures = {
	"mobs_mc_snowman.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
}

local snow_golem = {
	description = S("Snow Golem"),
	type = "npc",
	_spawn_category = "misc",
	hp_min = 4,
	hp_max = 4,
	fall_damage = 0,
	water_damage = 4,
	_mcl_freeze_damage = 0,
	head_eye_height = 1.7,
	rain_damage = 4,
	armor = { fleshy = 100, water_vulnerable = 100, },
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 1.89, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_snowman.b3d",
	sounds = {
		damage = { name = "mobs_mc_snowman_hurt", gain = 0.2 },
		death = { name = "mobs_mc_snowman_death", gain = 0.25 },
		distance = 16,
	},
	textures = {
		"mobs_mc_snowman.png", --snowman texture
		"farming_pumpkin_side.png", --top
		"farming_pumpkin_top.png", --down
		"farming_pumpkin_face.png", --front
		"farming_pumpkin_side.png", --left
		"farming_pumpkin_side.png", --right
		"farming_pumpkin_top.png", --left
	},
	drops = {{
		name = "mcl_throwing:snowball",
		chance = 1, min = 0,
		max = 15,
	}},
	visual_size = {x=3, y=3},
	movement_speed = 4.0,
	makes_footstep_sound = true,
	attack_type = "ranged",
	arrow = "mcl_throwing:snowball_entity",
	ranged_attack_radius = 10.0,
	shoot_offset = 0.5,
	pursuit_bonus = 1.25,
	animation = {
		stand_start = 20, stand_end = 40, stand_speed = 25,
		walk_start = 0, walk_end = 20, walk_speed = 25,
	},
}

------------------------------------------------------------------------
-- Snow Golem interaction.
------------------------------------------------------------------------

-- Remove pumpkin if using shears
function snow_golem:on_rightclick (clicker)
	local item = clicker:get_wielded_item()
	local item_name = item:get_name()
	if self.gotten ~= true and core.get_item_group(item_name, "shears") > 0 then
		-- Remove pumpkin
		self.gotten = true
		self.base_texture = sheared_textures
		self:set_textures (sheared_textures)

		local pos = self.object:get_pos()
		core.sound_play("mcl_tools_shears_cut", {pos = pos}, true)

		if core.registered_items["mcl_farming:pumpkin_face"] then
			core.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_farming:pumpkin_face")
		end

		-- Wear out
		if not core.is_creative_enabled(clicker:get_player_name()) then
			local wear = mcl_autogroup.get_wear(item:get_name(), "shearsy")
			item:add_wear(wear)
			clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
		end
	end
end

function snow_golem:_on_dispense (dropitem, pos, droppos, dropnode, dropdir)
	if core.get_item_group(dropitem:get_name(), "shears") > 0 then
		if not self.gotten then
			dropitem = self:use_shears ({
				"mobs_mc_snowman.png",
				"blank.png", "blank.png",
				"blank.png", "blank.png",
				"blank.png", "blank.png",
			}, dropitem)
			return dropitem
		end
	end
	return mob_class._on_dispense (self, dropitem, pos, droppos, dropnode, dropdir)
end

------------------------------------------------------------------------
-- Snow Golem AI.
------------------------------------------------------------------------

function snow_golem:ai_step (dtime)
	mob_class.ai_step (self, dtime)

	-- Is this biome inhospitable?
	if self:check_timer ("biome_damage", 0.5) then
		local self_pos = mcl_util.get_nodepos (self.object:get_pos ())
		local biome_name = mcl_biome_dispatch.get_biome_name (self_pos)
		local temp = mcl_biome_dispatch.get_temperature_in_biome (biome_name,
									  self_pos)
		if temp > 1.0 then
			self:damage_mob ("on_fire", 1.0)
		end
	end

	if not mobs_griefing then
		return
	end
	-- Leave a trail of top snow behind.
	if not self._snowtimer then
		self._snowtimer = 0
		return
	end
	self._snowtimer = self._snowtimer + dtime
	if self.health > 0 and self._snowtimer > snow_trail_frequency then
		self._snowtimer = 0
		local pos = self.object:get_pos ()
		local below = {x=pos.x, y=pos.y-1, z=pos.z}
		local def = core.registered_nodes[core.get_node(pos).name]
		-- Node at snow golem's position must be replacable
		if def and def.buildable_to and def.liquidtype == "none" then
			-- Node below must be walkable
			-- and a full cube (this prevents oddities like top snow on top snow, lower slabs, etc.)
			local belowdef = core.registered_nodes[core.get_node(below).name]
			if belowdef and belowdef.walkable
				and (belowdef.node_box == nil or belowdef.node_box.type == "regular") then
				-- Place top snow
				core.set_node(pos, {name = "mcl_core:snow"})
			end
		end
	end
end

function snow_golem:shoot_arrow (pos, dir)
	mcl_throwing.throw ("mcl_throwing:snowball", pos, dir, nil, self.object)
end

snow_golem.ai_functions = {
	mob_class.check_attack,
	mob_class.check_pace,
}

snow_golem._targeting_rules = {
	mcl_mobs.build_nearest_target_rule ("mob", {"monster",}, nil, nil, nil),
}

mcl_mobs.register_mob ("mobs_mc:snowman", snow_golem)

------------------------------------------------------------------------
-- Snow Golem summoning.
------------------------------------------------------------------------

local summon_particles = function(obj)
	local cb = obj:get_properties().collisionbox
	local min = {x=cb[1], y=cb[2], z=cb[3]}
	local max = {x=cb[4], y=cb[5], z=cb[6]}
	local pos = obj:get_pos()
	core.add_particlespawner({
		amount = 60,
		time = 0.1,
		minpos = vector.add(pos, min),
		maxpos = vector.add(pos, max),
		minvel = {x = -0.1, y = -0.1, z = -0.1},
		maxvel = {x = 0.1, y = 0.1, z = 0.1},
		minexptime = 1.0,
		maxexptime = 2.0,
		minsize = 2.0,
		maxsize = 3.0,
		texture = "mcl_particles_smoke.png",
	})
end

-- This is to be called when a pumpkin or jack'o lantern has been placed. Recommended: In the on_construct function
-- of the node.
-- This summons a snow golen when pos is next to a row of two snow blocks.
function mobs_mc.check_snow_golem_summon(pos, player)
	local checks = {
		-- These are the possible placement patterns
		-- { snow block pos. 1, snow block pos. 2, snow golem spawn position }
		{ {x=pos.x, y=pos.y-1, z=pos.z}, {x=pos.x, y=pos.y-2, z=pos.z}, {x=pos.x, y=pos.y-2.5, z=pos.z} },
		{ {x=pos.x, y=pos.y+1, z=pos.z}, {x=pos.x, y=pos.y+2, z=pos.z}, {x=pos.x, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x-1, y=pos.y, z=pos.z}, {x=pos.x-2, y=pos.y, z=pos.z}, {x=pos.x-2, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x+1, y=pos.y, z=pos.z}, {x=pos.x+2, y=pos.y, z=pos.z}, {x=pos.x+2, y=pos.y-0.5, z=pos.z} },
		{ {x=pos.x, y=pos.y, z=pos.z-1}, {x=pos.x, y=pos.y, z=pos.z-2}, {x=pos.x, y=pos.y-0.5, z=pos.z-2} },
		{ {x=pos.x, y=pos.y, z=pos.z+1}, {x=pos.x, y=pos.y, z=pos.z+2}, {x=pos.x, y=pos.y-0.5, z=pos.z+2} },
	}

	for c=1, #checks do
		local b1 = checks[c][1]
		local b2 = checks[c][2]
		local place = checks[c][3]
		local b1n = core.get_node(b1)
		local b2n = core.get_node(b2)
		if b1n.name == "mcl_core:snowblock" and b2n.name == "mcl_core:snowblock" then
			-- Remove the pumpkin and both snow blocks and summon the snow golem
			core.remove_node(pos)
			core.remove_node(b1)
			core.remove_node(b2)
			core.check_for_falling(pos)
			core.check_for_falling(b1)
			core.check_for_falling(b2)
			local obj = core.add_entity(place, "mobs_mc:snowman")
			if obj then
				summon_particles(obj)
				local l = obj:get_luaentity()
				if l and player then l._creator = player:get_player_name() end
			end
			break
		end
	end
end

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:snowman", S("Snow Golem"), "#f2f2f2", "#fd8f47", 0)
