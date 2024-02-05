# add map conditions
gamescene.add_map_condition("all_enemy_units_dead", "win", {"type": "enemy_count", "equals": 0}, "levels/sprinkles_garden/win.gd")
gamescene.add_map_condition("player_units_dead", "lose", {"type": "player_count", "equals": 0}, "levels/sprinkles_garden/lose.gd")
gamescene.add_map_condition("ally_units_dead", "lose", {"type": "ally_count", "equals": 0}, "levels/sprinkles_garden/lose.gd")
gamescene.add_map_condition("sprinkles_dead", "lose", {"type": "unit_alive_state", "unit_id": "sprinkles", "equals": false}, "units/sprinkles/on_death.gd")
gamescene.add_map_condition("spyro_dead", "lose", {"type": "unit_alive_state", "unit_id": "spyro", "equals": false}, "units/spyro/on_death.gd")

gamescene.add_map_condition("2nd_turn", "", {"type": "turn", "equals": 2}, "levels/sprinkles_garden/2nd_turn.gd")

# set base variables
set_variable("tutorial_state", 1)
set_variable("sprinkles_garden_2nd_turn", false)
set_variable("gray_cats_death", 0)

play_bgm("sprinkles_garden")
