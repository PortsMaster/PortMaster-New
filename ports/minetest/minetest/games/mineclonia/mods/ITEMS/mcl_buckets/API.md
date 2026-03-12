# mcl_buckets
Add an API to register buckets to mcl

## mcl_buckets.register_liquid(def)

Register a new liquid
Accept folowing params:
* source_place: a string or function.
	* string: name of the node to place
	* function(pos): will returns name of the node to place with pos being the placement position
* source_take: table of liquid source node names to take
* bucketname: itemstring of the new bucket item
* inventory_image: texture of the new bucket item (ignored if itemname == nil)
* name: user-visible bucket description
* longdesc: long explanatory description (for help)
* usagehelp: short usage explanation (for help)
* tt_help: very short tooltip help
* extra_check(pos, placer): (optional) function(pos)
* groups: optional list of item groups


**Usage exemple:**
```lua
mcl_buckets.register_liquid({
	bucketname = "dummy:bucket_dummy",
	--source_place = "dummy:dummy_source",
	source_place = function(pos)
		if condition then
			return "dummy:dummy_source"
		else
			return "dummy:dummy_source_nether"
		end
	end,
	source_take = {"dummy:dummy_source"},
	inventory_image = "bucket_dummy.png",
	name = S("Dummy liquid Bucket"),
	longdesc = S("This bucket is filled with a dummy liquid."),
	usagehelp = S("Place it to empty the bucket and create a dummy liquid source."),
	tt_help = S("Places a dummy liquid source"),
	extra_check = function(pos, placer)
		--pos = pos where the liquid should be placed
		--placer people who tried to place the bucket (can be nil)

		--no liquid node will be placed
		--the bucket will not be emptied
		--return false, false

		--liquid node will be placed
		--the bucket will be emptied
		return true, true
	end,
	groups = { dummy_group = 123 },
})
```