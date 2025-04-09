set_variable("unit_action_result", self.battlesystem.get_battle_action_result(get_variable("unit_action_attacking"), get_variable("unit_action_attacked"), get_variable("unit_action_action")))

set_variable("unit_action_missed_message", "They didn't fall for it!")
set_variable("unit_action_damage_message", "%s charmed the enemy, they won't attack for %s turns!" % [get_variable("unit_action_attacking").get_unit_name(), get_variable("unit_action_action")['attributes']['stat'][0]['expire_turns']])

get_variable("unit_action_attacking").apply_stat_modifier("charm", 1, get_variable('unit_action_action')['attributes']['stat'][0]['expire_turns'])

textbox(get_variable("unit_action_damage_message"))
hide_textbox()

# include("unit_actions/process_action.gd")
return()
