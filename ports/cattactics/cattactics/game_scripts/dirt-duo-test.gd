# dirt duo test script
spawn_sprite("TestSprite", "duosprite1", -10, -10)
spawn_sprite("TestSprite", "duosprite2", -10, -10)

set_sprite_position("duosprite1", 2, -1)
set_sprite_position("duosprite2", 4, -1)
sprite("duosprite1").set_movement_speed(0.15)
sprite("duosprite2").set_movement_speed(0.15)

move_sprite("duosprite1", ["down", "down"])
move_sprite("duosprite2", ["down", "right", "down"])
sprite_set_wait_movement("duosprite1", true)
sprite_set_wait_movement("duosprite2", true)
textbox("Halt! We are dirt duo, and we challenge you to earthly duel. Prepare yourself!", "Dirt")
wait(1)
textbox("... ... ...")
textbox("Oops, we just realised we can't fight, because we are dirt!", "Dirt")
hide_textbox()

sprite("duosprite1").set_movement_speed(0.10)
sprite("duosprite2").set_movement_speed(0.10)
move_sprite("duosprite1", ["up", "up", "up"])
move_sprite("duosprite2", ["up", "up", "up"])
sprite_set_wait_movement("duosprite1", true)
sprite_set_wait_movement("duosprite2", true)

despawn_sprite("duosprite1")
despawn_sprite("duosprite2")
