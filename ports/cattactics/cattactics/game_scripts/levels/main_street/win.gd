# won the map!
play_bgm("sprinkles_theme")

gamescene.change_state(gamescene.MAP_FINISHED)
gamescene.hide_selected_unit_name() 

# move to the alley
set_sprite_position("MAPCURSOR", 0, 5)

move_sprite("sprinkles", get_movement_path_to_point("sprinkles", Vector2(0, 5)))
move_sprite("spyro", get_movement_path_to_point("spyro", Vector2(0, 6)))

multi_sprite_set_wait_movement(["sprinkles", "spyro"])

# move the others if we can
jump_if("recruited_mantequilla", (unit_recruited_and_present("mantequilla")), true)
jump_if("recruited_misty", (unit_recruited_and_present("misty")), true)
jump_if("recruited_lilu", (unit_recruited_and_present("lilu")), true)
jump_if("recruited_sabu", (unit_recruited_and_present("sabu")), true)

# dialog applies to all
textbox_portrait_left("sprinkles", true)
textbox("This is it, the entrance to Black Cat Alley.", "Sprinkles")
textbox("It's finally time to put an end to their tyranny.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("Let's go!", "Spyro")
textbox_portrait_right()
hide_textbox()

# recruited messages
jump_if("recruited_lilu_dialog", (get_variable("recruited_lilu")), true)
jump_if("recruited_sabu_dialog", (get_variable("recruited_sabu")), true)
jump_if("recruited_mantequilla_dialog", (get_variable("recruited_mantequilla")), true)
jump_if("recruited_misty_dialog", (get_variable("recruited_misty")), true)


jump_if("recruited_nobody", (get_variable("recruited_sabu") == false and get_variable("recruited_lilu")), true)

change_level("black_cats_alley")
return()

# block:recruited_mantequilla
set_variable("recruited_mantequilla", true)
move_sprite("mantequilla", get_movement_path_to_point("misty", Vector2(1, 5)))
return()


# block:recruited_misty
set_variable("recruited_misty", true)
move_sprite("misty", get_movement_path_to_point("misty", Vector2(0, 4)))
return()

# block:recruited_lilu
set_variable("recruited_lilu", true)
move_sprite("lilu", get_movement_path_to_point("lilu", Vector2(1, 4)))
return()


# block:recruited_sabu
set_variable("recruited_sabu", true)
move_sprite("sabu", get_movement_path_to_point("sabu", Vector2(1, 6)))
return()


# block:recruited_nobody
textbox_portrait_left("sprinkles", true)
textbox("It's a shame that Sabu and Lilu won't be joining the fight.", "Sprinkles")
textbox_portrait_left()
hide_textbox()
return()

# block:recruited_mantequilla_dialog
textbox_portrait_right("mantequilla", true)
textbox("Finally things are beginning to get interesting...", "Mantequilla")
textbox_portrait_right()
hide_textbox()
return()

# block:recruited_misty_dialog
textbox_portrait_right("misty", true)
textbox("... Let's make this quick.", "Misty")
textbox_portrait_right()
hide_textbox()
return()

# block:recruited_lilu_dialog
textbox_portrait_right("lilu", true)
textbox("They have no idea who they are messing with.", "Lilu")
textbox_portrait_right()
hide_textbox()
return()

# block:recruited_sabu_dialog
textbox_portrait_right("sabu", true)
textbox("This is scary!", "Sabu")
textbox_portrait_right()
hide_textbox()
return()
