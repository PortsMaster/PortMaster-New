# init script for TestLevel
# gamescene.add_map_condition("all_enemy_units_dead", "win", {"type": "enemy_count", "equals": 0}, "levels/testlevel_win.gd")
# gamescene.add_map_condition("player_units_dead", "lose", {"type": "player_count", "equals": 0}, "levels/testlevel_lose.gd")
# gamescene.add_map_condition("ally_units_dead", "lose", {"type": "ally_count", "equals": 0}, "levels/testlevel_lose.gd")
# gamescene.add_map_condition("sabu_dead", "lose", {"type": "unit_alive_state", "unit_id": "sabu", "equals": false}, "levels/testlevel_lose.gd")
# gamescene.add_map_condition("max_turns_reached", "win", {"type": "turn", "equals": 2})

# test sprite script interaction
spawn_sprite("TestSprite", "testsprite1", 1, 1)
sprite("testsprite1").add_hook_script("animation-test.gd", "on_select")
sprite("testsprite1").set_cursor_highlight_color("white")
spawn_sprite("TestSprite", "testsprite2", 1, 0)
sprite("testsprite2").add_hook_script("portrait-test.gd", "on_select")
sprite("testsprite2").set_cursor_highlight_color("white")



# textbox("This is an init script, and the screen should be black right now")
# spawn_sprite("TestUnit", "sprinkles", 3, 2)
# get_unit("sprinkles").set_unit_owner(0)
# get_unit("sprinkles").set_unit_movement_range(5)
# get_unit("sprinkles").set_unit_permanent(true)
# get_unit("sprinkles").set_unit_attack_range(1)
# get_unit("sprinkles").set_unit_class("king")
# get_unit("sprinkles").set_unit_name("Sprinkles")
# # get_unit("sprinkles").set_stat_delta("level", 10)
# get_unit("sprinkles").add_hook_script("dead.gd", "on_death")

# spawn_sprite("TestUnit", "mantequilla", 1, 3)
# get_unit("mantequilla").set_unit_owner(0)
# get_unit("mantequilla").set_unit_movement_range(5)
# get_unit("mantequilla").set_unit_permanent(true)
# get_unit("mantequilla").set_unit_attack_range(2)
# get_unit("mantequilla").set_unit_class("blind")
# get_unit("mantequilla").set_unit_name("Mantequilla")
# get_unit("mantequilla").add_hook_script("dead.gd", "on_death")
# # get_unit("mantequilla").set_stat_delta("level", 1)
#
# spawn_sprite("TestUnit", "lilu", 2, 3)
# get_unit("lilu").set_unit_owner(0)
# get_unit("lilu").set_unit_movement_range(5)
# get_unit("lilu").set_unit_permanent(true)
# get_unit("lilu").set_unit_attack_range(2)
# get_unit("lilu").set_unit_class("stray")
# get_unit("lilu").set_unit_name("Lilu")
# get_unit("lilu").add_hook_script("dead.gd", "on_death")
#
# get_unit("mantequilla").set_affinity_delta("lilu", 3)
# get_unit("lilu").set_affinity_delta("mantequilla", 3)
#
# spawn_sprite("TestUnit", "misty", 5, 2)
# get_unit("misty").set_unit_owner(10)
# get_unit("misty").set_unit_movement_range(3)
# get_unit("misty").set_unit_attack_range(1)
# get_unit("misty").set_unit_class("test")
# get_unit("misty").set_unit_name("Misty")
# get_unit("misty").add_hook_script("dead.gd", "on_death")
# get_unit("misty").add_hook_script("recruited.gd", "on_recruit")
#
# spawn_sprite("TestUnit", "sabu", 3, 6)
# get_unit("sabu").set_unit_owner(80)
# get_unit("sabu").set_unit_movement_range(2)
# get_unit("sabu").set_unit_attack_range(1)
# get_unit("sabu").set_unit_class("beauty")
# get_unit("sabu").set_unit_name("Sabu")
# # get_unit("sabu").add_hook_script("textbox-test3.gd", "on_attacked_first_time")
# # get_unit("sabu").add_hook_script("textbox-test.gd", "on_low_hp")
# get_unit("sabu").add_hook_script("dead.gd", "on_death")
#
# spawn_sprite("TestUnit", "spyro", 8, 5)
# get_unit("spyro").set_unit_owner(90)
# get_unit("spyro").set_unit_movement_range(3)
# get_unit("spyro").set_unit_attack_range(1)
# get_unit("spyro").set_unit_class("warrior")
# get_unit("spyro").set_unit_name("Spyro")
# get_unit("spyro").add_hook_script("dead.gd", "on_death")

return()

# set_variable("testvar", "sprite pos: " + str(sprite("testsprite1").tile_position))
# textbox(get_variable("testvar"))
#
# # block:test_block
# textbox("cursor pos: " + str(sprite("MAPCURSOR").tile_position))
# # return()
#
# include("include-test.gd") if current_script_line == 13
#
# textbox ("back to the original script")
#
# # test jumping to specific block
# textbox("before jump")
jump("test_block2") 
return()
#
#
#
# block:test_block2
textbox("should never show unless jumped to")
return()
