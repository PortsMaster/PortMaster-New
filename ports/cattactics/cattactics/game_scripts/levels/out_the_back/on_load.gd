# starting map event
wait(1.2)

textbox("Sprinkles and Spyro begin their quest for the Black Cat's Territory.")
textbox("Level Start - Out the Back")
hide_textbox()

wait(0.3)

textbox_portrait_left("sprinkles", true)
textbox("I think they came from this way...", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("Hey... Isn't this..?", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("The great unconquered territory...", "Sprinkles")
textbox("Portals leading to multiple realms, each with it's own master.", "Sprinkles")
textbox("Quite a troublesome area to say the least.", "Sprinkles")
textbox_portrait_left()
hide_textbox()

wait(0.5)

textbox_portrait_left("sprinkles", true)
textbox("Looks like we already have company.", "Sprinkles")
textbox_portrait_left()
hide_textbox()

wait(0.5)

set_sprite_position("MAPCURSOR", 3, 0)
wait(1.5)

set_sprite_position("MAPCURSOR", 13, 0)
wait(1.5)

set_sprite_position("MAPCURSOR", 20, 0)
wait(1.5)

set_sprite_position("MAPCURSOR", 22, 7)
wait(1.5)


textbox_portrait_left("sprinkles", true)
textbox("Ah, she's here....", "Sprinkles")
textbox("Our mother, Misty.", "Sprinkles")
textbox("She will be the most troublesome of all to win over to our cause.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("It would be beneficial to form a temporary alliance against the Black Cats.", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Maybe if we try to be friendly by Petting her and the others, we could get them on our side.", "Sprinkles")
textbox("Regardless, as she blocks our path we are forced to contront her.", "Sprinkles")
textbox("I will let fate decide the outcome of whether or not she joins forces with us...", "Sprinkles")
textbox_portrait_left()
hide_textbox()

wait(1)

textbox_portrait_right("spyro", true)
textbox("If there's already this many enemies, more will be on the way the moment they get word of our attack.", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("We must make haste to the end of the alley, before we're swarmed by the enemy.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("misty", true)
textbox("...", "Misty")
textbox_portrait_right()
hide_textbox()

set_sprite_position("MAPCURSOR", 0, 7)

wait(0.5)

include("levels/out_the_back/tutorial.gd")
return()
