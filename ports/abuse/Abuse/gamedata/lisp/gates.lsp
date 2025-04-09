;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun delay_ai ()
  (if (> (xvel) 0)
      (progn
	(set_xvel (- (xvel) 1))
	(if (eq (xvel) 0)
	    (if (eq (state) stopped)
		(progn
		  (set_aistate 1)
		  (set_state on_state))
	      (progn
		(set_state stopped)
		(set_aistate 0)))))
    (if (> (total_objects) 0)
	(if (eq (eq (aistate) 0) (eq (with_obj0 (aistate)) 0))
	  T
	(set_xvel delay_time))))
T)

(def_char GATE_DELAY
  (funs (ai_fun delay_ai)
	(draw_fun dev_draw))
  (vars delay_time)
  (fields ("delay_time" gate_delay_time)
	  ("aistate"    ai_state)
	  )
  (states "art/misc.spe"
	  (stopped "0_delay")
	  (on_state "1_delay")))


(def_char GATE_OR
  (funs (ai_fun or_ai)
	(draw_fun dev_draw))
  (states "art/misc.spe"
	  (stopped "0_or_gate")
	  (on_state "1_or_gate")))

(def_char GATE_AND
  (funs (ai_fun and_ai)
	(draw_fun dev_draw))
  (states "art/misc.spe"
	  (stopped "0_and_gate")
	  (on_state "1_and_gate")))


(def_char GATE_NOT
  (funs (ai_fun not_ai)
	(draw_fun dev_draw))
  (states "art/misc.spe"
	  (stopped "0_not_gate")
	  (on_state "1_not_gate")))


(def_char GATE_XOR
  (funs (ai_fun xor_ai)
	(draw_fun dev_draw))
  (states "art/misc.spe"
	  (stopped "0_xor_gate")
	  (on_state "1_xor_gate")))


(def_char GATE_PULSE
  (funs (ai_fun pulse_ai)
	(draw_fun dev_draw))
  (vars time_left pulse_speed)
  (fields ("pulse_speed" gate_pulse_speed))
  (states "art/misc.spe"
	  (stopped "0_pulse")
	  (on_state "1_pulse")))


(def_char INDICATOR
  (funs (ai_fun indicator_ai))
  (states "art/misc.spe"
	  (stopped "0_indicator")
	  (on_state "1_indicator")))

(defun indicator_ai ()
  (if (> (total_objects) 0)
      (if (eq (with_obj0 (aistate)) 0)
	  (progn
	    (set_state stopped)
	    (set_aistate 0))
	(progn
	  (set_state on_state)
	  (set_aistate 1)))) T)

(defun xor_check (last_object stat)
  (if (< last_object 0)
      stat
    (if (eq (with_object (get_object last_object) (aistate)) 0)
	(xor_check (- last_object 1) stat)
      (xor_check (- last_object 1) (not stat)))))

(defun xor_ai ()
  (if (xor_check (- (total_objects) 1) nil)
      (progn
	(set_state on_state)
	(set_aistate 1))
    (progn
      (set_state stopped)
      (set_aistate 0))) T)

(defun or_check (last_object)
  (if (< last_object 0)
      nil
    (if (eq (with_object (get_object last_object) (aistate)) 0)
	(or_check (- last_object 1))
      T)))

(defun or_ai ()
  (if (or_check (- (total_objects) 1))
      (progn
	(set_state on_state)
	(set_aistate 1))
    (progn
      (set_state stopped)
      (set_aistate 0))) T)


(defun and_check (last_object)
  (if (< last_object 0)
      T
    (if (eq (with_object (get_object last_object) (aistate)) 0)
	nil
      (and_check (- last_object 1)))))


(defun and_ai ()
  (if (and_check (- (total_objects) 1))
      (progn
	(set_state on_state)
	(set_aistate 1))
    (progn
      (set_state stopped)
      (set_aistate 0))) T)


(defun not_ai ()
  (if (> (total_objects) 0)
      (if (eq (with_obj0 (aistate)) 0)
	  (progn
	    (set_state on_state)
	    (set_aistate 1))
	(progn
	  (set_state stopped)
	  (set_aistate 0)))) T)

(defun pulse_ai ()
  (if (> (total_objects) 0)
      (if (not (eq (with_obj0 (aistate)) 0))
	  (if (eq time_left 0)
	      (if (eq (aistate) 0)
		  (progn
		    (setq time_left pulse_speed)
		    (set_state on_state)
		    (set_aistate 1))
		(progn
		  (set_state stopped)
		  (set_aistate 0)))
	    (setq time_left (- time_left 1)))))
  T)

