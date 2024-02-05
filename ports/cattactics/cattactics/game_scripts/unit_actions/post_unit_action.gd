# process attacked first time when unit is attacked
set_variable("process_unit_attacked_first_time_unit", get_variable("unit_action_attacked"))
include_if("unit_actions/process_unit_attacked_first_time.gd", get_variable("unit_action_is_attack"), true)
include_if("unit_actions/process_unit_attacked_first_time.gd", get_variable("unit_action_is_stat"), true)

# check if unit has low HP
set_variable("process_unit_low_hp_unit", get_variable("unit_action_attacking"))
include("unit_actions/process_unit_low_hp.gd")

set_variable("process_unit_low_hp_unit", get_variable("unit_action_attacked"))
include("unit_actions/process_unit_low_hp.gd")

# check if the unit was killed by this action
set_variable("process_unit_death_unit", get_variable("unit_action_attacking"))
include("unit_actions/process_unit_death.gd")

set_variable("process_unit_death_unit", get_variable("unit_action_attacked"))
include("unit_actions/process_unit_death.gd")

# process unit EXP if not miss or dead
jump_if("process_exp", (not get_variable("unit_action_attacking").is_dead() and not get_variable("unit_action_is_miss") and get_variable("unit_action_result")), true)

hide_textbox()
return()

# block:process_exp
set_variable("give_exp_unit", get_variable("unit_action_attacking"))
set_variable("give_exp_amount", get_variable("unit_action_result")['exp'])
set_variable("give_exp_state", get_variable("unit_action_result")['exp_state'])
set_variable("give_pre_exp_state", get_variable("unit_action_result")['pre_exp_state'])
include("unit_actions/give_exp.gd")
return()
