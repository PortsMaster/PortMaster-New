local S = minetest.get_translator(minetest.get_current_modname())

local mod_doc_basics = minetest.get_modpath("doc_basics")

local doc_identifier = {}

doc_identifier.registered_objects = {}

-- API
doc.sub.identifier = {}

function doc.sub.identifier.register_object(object_name, category_id, entry_id)
	doc_identifier.registered_objects[object_name] = { category = category_id, entry = entry_id }
end

-- END OF API

function doc_identifier.identify(itemstack, user, pointed_thing)
	local username = user:get_player_name()
	local function show_message(username, itype, param)
		local vsize = 2
		local message
		if itype == "error_item" then
			message = S("No help entry for this item could be found.")
		elseif itype == "error_node" then
			message = S("No help entry for this block could be found.")
		elseif itype == "error_unknown" then
			vsize = vsize + 2
			local mod
			if param then
				local colon = string.find(param, ":")
				if colon and colon > 1 then
					mod = string.sub(param,1,colon-1)
				end
			end
			message = S("Error: This node, item or object is undefined. This is always an error.").."\n"..
				S("This can happen for the following reasons:").."\n"..
				S("• The mod which is required for it is not enabled").."\n"..
				S("• The author of the game or a mod has made a mistake")
			message = message .. "\n\n"

			if mod then
				if minetest.get_modpath(mod) then
					message = message .. S("It appears to originate from the mod “@1”, which is enabled.", mod)
					message = message .. "\n"
				else
					message = message .. S("It appears to originate from the mod “@1”, which is not enabled!", mod)
					message = message .. "\n"
				end
			end
			if param then
				message = message .. S("Its identifier is “@1”.", param)
			end
		elseif itype == "error_ignore" then
			message = S("This block cannot be identified because the world has not materialized at this point yet. Try again in a few seconds.")
		elseif itype == "error_object" or itype == "error_unknown_thing" then
			message = S("No help entry for this object could be found.")
		elseif itype == "player" then
			message = S("This is a player.")
		end
		minetest.show_formspec(
			username,
			"doc_identifier:error_missing_item_info",
			"size[10,"..vsize..";]" ..
			"textarea[0.5,0.2;10,"..(vsize-0.2)..";;;"..minetest.formspec_escape(message).."]" ..
			"button_exit[3.75,"..(-0.5+vsize)..";3,1;okay;"..minetest.formspec_escape(S("OK")).."]"
		)
	end
	if pointed_thing.type == "node" then
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if minetest.registered_nodes[node.name] then
			--local nodedef = minetest.registered_nodes[node.name]
			if(node.name == "ignore") then
				show_message(username, "error_ignore")
			elseif doc.entry_exists("nodes", node.name) then
				doc.show_entry(username, "nodes", node.name, true)
			else
				show_message(username, "error_node")
			end
		else
			show_message(username, "error_unknown", node.name)
		end
	elseif pointed_thing.type == "object" then
		local object = pointed_thing.ref
		local le = object:get_luaentity()
		if object:is_player() then
			if mod_doc_basics and doc.entry_exists("basics", "players") then
				doc.show_entry(username, "basics", "players", true)
			else
				-- Fallback message
				show_message(username, "player")
			end
		-- luaentity exists
		elseif le then
			local ro = doc_identifier.registered_objects[le.name]
			-- Dropped items
			if le.name == "__builtin:item" then
				local itemstring = ItemStack(minetest.deserialize(le:get_staticdata()).itemstring):get_name()
				if doc.entry_exists("nodes", itemstring) then
					doc.show_entry(username, "nodes", itemstring, true)
				elseif doc.entry_exists("tools", itemstring) then
					doc.show_entry(username, "tools", itemstring, true)
				elseif doc.entry_exists("craftitems", itemstring) then
					doc.show_entry(username, "craftitems", itemstring, true)
				elseif minetest.registered_items[itemstring] == nil or itemstring == "unknown" then
					show_message(username, "error_unknown", itemstring)
				else
					show_message(username, "error_item")
				end
			-- Falling nodes
			elseif le.name == "__builtin:falling_node" then
				local itemstring = minetest.deserialize(le:get_staticdata()).name
				if doc.entry_exists("nodes", itemstring) then
					doc.show_entry(username, "nodes", itemstring, true)
				end
			-- A known registered object
			elseif ro and doc.entry_exists (ro.category, ro.entry) then
				doc.show_entry(username, ro.category, ro.entry, true)
			-- Undefined object (error)
			elseif minetest.registered_entities[le.name] == nil then
				show_message(username, "error_unknown", le.name)
			-- Other object (undocumented)
			else
				show_message(username, "error_object")
			end
		else
			--show_message(username, "error_object")
			show_message(username, "error_unknown")
		end
	elseif pointed_thing.type ~= "nothing" then
		show_message(username, "error_unknown_thing")
	end
	return itemstack
end

function doc_identifier.solid_mode(itemstack, user, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	if pointed_thing.type == "node" then
		local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if rc then return rc end
	end

	return ItemStack("doc_identifier:identifier_solid")
end

function doc_identifier.liquid_mode(itemstack, user, pointed_thing)
	-- Use pointed node's on_rightclick function first, if present
	if pointed_thing.type == "node" then
		local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if rc then return rc end
	end

	return ItemStack("doc_identifier:identifier_liquid")
end

minetest.register_tool("doc_identifier:identifier_solid", {
	description = S("Lookup Tool"),
	_tt_help = S("Show help for pointed thing"),
	_doc_items_longdesc = S("This useful little helper can be used to quickly learn more about about one's closer environment. It identifies and analyzes blocks, items and other things and it shows extensive information about the thing on which it is used."),
	_doc_items_usagehelp = S("Punch any block, item or other thing about you wish to learn more about. This will open up the appropriate help entry. The tool comes in two modes which are changed by using. In liquid mode, this tool points to liquids as well while in solid mode this is not the case."),
	_doc_items_hidden = false,
	tool_capabilities = {},
	range = 10,
	wield_image = "doc_identifier_identifier.png",
	inventory_image = "doc_identifier_identifier.png",
	liquids_pointable = false,
	on_use = doc_identifier.identify,
	on_place = doc_identifier.liquid_mode,
	on_secondary_use = doc_identifier.liquid_mode,
})
minetest.register_tool("doc_identifier:identifier_liquid", {
	description = S("Lookup Tool"),
	_doc_items_create_entry = false,
	tool_capabilities = {},
	range = 10,
	groups = { not_in_creative_inventory = 1, not_in_craft_guide = 1, disable_repair = 1 },
	wield_image = "doc_identifier_identifier_liquid.png",
	inventory_image = "doc_identifier_identifier_liquid.png",
	liquids_pointable = true,
	on_use = doc_identifier.identify,
	on_place = doc_identifier.solid_mode,
	on_secondary_use = doc_identifier.solid_mode,
})

minetest.register_craft({
	output = "doc_identifier:identifier_solid",
	recipe = { {"group:stick", "group:stick" },
		   {"", "group:stick"},
		   {"group:stick", ""} }
})

if minetest.get_modpath("mcl_core") then
	minetest.register_craft({
		output = "doc_identifier:identifier_solid",
		recipe = { { "mcl_core:glass" },
			   { "group:stick" } }
	})
end

minetest.register_alias("doc_identifier:identifier", "doc_identifier:identifier_solid")

doc.add_entry_alias("tools", "doc_identifier:identifier_solid", "tools", "doc_identifier:identifier_liquid")
