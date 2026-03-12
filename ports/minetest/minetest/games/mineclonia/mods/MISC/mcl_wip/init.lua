-- Allow items or nodes to be marked as WIP (Work In Progress) or Experimental

local S = core.get_translator(core.get_current_modname())

mcl_wip = {}
mcl_wip.registered_wip_items = {}
mcl_wip.registered_experimental_items = {}

function mcl_wip.register_wip_item(itemname)
	table.insert(mcl_wip.registered_wip_items, itemname) --Only check for valid node name after mods loaded
end

function mcl_wip.register_experimental_item(itemname)
	table.insert(mcl_wip.registered_experimental_items, itemname)
end

core.register_on_mods_loaded(function()
	for _,name in pairs(mcl_wip.registered_wip_items) do
		local def = core.registered_items[name]
		if not def then
			core.log("error", "[mcl_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..core.colorize(mcl_colors.RED, S("(WIP)"))
		core.override_item(name, {description = new_description})
	end

	for _,name in pairs(mcl_wip.registered_experimental_items) do
		local def = core.registered_items[name]
		if not def then
			core.log("error", "[mcl_wip] Unknown item: "..name)
			break
		end
		local new_description = def.description
		if new_description == "" then
			new_description = name
		end
		new_description = new_description .. "\n"..core.colorize(mcl_colors.YELLOW, S("(Temporary)"))
		core.override_item(name, {description = new_description})
	end
end)
