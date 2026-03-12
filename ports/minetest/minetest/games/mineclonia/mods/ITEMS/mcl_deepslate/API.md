# mcl_deepslate

`mcl_deepslate.register_variants(name, def)`

## Variant definition

```lua
{
	basename = "deepslate",
	basetiles = "mcl_deepslate",
	basedef = {
		_mcl_hardness = 5,
	},

	-- the following should contain additional node definition fields of the individual variants, most importantly description and _doc_longdesc fields.
	-- note that the tiles field if not explicitly specified will be automatically generated from the "basetiles" field. Any fields in these tables will end up in the node definitions.
	node = {},
	cracked = {},

	--the following will only work if the above "node" field was specified as they are constructed from the base node.
	stairs = {},
	slabs = {},
	wall = {},
}
```
