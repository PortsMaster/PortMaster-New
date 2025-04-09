# only jump once
jump_if("out_the_back_3rd_turn", (get_variable("out_the_back_3rd_turn", false) == false), true)
return()

# block:out_the_back_3rd_turn
# gray cats start talking
gamescene.change_state(gamescene.SCRIPT)
gamescene.hide_selected_unit_name()

wait(0.5)

set_sprite_position("MAPCURSOR", 13, 0)

# block:out_the_back_5th_turn
# gray cats start talking
gamescene.change_state(gamescene.SCRIPT)
gamescene.hide_selected_unit_name()

spawn_sprite("Mantequilla", "mantequilla", 11, 0)
get_unit("mantequilla").set_unit_owner(80)
get_unit("mantequilla").set_unit_class("stray")
get_unit("mantequilla").set_unit_name("Mante")
get_unit("mantequilla").set_stat_delta("level", 3)
get_unit("mantequilla").set_unit_recruitable(true)
get_unit("mantequilla").set_unit_permanent(true)
get_unit("mantequilla").set_affinity_delta("sprinkles", 5)
get_unit("mantequilla").set_affinity_delta("spyro", 2)
get_unit("mantequilla").set_affinity_delta("misty", 2)
get_unit("mantequilla").set_movement_speed(0.1)
get_unit("mantequilla").set_unit_class("blind")
get_unit("mantequilla").add_hook_script("levels/out_the_back/mantequilla_on_recruit.gd", "on_recruit")
get_unit("mantequilla").add_hook_script("units/mantequilla/on_death.gd", "on_death")

play_bgm("out_the_back_mantequilla")
textbox_portrait_right("mantequilla", true)
textbox("Who's there!?", "Mante")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Mantequilla! You're here?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("mantequilla", true)
textbox("Psssss!!!", "Mante")
textbox("Who said that!??", "Mante")
textbox("How do you know my name?", "Mante")
textbox("Show yourself...", "Mante")
textbox_portrait_right()

wait(0.5)

textbox_portrait_left("sprinkles", true)
textbox("...", "Sprinkles")
textbox("It's no use, she can't see me.", "Sprinkles")
textbox("I don't blame her, after all she wasn't blessed with great eyesight.", "Sprinkles")
textbox("I'll have to Pet her to calm her down.", "Sprinkles")
textbox_portrait_left()

wait(0.5)
set_sprite_position("MAPCURSOR", get_unit("sprinkles").get_tile_position().x, get_unit("sprinkles").get_tile_position().y)

set_variable("out_the_back_3rd_turn", true)
play_bgm("out_the_back")
return()
