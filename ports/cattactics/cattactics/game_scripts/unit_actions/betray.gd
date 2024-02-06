textbox("%s attempted to be friendly with %s..." % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
textbox("...")
textbox("W-What!?", get_variable("unit_action_attacked").get_unit_name())
textbox("%s betrayed %s and attacked instead!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_attacked").get_unit_name()])
textbox("Aaahh!", get_variable("unit_action_attacked").get_unit_name())
hide_textbox()

set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

# set a custom damage message to show later
set_variable("unit_action_damage_message", "%s's unexpected attack dealt %s damage!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable('unit_action_result')['damage']])
set_variable("unit_action_missed_message", "%s saw through your lies and your plot failed..." % [get_variable("unit_action_attacked").get_unit_name()])

include("unit_actions/process_action.gd")
