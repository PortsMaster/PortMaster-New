# tutorial
jump("tutorial_state_%s" % [get_variable("tutorial_state", 1)])
return()

# block:tutorial_state_1
textbox("Psst. Hey, you, up there. Can you see me?", "Snail")
textbox("Let me teach you how to be a good commander and win this battle!", "Snail")
textbox("Use the ARROW / WASD keys to move the cursor, and the Enter key to select.", "Snail")
set_variable("tutorial_state", 2)
return()

# block:tutorial_state_2
return()

# block:tutorial_state_3
# remove tutorial scripts from sprinkles
get_unit("sprinkles").remove_all_hook_scripts("on_select")
get_unit("sprinkles").remove_all_hook_scripts("on_hover")

textbox("Now attack those rascals and deal some damage!", "Snail")
set_variable("tutorial_state", 4)

gamescene.show_unit_action_menu("sprinkles")
hide_textbox()
return()

# block:tutorial_state_4
jump_if("tutorial_state_5", get_variable("unit_action_attacking").get_instance_id() != "sprinkles", true)

jump_if("tutorial_state_4_message", get_variable("unit_action_attacking").get_instance_id() == "sprinkles", true)
return()

# block:tutorial_state_4_message
textbox("Nice one!", "Snail")
textbox("Good luck!", "Snail")
set_variable("tutorial_state", 5)
return()

# block:tutorial_state_5
return()
