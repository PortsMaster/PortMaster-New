;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights



(defun make_smart_plat (symbol off_frame on_frame snap_yoffset)
  (eval (list 'def_char symbol
	      '(flags (can_block T))
	      `(abilities (start_accel ,snap_yoffset))
	      `(fields ("xacel" ,plat_speed)
		       ("yacel" ,plat_2speed)
		       ("xvel"  ,plat_pos)
		       ("yvel"  ,plat_wait))
	      '(funs (ai_fun      platform_ai)
		     (constructor platform_cons))
	      '(range 50 500)
	      '(draw_range 30 60)
	      `(states "art/chars/platform.spe"
		       (stopped   ,off_frame)
		       (running   (list ,off_frame ,on_frame) )))))


(make_smart_plat 'SMART_PLAT_BIG   "big_off"   "big_on"   26)
(make_smart_plat 'SMART_PLAT_SMALL "small_off" "small_on" 22)
(make_smart_plat 'SMART_PLAT_RED   "rplat_off" "rplat_on" 72)


(defun platform_cons () (set_xacel 20) (set_yvel 50))

(defun plat_speed ()
  (if (eq (aistate) 0)
      (xacel)
    (if (eq (yacel) 0)
	(xacel)
      (yacel))))

(defun platform_move (source dest)
  (let ((destx (with_object dest (x)))
	(desty (with_object dest (y)))
	(sourcex (with_object source (x)))
	(sourcey (with_object source (y))))
    (if (equal (xvel) 0)  ;; no more steps
	(progn
	  (platform_push (- destx (x)) (- desty (y)))
	  (set_x destx)
	  (set_y desty)
	  (set_aistate 0))  ;; stop
      (let ((speed (plat_speed)))
	(let ((newx (- destx (/ (* (- destx sourcex) (xvel)) speed)))
	      (newy (- desty (/ (* (- desty sourcey) (xvel)) speed))))
	  (progn
	    (platform_push (- newx (x)) (- newy (y)))
	    (set_xvel (- (xvel) 1))
	    (set_x newx)
	    (set_y newy)))))))

(defun platform_ai ()
  (if (or (eq (total_objects) 2)                     ;; no switch to listen to processed as normal
	  (and (eq (total_objects) 3)
	       (not (eq (with_object (get_object 2) (aistate)) 0))))  ;; see if switch is active
      (progn
	(if (eq (state) stopped)
	    (set_state running)
	  (next_picture))
	(select (aistate)
		(0 ;; look for a player
		 (if (or (not (eq (with_object (get_object (aitype)) (aistate)) 0))
			 (and (touching_bg) (with_object (bg) (pressing_action_key))))
		     (progn
		       (if (and (touching_bg) (with_object (bg) (pressing_action_key)))
			   (let ((mex (x))
				 (mey (- (y) (get_ability start_accel))))
			     (with_object (bg) (progn (set_y mey)))))
		       (go_state 2))))


		(2 ;; swap dest and source and go to new dest
		 (play_sound PLAT_A_SND 127 (x) (y))
		 (set_aitype (- 1 (aitype)))
		 (set_xvel (plat_speed));; steps to go
		 (go_state 3))

		(3 ;; go to dest
		 (if (eq (xvel) 6)
		     (play_sound PLAT_D_SND 127 (x) (y)))
		 (platform_move (get_object (aitype)) (get_object (- 1 (aitype)))))
		))
    (set_state stopped))
  T)
































