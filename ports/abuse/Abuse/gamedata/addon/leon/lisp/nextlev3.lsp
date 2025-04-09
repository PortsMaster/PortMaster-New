(defun next_level3_ai ()
  (if (and (touching_bg) (with_object (bg) (pressing_action_key)))
      (if (eq (aistate) end_level)
	  (request_end_game)
	(progn
	  (show_stats)
	  (request_level_load (concatenate 'string "addon/leon/level" (digstr (aistate) 2) ".spe")))))
  T)


(def_char NEXT_LEVEL3
  (funs (ai_fun next_level3_ai))
  (flags (can_block T))
  (fields ("aistate" next_level))
  (states "art/misc.spe"
	  (stopped "end_port2")))

(defun sw_endlev_ai ()
  (if (> (total_objects) 0)
      (if (eq (with_obj0 (aistate)) 1)
	  (progn
	    (set_state stopped)
	    (if (eq (aistate) end_level)
	  (request_end_game)
	(progn
	  (show_stats)
	  (request_level_load (concatenate 'string "addon/leon/level" (digstr (aistate) 2) ".spe"))))))) T)

(def_char SW_ENDLEV
  (funs (ai_fun sw_endlev_ai)
        (draw_fun dev_draw))
  (fields ("aistate" next_level))
  (states "art/misc.spe"
	  (stopped "end_port2")))