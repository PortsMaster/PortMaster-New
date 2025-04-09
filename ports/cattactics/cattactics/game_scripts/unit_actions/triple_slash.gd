# execute multiple attacks in succession
set_variable("triple_slash_current", 0)

jump("triple_slash_attack")
return()

# block:triple_slash_attack
jump_if("triple_slash_attack_end", (get_variable("triple_slash_current", 0) >= get_variable("unit_action_action")['attributes']['attack_count_max']), true)
set_variable_delta("triple_slash_current", 1)

set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

# set a custom damage message to show later
set_variable("unit_action_missed_message", "%s missed!" % [get_variable("unit_action_attacking").get_unit_name()])
set_variable("unit_action_damage_message", "%s's slash dealt %s damage!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable('unit_action_result')['damage']])

include("unit_actions/process_action.gd")
jump("triple_slash_attack")
return()

# block:triple_slash_attack_end
# check if the unit was killed by this action
set_variable("process_unit_death_unit", get_variable("unit_action_attacking"))
include("unit_actions/process_unit_death.gd")

set_variable("process_unit_death_unit", get_variable("unit_action_attacked"))
include("unit_actions/process_unit_death.gd")
return()
