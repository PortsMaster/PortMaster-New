# get sprinkles position and check if he's at the entrance to the alley
set_variable("sprinkles_position", get_unit("sprinkles").tile_position)
set_variable("spyro_position", get_unit("spyro").tile_position)

jump_if("reached_alley", (get_variable("sprinkles_position") == Vector2(0, 4)), true)
jump_if("reached_alley", (get_variable("sprinkles_position") == Vector2(0, 5)), true)
jump_if("reached_alley", (get_variable("sprinkles_position") == Vector2(0, 5)), true)
jump_if("reached_alley", (get_variable("spyro_position") == Vector2(0, 4)), true)
jump_if("reached_alley", (get_variable("spyro_position") == Vector2(0, 5)), true)
jump_if("reached_alley", (get_variable("spyro_position") == Vector2(0, 5)), true)
return()

# block:reached_alley
include("levels/main_street/win.gd")
return()
