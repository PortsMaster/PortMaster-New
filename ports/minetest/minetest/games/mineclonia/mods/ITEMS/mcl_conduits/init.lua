mcl_conduits = {}
local modname = core.get_current_modname()
local S = core.get_translator(modname)

local check_interval = 5
local conduit_nodes = { "mcl_ocean:prismarine",  "mcl_ocean:prismarine_brick", "mcl_ocean:prismarine_dark", "mcl_ocean:sea_lantern" }

local frame_offsets = {
	vector.new(1, 2, 0),
	vector.new(2, 2, 0),
	vector.new(-1, 2, 0),
	vector.new(-2, 2, 0),
	vector.new(0, 2, 0),
	vector.new(0, 2, 1),
	vector.new(0, 2, 2),
	vector.new(0, 2, -1),
	vector.new(0, 2, -2),

	vector.new(2, 1, 0),
	vector.new(-2, 1, 0),
	vector.new(0, 1, 2),
	vector.new(0, 1, -2),

	vector.new(2, 0, 0),
	vector.new(2, 0, 1),
	vector.new(2, 0, 2),

	vector.new(-2, 0, 0),
	vector.new(-2, 0, 1),
	vector.new(-2, 0, 2),

	vector.new(2, 0, -1),
	vector.new(2, 0, -2),
	vector.new(-2, 0, -1),
	vector.new(-2, 0, -2),

	vector.new(0, 0, 2),
	vector.new(1, 0, 2),

	vector.new(0, 0, -2),
	vector.new(1, 0, -2),

	vector.new(-1, 0, 2),
	vector.new(-1, 0, -2),

	vector.new(2, -1, 0),
	vector.new(-2, -1, 0),
	vector.new(0, -1, 2),
	vector.new(0, -1, -2),

	vector.new(1, -2, 0),
	vector.new(2, -2, 0),
	vector.new(-1, -2, 0),
	vector.new(-2, -2, 0),
	vector.new(0, -2, 0),
	vector.new(0, -2, 1),
	vector.new(0, -2, 2),
	vector.new(0, -2, -1),
	vector.new(0, -2, -2),
}

local entity_pos_offset = vector.new(0, -1.25, 0)

local function check_conduit(pos)
	local water = core.find_nodes_in_area(vector.offset(pos, -1,-1,-1), vector.offset(pos, 1, 1, 1), {"group:water"})
	local cname = core.get_node(pos).name
	if #water < 26 or ( cname ~= "mcl_conduits:conduit" and #water < 27 ) then return false end
	local pn = 0
	for _, v in pairs(frame_offsets) do
		if table.indexof(conduit_nodes, core.get_node(vector.add(pos, v)).name) ~= -1 then
			pn = pn + 1
		end
	end
	if pn < 16 then return false end
	return math.floor(pn / 7) * 16
end

function mcl_conduits.player_effect(player)
    if core.get_item_group(mcl_player.players[player].nodes.feet, "water") == 0 then return end
    mcl_potions.give_effect_by_level ("conduit_power", player, 1, 17)
end

function mcl_conduits.conduit_damage(ent)
	if core.get_item_group(core.get_node(ent.object:get_pos()).name, "water") == 0 then return end
	mcl_util.deal_damage(ent.object, 4, {type = "magic"})
end

core.register_entity("mcl_conduits:conduit", {
	initial_properties = {
		physical = true,
		visual = "mesh",
		visual_size = {x = 4, y = 4},
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		mesh = "mcl_end_crystal.b3d",
		textures = {"mcl_conduit_conduit.png"},
		collide_with_objects = false,
	},
	on_activate = function(self, staticdata)
		local d = core.deserialize(staticdata)
		if d then
			self._pos = d._pos
		end
		self.object:set_armor_groups({immortal = 1})
		self.object:set_animation({x = 0, y = 120}, 3)
	end,
	get_staticdata = function(self)
		return core.serialize({ _pos = self._pos })
	end,
	on_step = function(self, dtime)
		self._timer = (self._timer or check_interval) - dtime
		if self._timer > 0 then return end
		self._timer = check_interval
		if not self._pos then
			self.object:remove()
			return
		end
		local lvl = check_conduit(self._pos)
		if not lvl then
			core.set_node(self._pos, {name = "mcl_conduits:conduit"})
			self.object:remove()
			return
		end

		for pl in mcl_util.connected_players(self._pos, lvl * 2) do
			mcl_conduits.player_effect(pl)
		end

		for _, ent in pairs(core.luaentities) do
			if ent.is_mob and ent.type == "monster" and ent.object and ent.object:get_pos() and vector.distance(self._pos, ent.object:get_pos()) < 9 then
				mcl_conduits.conduit_damage(ent)
			end
		end
	end
})
local conduit_box = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25, }
core.register_node("mcl_conduits:conduit", {
	description = S("Conduit"),
	_doc_longdesc = S("A conduit provides certain status effects to nearby players much like a beacon but under water"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = conduit_box,
	},
	collisionbox = conduit_box,
	selectionbox = conduit_box,
	groups = { pickaxey = 1, deco_block = 1, rarity = 1 },
	light_source = core.LIGHT_MAX,
	tiles = { "mcl_conduit_conduit_node.png", },
	_mcl_hardness = 3,
})

core.register_abm({
	label = "Conduit Activation",
	nodenames = { "mcl_conduits:conduit" },
	interval = check_interval,
	chance = 1,
	action = function(pos, _)
		for v in core.objects_inside_radius(vector.subtract(pos, entity_pos_offset), 0.5) do
			if v.name == "mcl_conduits:conduit" then return end
		end
		if check_conduit(pos) then
			core.remove_node(pos)
			local o = core.add_entity(vector.add(pos, entity_pos_offset) , "mcl_conduits:conduit")
			if o then
				local l = o:get_luaentity()
				l._pos = pos
			end
		end
	end
})

core.register_craft({
	output = "mcl_conduits:conduit",
	recipe = {
		{"mcl_mobitems:nautilus_shell", "mcl_mobitems:nautilus_shell", "mcl_mobitems:nautilus_shell"},
		{"mcl_mobitems:nautilus_shell", "mcl_mobitems:heart_of_the_sea", "mcl_mobitems:nautilus_shell"},
		{"mcl_mobitems:nautilus_shell", "mcl_mobitems:nautilus_shell", "mcl_mobitems:nautilus_shell"},
	},
})
