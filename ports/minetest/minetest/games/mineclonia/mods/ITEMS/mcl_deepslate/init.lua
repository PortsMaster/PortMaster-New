local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

mcl_deepslate = {}
mcl_deepslate.translator = core.get_translator(modname)
local S = mcl_deepslate.translator

function mcl_deepslate.register_deepslate_ore(item, desc, extra, basename)
	local nodename = "mcl_deepslate:deepslate_with_"..item
	local basename = basename or ("mcl_core:stone_with_" .. item)

	local def = table.copy(core.registered_nodes[basename])
	def._doc_items_longdesc = S("@1 is a variant of @2 that can generate in deepslate and tuff blobs.", desc, def.description)
	def.description = desc
	def.tiles = { "mcl_deepslate_" .. item .. "_ore.png" }

	table.update(def,extra or {})

	core.register_node(nodename, def)
end

function mcl_deepslate.register_variants(name, defs)
	assert(name, "[mcl_deepslate] mcl_deepslate.register_variants called without a valid name, refer to API.md in mcl_deepslate.")
	assert(defs.basename, "[mcl_deepslate] mcl_deepslate.register_variants needs a basename field to work, refer to API.md in mcl_deepslate.")
	assert(defs.basetiles, "[mcl_deepslate] mcl_deepslate.register_variants needs a basetiles field to work, refer to API.md in mcl_deepslate.")

	local main_itemstring = "mcl_deepslate:"..defs.basename.."_"..name
	local main_def = table.merge({
		_doc_items_hidden = false,
		tiles = { defs.basetiles.."_"..name..".png" },
		is_ground_content = false,
		groups = { pickaxey = 1, building_block = 1, material_stone = 1 },
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 6,
		_mcl_hardness = 3.5,
		_mcl_silk_touch_drop = true,
	}, defs.basedef or {})
	if defs.node then
		defs.node.groups = table.merge(main_def.groups, defs.node.groups)
		core.register_node(main_itemstring, table.merge(main_def, defs.node))
	end

	if defs.cracked then
		core.register_node(main_itemstring.."_cracked", table.merge(main_def, {
			_doc_items_longdesc = S("@1 are a cracked variant.", defs.cracked.description),
			tiles = { defs.basetiles.."_"..name.."_cracked.png" },
		}, defs.cracked))
	end
	if defs.node and defs.stair then
		mcl_stairs.register_stair(defs.basename.."_"..name, {
			description = defs.stair.description,
			baseitem = main_itemstring,
			overrides = defs.stair
		})
	end
	if defs.node and defs.slab then
		mcl_stairs.register_slab(defs.basename.."_"..name, {
			description = defs.slab.description,
			baseitem = main_itemstring,
			overrides = defs.slab
		})
	end

	if defs.node and defs.wall then
		mcl_walls.register_wall("mcl_deepslate:"..defs.basename..name.."wall", defs.wall.description, main_itemstring, nil, nil, nil, nil, defs.wall)
	end
end

dofile(modpath.."/deepslate.lua")
dofile(modpath.."/tuff.lua")
