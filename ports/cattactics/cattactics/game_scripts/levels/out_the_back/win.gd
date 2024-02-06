# won the map!
play_bgm("sprinkles_theme")

gamescene.change_state(gamescene.MAP_FINISHED)
gamescene.hide_selected_unit_name() 

textbox("Sprinkles and the group managed to keep the other cats at bay...")
hide_textbox()

jump_if("recruited_mantequilla", (unit_recruited_and_present("mantequilla")), true)
jump_if("recruited_misty", (unit_recruited_and_present("misty")), true)
jump_if("recruited_nobody", (get_unit("mantequilla").get_unit_owner_type() != 0 and get_unit("misty").get_unit_owner_type() != 0), true)

change_level("main_street")
return()

# block:recruited_mantequilla
textbox_portrait_right("mantequilla", true)
textbox("I hear lot's of chatter about these so called Black Cats.", "Mante")
textbox("Perhaps coming along wasn't such a bad idea after all...", "Mante")
set_variable("recruited_mantequilla", true)

textbox_portrait_right()
return()


# block:recruited_misty
textbox_portrait_right("misty", true)
textbox("...", "Misty")
textbox("I've heard of the Black Cats, their territory is right at the end of the street.", "Misty")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Well then, let's be off.", "Sprinkles")
textbox_portrait_left()

set_variable("recruited_misty", true)
return()


# block:recruited_nobody
textbox_portrait_left("sprinkles", true)
textbox("Well, somehow we drove them off.", "Sprinkles")
textbox("It is rather a shame that Misty or Mantequilla won't be joining the fight.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("There's no time to waste, the Black Cat's territory must be over there.", "Spyro")
textbox_portrait_right()
return()
