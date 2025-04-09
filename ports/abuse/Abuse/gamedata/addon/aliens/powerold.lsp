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

;; New Power Up code

(setf shlamp_image (def_image "addon/aliens/aliens.spe" "slmp_img"))

(enum 'NO_POWER
      'FAST_POWER
      'FLY_POWER
      'SNEAKY_POWER
      'HEALTH_POWER
      'SHLAMP_POWER)

(defun give_player_health (amount)
  (let ((h_amount  (select difficulty
			   ('easy    amount)
			   ('medium  (/ (* amount 3) 4))
			   ('hard    (/ amount 2))
			   ('extreme (/ amount 5))))
	(h_max (if (or (eq special_power HEALTH_POWER))
		   200
		 100)))
    (if (eq (hp) h_max)
	nil
      (progn
	(if (<= (+ (hp) h_amount) h_max)
	    (add_hp h_amount)
	  (add_hp (- h_max (hp))))
	(setq b_ramp (+ b_ramp (* h_amount 2)))
	T))))

(setq sec1 0)
(setq sec2 0)
(setq sec3 0)
(setq min1 0)
(setq min2 0)

(setq ani_reg 0)

(defun bottom_draw ()
  (if (not (and (eq r_ramp 0)    ;; need to draw red palette
		(eq g_ramp 0)
		(eq b_ramp 0)))
      (progn
	(if (> r_ramp 7)
	    (setq r_ramp (- r_ramp 7))
	  (if (< r_ramp -7)
	      (setq r_ramp (+ r_ramp 7))
	    (setq r_ramp 0)))
	(if (> g_ramp 7)
	    (setq g_ramp (- g_ramp 7))
	  (if (< g_ramp -7)
	      (setq g_ramp (+ g_ramp 7))
	    (setq g_ramp 0)))
	(if (> b_ramp 7)
	    (setq b_ramp (- b_ramp 7))
	  (if (< b_ramp -7)
	      (setq b_ramp (+ b_ramp 7))
	    (setq b_ramp 0)))
	(if (local_player)
	    (tint_palette r_ramp g_ramp b_ramp))))

  (select (aistate)
	  (NORMAL_PLAY
	(if (eq ani_reg 24)
		(setq ani_reg 1)
		(setq ani_reg (+ ani_reg 1)))

	(setq sec1 (+ sec1 1))
	(if (eq sec1 10)
		(progn
		(setq sec2 (+ sec2 1))
		(setq sec1 0)))
	(if (eq sec2 10)
		(progn
		(setq sec3 (+ sec3 1))
		(setq sec2 0)))
	(if (eq sec3 6)
		(progn
		(setq min1 (+ min1 1))
		(setq sec3 0)))
	(if (eq min1 10)
		(progn
		(setq min2 (+ min2 1))
		(setq min1 0)))
	(if (eq min2 10)
		(setq min2 0))
	   (select special_power
		   (NO_POWER (player_draw (player_number)))
		   (HEALTH_POWER (player_draw (player_number))
				 (if (local_player)
				     (put_image (- (view_x2) 20) (+ (view_y1) 5) health_image)))
		   (FAST_POWER (draw_fast) (player_draw (player_number)))
		   (FLY_POWER  (player_draw (player_number))
				(if (local_player)
				    (put_image (- (view_x2) 20) (+ (view_y1) 5) fly_image)))
		   (SNEAKY_POWER
		    (if (local_player)
			(put_image (- (view_x2) 20) (+ (view_y1) 5) sneaky_image))
				 (sneaky_draw used_special_power (player_number)))
		   (SHLAMP_POWER (player_draw (player_number))
				 (if (local_player)
				     (put_image (- (view_x2) 20) (+ (view_y1) 5) shlamp_image)))
	  ))))
