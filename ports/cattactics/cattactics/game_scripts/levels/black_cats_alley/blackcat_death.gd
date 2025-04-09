# jump based on the number of killed cats
play_bgm("black_cats_alley_boss")

jump("blackcats_death_state_%s" % [get_variable("blackcats_death_state", 1)])
return()

# block:blackcats_death_state_1
set_variable("blackcats_death_state", 2)

textbox_portrait_right(get_variable("unit_action_attacked").get_instance_id(), true)
textbox("Aaaaaruuugh! Psssss!", get_variable("unit_action_attacked").get_unit_name())
textbox("You..! You won't get away with this!", get_variable("unit_action_attacked").get_unit_name())
textbox_portrait_right()
hide_textbox()
return()

# block:blackcats_death_state_2
set_variable("blackcats_death_state", 3)

textbox_portrait_right(get_variable("unit_action_attacked").get_instance_id(), true)
textbox("How??", get_variable("unit_action_attacked").get_unit_name())
textbox("I am part of the Black Cats, you don't just.. a-attack us.. Ah!", get_variable("unit_action_attacked").get_unit_name())
textbox_portrait_right()
hide_textbox()
return()

# block:blackcats_death_state_3
set_variable("blackcats_death_state", 4)

textbox_portrait_right(get_variable("unit_action_attacked").get_instance_id(), true)
textbox("I must admit you put up a good fight...", get_variable("unit_action_attacked").get_unit_name())
textbox("We admit defeat...", get_variable("unit_action_attacked").get_unit_name())
textbox("Keep your blasted territories!", get_variable("unit_action_attacked").get_unit_name())
textbox_portrait_right()
hide_textbox()

jump("blackcats_death_state_4")
return()

# block:blackcats_death_state_4
# game finished!
game_complete()
return()
