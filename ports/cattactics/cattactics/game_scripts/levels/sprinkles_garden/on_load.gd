# starting map event
wait(1.2)

textbox("Sprinkles was enjoying his day in the garden, when suddenly he was attacked!")
textbox("And so begins his epic tale...")
textbox("Level Start - Garden Invasion")
hide_textbox()

wait(0.3)

stop_bgm()

# bring the gray cats in
move_sprite("graycat1", get_movement_path_to_unit("graycat1", "sprinkles", Vector2(-1, -2)))
move_sprite("graycat2", get_movement_path_to_unit("graycat2", "sprinkles", Vector2(0, -2)))
move_sprite("graycat3", get_movement_path_to_unit("graycat3", "sprinkles", Vector2(1, -2)))
multi_sprite_set_wait_movement(["graycat1", "graycat2", "graycat3"])

play_bgm("sprinkles_garden_attacked")

wait(0.5)


# face them
sprite("sprinkles").set_sprite_facing("up")
wait(1)

textbox_portrait_left("sprinkles", true)
textbox("Huh?", "Sprinkles")
textbox("You dare set paw in my domain!?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("graycat1", true)
textbox("Psss..!", "Gray Cat")
textbox("We bring a message from the Black Cats.", "Gray Cat")
textbox("This territory will be ours!", "Gray Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("En garde!", "Sprinkles")
textbox_portrait_left()
textbox_portrait_right()
hide_textbox()

wait(0.8)
stop_bgm()
textbox("...!", "Sprinkles")


wait(0.2)

# bring Spyro into the mix
set_sprite_position("spyro", 6, 0)
move_sprite("spyro", get_movement_path_to_unit("spyro", "sprinkles", Vector2(-1, -3)), true)

wait(0.2)

play_bgm("sprinkles_garden_spyro")

# spyro joins the party
textbox_portrait_left("sprinkles", true)
textbox("S-Spyro?? But... they said you'd run away!", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("Let's save the reunion for later!", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Aye, let's teach these ruffians not to mess with family!", "Sprinkles")
textbox_portrait_left()

hide_textbox()

include("levels/sprinkles_garden/tutorial.gd")
return()
