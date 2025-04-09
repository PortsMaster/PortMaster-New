;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(defun quick_explo_light ()
  (select (aistate)
	  (0 (progn (link_light (add_light 0 (x) (y) 1 (aitype) 0 0))
		    (go_state 1)))
	  (1 (if (>= (state_time) 1)
		 (let ((l (get_light 0)))
		   (delete_light l)
		   nil)
	       T))))

(def_char QUICK_EXP_LIGHT
  (funs (ai_fun   quick_explo_light)
	(draw_fun dev_draw))
  (flags (unlistable T))
  (range 10000 10000)
  (states "art/misc.spe"
	  (stopped           "lhold")))