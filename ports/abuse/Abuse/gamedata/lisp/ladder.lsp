;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;; XXX: Mac Abuse reimplements this in C++
(defun latter_check_area (first)
  (if first
      (progn
	(if (and (<= (x) (with_object first (x)))
		 (<= (y) (with_object first (y)))
		 (>= (with_object (get_object 0) (x)) (with_object first (x)))
		 (>= (with_object (get_object 0) (y)) (with_object first (y))))
	    (let ((yd (- (with_object first (y)) (y))))
	      (if (eq (with_object first (state)) climbing)
		  (let ((newx (/ (+ (x) (with_object (get_object 0) (x))) 2)))
		    (with_object first (set_x newx))))
	      (with_object first (setq in_climbing_area yd))))
	(latter_check_area (next_focus first)))))

;; XXX: Mac Abuse reimplements this in C++
(defun latter_ai ()
  (if (> (total_objects) 0)
      (latter_check_area (first_focus)))
  T)

(def_char LADDER
  (funs (ai_fun   latter_ai)
	(draw_fun dev_draw))
  (range 50 800)
  (states "art/misc.spe" (stopped "latter")))

(defun step_ai ()
  (if (or (eq (total_objects) 0)
	   (with_object (get_object 0) (not (eq (aistate) 0))))
      (set_state stopped)
    (set_state running))
  T)

(def_char STEP
  (funs (ai_fun   step_ai))
  (flags (can_block T))
  (states "art/chars/step.spe"
	  (stopped "step")
	  (running "step_gone")))

