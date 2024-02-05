# set the HP heal amount
set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

set_variable("unit_action_heal_self", get_variable("unit_action_attacking") == get_variable("unit_action_attacked"))

include("unit_actions/process_action.gd")
