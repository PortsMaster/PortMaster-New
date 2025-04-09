# death message
gamescene.change_state(gamescene.MAP_FINISHED)
gamescene.hide_selected_unit_name() 

play_bgm("party_member_defeated")

textbox("Arrrrgh... No, Sprinkles I'm sorry ... I have to retreat!", "Spyro")

stop_bgm()
restart_level()
exit()
