create_dynamic_menu("test1")
get_dynamic_menu("test1").add_item("Short item", "test1")
get_dynamic_menu("test1").add_item("Longer item", "test2")
show_dynamic_menu("test1")

textbox("selected: " + str(get_dynamic_menu_selected_text("test1")))
hide_textbox()
