create_dynamic_menu("test2")
get_dynamic_menu("test2").add_item("Item 1", "test1")
get_dynamic_menu("test2").add_item("Item 2", "test2")
get_dynamic_menu("test2").set_position(5, 25)
show_dynamic_menu("test2")

textbox("selected: " + str(get_dynamic_menu_selected_text("test2")))
hide_textbox()
