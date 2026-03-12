-- CUSTOM SNIPPETS --

-- Custom text (_tt_help)
tt.register_snippet(function(itemstring)
	local def = core.registered_items[itemstring]
	if def and def._tt_help then
		return def._tt_help
	end
end)


