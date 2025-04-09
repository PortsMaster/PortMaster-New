# only jump once
jump_if("sprinkles_garden_2nd_turn", (get_variable("sprinkles_garden_2nd_turn", false) == false), true)
return()

# block:sprinkles_garden_2nd_turn
# gray cats start talking
gamescene.change_state(gamescene.SCRIPT)
gamescene.hide_selected_unit_name()

textbox_portrait_right("graycat1", true)
textbox("You're no match for us even with the 2 of you!", "Gray Cat")
textbox_portrait_right()
hide_textbox()
set_variable("sprinkles_garden_2nd_turn", true)
return()
