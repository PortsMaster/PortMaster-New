# deal stat changes to units
jump_if("missed", get_variable('unit_action_result')['is_miss'], true)

jump_if("show_action_outcome", not get_variable('unit_action_result')['is_miss'], true)
return()
return()

# block:missed
textbox(get_variable("unit_action_missed_message", "Nothing happened!"))
erase_variable("unit_action_missed_message")
hide_textbox()
return()

# block:show_action_outcome
set_variable("stat_action_current", 0)
jump("show_action_outcome_loop")
return()

# block:show_action_outcome_loop
jump_if("end", (get_variable("stat_action_current") >= get_variable('unit_action_action')['attributes']['stat'].size()), true)
jump_if("show_action_outcome_process", (get_variable("stat_action_current") < get_variable('unit_action_action')['attributes']['stat'].size()), true)
return()

# block:show_action_outcome_process
set_variable("stat_action_current_stat", get_variable('unit_action_action')['attributes']['stat'][get_variable("stat_action_current")])

play_sfx("action_stat")
textbox(get_variable("unit_action_damage_message", "%s's %s was %s by %s for %s turns" % [get_variable("unit_action_attacked").get_unit_name(), get_variable('stat_action_current_stat')['type'].to_upper(), get_variable('stat_action_current_stat')['amount_str'], abs(get_variable('stat_action_current_stat')['amount']), get_variable('stat_action_current_stat')['expire_turns']]))
hide_textbox()

# apply stat effects to unit
get_variable("unit_action_attacked").apply_stat_modifier(get_variable('stat_action_current_stat')['type'], get_variable('stat_action_current_stat')['amount'], get_variable('stat_action_current_stat')['expire_turns'])

set_variable_delta("stat_action_current", 1)
jump("show_action_outcome_loop")
return()

# block:end
return()
