# textbox("critical: %s" % [get_variable('unit_action_result')['is_critical']])
# textbox("miss: %s" % [get_variable('unit_action_result')['is_miss']])
set_variable("unit_action_attacking_facing", get_variable("unit_action_attacking").get_facing())

# attack animation
animate_sprite(get_variable("unit_action_attacking").get_instance_id(), "attack_%s" % [get_variable("unit_action_attacking_facing")], get_variable("unit_action_attacking_facing"))

jump_if("missed", get_variable('unit_action_result')['is_miss'], true)
jump_if("critical_hit", get_variable('unit_action_result')['is_critical'] and not get_variable('unit_action_result')['is_miss'], true)
jump_if("normal_sfx", not get_variable('unit_action_result')['is_critical'] and not get_variable('unit_action_result')['is_miss'], true)

# if it didn't miss, and we didn't already jump to critical, then jump to damage outcome
jump_if("show_damage_amount", not get_variable('unit_action_result')['is_critical'] and not get_variable('unit_action_result')['is_miss'], true)
return()

# block:critical_hit
play_sfx("attack_critical")
textbox("Critical hit!")
hide_textbox()
jump("show_damage_amount")
return()

# block:missed
play_sfx("attack_missed")
textbox(get_variable("unit_action_missed_message", "The attack missed!"))
hide_textbox()
erase_variable("unit_action_missed_message")
return()

# block:normal_sfx
play_sfx("attack_general")
return()

# block:show_damage_amount
jump_if("affinity_boosted", get_variable("unit_action_is_affinity_boosted"), true)
textbox(get_variable("unit_action_damage_message", "Dealt %s damage!" % [get_variable('unit_action_result')['damage']]))
hide_textbox()
erase_variable("unit_action_damage_message")

# deal damage
get_variable("unit_action_attacked").set_stat_delta("hp_current", -get_variable('unit_action_result')['damage'])
return()

# block:affinity_boosted
textbox("Ally units boosted %s's attack" % [get_variable("unit_action_attacking").get_unit_name()])
hide_textbox()
return()
