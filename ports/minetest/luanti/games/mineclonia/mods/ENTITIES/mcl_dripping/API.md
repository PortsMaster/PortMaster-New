# mcl_dripping

## API

```lua
mcl_dripping.register_drop({
	-- The group the liquid's nodes belong to
	liquid   = "water",
	-- The texture used (particles will take a random 2x2 area of it)
	texture  = "default_water_source_animated.png",
	-- Define particle glow, ranges from `0` to `minetest.LIGHT_MAX`
	light    = 1,
	-- The nodes (or node group) the particles will spawn under
	nodes    = { "group:opaque", "group:leaves" },
	-- The sound that will be played then the particle detaches from the roof, see SimpleSoundSpec in lua_api.txt
	sound    = "drippingwater_drip",
	-- The interval for the ABM to run
	interval = 60,
	-- The chance of the ABM
	chance   = 10,
})
```
