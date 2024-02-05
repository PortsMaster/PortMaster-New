# execute multiple attacks in succession
set_variable("blind_swipes_current", 0)
set_variable("blind_swipes_max", randi_range(get_variable("unit_action_action")['attributes']['attack_count_min'], get_variable("unit_action_action")['attributes']['attack_count_max']))

jump("blind_swipes_attack")
return()

# block:blind_swipes_attack
jump_if("blind_swipes_attack_end", (get_variable("blind_swipes_current", 0) >= get_variable("blind_swipes_max")), true)
set_variable_delta("blind_swipes_current", 1)

textbox("%s swiped blindly at %s..." % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()

set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

# set a custom damage message to show later
set_variable("unit_action_damage_message", "It dealt %s damage to %s!" % [get_variable('unit_action_result')['damage'], get_variable("unit_action_attacked").get_unit_name()])
set_variable("unit_action_missed_message", "%s completely missed!" % [get_variable("unit_action_attacking").get_unit_name()])


include("unit_actions/process_action.gd")
jump("blind_swipes_attack")
return()

# block:blind_swipes_attack_end
textbox("%s swipes!" % [get_variable("blind_swipes_max")])
hide_textbox()

# check if the unit was killed by this action
set_variable("process_unit_death_unit", get_variable("unit_action_attacking"))
include("unit_actions/process_unit_death.gd")

set_variable("process_unit_death_unit", get_variable("unit_action_attacked"))
include("unit_actions/process_unit_death.gd")
return()
