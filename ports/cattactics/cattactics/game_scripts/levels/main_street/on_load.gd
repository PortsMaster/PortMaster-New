# starting map event
set_sprite_position("MAPCURSOR", 0, 20)
wait(1.2)
#
textbox("Sprinkles and Spyro reach the Main Street, venturing ever closer to the Black Cat's Territory.")
textbox("Level Start - Main Street")
hide_textbox()

wait(0.3)
#
textbox_portrait_left("sprinkles", true)
textbox("...", "Sprinkles")
textbox("It's awfully quiet around here, isn't it?", "Sprinkles")
textbox_portrait_left()
#
textbox_portrait_right("spyro", true)
textbox("I wouldn't be so sure. Look over there!", "Spyro")
textbox_portrait_right()
hide_textbox()

wait(0.5)

set_sprite_position("MAPCURSOR", 9, 4)
wait(1.0)

textbox_portrait_left("sprinkles", true)
textbox("!", "Sprinkles")
textbox("Lilu and Sabu are in trouble, quickly, we must rush to their aid.", "Sprinkles")
textbox_portrait_left()
hide_textbox()

animate_sprite("streetstray2", "attack_left")

animate_sprite("streetstray1", "attack_up")
wait(0.3)
animate_sprite("streetstray2", "attack_left")
wait(0.3)
animate_sprite("streetstray3", "attack_down")

wait(0.5)


set_sprite_position("MAPCURSOR", 0, 20)

textbox_portrait_right("streetcat1", true)
textbox("Now hold on a minute...", "Street Cat")
textbox_portrait_right()
hide_textbox()

wait(0.5)

# bring the gray cats in
move_sprite("streetcat1", get_movement_path_to_unit("streetcat1", "sprinkles", Vector2(3, -2)))
move_sprite("streetcat2", get_movement_path_to_unit("streetcat2", "sprinkles", Vector2(3, -1)))
move_sprite("streetcat3", get_movement_path_to_unit("streetcat3", "sprinkles", Vector2(2, -1)))
move_sprite("streetcat4", get_movement_path_to_unit("streetcat4", "sprinkles", Vector2(1, 0)))
multi_sprite_set_wait_movement(["streetcat1", "streetcat2", "streetcat3", "streetcat4"])
animate_sprite("streetcat1", "face_left")
animate_sprite("streetcat2", "face_left")
animate_sprite("streetcat3", "face_left")
animate_sprite("streetcat4", "face_left")

wait(0.5)

play_bgm("main_street_encounter")

textbox_portrait_right("streetcat1", true)
textbox("Where do you think you're going?", "Street Cat")
textbox("Traitors must be dealt with on-sight!", "Street Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Traitor..?", "Sprinkles")
textbox("Who is the traitor here?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("streetcat1", true)
textbox("That's rich, coming from the one who's behind all the recent invasions!", "Street Cat")
textbox("Let's get him, boys!", "Street Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("You are sorely mistaken!", "Sprinkles")
textbox("Mark my words... this action won't go unpunished.", "Sprinkles")
textbox_portrait_left()
