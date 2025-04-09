# death message
gamescene.change_state(gamescene.MAP_FINISHED)
gamescene.hide_selected_unit_name() 

play_bgm("party_member_defeated")

textbox("U-uggggh.. I-I can't go on! I'm sorry...", "Sprinkles")
textbox("Curse you, Black Cats! I will... have my r-revenge!", "Sprinkles")

stop_bgm()
restart_level()
exit()
