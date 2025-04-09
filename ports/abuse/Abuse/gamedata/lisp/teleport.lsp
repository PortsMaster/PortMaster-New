;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun other_door_opening ()
  (if (eq (total_objects) 0)
      nil
    (with_object (get_object 0)
		 (if (eq (otype) TP_DOOR)
		     (if (eq is_opening 0)
			 (if (and (< (distx) 100) (< (disty) 80))
			     T
			   nil)
		       T)
		   nil))))

(defun open_door ()

  (setq is_opening 1)
  (if (eq (current_frame) 4)
      (setq is_opening 0)
    (progn
      (if (eq (current_frame) 0)
	  (play_sound DOOR_UP 127 (x) (y)))
      (next_picture))))

(defun close_door ()
  (setq is_opening 0)
  (if (eq (current_frame) 0)
      nil
    (progn
      (if (eq (current_frame) 4)
	  (play_sound DOOR_DOWN 127 (x) (y)))
      (set_current_frame (- (current_frame) 1)))))


(defun tpd_ai ()     ;; teleporting door ai
  (if (or (and (< (distx) 100) (< (disty) 80))
	  (other_door_opening))
      (open_door)
    (close_door))

  (let ((player (bg)))
    (if (has_object player)
	(if (not (with_object player (pressing_action_key)))
	    (remove_object player))
      (if (and (< (distx) 20) (< (disty) 30) (with_object player (pressing_action_key))
	       (> (total_objects) 0))
	  (let ((otherx (with_object (get_object 0) (x)))
		(othery (with_object (get_object 0) (y))))
	    (with_object (get_object 0) (link_object player))
	    (with_object player (progn
				  (set_x otherx)
				  (set_y othery)))))))
T)


(defun tp_door_cons () (set_xvel -1))
(defun tp_door_draw () (set_ambient_light (bg) (xvel)) (draw))

(def_char TP_DOOR
  (range 0 0)
  (vars is_opening)
  (funs (ai_fun      tpd_ai)
	(constructor tp_door_cons)
	(reload_fun lower_reload)
	(draw_fun   tp_door_draw))
  (fields ("xvel"   tp_amb))
  (states "art/door.spe" (stopped (seq "door" 1 5))))

;; Teleporting door AI
(defun tpdi_ai ()
  (let ((player (bg)))
       (if (has_object player)
	   (if (not (with_object player (pressing_action_key)))
	       (remove_object player))
	   (if (and (< (distx) 15)
		    (< (disty) 20)
		    (with_object player (pressing_action_key))
		    (> (total_objects) 0))
	       (let ((otherx (with_object (get_object 0) (x)))
		     (othery (with_object (get_object 0) (y))))
		    (with_object (get_object 0) (link_object player))
		    (with_object player
		      (progn (set_x otherx) (set_y othery)))))))
  T)

(def_char TP_DOOR_INVIS
  (range 0 0)
  (funs (ai_fun tpdi_ai)
	(draw_fun dev_draw))
  (fields ("xvel" tp_amb))
  (states "art/misc.spe" (stopped "clone_icon")))

