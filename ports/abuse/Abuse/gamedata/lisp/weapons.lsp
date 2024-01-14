;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights


(defun mbullet_ai ()
  (if (> (state_time) 5)
      nil
    (let ((bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))  ; don't hit the guy who fired us.
      (if (eq bx T)
	  T
	(progn
	  (if (null bx)
	      (if (eq (random 2) 0)
		  (progn
		    (add_panim MGUN_HIT1 (x) (y) (direction))
		    (play_sound MG_HIT_SND1 127 (x) (y)))
		(progn
		  (add_panim MGUN_HIT2 (x) (y) (direction))
		  (play_sound MG_HIT_SND2 127 (x) (y))))
	    (progn
;	      (add_panim EXPLO2 (x) (y) (direction))
;	      (add_object EXP_LIGHT (x) (y) 80)
	      (do_damage 5 bx (if (> 0 (direction)) -10 10) 0)
	      ))
	  nil))))
)

(defun grenade_ai ()
  (if (and (eq (tick) 0)
	   (if (< (total_objects) 1)
	       nil
	     (let ((mex (x))
		   (mey (y)))
	       (not (with_object (get_object 0) (find_object_in_area (- mex 7)
								     (- mey 7)
								     (+ mex 7)
								     (+ mey 7) bad_guy_list))))))
      (progn (next_picture) T)
    (do_explo 40 36)))

(defun fb_draw () nil)   ;; only draw while in the air

(defun firebomb_ai ()

  (add_object EXPLODE1 (- (x) (random 5)) (+ (y) (random 20)) 0)
  (hurt_radius (x) (y) 60 40 (if (> (total_objects) 0) (get_object 0) nil) 10)

  (and (or (< (state_time) 3) (not (eq (xvel) 0)))
       (< (state_time) 20)
       (select (direction)
	      (1 (progn ;(set_xvel 30)
			(not (blocked_right (move 0 0 0)))
			))
	      (-1 (progn ;(set_xvel -30)
			 (not (blocked_left (move 0 0 0))))))))





(defun mbullet_ufun (creator)
  (set_direction (with_object creator (direction)))

  (let ((start (if (> (direction) 0) 335 155))
	(end   (if (> (direction) 0) 25 205)))
    (let ((target (with_object creator (find_object_in_angle start end bad_guy_list))))
      (if (and target (< (abs (- (x) (with_object target (x)))) 150)
	       (< (abs (- (y) (with_object target (y)))) 100))
	  (set_course (site_angle target) 50)
	(if (> (direction) 0)
	    (set_course 0 50)
	  (set_course 180 50)))))

  (link_object creator)
)


(defun firebomb_ufun (creator)
  (set_direction (with_object creator (direction)))
  (link_object creator)
)



(defun player_mine_ufun (creator)
  (set_x (with_object creator (x)))
  (set_y (with_object creator (y)))
  (link_object creator)
  (let ((me (me)))
    (with_object creator (link_object me)))
)

(defun player_mine_ai ()
  (select (aistate)
	  (0
	   ;; wait till no player (just in case), or player lets go of fire button
	   (if (or (eq 0 (total_objects))
		   (and (eq (with_object (get_object 0) (player_b1_suggest)) 0)
			(eq (with_object (get_object 0) (player_b2_suggest)) 0)))
	       (progn
		 (set_state blocking)
		 (set_aistate 1)
		 T)
	     T))
	  (1 (if (next_picture)
		 T
	       (do_explo 50 40)
	     ))))


(def_char MBULLET
  (funs (ai_fun     mbullet_ai)
	(draw_fun   dev_draw)     ; you can't see the bullets
	(user_fun   mbullet_ufun))
  (range 10000 10000)
  (flags (unlistable T))
  (states "art/misc.spe" (stopped "mbullet_icon")))


(defun grenade_ufun (creator)
  (set_direction (with_object creator (direction)))
  (play_sound GRENADE_THROW 127 (x) (y))
  (select (aitype)
	  (1 (progn (set_xvel (if (> (direction) 0)
				  (+ 13 (random 2))
				(+ -13 (random 2)))) (set_yvel -4)))
	  (2 (progn (set_xvel (if (> (direction) 0)
				  (+ 7 (random 2))
				(+ -7 (random 2)))) (set_yvel -10))))
  (set_xvel (+ (xvel) (with_object creator (xvel))))
  (link_object creator)
)

(defun grenade_cache (type)
  (list (list EXPLODE1 EXP_LIGHT)
	(list GRENADE_SND)))


(def_char GRENADE
  (funs (ai_fun   grenade_ai)
	(get_cache_list_fun grenade_cache)
	(user_fun grenade_ufun))
  (range 10000 10000)
  (flags (unlistable  T))
  (states "art/misc.spe" (stopped (seq "4gre" 1 8))))


(def_char FIREBOMB
  (funs (ai_fun   firebomb_ai)
	(user_fun firebomb_ufun)
	(get_cache_list_fun grenade_cache)
	(draw_fun fb_draw))
  (abilities (walk_top_speed  20)
	     (run_top_speed   20))
  (range 10000 10000)
  (flags (unlistable T))
  (states "art/misc.spe"
	  (stopped "firebomb")
	  (walking "firebomb")))

(defun giver (type)
  (let ((amount (get_ability start_hp)))
    (with_object (bg)
		 (progn
		   (if (and (not (has_weapon type)) change_on_pickup)
		       (progn
			 (give_weapon type)
			 (set_current_weapon type))
		     (give_weapon type))
		   (add_ammo type amount)))))


;; XXX: Mac Abuse reimplements this in C++
(defun weapon_icon_ai ()
  (if (eq0 (aistate))
      (if (activated)
	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))  ; if we are on the floor, don't check falling anymore
		(set_aistate 1))

	    (if (touching_bg)
		(progn
		  (play_sound AMMO_SND 127 (x) (y))
		  (select (otype)
			  (MBULLET_ICON5   (giver 0));; these numbers correspond to status bar position
			  (MBULLET_ICON20  (giver 0))
			  (GRENADE_ICON2   (giver 1))
			  (GRENADE_ICON10  (giver 1))

			  (ROCKET_ICON2    (giver 2))
			  (ROCKET_ICON5    (giver 2))

			  (FBOMB_ICON1     (giver 3))
			  (FBOMB_ICON5     (giver 3))

			  (PLASMA_ICON20   (giver 4))
			  (PLASMA_ICON50   (giver 4))

			  (LSABER_ICON50   (giver 5))
			  (LSABER_ICON100  (giver 5))

			  (DFRIS_ICON4     (giver 6))
			  (DFRIS_ICON10    (giver 6))

			  )

		  nil)
	      T))
	T)
    (if (touching_bg)
	(progn
	  (play_sound AMMO_SND 127 (x) (y))
	  (select (otype)
		  (MBULLET_ICON5   (giver 0));; these numbers correspond to status bar position
		  (MBULLET_ICON20  (giver 0))
		  (GRENADE_ICON2   (giver 1))
		  (GRENADE_ICON10  (giver 1))

		  (ROCKET_ICON2    (giver 2))
		  (ROCKET_ICON5    (giver 2))

		  (FBOMB_ICON1     (giver 3))
		  (FBOMB_ICON5     (giver 3))

		  (PLASMA_ICON20   (giver 4))
		  (PLASMA_ICON50   (giver 4))

		  (LSABER_ICON50   (giver 5))
		  (LSABER_ICON100  (giver 5))

		  (DFRIS_ICON4     (giver 6))
		  (DFRIS_ICON10    (giver 6))

		  )
	  nil)
      T)))

;; XXX: Mac Abuse reimplements this in C++
(defun on_draw ()
  (if (activated)
      (draw)
    (dev_draw)))

;; XXX: Mac Abuse reimplements this in C++
(defun ammo_cache (type)    ;; tells what other chars to load in with this character
  (list
   (select type
	   (GRENADE_ICON2    `(,GRENADE ,GRENADE_TOP))
	   (GRENADE_ICON10   `(,GRENADE ,GRENADE_TOP))
	   (MBULLET_ICON5    `(,SHOTGUN_BULLET ,MGUN_TOP))
	   (MBULLET_ICON20   `(,SHOTGUN_BULLET ,MGUN_TOP))
	   (ROCKET_ICON2     `(,ROCKET ,ROCKET_TOP))
	   (ROCKET_ICON5     `(,ROCKET ,ROCKET_TOP))
	   (FBOMB_ICON1      `(,FIREBOMB ,FIREBOMB_TOP))
	   (FBOMB_ICON5      `(,FIREBOMB ,FIREBOMB_TOP))

	   (PLASMA_ICON20    `(,PLASMAGUN_BULLET))
	   (PLASMA_ICON50    `(,PLASMAGUN_BULLET))

	   (LSABER_ICON50    `(,LSABER_BULLET ,PGUN_TOP))
	   (LSABER_ICON100   `(,LSABER_BULLET ,PGUN_TOP))

	   (DFRIS_ICON4      `(,DFRIS_BULLET ,DFRIS_TOP))
	   (DFRIS_ICON10     `(,DFRIS_BULLET ,DFRIS_TOP))
   nil)))

(defun make_ammo_icon (symbol icon_name increment)
  (eval (list 'def_char symbol
	      '(funs (ai_fun weapon_icon_ai)
		     (get_cache_list_fun ammo_cache)
		     (draw_fun on_draw))
	      '(range 5 5)
	      '(flags (add_front T))
	      `(abilities (start_hp ,increment))
	      `(states  "art/chars/ammo.spe" (stopped ,icon_name)))))

(make_ammo_icon 'GRENADE_ICON2  "grenade_small" 2 )
(make_ammo_icon 'GRENADE_ICON10 "grenade_large" 10)

(make_ammo_icon 'MBULLET_ICON5  "bullets_small"  5)
(make_ammo_icon 'MBULLET_ICON20 "bullets_large" 20)

(make_ammo_icon 'FBOMB_ICON1 "firebomb_small"   1)
(make_ammo_icon 'FBOMB_ICON5 "firebomb_large"   5)

(make_ammo_icon 'ROCKET_ICON2 "rocket_small"      2)
(make_ammo_icon 'ROCKET_ICON5 "rocket_large"      5)



(defun guner_cons ()
  (set_xvel 7)     ;; fire speed
  (set_yvel 50)    ;; speed of bullet
  (set_xacel 290)  ;; start angle
  (set_yacel 359)  ;; end angle
)


(defun guner_damage (amount from hitx hity push_xvel push_yvel)  ; transfer damage to lower half
  (if (not (eq (state) stopped))
      (progn
	(add_object EXPLODE3 (+ hitx (random 5)) (+ hity (random 5)) 0)
	(add_object EXPLODE2 (+ hitx (random 5)) (+ hity (random 5)) 2)
	(add_object EXPLODE3 (- hitx (random 5)) (- hity (random 5)) 1)
	(add_object EXPLODE3 (- hitx (random 5)) (- hity (random 5)) 2)

	(damage_fun amount from hitx hity 0 0)     ; don't allow pushing

	(if (<= (hp) 0)
	    (progn
	      (play_sound BLOWN_UP 127 (x) (y))
	      (add_object EXPLODE1 (- hitx (random 10)) (- hity (random 25)) 0)
	      (add_object EXPLODE1 (+ hitx (random 10)) (+ hity (random 25)) 1)
	      (add_object EXPLODE1 (- hitx (random 10)) (- hity (random 10)) 2)
	      (add_object EXPLODE1 (+ hitx (random 10)) (+ hity (random 10)) 3) ))))
)






(defun shot_ai () (eq (bmove nil) T))
(defun gun_ai ()
  (if (> (hp) 0)
      (progn
	(select (state)
		(stopped (if (> (state_time) (xvel))
			     (let ((a (site_angle (bg)))
				   (me (me))
				   (speed (yvel)))
			       (if (eq (aitype) 1)
				   (print a))        ;; show the angle for level designers
			       (if (and (>= a (xacel)) (<= a (yacel)) (if (> (direction) 0)
				       (set_frame_angle 290 0 a)
				     (set_frame_angle 180 250 a)))
				   (progn
				     (with_object (add_object VIS_SHOT
							      (+ (x) (* (cos a) 10))
							      (- (y) (+ 10 (* (sin a) 10))))
						  (progn
						    (play_sound MGUN_SND 127 (x) (y))
						    (set_course a speed)
						    (link_object me)))
					      (set_aistate (+ (aistate) 1))
					      (jump_state walking))))
			   nil))
		(walking (jump_state blocking))
		(blocking (jump_state stopped)))
	T)
    nil)
  )


(defun rocket_ai ()
  (if (not (frame_panic))
      (let ((rand (rand_on)))
	(with_object (add_object SMALL_LIGHT_CLOUD (+ (x) (random 3))
				 (- (y) (random 3) (/ (picture_height) 2)))
		     (set_fade_count 11))
	(set_rand_on rand)))

  (if (> (total_objects) 1)  ;; if not attached to object, just fly strait (0 is player)
    (let ((angle (atan2 (- (- (y) (with_object (get_object 1) (y))) -15)
			(- (with_object (get_object 1) (x)) (x) ))))
      (let ((clock_dist (if (< angle (aistate))          ;; calculate clockwise andle distance
			    (- (aistate) angle)
			  (+ (aistate) (- 360 angle)))))
	(let ((closest_dist (if (> clock_dist 180)
				(- 360 clock_dist)
			      clock_dist)))
	  (let ((angle_add (if (> closest_dist 23)
			       23
			     (if (< closest_dist 5)
				 0
			       closest_dist))))
	    (if (> clock_dist 180)     ;; should we steer clock wise or counter?
		(set_aistate (mod (+ (aistate) angle_add) 360))
	      (set_aistate (mod (+ (- (aistate) angle_add) 360) 360))) )))))

  (if (< speed max_speed)
      (setq speed (+ speed 2)))
  (set_course (aistate) speed)
  (set_frame_angle 0 359 (aistate))
  (if (or (eq (hp) 0)
	  (not (eq (bmove (if (> (total_objects) 0) (get_object 0) nil)) T))
	  (and (> (total_objects) 1)
	       (< (abs (- (with_object (get_object 1) (x)) (x) )) 10)
	       (< (abs (- (- (with_object (get_object 1) (y)) (y)) 15 )) 10)))
      (progn
	(do_explo 40 50)
	nil)
  T))


(defun rocket_ufun (creator)
  (link_object creator)
  (play_sound ROCKET_SND 127 (x) (y))

  (let ((target (with_object creator (find_object_in_area
				      (- (x) 160) (- (y) 160)
				      (+ (x) 160) (+ (y) 160) bad_guy_list))))
    (select (aitype)
	    (1 (set_aistate (if (> (with_object creator (direction)) 0) 0 180)))
	    (2  (set_aistate (if (> (with_object creator (direction)) 0) 45 135))))
    (if target (link_object target)))

)

(defun rocket_cache (type)
  (list (list SMALL_LIGHT_CLOUD) nil))

(def_char ROCKET
  (funs (ai_fun   rocket_ai)
	(get_cache_list_fun rocket_cache)
	(get_cache_list_fun grenade_cache)
	(user_fun rocket_ufun))
  (vars speed max_speed)
  (range 10000 10000)
  (flags (unlistable T)
	 (hurtable T)
	 (add_front T))
  (abilities (start_hp 4))
  (states "art/missle.spe" (stopped  (seq "miss" 1 32))))


/*
(defun sgun_ai ()
  (setq sgb_lastx (x))
  (setq sgb_lasty (y))
  (setq sgb_speed (/ (* sgb_speed 6) 5))
  (set_course sgb_angle sgb_speed)
  (if (eq sgb_lifetime 0)
      nil
    (let ((bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))  ; don't hit the guy who fired us.
      (setq sgb_lifetime (- sgb_lifetime 1))
      (if (eq bx T) T
	(progn
	  (setq sgb_lifetime 0)    ;; disappear next tick
	  (if (eq bx nil)
	      (add_object EXPLODE5 (- (x) (random 5)) (- (y) (random 5)) 0)
	    (progn
	      (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 0)
	      (do_damage 5 bx (* (cos sgb_angle) 10) (* (sin sgb_angle) 10))))))
      T)))
	*/


(defun sgun_draw ()
  (draw_line sgb_lastx (- sgb_lasty 1) (x) (- (y) 1) sgb_medium_color)
  (draw_line sgb_lastx (+ sgb_lasty 1) (x) (+ (y) 1) sgb_medium_color)

  (draw_line (- sgb_lastx 1) sgb_lasty (- (x) 1) (y) sgb_bright_color)
  (draw_line (+ sgb_lastx 1) sgb_lasty (+ (x) 1) (y) sgb_medium_color)


  (draw_line sgb_lastx sgb_lasty (x) (y) sgb_bright_color)
)


(defun sgun_ufun (creator)
  (set_direction (with_object creator (direction)))
  (set_y (- (y) 4))
  (set_x (+ (x) (* (direction) 20)))
  (play_sound ZAP_SND 127 (x) (y))
  (let ((start (if (> (direction) 0) 335 155))
	(end   (if (> (direction) 0) 25 205)))
    (setq sgb_speed 8)
    (setq sgb_lastx (x))
    (setq sgb_lasty (y))
    (let ((target (with_object creator (find_object_in_angle start end bad_guy_list))))
      (if (and target (< (abs (- (x) (with_object target (x)))) 150)
	       (< (abs (- (y) (with_object target (y)))) 100))
	  (setq sgb_angle (site_angle target))
	(if (> (direction) 0)
	    (setq sgb_angle 0)
	  (setq sgb_angle 180)))))
  (link_object creator)
)


(def_char SHOTGUN_BULLET
  (vars sgb_speed sgb_angle sgb_lastx sgb_lasty
	sgb_bright_color sgb_medium_color sgb_lifetime)
  (funs (ai_fun   sgun_ai)
	(user_fun sgun_ufun)
	(draw_fun sgun_draw))
  (range 10000 10000)
  (flags (unlistable T)
	 (add_front T))
  (states "art/misc.spe" (stopped  "sgun_bullet")))



(make_ammo_icon 'PLASMA_ICON20 "plasma_small"     20)
(make_ammo_icon 'PLASMA_ICON50 "plasma_large"     50)

(make_ammo_icon 'LSABER_ICON50  "lsaber_small"    50)
(make_ammo_icon 'LSABER_ICON100 "lsaber_large"   100)

(make_ammo_icon 'DFRIS_ICON4  "dfris_small"      4)
(make_ammo_icon 'DFRIS_ICON10 "dfris_large"     10)


(defun pgun_draw ()
  (let ((c (- 255 (* (state_time) 40))))
    (scatter_line sgb_lastx sgb_lasty (x) (y) (find_rgb c (/ c 2) c) (state_time))
    (scatter_line sgb_lastx sgb_lasty (x) (y) (find_rgb c (/ c 2) c) 0)
    ))



(defun pgun_ai ()
  (select (state_time)
	  (0 T)
	  (1 T)
	  (2 T)
	  (3 T)
	  (4 T)
	  (5 nil)))

(def_char PLASMAGUN_BULLET
  (vars sgb_angle sgb_lastx sgb_lasty)
  (funs (ai_fun   pgun_ai)
	(draw_fun pgun_draw))
  (range 10000 10000)
  (flags (unlistable T)
	 (add_front T))
  (states "art/misc.spe" (stopped  "sgun_bullet")))


(defun lsaber_ai ()
  (shift_rand_table (random 80))
  nil)


(defun lsaber_draw ()
  (let ((c1 (find_rgb 255 255 255))
	(c2 (find_rgb 70 59 67))
	(c3 (find_rgb 147 155 195)))


    (scatter_line sgb_lastx sgb_lasty (x) (y) c1 0)
    (scatter_line sgb_lastx sgb_lasty (x) (y) c3 2)
    (ascatter_line sgb_lastx sgb_lasty (x) (y) c1 c2 1)
  ))



(def_char LSABER_BULLET
  (vars sgb_angle sgb_lastx sgb_lasty)
  (funs (ai_fun   lsaber_ai)
	(draw_fun lsaber_draw))
  (range 10000 10000)
  (flags (unlistable T)
	 (add_front T))
  (states "art/misc.spe" (stopped  "sgun_bullet")))


(defun angle_diff (a1 a2)
  (if (< (abs (- a2 a1)) 180)
      (- a2 a1)
    (if (< a1 a2)
	(+ (- a1 a2) 180)
      (- (- a1 a2) 180))))


(defun get_fris_angle ()
  (let ((px (with_object (get_object 0) (player_pointer_x)))
	(py (with_object (get_object 0) (player_pointer_y))))
    (atan2 (- (y) py 4)
	   (- px (x)))))

(defun dfris_ai ()
  (if (and (eq 0 (mod (game_tick) 2)) (not (frame_panic)))
      (let ((rand (rand_on)))
	(with_object (add_object SMALL_LIGHT_CLOUD (+ (x) (random 3))
				 (- (y) (random 3) (/ (picture_height) 2)))
		     (set_fade_count 11))
	(set_rand_on rand)))
  (set_course (aistate) 12)
  (if (or (not (eq (bmove (if (> (total_objects) 0) (get_object 0) nil)) T))
	  (< (total_objects) 1)
	  (let ((mex (x))
		(mey (y)))
	    (with_object (get_object 0) (find_object_in_area (- mex 7)
							     (- mey 7)
							     (+ mex 7)
							     (+ mey 7) bad_guy_list))))
      (progn
	(do_white_explo 40 45)
	nil)
    (progn
      (next_picture)
      (if (> (with_object (get_object 0) (total_objects)) 0)
	  (let ((player_angle (get_fris_angle)))
	    (let ((angle_change (angle_diff (aistate) player_angle)))
	      (if (< (abs angle_change) 35)
		  (set_aistate (mod (+ (aistate) angle_change 360) 360))
		(if (>= angle_change 0)
		    (set_aistate (mod (+ (aistate) 35) 360))
		  (set_aistate (mod (+ (aistate) 325 ) 360)))))))
      T))
)



(defun dfris_cache (type)
  (list (list EXPLODE8 EXP_LIGHT)
	(list GRENADE_SND)))

(def_char DFRIS_BULLET
  (funs (ai_fun   dfris_ai)
	(get_cache_list_fun dfris_cache))
  (range 10000 10000)
  (flags (unlistable T)
	 (add_front T))
  (states "art/misc.spe" (stopped  "dfris_bullet")))

