local S = core.get_translator(core.get_current_modname())

local peaceful = core.settings:get_bool("only_peaceful_mobs", false)

local explosion_strength = 6

local directions = {
	{x = 1}, {x = -1}, {z = 1}, {z = -1}
}

local dimensions = {"x", "y", "z"}

for _, dir in pairs(directions) do
	for _, dim in pairs(dimensions) do
		dir[dim] = dir[dim] or 0
	end
end

local function find_crystal(pos)
	for obj in core.objects_inside_radius(pos, 0) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_end:crystal" then
			return luaentity
		end
	end
end

local function crystal_explode(self, puncher)
	if self._exploded then
		return true
	end
	self._exploded = true
	self._puncher = puncher
	local strength = 1
	local source
	if puncher then
		strength = explosion_strength
		local reason = {}
		mcl_damage.from_punch(reason, puncher)
		mcl_damage.finish_reason(reason)
		source = reason.source
	end
	-- Enable dragons to detect explosions by slightly deferring
	-- object deletion.
	core.after (0.1, self.object.remove, self.object)
	mcl_explosions.explode(vector.add(self.object:get_pos(), {x = 0, y = 1.5, z = 0}), strength, {}, self.object, source)
	return true
end

local function set_crystal_animation(self)
	self.object:set_animation({x = 0, y = 120}, 25)
end

local function spawn_crystal(pos)
	core.add_entity(pos, "mcl_end:crystal")
	if not vector.equals(pos, vector.floor(pos)) then return end
	if mcl_worlds.pos_to_dimension(pos) ~= "end" then return end
	local portal_center
	for _, dir in pairs(directions) do
		local node = core.get_node(vector.add(pos, dir))
		if node.name == "mcl_portals:portal_end" then
			portal_center = vector.add(pos, vector.multiply(dir, 3))
			break
		end
	end
	if not portal_center then return end
	local crystals = {}
	for i, dir in pairs(directions) do
		local crystal_pos = vector.add(portal_center, vector.multiply(dir, 3))
		crystals[i] = find_crystal(crystal_pos)
		if not crystals[i] then return end
	end
	for o in core.objects_inside_radius(pos, 64) do
		local l = o:get_luaentity()
		if l and l.name == "mobs_mc:enderdragon" then return end
		if not peaceful then
			if o:is_player() then
				awards.unlock(o:get_player_name(), "mcl:theEndAgain")
			end
		end
	end
	if mcl_end.resurrect_dragon (crystals[1].object:get_pos (),
				     crystals[2].object:get_pos (),
				     crystals[3].object:get_pos (),
				     crystals[4].object:get_pos ()) then
		local portal_pos = vector.offset (portal_center, 0, -1, 0)
		local exit_portal
			= mcl_structures.registered_structures["end_exit_portal_deferred"]
		mcl_structures.place_structure (portal_pos, exit_portal,
						PcgRandom (0), -1)
	end
end

core.register_entity("mcl_end:crystal", {
	initial_properties = {
		physical = true,
		visual = "mesh",
		visual_size = {x = 6, y = 6},
		collisionbox = {-1, 0.5, -1, 1, 2.5, 1},
		mesh = "mcl_end_crystal.b3d",
		textures = {"mcl_end_crystal.png"},
		collide_with_objects = false,
	},
	on_punch = crystal_explode,
	on_activate = set_crystal_animation,
	on_step = function (self, dtime, _)
		if mcl_end.get_crystal_beam_phase () == 3 then
			if not self._beam or not self._beam:is_valid () then
				local self_pos = self.object:get_pos ()
				local block_pos	= mcl_util.get_nodepos (self_pos)
				block_pos.y = block_pos.y
				local node_1 = core.get_node (block_pos)
				block_pos.y = block_pos.y - 1
				local node_2 = core.get_node (block_pos)

				if node_1.name == "mcl_core:bedrock"
					and node_2.name == "mcl_core:obsidian" then
					local beam = core.add_entity (block_pos, "mcl_end:crystal_beam")
					if beam then
						local entity = beam:get_luaentity ()
						entity._crystal_beam_src
							= vector.offset (block_pos, 0, 2, 0)
					end
					self._beam = beam
				end
			end
		elseif self._beam then
			self._beam:remove ()
			self._beam = nil
		end
	end,
	_exploded = false,
	_hittable_by_projectile = true,
	_mcl_pistons_unmovable = true,
	_forbid_portal_teleportation = true,
})

core.register_entity("mcl_end:crystal_beam", {
	initial_properties = {
		physical = false,
		visual = "cube",
		visual_size = {x = 1, y = 1, z = 1},
		textures = {
			"mcl_end_crystal_beam.png^[transformR90",
			"mcl_end_crystal_beam.png^[transformR90",
			"mcl_end_crystal_beam.png",
			"mcl_end_crystal_beam.png",
			"blank.png",
			"blank.png",
		},
		static_save = false,
	},
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = false,
	spin = 0,
	init = function(self, dragon, crystal)
		self.dragon = dragon
		self.crystal = crystal
	end,
	update_animation = function (self, dtime, dragon_pos, crystal_pos)
		self.spin = self.spin + dtime * math.pi * 2 / 4
		self.object:set_pos(vector.divide(vector.add(dragon_pos, crystal_pos), 2))
		local rot = vector.dir_to_rotation(vector.direction(dragon_pos, crystal_pos))
		rot.z = self.spin
		self.object:set_rotation(rot)
		local dist = vector.distance (dragon_pos, crystal_pos)
		self.object:set_properties({
			visual_size = {
				x = 0.5,
				y = 0.5,
				z = math.min (256, dist),
			},
		})
	end,
	on_step = function(self, dtime)
		if self.dragon and self.dragon:get_luaentity()
			and self.crystal and self.crystal:get_luaentity() then
			local dragon_pos, crystal_pos = self.dragon:get_pos(), self.crystal:get_pos()

			dragon_pos.y = dragon_pos.y + 4
			crystal_pos.y = crystal_pos.y + 2
			self:update_animation (dtime, dragon_pos, crystal_pos)
		elseif self._crystal_beam_src then
			local dst = mcl_end.get_crystal_beam_dst ()
			if dst then
				local src = vector.offset (self._crystal_beam_src, 0, 2, 0)
				self:update_animation (dtime, src, vector.offset (dst, 0, 1.0, 0))
			else
				self.object:remove ()
			end
		else
			self.object:remove()
		end
	end,
})

core.register_craftitem("mcl_end:crystal", {
	inventory_image = "mcl_end_crystal_item.png",
	description = S("End Crystal"),
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local pos = core.get_pointed_thing_position(pointed_thing)
			local node = core.get_node(pos)
			local node_name = node.name

			local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if rc then return rc end

			if find_crystal(pos) then return itemstack end
			if node_name == "mcl_core:obsidian" or node_name == "mcl_core:bedrock" then
				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				spawn_crystal(pos)
			end
		end
		return itemstack
	end,
	_tt_help = S("Ignited by a punch or a hit with an arrow").."\n"..S("Explosion power: @1", tostring(explosion_strength)),
	_doc_items_longdesc = S("End Crystals are explosive devices. They can be placed on Obsidian or Bedrock. Ignite them by a punch or a hit with an arrow. End Crystals can also be used the spawn the Ender Dragon by placing one at each side of the End Exit Portal."),
	_doc_items_usagehelp = S("Place the End Crystal on Obsidian or Bedrock, then punch it or hit it with an arrow to cause an huge and probably deadly explosion. To Spawn the Ender Dragon, place one at each side of the End Exit Portal."),

})

core.register_craft({
	output = "mcl_end:crystal",
	recipe = {
		{"mcl_core:glass", "mcl_core:glass", "mcl_core:glass"},
		{"mcl_core:glass", "mcl_end:ender_eye", "mcl_core:glass"},
		{"mcl_core:glass", "mcl_mobitems:ghast_tear", "mcl_core:glass"},
	}
})

core.register_alias("mcl_end_crystal:end_crystal", "mcl_end:crystal")

------------------------------------------------------------------------
-- Dragon resurrection.
------------------------------------------------------------------------

local mathmin = math.min
local mathmax = math.max
local floor = math.floor

local PHASE_START = 0
local PHASE_PREPARE = 1
local PHASE_REBUILD = 2
local PHASE_SUMMON = 3

local storage = core.get_mod_storage ()

local resurrection_state = {
	pillars = nil,
	phase = -1,
	tick = 0,

	c1 = vector.zero (),
	c2 = vector.zero (),
	c3 = vector.zero (),
	c4 = vector.zero (),
	beam_target = nil,
}

local function restore_resurrection_program ()
	local str = storage:get_string ("dragon_resurrection_state")
	if str and str ~= "" then
		local tbl = core.deserialize (str)
		resurrection_state = tbl
	end
end

restore_resurrection_program ()

local function save_resurrection_program ()
	storage:set_string ("dragon_resurrection_state",
			    core.serialize (resurrection_state))
end

core.register_on_shutdown (save_resurrection_program)

local end_dimension = mcl_levelgen.get_dimension ("mcl_levelgen:end")
local end_preset = end_dimension and end_dimension.preset

local function get_levelgen_spikes ()
	return mcl_end.get_spikes (end_preset)
end

local function get_spike_crystal_position (spike)
	local x = spike.center_x
	local y = spike.height + 1 - end_dimension.y_offset
	local z = -spike.center_z - 1

	return vector.new (x, y, z)
end

function mcl_end.resurrect_dragon (c1, c2, c3, c4)
	if resurrection_state.phase == -1 then
		resurrection_state.c1 = c1
		resurrection_state.c2 = c2
		resurrection_state.c3 = c3
		resurrection_state.c4 = c4
		resurrection_state.tick = 0
		resurrection_state.phase = PHASE_START

		if mcl_levelgen.levelgen_enabled then
			resurrection_state.pillars
				= get_levelgen_spikes ()
		else
			resurrection_state.pillars = {}
		end
		return true
	end
	return false
end

function mcl_end.get_crystal_beam_dst ()
	return resurrection_state.phase ~= -1
		and resurrection_state.beam_target
end

function mcl_end.get_crystal_beam_phase ()
	return resurrection_state.phase
end

local cids, param2s = {}, {}
local ipos3 = mcl_levelgen.ipos3

local function reconstruct_spike (spike)
	local cx, cz = spike.center_x, -spike.center_z - 1

	local x1 = cx - spike.radius
	local z1 = cz - spike.radius
	local x2 = cx + spike.radius
	local z2 = cz + spike.radius
	local y1 = end_dimension.y_global
	local y2 = end_dimension.y_max

	local cid_obsidian = core.get_content_id ("mcl_core:obsidian")
	local cid_iron_bars = core.get_content_id ("mcl_panes:bar")
	local cid_eternal_fire = core.get_content_id ("mcl_fire:eternal_fire")
	local cid_bedrock = core.get_content_id ("mcl_core:bedrock")
	local cid_air = core.CONTENT_AIR
	local height = spike.height - end_dimension.y_offset
	local crystal_pos = vector.new (cx, height, cz)
	mcl_explosions.explode (crystal_pos, 5, {}, nil, nil)

	local vm = VoxelManip (vector.new (x1, y1, z1),
			       vector.new (x2, y2, z2))
	vm:get_data (cids)
	vm:get_data (param2s)
	local area = VoxelArea (vm:get_emerged_area ())
	local r = spike.radius

	-- If you adjust this code (or end_spike_place_1), please be
	-- circumspect in maintaining the symmetry of the spike
	-- structure, so as not to require coordinate system
	-- conversions in this module.
	for x, y, z in ipos3 (x1, y1, z1, x2, mathmax (y2, height + 10), z2) do
		local d_sqr
			= ((x - cx) * (x - cx) + (z - cz) * (z - cz))
		if d_sqr <= r * r + 1 and y < height then
			local idx = area:index (x, y, z)
			cids[idx], param2s[idx] = cid_obsidian, 0
		elseif y > 65 then
			local idx = area:index (x, y, z)
			cids[idx], param2s[idx] = cid_air, 0
		end
	end

	-- Cage.

	if spike.guarded then
		for dx, y, dz in ipos3 (-2, height, -2, 2, mathmin (height + 3, y2), 2) do
			local at_corner = dx == -2 or dx == 2
				or dz == -2 or dz == 2
				or y == height + 3
			if at_corner then
				local idx = area:index (cx + dx, y, cz + dz)
				cids[idx], param2s[idx] = cid_iron_bars, 0
			end
		end
	end

	-- Fire and bedrock.
	local idx = area:index (cx, height + 1, cz)
	cids[idx], param2s[idx] = cid_eternal_fire, 0
	local idx = area:index (cx, height, cz)
	cids[idx], param2s[idx] = cid_bedrock, 0
	vm:set_data (cids)
	vm:set_param2_data (param2s)
	vm:write_to_map (true)
	if vm.close then
		vm:close ()
	end

	-- End crystal; any previous crystal has presumably been
	-- deleted by the preceding explosion.
	core.add_entity (crystal_pos, "mcl_end:crystal")
end

local function next_phase (phase)
	resurrection_state.tick = 0
	resurrection_state.phase = phase
end

local function delete_end_crystals_at_position (pos)
	for object in core.objects_inside_radius (pos, 1.0) do
		local entity = object:get_luaentity ()
		if entity and entity.name == "mcl_end:crystal" then
			object:remove ()
		end
	end
end

local total = 0
local end_min = mcl_vars.mg_end_min

local c1_beam, c2_beam, c3_beam, c4_beam

local function delete_beam_entities ()
	if c1_beam then
		c1_beam:remove ()
		c1_beam = nil
	end

	if c2_beam then
		c2_beam:remove ()
		c2_beam = nil
	end

	if c3_beam then
		c3_beam:remove ()
		c3_beam = nil
	end

	if c4_beam then
		c4_beam:remove ()
		c4_beam = nil
	end
end

local function animate_one_beam (obj, pos)
	local entity = obj and obj:get_luaentity ()
	if entity then
		entity._crystal_beam_src = pos
	end
end

local function create_and_animate_beam_entities (c1, c2, c3, c4)
	if not c1_beam or not c1_beam:is_valid () then
		c1_beam = core.add_entity (c1, "mcl_end:crystal_beam")
	end
	if not c2_beam or not c2_beam:is_valid () then
		c2_beam = core.add_entity (c2, "mcl_end:crystal_beam")
	end
	if not c3_beam or not c3_beam:is_valid () then
		c3_beam = core.add_entity (c3, "mcl_end:crystal_beam")
	end
	if not c4_beam or not c4_beam:is_valid () then
		c4_beam = core.add_entity (c4, "mcl_end:crystal_beam")
	end

	animate_one_beam (c1_beam, c1)
	animate_one_beam (c2_beam, c2)
	animate_one_beam (c3_beam, c3)
	animate_one_beam (c4_beam, c4)
end

local function tick_resurrection (dtime)
	total = total + dtime
	if total < 0.05 then
		return false
	end
	total = 0

	if resurrection_state.phase == -1 then
		delete_beam_entities ()
	end

	-- Do not tick if the crystals are not loaded any longer.
	local c1 = resurrection_state.c1
	local c2 = resurrection_state.c2
	local c3 = resurrection_state.c3
	local c4 = resurrection_state.c4
	if not c1 or not c2 or not c3 or not c4
		or not core.compare_block_status (c1, "active")
		or not core.compare_block_status (c2, "active")
		or not core.compare_block_status (c3, "active")
		or not core.compare_block_status (c4, "active") then
		return
	end

	local tick = resurrection_state.tick + 1
	resurrection_state.tick = tick
	local pillars = resurrection_state.pillars

	if resurrection_state.phase == PHASE_START then
		resurrection_state.beam_target
			= vector.new (0, end_min + 128, 0)
		next_phase (PHASE_PREPARE)
		create_and_animate_beam_entities (c1, c2, c3, c4)
	elseif resurrection_state.phase == PHASE_PREPARE then
		if tick > 100 then
			next_phase (PHASE_REBUILD)
		end
		create_and_animate_beam_entities (c1, c2, c3, c4)
	elseif resurrection_state.phase == PHASE_REBUILD then
		local spike_id = floor (tick / 40) + 1
		if tick % 40 == 39 then
			local spike = pillars[spike_id]
			if not spike then
				next_phase (PHASE_SUMMON)
			else
				reconstruct_spike (spike)
			end
		elseif tick % 40 == 0 then
			local spike = pillars[spike_id]
			if not spike then
				next_phase (PHASE_SUMMON)
			else
				resurrection_state.beam_target
					= get_spike_crystal_position (spike)
			end
		end
		create_and_animate_beam_entities (c1, c2, c3, c4)
	elseif resurrection_state.phase == PHASE_SUMMON then
		local dragon_pos = vector.new (0, end_min + 128, 0)
		if tick >= 100 then
			next_phase (-1)
			mcl_explosions.explode (c1, 6, {griefing = false,}, nil, nil)
			mcl_explosions.explode (c2, 6, {griefing = false,}, nil, nil)
			mcl_explosions.explode (c3, 6, {griefing = false,}, nil, nil)
			mcl_explosions.explode (c4, 6, {griefing = false,}, nil, nil)
			delete_end_crystals_at_position (c1)
			delete_end_crystals_at_position (c2)
			delete_end_crystals_at_position (c3)
			delete_end_crystals_at_position (c4)
			delete_beam_entities ()
			core.add_entity (dragon_pos, "mobs_mc:enderdragon")
		else
			resurrection_state.beam_target = dragon_pos
			create_and_animate_beam_entities (c1, c2, c3, c4)
		end
	end
end

core.register_globalstep (tick_resurrection)
