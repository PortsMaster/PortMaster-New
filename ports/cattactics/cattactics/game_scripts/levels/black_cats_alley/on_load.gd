# starting map event
set_sprite_position("MAPCURSOR", 27, 9)
wait(1.2)
# 
textbox("Sprinkle's group reaches the Black Cat's Alley for their final showdown.")
textbox("Level Start - Black Cat's Alley")
hide_textbox()

wait(0.3)
# 
textbox_portrait_left("sprinkles", true)
textbox("Enemy sighting confirmed on the rooftops!", "Sprinkles")
textbox_portrait_left()
hide_textbox()

wait(0.5)

set_sprite_position("MAPCURSOR", 0, 0)
wait(1.0)

textbox_portrait_right("spyro", true)
textbox("They are so high up!", "Spyro")
textbox("What method will we use to reach them? I doubt they will be the ones to come to us...", "Spyro")
textbox_portrait_right()
hide_textbox()

set_sprite_position("MAPCURSOR", 27, 9)

wait(0.5)

textbox_portrait_left("sprinkles", true)
textbox("We'll take the route up the window ledges, and continue via jumping between roofs towards the final house.", "Sprinkles")
textbox_portrait_left()


textbox_portrait_right("spyro", true)
textbox("Considering how overrun this place is with underlings we need to get moving now!", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("We came this far, it's no time to flee with our tails low. We stepped paw into enemy territory to settle this once and for all.", "Sprinkles")
textbox("I swear on my fur that we'll return peace to our realm.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("I'm glad to be by your side, Sprinkles!", "Spyro")
textbox_portrait_right()

jump_if("recruited_mantequilla", (unit_recruited_and_present("mantequilla")), true)
jump_if("recruited_misty", (unit_recruited_and_present("misty")), true)
jump_if("recruited_lilu", (unit_recruited_and_present("lilu")), true)
jump_if("recruited_sabu", (unit_recruited_and_present("sabu")), true)
hide_textbox()
return()

# block:recruited_mantequilla
set_variable("recruited_mantequilla", true)
textbox_portrait_right("mantequilla", true)
textbox("I can't wait to get onto those roof tops!", "Mantequilla")
textbox_portrait_right()
return()


# block:recruited_misty
set_variable("recruited_misty", true)
textbox_portrait_right("misty", true)
textbox("I do have some confidence in our ability to win this one.", "Misty")
textbox_portrait_right()
return()

# block:recruited_lilu
set_variable("recruited_lilu", true)
textbox_portrait_right("lilu", true)
textbox("My leaping attack will send them packing.", "Lilu")
textbox_portrait_right()
return()


# block:recruited_sabu
set_variable("recruited_sabu", true)
textbox_portrait_right("sabu", true)
textbox("I'll be hiding somewhere in the shadows if you need me!", "Sabu")
textbox_portrait_right()
return()
