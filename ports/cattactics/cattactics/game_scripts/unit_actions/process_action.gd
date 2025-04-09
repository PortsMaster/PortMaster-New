# get the result of unit_action_result and process the action result
set_variable("unit_action_is_critical", (get_variable("unit_action_result")['is_critical']))
set_variable("unit_action_is_miss", (get_variable("unit_action_result")['is_miss']))
set_variable("unit_action_is_affinity_boosted", (get_variable("unit_action_result")['is_affinity_boosted']))

# set type of attack used
set_variable("unit_action_attacked_charm", (get_variable("unit_action_attacked").get_stat("charm") > 0))
jump_if("allow_attack", (get_variable("unit_action_attacked_charm") and get_variable("unit_action_attacking") != get_variable("unit_action_attacked")), false)
jump_if("charmed_attack", get_variable("unit_action_attacked_charm"), true)
return()

# block:allow_attack
set_variable("unit_action_is_attack", (get_variable("unit_action_action")['type'] in ['attack', 'attack_multiple']))
set_variable("unit_action_is_heal", (get_variable("unit_action_action")['type'] in ['heal']))
set_variable("unit_action_is_stat", (get_variable("unit_action_action")['type'] in ['stat']))
set_variable("unit_action_is_special", (get_variable("unit_action_action")['type'] in ['special']))

# jump to process different types
include_if("unit_actions/process_action_attack.gd", get_variable("unit_action_is_attack"), true)
include_if("unit_actions/process_action_heal.gd", get_variable("unit_action_is_heal"), true)
include_if("unit_actions/process_action_stat.gd", get_variable("unit_action_is_stat"), true)
include_if("unit_actions/process_action_special.gd", get_variable("unit_action_is_special"), true)

return()

# block:charmed_attack
textbox("%s's charm causes %s to stop attacking!" % [get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_attacking").get_unit_name()])
hide_textbox()
return()
