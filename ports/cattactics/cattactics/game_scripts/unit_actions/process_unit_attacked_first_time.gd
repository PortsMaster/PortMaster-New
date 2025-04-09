# check if attacked
jump_if("attacked_first_time", get_variable("unit_attacked_first_time_%s" % [get_variable("process_unit_attacked_first_time_unit")], false), false)

return()

# block:attacked_first_time
gamescene.execute_scripts("on_attacked_first_time", false, get_variable("unit_action_attacked").get_instance_id())
set_variable("unit_attacked_first_time_%s" % [get_variable("process_unit_attacked_first_time_unit")], true)

# wait(0.5)
return()
