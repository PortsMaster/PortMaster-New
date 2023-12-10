(defun Njug_can_hit_player ()
  (let ((firex (x))
	(firey (- (y) 24))
	(playerx (with_object (bg) (x)))
	(playery (- (with_object (bg) (y)) 15)))
    (can_see firex firey playerx playery nil)))

(defun Njug_fire_at_player ()
  (let ((firex (x) )
	(firey (- (y) 24) )
	(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 1))))
	(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 1)))))

    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
	(progn
	  (let ((angle (atan2 (- firey playery)
			      (- playerx firex))))
	    (fire_object (me) (aitype) firex firey angle (bg))
	    (set_state weapon_fire))

	  ))))

(defun Njug_ai ()
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(set_state dieing))
    (if (activated)
	(progn
	  (set_targetable T)
	  (push_char 35 40)
	  (select (aistate)
		  (0 ;; prepare to walk toward player
		   (if (eq stationary 0)
		       (progn
			 (set_state running)
			 (go_state 1))
		     (if (> (state_time) throw_xvel)
			 (progn
			   (set_state weapon_fire)
			   (set_aistate 2)))))

		  (1 ;; walk toward player
		   (if (eq stationary 0)
		       (progn
			 (set_direction (toward))
			 (let ((curx (x));; save position in case we fall off a cliff
			       (cury (y)))
			   (if (next_picture)
			       (if (eq (current_frame) 8)
				   (play_sound JSTOMP_SND 127 (x) (y)))
			     (progn
			       (play_sound JSTOMP_SND 127 (x) (y))
			       (set_state weapon_fire)
			       (set_aistate 2)))
			   (if (can_see (x) (y) (x) (+ (y) 5) nil)
			       (progn
				 (set_x curx)
				 (set_y cury)
				 (try_move 0 10)))))
		     (if (> (state_time) throw_xvel)
			 (progn
			   (set_state weapon_fire)
			   (set_aistate 2)))))

		  (2 ;; start fire
                   (if (eq (Njug_can_hit_player) nil) (go_state 0))
		   (if (> (state_time) 3)
		       (let ((myself (me)))
			 (set_direction (toward))
			 (Njug_fire_at_player)
			 (go_state 0))
		     (next_picture)))
		  (3 ;; wait for fire animation
		   (if (next_picture) nil (set_aistate 0))))
	  T)
      (progn (set_targetable nil)
	     T))))

(defun Njug_cons ()
  (setq throw_xvel 3)
  (setq throw_yvel -10)
  (set_aitype 1))

(def_char NJUGGER
  (range 200 0)
  (funs (ai_fun     Njug_ai)
	(constructor Njug_cons)
	(get_cache_list_fun explo_damage_cache)
	(damage_fun explo_damage))
  (flags (hurtable T)
         (can_block T))
  (abilities (start_hp    50)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        ai_type)
	  ("throw_xvel"    jug_throw_spd)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "art/jug.spe"
	  (stopped "robo0001.pcx")
	  (running (seq "rwlk" 1 13))
	  (weapon_fire (seq "robo" 1 10))
	  (dieing (seq "jugdie" 1 8))))
