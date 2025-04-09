;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(setq ant_tints (make-array 13 :initial-contents (list
						(def_tint "art/tints/ant/green.spe")
						(def_tint "art/tints/ant/blue.spe")
						(def_tint "art/tints/ant/brown.spe")
						(def_tint "art/tints/ant/egg.spe")
						(def_tint "art/tints/ant/yellow.spe")
						(def_tint "art/tints/ant/mustard.spe")
						(def_tint "art/tints/ant/orange.spe")
						(def_tint "art/tints/ant/gray.spe")
						(def_tint "art/tints/guns/green.spe")
						(def_tint "art/tints/ant/darkblue.spe")
						normal_tint
						normal_tint
						normal_tint
						)))

/*
------ this code has been compiled --------
(defun no_fall_move (xm ym but)
  (move xm ym but))
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
	    0)
	ret))))


(defun will_fall_if_jump ()
  nil)
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
^^^^^^ this code has been compiled ^^^^^^^^
*/


(defun strait_rocket_ai ()
  (set_course (aistate)
	      (select difficulty
		      ('easy    12)
		      ('medium  15)
		      ('hard    17)
		      ('extreme 22) ))
  (set_frame_angle 0 359 (aistate))
  (let ((stat (bmove nil)))
    (if (eq stat T)
	T
    (progn
      (if (not (eq stat nil))
	  (progn
	    (add_object EXPLODE3 (+ (x) (random 5)) (+ (y) (random 5)) 0)
	    (add_object EXPLODE2 (+ (x) (random 5)) (+ (y) (random 5)) 2)
	    (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 1)
	    (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 2)
	    (hurt_radius (x) (+ (y) 20) 25 15 nil 10)
	    )
	(let ((myself (me)))
	  (with_object (add_object EG_EXPLO (x) (y)) (user_fun myself (car stat)))))
      nil))))


(def_char STRAIT_ROCKET
  (funs (ai_fun strait_rocket_ai))
  (range 10000 10000)
  (flags (unlistable T))
  (states "art/missle.spe" (stopped    (seq "b32r" 1 32))))

(defun animate_ai () (next_picture))

(defun eg_explo_ufun (creator block_flags)
  (set_direction (with_object creator (direction)))
  (if block_flags
      (if (or (blocked_left block_flags) (blocked_right block_flags))
	  (set_state blocking))))

(def_char EG_EXPLO
  (funs (ai_fun   animate_ai)
	(user_fun eg_explo_ufun))
  (range 10000 10000)
  (flags (unlistable T))
  (states "art/missle.spe"
	  (stopped  (seq "bifl" 1 4))
	  (blocking (seq "bilw" 1 4))))

/*
------ this code has been compiled --------
(defun alien_wait_time ()
  (select difficulty
	  ('easy    6)
	  ('medium  4)
	  ('hard    2)
	  ('extreme 1)))

(defun can_hit_player ()
  (let ((firex (+ (x) (* (direction) 15)) )
	(firey (- (y) 15))
	(playerx (with_object (bg) (x)))
	(playery (- (with_object (bg) (y)) 15)))
    (can_see firex firey playerx playery nil)))

(defun not_ant_congestion ()
  (if (> (direction) 0)
      (if (find_object_in_area (+ (x) 23) (- (y) 20) (+ (x) 30) (+ (y) 20) (list ANT_ROOF))
	  nil
	T)
    (if (find_object_in_area (- (x) 30) (- (y) 20) (- (x) 23) (+ (y) 20) (list ANT_ROOF))
	nil
      T)))


(defun roof_above () (not (can_see (x) (y) (x) (- (y) 120) nil)))

(defun fire_at_player ()
  (let ((firex (+ (x) (* (direction) 15)) )
	(firey (- (y) 15))
	(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 8))))
	(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))

    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
	(progn
	  (let ((angle (atan2 (- firey playery)
			      (- playerx firex))))
	    (fire_object (me) (aitype) firex firey angle (bg))
	    (set_state weapon_fire))

	  ))))

(defun ant_dodge ()
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

(defun scream_check ()
  (if (can_see (x) (y) (with_object (bg) (x)) (with_object (bg) (y)) nil)
      (progn
	(if (or (eq no_see_time 0) (> no_see_time 20))
	  (play_sound ASCREAM_SND 127 (x) (y)))
	(setq no_see_time 1))
    (setq no_see_time (+ no_see_time 1))))

(defun ant_ai ()
      (push_char 30 20)
      (if (or (eq (state) flinch_up) (eq (state) flinch_down))
	  (progn (next_picture) T)
	(progn

	  (select (aistate)
		  (0   (set_state hanging)
		       (if (eq hide_flag 0)
			   (set_aistate 15)
			 (set_aistate 16)))

		  (15 ;; hanging on the roof waiting for the main character
		   (if (next_picture) T (set_state hanging))
		   (if (if (eq (total_objects) 0);; no sensor, wait for guy
			   (and (< (distx) 130) (< (y) (with_object (bg) (y))))
			 (not (eq (with_object (get_object 0) (aistate)) 0)))
		       (progn
			 (set_state fall_start)			 (set_direction (toward))
			 (set_aistate 1))))

		  (16 ;; hiding
		   (set_state hiding)
		   (if (if (eq (total_objects) 0);; no sensor, wait for guy
			   (and (< (distx) 130) (< (y) (with_object (bg) (y))))
			 (not (eq (with_object (get_object 0) (aistate)) 0)))
		       (progn
			 (set_state fall_start)			 (set_direction (toward))
			 (set_aistate 1))))

		  (1 ;; falling down
		   (set_state falling)
		   (scream_check)
		   (if (blocked_down (move 0 0 0))
		       (progn
			 (set_state landing)
			 (play_sound ALAND_SND 127 (x) (y))
			 (set_aistate 9))))

		  (9 ;; landing / turn around (gerneal finish animation state)
		   (if (next_picture) T
		     (if (try_move 0 2)
			 (progn
			   (set_gravity 1)
			   (set_aistate 1))
		       (progn (set_state stopped)
			      (go_state 2)))))  ;; running

		  (2 ;; running
		   (scream_check)
		   (if (eq (random 20) 0) (setq need_to_dodge 1))
		   (if (not (ant_dodge))
		     (if (eq (facing) (toward))
			 (progn
			   (next_picture)
			   (if (and (eq (random 5) 0) (< (distx) 180) (< (disty) 100) (can_hit_player))
			       (progn
				 (set_state weapon_fire)
				 (set_aistate 8))  ;; fire at player
			     (if (and (< (distx) 100) (> (distx) 10) (eq (random 5) 0))
				 (set_aistate 4)  ;; wait for pounce

			       (if (and (> (distx) 140)
					(not_ant_congestion)
					(not (will_fall_if_jump)))
				   (set_aistate 6)

				 (if (> (direction) 0)
				     (if (and (not_ant_congestion) (blocked_right (no_fall_move 1 0 0)))
					 (set_direction -1))
				   (if (and (not_ant_congestion) (blocked_left (no_fall_move -1 0 0)))
				       (set_direction 1)))))))
			   (progn
			     (set_direction (toward))
			     (set_state turn_around)
			     (set_aistate 9)))))

		  (4 ;; wait for pounce
		   (if (ant_dodge) T
		     (progn
		       (set_state pounce_wait)
		       (move 0 0 0)
		       (if (> (state_time) (alien_wait_time))
			   (progn
			     (play_sound ASLASH_SND 127 (x) (y))
			     (set_state stopped)
			     (go_state 6))))))

		  (6 ;; jump
		   (setq need_to_dodge 0)
		   (if (blocked_down (move (direction) -1 0))
		       (progn
			 (set_aistate 2))))

		  (8 ;; fire at player
		   (if (ant_dodge) T
		     (if (eq (state) fire_wait)
			 (if (next_picture)
			     T
			   (progn
			     (fire_at_player)
			     (set_state stopped)
			     (set_aistate 2)))
		       (set_state fire_wait))))

		  (12 ;; jump to roof
		   (setq need_to_dodge 0)
		   (set_state jump_up)
		   (set_yvel (+ (yvel) 1))
		   (set_xacel 0)
		   (let ((top (- (y) 31))
			 (old_yvel (yvel))
			 (new_top (+ (- (y) 31) (yvel))))
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
		   (scream_check)
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
		       (if (and (< (distx) 120) (eq (random 5) 0))
			   (progn
			     (set_state ceil_fire)
			     (go_state 14))
			 (let ((xspeed (if (> (direction) 0) (get_ability run_top_speed)
					 (- 0 (get_ability run_top_speed)))))
			   (if (and (can_see (x) (- (y) 31) (+ (x) xspeed) (- (y) 31) nil)
				    (not (can_see (+ (x) xspeed) (- (y) 31)
						  (+ (x) xspeed) (- (y) 32) nil)))
			       (progn
				 (set_x (+ (x) xspeed))
				 (if (not (next_picture))
				     (set_state top_walk)))
			     (set_aistate 1)))))))


		  (14 ;; cieling shoot
		   (if (next_picture)
		       T
		     (progn
		       (fire_at_player)
		       (set_state top_walk)
		       (set_aistate 13))))

		  )))

      T)
*/


(defun create_dead_parts (array part_num type)
  (let ((dir  (direction))
	(rand (rand_on)))
    (with_object (add_object (aref array part_num) (x) (y))
	       (progn (set_aitype type)
		      (set_xvel (* dir (random 10)))
		      (set_yvel (- 0 (random 25)))))
    (with_object (add_object (aref array (+ part_num 1)) (x) (y))
	       (progn (set_aitype type)
		      (set_xvel (* dir (random 10)))
		      (set_yvel (- 0 (random 25)))))
    (with_object (add_object (aref array (+ part_num 2)) (x) (y))
	       (progn (set_aitype type)
		      (next_picture)                        ;; unsync the animations
		      (set_xvel (* dir (random 10)))
		      (set_yvel (- 0 (random 25)))))
    (with_object (add_object (aref array (+ part_num 2)) (x) (y))
	       (progn (set_aitype type)
		      (next_picture)
		      (next_picture)
		      (set_xvel (* dir (random 10)))
		      (set_yvel (- 0 (random 25)))))
    (with_object (add_object (aref array (+ part_num 2)) (x) (y))
	       (progn (set_aitype type)
		      (next_picture)
		      (next_picture)
		      (next_picture)
		      (set_xvel (* dir (random 10)))
		      (set_yvel (- 0 (random 25)))))
    (set_rand_on rand)))   ;; restore random table, in case this didn't get called because of frame panic


(enum 'decay_part
      'flaming_part
      'electric_part
      'normal_part)

(defun get_dead_part (from)
  (if from
      (let ((type (with_object from (otype))))
	(if (or (eq type GRENADE) (eq type ROCKET) (eq type FIREBOMB))
	    flaming_part
	  (if (or (eq type PLASMAGUN_BULLET) (eq type LSABER_BULLET))
	      electric_part
	    normal_part)))
    normal_part)

)


(defun ant_damage (amount from hitx hity push_xvel push_yvel)  ; transfer damage to lower half

  (if (and (not (eq (state) dead))
	   (or (not from)
	       (with_object from (if (eq (total_objects) 0)
				     (not (eq (otype) ANT_ROOF))
				   (with_object (get_object 0) (not (eq (otype) ANT_ROOF)))))))
      (if (not (eq (aistate) 15))
	  (progn
	    (if (eq (random 2) 0)
		(set_state flinch_up)
	      (set_state flinch_down))
	    (damage_fun amount from hitx hity push_xvel push_yvel)
	    (play_sound APAIN_SND 127 (x) (y))
	    (setq need_to_dodge 1)
	    (if (<= (hp) 0)
		(progn
		  (if (eq (aitype) 0)
		      (play_sound (aref ASML_DEATH (random 2)) 127 (x) (y))
		    (play_sound (aref ALRG_DEATH (random 3)) 127 (x) (y)))

		  (set_state dead)
		  (if (eq (random (select difficulty
					  ('easy 2)
					  ('medium 5)
					  ('hard   8)
					  ('extreme 20))) 0)
		      (if (eq (random 4) 0)
			  (add_object (aitype_to_ammo (+ (aitype) 1)) (x) (y)))
		    (add_object (aitype_to_ammo (aitype)) (x) (y)))
		  (create_dead_parts ant_dead_parts (* (get_dead_part from) 3) (aitype)))
		  )))))

(defun ant_cons ()
  (set_state hanging)
  (setq no_see_time 300))

(defun ant_ct ()
  (select (aitype)
	  (0 (set_hp 15))
	  (1 (set_hp 50))
	  (2 (set_hp 25))
	  (3 (set_hp 35))
	  (4 (set_hp 35))
	  (5 (set_hp 20))

	  ))


;; XXX: Mac Abuse reimplements this in C++
(defun ant_draw ()
  (if (eq 0 (aitype))
      (draw)
    (draw_tint (aref ant_tints (aitype)))))

(def_char ANT_ROOF
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (fields
	  ("hide_flag"    ant_hide)
	  ("fade_count"   ai_fade)
	  ("aitype"       ai_type)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))
  (range 250 20)
  (draw_range 40 40)
  (funs (ai_fun     ant_ai)
	(draw_fun   ant_draw)
	(constructor ant_cons)
	(type_change_fun ant_ct)
	(get_cache_list_fun ant_cache)
	(damage_fun ant_damage))

  (abilities (run_top_speed   7)
	     (start_hp       20)
	     (stop_acel      20)
	     (start_acel     20)
	     (jump_yvel      -4)
	     (jump_xvel      20)
	     (push_xrange     1)
	     (jump_top_speed 20))

  (flags (hurtable  T)
	 (force_health T))

  (states "art/ant.spe"
	  (hanging (rep "ant" 2))

	  (fall_start "affc0001.pcx")
	  (falling    "affc0002.pcx")

	  (stopped "awlk0001.pcx")
	  (running (seq "awlk" 1 10))
	  (landing (seq "acff" 1 4))
	  (pounce_wait "acff0001.pcx")
	  (turn_around (seq "atrn" 1 5))

	  (run_jump "dive")
	  (run_jump_fall "dive")
	  (start_run_jump "dive")
	  (fire_wait (seq "wait" 1 3))

	  (ceil_fire (seq "cfire" 1 3))
	  (top_walk  (seq "awkc" 1 10))
	  (flinch_up (rep "afh10001.pcx" 2))
	  (flinch_down (rep "afh20001.pcx" 2))
	  (blown_back_dead     "adib0009.pcx")
	  (jump_up            "ajmp.pcx")
	  (hiding             "hidden")
	  (dead             "hidden")
	  (weapon_fire  (seq "asht" 2 5))))


(def_char HIDDEN_ANT
  (funs (ai_fun     ant_ai)
	(draw_fun   dev_draw))
  (flags (unlistable T))
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (states "art/ant.spe" (stopped "hidden")))




(defun crack_ai ()
  (if (eq (aistate) 0)
      (if (if (eq (total_objects) 0)
	      (and (< (distx) 50) (< (disty) 70))
	    (with_object (get_object 0) (not (eq (aistate) 0))))
	  (set_aistate 1))
    (select (current_frame)
	    (4 nil)
	    (3
	     (let ((d (direction))
		   (type (aitype)))
	       (if (or (eq create_total 0) (eq create_total 1))
		   (set_current_frame 4)
		 (progn
		   (setq create_total (- create_total 1))
		   (set_current_frame 0)))
	       (with_object (add_object_after ANT_ROOF (+ (x) (* (direction) 20)) (y))
			    (progn
			      (set_aitype type)
			      (set_direction d)
			      (set_xvel (* d 20))
			      (set_state run_jump)
			      (set_aistate 6)))
	       ))
	    (0 (next_picture))
	    (1 (next_picture))
	    (2 (next_picture))))
  T)


(defun crack_cons ()
  (setq create_total 1)
  (set_aitype 1))


(def_char ANT_CRACK
  (funs (ai_fun crack_ai)
	(draw_fun ant_draw)
	(get_cache_list_fun ant_cache)
	(constructor crack_cons))
  (range 250 0)
  (vars create_total)
  (fields ("create_total"  ant_total)
	  ("aitype"        ant_type))
  (states "art/ant.spe"
	  (stopped (seq "aisw" 2 6))))


(defun head_ai ()
  (select (aistate)
	  (0 ;; falling
	   (next_picture)
	   (set_yvel (+ (yvel) 3))
	   (bounce_move T T T '(progn (set_state dieing) (set_aistate 1)) T)
	   (or (< (state_time) 15)
	       (not (frame_panic))))
	  (1 ;; hit the ground
	   nil)
	  ))

(setq ant_dead_parts (make-array (* 3 4) :initial-contents
			     '((AD_1  "adbn") (AD_2  "adha") (AD_3  "adla")     ; disapear
			       (AD_4  "adaf") (AD_5  "adah") (AD_6  "adlf")     ; flaming
			       (AD_7  "adbe") (AD_8  "adhe") (AD_9  "adle")     ; electrical
			       (AD_10 "adan") (AD_11 "adhn") (AD_12 "adln"))))  ; normal


(defun ant_cache (type)  ;; cache in the ant (from crack) and the dead body parts and the ant tints
  (list
   (list ANT_ROOF AD_1 AD_2 AD_3 AD_4 AD_5 AD_6 AD_7 AD_8 AD_9 AD_10 AD_11 AD_12)
   (list (aref ant_tints 0) (aref ant_tints 1) (aref ant_tints 2) (aref ant_tints 3)
	 (aref ant_tints 4) (aref ant_tints 5) (aref ant_tints 6) (aref ant_tints 7)
	 (aref ant_tints 8) (aref ant_tints 9) (aref ant_tints 10))))



(defun make_dead_part (sym base frames filename draw)
  (eval `(def_char ,sym
	   (range 100 100)
	   (funs (ai_fun    head_ai)
		 (draw_fun  ,draw))
	   (flags (unlistable T)
		  (add_front T))
	   (states filename
		  (stopped (seq base 1 ,frames))))))


(do ((i 0 (setq i (+ i 1))))
	   ((>= i 12) nil)
	   (setq (aref ant_dead_parts i)
		 (make_dead_part (car (aref ant_dead_parts i))
				 (car (cdr (aref ant_dead_parts i))) 4 "art/ant.spe" 'ant_draw)))



(defun boss_damage (amount from hitx hity push_xvel push_yvel)
  (if (and (eq (fade_count) 0) (not (eq (aistate) 0)) (< (aitype) 6))
      (progn
	(damage_fun amount from hitx hity push_xvel push_yvel)
	(if (eq (hp) 0)
	    (progn
	      (set_hp 1)
	      (set_aitype (+ (aitype) 1))
	      (if (eq (aitype) 6)         ;; go to next alien type
		  (set_aistate 10)        ;; end game
		(set_aistate 5)))))))         ;; fade out

(defun boss_cons ()
  (set_hp 1)
  (setq taunt_time 20))

(defun boss_fire ()
  (let ((firex (+ (x) (* (direction) 17)) )
	(firey (- (y) 25))
	(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 8))))
	(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))

    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
	(progn
	  (let ((angle (atan2 (- firey playery)
			      (- playerx firex))))
	    (fire_object (me) (aitype) firex firey angle (bg))
	    (set_state weapon_fire))

	  ))))


(defun boss_ai ()
  (if (total_objects)

      (if (eq (aistate) 11)
	  nil
	(progn
	  (select (aistate)
		  (0;; wait for turn on
		   (set_state hiding);; can't see us
		   (set_targetable nil)
		   (if (activated)
		       (set_aistate 1)))
		  (1;; taunt for a while
		   (set_targetable nil)
		   (if (eq taunt_time 0)
		       (progn
			 (set_fade_count 14)
			 (set_state stopped)
			 (play_sound APPEAR_SND 127 (x) (y))
			 (set_aistate 2)));; fade in
		   (progn
		     (setq taunt_time (- taunt_time 1))
		     (if (eq (mod taunt_time 25) 0)
			 (play_sound TAUNT_SND 127 (x) (y)))))

		  (2;; fade in
		   (set_direction (toward))
		   (if (eq (fade_count) 0)
		       (progn
			 (set_state weapon_fire)
			 (go_state 3))
		     (set_fade_count (- (fade_count) 2))))

		  (3;; wait to fire
		   (set_targetable T)
		   (if (next_picture) T
		     (go_state 4)))

		  (4;; fire1
		   (boss_fire)
		   (set_aistate 5)
		   (set_state weapon_fire))

		  (5;; wait to fire
		   (set_targetable T)
		   (if (next_picture) T
		     (go_state 6)))

		  (6;; fire1
		   (boss_fire)
		   (set_aistate 7)
		   (set_state stopped))

		  (7;; fade out
		   (set_targetable nil)
		   (set_fade_count (+ (fade_count) 2))
		   (if (eq (fade_count) 14)
		       (progn
			 (set_state hiding)
			 (let ((to_object (get_object (random (total_objects)))))
			   (set_x (with_object to_object (x)))
			   (set_y (with_object to_object (y))))
			 (setq taunt_time (- 30 (* (aitype) 2)))
			 (go_state 0))))

		  (10;; game over
		   (set_state hiding)
		   (set_targetable nil)
		   (if (eq (state_time) 60)
		       (go_state 11))
		   (if (not (eq (state_time) 0))
		       (progn
			 (if (eq (mod (state_time) 8) 0)
			     (play_sound GRENADE_SND 127 (x) (y)))
			 (add_object EXPLODE1 (+ (x) (random (* (state_time) 2))) (+ (random (state_time)) (y)))
			 (add_object EXPLODE1 (- (x) (random (* (state_time) 2))) (- (y) (random (state_time)))))))
		  )

	  T))))



(def_char BOSS_ANT
  (funs (ai_fun boss_ai)
	(draw_fun ant_draw)
	(damage_fun boss_damage))
  (vars taunt_time)
  (flags (hurtable T)
	 (unlistable T))
  (fields ("taunt_time" "taunt_tint")
	 ("aistate" "aistate"))
  (states  "art/boss.spe"
   (stopped "awlk0001.pcx")
   (hiding  "hidden")
   (weapon_fire  (seq "asht" 2 5))))

