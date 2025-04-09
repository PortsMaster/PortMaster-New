set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

set_variable("unit_action_missed_message", "It failed!")
set_variable("unit_action_damage_message", "%s was stunned, cannot move for %s turns!" % [get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_action")['attributes']['stat'][0]['expire_turns']])

include("unit_actions/process_action.gd")
return()
