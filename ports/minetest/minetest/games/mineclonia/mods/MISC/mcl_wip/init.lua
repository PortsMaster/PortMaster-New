-- Allow items or nodes to be marked as WIP (Work In Progress) or Experimental

local S = minetest.get_translator(minetest.get_current_modname())

mcl_wip = {}
mcl_wip.registered_wip_items = {}
mcl_wip.registered_experimental_items = {}

function mcl_wip.register_wip_item(itemname)
	table.insert(mcl_wip.registered_wip_items, itemname) --Only check for valid node name after mods loaded
end

function mcl_wip.register_experimental_item(itemname)
	table.insert(mcl_wip.registered_experimental_items, itemname)
end

minetest.register_on_mods_loaded(function()
	for _,name in pairs(mcl_wip.registered_wip_items) do
		local def = minetest.registered_items[name]
		if not def then
			minetest.log("error", "[mcl_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..minetest.colorize(mcl_colors.RED, S("(WIP)"))
		minetest.override_item(name, {description = new_description})
	end

	for _,name in pairs(mcl_wip.registered_experimental_items) do
		local def = minetest.registered_items[name]
		if not def then
			minetest.log("error", "[mcl_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..minetest.colorize(mcl_colors.YELLOW, S("(Temporary)"))
		minetest.override_item(name, {description = new_description})
	end
end)
