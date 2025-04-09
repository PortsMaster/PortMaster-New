# only jump once
jump_if("out_the_back_5th_turn", (get_variable("out_the_back_5th_turn", false) == false), true)
return()

wait(0.5)

set_sprite_position("MAPCURSOR", 0, 2)
wait(1.5)

# block:out_the_back_5th_turn
# gray cats start talking
gamescene.change_state(gamescene.SCRIPT)
gamescene.hide_selected_unit_name()

# spawn 2 more white cats
spawn_sprite("WhiteCat", "whitestray1", 0, 2)
get_unit("whitestray1").set_unit_owner(80)
get_unit("whitestray1").set_unit_class("stray")
get_unit("whitestray1").set_unit_name("W. Stray 1")
get_unit("whitestray1").set_stat_delta("level", 3)
get_unit("whitestray1").set_unit_recruitable(true)
get_unit("whitestray1").set_unit_permanent(true)
get_unit("whitestray1").set_movement_speed(0.1)
get_unit("whitestray1").add_hook_script("levels/out_the_back/generic_on_recruit.gd", "on_recruit")

spawn_sprite("WhiteCat", "whitestray2", 0, 3)
get_unit("whitestray2").set_unit_owner(80)
get_unit("whitestray2").set_unit_class("stray")
get_unit("whitestray2").set_unit_name("W. Stray 2")
get_unit("whitestray2").set_stat_delta("level", 4)
get_unit("whitestray2").set_unit_recruitable(true)
get_unit("whitestray2").set_unit_permanent(true)
get_unit("whitestray2").set_movement_speed(0.1)
get_unit("whitestray2").add_hook_script("levels/out_the_back/generic_on_recruit.gd", "on_recruit")

textbox_portrait_left("sprinkles", true)
textbox("The Strays have arrived to get in on the action...", "Sprinkles")
textbox_portrait_left()

set_sprite_position("MAPCURSOR", get_unit("sprinkles").get_tile_position().x, get_unit("sprinkles").get_tile_position().y)
wait(0.5)

set_variable("out_the_back_5th_turn", true)
return()
