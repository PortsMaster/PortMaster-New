set_variable("random_stat", ['atk', 'def', 'spd', 'int', 'vit', 'lck'])
get_variable("random_stat").shuffle()
set_variable("random_stat", get_variable("random_stat")[0])

set_variable("random_stat_turns", randi_range(2, 3))

textbox("%s's %s is increased for %s turns!" % [get_variable("random_stat_buff_unit").get_unit_name(), get_variable("random_stat").to_upper(), get_variable("random_stat_turns")])
hide_textbox()

get_variable("random_stat_buff_unit").apply_stat_modifier(get_variable('random_stat'), 1, get_variable('random_stat_turns'))
