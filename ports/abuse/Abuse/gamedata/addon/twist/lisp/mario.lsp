;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(defun yoshi_ai ()	;; This is kinda amatuerish as this is my first attempt
  (if (<= (hp) 0)	;; in writing the code from scratch
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
	  T))
    (progn
	(try_move 0 10)
	(next_picture)
	(if (and (not (> (distx) 70)) (not (eq (state) stopped))) (set_state stopped))
	(if (and (> (distx) 70) (eq (state) stopped)) (set_state running))
	(if (or (eq (state) running) (not (eq (direction) (toward))))
	    (progn
		(set_direction (toward))
		(try_move (* (toward) 7) 0)
		(next_picture)(next_picture)(next_picture)(next_picture)(next_picture)(next_picture)
	    ))
	T) ))


(defun mario_ai ()	;; I think you know where i got this code from...
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
		     (if (> (state_time) (aitype))
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
			       (if (eq (current_frame) 99) ;; The sound wont play anyway
				   (play_sound JSTOMP_SND 127 (x) (y)));; bc there's 9 frames
			     (progn					;; only!
			       (play_sound JSTOMP_SND 127 (x) (y))
			       (set_state weapon_fire)
			       (set_aistate 2)))
			   (if (can_see (x) (y) (x) (+ (y) 5) nil)
			       (progn
				 (set_x curx)
				 (set_y cury)
				 (try_move 0 10)))))
		     (if (> (state_time) (aitype))
			 (progn
			   (set_state weapon_fire)
			   (set_aistate 2)))))

		  (2 ;; start fire
		   (if (> (state_time) 10)
		       (let ((myself (me))
			     (xspeed (* throw_xvel (direction)))
			     (yspeed throw_yvel))
			 (with_object (add_object MARIO_FIREBALL (+ (x) (* (direction) 20)) (- (y) 5) 1)
				      (progn
					(user_fun myself)
					(set_xvel xspeed)
					(set_yvel yspeed)))
			 (go_state 3))
		     (next_picture)))
		  (3 ;; wait for fire animation
		   (if (next_picture) nil (set_aistate 0))))
	  T)
      (progn (set_targetable nil)
	     T))))

(defun mario_cons ()
  (setq throw_xvel 10)
  (setq throw_yvel 5)
  (set_aitype 0))


(defun m_fireball_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (if (eq (hp) 0)
	  (progn
	    (play_sound P_EXPLODE_SND 127 (x) (y))
	    (add_object EXPLODE3 (+ (x) (random 5)) (+ (y) (random 5)) 0)
	    (add_object EXPLODE2 (+ (x) (random 5)) (+ (y) (random 5)) 2)
	    (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 1)
	    (add_object EXPLODE2 (- (x) (random 5)) (- (y) (random 5)) 2)
	    (add_object EXP_LIGHT (x) (y) 100)
	    nil)
	(progn
	  (next_picture)
	  (set_yvel (+ (yvel) 1))
	  (let ((old_yv  (yvel))
		(old_xv  (xvel))
		(old_x   (x))
		(old_y   (y))
		(status (float_tick)))

	    (let ((new_x (x))
		  (new_y (y))
		  (set_x old_x)
		  (set_y old_y))
	      (platform_push (- new_x (x)) (- new_y (y)))
	      (set_x new_x)
	      (set_y new_y))
	    (hurt_radius (x) (y) 20 10 (me) 15)
	    (if (not (eq status T));; T means we did not hit anything
		(let ((block_flags (car status)))
		  (if (or (blocked_up block_flags) (blocked_down block_flags));; bounce up/down
		      (progn
			(if (> (abs old_yv) 3)
			    (play_sound SBALL_SND 127 (x) (y)))
			(set_xvel old_xv)
			(if (> old_yv 1)
			    (set_yvel (- 2 old_yv))
			  (set_yvel (- 0 old_yv))))
		    (if (or (blocked_left block_flags) (blocked_right block_flags));; bounce left/right
			(progn
			  (set_yvel old_yv)
			  (set_xvel (- 0 old_xv))))))))
	  T))
    T))



(defun mqblock_ai ()
	(set_fade_count (yacel))
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
	(with_object (add_object MARIO_BLOCKH (x) (y)) (progn (set_xvel 0) (set_yvel 0)))
		(select (aitype)
		  (1 (add_object MARIO_POWERCOIN (x) (- (y) 20)))
		  (2 (add_object MARIO_POWERFLOW (x) (- (y) 20)))
		  (3 (add_object MARIO_POWERTOAD (x) (- (y) 20)))
		  (4 (add_object MARIO_POWERSTAR (x) (- (y) 20)))
		)
	  T))
    T))


(defun mbblock_ai ()
	(set_fade_count (yacel))
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
		(select (aitype)
		  (1 (add_object MARIO_POWERCOIN (x) (y)))
		  (2 (add_object MARIO_POWERFLOW (x) (y)))
		  (3 (add_object MARIO_POWERTOAD (x) (y)))
		  (4 (add_object MARIO_POWERSTAR (x) (y)))
		)
	  T))
    T))

(defun mvenus_ai ()
	(next_picture)
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
	  T))
    T))


(defun mvenus_cons ()
(set_current_frame 16))


(defun memush_ai ()
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
	  T))
    (progn
	(try_move 0 10)
	(next_picture)
	(if (and (eq (direction) 1) (blocked_right (move 1 0 0))) (set_direction -1))
	(if (and (eq (direction) -1) (blocked_left (move -1 0 0))) (set_direction 1))
	T) ))

(defun mbill_ai ()
  (if (eq (mod (game_tick) 40) 0)
	(add_object MARIO_BULLET (x) (- (y) 18) ))
  T)

(defun mbullet_ai ()
  (try_move (xvel) 0)
)

(defun mbullet_cons ()
	(set_direction (toward))
  (if (eq (direction) -1) (progn (set_x (- (x) 7)) (set_xvel -7)))
  (if (eq (direction) 1) (progn (set_x (+ (x) 22)) (set_xvel 7)))
)


(defun mpowtoad_ai ()
	(try_move 0 10)
	(next_picture)
	(if (touching_bg)
	   (progn
	(with_object (bg) (give_player_health 20))
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))

(defun mpowstar_ai ()
	(try_move 0 10)
	(next_picture)
	(if (touching_bg)
	   (progn
	(with_object (bg) (setq special_power FAST_POWER))
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))

(defun mpowflow_ai ()
	(try_move 0 10)
	(next_picture)
	(if (touching_bg)
	   (progn
	(with_object (bg) (setq special_power HEALTH_POWER))
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))

(defun mpowcoin_ai ()
	(try_move 0 10)
	(next_picture)
	(if (touching_bg)
	   (progn
	(with_object (bg) (give_player_health 4))
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))


(def_char MARIO_YOSHI
  (funs (ai_fun  yoshi_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 200))
  (states "addon/twist/art/mario.spe"
	  (stopped       '("ys0001.bmp" "ys0002.bmp" "ys0003.bmp" "ys0002.bmp" "ys0001.bmp"
			   "ya0001.bmp" "ya0002.bmp" "ya0003.bmp" "ya0004.bmp" "ya0005.bmp"
			   "ya0006.bmp" "ya0007.bmp" "ya0008.bmp" "ya0009.bmp" "ya0010.bmp"
			   "ya0011.bmp" "ya0012.bmp"))
	  (running	 (seqbmp "yr" 1 6))
	  (dieing        (seqbmp "yd" 1 20))))


(def_char MARIO_MARIO
  (range 200 0)
  (funs (ai_fun     mario_ai)
	(constructor mario_cons)
	(draw_fun	gun_draw)
	(get_cache_list_fun explo_damage_cache))
  (flags (hurtable T))
  (abilities (start_hp    100)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        jug_throw_spd)
	  ("throw_xvel"    jug_throw_xv)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "addon/twist/art/mario.spe"
	  (stopped "ms.bmp")
	  (running '("mr0001.bmp" "mr0002.bmp" "mr0003.bmp"
		     "mr0001.bmp" "mr0002.bmp" "mr0003.bmp"
		     "mr0001.bmp" "mr0002.bmp" "mr0003.bmp"))
	  (weapon_fire  '("ms.bmp" "mj.bmp" "ma.bmp" "ma.bmp" "ms.bmp"))
	  (dieing (seqbmp "md" 1 10))))


(def_char MARIO_LUIGI
  (range 200 0)
  (funs (ai_fun     mario_ai)
	(constructor mario_cons)
	(draw_fun	gun_draw)
	(get_cache_list_fun explo_damage_cache))
  (flags (hurtable T))
  (abilities (start_hp    100)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        jug_throw_spd)
	  ("throw_xvel"    jug_throw_xv)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "addon/twist/art/mario.spe"
	  (stopped "ls.bmp")
	  (running '("lr0001.bmp" "lr0002.bmp" "lr0003.bmp"
		     "lr0001.bmp" "lr0002.bmp" "lr0003.bmp"
		     "lr0001.bmp" "lr0002.bmp" "lr0003.bmp"))
	  (weapon_fire  '("ls.bmp" "lj.bmp" "la.bmp" "la.bmp" "ls.bmp"))
	  (dieing (seqbmp "ld" 1 10))))


(def_char MARIO_FIREBALL
  (funs  (ai_fun m_fireball_ai)
	 (damage_fun bold_dam)
	 (constructor bolder_cons))
  (flags (can_block  T)
	 (add_front  T)
	 (hurtable   T)
	 (unlistable T))
  (range 200 200)
  (abilities (start_hp 1))
  (fields ("xvel" ai_xvel)
	  ("yvel" ai_yvel)
	  ("hp"   ai_health)
	  )
  (states "addon/twist/art/mario.spe"
	  (stopped (seqbmp "mf" 1 4))))


(def_char MARIO_BLOCKQ
  (funs (ai_fun  mqblock_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 2))
  (fields ("aitype" "Power 0=nil,1=cn,2=fl,3=td,4=st")
	  ("yacel" "Fade Count"))
  (states "addon/twist/art/mario.spe"
	  (stopped       "b0012.bmp")
	  (dieing        (seqbmp "b" 12 1))))


(def_char MARIO_BLOCKH
  (funs (ai_fun  do_nothing)
	(draw_fun lower_draw))
  (flags (can_block T)
	 (hurtable  nil))
  (states "addon/twist/art/mario.spe"
	  (stopped       "b0001.bmp")))


(def_char MARIO_BLOCKB
  (funs (ai_fun  mbblock_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 2))
  (fields ("aitype" "Power 0=nil,1=cn,2=fl,3=td,4=st")
	  ("yacel" "Fade Count"))
  (states "addon/twist/art/mario.spe"
	  (stopped       "b20001.bmp")
	  (dieing        (seqbmp "b2" 1 10))))


(def_char MARIO_PIPEUP
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pup.bmp")))


(def_char MARIO_PIPEDOWN
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pdown.bmp")))


(def_char MARIO_PIPELEFT
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pleft.bmp")))


(def_char MARIO_PIPERIGHT
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pright.bmp")))


(def_char MARIO_PIPEVERT
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pvert.bmp")))


(def_char MARIO_PIPEHORI
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "phori.bmp")))


(def_char MARIO_PIPECROSS
  (funs (ai_fun  do_nothing))
  (flags (can_block T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "pcross.bmp")))


(def_char MARIO_VENUS
  (funs (ai_fun  mvenus_ai)
	(constructor mvenus_cons))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 25))
  (states "addon/twist/art/mario.spe"
	  (stopped       '("v0001.bmp" "v0001.bmp" "v0001.bmp" "v0001.bmp"
			   "v0001.bmp" "v0001.bmp" "v0001.bmp" "v0001.bmp"
			   "v0001.bmp" "v0001.bmp" "v0001.bmp" "v0001.bmp"
			   "v0002.bmp" "v0003.bmp" "v0004.bmp" "v0005.bmp"
			   "v0005.bmp" "v0005.bmp" "v0005.bmp" "v0005.bmp"
			   "v0005.bmp" "v0005.bmp" "v0005.bmp" "v0005.bmp"
			   "v0004.bmp" "v0003.bmp" "v0002.bmp" "v0001.bmp"))
	  (dieing        (seqbmp "vd" 1 10))
	  (risen	 "v0005.bmp")))


(def_char MARIO_ENEMYMUSH
  (funs (ai_fun  memush_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 20)
	     (run_top_speed 4))
  (states "addon/twist/art/mario.spe"
	  (stopped       '("mush0001.bmp" "mush0002.bmp" "mush0003.bmp"))
	  (dieing        (seqbmp "mshd" 1 10))))


(def_char MARIO_ENEMYTRTL
  (funs (ai_fun  memush_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 30)
	     (run_top_speed 2))
  (states "addon/twist/art/mario.spe"
	  (stopped       (seq "trtl" 1 2))
	  (dieing        (seq "tdie" 1 10))))


(def_char MARIO_BULLETBILL
  (funs (ai_fun  mbill_ai))
  (flags (can_block T)
	 (hurtable  nil))
  (states "addon/twist/art/mario.spe"
	  (stopped       "bill")))

(def_char MARIO_BULLET
  (funs (ai_fun  mbullet_ai) (constructor mbullet_cons))
  (flags (can_block T)
	 (hurtable  nil)
	 (unlistable T))
  (states "addon/twist/art/mario.spe"
	  (stopped       "bullet")))


(def_char MARIO_POWERTOAD
  (funs (ai_fun mpowtoad_ai))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "powtoad" )))

(def_char MARIO_POWERSTAR
  (funs (ai_fun mpowstar_ai))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "powstar" )))

(def_char MARIO_POWERFLOW
  (funs (ai_fun mpowflow_ai))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "powflow" )))

(def_char MARIO_POWERCOIN
  (funs (ai_fun mpowcoin_ai))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped (seq "coin" 1 4) )))

(def_char MARIO_PROPCLDS
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "clouds")))

(def_char MARIO_PROPBUSH
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "bushes")))

(def_char MARIO_PROPHILL
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "hill")))

(def_char MARIO_PROPHILL2
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "hillbig")))

(def_char MARIO_PROPTREE2
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "treebig")))

(def_char MARIO_PROPTREE
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "tree")))

(def_char MARIO_PROPTREE
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "tree")))

(def_char MARIO_PROPBRID
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (flags (can_block T))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "bridge")))

(def_char MARIO_PROPPLAT
  (funs (ai_fun do_nothing) (draw_fun lower_draw))
  (flags (can_block T))
  (range 0 0)
  (states "addon/twist/art/mario.spe" (stopped "platform")))

