# jump_if("show_use_message", gamescene.is_ai_attack_turn(), true)
include(get_variable("unit_action_action_script"))
return()

# block:show_use_message
set_variable("unit_action_is_attack", (get_variable("unit_action_action")['type'] in ['attack', 'attack_multiple']))
set_variable("unit_action_is_heal", (get_variable("unit_action_action")['type'] in ['heal']))
set_variable("unit_action_is_stat", (get_variable("unit_action_action")['type'] in ['stat']))
set_variable("unit_action_is_special", (get_variable("unit_action_action")['type'] in ['stat']))

jump_if("type_use_self", get_variable("unit_action_is_attack"), true)
jump_if("type_use_self", get_variable("unit_action_is_heal"), true)
jump_if("type_use_self", get_variable("unit_action_is_stat"), true)
jump_if("type_use_self", get_variable("unit_action_is_special"), true)
return()

# block:type_attack
textbox("%s attacked %s with %s!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_action")['name']])
hide_textbox()
exit()

# block:type_use
jump_if("type_use_self", (get_variable("unit_action_attacking") == get_variable("unit_action_attacked")), true)
jump_if("type_use_other", (get_variable("unit_action_attacking") != get_variable("unit_action_attacked")), true)
exit()

# block:type_use_self
textbox("%s used %s!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_action")['name']])
hide_textbox()
exit()

# block:type_use_other
textbox("%s used %s on %s!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_action")['name'], get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()
exit()
