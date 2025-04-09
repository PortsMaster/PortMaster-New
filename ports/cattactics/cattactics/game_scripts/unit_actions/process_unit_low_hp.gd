set_variable("unit_hp_low", (get_variable("process_unit_low_hp_unit").get_stat("hp_current") <= 5 and get_variable("process_unit_low_hp_unit").get_stat("hp_current") > 0))
jump_if("unit_hp_low", get_variable("unit_hp_low"), true)
return()

# block:unit_hp_low
gamescene.execute_scripts("on_low_hp", false)

# wait(0.5)
return()
