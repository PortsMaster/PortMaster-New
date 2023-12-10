;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun switch_dim_ai ()
  (general_dim_ai '(if (> (total_objects) 0)
		       (not (eq (with_object (get_object 0) (aistate)) 0))
		     nil)
		  '(if (> (total_objects) 0)
		       (eq (with_object (get_object 0) (aistate)) 0)
		     nil)))


(defun dim_ai ()
  (general_dim_ai '(and (< (distx) (aitype)) (< (disty) 50)) '(> (distx) (xacel))))

(defun get_light_value ()
  (if (> (total_lights) 0)
      (light_r2 (get_light 0))
    (ambient_light (bg))))

(defun set_light_value (x)
  (if (> (total_lights) 0)
      (set_light_r2 (get_light 0) x)
    (set_ambient_light (bg) x)))

(defun general_dim_ai (activation_condition deactivation_condition)
      (select (aistate)
	      (0 (if (eval activation_condition)
		     (progn
		       (if (< (* (xvel) (direction)) 0)
			   (if (eq (yacel) 0)  ;; play sound effect?
			       (play_sound FADEON_SND 127 (x) (y))))
		       (go_state 1))
		   T))
	      (1 (if (> (state_time) (yvel))
		     (go_state 2)
		   (set_light_value (- (get_light_value) (* (xvel) (direction))))))
	      (2 (progn
		   (if (> (total_objects) 0)
		       (with_object (get_object 0) (set_aistate 1))
		     nil)
		   (set_aistate 3)
		   T))
	      (3 (if (eval deactivation_condition)
		     (progn
		       (if (> (* (xvel) (direction)) 0)
			   (if (eq (yacel) 0)  ;; play sound effect?
			       (play_sound FADEON_SND 127 (x) (y))))
		       (go_state 4))
		   T))
	      (4 (if (> (state_time) (yvel))
		     (go_state 5)
		   (set_light_value (+ (get_light_value) (* (xvel) (direction))))))
	      (5 (progn
		   (if (> (total_objects) 0)
		       (with_object (get_object 0) (set_aistate 4))
		     nil)
		   (set_aistate 0)
		   T))
	      )
    T)

(defun dim_cons () (set_xvel 20) (set_yvel 5))


(def_char DIMMER
  (funs (ai_fun      dim_ai)
	(draw_fun    dev_draw)
	(constructor dim_cons))
  (flags (unlistable T))
  (fields  ("aistate"    ai_state)
           ("xvel"       dimmer_step_amount)
	   ("yvel"       dimmer_steps)
	   ("aitype"     dimmer_dist)
	   ("xacel"      dimmer_dedist)
	   ("yacel"      dimmer_silent))
  (states "art/misc.spe"
	 (stopped  "dim")))



(def_char SWITCH_DIMMER
  (funs (ai_fun      switch_dim_ai)
	(draw_fun    dev_draw)
	(constructor dim_cons))
  (fields  ("aistate"   ai_state)
           ("xvel"      dimmer_step_amount)
	   ("yvel"      dimmer_steps)
	   ("yacel"     dimmer_silent))
  (states "art/misc.spe"  (stopped "dim")))

