mcl_sus_nodes = {}
local modname = core.get_current_modname()
local S = core.get_translator(modname)

local item_entities = {}

local HIDE_DELAY = 5

local tpl = {
	groups = { crumbly = 1, oddly_breakable_by_hand = 3, falling_node = 1, brushable = 1, suspicious_node = 1},
	paramtype = "light",
}

local sus_drops_default = {
	"mcl_core:diamond",
	"mcl_farming:wheat_item",
	"mcl_dyes:blue",
	"mcl_dyes:white",
	"mcl_dyes:orange",
	"mcl_dyes:light_blue",
	"mcl_core:coal_lump",
	"mcl_flowerpots:flower_pot",
}

local desert_well_loot = {
	stacks_min = 1,
	stacks_max = 1,
	items = {
		{ itemstring = "mcl_pottery_sherds:arms_up", weight = 2, },
		{ itemstring = "mcl_pottery_sherds:brewer", weight = 2, },
		{ itemstring = "mcl_core:brick", weight = 1 },
		{ itemstring = "mcl_core:emerald", weight = 1 },
		{ itemstring = "mcl_core:stick", weight = 1 },
		{ itemstring = "mcl_sus_stew:stew", weight = 1 },
	},
}

local sus_node_loot = {
	trail_ruins_common = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_core:emerald",
				weight = 2,
			},
			{
				itemstring = "mcl_farming:wheat_item",
				weight = 2,
			},
			{
				itemstring = "mcl_tools:hoe_wood",
				weight = 2,
			},
			{
				itemstring = "mcl_core:clay_lump",
				weight = 2,
			},
			{
				itemstring = "mcl_core:brick",
				weight = 2,
			},
			{
				itemstring = "mcl_dyes:yellow",
				weight = 2,
			},
			{
				itemstring = "mcl_dyes:blue",
				weight = 2,
			},
			{
				itemstring = "mcl_dyes:light_blue",
				weight = 2,
			},
			{
				itemstring = "mcl_dyes:white",
				weight = 2,
			},
			{
				itemstring = "mcl_dyes:orange",
				weight = 2,
			},
			{
				itemstring = "mcl_candles:candle_1",
				weight = 2,
				func = function (stack, pr)
					local colors = {
						"red",
						"green",
						"purple",
						"brown",
					}
					local color = colors[pr:next (1, #colors)]
					mcl_candles.set_candle_properties (stack, color)
				end,
			},
			{
				itemstring = "mcl_panes:pane_magenta_flat",
			},
			{
				itemstring = "mcl_panes:pane_pink_flat",
			},
			{
				itemstring = "mcl_panes:pane_blue_flat",
			},
			{
				itemstring = "mcl_panes:pane_light_blue_flat",
			},
			{
				itemstring = "mcl_panes:pane_red_flat",
			},
			{
				itemstring = "mcl_panes:pane_yellow_flat",
			},
			{
				itemstring = "mcl_signs:hanging_sign_spruce",
			},
			{
				itemstring = "mcl_signs:hanging_sign_oak"
			},
			{
				itemstring = "mcl_core:gold_nugget",
			},
			{
				itemstring = "mcl_core:coal_lump",
			},
			{
				itemstring = "mcl_farming:wheat_seeds",
			},
			{
				itemstring = "mcl_farming:beetroot_seeds",
			},
			{
				itemstring = "mcl_core:deadbush",
			},
			{
				itemstring = "mcl_flowerpots:flower_pot",
			},
			{
				itemstring = "mcl_mobitems:string",
			}
			-- TODO!
			-- {
			-- 	itemstring = "mcl_leads:lead",
			-- },
		},
	},
	trail_ruins_rare = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{
				itemstring = "mcl_pottery_sherds:burn",
			},
			{
				itemstring = "mcl_pottery_sherds:danger",
			},
			{
				itemstring = "mcl_pottery_sherds:friend",
			},
			{
				itemstring = "mcl_pottery_sherds:heart",
			},
			{
				itemstring = "mcl_pottery_sherds:heartbreak",
			},
			{
				itemstring = "mcl_pottery_sherds:howl",
			},
			{
				itemstring = "mcl_pottery_sherds:sheaf",
			},
			{
				itemstring = "mcl_armor:wayfinder",
			},
			-- TODO!
			-- {
			-- 	itemstring = "mcl_armor:raiser",
			-- },
			-- {
			-- 	itemstring = "mcl_armor:shaper",
			-- },
			-- {
			-- 	itemstring = "mcl_armor:host",
			-- },
			-- {
			-- 	itemstring = "mcl_jukebox:record_relic",
			-- },
		},
	},
	desert_pyramid_archeology = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_pottery_sherds:archer", weight = 1, },
			{ itemstring = "mcl_core:emerald", weight = 1 },
			{ itemstring = "mcl_mobitems:gunpowder", weight = 1 },
			{ itemstring = "mcl_pottery_sherds:miner", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:prize", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:skull", weight = 1, },
			{ itemstring = "mcl_tnt:tnt", weight = 1 },
			{ itemstring = "mcl_core:diamond", weight = 1 },
		},
	},
	ocean_ruins_cold = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 2 },
			{ itemstring = "mcl_core:emerald", weight = 2 },
			{ itemstring = "mcl_farming:wheat_item", weight = 2 },
			{ itemstring = "mcl_farming:hoe_wood", weight = 2 },
			{ itemstring = "mcl_core:gold_nugget", weight = 2 },
			{ itemstring = "mcl_pottery_sherds:blade", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:explorer", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:mourner", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:plenty", weight = 1, },
			{ itemstring = "mcl_tools:axe_iron", weight = 1 },
		},
	},
	ocean_ruins_warm = {
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mcl_core:coal_lump", weight = 2 },
			{ itemstring = "mcl_core:emerald", weight = 2 },
			{ itemstring = "mcl_farming:wheat_item", weight = 2 },
			{ itemstring = "mcl_farming:hoe_wood", weight = 2 },
			{ itemstring = "mcl_core:gold_nugget", weight = 2 },
			{ itemstring = "mcl_pottery_sherds:angler", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:shelter", weight = 1, },
			--FIXME: add sniffer egg { itemstring = "mobs_mc:SNIFFER", weight = 1, },
			{ itemstring = "mcl_pottery_sherds:snort", weight = 1, },
			{ itemstring = "mcl_tools:axe_iron", weight = 1 },
		},
	},
}

function mcl_sus_nodes.get_random_item(pos)
	local meta = core.get_meta(pos)
	local str = meta:get_string ("mcl_sus_nodes:desert_well_loot_seed")
	if str ~= "" then
		local seed = tonumber (str) or 0
		local pr = PcgRandom (seed)
		return mcl_loot.get_loot (desert_well_loot, pr)[1]
	else
		local str = meta:get_string ("mcl_sus_nodes:loot_seed")
		local kind = meta:get_string ("mcl_sus_nodes:loot_type")

		if sus_node_loot[kind] then
			local seed = tonumber (str) or 0
			local pr = PcgRandom (seed)
			local loot = mcl_loot.get_loot (sus_node_loot[kind], pr)
			return loot[1]
		else
			local struct = meta:get_string("structure")
			local structdef = mcl_structures.registered_structures[struct]
			local pr = PcgRandom (core.hash_node_position(pos))
			if struct ~= "" and structdef and structdef.loot and structdef.loot["SUS"] then
				local lootitems = mcl_loot.get_multi_loot(structdef.loot["SUS"], pr)
				if #lootitems > 0 then
					return lootitems[1]
				end
			else
				return sus_drops_default[pr:next(1, #sus_drops_default)]
			end
		end
	end
end

local function brush_node(_, _, pointed_thing)
	if pointed_thing and pointed_thing.type == "node" then
		local pos = core.get_pointed_thing_position(pointed_thing)
		local node = core.get_node(pos)
		if core.get_item_group(node.name,"brushable") == 0 then return end
		local ph = core.hash_node_position(vector.round(pos))
		local dir = vector.direction(pointed_thing.under,pointed_thing.above)
		local def = core.registered_nodes[node.name]

		if not item_entities[ph] then
			local o = core.add_entity(pos + (dir * 0.38),"mcl_sus_nodes:item_entity")
			local l = o:get_luaentity()
			l._item = mcl_sus_nodes.get_random_item(pos)
			if not l._item then
				o:remove()
				return
			end
			l._stage = 1
			l._nodepos = pos
			l._poshash = ph
			l._dir = dir
			o:set_properties({
				wield_item = l._item,
			})
			if dir.z ~= 0 then
				o:set_rotation(vector.new(0,0.5*math.pi,0))
			end
			item_entities[ph] = l
		else
			local p = item_entities[ph].object:get_pos()
			item_entities[ph]._hide = nil
			item_entities[ph]._hide_timer = HIDE_DELAY
			if p and math.random(3) == 1  then
				item_entities[ph]._stage = item_entities[ph]._stage + 1
				item_entities[ph].object:set_pos(p + ( vector.new(item_entities[ph]._dir) * ( 0.02 * item_entities[ph]._stage )))
			end
		end
		if item_entities[ph]._stage >= 4 then
			core.add_item(pos+dir,item_entities[ph]._item)
			item_entities[ph].object:remove()
			item_entities[ph] = nil
			core.swap_node(pos,{name = def._mcl_sus_nodes_parent})
		elseif item_entities[ph]._stage <= 0 then
			core.swap_node(pos,{name=def._mcl_sus_nodes_main})
		else
			core.swap_node(pos,{name=def._mcl_sus_nodes_main.."_"..item_entities[ph]._stage})
		end
	end
end

local function overlay_tiles(orig,overlay)
	local tiles = table.copy(orig)
	for k,v in pairs(tiles) do
		if v.name then
			tiles[k].name = tiles[k].name.."^"..overlay
		else
			tiles[k] = v.."^"..overlay
		end
	end
	return tiles
end

function mcl_sus_nodes.register_sus_node(name,source,overrides)
	local sdef = core.registered_nodes[source]
	assert(sdef, "[mcl_sus_nodes] trying to register "..tostring(name).." but source node "..tostring(source).."doesn't exist")
	local main_itemstring = "mcl_sus_nodes:"..name
	table.shuffle(sus_drops_default)
	local def = table.merge(sdef,tpl,{
		description = S("Suspicious "..name),
		tiles = overlay_tiles(sdef.tiles,"mcl_sus_nodes_suspicious_overlay.png"),
		drop = source,
		_mcl_sus_nodes_parent = source,
		_mcl_sus_nodes_main = main_itemstring,
		_mcl_sus_nodes_drops = table.copy(sus_drops_default),
		_mcl_falling_node_alternative = source,
	},overrides or {})
	core.register_node(main_itemstring,def)
	for i=1,3 do
		core.register_node(main_itemstring.."_"..i,table.merge(def,{
			tiles = overlay_tiles(sdef.tiles,"mcl_sus_nodes_suspicious_overlay_"..i..".png"),
			groups = table.merge(tpl.groups, { suspicious_stage =i, not_in_creative_inventory = 1 }),
		}))
	end
end

core.register_entity("mcl_sus_nodes:item_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
		collisionbox = {0,0,0,0,0,0},
		pointable = true,
		--static_save = false,
	},
	on_step = function(self, dtime)
		self._timer = (self._timer or 1) - dtime
		if self._timer < 0 then
			if core.get_item_group(core.get_node(self._nodepos or vector.zero()).name,"suspicious_node") == 0 or self._stage <= 0 or not self._dir then
				if self._poshash then item_entities[self._poshash] = nil end
				self.object:remove()
				return
			end
			if self._hide then
				self._stage = self._stage - 1
				self.object:set_pos(self.object:get_pos() - ( vector.new(self._dir) * ( 0.02 * self._stage )))
				local def = core.registered_nodes[core.get_node(self._nodepos).name]
				if self._stage <= 0 then
					core.swap_node(self._nodepos, {name=def._mcl_sus_nodes_main})
				else
					core.swap_node(self._nodepos, {name=def._mcl_sus_nodes_main.."_"..self._stage})
				end
			end
			self._timer = 1
		end
		self._hide_timer = ( self._hide_timer or HIDE_DELAY ) - dtime
		if self._hide_timer < 0 then
			self._hide = true
			self._hide_timer = HIDE_DELAY
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
	on_activate = function(self, staticdata, dtime_s)
		if dtime_s and dtime_s > 5 then
			self.object:remove()
			return
		elseif dtime_s then
			self._hide_timer = 5 - dtime_s
		end
		if type(staticdata) == "userdata" then return end
		local s = core.deserialize(staticdata)
		if type(s) == "table" then
			for k,v in pairs(s) do self[k] = v end
			item_entities[self._poshash] = self
			if self._item then
				self.object:set_properties({
					wield_item = self._item,
				})
			else
				self.object:remove()
				return
			end
		else
			self._poshash = core.hash_node_position(self.object:get_pos())
		end
		self.object:set_armor_groups({ immortal = 1 })
	end,
})

core.register_tool("mcl_sus_nodes:brush", {
	description = S("Brush"),
	_doc_items_longdesc = S("Brushes are used in archeology to discover hidden items"),
	_doc_items_usagehelp = S("Use the brush on a suspicious node to uncover its secrets"),
	_doc_items_hidden = false,
	inventory_image = "mcl_sus_nodes_brush.png",
	groups = { tool=2, brush = 1, dig_speed_class=0, enchantability=0 },
	on_use = brush_node,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
	_mcl_uses = 64
})

core.register_craft({
	output = "mcl_sus_nodes:brush",
	recipe = {
		{ "mcl_mobitems:feather"},
		{ "mcl_copper:copper_ingot"},
		{ "mcl_core:stick"},
	}
})

mcl_sus_nodes.register_sus_node("sand","mcl_core:sand",{
	description = S("Suspicious Sand"),
})

mcl_sus_nodes.register_sus_node("gravel","mcl_core:gravel",{
	description = S("Suspicious Gravel"),
})

------------------------------------------------------------------------
-- Level generator interface.
------------------------------------------------------------------------

local function handle_suspicious_sand_meta (name, data)
	if data.name == "desert_well" then
		local meta = core.get_meta (data.pos)
		meta:set_string ("mcl_sus_nodes:desert_well_loot_seed",
				 tostring (data.loot_seed))
	end
end

mcl_levelgen.register_notification_handler ("mcl_sus_nodes:suspicious_sand_meta",
					    handle_suspicious_sand_meta)

local v = vector.zero ()
local level_to_minetest_position
	= mcl_levelgen.level_to_minetest_position

local function handle_suspicious_sand_structure_meta (name, data)
	-- print (#data)
	for _, data in ipairs (data) do
		v.x, v.y, v.z = level_to_minetest_position (data[1], data[2], data[3])
		core.load_area (v)
		local meta = core.get_meta (v)
		-- print ("--->", data[4], data[5])
		meta:set_string ("mcl_sus_nodes:loot_seed", tostring (data[4]))
		meta:set_string ("mcl_sus_nodes:loot_type", data[5])
	end
end

mcl_levelgen.register_notification_handler ("mcl_sus_nodes:suspicious_sand_structure_meta",
					    handle_suspicious_sand_structure_meta)
