
map.file = "book-empire.sve"

scenario.short_description = "Supply book shop"
scenario.author = "prissi (scripting by Dwachs)"
scenario.version = "0.1"

function get_rule_text(pl)
{
	return ttext("No rules. Only pressure to win.")
}

function get_goal_text(pl)
{
	return ttext("Supply the book shop at (20,50). <br><br>The scenario is won if book shop starts selling.")
}

function get_info_text(pl)
{
	return ttext("Your transport company is engaged to help the people of Leipzig to get something to read in dark winter nights.")
}

function get_result_text(pl)
{
	local con = get_book_consumption()

	local text = ttext("The bookshop sold {book} books.")
	text.book = con

	local text2 = ""
	if ( con > 0 ) {
		text2 = ttext("<it>Congratulation!</it><br> <br> You won the scenario!")
		if (!(persistent.win_date)) {
			persistent.win_date = world.get_time()
		}
		local date = ttext("<br><br> Won in {month} of {year}.")
		date.month = get_month_name(persistent.win_date.month)
		date.year  = persistent.win_date.year

		text2 = "" + text2 + date
	}
	else
		text2 = ttext("Leipzig people are still bored of your transportation service.")

	return text + "<br> <br>" + text2
}

// accessor to the book statistics
book_slot <- null

function start()
{
	book_slot = factory_x(20, 50).input.Buecher
	persistent.win_date <- null
}

function resume_game()
{
	book_slot = factory_x(20, 50).input.Buecher
	if (!("win_date" in persistent)) {
		persistent.win_date <- null
	}
}

function get_book_consumption()
{
	return book_slot.consumed.reduce( max )
}

function is_scenario_completed(pl)
{
	// make the book shop sell something
	return  get_book_consumption() > 0 ? 100 : 0;
}
