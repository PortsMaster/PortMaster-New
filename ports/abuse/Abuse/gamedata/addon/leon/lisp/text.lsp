   ;  0123456789012345678901234567890123456789012345678901234567890123456789
   ;  "--------------------------------------------------------------------"
   ; Please keep all strings below shorter than the above line.
   ; Add as many strings as you like.


(defun get_message (message_num)
  (select message_num
   (0 "Dammit! I gotta get out of here!")
   (1 "What the...")
   (2 "Damn!")
   (3 "Holy Shit!")
   (4 "I don't like the looks of this...")
   (5 "I have a bad feeling about this.")
  )
)

(defun msg_ai ()
  (if (eq (aistate) 0)
      (if (activated)
	  (progn
	    (with_object (bg)
			 (progn nil
;			   (if (local_player) ;; Doesnt work for some reason
;			       (show_help (get_message (aitype))))
			   ))
	    (set_aistate 1)
	    T)
	T)
    (if (eq (aistate) 20)
	nil
      (progn
	(if (with_object (bg) (local_player))
	    (show_help (get_message (aitype))))
	(set_aistate (+ (aistate) 1))
	T))))

(def_char MESSAGE
  (funs (ai_fun msg_ai)
	(draw_fun dev_draw))
  (fields ("aitype" train_msg_num))
  (states "art/misc.spe"
	  (stopped "bubble")))
