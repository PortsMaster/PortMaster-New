textbox("%s slashed %s!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()

set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

# set a custom damage message to show later
set_variable("unit_action_missed_message", "Huh, %s missed %s!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
set_variable("unit_action_damage_message", "%s's sharp claws dug into %s and dealt %s damage!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name(), get_variable('unit_action_result')['damage']])

include("unit_actions/process_action.gd")
