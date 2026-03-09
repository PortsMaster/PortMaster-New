## mcl_furnaces

### mcl_furnaces.register_furnace(node_basename, furnace_definition)
Registeres a new type of furnace

### Furnace definition
{
	cook_group = "blast_furnace_smeltable", --optional: itemgroup this furnace is restricted to
	factor = 2, --optional: cook time factor when using cook_group
	node_normal = { -- node definition overrides of the normal furnace node (node_basename)
		tiles = {}, --...
	},
	node_active = { }, --node definition of the active furnace node (node_basename.."_active")
	get_active_formspec = function(fuel_percent, item_percent, name) end, --optional: function that returns the active furnace's formspec
	get_inactive_formspec = function(name) end, -- optional: function that returns the inactive furnace's formspec
}
