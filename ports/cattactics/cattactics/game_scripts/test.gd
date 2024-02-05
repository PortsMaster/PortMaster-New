# wait(1)

# sprite("MAPCURSOR").set_colour("red")

# test sprite script interaction
spawn_sprite("TestSprite", "testsprite1", 1, 2)
# sprite("testsprite1").add_hook_script("textbox-test.gd", "on_select")
# sprite("testsprite1").add_hook_script("textbox-test2.gd", "on_hover")
sprite("testsprite1").add_hook_script("dead.gd", "on_select")
sprite("testsprite1").set_cursor_highlight_color("blue")



# textbox("This is an init script, and the screen should be black right now")
spawn_sprite("TestUnit", "sprinkles", 3, 2)
get_unit("sprinkles").set_unit_owner(0)
get_unit("sprinkles").set_unit_movement_range(5)
get_unit("sprinkles").set_unit_attack_range(1)
get_unit("sprinkles").set_unit_class("king")
get_unit("sprinkles").set_unit_name("Sprinkles")
get_unit("sprinkles").set_stat_delta("level", 10)
get_unit("sprinkles").add_hook_script("dead.gd", "on_death")

spawn_sprite("TestUnit", "mantequilla", 1, 3)
get_unit("mantequilla").set_unit_owner(0)
get_unit("mantequilla").set_unit_movement_range(5)
get_unit("mantequilla").set_unit_attack_range(2)
get_unit("mantequilla").set_unit_class("blind")
get_unit("mantequilla").set_unit_name("Mantequilla")
get_unit("mantequilla").add_hook_script("dead.gd", "on_death")
# get_unit("mantequilla").set_stat_delta("level", 1)

spawn_sprite("TestUnit", "lilu", 2, 3)
get_unit("lilu").set_unit_owner(0)
get_unit("lilu").set_unit_movement_range(5)
get_unit("lilu").set_unit_attack_range(2)
get_unit("lilu").set_unit_class("stray")
get_unit("lilu").set_unit_name("Lilu")
get_unit("lilu").add_hook_script("dead.gd", "on_death")

get_unit("mantequilla").set_affinity_delta("lilu", 3)
get_unit("lilu").set_affinity_delta("mantequilla", 3)

spawn_sprite("TestUnit", "misty", 5, 2)
get_unit("misty").set_unit_owner(10)
get_unit("misty").set_unit_movement_range(3)
get_unit("misty").set_unit_attack_range(1)
get_unit("misty").set_unit_class("queen")
get_unit("misty").set_unit_name("Misty")
get_unit("misty").add_hook_script("dead.gd", "on_death")

spawn_sprite("TestUnit", "sabu", 3, 8)
get_unit("sabu").set_unit_owner(80)
get_unit("sabu").set_unit_movement_range(2)
get_unit("sabu").set_unit_attack_range(1)
get_unit("sabu").set_unit_class("beauty")
get_unit("sabu").set_unit_name("Sabu")
# get_unit("sabu").add_hook_script("textbox-test3.gd", "on_attacked_first_time")
# get_unit("sabu").add_hook_script("textbox-test.gd", "on_low_hp")
get_unit("sabu").add_hook_script("dead.gd", "on_death")

spawn_sprite("TestUnit", "spyro", 7, 5)
get_unit("spyro").set_unit_owner(90)
get_unit("spyro").set_unit_movement_range(3)
get_unit("spyro").set_unit_attack_range(1)
get_unit("spyro").set_unit_class("warrior")
get_unit("spyro").set_unit_name("Spyro")
get_unit("spyro").add_hook_script("dead.gd", "on_death")

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
