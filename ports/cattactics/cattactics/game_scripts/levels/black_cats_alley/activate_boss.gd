jump_if("boss_dialog", (get_variable("black_cats_alley_boss_activated", false)), false)
jump_if("game_complete", (gamescene.unit_is_dead("bosscat1") and gamescene.unit_is_dead("bosscat2") and gamescene.unit_is_dead("bosscat3")), true)
return()

# block:boss_dialog
textbox_portrait_right("bosscat1", true)
textbox("Pssssss...!", "Boss Cat")
textbox("How dare a lowly weakling such as yourself disturb our nap...", "Boss Cat")
textbox_portrait_right()

textbox_portrait_left("sprinkles", true)
textbox("Black Cats!", "Sprinkles")
textbox("We are putting down your plot for invasion. We've brought friends, too.", "Sprinkles")
textbox("The 3 of you are powerless against us.", "Sprinkles")
textbox_portrait_left()

textbox_portrait_right("bosscat1", true)
textbox("You broke the sacred rule of attacking another cat while they are asleep.", "Boss Cat")
textbox("Now witness our true power and strength as Boss Cats!", "Boss Cat")
textbox_portrait_right()
hide_textbox()

textbox("The Black Cats grew in strength!")

play_bgm("black_cats_alley_boss")

get_unit("bosscat1").set_unit_class("boss")
get_unit("bosscat2").set_unit_class("boss")
get_unit("bosscat3").set_unit_class("boss")

set_variable("black_cats_alley_boss_activated", true)
return()

# block:game_complete
game_complete()
return()
