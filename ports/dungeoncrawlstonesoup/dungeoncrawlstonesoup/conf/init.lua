pickup_menu_limit=1
easy_unequip=true
equip_unequip=true
jawellery_prompt=true
prompt_menu=true
ability_menu=true
spell_menu=true
menu_arrow_control=true

tile_update_rate = 1000
tile_runrest_rate = 1000
# tile_window_width  = 720
# tile_window_height = 720
# game_scale = 1
# tile_viewport_scale = 1
tile_use_small_layout = true
tile_sidebar_pixels = 1
tile_font_crt_size  = 13
tile_font_stat_size = 15
tile_font_msg_size  = 15
tile_font_tip_size  = 14
tile_font_lbl_size  = 14
tile_water_anim = false
tile_misc_anim = false
tile_display_mode = tiles


<
RIGHT = -251
LEFT = -252
DOWN = -253
UP = -254
ENTER = 13
ESC = 27
F2 = -266
F3 = -267
CHUNK_SIZE = 3
MENU_COLOR = "lightcyan"
SELECTED_MENU_COLOR = "red"


function make_menu_item(name, func)
	return { ["name"] = name, ["func"] = func }
end
function make_command_menu_item(name, command)
	return make_menu_item(name, function() crawl.do_commands({command}) end)
end
function make_search_menu_item(search_key)
	return make_menu_item(search_key, function() crawl.sendkeys(6, search_key, 13) end)
end


function print_menu(items, chunk_size, selected_idx, item_fmt)
	local menu_line = ""

	for i=1,#items do
		local color = selected_idx == i and SELECTED_MENU_COLOR or  MENU_COLOR
		menu_line = menu_line .. string.format(item_fmt, color, items[i].name, color)

		if i % chunk_size == 0 then
			menu_line = menu_line .. "\n"
		end
	end

	crawl.clear_messages(true)
	crawl.formatted_mpr(menu_line, "prompt")
end


function get_max_menu_item_len(items)
	local max_item_len = -1

	for key,item in pairs(items) do
		local item_len = string.len(item.name)

		if item_len > max_item_len then
			max_item_len = item_len
		end
	end

	return max_item_len
end


function make_menu(items)
	local selected_idx = 1
	local max_item_len = get_max_menu_item_len(items)
	local item_fmt = "<%s>[ %-" .. max_item_len .. "s ]<%s>  "

	while true do
		print_menu(items, CHUNK_SIZE, selected_idx, item_fmt)
		local pressed_key = crawl.getch()

		if pressed_key == UP then
			selected_idx = math.max(1, selected_idx - CHUNK_SIZE)
		elseif pressed_key == DOWN then
			selected_idx = math.min(#items, selected_idx + CHUNK_SIZE)
		elseif pressed_key == LEFT then
			selected_idx = math.max(1, selected_idx - 1)
		elseif pressed_key == RIGHT then
			selected_idx = math.min(#items, selected_idx + 1)
		elseif pressed_key == ENTER or pressed_key == F2 or pressed_key == F3 then
			local selected_item = items[selected_idx]
			crawl.clear_messages(true)

			if selected_item == nil then 
				return 
			end

			selected_item.func()
			return
		elseif pressed_key == ESC then
			crawl.clear_messages(true)
			return
		else
			crawl.formatted_mpr(pressed_key)
		end
	end
end


ACTIONS = {
	make_command_menu_item("rest", "CMD_REST"),
	make_command_menu_item("read", "CMD_READ"),
	make_command_menu_item("quaff", "CMD_QUAFF"),
	make_command_menu_item("look", "CMD_LOOK_AROUND"),
	make_command_menu_item("drop", "CMD_DROP"),
	make_command_menu_item("equip", "CMD_EQUIP"),
	make_command_menu_item("unequip", "CMD_UNEQUIP"),
	make_command_menu_item("quiver", "CMD_QUIVER_ITEM"),
	make_command_menu_item("evoke", "CMD_EVOKE"),
	make_command_menu_item("use ability", "CMD_USE_ABILITY"),
	make_command_menu_item("cast spell", "CMD_CAST_SPELL"),
	make_command_menu_item("memorise spell", "CMD_MEMORISE_SPELL"),
	make_command_menu_item("open door", "CMD_OPEN_DOOR"),
	make_command_menu_item("close door", "CMD_CLOSE_DOOR"),
}
SEARCH = {
	make_search_menu_item(".."),
	make_search_menu_item("armor"),
	make_search_menu_item("weapon"),
	make_search_menu_item("ego"),
	make_search_menu_item("artifact"),
	make_search_menu_item("scroll"),
	make_search_menu_item("book"),
	make_search_menu_item("potion"),
	make_search_menu_item("jewellery"),
	make_search_menu_item("rCorr"),
	make_search_menu_item("rFire"),
	make_search_menu_item("rCold"),
	make_search_menu_item("rNeg"),
	make_search_menu_item("rPois"),
	make_search_menu_item("rElec"),
	make_search_menu_item("Will"),
}
INFOS = {
	make_command_menu_item("inventory", "CMD_DISPLAY_INVENTORY"),
	make_command_menu_item("player", "CMD_RESISTS_SCREEN"),
	make_command_menu_item("religion", "CMD_DISPLAY_RELIGION"),
	make_command_menu_item("mutations", "CMD_DISPLAY_MUTATIONS"),
	make_command_menu_item("messages", "CMD_REPLAY_MESSAGES"),
	make_command_menu_item("skills", "CMD_DISPLAY_SKILLS"),
	make_command_menu_item("spells", "CMD_DISPLAY_SPELLS"),
	make_command_menu_item("dungeon", "CMD_DISPLAY_OVERMAP"),
	make_command_menu_item("map", "CMD_DISPLAY_MAP"),
	make_command_menu_item("runes", "CMD_DISPLAY_RUNES"),
	make_menu_item("> search", function() make_menu(SEARCH) end),
}

function action_menu() make_menu(ACTIONS) end
function infos_menu() make_menu(INFOS) end

function print_key()
	local pressed_key = crawl.getch()
	crawl.formatted_mpr("pressed key: " .. pressed_key, "prompt")
end
>


macros += M \{F2} ===action_menu
macros += M \{F3} ===infos_menu
macros += M \{F4} ===print_key

macros += K4 \{Left} .
macros += K4 \{Right} .
macros += K4 \{F2} \{n}
macros += K4 \{F3} \{y}

macros += K1 \{F2} e
macros += K1 \{F3} v
macros += K2 \{F2} e
macros += K2 \{F3} v
macros += K1 f {
macros += K1 o }
