;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun jug_ai ()
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (if (not (next_picture))
	      (progn
		(with_object (bg) (set_kills (+ (kills) 1)))
		nil)
	      T)
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
		     (if (> (state_time) (aitype))
			 (progn
			   (set_state weapon_fire)
			   (set_aistate 2)))))

		  (2 ;; start fire
		   (if (> (state_time) 3)
		       (let ((myself (me))
			     (xspeed (* throw_xvel (direction)))
			     (yspeed throw_yvel))
			 (with_object (add_object GRENADE (x) (- (y) 24) 1)
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

(defun jug_cons ()
  (setq throw_xvel 13)
  (setq throw_yvel -10)
  (set_aitype 10))

(defun explo_damage_cache (type)
  (list (list EXPLODE6) nil))

(def_char JUGGER
  (range 200 0)
  (funs (ai_fun     jug_ai)
	(constructor jug_cons)
	(get_cache_list_fun explo_damage_cache)
	(damage_fun explo_damage))
  (flags (hurtable T))
  (abilities (start_hp    50)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        jug_throw_spd)
	  ("throw_xvel"    jug_throw_xv)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "art/jug.spe"
	  (stopped "robo0001.pcx")
	  (running (seq "rwlk" 1 13))
	  (weapon_fire (seq "robo" 1 10))
	  (dieing (seq "jugdie" 1 8))))

;; AI for cleaner robot machine "ROB1"
;; The robot waits for a sensor/switch/gate to turn it
;; on before appearing
(defun rob1_ai ()
  (if (not (eq (fade_count) 0))             ;; appearing?
      (set_fade_count (- (fade_count) 1)))  ;; fade in
  (select (aistate)
	  (0 ;; wait for sensor to turn on
	   (if (eq rob_hiden 1)
	       (progn
		 (set_targetable nil)       ;; can't lock into us while hiden
		 (set_state rob_hiding))    ;; set invisible animation frame
	     (progn
	       (set_targetable T)           ;; can lock into us
	       (push_char 30 55)))          ;; push player away

	   (if (or (< (total_objects) 1)    ;; if not linked or link is on
		   (not (eq (with_object (get_object 0) (aistate)) 0)))
	       (progn
		 (if (eq rob_hiden 1)
		     (set_fade_count 15))
		 (set_aistate 1)))
	   T)
	  (1 ;; walk towards player
	   (push_char 30 55)                      ;; push her back
	   (next_picture)                         ;; go to next animation frame
	   (if (eq (mod (state_time) 6) 0)        ;; play sound every 6 ticks
	       (play_sound CLEANER_SND 127 (x) (y)))
	   (try_move 0 10)                        ;; see how far ahead we can move
	   (if (> (direction) 0)                  ;; moving right
	       (if (can_see (x) (y) (+ (x) (xvel) 23) (y) nil)   ;; can we see 23 pixels ahead?
		     (set_x (+ (x) (xvel))))
	     (if (can_see (x) (y) (- (x) (xvel) 23) (y) nil)
		   (set_x (- (x) (xvel)))))

	   (if (<= (hp) 0)                        ;; are we dead, if so blow up
	       (progn
		 (add_object EXPLODE1 (+ (x) 5) (- (y) 10)     0)
		 (add_object EXPLODE1 (+ (x) -5) (- (y) 15)    2)  ;; wait 2 frames before appearing
		 (add_object EXPLODE1 (+ (x) 10) (- (y) 2)     1)
		 (add_object EXPLODE1 (+ (x) -10) (- (y) 20)   3)
		 (add_object EXPLODE1 (+ (x) 20) (- (y) 27)    4)
		 (add_object EXPLODE1 (+ (x) -25) (- (y) 30)   2)
		 (add_object EXPLODE1 (+ (x) 20) (- (y) 5)     4)
		 (add_object EXPLODE1 (+ (x) -3) (- (y) 1)     5)
		 (set_aistate 2)))
	   T)
	  (2 ;; dead, wait a few frames then return nil
	   (push_char 30 55)
	   (< (state_time) 3))))  ;; return nil (dead) if we've been in this state for 3 frames



(defun explo_damage (amount from hitx hity push_xvel push_yvel)
  (add_object EXPLODE6 (+ (x) (- 10 (random 20))) (- (y) (random 30))     0)
  (damage_fun amount from hitx hity 0 0)
  (if (eq 0 (hp))
      (play_sound BLOWN_UP 127 (x) (y))))

(defun rob_cons () (set_xvel 2))

(def_char ROB1
  (range 200 0)
  (funs (ai_fun     rob1_ai)
	(constructor rob_cons)
	(get_cache_list_fun explo_damage_cache)
	(damage_fun explo_damage))
  (flags (hurtable T)
	 (can_block T))
  (abilities (run_top_speed 4)
	     (start_hp      70)
	     (push_xrange   1))
  (vars rob_hiden)
  (fields ("xvel"         ai_xvel)
	  ("aitype"       rob_noturn)
	  ("rob_hiden"    rob_hide)
	  ("hp"           ai_health))
  (states "art/rob1.spe"
	  (rob_hiding             "hiding")
	  (stopped (seq "clen" 1 10))))

(defun who_ai ()
  (if (eq (hp) 0)
      nil
    (progn
      (set_xvel (+ (xvel) (* (+ (mod (state_time) 10) -4) (direction))))
      (if (< (xvel) -15) (set_xvel -15))
      (if (> (xvel) 15) (set_xvel 15))
      (if (not (next_picture)) (set_state stopped))
      (bounce_move '(progn
		      (set_direction (- 0 (direction)))
		      (set_state turn_around))
		   '(progn
		      (set_direction (- 0 (direction)))
		      (set_state turn_around))
		   nil nil nil)
      T)))

(defun who_cache (type) `((,STRAIT_ROCKET) nil))

(def_char WHO
  (range 200 100)
  (funs (ai_fun flyer_ai)
	(damage_fun  flyer_damage)
	(get_cache_list_fun who_cache)
	(constructor flyer_cons))

  (flags (hurtable T))
  (abilities (start_hp 20))
  (vars fire_delay burst_delay burst_total burst_wait burst_left
	max_xvel   max_yvel    smoke_time fire_time)
  (fields ("fire_delay"   who_fdelay)
	  ("burst_delay"  who_bdelay)
	  ("burst_total"  who_btotal)
	  ("max_xvel"     who_mxv)
	  ("max_yvel"     who_myv)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))

  (states "art/rob2.spe"
	  (stopped (seq "wgo" 1 3))
	  (running (seq "wgo" 1 3))
	  (turn_around (seq "wtrn" 1 9))
	  (flinch_up  '("flinch" "flinch" "flinch"))
	  ))


/*   --- not working
(defun burst_fire (firex firey angle)
  (if (> fire_time 0);; if we need to wait till next burst
      (progn
	(setq fire_time (- fire_time 1))
	(if (eq fire_time 0)
	    (progn
	      (setq burst_left burst_total)
	      (setq burst_wait 0))))
    (if (eq burst_wait 0)
	(progn
	  (if (or (eq burst_left 1) (eq burst_left 0))
	      (setq fire_time fire_delay)
	    (setq burst_left (- burst_left 1)))
	  (setq burst_wait burst_delay)
	  (fire_object (me) (aitype) firex firey angle (bg)))
      (setq burst_wait (- burst_wait 1)))))


(defun wrob_cons ()
  (setq fire_delay 4)
  (setq burst_delay 1)
  (setq max_xvel 10)
  (setq max_yvel 5)
  (set_aitype 0)
  (setq burst_total 5))


(defun wrob_ai ()
  (if (eq (hp) 0)
      nil
    (progn
      (select (aistate)
	      (0;; walk toward player
	       (if (or (> (distx) 120) (not (eq (direction) (toward))))
		   (progn
		     (move (toward) 0 0)
		     (next_picture))
		 (progn
		   (set_state stopped)
		   (set_aistate 1))))
	      (1;; stop and fire
	       (burst_fire  (+ (x) (* (direction) 28)) (- (y) 35)
			    (if (> (direction) 0)
				(mod (- 375 (/ (* burst_left 30) burst_total)) 360)
			      (+ 165 (/ (* burst_left 30) burst_total))))
	       (if (not (eq fire_time 0))
		   (set_aistate 0))))
      T)))




(def_char WALK_ROB
  (funs (ai_fun wrob_ai)
	(constructor wrob_cons)
	(damage_fun  guner_damage))
  (abilities (run_top_speed 12))
  (flags (hurtable T) (can_block T))
  (range 300 100)
  (vars fire_delay burst_delay burst_total burst_wait burst_left
	max_xvel   max_yvel    smoke_time fire_time)
  (fields ("fire_delay"   wrob_fdelay)
	  ("burst_delay"  wrob_bdelay)
	  ("burst_total"  wrob_btotal)
	  ("max_xvel"     wrob_mxv)
	  ("max_yvel"     wrob_myv)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))

  (states "art/rob2.spe"
	  (stopped "wwlk0001.pcx")
	  (running (seq "wwlk" 1 10))
	  (start_run_jump "wstart_jump")
	  (flinch_up      "wflinch")
	  (run_jump       "wwlk0009.pcx")
	  ))



*/
