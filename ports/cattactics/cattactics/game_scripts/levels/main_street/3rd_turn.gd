# find a street cat that is still alive
jump_if("street_cats_truce", get_variable("main_street_3rd_turn", false), false)
return()

# block:street_cats_truce
textbox_portrait_left("sprinkles", true)
textbox("It must be stated before further bloodshed ensues that the ones behind this are the Black Cats.", "Sprinkles")
textbox("We're here to hunt them down, and run them out!", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("spyro", true)
textbox("It's true, I witnessed the invasion of Black Cat underlings in Sprinkle's Garden.", "Spyro")
textbox_portrait_right()

textbox_portrait_right("streetcat1", true)
textbox("Is that the truth you speak?", "Street Cat")
textbox("Very well, if you say so, then we must cease crossing claws any further and propose an alliance.", "Street Cat")
textbox("We know where those Black Cats are currently holed up.", "Street Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Then it's an honour to welcome you to our cause.", "Sprinkles")
textbox("Where can we find them?", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("streetcat1", true)
textbox("Up the road, along the side of the houses, is known as Black Cat Alley.", "Street Cat")
textbox("All the black cats in the area hang out there.", "Street Cat")
textbox("If they are anywhere, it must be there!", "Street Cat")
textbox("We must make it there quickly, I sense that reinforcements are already on the move.", "Street Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Then we must go, to the alley!", "Sprinkles")
textbox_portrait_left()

wait(0.5)

set_sprite_position("MAPCURSOR", 0, 4)

textbox("Objective: Reach the Black Cat's Alley or defeat all enemies to complete the level.")
hide_textbox()


get_unit("streetcat1").set_unit_owner(0)
get_unit("streetcat2").set_unit_owner(0)
get_unit("streetcat3").set_unit_owner(0)
get_unit("streetcat4").set_unit_owner(0)

# spawn reinforcements
spawn_sprite("BlackCat", "reinforcement1", 8, 0)
get_unit("reinforcement1").set_unit_owner(80)
get_unit("reinforcement1").set_unit_class("stray")
get_unit("reinforcement1").set_unit_name("Underling 1")
get_unit("reinforcement1").set_stat_delta("level", 5)
get_unit("reinforcement1").set_unit_recruitable(false)
get_unit("reinforcement1").set_unit_permanent(false)
get_unit("reinforcement1").set_movement_speed(0.1)

spawn_sprite("BlackCat", "reinforcement2", 8, 2)
get_unit("reinforcement2").set_unit_owner(80)
get_unit("reinforcement2").set_unit_class("stray")
get_unit("reinforcement2").set_unit_name("Underling 2")
get_unit("reinforcement2").set_stat_delta("level", 5)
get_unit("reinforcement2").set_unit_recruitable(false)
get_unit("reinforcement2").set_unit_permanent(false)
get_unit("reinforcement2").set_movement_speed(0.1)

spawn_sprite("BlackCat", "reinforcement3", 6, 0)
get_unit("reinforcement3").set_unit_owner(80)
get_unit("reinforcement3").set_unit_class("stray")
get_unit("reinforcement3").set_unit_name("Underling 3")
get_unit("reinforcement3").set_stat_delta("level", 5)
get_unit("reinforcement3").set_unit_recruitable(false)
get_unit("reinforcement3").set_unit_permanent(false)
get_unit("reinforcement3").set_movement_speed(0.1)

spawn_sprite("BlackCat", "reinforcement4", 6, 2)
get_unit("reinforcement4").set_unit_owner(80)
get_unit("reinforcement4").set_unit_class("stray")
get_unit("reinforcement4").set_unit_name("Underling 4")
get_unit("reinforcement4").set_stat_delta("level", 5)
get_unit("reinforcement4").set_unit_recruitable(false)
get_unit("reinforcement4").set_unit_permanent(false)
get_unit("reinforcement4").set_movement_speed(0.1)

spawn_sprite("BlackCat", "reinforcement5", 4, 0)
get_unit("reinforcement5").set_unit_owner(80)
get_unit("reinforcement5").set_unit_class("stray")
get_unit("reinforcement5").set_unit_name("Underling 5")
get_unit("reinforcement5").set_stat_delta("level", 5)
get_unit("reinforcement5").set_unit_recruitable(false)
get_unit("reinforcement5").set_unit_permanent(false)
get_unit("reinforcement5").set_movement_speed(0.1)

wait(0.5)

set_sprite_position("MAPCURSOR", 8, 0)

wait(0.5)

set_sprite_position("MAPCURSOR", get_unit("sprinkles").tile_position.x, get_unit("sprinkles").tile_position.y)

set_variable("main_street_3rd_turn", true)

play_bgm("main_street_after_truce")
return()
