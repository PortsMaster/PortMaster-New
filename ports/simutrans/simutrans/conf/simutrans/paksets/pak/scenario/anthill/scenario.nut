
map.file = "anthill.sve"

scenario.short_description = "Anthill"
scenario.author = "prissi (scripting by Dwachs)"
scenario.version = "0.1"

function get_rule_text(pl)
{
	return ttext("Do what you want. But do it now.")
}

function get_goal_text(pl)
{
	return ttext("Transport at least 500 passengers per month.")
}

function get_info_text(pl)
{
	return ttext("Your duty is to build up a passenger network that is capable of transporting 500 passengers per month.")
}

function get_result_text(pl)
{
	local pax = get_transported_pax(pl)


	local text1 = ttext("You already transported max. {pax} passengers per month.<br> <br>")
	text1.pax = pax

	local text = text1.tostring()
	if ( pax > 500 )
		text += ttext("<it>Congratulation!</it><br> <br> You won the scenario!")
	else
		text += ttext("Local authorities are slowly losing patience with your poor transport network.")

	return text
}

function get_transported_pax(pl)
{
	return player_x(pl).transported_pax.reduce( max )
}

function is_scenario_completed(pl)
{
	// transport 500 passengers / month
	return  (get_transported_pax(pl)*100) / 500
}
