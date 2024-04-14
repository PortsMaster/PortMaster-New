mcl_sus_nodes = {}
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local item_entities = {}

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

function mcl_sus_nodes.get_random_item(pos)
	local meta = minetest.get_meta(pos)
	local struct = meta:get_string("structure")
	local structdef = mcl_structures.registered_structures[struct]
	if struct ~= "" and structdef and structdef.loot and structdef.loot["SUS"] then
		local lootitems = mcl_loot.get_multi_loot(structdef.loot["SUS"], PseudoRandom(minetest.hash_node_position(pos)))
		if #lootitems > 0 then
			return lootitems[1]
		end
	else
		table.shuffle(sus_drops_default)
		return sus_drops_default[1]
	end
end

local function brush_node(itemstack, user, pointed_thing)
	if pointed_thing and pointed_thing.type == "node" then
		local pos = minetest.get_pointed_thing_position(pointed_thing)
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name,"brushable") == 0 then return end
		local ph = minetest.hash_node_position(vector.round(pos))
		local dir = vector.direction(pointed_thing.under,pointed_thing.above)
		local def = minetest.registered_nodes[node.name]

		if not item_entities[ph] then
			local o = minetest.add_entity(pos + (dir * 0.38),"mcl_sus_nodes:item_entity")
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
			if p and math.random(3) == 1  then
				item_entities[ph]._stage = item_entities[ph]._stage + 1
				item_entities[ph].object:set_pos(p + ( vector.new(item_entities[ph]._dir) * ( 0.02 * item_entities[ph]._stage )))
			end
		end
		if item_entities[ph]._stage == 4 then
			minetest.add_item(pos+dir,item_entities[ph]._item)
			item_entities[ph].object:remove()
			item_entities[ph] = nil
			minetest.swap_node(pos,{name = def._mcl_sus_nodes_parent})
		else
			minetest.swap_node(pos,{name=def._mcl_sus_nodes_main.."_"..item_entities[ph]._stage})
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
	local sdef = minetest.registered_nodes[source]
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
	},overrides or {})
	minetest.register_node(main_itemstring,def)
	for i=1,3 do
		minetest.register_node(main_itemstring.."_"..i,table.merge(def,{
			tiles = overlay_tiles(sdef.tiles,"mcl_sus_nodes_suspicious_overlay_"..i..".png"),
			groups = table.merge(tpl.groups, { suspicious_stage =i, not_in_creative_inventory = 1 }),
		}))
	end
end

minetest.register_entity("mcl_sus_nodes:item_entity", {
	initial_properties = {
		physical = false,
		visual = "wielditem",
		visual_size = {x=0.25, y=0.25},
		collisionbox = {0,0,0,0,0,0},
		pointable = true,
	},
	on_step = function(self,dtime)
		self._timer = (self._timer or 1) - dtime
		if self._timer > 0 then return end
		if minetest.get_item_group(minetest.get_node(self._nodepos or vector.zero()).name,"suspicious_node") == 0 then
			if self._poshash then item_entities[self._poshash] = nil end
			self.object:remove()
			return
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
		return minetest.serialize(d)
	end,
	on_activate = function(self, staticdata)
		if type(staticdata) == "userdata" then return end
		local s = minetest.deserialize(staticdata)
		if type(s) == "table" then
			for k,v in pairs(s) do self[k] = v end
			self._poshash = minetest.hash_node_position(self.object:get_pos())
			item_entities[self._poshash] = self
			if self._item then
				self.object:set_properties({
					wield_item = self._item,
				})
			else
				self.object:remove()
				return
			end
		end
		self.object:set_armor_groups({ immortal = 1 })
	end,
})

minetest.register_tool("mcl_sus_nodes:brush", {
	description = S("Brush"),
	_doc_items_longdesc = S("Brushes are used in archeology to discover hidden items"),
	_doc_items_usagehelp = S("Use the brush on a suspicious node to uncover its secrets"),
	_doc_items_hidden = false,
	inventory_image = "mcl_sus_nodes_brush.png",
	groups = { tool=1, brush = 1, dig_speed_class=0, enchantability=0 },
	on_use = brush_node,
	sound = { breaks = "default_tool_breaks" },
	_mcl_toollike_wield = true,
})

minetest.register_craft({
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
