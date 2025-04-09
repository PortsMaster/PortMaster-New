;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights


(defun mine_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (select (aistate)
	      (0 (if (touching_bg)
		     (progn (set_state running)
			    (if (eq (xvel) 1)
				(progn
				  (with_object (bg)
					       (make_view_solid (find_rgb 250 10 10)))
				  (hurt_radius (x) (y) 40 35 nil 20))
			      (hurt_radius (x) (y) 40 25 nil 20))
			    (go_state 1))
		   (next_picture))
		   T)
	      (1 (next_picture)))
    T))




(def_char CONC
  (funs (ai_fun  mine_ai))
  (fields  ("xvel" conc_flash))
  (states "art/chars/mine.spe"
	  (running   (seq "mine" 1 8))
	  (stopped    '("mine0001.pcx" "mine_off"))))



(defun air_mine_ai ()
  (if (or (eq (total_objects) 0)                                 ;; turned on?
	  (not (eq (with_object (get_object 0) (aistate)) 0)))

      (if (touching_bg)
	  (progn
	    (if (eq (xvel) 1)
		(with_object (bg) (make_view_solid (find_rgb 250 10 10))))
	    (do_explo 40 25)
	    nil)
	(progn (next_picture)
	       T))
    T))

(def_char CONC_AIR
  (funs (ai_fun  air_mine_ai))
  (fields  ("xvel" conc_flash))
  (states "art/chars/mine.spe"
	  (stopped   (seq "amin" 1 2))))






(defun bomb_cons ()
  (setq blink_time 14))

(defun bomb_ai ()
  (select (aistate)
	  (0 ;; wait for a signal if connected, or wait for player touch
	   (if (activated)
	       (go_state 1)
	     T))

	  (1 ;; count down blink time until zero then blow up
	   (if (< blink_time 1)
	       (go_state 2)
	     (progn
	       (if (or (< blink_time 10)
		       (and (< blink_time 18) (eq (mod blink_time 2) 0))
		       (and (< blink_time 30) (eq (mod blink_time 3) 0))
		       (and (< blink_time 50) (eq (mod blink_time 4) 0)))
		   (progn
		     (play_sound TICK_SND 127 (x) (y))
		     (next_picture)))
	       (setq blink_time (- blink_time 1))
	       T)))

	  (2 ;; blow up
	   (let ((oldy (y)))
	     (set_y (- (y) (/ (picture_height) 2)))
	     (do_explo 40 (get_ability jump_yvel))
	     (if (> (get_ability jump_yvel) 100)
		 (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0))
	     (set_y oldy))
	   nil)))



(def_char BOMB
  (funs (ai_fun      bomb_ai)
	(constructor bomb_cons))
  (abilities (jump_yvel 30))
  (range 150 150)
  (vars blink_time)
  (fields ("blink_time" bomb_blink))
  (states "art/chars/mine.spe"
	  (stopped '("abomb0001.pcx" "abomb0002.pcx"))))

(def_char BIG_BOMB
  (funs (ai_fun      bomb_ai)
	(constructor bomb_cons))
  (abilities (jump_yvel 400))
  (range 150 150)
  (vars blink_time)
  (fields ("blink_time" bomb_blink))
  (states "art/chars/mine.spe"
	  (stopped '("abomb0001.pcx+" "abomb0002.pcx+"))))




(defun block_ai ()
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound CRUMBLE_SND 127 (x) (y))
	  (set_state dieing)
	  T))
    T))

(def_char BLOCK
					;block has only 1 frame now will have block blowing up
  (funs (ai_fun  block_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 30))
  (states "art/chars/block.spe"
	  (stopped       "block.pcx")
	  (dieing        (seq "bexplo" 1 7))))


(defun trap_door_ai ()
  (if (> (total_objects) 0)
      (select (aistate)
	      (0 ;; wait for switch to go off
	       (if (not (eq (with_object (get_object 0) (aistate)) 0))
		   (progn
		     (set_state running)
		     (go_state 1))))
	      (1 ;; wait for animation
	       (if (next_picture) T
		 (progn
		   (set_state blocking)
		   (set_aistate 2))))
	      (2 ;; just stay here
	       T)))
T)


(defun strap_door_ai ()
  (general_sdoor_ai nil))


(def_char TRAP_DOOR2
  (funs (ai_fun strap_door_ai))
  (flags (can_block T))
  (abilities (start_hp 30))
  (states "art/chars/tdoor.spe"
	  (stopped        "tdor0001.pcx")
	  (running        (seq "tdor" 1 7))
	  (walking        (seq "tdor" 7 1))
	  (blocking       "tdor0007.pcx")))


(def_char TRAP_DOOR3
  (funs (ai_fun strap_door_ai))
  (flags (can_block T))
  (abilities (start_hp 30))
  (states "art/chars/tdoor.spe"
          (stopped        "cdor0001.pcx")
          (running        (seq "cdor" 1 7))
          (walking        (seq "cdor" 7 1))
          (blocking       "cdor0007.pcx")))

(defun lightin_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (select (aistate)
	      (0  ;; delay
	       (if (< (state_time) (* (aitype) 2)) (set_state stopped)
		 (progn
					;		 (hurt_radius (x) (y) 40 30 nil 30)
		   (set_state running)
		   (play_sound ELECTRIC_SND 127 (x) (y))
		   (go_state 1))))
	      (1  ;; next picture
	       (if (next_picture) T
		 (set_aistate 0)))))
T)

(def_char LIGHTIN
  (funs (ai_fun lightin_ai))
  (flags (can_block T))
  (fields  ("aitype" lightin_speed))
  (states "art/chars/lightin.spe"
	  (running   (seq "lite" 1 9))
	  (stopped    "lite0001.pcx")))



(defun lava_ai ()
  (if (and (touching_bg) (eq (mod (state_time) 20) 0))
      (do_damage 6 (bg)))

  (select (aistate)
	  (0 (if (eq (random 100) 0)
		 (progn
		   (play_sound LAVA_SND 64 (x) (y))
		   (set_aistate 1)))
	     (next_picture))
	  (1 (next_picture)
	     (if (eq (state_time) 5)
		 (progn
		   (hurt_radius (x) (y) 20 20 nil 10)
		   (set_aistate 0)))))
  T)


(def_char LAVA
  (funs (ai_fun lava_ai))
  (states  "art/chars/lava.spe"
	   (stopped (seq "lava" 1 15))))


;; XXX: Mac Abuse reimplements this in C++
(defun tp2_ai ()
  (if (> (total_objects) 0)
      (select (aistate)
	      (0 ;; wait for player to activate
	       (if (and (touching_bg) (eq (total_objects) 1))
		   (progn
		     (if (with_object (bg) (pressing_action_key))
			 (progn
			   (link_object (bg))
			   (set_state running)
			   (play_sound TELEPORTER_SND 127 (x) (y))
			   (set_aistate 1))))))
	      (1 ;; wait for animation
	       (if (next_picture)
		   (let ((x (x))
			 (y (- (y) 16))
			 (fade (if (< (current_frame) 16) (current_frame) 15)))
		     (with_object (get_object 1)
				  (progn
				    (set_x x)
				    (set_y y)
				    (user_fun SET_FADE_COUNT fade)
				    (setq is_teleporting 1)
				    )))

		 (let ((x (with_object (get_object 0) (x)))
		       (y (with_object (get_object 0) (- (y) 16))))
		   (with_object (get_object 1)
				(progn
				  (set_x x)
				  (set_y y)
				  (setq is_teleporting 0)
				  (user_fun SET_FADE_COUNT 0)
				  ))
		   (remove_object (get_object 1))
		   (set_aistate 0))))))
  T)



(def_char TELE2
  (funs  (ai_fun tp2_ai))
  (flags (can_block  T))
  (states "art/chars/teleport.spe"
	  (stopped "close")
	  (running (seq "elec" 1 15))))


(defun bolder_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (if (eq (hp) 0)
	  (progn
	    (play_sound P_EXPLODE_SND 127 (x) (y))
	    (add_object EXPLODE1 (+ (x) (random 5)) (+ (y) (random 5)) 0)
	    (add_object EXPLODE1 (+ (x) (random 5)) (+ (y) (random 5)) 2)
	    (add_object EXPLODE1 (- (x) (random 5)) (- (y) (random 5)) 1)
	    (add_object EXPLODE1 (- (x) (random 5)) (- (y) (random 5)) 2)
	    (with_object (add_object SMALL_BOLDER (x) (y)) (progn (set_xvel -4) (set_yvel -8)))
	    (with_object (add_object SMALL_BOLDER (x) (y)) (progn (set_xvel 4) (set_yvel -9)))
	    (with_object (add_object SMALL_BOLDER (x) (y)) (progn (set_xvel 2) (set_yvel -5)))
	    (with_object (add_object SMALL_BOLDER (x) (y)) (progn (set_xvel -3) (set_yvel -5)))
	    (with_object (add_object SMALL_BOLDER (x) (y)) (progn (set_xvel -1) (set_yvel 2)))
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
	    (hurt_radius (x) (y) 19 30 (me) 15)
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


(defun bolder_cons ()
  (set_xvel -4)
  (set_yvel 0))


(defun bold_dam (amount from hitx hity push_xvel push_yvel)
  (add_object EXPLODE3 (+ (x) (- 10 (random 20))) (- (y) (random 30)) 0)
  (damage_fun amount from hitx hity (/ push_xvel 10) (/ push_yvel 2)))

(def_char BOLDER
  (funs  (ai_fun bolder_ai)
	 (damage_fun bold_dam)
	 (constructor bolder_cons))
  (flags (can_block  T)
	 (add_front  T)
	 (hurtable   T))
  (range 200 200)
  (abilities (start_hp 40))
  (fields ("xvel" ai_xvel)
	  ("yvel" ai_yvel)
	  ("hp"   ai_health)
	  )
  (states "art/bold.spe"
	  (stopped '("bold0001.pcx" "bold0001.pcx" "bold0001.pcx"
		    "bold0002.pcx" "bold0002.pcx" "bold0002.pcx"
		    "bold0003.pcx" "bold0003.pcx" "bold0003.pcx"
		    "bold0004.pcx" "bold0004.pcx" "bold0004.pcx"))))

(defun bounce_move (left_stub right_stub up_stub down_stub nothing_stub)
  (let ((old_yv  (yvel))
	(old_xv  (xvel))
	(status (float_tick)))
    (if (not (eq status T)) ;; T means we did not hit anything
	(let ((block_flags (car status)))
	  (if (blocked_up block_flags) ;; bounce up/down
	      (progn
		(set_xvel old_xv)
		(if (> old_yv 1)
		    (set_yvel (- 2 old_yv))
		  (set_yvel (- 0 old_yv)))
		(eval up_stub))
	    (if (blocked_down block_flags)
		(progn
		  (set_xvel old_xv)
		  (if (> old_yv 1)
		      (set_yvel (- 2 old_yv))
		    (set_yvel (- 0 old_yv)))
		  (eval down_stub))
	      (if (blocked_left block_flags)
		  (progn
		    (set_yvel old_yv)
		    (set_xvel (- 0 old_xv))
		    (eval left_stub))
		(if (blocked_right block_flags)
		    (progn
		      (set_yvel old_yv)
		      (set_xvel (- 0 old_xv))
		      (eval right_stub)))))))
      (eval nothing_stub))))



(defun small_rock_ai ()
  (next_picture)
  (set_yvel (+ (yvel) 1))
  (bounce_move T T T
	       '(progn (add_object EXPLODE1 (+ (x) (random 10)) (- (+ (random 5) (y)) 10)     0)
		 (add_object EXPLODE1 (- (x) (random 10)) (- (- (y) (random 5)) 10) 2)
		 (play_sound P_EXPLODE_SND 127 (x) (y))
		 (hurt_radius (x) (y) 40 15 (if (> (total_objects) 0)
						(get_object 0)
					      nil) 20)
		 nil) T))


(def_char SMALL_BOLDER
  (funs  (ai_fun small_rock_ai))

  (flags (add_front  T)
	 (unlistable T))

  (states "art/bold.spe"
	  (stopped "bsmall")))







