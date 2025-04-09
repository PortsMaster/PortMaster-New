# low hp message
jump_if("low_hp_message", (get_variable("unit_action_attacked").get_instance_id() == "sprinkles"), true)
return()

# block:low_hp_message
textbox("Sprinkles is low on HP, don't let him be defeated.")
return()
