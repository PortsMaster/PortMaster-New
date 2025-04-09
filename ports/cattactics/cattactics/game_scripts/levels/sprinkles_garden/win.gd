# won the map!
play_bgm("sprinkles_theme")

gamescene.change_state(gamescene.MAP_FINISHED)
gamescene.hide_selected_unit_name() 

textbox("Sprinkles and Spyro managed to scare off the intruders")
hide_textbox()

wait(0.5)

set_cursor_position(7, 4))

move_sprite("sprinkles", get_movement_path_to_point("sprinkles", Vector2(6, 4)))
move_sprite("spyro", get_movement_path_to_point("spyro", Vector2(8, 4)))
multi_sprite_set_wait_movement(["sprinkles", "spyro"])

gamescene.sprite_face_sprite("sprinkles", "spyro")
gamescene.sprite_face_sprite("spyro", "sprinkles")

wait(0.8)

textbox_portrait_left("sprinkles", true)
textbox("You came back just in time, Spyro.", "Sprinkles")
textbox("Thanks to you, they cleared off!", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("I would have returned sooner, but I was kidnapped!", "Spyro")
textbox("Look, they even put a colar on me...", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("What!? Who would dare do such a thing?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("That's the thing...", "Spyro")
textbox("I overheard talk of the Black Cats planning an invasion of multiple territories, including this area.", "Spyro")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Tch. Those Black Cats...", "Sprinkles")
textbox("They won't give it a rest until we show them not to mess with us. Come on, let's round everyone up and find their territory.", "Sprinkles")
textbox("We're gonna run them right out of the realm!", "Sprinkles")

textbox("You're coming, right?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("Count me in!", "Spyro")
textbox_portrait_right()

set_variable("recruit_unit_owner", 0)
set_variable("recruit_unit", get_unit("spyro"))
include("unit_actions/recruit.gd")

change_level("out_the_back")
