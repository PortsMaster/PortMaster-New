# heal the unit, and check the amount healed
set_variable("unit_action_heal_result", get_variable("unit_action_attacked").recover_hp(get_variable("unit_action_result")['damage']))

jump_if("pre_unit_was_healed", (get_variable("unit_action_heal_result") > 0), true)
jump_if("unit_not_healed", (get_variable("unit_action_heal_result") == 0), true)
return()

# block:pre_unit_was_healed
jump_if("unit_was_healed_self", get_variable("unit_action_heal_self"), true)
jump_if("unit_was_healed_other", get_variable("unit_action_heal_self"), false)
return()

# block:unit_was_healed_other
textbox("%s licked %s back to health" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()
jump("unit_was_healed")
return()

# block:unit_was_healed_self
textbox(get_variable("unit_action_heal_message", "%s licked themselves back to health" % [get_variable("unit_action_attacking").get_unit_name()]))
hide_textbox()
erase_variable("unit_action_heal_message")
jump("unit_was_healed")
return()

# block:unit_was_healed
play_sfx("action_heal")
textbox("%s recovered %s HP!" % [get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_heal_result")])
hide_textbox()
return()

# block:unit_not_healed
textbox("%s is at full HP!" % [get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()
return()
