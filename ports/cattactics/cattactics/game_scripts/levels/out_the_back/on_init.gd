# add map conditions
gamescene.add_map_condition("all_enemy_units_dead", "win", {"type": "enemy_count", "equals": 0}, "levels/out_the_back/win.gd")
gamescene.add_map_condition("player_units_dead", "lose", {"type": "player_count", "equals": 0}, "levels/out_the_back/lose.gd")
gamescene.add_map_condition("ally_units_dead", "lose", {"type": "ally_count", "equals": 0}, "levels/out_the_back/lose.gd")
gamescene.add_map_condition("sprinkles_dead", "lose", {"type": "unit_alive_state", "unit_id": "sprinkles", "equals": false}, "units/sprinkles/on_death.gd")
gamescene.add_map_condition("spyro_dead", "lose", {"type": "unit_alive_state", "unit_id": "spyro", "equals": false}, "units/spyro/on_death.gd")

gamescene.add_map_condition("3rd_turn", "", {"type": "turn", "equals": 3}, "levels/out_the_back/3rd_turn.gd")

gamescene.add_map_condition("5th_ture", "", {"type": "turn", "equals": 5}, "levels/out_the_back/5th_turn.gd")

# set base variables
set_variable("tutorial_state", 10)
set_variable("out_the_back_3rd_turn", false)
set_variable("out_the_back_5th_turn", false)
set_variable("recruited_misty", false)
set_variable("recruited_mantequilla", false)

play_bgm("out_the_back")
