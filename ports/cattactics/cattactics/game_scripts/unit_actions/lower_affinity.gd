textbox("%s is no longer as friendly with %s..." % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
hide_textbox()

# raise affinity on both sides
get_variable("unit_action_attacking").set_affinity_delta(get_variable("unit_action_attacked").get_instance_id(), -0.3)
get_variable("unit_action_attacked").set_affinity_delta(get_variable("unit_action_attacking").get_instance_id(), -0.3)
