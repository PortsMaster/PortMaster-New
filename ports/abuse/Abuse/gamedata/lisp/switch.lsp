;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun switcher_ai ()
  (next_picture)
  (select (aistate)
	  (0      ; waiting for player to press, then turn to on
	   (if (and (< (distx) 20) (< (disty) 30) (with_object (bg) (pressing_action_key)))
	       (progn
		 (play_sound SWITCH_SND 127 (x) (y))
		 (set_state running)
		 (set_aistate 1))))
	  (1     ; wait for player to let go of button
	   (if (not (with_object (bg) (pressing_action_key)))
	       (set_aistate 2)))
	  (2     ; wait for player to press, then turn to off
	   (if (and (< (distx) 20) (< (disty) 30) (with_object (bg) (pressing_action_key)))
	       (progn
		 (play_sound SWITCH_SND 127 (x) (y))
		 (set_state stopped)
		 (set_aistate 4))))
	   (4     ; wait for player to let go of button
	    (if (not (with_object (bg) (pressing_action_key)))
		(set_aistate 0)))
	   )
T)


(defun switch_once_ai ()
  (select (aistate)
	  (0      ; waiting for player to press, then turn to on
	   (next_picture)
	   (if (and (< (distx) 20) (< (disty) 30) (with_object (bg) (pressing_action_key)))
	       (progn
		 (print (random 1000))
		 (play_sound SWITCH_SND 127 (x) (y))
		 (set_state running)
		 (set_aistate 1)))))
  T)

(defun lower_reload () (lower))   ;; move object below all other objects

(def_char SWITCH
  (funs (ai_fun switcher_ai)
	(reload_fun lower_reload))
  (range 0 0)
  (states "art/misc.spe"
	  (stopped '("switch_off1" "switch_off2"))
	  (running '("switch_on1"  "switch_on2"))))

(def_char SWITCH_ONCE
  (funs (ai_fun switch_once_ai)
	(reload_fun lower_reload))
  (range 0 0)
  (states "art/misc.spe"
	  (stopped '("switch_off1" "switch_off2"))
	  (running '("switch_on1"  "switch_on2"))))


(defun switch_delay_cons ()
  (setq reset_time 14))

(def_char SWITCH_DELAY
  (funs (ai_fun switch_delay_ai)
	(reload_fun lower_reload)
	(constructor switch_delay_cons))
  (vars reset_time)
  (fields ("reset_time" switch_reset))
  (range 0 0)
  (states "art/misc.spe"
	  (stopped '("switch_off1" "switch_off2"))
	  (running '("switch_on1"  "switch_on2"))))



(defun switch_delay_ai ()
  (select (aistate)
	  (0      ; waiting for player to press, then turn to on
	   (next_picture)
	   (if (and (< (distx) 20) (< (disty) 30) (with_object (bg) (pressing_action_key)))
	       (progn
		 (print (random 1000))
		 (play_sound SWITCH_SND 127 (x) (y))
		 (set_state running)
		 (set_aistate 1))))
	  (1     ; wait for player to let go of button
	   (if (not (with_object (bg) (pressing_action_key)))
	       (set_aistate 2)))
	  (2     ; wait for reset time
	   (if (> (state_time) reset_time)
	       (progn
		 (play_sound SWITCH_SND 127 (x) (y))
		 (set_state stopped)
		 (set_aistate 0)))))
T)


(defun switch_mover_ai ()
  (if (> (total_objects) 1)
      (select (aistate)
	      (0 (if (not (eq (with_object (get_object 0) (aistate)) 0))
		     (let ((mex (x))
			   (mey (y)))
		       (if (eq (xvel) 0)
			   (progn
			     (with_object (get_object 1)
					  (progn
					    (set_x mex)
					    (set_y mey)
					    (set_fade_count 15)
					    ))
			     (set_aistate 1)
			     T)
			 (with_object (get_object 1)
				      (progn
					(set_x mex)
					(set_y mey)
					nil))))
		   T))
	      (1 (let ((count (with_object (get_object 1) (fade_count))))
		   (if (equal count 0)
		       nil
		     (progn
		       (with_object (get_object 1) (set_fade_count (- count 1)))
		       T)))))

    nil))

(def_char SWITCH_MOVER
  (funs (ai_fun   switch_mover_ai)
	(draw_fun dev_draw))
  (range 0 0)
  (states "art/misc.spe" (stopped "switch_mover")))



(defun sensor_cons ()
  (set_aitype 1)
  (add_hp -10))


/* -- compiled code
(defun sensor_ai ()
  (if (eq (aistate) 0)
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	  (progn
	    (if (eq (hp) 0)  ;; don't time out
		(set_aistate 1)
	      (set_aistate (hp)))
	    (set_state blocking))
	(set_state stopped))

	(if (eq (hp) 0)
	    (if (or (> (distx) (xacel)) (> (disty) (yacel)))
		(set_aistate 0))
	  (set_aistate (- (aistate) 1))))
T) */

(defun sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 0 255 0)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c))

	(let ((x1 (- (x) (xacel)))
	      (y1 (- (y) (yacel)))
	      (x2 (+ (x) (xacel)))
	      (y2 (+ (y) (yacel)))
	      (c  (find_rgb 255 0 0)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))


    nil))

(defun sensor_ct ()
  (select (aitype)
	  (1 (set_xvel 50)
	     (set_yvel 50)
	     (set_xacel 100)
	     (set_yacel 100))
	  (2 (set_xvel 50)
	     (set_yvel 30)
	     (set_xacel 100)
	     (set_yacel 50))
	  (3 (set_xvel 50)
	     (set_yvel 15)
	     (set_xacel 100)
	     (set_yacel 30))))

(def_char SENSOR
  (range 100 100)
  (funs (ai_fun      sensor_ai)
	(draw_fun    sensor_draw)
	(type_change_fun sensor_ct)
	(constructor sensor_cons))
  (vars unoffable)
  (fields ("xvel"        sens_onxd)
	   ("yvel"       sens_onyd)
	   ("xacel"      sens_offxd)
	   ("yacel"      sens_offyd)
	   ("hp"         sens_reset)
	   ("unoffable"  sens_unoff)
	   ("aistate"    sens_cs))
  (states "art/misc.spe"
	  (stopped "off")
	  (blocking "on")))

/*
(defun sensor_linker_ai ()
  (if (eq (aistate) 0)
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	  (progn
	    (if (eq (hp) 0)  ;; don't time out
		(set_aistate 1)
	      (set_aistate (hp)))
	    (set_state blocking))
	(set_state stopped))

    (if (eq (hp) 0)
	(if (or (> (distx) (xacel)) (> (disty) (yacel)))
	    (set_aistate 0))
      (set_aistate (- (aistate) 1)))))



(def_char SENSOR_LINKER
  (range 100 100)
  (funs (ai_fun sensor_linker_ai)
	(draw_fun sensor_draw)
	(constructor sensor_cons))
  (vars offable)
  (fields  ("xvel"      sens_onxd)
	   ("yvel"      sens_onyd)
	   ("xacel"     sens_offxd)
	   ("yacel"     sens_offyd)
	   ("hp"        sens_reset)
	   ("unoffable" sens_unoff)
	   ("aistate"   sens_cs))
  (states "art/misc.spe"
	  (stopped "off")
	  (blocking "on")))

*/

(defun dead_object (current)
  (if (>= current 0)
      (let ((st (with_object (get_object current) (state))))
	(if (or (eq st dead) (eq st blown_back_dead))
	    (let ((dead_guy (get_object current)))
	      (remove_object (get_object current))
	      dead_guy)
	  (dead_object (- current 1))))
    nil))

(defun death_re_ai ()
  (if (> (total_objects) 1)
      (let ((find (dead_object (- (total_objects) 1))))
	(if find
	    (add_object (with_object (get_object 0) (otype))
			(with_object find (x))
			(with_object find (y))))))

  T)

(def_char  DEATH_RESPAWNER
  (range 50 50)
  (funs (ai_fun      death_re_ai)
	(draw_fun    dev_draw))
  (states "art/misc.spe"
	  (stopped "death_respawn")))


(defun death_sen_ai ()
  (if (eq (total_objects) 0)
      (progn
	(set_state running)
	(set_aistate 1))
    (if (with_object (get_object 0) (or (eq (state) dead) (eq (state) blown_back_dead)))
	(remove_object (get_object 0))))
  T)

(def_char  DEATH_SENSOR
  (range 50 50)
  (funs (ai_fun      death_sen_ai)
	(draw_fun    dev_draw))
  (states "art/misc.spe"
	  (stopped "death_sensor0")
	  (running "death_sensor1")))


