set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

set_variable("unit_action_damage_message", "%s enchanted %s and rose their SPD and affinity!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
set_variable("unit_action_missed_message", "It wasn't effective against %s!" % [get_variable("unit_action_attacked").get_unit_name()])

include("unit_actions/raise_affinity.gd")



include("unit_actions/process_action.gd")
return()
