set_variable("multiple-menu-id", 0)
jump("spawn_menu")
return()

# block:spawn_menu
textbox("quit?")
create_dynamic_menu(get_variable("multiple-menu-id"))
get_dynamic_menu(get_variable("multiple-menu-id")).add_item("Yes", "yes")
get_dynamic_menu(get_variable("multiple-menu-id")).add_item("No", "no", true, false)
get_dynamic_menu(get_variable("multiple-menu-id")).set_random_position()
get_dynamic_menu(get_variable("multiple-menu-id")).set_hide_on_close(false)

# track if it's not the first menu, and if it's not, set the selection not required so we can cancel them
jump("show_menu")
return()

# block:show_menu
set_variable("multiple-menu-id-over-0", (int(get_variable("multiple-menu-id")) > 0))
jump_if("not_first_menu", get_variable("multiple-menu-id-over-0"), true)

show_dynamic_menu(get_variable("multiple-menu-id"))

jump_if("cancelled", dynamic_menu_cancelled(get_variable("multiple-menu-id")), true)
jump_if("selected", get_dynamic_menu_selected_id(get_variable("multiple-menu-id")), "no")
jump("hide_current_menu")

set_variable("multiple-menu-id-over-0", (int(get_variable("multiple-menu-id")) > 0))
jump_if("cancelled", get_variable("multiple-menu-id-over-0"), true)
return()

# block:selected
textbox("selected: " + str(get_dynamic_menu_selected_text(get_variable("multiple-menu-id"))))
textbox("current menu id: " + str(get_variable("multiple-menu-id")))
hide_textbox()

set_variable("multiple-menu-id", get_variable("multiple-menu-id") + 1)
jump("spawn_menu")
return()

# block:not_first_menu
get_dynamic_menu(get_variable("multiple-menu-id")).set_selection_required(false)
get_dynamic_menu(get_variable("multiple-menu-id")).set_hide_on_close(false)
return()

# block:cancelled
set_variable("multiple-menu-id-previous", get_variable("multiple-menu-id") - 1)
textbox("previous open menu id: " + str(get_variable("multiple-menu-id-previous")))
hide_textbox()

print(self.gamescene.dynamic_menus)
jump("hide_current_menu")
get_dynamic_menu(get_variable("multiple-menu-id-previous")).change_state(0)

# set the active ID to the previous one
set_variable("multiple-menu-id", get_variable("multiple-menu-id-previous"))
set_script_run_state(1)

jump_if("cancelled", dynamic_menu_cancelled(get_variable("multiple-menu-id")), true)
return()

# block:hide_current_menu
get_dynamic_menu(get_variable("multiple-menu-id")).hide()
