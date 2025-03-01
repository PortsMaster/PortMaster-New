/*
 *  class basic_convoys
 *
 *
 *  Can NOT be used in network game !
 */

//Number of convoys in each chapter are listed
cv_list <-	[
				//Chapter_02: [Step..], [Cov_nr..], Index --------------
				{stp = [4,6,7], cov = [1,3,1], idx = 0},

				//Chapter_03: [Step..], [Cov_nr..], Index --------------
				{stp = [5,7,11], cov = [1,1,3], idx = 0}

				//Chapter_04: [Step..], [Cov_nr..], Index --------------
				{stp = [4,5,7], cov = [2,2,1], idx = 0}

				//Chapter_05: [Step..], [Cov_nr..], Index --------------
				{stp = [2,4,4], cov = [10,3,1], idx = 0}

				//Chapter_06: [Step..], [Cov_nr..], Index --------------
				{stp = [2,3,4], cov = [1,2,5], idx = 0}
			]

//Generate list with convoy limits
cv_lim <- [] //[{limit_a, limit_b, chapter_nr, step_nr}..]

class basic_convoys
{
	function set_convoy_limit()
	{
		local nr = -1
		local idx = 0
		for(local j = 0; j<cv_list.len(); j++){
			local cov = cv_list[j].cov
			local step = cv_list[j].stp
			cv_list[j].idx = idx
			for(local i = 0; i<cov.len(); i++){
				local cv = cov[i]
				local st = step[i]
				cv_lim.push({a = nr, b = (nr + cv)+(1), stp = st, ch = (j+2) })
				nr += cv
				idx++
			}

		}
	}

	function checks_all_convoys()
	{
		local cov_list = world.get_convoy_list()
		local cov_nr = 0
		foreach(cov in cov_list) {
			local id = cov.id
			if (id>gcov_id)
				gcov_id = id

			if (!cov.is_in_depot() && convoy_ignore(ignore_save, id))
				cov_nr++	
		}	
		return cov_nr
	}

	function convoy_ignore(list, id)
	{
		for(local j = 0; j<list.len(); j++) {
			if(list[j].id == id)
				return false
		}
		return true
	}

	function checks_convoy_removed(pl)
	{
		local j = 0
		local sw = true
		for(j;j<cov_save.len();j++){
			//gui.add_message("checks_convoy_removed --- j "+ j)
			local result = true
			// cnv - convoy_x instance saved somewhat earlier
			try {
				 cov_save[j].get_pos() // will fail if cnv is no longer existent
				 // do your checks
			}
			catch(ev) {
				result = false
				cov_save[j] = null
				if (sw){
					current_cov = j
					persistent.current_cov = j				
				}
				sw = false
				break
			}
			if (result){
				if (cov_save[j].is_in_depot()){
					cov_save[j] = null						
				}
			}
		}
		if (sw){
			current_cov = j
			persistent.current_cov = j				
		}
		//gui.add_message(""+j+"::"+current_cov+"")
		if (!correct_cov_list()){
			set_convoy_regression(current_cov)
		}
		return null
	}

	function correct_cov_list()
	{
		if (gall_cov==gcov_nr){
			return true
		}

		return false
	}

	function set_convoy_regression(cov_nr)
	{
		local pl = 0
		foreach(lim in cv_lim) {
			//gui.add_message(""+lim.a +" :: "+lim.b + " - "+lim.ch+ " :: "+lim.stp+" :: index "+cv_list[1].idx)
			if (cov_nr > lim.a && cov_nr < lim.b && persistent.status.chapter >= lim.ch){
				if(lim.stp < persistent.step || persistent.status.chapter != lim.ch)
					load_conv_ch(lim.ch, lim.stp, pl)
				break
			}

		}
	}
}

// END OF FILE
