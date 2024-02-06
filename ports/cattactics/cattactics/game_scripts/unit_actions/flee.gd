# get walkable tiles for unit using action movement range
set_variable("random_path_target_size", get_variable("unit_action_action")['attributes']['movements'])
set_variable("unit_action_flee_walkable_tiles", get_walkable_tiles_for_unit(get_variable("unit_action_attacking").get_instance_id(), 0))

# create pathfinder instance
set_variable("unit_action_flee_pathfinder", get_pathfinder(get_variable("unit_action_flee_walkable_tiles", [])))

# textbox("Flee tiles: %s" % [get_variable("unit_action_flee_walkable_tiles", [])])
textbox("Time to retreat...", get_variable("unit_action_attacking").get_unit_name())
hide_textbox()

jump_if("choose_path", (get_variable("unit_action_flee_walkable_tiles", []).size() > 0), true)
jump_if("no_path", (get_variable("unit_action_flee_walkable_tiles", []).size() == 0), true)
return()

# block:choose_path
# loop until we chose a long path
# get_variable("unit_action_flee_walkable_tiles", []).shuffle()

# if we ran out of tiles, jump to no path
jump_if("end", get_variable("path_followed"), true)
jump_if("no_path", (get_variable("unit_action_flee_walkable_tiles", []).size() == 0), true)

# take out a random tile
set_variable("random_tile", get_variable("unit_action_flee_walkable_tiles", []).pop_front())

# calculate path to it
set_variable("random_path", gamescene.get_movement_names_from_path(get_variable("unit_action_flee_pathfinder").calculate_point_path(get_variable("unit_action_attacking").get_tile_position(), get_variable("random_tile"))))
set_variable("random_path_size", get_variable("random_path").size())

# choose another one if it's less than the desired movements
jump_if("end", get_variable("path_followed"), true)
# jump_if("choose_path", (get_variable("random_path_size") < get_variable("random_path_target_size")), true)
jump_if("choose_path", (get_variable("random_path_size") < 3), true)
jump_if("follow_path", (get_variable("random_path_size") >= 3), true)
jump_if("end", get_variable("path_followed"), true)
return()

# block:follow_path
jump_if("end", get_variable("path_followed"), true)
set_variable("path_followed", true)

# move the sprite following the found path
textbox("I can see an escape route!", get_variable("unit_action_attacking").get_unit_name())
hide_textbox()
move_sprite(get_variable("unit_action_attacking").get_instance_id(), get_variable("random_path"))
sprite_set_wait_movement(get_variable("unit_action_attacking").get_instance_id(), true)
textbox("%s escaped the area" % [get_variable("unit_action_attacking").get_unit_name()])
hide_textbox()
jump_if("end", get_variable("path_followed"), true)
return()

# block:no_path
textbox("Uh-oh, I'm trapped!", get_variable("unit_action_attacking").get_unit_name())
hide_textbox()
return()

# block:end
return()
