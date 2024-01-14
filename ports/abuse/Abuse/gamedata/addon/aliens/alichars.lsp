;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights
;;
;; Copyright 1997 Mike Moss (tfirestorm@aol.com),  All Rights reserved
;; See readme for more details on usage rights

;; Face Hugger

(defun no_fall_move (xm ym but)
  (move xm ym but)
  (if (not (eq (gravity) 0))         ;; if we are in the air don't check for no fall
      (move xm ym but)
    (let ((oldx (x))
	  (oldy (y))
          (ret (move xm ym but)))
      (if (try_move 0 5)
	  (progn
	    (set_x oldx)
	    (set_y oldy)
	    (set_xacel 0)
	    (set_state stopped)
	    (set_xv 0)
	    (set_gravity 0)
	    0))
	ret)))

(defun will_fall_if_jump ()
  (let ((dist (* (abs (get_ability jump_yvel)) (get_ability jump_xvel)))
	(oldx (x))
	(oldy (y))
	)
    (if (> (direction) 0)
	(set_x (+ (x) dist))
      (set_x (- (x) dist)))
    (if (try_move 0 5)
	(progn
	  (set_x oldx)
	  (set_y oldy)
	  T)
      (progn
	(set_x oldx)
	  (set_y oldy)
	nil))))


(defun alien_wait_time ()
  (select difficulty
	  ('easy    6)
	  ('medium  4)
	  ('hard    2)
	  ('extreme 1)))

(defun not_ali_congestion ()
  (if (> (direction) 0)
      (if (find_object_in_area (+ (x) 23) (- (y) 20) (+ (x) 30) (+ (y) 20) (list ALIEN_DRONE ALIEN_WARRIOR FACE_HUGGER))
	  nil
	T)
    (if (find_object_in_area (- (x) 30) (+ (y) 20) (- (x) 23) (+ (y) 20) (list ALIEN_DRONE ALIEN_WARRIOR FACE_HUGGER))
	nil
      T)))


(defun roof_above () (not (can_see (x) (y) (x) (- (y) 120) nil)))

(defun ali_dodge ()
  (if (eq need_to_dodge 1)
      (progn
	(setq need_to_dodge 0)
	(if (eq (random 2) 1)
	    (progn
	      (set_state stopped)
	      (go_state 6))         ;; jump at player
	    (progn
	      (set_yvel -12)  ;; long jump
	      (set_xvel (* (direction) 20))
	      (set_aistate 6)))
	T
    nil)))

(defun alscream_check ()
  (if (can_see (x) (y) (with_object (bg) (x)) (with_object (bg) (y)) nil)
      (progn
	(if (or (eq no_see_time 0) (> no_see_time 20))
	  (play_sound ALSCREAM_SND 127 (x) (y)))
	(setq no_see_time 1))
    (setq no_see_time (+ no_see_time 1))))

(defun al_char_draw ()
	(draw)
	(if (edit_mode)
	  (progn
	  (draw_line (x) (- (y) 9) (+ (x) 9) (- (y) 9) (find_rgb 255 0 0))
	  (draw_line (+ (x) 9) (- (y) 9) (+ (x) 9) (y) (find_rgb 255 0 0))
	  (draw_line (+ (x) 9) (y) (x) (y) (find_rgb 255 0 0))
	  (draw_line (x) (y) (x) (- (y) 9) (find_rgb 255 0 0)))))

(defun fh_ai ()
	(if (not (eq (aistate) 20))
	   (if (not (eq (aistate) 0))
      	(push_char 30 10)))
      (if (or (eq (state) flinch_up) (eq (state) flinch_down))
	  (progn (next_picture) T)
	(progn

	  (select (aistate)
		  (0   (if (eq hide_flag 0)
			   (set_aistate 15)
			 (set_aistate 1)))

		(15 ;; hiding
		   (set_state hiding)
		   (if (if (eq (total_objects) 0);; no sensor, wait for guy
			   (and (< (distx) 130) (< (y) (with_object (bg) (y))))
			 (not (eq (with_object (get_object 0) (aistate)) 0)))
		       (progn
			 (set_state fall_start)			 (set_direction (toward))
			 (set_aistate 1))))

		  (1 ;; falling down
		   (set_state falling)
		   (alscream_check)
		   (if (blocked_down (move 0 0 0))
		       (progn
			 (set_state landing)
			 (play_sound ALAND_SND 127 (x) (y))
			 (set_aistate 9))))

		  (9 ;; landing / turn around (general finish animation state)
		   (if (next_picture) T
		     (if (try_move 0 2)
			 (progn
			   (set_gravity 1)
			   (set_aistate 1))
		       (progn (set_state stopped)
			      (go_state 2)))))  ;; running

		  (2 ;; running
		   (alscream_check)
		   (if (eq (random 20) 0) (setq need_to_dodge 1))
		   (if (not (ali_dodge))
		     (if (eq (facing) (toward))
			 (progn
			   (next_picture)
			     (if (and (< (distx) 100) (> (distx) 10) (eq (random 5) 0))
				 (set_aistate 4)  ;; wait for pounce

			       (if (and (> (distx) 140)
					(not_ali_congestion)
					(not (will_fall_if_jump)))
				   (set_aistate 6)

				 (if (> (direction) 0)
				     (if (and (not_ali_congestion) (blocked_right (no_fall_move 1 0 0)))
					 (set_direction -1))
				   (if (and (not_ali_congestion) (blocked_left (no_fall_move -1 0 0)))
				       (set_direction 1))))))
			   (progn
			     (set_direction (toward))
			     (set_state turn_around)
			     (set_aistate 9)))))

		  (4 ;; wait for pounce
		   (if (ali_dodge) T
		     (progn
		       (set_state pounce_wait)
		       (move 0 0 0)
		       (if (> (state_time) (alien_wait_time))
			   (progn
			     (play_sound ALSLASH_SND 127 (x) (y))
			     (set_state stopped)
			     (go_state 6))))))

		  (6 ;; jump
		   (setq need_to_dodge 0)
		   (if (blocked_down (move (direction) -1 0))
		       (progn
			 (set_aistate 2))))
		  )))
   (if (eq (aistate) 20)
	(progn nil)
	(progn   T)))

(defun ali_damage (amount from hitx hity push_xvel push_yvel)

  (if (not (or (eq (state) dead)
	   (with_object from (or (eq (otype) FACE_HUGGER) (or (eq (otype) ALIEN_DRONE) (or (eq (otype) ALIEN_WARRIOR) (eq (otype) ALI_QUE)))))))
      (if (not (eq (aistate) 15))
	  (progn
	    (if (eq (random 2) 0)
		(set_state flinch_up)
	      (set_state flinch_down))
	    (damage_fun amount from hitx hity push_xvel push_yvel)
	    (play_sound ALPAIN_SND 127 (x) (y))
	    (setq need_to_dodge 1)
	    (if (<= (hp) 0)
		(progn
		  (play_sound (aref AL_DEATH (random 4)) 127 (x) (y))
		  (set_state dead)
		  (set_aistate 20)
			(if (eq (with_object (me) (otype)) ALIEN_DRONE)
			   (add_object DYING_AD (x) (y))
			   (if (eq (with_object (me) (otype)) ALIEN_WARRIOR)
				(add_object DYING_AW (x) (y))
				(if (eq (with_object (me) (otype)) ALI_QUE)
				     (add_object DYING_AQ (x) (y))
				     (if (eq (with_object (me) (otype)) FACE_HUGGER)
					(add_object DYING_FH (x) (y))))))
		  ))))))

(defun fh_cons ()
  (set_hp 15)
  (set_state hiding)
  (setq no_see_time 300))

(def_char FACE_HUGGER
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (fields
	  ("hide_flag"    "hidden? 0-Yes 1-No")
	  ("fade_count"   "fade")
	  ("aitype"       "aitype")
	  ("hp"           "health")
	  ("aistate"      "aistate"))
  (range 250 200)
  (draw_range 40 40)
  (funs (ai_fun		fh_ai)
	(draw_fun	al_char_draw)
	(constructor	fh_cons)
	(damage_fun		ali_damage))

  (abilities (run_top_speed   9)
	     (start_hp       20)
	     (stop_acel      14)
	     (start_acel     10)
	     (jump_yvel      -4)
	     (jump_xvel      14)
	     (push_xrange     1)
	     (jump_top_speed 15))

  (flags (hurtable  T)
	 (force_health T))

  (states "addon/aliens/aliens.spe"
	  (stopped		"fhwk0001.pcx")
	  (fall_start	"fhattack.pcx")
	  (falling		"fhattack.pcx")
	  (running		(seq "fhwk" 1 4))
	  (landing		"fhattack.pcx")
	  (pounce_wait	"fhwk0002.pcx")
	  (turn_around	(seq "fhtn" 1 3))
	  (run_jump		"fhattack.pcx")
	  (run_jump_fall	"fhattack.pcx")
	  (start_run_jump "fhattack.pcx")
	  (flinch_up 	"fhhit.pcx")
	  (flinch_down 	"fhattack.pcx")
	  (hiding         "hidden")
	  ))

(defun fh_egg_ai ()
   (try_move 0 10)
   (progn
	(if (eq (aistate) 0)
         (if (if (eq (total_objects) 0)
	      (and (< (distx) 70) (< (disty) 70))
	      (with_object (get_object 0) (not (eq (aistate) 0))))
	      (set_aistate 1))
	(select (current_frame)
	    (12 (set_current_frame 13)
	        (with_object (add_object_after FACE_HUGGER (+ (x) (* (toward) 20)) (y))
			    (progn
			      (set_aitype 0)
			      (set_direction (toward))
			      (set_state run_jump)
			      (set_aistate 6)))
	       )
	    (0 (next_picture)
		 (play_sound EGGH_SND 127 (x) (y)))
	    (1 (next_picture))
	    (2 (next_picture))
	    (3 (next_picture))
	    (4 (next_picture))
	    (5 (next_picture))
	    (6 (next_picture))
	    (7 (next_picture))
	    (8 (next_picture))
	    (9 (next_picture))
	    (10 (next_picture))
	    (11 (next_picture))
	)))
  T)


(def_char FACE_HUGGER_EGG
  (funs (ai_fun fh_egg_ai))
  (range 250 0)
  (states "addon/aliens/aliens.spe"
	  (stopped		(seq "eggh" 0 13))))

(defun dying_ai ()
	(try_move 0 10)
	(next_picture))

(def_char DYING_FH
  (flags (unlistable T))
  (funs (ai_fun dying_ai))
  (states "addon/aliens/aliens.spe"
	 (stopped (seq "fhdi" 2 11))))

(def_char FACE_HUGGER_EGG_HATCHED
  (funs (ai_fun fh_d_egg_ai))
	(states "addon/aliens/aliens.spe"
	 (stopped "eggh0013.pcx")))

(def_char FACE_HUGGER_EGG_UNHATCHED
  (funs (ai_fun fh_d_egg_ai))
	(states "addon/aliens/aliens.spe"
	 (stopped "eggunh.pcx")))

(defun fh_d_egg_ai ()
	(progn
	(try_move 0 10)
	(lower)))

(def_char FACE_HUGGER_JAR_DEAD
  (funs (ai_fun d_fh_jar_ai))
	(states "addon/aliens/aliens.spe"
	 (stopped "afhj0001.pcx")))

(defun d_fh_jar_ai ()
	(progn
	(lower)))

(def_char FACE_HUGGER_JAR_ALIVE
   (funs (ai_fun a_fh_jar_ai)
	(damage_fun		jar_damage))
   (flags (hurtable  T))
   (states "addon/aliens/aliens.spe"
	 (stopped (seq "afhj" 1 2))
	 (escaped "fhjexplo.pcx")))

(defun jar_damage ()
	(if (eq (aistate) 0)
	   (progn
	   (play_sound JBRK_SND 127 (x) (y))
	   (set_aistate 1)
	   (set_state escaped)
		)))

(defun a_fh_jar_ai ()
  (if (eq (aistate) 0)
	(progn
	   (lower)
	   (if (and (eq (current_frame) 0) (eq (random 20) 0))
		(progn
		(next_picture))
		(progn
		(set_current_frame 0)))
	)
	(if (eq (aistate) 1)
	    (progn
		(add_object EXPLODE1 (x) (- (y) 10))
	       (with_object (add_object_after FACE_HUGGER (x) (y))
			    (progn
			      (set_aitype 0)
			      (set_direction (toward))
			      (set_yvel 2)
			      (set_state falling)
			      (set_aistate 1)))
		(set_aistate 2)
	)))
  T)

;; Alien Drone

(defun ad_dodge ()
  (if (eq need_to_dodge 1)
      (progn
	(setq need_to_dodge 0)
	(if (eq (random 2) 1)
	    (progn
	      (set_state stopped)
	      (go_state 6))         ;; jump at player
	  (if (roof_above)
	      (progn
		(set_yvel -17)  ;; jump up
		(set_xvel 0)
		(go_state 12))
	    (progn
	      (set_yvel -12)  ;; long jump
	      (set_xvel (* (direction) 20))
	      (set_aistate 6))))
	T
    nil)))

(defun can_hit_player ()
  (let ((firex (+ (x) (* (direction) 15)) )
	(firey (- (y) 15))
	(playerx (with_object (bg) (x)))
	(playery (- (with_object (bg) (y)) 15)))
    (can_see firex firey playerx playery nil)))

(defun ali_fire_at_player ()
  (let ((firex (+ (x) (* (direction) 15)) )
	(firey (- (y) 15))
	(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 8))))
	(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))

    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
	(progn
	  (let ((angle (atan2 (- firey playery)
			      (- playerx firex))))
	    (fire_object (me) 50 firex firey angle (bg))
	    (set_state weapon_fire))

	  ))))

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

	  (50 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ALSLASH_SND 127 (x) (y))
					(setq sgb_lifetime 6)
					(setq sgb_speed 15)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)
					(setq sgb_bright_color (find_rgb 170 210 50))
					(setq sgb_medium_color (find_rgb 120 180 70))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  ))

(defun ad_ai ()
	(if (not (eq (aistate) 20))
	   (if (not (eq (aistate) 0))
      	(push_char 30 20)))
      (if (or (eq (state) flinch_up) (eq (state) flinch_down))
	  (progn (next_picture) T)
	(progn

	  (select (aistate)
		  (0   (if (eq hide_flag 0)
			   (set_aistate 15)
			 (set_aistate 1)))

		(15 ;; hiding
		   (set_state hiding)
		   (if (eq (random 200) 0)
			     (play_sound ALTAUNT_SND 127 (x) (y)))
		   (if (if (eq (total_objects) 0);; no sensor, wait for guy
			   (and (< (distx) 130) (< (y) (with_object (bg) (y))))
			 (not (eq (with_object (get_object 0) (aistate)) 0)))
		       (progn
			 (set_state fall_start)			 (set_direction (toward))
			 (set_aistate 1))))

		  (1 ;; falling down
		   (set_state falling)
		   (alscream_check)
		   (if (blocked_down (move 0 0 0))
		       (progn
			 (set_state landing)
			 (play_sound ALAND_SND 127 (x) (y))
			 (set_aistate 9))))

		  (9 ;; landing / turn around (general finish animation state)
		   (if (next_picture) T
		     (if (try_move 0 2)
			 (progn
			   (set_gravity 1)
			   (set_aistate 1))
		       (progn (set_state stopped)
			      (go_state 2)))))  ;; running

		  (2 ;; running
		   (alscream_check)
		   (if (eq (random 20) 0) (setq need_to_dodge 1))
		   (if (not (ad_dodge))
		     (if (eq (facing) (toward))
			 (progn
			   (next_picture)
			   (if (and (eq (random 15) 0) (< (distx) 180) (< (disty) 100) (can_hit_player))
			       (progn
				 (set_state weapon_fire)
				 (set_aistate 8))  ;; fire at player
			     (if (and (< (distx) 100) (> (distx) 10) (eq (random 5) 0))
				 (set_aistate 4)  ;; wait for pounce

			       (if (and (> (distx) 140)
					(not_ali_congestion)
					(not (will_fall_if_jump)))
				   (set_aistate 6)

				 (if (> (direction) 0)
				     (if (and (not_ali_congestion) (blocked_right (no_fall_move 1 0 0)))
					 (set_direction -1))
				   (if (and (not_ali_congestion) (blocked_left (no_fall_move -1 0 0)))
				       (set_direction 1)))))))
			   (progn
			     (set_direction (toward))
			     (set_state turn_around)
			     (set_aistate 9)))))

		  (4 ;; wait for pounce
		   (if (ad_dodge) T
		     (progn
		       (set_state pounce_wait)
		       (move 0 0 0)
		       (if (> (state_time) (alien_wait_time))
			   (progn
			     (play_sound ALSLASH_SND 127 (x) (y))
			     (set_state stopped)
			     (go_state 6))))))

		  (6 ;; jump
		   (setq need_to_dodge 0)
		   (if (blocked_down (move (direction) -1 0))
		       (progn
			 (set_aistate 2))))

		  (8 ;; fire at player
		   (if (ad_dodge) T
		     (if (eq (state) fire_wait)
			 (if (next_picture)
			     T
			   (progn
			     (ali_fire_at_player)
			     (set_state stopped)
			     (set_aistate 2)))
		       (set_state fire_wait))))

		  (12 ;; jump to roof
		   (setq need_to_dodge 0)
		   (set_state jump_up)
		   (set_yvel (+ (yvel) 1))
		   (set_xacel 0)
		   (let ((top (- (y) 21))
			 (old_yvel (yvel))
			 (new_top (+ (- (y) 21) (yvel))))
		     (let ((y2 (car (cdr (see_dist (x) top (x) new_top)))))
		       (try_move 0 (- y2 top) nil)
		       (if (not (eq y2 new_top))
			   (if (> old_yvel 0)
			     (progn
			       (set_state stopped)
			       (set_aistate 2))
			   (progn
			     (set_state top_walk)
			     (set_aistate 13)))))))

		  (13 ;; roof walking
		   (alscream_check)
		   (if (or (and (< (y) (with_object (bg) (y)))
				(< (distx) 10) (eq (random 8) 0))
			   (eq need_to_dodge 1))  ;; shooting at us, fall down
		       (progn
			 (set_gravity 1)
			 (set_state run_jump)
			 (go_state 6))
		     (progn
		       (if (not (eq (facing) (toward)))        ;; run toward player
			   (set_direction (- 0 (direction))))
		       (if (and (< (distx) 120) (eq (random 15) 0))
			   (progn
			     (set_state ceil_fire)
			     (go_state 14))
			 (let ((xspeed (if (> (direction) 0) (get_ability run_top_speed)
					 (- 0 (get_ability run_top_speed)))))
			   (if (and (can_see (x) (- (y) 21) (+ (x) xspeed) (- (y) 21) nil)
				    (not (can_see (+ (x) xspeed) (- (y) 21)
						  (+ (x) xspeed) (- (y) 22) nil)))
			       (progn
				 (set_x (+ (x) xspeed))
				 (if (not (next_picture))
				     (set_state top_walk)))
			     (set_aistate 1)))))))

		  (14 ;; cieling shoot
		   (if (next_picture)
		       T
		     (progn
		       (ali_fire_at_player)
		       (set_state top_walk)
		       (set_aistate 13))))
		  )))
   (if (eq (aistate) 20)
	(progn nil)
	(progn   T)))

(defun ad_cons ()
  (set_hp 35)
  (set_state hiding)
  (setq no_see_time 300))

(def_char ALIEN_DRONE
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (fields
	  ("hide_flag"    "hidden? 0-Yes 1-No")
	  ("fade_count"   "fade")
	  ("aitype"       "aitype")
	  ("hp"           "health")
	  ("aistate"      "aistate"))
  (range 250 200)
  (draw_range 40 40)
  (funs (ai_fun     ad_ai)
	(draw_fun	al_char_draw)
	(constructor ad_cons)
	(damage_fun ali_damage))

  (abilities (run_top_speed   7)
	     (start_hp       20)
	     (stop_acel      12)
	     (start_acel     9)
	     (jump_yvel      -4)
	     (jump_xvel      16)
	     (push_xrange     2)
	     (jump_top_speed 16))

  (flags (hurtable  T)
	 (force_health T))

  (states "addon/aliens/aliens.spe"
	  (fall_start	"adrjf")
	  (falling		"adrjf")
	  (stopped 		"adpouncew")
	  (running		(seq "adrn" 1 4))
	  (landing 		"adrjf")
	  (pounce_wait 	"adpouncew")
	  (turn_around 	(seq "adtn" 1 3))
	  (run_jump 	"adjump")
	  (run_jump_fall 	"adrjf")
	  (start_run_jump "adsrj")
	  (top_walk  	(seq "adcr" 1 4))
	  (flinch_up 	"adsrj")
	  (flinch_down 	"adrjf")
	  (jump_up        "adjump")
	  (hiding         "hidden")
	  (dead           "hidden")
	  (fire_wait	"adjump")
	  (ceil_fire	"adcr0004.pcx")
	  (weapon_fire	"adsrj")
	))

(def_char DYING_AD
  (flags (unlistable T))
  (funs (ai_fun dying_ai))
  (states "addon/aliens/aliens.spe"
	 (stopped (seq "addi" 1 10))))


;; Alien Warrior

(defun aw_ai ()
	(if (not (eq (aistate) 20))
	   (if (not (eq (aistate) 0))
      	(push_char 30 20)))
      (if (or (eq (state) flinch_up) (eq (state) flinch_down))
	  (progn (next_picture) T)
	(progn

	  (select (aistate)
		  (0   (if (eq hide_flag 0)
			   (set_aistate 15)
			 (set_aistate 1)))

		(15 ;; hiding
		   (set_state hiding)
		   (if (and (< (distx) 200) (eq (random 50) 50))
			     (play_sound ALTAUNT_SND 127 (x) (y)))
		   (if (if (eq (total_objects) 0);; no sensor, wait for guy
			   (and (< (distx) 130) (< (y) (with_object (bg) (y))))
			 (not (eq (with_object (get_object 0) (aistate)) 0)))
		       (progn
			 (set_state fall_start)			 (set_direction (toward))
			 (set_aistate 1))))

		  (1 ;; falling down
		   (set_state falling)
		   (alscream_check)
		   (if (blocked_down (move 0 0 0))
		       (progn
			 (set_state landing)
			 (play_sound ALAND_SND 127 (x) (y))
			 (set_aistate 9))))

		  (9 ;; landing / turn around (general finish animation state)
		   (if (next_picture) T
		     (if (try_move 0 2)
			 (progn
			   (set_gravity 1)
			   (set_aistate 1))
		       (progn (set_state stopped)
			      (go_state 2)))))  ;; running

		  (2 ;; running
		   (alscream_check)
		   (if (eq (random 20) 0) (setq need_to_dodge 1))
		   (if (not (ali_dodge))
		     (if (eq (facing) (toward))
			 (progn
			   (next_picture)
			   (if (and (eq (random 25) 0) (< (distx) 180) (< (disty) 100) (can_hit_player))
			       (progn
				 (set_state weapon_fire)
				 (set_aistate 8))  ;; fire at player
			     (if (and (< (distx) 100) (> (distx) 10) (eq (random 5) 0))
				 (set_aistate 4)  ;; wait for pounce

			       (if (and (> (distx) 140)
					(not_ali_congestion)
					(not (will_fall_if_jump)))
				   (set_aistate 6)

				 (if (> (direction) 0)
				     (if (and (not_ali_congestion) (blocked_right (no_fall_move 1 0 0)))
					 (set_direction -1))
				   (if (and (not_ali_congestion) (blocked_left (no_fall_move -1 0 0)))
				       (set_direction 1)))))))
			   (progn
			     (set_direction (toward))
			     (set_state turn_around)
			     (set_aistate 9)))))

		  (4 ;; wait for pounce
		   (if (ali_dodge) T
		     (progn
		       (set_state pounce_wait)
		       (move 0 0 0)
		       (if (> (state_time) (alien_wait_time))
			   (progn
			     (play_sound ALSLASH_SND 127 (x) (y))
			     (set_state stopped)
			     (go_state 6))))))

		  (6 ;; jump
		   (setq need_to_dodge 0)
		   (if (blocked_down (move (direction) -1 0))
		       (progn
			 (set_aistate 2))))

		  (8 ;; fire at player
		   (if (ad_dodge) T
		     (if (eq (state) fire_wait)
			 (if (next_picture)
			     T
			   (progn
			     (ali_fire_at_player)
			     (set_state stopped)
			     (set_aistate 2)))
		       (set_state fire_wait))))
		  )))
   (if (eq (aistate) 20)
	(progn nil)
	(progn   T)))

(defun aw_cons ()
  (set_hp 80)
  (set_state hiding)
  (setq no_see_time 300))

(def_char ALIEN_WARRIOR
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (fields
	  ("hide_flag"    "hidden? 0-Yes 1-No")
	  ("fade_count"   "fade")
	  ("aitype"       "aitype")
	  ("hp"           "health")
	  ("aistate"      "aistate"))
  (range 250 200)
  (draw_range 40 40)
  (funs (ai_fun     aw_ai)
	(draw_fun	al_char_draw)
	(constructor aw_cons)
	(damage_fun ali_damage))

  (abilities (run_top_speed   5)
	     (start_hp       20)
	     (stop_acel      11)
	     (start_acel     8)
	     (jump_yvel      -2)
	     (jump_xvel      8)
	     (push_xrange     2)
	     (jump_top_speed 12))

  (flags (hurtable  T)
	 (force_health T))

  (states "addon/aliens/aliens.spe"
	  (fall_start	"awrjf")
	  (falling		"awrjf")
	  (stopped		"awrn0001.pcx")
	  (running		(seq "awrn" 1 4))
	  (landing		"awrjf")
	  (pounce_wait	"awpouncew")
	  (turn_around	(seq "awtn" 1 3))
	  (run_jump		"awjump")
	  (run_jump_fall	"awrjf")
	  (start_run_jump "awsrj")
	  (flinch_up 	"awsrj")
	  (flinch_down 	"awrjf")
	  (jump_up        "awjump")
	  (hiding         "hidden")
	  (dead           "hidden")
	  (fire_wait	"awjump")
	  (weapon_fire	"awsrj")
	))

(def_char DYING_AW
  (flags (unlistable T))
  (funs (ai_fun dying_ai))
  (states "addon/aliens/aliens.spe"
	 (stopped (seq "awdi" 1 10))))

;; Old Alien speed settings, modified 6/28/00
;;  (abilities (run_top_speed   15)
	     ;; (start_hp       20)
	     ;; (stop_acel      20)
	     ;; (start_acel     20)
	     ;; (jump_yvel      -4)
	     ;; (jump_xvel      20)
	     ;; (push_xrange     1)
	     ;; (jump_top_speed 20))