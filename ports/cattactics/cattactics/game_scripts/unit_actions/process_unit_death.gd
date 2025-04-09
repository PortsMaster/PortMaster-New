set_variable("unit_dead", get_variable("process_unit_death_unit").is_dead())
set_variable("post_on_death_script_done", false)

jump_if("pre_unit_dead", get_variable("unit_dead"), true)
return()

# block:pre_unit_dead
set_variable("on_death_scripts", get_variable("process_unit_death_unit").get_scripts()['on_death'])
jump("unit_dead")
return()

# block:unit_dead
# keep executing on_death scripts until there's none left
jump_if("on_death_script", (get_variable("on_death_scripts").size() > 0), true)
jump_if("post_on_death_script", (get_variable("on_death_scripts").size() == 0 and not get_variable("post_on_death_script_done")), true)
return()

# block:post_on_death_script
play_sfx("death")
animate_sprite(get_variable("process_unit_death_unit").get_instance_id(), "death")
textbox("%s fled the area..." % [get_variable("process_unit_death_unit").get_unit_name()])
hide_textbox()
set_variable("post_on_death_script_done", true)
return()

# block:on_death_script
set_variable("script_hook_sprite", get_variable("process_unit_death_unit"))
include(get_variable("on_death_scripts").pop_front(), 0, "")
jump("unit_dead")
return()
