-- Lava in the Nether

local S = minetest.get_translator(minetest.get_current_modname())

-- TODO: Increase flow speed. This could be done by reducing viscosity,
-- but this would also allow players to swim faster in lava.

local lava_src_def = table.copy(minetest.registered_nodes["mcl_core:lava_source"])
lava_src_def.description = S("Nether Lava Source")
lava_src_def._doc_items_create_entry = false
lava_src_def._doc_items_entry_name = nil
lava_src_def._doc_items_longdesc = nil
lava_src_def._doc_items_usagehelp = nil
lava_src_def.liquid_range = 7
lava_src_def.liquid_alternative_source = "mcl_nether:nether_lava_source"
lava_src_def.liquid_alternative_flowing = "mcl_nether:nether_lava_flowing"
minetest.register_node("mcl_nether:nether_lava_source", lava_src_def)

local lava_flow_def = table.copy(minetest.registered_nodes["mcl_core:lava_flowing"])
lava_flow_def.description = S("Flowing Nether Lava")
lava_flow_def._doc_items_create_entry = false
lava_flow_def.liquid_range = 7
lava_flow_def.liquid_alternative_flowing = "mcl_nether:nether_lava_flowing"
lava_flow_def.liquid_alternative_source = "mcl_nether:nether_lava_source"
minetest.register_node("mcl_nether:nether_lava_flowing", lava_flow_def)

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_source")
	doc.add_entry_alias("nodes", "mcl_core:lava_source", "nodes", "mcl_nether:nether_lava_flowing")
end

