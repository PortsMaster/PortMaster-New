# block:menutest
textbox_auto_close(false)
textbox("select a menu test")

create_dynamic_menu("menutest")
get_dynamic_menu("menutest").add_item("Auto-resize", "menu-test-autosize.gd")
get_dynamic_menu("menutest").add_item("Manual position", "menu-test-manual-position.gd")
get_dynamic_menu("menutest").add_item("Center position", "menu-test-center-position.gd")
get_dynamic_menu("menutest").add_item("Yes/no", "menu-test-yesno.gd")
get_dynamic_menu("menutest").add_item("Custom Yes/no", "menu-test-yesno-custom.gd")
get_dynamic_menu("menutest").add_item("Scrolling", "menu-test-scrolling.gd")
get_dynamic_menu("menutest").add_item("Multiple menus", "menu-test-multiple.gd")
get_dynamic_menu("menutest").set_selection_required(false)
show_dynamic_menu("menutest")

jump_if("menutest_selected", dynamic_menu_cancelled("menutest"), false)
hide_textbox()
return()

# block:menutest_selected
include(get_dynamic_menu_selected_id("menutest"))
jump("menutest")
return()
