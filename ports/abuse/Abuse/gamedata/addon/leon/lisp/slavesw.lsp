(def_char SWITCH_SLAVE
  (funs (ai_fun swslave_ai))
  (states "art/misc.spe"
	  (stopped "0_indicator")
	  (on_state "1_indicator")))

(defun swslave_ai ()
  (if (> (total_objects) 0)
      (if (eq (with_obj0 (aistate)) 0)
	  (progn
	    (set_state stopped)
	    (set_aistate 0))
	(progn
	  (set_state on_state)
	  (set_aistate 1)))) T)