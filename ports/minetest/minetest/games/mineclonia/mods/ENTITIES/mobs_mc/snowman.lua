--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local snow_trail_frequency = 0.5 -- Time in seconds for checking to add a new snow trail

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local mod_throwing = minetest.get_modpath("mcl_throwing") ~= nil

local gotten_texture = {
	"mobs_mc_snowman.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
	"blank.png",
}

mcl_mobs.register_mob("mobs_mc:snowman", {
	description = S("Snow Golem"),
	type = "npc",
	spawn_class = "passive",
	passive = true,
	hp_min = 4,
	hp_max = 4,
	pathfinding = 1,
	view_range = 10,
	fall_damage = 0,
	water_damage = 4,
	rain_damage = 4,
	armor = { fleshy = 100, water_vulnerable = 100 },
	attacks_monsters = true,
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
	gotten_texture = gotten_texture,
	drops = {{ name = "mcl_throwing:snowball", chance = 1, min = 0, max = 15 }},
	visual_size = {x=3, y=3},
	walk_velocity = 0.6,
	run_velocity = 2,
	jump = true,
	makes_footstep_sound = true,
	attack_type = "shoot",
	arrow = "mcl_throwing:snowball_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_throwing then
			mcl_throwing.throw("mcl_throwing:snowball", pos, dir, nil, self.object)
		end
	end,
	shoot_interval = 1,
	shoot_offset = 1,
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
		die_start = 40,
		die_end = 50,
		die_speed = 15,
	        die_loop = false,
	},
	do_custom = function(self, dtime)
		if not mobs_griefing then
			return
		end
		-- Leave a trail of top snow behind.
		-- This is done in do_custom instead of just using replace_what because with replace_what,
		-- the top snop may end up floating in the air.
		if not self._snowtimer then
			self._snowtimer = 0
			return
		end
		self._snowtimer = self._snowtimer + dtime
		if self.health > 0 and self._snowtimer > snow_trail_frequency then
			self._snowtimer = 0
			local pos = self.object:get_pos()
			local below = {x=pos.x, y=pos.y-1, z=pos.z}
			local def = minetest.registered_nodes[minetest.get_node(pos).name]
			-- Node at snow golem's position must be replacable
			if def and def.buildable_to then
				-- Node below must be walkable
				-- and a full cube (this prevents oddities like top snow on top snow, lower slabs, etc.)
				local belowdef = minetest.registered_nodes[minetest.get_node(below).name]
				if belowdef and belowdef.walkable and (belowdef.node_box == nil or belowdef.node_box.type == "regular") then
					-- Place top snow
					minetest.set_node(pos, {name = "mcl_core:snow"})
				end
			end
		end
	end,
	-- Remove pumpkin if using shears
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if self.gotten ~= true and minetest.get_item_group(item:get_name(), "shears") > 0 then
			-- Remove pumpkin
			self.gotten = true
			self.object:set_properties({
				textures = gotten_texture,
			})

			local pos = self.object:get_pos()
			minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)

			if minetest.registered_items["mcl_farming:pumpkin_face"] then
				minetest.add_item({x=pos.x, y=pos.y+1.4, z=pos.z}, "mcl_farming:pumpkin_face")
			end

			-- Wear out
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				item:add_wear(mobs_mc.shears_wear)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
		end
	end,
	_on_dispense = function(self, dropitem, pos, droppos, dropnode, dropdir)
		if minetest.get_item_group(dropitem:get_name(), "shears") > 0 then
			if self.object:get_properties().textures[2] ~= "blank.png" then
				dropitem = self:use_shears({
					"mobs_mc_snowman.png",
					"blank.png", "blank.png",
					"blank.png", "blank.png",
					"blank.png", "blank.png",
				}, dropitem)
				return dropitem
			end
		end
		return mcl_mobs.mob_class._on_dispense(self, dropitem, pos, droppos, dropnode, dropdir)
	end,
})

local summon_particles = function(obj)
	local cb = obj:get_properties().collisionbox
	local min = {x=cb[1], y=cb[2], z=cb[3]}
	local max = {x=cb[4], y=cb[5], z=cb[6]}
	local pos = obj:get_pos()
	minetest.add_particlespawner({
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
function mobs_mc.check_snow_golem_summon(pos)
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
		local b1n = minetest.get_node(b1)
		local b2n = minetest.get_node(b2)
		if b1n.name == "mcl_core:snowblock" and b2n.name == "mcl_core:snowblock" then
			-- Remove the pumpkin and both snow blocks and summon the snow golem
			minetest.remove_node(pos)
			minetest.remove_node(b1)
			minetest.remove_node(b2)
			core.check_for_falling(pos)
			core.check_for_falling(b1)
			core.check_for_falling(b2)
			local obj = minetest.add_entity(place, "mobs_mc:snowman")
			if obj then
				summon_particles(obj)
			end
			break
		end
	end
end

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:snowman", S("Snow Golem"), "#f2f2f2", "#fd8f47", 0)
