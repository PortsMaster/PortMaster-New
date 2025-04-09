sprite(get_variable("give_exp_unit").get_instance_id()).set_stat_delta("exp", get_variable("give_exp_amount"))
jump_if("show_exp_message", (not gamescene.is_ai_attack_turn()), true)
return()

# block:show_exp_message
textbox("%s gained %s EXP" % [get_variable("give_exp_unit").get_unit_name(), get_variable("give_exp_amount")])
hide_textbox()

# textbox("%s" % [get_variable("give_exp_state")])
# textbox("%s" % [get_variable("give_pre_exp_state")])
jump_if("show_level_message", get_variable("give_exp_state")['level_up'], true)
return()

# block:show_level_message
play_sfx("levelup")
textbox("%s leveled up!" % [get_variable("give_exp_unit").get_unit_name()])
hide_textbox()

# apply the new level
sprite(get_variable("give_exp_unit").get_instance_id()).set_stat("level", get_variable("give_exp_state")['level'])
jump("pre_stat_increase")
return()

# block:pre_stat_increase
set_variable("level_up_stat_increases", get_variable("give_exp_state")['stat_increases'])
jump("stat_increases")
return()

# block:stat_increases
jump_if("on_stat_increase", (get_variable("level_up_stat_increases").size() > 0), true)
jump_if("post_on_stat_increase", (get_variable("level_up_stat_increases").size() == 0 and not get_variable("post_on_stat_increase_done")), true)
return()

# block:post_on_stat_increase
set_variable("post_on_stat_increase_done", true)
return()

# block:on_stat_increase
set_variable("give_exp_stat_increase", get_variable("level_up_stat_increases").pop_front())
textbox("%s increased by %s" % [get_variable("give_exp_stat_increase")['stat'].to_upper(), get_variable("give_exp_stat_increase")['amount']])
hide_textbox()

# give increase
sprite(get_variable("give_exp_unit").get_instance_id()).set_stat_delta(get_variable("give_exp_stat_increase")['stat'], get_variable("give_exp_stat_increase")['amount'])

jump("stat_increases")
return()
