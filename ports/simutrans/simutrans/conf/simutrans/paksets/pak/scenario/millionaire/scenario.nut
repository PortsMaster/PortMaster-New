
map.file = "millionaire.sve"

scenario.short_description = "Millionaire"
scenario.author = "prissi (scripting by Dwachs)"
scenario.version = "0.1"

function get_rule_text(pl)
{
	return ttext("No limits.")
}

function get_goal_text(pl)
{
	return ttext("Become millionaire as fast as possible.")
}

function get_info_text(pl)
{
	return ttext("You started a small transport company to become rich. Your grandparents did not have a glue, where all their money flows into.")
}

function get_result_text(pl)
{
	local cash = get_cash(pl)

	local text = ttext("Your bank account is worth {tcash}.")
	text.tcash = cash
	
	local text2 = ""
	if ( cash >= 1000000 )
		text2 = ttext("<it>Congratulation!</it><br> <br> You won the scenario!")
	else
		text2 = ttext("You still have to work a little bit harder.")

	return text + "<br> <br>" + text2
}

function get_cash(pl)
{
	return player_x(pl).cash[0]
}

function is_scenario_completed(pl)
{
	return  get_cash(pl) / 10000
}
