# add map conditions
gamescene.add_map_condition("all_enemy_units_dead", "win", {"type": "enemy_count", "equals": 0}, "levels/black_cats_alley/win.gd")
gamescene.add_map_condition("player_units_dead", "lose", {"type": "player_count", "equals": 0}, "levels/black_cats_alley/lose.gd")
gamescene.add_map_condition("ally_units_dead", "lose", {"type": "ally_count", "equals": 0}, "levels/black_cats_alley/lose.gd")
gamescene.add_map_condition("sprinkles_dead", "lose", {"type": "unit_alive_state", "unit_id": "sprinkles", "equals": false}, "units/sprinkles/on_death.gd")
gamescene.add_map_condition("spyro_dead", "lose", {"type": "unit_alive_state", "unit_id": "spyro", "equals": false}, "units/spyro/on_death.gd")

# set base variables
# set_variable("tutorial_state", 10)
# set_variable("main_street_3rd_turn", false)
# set_variable("main_street_5th_turn", false)
# set_variable("recruited_lilu", false)
# set_variable("recruited_sabu", false)

set_variable("black_cats_alley_boss_activated", false)
set_variable("blackcats_death_state", 1)

spawn_sprite_from_party("misty", "sprinkles", Vector2(1, -1))
spawn_sprite_from_party("mantequilla", "sprinkles", Vector2(0, -2))
spawn_sprite_from_party("sabu", "sprinkles", Vector2(-2, -2))
spawn_sprite_from_party("lilu", "sprinkles", Vector2(-4, -2))
spawn_sprite_from_party("graystray1", "sprinkles", Vector2(-2, 0))
spawn_sprite_from_party("blackcat1", "sprinkles", Vector2(-3, -1))
spawn_sprite_from_party("whitecat1", "sprinkles", Vector2(-4, 0))
spawn_sprite_from_party("whitecat2", "sprinkles", Vector2(-5, -1))
spawn_sprite_from_party("whitestray1", "sprinkles", Vector2(-6, 0))
spawn_sprite_from_party("whitestray2", "sprinkles", Vector2(-7, -1))

jump_if("recruited_mantequilla", (unit_recruited_and_present("mantequilla")), true)
jump_if("recruited_misty", (unit_recruited_and_present("misty")), true)
jump_if("recruited_lilu", (unit_recruited_and_present("lilu")), true)
jump_if("recruited_sabu", (unit_recruited_and_present("sabu")), true)

set_sprite_position("MAPCURSOR", 27, 9)

play_bgm("black_cats_alley_start")
return()

# block:recruited_mantequilla
get_unit("mantequilla").add_hook_script("units/mantequilla/on_death.gd", "on_death")
return()

# block:recruited_misty
get_unit("misty").add_hook_script("units/misty/on_death.gd", "on_death")
return()

# block:recruited_lilu
get_unit("lilu").add_hook_script("units/lilu/on_death.gd", "on_death")
return()

# block:recruited_sabu
get_unit("sabu").add_hook_script("units/sabu/on_death.gd", "on_death")
return()
