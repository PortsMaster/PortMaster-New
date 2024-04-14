## mcl_info
An api to make custom entries in the mcl2 debug hud.

### mcl_info.register_debug_field(name,defintion)
Debug field defintion example:
{
	level = 3,
	--show with debug level 3 and upwards

	func = function(player,pos) return minetest.pos_to_string(pos) end,
	-- Function that is run for at each debug
	-- sample (default: every .63 seconds)
	-- It should output a string and determines
	-- the content of the debug field.
}

### mcl_info.registered_debug_fields
Table the debug definitions are stored in. Do not modify this directly. If you need to overwrite a field just set it again with mcl_info.register_debug_field().
