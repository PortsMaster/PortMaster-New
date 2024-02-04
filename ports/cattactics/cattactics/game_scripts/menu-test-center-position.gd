create_dynamic_menu("test2")
get_dynamic_menu("test2").add_item("Item A", "test1")
get_dynamic_menu("test2").add_item("Item B", "test2")
get_dynamic_menu("test2").add_item("Item C", "test3")
get_dynamic_menu("test2").add_item("Item D", "test4")
get_dynamic_menu("test2").set_position_layout("center")
show_dynamic_menu("test2")

textbox_auto_close(true)

textbox("selected: " + str(get_dynamic_menu_selected_text("test2")))
hide_textbox()
