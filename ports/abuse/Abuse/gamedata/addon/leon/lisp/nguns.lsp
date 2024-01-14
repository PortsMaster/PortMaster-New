(defun zap (zapdam zapspd x y angle)
	(with_object (add_object LASR_BULLET x y)
		      (progn
			(setq sgb_lifetime 10)
			(setq sgb_speed zapspd)
			(setq sgb_dam zapdam)
			(setq sgb_lastx (x))
			(setq sgb_lasty (y))
			(setq sgb_angle angle)
			(setq sgb_bright_color (find_rgb 255 245 235))
			(setq sgb_medium_color (find_rgb 150 145 140))
			(if creator
			    (progn
			      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
			      (link_object creator)))
			(sgun_ai)
			))
)

(defun fire_object (creator type x y angle target)
  (select type

	  (0 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 6)
					(setq sgb_speed 15)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)
					(setq sgb_bright_color (find_rgb 255 255 200))
					(setq sgb_medium_color (find_rgb 150 150 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  (1 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 40)
					(setq sgb_speed 6)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)

					(setq sgb_bright_color (find_rgb 255 128 64))
					(setq sgb_medium_color (find_rgb 255 0 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  (2 (with_object (add_object GRENADE x y)
			  (progn
			    (play_sound GRENADE_THROW 127 x y)
			    (set_course angle 20)
			    (if creator
				(progn
				  (link_object creator)
				  (set_xvel (+ (xvel) (with_object creator (xvel))))
				  (set_yvel (+ (yvel) (with_object creator (yvel))))
				  ))

			    (set_frame_angle 0 359 angle)
			    )))
	  (3 (with_object (add_object ROCKET x y)
			  (progn
			    (play_sound ROCKET_LAUNCH_SND 127 x y)
			    (set_aistate angle)
			    (if creator	(link_object creator))

			    (if (and target   ;; don't link if not in line of site
				     (can_see (x) (y)
					      (with_object target (x))
					      (with_object target (y)) nil))
					      (link_object target))

			    (set_frame_angle 0 359 angle)
			    (setq speed 5)
			    (if (and creator (with_object creator (isa_player)))
				(setq max_speed 14)
			      (setq max_speed 10))
			    (set_y (+ (y) (/ (picture_height) 2)))  ;; move down to match frame/pos
			    )))

	  (4 (with_object (add_object PLASMAGUN_BULLET x y)
				      (progn
					(play_sound PLASMA_SND 127 (x) (y))
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(if creator
					      (link_object creator))
					(set_course angle 200)
					(let ((old_x (x))
					      (old_y (y))
					      (bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))
					  (if (not (eq bx T))
					      (if (eq bx nil)
						  (add_object EXPLODE5 (- (x) (random 5))
							      (- (y) (random 5)) 0)
						(progn
						  (add_object EXPLODE3 (- (x) (random 5))
							      (- (y) (random 5)) 0)
						  (do_damage 10 bx (* (cos sgb_angle) 20)
							     (* (sin sgb_angle) 10)))))
					  (setq sgb_lastx (x))
					  (setq sgb_lasty (y))
					  (set_x old_x)
					  (set_y old_y))
					)))


	  (5 (with_object (add_object FIREBOMB x y)
			  (progn
			    (play_sound FIREBOMB_SND 127 (x) (y))
			    (set_course angle 20)
			    (if creator
				(progn
				  (link_object creator)
				  (set_yvel (+ (yvel) (with_object creator (yvel))))
				  )))))

	  (6 (with_object (add_object DFRIS_BULLET x y)
				      (progn
					(play_sound ROCKET_LAUNCH_SND 127 x y)
					(set_course angle 25)
					(set_aistate angle)
					(if creator
					      (link_object creator))
					(dfris_ai)
					)))

	  (7 (with_object (add_object LSABER_BULLET x y)
				      (progn
					(play_sound LSABER_SND 127 (x) (y))
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(if creator
					      (link_object creator))
					(set_course angle 45)
					(let ((bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))
					  (if (not (eq bx T))
					      (if (not (eq bx nil))
						  (do_damage 30 bx (* (cos sgb_angle) 20)
							     (* (sin sgb_angle) 10)))))
					)))


	  (9 (with_object (add_object STRAIT_ROCKET x y)
				      (progn
					(play_sound MGUN_SND 127 (x) (y))
					(if creator
					      (link_object creator))
					(set_aistate angle)
					(set_frame_angle 0 359 angle)
					(play_sound GRENADE_THROW 127 (x) (y)))))

	  (10 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 6)
					(setq sgb_speed 15)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)
					(setq sgb_bright_color (find_rgb 255 0 0))
					(setq sgb_medium_color (find_rgb 150 0 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  (11
	  (play_sound SHIP_ZIP_SND 127 (x) (y))
          (zap 8 18 x y angle)
	  )
	  (12
	  (play_sound SHIP_ZIP_SND 127 (x) (y))
          (zap 8 22 x y angle)
          (zap 8 22 x y (+ angle 14))
          (zap 8 22 x y (- angle 14))
	  )
	  (13
	  (play_sound SHIP_ZIP_SND 127 (x) (y))
          (zap 6 24 x y angle)
          (zap 6 20 x y (+ angle 15))
          (zap 6 20 x y (- angle 15))
          (zap 6 16 x y (+ angle 30))
          (zap 6 16 x y (- angle 30))
	  )
	  )
)

(defun las_ai ()
  (setq sgb_lastx (x))
  (setq sgb_lasty (y))
  (set_course sgb_angle sgb_speed)
  (if (eq sgb_lifetime 0)
      nil
    (let ((bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))  ; don't hit the guy who fired us.
      (setq sgb_lifetime (- sgb_lifetime 1))
      (if (eq bx T) T
	(progn
	  (setq sgb_lifetime 0)    ;; disappear next tick
	  (if (eq bx nil)
	      (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 0)
	    (progn
	      (add_object EXPLODE6 (- (x) (random 5)) (- (y) (random 5)) 0)
	      (do_damage sgb_dam bx (* (cos sgb_angle) 10) (* (sin sgb_angle) 10))))))
      T)))

(def_char LASR_BULLET
  (vars sgb_speed sgb_angle sgb_lastx sgb_lasty
	sgb_bright_color sgb_medium_color sgb_lifetime sgb_dam)
  (funs (ai_fun   las_ai)
	(user_fun sgun_ufun)
	(draw_fun sgun_draw))
  (range 10000 10000)
  (flags (unlistable T)
	 (add_front T))
  (states "art/misc.spe" (stopped  "sgun_bullet")))
