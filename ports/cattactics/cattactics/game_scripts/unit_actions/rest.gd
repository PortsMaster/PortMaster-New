# set the HP heal amount
set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

# rest is a self-only action
set_variable("unit_action_heal_self", true)

set_variable("unit_action_heal_message", "%s is having a nap..." % [get_variable("unit_action_attacking").get_unit_name()])

include("unit_actions/process_action.gd")
