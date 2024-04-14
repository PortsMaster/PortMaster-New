-- CUSTOM SNIPPETS --

-- Custom text (_tt_help)
tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if def._tt_help then
		return def._tt_help
	end
end)


