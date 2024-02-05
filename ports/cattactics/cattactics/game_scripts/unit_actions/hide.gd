set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

set_variable("unit_action_missed_message", "It didn't work!")
set_variable("unit_action_damage_message", "%s is invisible, cannot be attacked for %s turns!" % [get_variable("unit_action_attacked").get_unit_name(), get_variable("unit_action_action")['attributes']['stat'][0]['expire_turns']])

include("unit_actions/process_action.gd")
return()
