
map.file = "pharmacy-max.sve"

scenario.short_description = "Supply pharmacy"
scenario.author = "Dwachs"
scenario.version = "0.1"

function get_rule_text(pl)
{
	return ttext("You can build everything you like. The sky (and your bank account) is the limit.")
}

function get_goal_text(pl)
{
	return ttextfile("goal.txt")
}

function get_info_text(pl)
{
	return ttext("Your transport company is engaged to help the oil and pharmacy business in the small city of Port Petrol.")
}

function get_result_text(pl)
{
	local con = get_medicine_consumption()

	local text = ttext("The pharmacy sold {med} units of medicine per month.")
	text.med = con

	local text2 = ""

	if ( con >=120 )
		text2 = ttext("<it>Congratulation!</it><br> <br> You won the scenario!")
	else
		text2 = ttext("Still too few units.")

	return text.tostring() + "<br> <br>" + text2.tostring()
}

// accessor to the medicine supply statistics
medicine_slot <- null

function start()
{
	medicine_slot = factory_x(42, 37).input.Medicine
}

function get_medicine_consumption()
{
	return medicine_slot.consumed.reduce( max )
}

function is_scenario_completed(pl)
{
	// supply 120 units to the pharmacy
	return  (get_medicine_consumption()*100 ) / 120
}
