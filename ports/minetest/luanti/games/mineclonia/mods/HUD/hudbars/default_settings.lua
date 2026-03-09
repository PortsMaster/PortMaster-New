-- (Hardcoded) default settings

hb.settings.max_bar_length = 160
hb.settings.statbar_length = 20

-- Statbar positions
hb.settings.pos_left = {}
hb.settings.pos_right = {}
hb.settings.start_offset_left = {}
hb.settings.start_offset_right= {}
hb.settings.pos_left.x = hb.load_setting("hudbars_pos_left_x", "number", 0.5)
hb.settings.pos_left.y = hb.load_setting("hudbars_pos_left_y", "number", 1)
hb.settings.pos_right.x = hb.load_setting("hudbars_pos_right_x", "number", 0.5)
hb.settings.pos_right.y = hb.load_setting("hudbars_pos_right_y", "number", 1)
-- Modified in MCL2!
hb.settings.bar_type = hb.load_setting("hudbars_bar_type", "string", "statbar_modern", {"progress_bar", "statbar_classic", "statbar_modern"})
if hb.settings.bar_type == "progress_bar" then
	hb.settings.start_offset_left.x = hb.load_setting("hudbars_start_offset_left_x", "number", -175)
	hb.settings.start_offset_left.y = hb.load_setting("hudbars_start_offset_left_y", "number", -86)
	hb.settings.start_offset_right.x = hb.load_setting("hudbars_start_offset_right_x", "number", 15)
	hb.settings.start_offset_right.y = hb.load_setting("hudbars_start_offset_right_y", "number", -86)
else
	hb.settings.start_offset_left.x = hb.load_setting("hudbars_start_statbar_offset_left_x", "number", -258)
	hb.settings.start_offset_left.y = hb.load_setting("hudbars_start_statbar_offset_left_y", "number", -90)
	hb.settings.start_offset_right.x = hb.load_setting("hudbars_start_statbar_offset_right_x", "number", 16)
	hb.settings.start_offset_right.y = hb.load_setting("hudbars_start_statbar_offset_right_y", "number", -90)
end
-- Modified in MCL2!
hb.settings.vmargin  = hb.load_setting("hudbars_vmargin", "number", 28)
hb.settings.tick = hb.load_setting("hudbars_tick", "number", 0.1)

-- Experimental setting: Changing this setting is not officially supported, do NOT rely on it!
hb.settings.forceload_default_hudbars = hb.load_setting("hudbars_forceload_default_hudbars", "bool", true)

-- Misc. settings
hb.settings.alignment_pattern = hb.load_setting("hudbars_alignment_pattern", "string", "zigzag", {"zigzag", "stack_up", "stack_down"})
hb.settings.autohide_breath = hb.load_setting("hudbars_autohide_breath", "bool", true)

local sorting = core.settings:get("hudbars_sorting")
if sorting then
	hb.settings.sorting = {}
	hb.settings.sorting_reverse = {}
	for k,v in string.gmatch(sorting, "(%w+)=(%w+)") do
		hb.settings.sorting[k] = tonumber(v)
		hb.settings.sorting_reverse[tonumber(v)] = k
	end
else
	-- Modified in MCL2!
	hb.settings.sorting = { ["health"] = 0, ["hunger"] = 1, ["armor"] = 2, ["breath"] = 3, ["exhaustion"] = 4, ["saturation"] = 5 }
	hb.settings.sorting_reverse = {}
	for k,v in pairs(hb.settings.sorting) do
		hb.settings.sorting_reverse[tonumber(v)] = k
	end
end
