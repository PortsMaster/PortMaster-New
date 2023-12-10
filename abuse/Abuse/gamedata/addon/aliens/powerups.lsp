;; Copyright 1997 Mike Moss (tfirestorm@aol.com),  All Rights reserved
;; See read me for more details on usage rights
;; blah blah yackety smackety

;; New Power Up objects

(defun shlmp_ai ()
  (try_move 0 10)
  (next_picture)
  (if (touching_bg)
	(progn
	   (with_object (bg) (make_view_solid (find_rgb 255 255 255)))
	   (with_object (bg) (setq special_power SHLAMP_POWER))
	   (with_object (add_object_after SHLMP2 (x) (y)) (link_object (bg)))
	   (with_object (add_object_after WTW (x) (y)) (link_object (bg)))
	nil)
    T))

(def_char SHOULDER_LAMP
  (funs (ai_fun shlmp_ai))
  (range 20 20)
  (states "addon/aliens/aliens.spe" (stopped "shlamp")))

(defun shlmp2_ai ()
   (if (> (total_objects) 0)
      (progn
	(set_x (with_object (get_object 0) (x)))
	(set_y (with_object (get_object 0) (- (y) (/ (picture_height) 2) )))))
   (if (eq (total_lights) 1)
      (progn
	(set_light_x (get_light 0) (x))
	(set_light_y (get_light 0) (y)))
    nil)
  (if (not (eq (with_object (get_object 0) special_power) SHLAMP_POWER))
	(progn
	(if (eq (total_lights) 1)
	   (delete_light (get_light 0))) nil)
	T))

(defun slamp_cons ()
	(link_light (add_light 0 (x) (y) 1 100 0 0)))

(def_char SHLMP2
  (range 1000 1000)
  (flags (unlistable T))
  (funs  (ai_fun		shlmp2_ai)
	 (constructor	slamp_cons)
	 (draw_fun		dev_draw))
  (states "art/misc.spe"
	  (stopped           "lhold")))

(def_char WTW
  (range 1000 1000)
  (flags (unlistable T))
  (funs (draw_fun dev_draw))
  (states "art/misc.spe" (stopped "marker")))

