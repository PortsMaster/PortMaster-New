;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(setq bright_tint (def_tint "art/tints/cop/bright.spe"))  ;; used when the player fires a weapon
(setq player_tints (make-array 8 :initial-contents (list
						    0                                      ; 0 this is not used
						    (def_tint "art/tints/cop/blue.spe")    ; 1 bright blue
						    (def_tint "art/tints/cop/yellow.spe")  ; 2 yellow
						    (def_tint "art/tints/cop/fire.spe")    ; 3 red-yellow
						    (def_tint "art/tints/cop/olive.spe")   ; 4 green
						    (def_tint "art/tints/cop/pinkish.spe") ; 5 pink
						    (def_tint "art/tints/cop/darkblue.spe") ; 6 darkblue
						    (def_tint "art/tints/cop/purple.spe")  ; 7 purple

)))

(setq player_text_color (make-array 8 :initial-contents (list
							 43       ; 0 brown
							 216      ; 1 blue
							 76       ; 2 yellow
							 82       ; 3 orange
							 148      ; 4 green2
							 90       ; 5 red
							 231      ; 6 darkblue
							 192)))   ; 7 purple

(setq cop_dead_parts (make-array (* 4 3) :initial-contents
			       ;       head           arm            leg
			     '((CP_1  "4dha") (CP_2  "4daa") (CP_3  "4dba")     ; disapear
			       (CP_4  "4dhf") (CP_5  "4daf") (CP_6  "4dbf")     ; flaming
			       (CP_7  "4dae") (CP_8  "4dle") (CP_9  "4dbe")     ; electrical
			       (CP_10 "4dhn") (CP_11 "4dan") (CP_12 "4dbn"))))  ; normal


(do ((i 0 (setq i (+ i 1))))
	   ((>= i 12) nil)
	   (setq (aref cop_dead_parts i)
		 (make_dead_part (car (aref cop_dead_parts i))
				 (car (cdr (aref cop_dead_parts i))) 4 "art/cop.spe" 'dead_cop_part_draw)))





(setf fast_image (def_image "art/misc.spe" "fast_image"))
(setf fly_image (def_image "art/misc.spe" "fly_image"))
(setf sneaky_image (def_image "art/misc.spe" "sneaky_image"))
(setf health_image (def_image "art/misc.spe" "b_check_image"))
(setf shlamp_image (def_image "addon/aliens/aliens.spe" "slmp_img"))



(defun give_player_health (amount)
  (let ((h_amount  (select difficulty
			   ('easy    amount)
			   ('medium  (/ (* amount 3) 4))
			   ('hard    (/ amount 2))
			   ('extreme (/ amount 5))))
	(h_max (if (eq special_power HEALTH_POWER)
		   200
		 100)))
    (if (eq (hp) h_max)
	nil
      (progn
	(if (<= (+ (hp) h_amount) h_max)
	    (add_hp h_amount)
	  (add_hp (- h_max (hp))))
	(setq b_ramp (+ b_ramp (* h_amount 2)))

	T)))
)



(defun pressing_action_key ()
  (> (player_y_suggest) 0))


; signals for user function
(enum 'SET_SNEAKY_TIME
      'SET_VISOR_TIME
      'SET_FAST_TIME
      'SET_FADE_COUNT
)


; states for cop
(enum 'JUST_START
      'NORMAL_PLAY)


(enum 'NO_POWER
      'FAST_POWER
      'FLY_POWER
      'SNEAKY_POWER
      'HEALTH_POWER
      'SHLAMP_POWER)

; this is called by the engine when a level is loaded with no player_info in it
; i.e. not for savegames
; this function is called once for each player object
(defun set_player_defaults ()
  (set_ambient_light (me) 35)
  (set_aistate 0)
  (set_fade_count 0)
  (setq in_climbing_area 0)
  (setq disable_top_draw 0)
  (setq just_hit 0)
  (setq	used_special_power 0)
  (setq has_saved_this_level 0)
  (setq r_ramp 0)
  (setq g_ramp 0)
  (setq b_ramp 0)
  (setq is_teleporting 0)
  (setq just_fired 0)
  (setq has_compass 0)
  (setq special_power NO_POWER))



(defun cop_ufun (signal value)
  (if (< (total_objects) 1)    ; make sure upper body is there
      nil
    (select signal
	    (SET_SNEAKY_TIME
	     (progn
	       (set_sneaky_time value)
	       (with_obj0 (set_sneaky_time value))))
	    (SET_VISOR_TIME (set_visor_time value))
	    (SET_FAST_TIME
	     (progn
	       (set_fast_time value)
	       (with_obj0 (set_fast_time value))))
	    (SET_FADE_COUNT (set_fade_count value)
			    (with_obj0 (set_fade_count value)))

	    )))


(defun cop_adjust_top (return)
  (if (< (total_objects) 1)        ;; should be here
      (let ((me (me)))
	(link_object (add_object_after MGUN_TOP (x) (y)))
	(with_obj0 (link_object me))
	))
  return
)

(defun climb_off_handler ()
  (if (next_picture)
      (progn
	(view_push_down 4)
	0)
    (progn
      (set_y (- (y) 28))
      (set_state stopped)
      0)))

(defun climb_handler (xm ym but)
  (let ((yd in_climbing_area))
    (setq in_climbing_area 0)
    (if (eq (state) climb_off)
	(climb_off_handler)
      (if (eq (state) climbing)
	  (progn
	    (if (> ym 0)
		(progn
		  (if (eq (current_frame) 0) (set_current_frame 9)
		    (set_current_frame (- (current_frame) 1)))
		  (set_y (+ (y) 3)))
	      (if (< ym 0)
		  (progn
		    (if (< yd 32)
			(set_state climb_off)
		      (progn
			(if (not (next_picture)) (set_state climbing))
			(set_y (- (y) 3)))))))
	    (if (not (eq xm 0))
		(if (can_see (x) (- (y) 20) (x) (y) nil)
		    (if (eq ym 0)
			(progn
			  (set_state run_jump_fall)
			  (set_gravity 1))
		      (progn
			(set_state run_jump)
			(set_yvel (get_ability jump_yvel))
			(set_gravity 1)
			))))

	    0)
	(if (and (>= (yvel) 0) (or (> ym 0)
				   (and (< ym 0) (> yd 8))))
	    (progn
	      (set_state climbing)
	      (set_gravity 0)
	      (set_xvel 0)
	      (set_yvel 0)
	      (set_xacel 0)
	      (set_yacel 0)
	      0)
	  (progn
	    (next_picture)
	    (cop_adjust_top (mover xm ym but))))
	))))


(defun undo_special_power (xm ym but)
  (select special_power
	  (FAST_POWER   (setq used_special_power 0))
	  (SNEAKY_POWER (if (> used_special_power 0)
			    (setq used_special_power (- used_special_power 1))))))

(defun do_special_power (xm ym but)
  (select special_power
	  (FLY_POWER
	   (add_object CLOUD (+ (+ (x) (* (direction) -10)) (random 5)) (+ (y) (random 5)))
	   (set_state run_jump)
	   (set_gravity 1)
	   (set_yacel 0)
	   (if (> (yvel) 0) (set_yvel (/ (yvel) 2)))
	   (set_yvel (- (yvel) 2))
	   (if (< ym 0)
	       (set_yvel (- (yvel) 1)))
	   )


	  (FAST_POWER
	   (setq used_special_power 1)
	   (setq last1_x (x))
	   (setq last1_y (y))
	   (if (> (total_objects) 0)
	       (with_obj0
			    (if (> fire_delay1 0)
				(setq fire_delay1 (- fire_delay1 1)))))


	   (let ((in_area in_climbing_area)
		 (old_yvel (yvel)))
	     (player_move xm ym but)
	     (setq in_climbing_area in_area)
	     (if (and (< ym 0) (eq old_yvel 0) (< (yvel) 0))
		 (set_yvel (+ (yvel) (/ (yvel) 3))))

	     )

	   (setq last2_x (x))
	   (setq last2_y (y)))

	  (SNEAKY_POWER (if (<= used_special_power 15)
			    (setq used_special_power (+ used_special_power 1))))
	  ))

(defun player_move (xm ym but)
  (if (eq in_climbing_area 0)
      (progn
	(if (eq (state) climbing)
	    (progn
	      (set_gravity 1)
	      (set_state run_jump_fall)))
	(next_picture)
	(cop_adjust_top (mover xm ym but)))
    (climb_handler xm ym but)))

/*(defun cop_mover (xm ym but)
  (if (> (yvel) 10)
      (progn
	(set_yacel 0)
	(set_yvel (- (yvel) 1))))  ;; terminal velocity
  (select (aistate)
	  (JUST_START
	   (if (eq but 0)              ; wait till user lets go of button before moving
	       (progn
		 (set_aistate NORMAL_PLAY)
		 (mover xm ym but))
	     (cop_adjust_top (tick))))
	  (NORMAL_PLAY
	   (if (or (<= (hp) 0) (eq (state) dieing) (eq (state) dead))    ; are we dead?
	       (progn
		 (if (not (eq (state) dead))
		     (if (not (eq (state) dieing))
			 (progn
			   (set_state dieing)
			   (set_xvel 0)
			   (set_yvel 0)
			   (set_xacel 0)
			   (set_yacel 0))
		       (if (not (next_picture))
			   (set_state dead) nil))
		   (if (not (eq but 0)) ; wait till dead and pressing but, then reset
		       (progn
			 (restart_player)
			 (set_aistate JUST_START))
			 (cop_adjust_top (tick))))
		 0)

	     ; normal play code
	     (progn
	       ; check to see if player is firing
	       (if (equal (bit-and but 1) 1)
		   (do_special_power xm ym but)
		 (undo_special_power xm ym but))

	       (let ((ret (player_move xm ym but))
		     (other (me)))
		 (with_obj0
			      (progn
				(set_x (with_object other (x)))
				(set_y (- (- (with_object other (y)) -29)
					  (with_object other (picture_height))))
				))
		 (if (and (equal (bit-and but 2) 2)
			  (not (eq (state) dead)) (not (eq (state) dieing)))
		     (let ((ammo (ammo_total (current_weapon_type))))
		       (add_ammo (current_weapon_type) (with_obj0
								    (user_fun 'FIRE ammo)))
		       nil))
		 ret)
	       )))))

)*/

;;(defun normal_bottom_mover ()  ;; just runs around

(defun dead_cop_part_draw ()
  (if (eq (aitype) 0)
      (draw)
    (draw_tint (aref player_tints (aitype)))))

(defun bottom_damage (amount from hitx hity push_xvel push_yvel)  ; transfer damage to lower half
  (if (eq is_teleporting 1)
      nil
    (let ((amount (select difficulty;; reduce damage according to difficulty
			  ('easy   (/ amount 2))
			  ('medium (/ (* amount 3) 4))
			  ('hard    amount)
			  ('extreme (* amount 3))
			  )))


      (select (aistate)
	      (NORMAL_PLAY (if (and (not (eq (state) dieing)) (not (eq (state) dead)))
			       (progn
				 (if (eq (random 2) 0)
				     (set_state flinch_up)
				   (set_state flinch_down))
				 (if (local_player)
				     (progn
				       (setq r_ramp (+ r_ramp (* amount 7)))
				       (setq g_ramp (- g_ramp (* amount 14)))
				       (setq b_ramp (- b_ramp (* amount 14)))
				       (if (> r_ramp 120) (setq r_ramp 120))
				       (if (< g_ramp 0) (setq g_ramp 0))
				       (if (< b_ramp 0) (setq b_ramp 0))))

				 (damage_fun amount from hitx hity (/ push_xvel 2) (/ push_yvel 2))
				 (if (eq (hp) 0)
				     (progn
				       (if (and (time_for_next_level) (nth current_net_level net_levels))
					   (progn
					     (show_kills)
					     (reset_kills)
					     (setq current_net_level (+ current_net_level 1))
					     (if (not (nth current_net_level net_levels))
						 (setq current_net_level 0))

					     ;; save the level we are so joining clients know which one to load
					     (if (not (am_a_client))
						 (open_file "config/cur_lev.lsp" "wb"
							    (print `(setq current_net_level ,current_net_level))))

					     (request_level_load (nth current_net_level net_levels))))

				       (create_dead_parts cop_dead_parts (* (get_dead_part from) 3) (player_number))
				       (play_sound (aref PLAYER_DEATH (random 4)) 127 (x) (y)))
				   (if (> amount 8)
				       (play_sound (aref PLAYER_PAIN (random 4)) 127 (x) (y)))))))


	      )))
  )

(defun should_draw_top? (mode)
  (select mode
	  (JUST_START T)
	  (NORMAL_PLAY T)))

(defun change_mode (new_mode)
  (setq disable_top_draw (if (should_draw_top? new_mode) 0 1))
  (set_aistate new_mode))

(defun draw_fast ()
  (if  (local_player)
      (put_image (- (view_x2) 20) (+ (view_y1) 5) fast_image))
		       (if (eq used_special_power 1)
			   (if (> (total_objects) 0)
			       (let ((nowx (x))
				     (nowy (y))
				     (l2x last2_x)
				     (l2y last2_y)
				     (l1x last1_x)
				     (l1y last1_y)
				     (td (top_draw_state (state)))
				     (h   (picture_height)))

				 (set_x l2x)
				 (set_y l2y)
				 (draw_transparent 5 16)
				 (if td (with_obj0 (progn (set_x l2x)
								    (set_y (- (- l2y -29) h))
								    (draw_transparent 5 16))))
				 (set_x last1_x)
				 (set_y last1_y)
				 (draw_transparent 10 16)

				 (if td (with_obj0 (progn (set_x l1x)
								    (set_y (- (- l1y -29) h))
								    (draw_transparent 10 16)
								    (set_x nowx)
								    (set_y nowy)
								    )))

				 (set_x nowx)
				 (set_y nowy)))))

(defun sneaky_draw (count num)
  (print count)
  (if (eq count 0)
      (player_draw num)
    (if (> count 15)
	(draw_predator)
      (draw_transparent count 16))))

(defun player_draw (num)
  (if (eq num 0)
      (if (eq just_fired 1)           ;; if they just fired a weapon, draw them lite up.. use the bright tint
	  (progn
	    (draw_tint bright_tint)
	    (setq just_fired 0))      ;; ok to change this in the draw function only if it is not accessed anywhere else!
	(draw)
;	(draw_tint (aref player_tints (aitype)))
	)
    (if (eq just_fired 1)
	(progn
	  (draw_double_tint (aref player_tints num) bright_tint)
	  (setq just_fired 0))      ;; ok to change this in the draw function only if it is not accessed anywhere else!
      (draw_tint (aref player_tints num)))))

/*(defun bottom_draw ()
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
	  (JUST_START (player_draw (player_number)))
	  (NORMAL_PLAY
	   (select special_power
		   (NO_POWER (player_draw (player_number)))
		   (HEALTH_POWER (player_draw (player_number))
				 (if (local_player)
				     (put_image (- (view_x2) 20) (+ (view_y1) 5) health_image)))
		   (FAST_POWER (draw_fast) (player_draw (player_number)))
		   (FLY_POWER   (player_draw (player_number))
				(if (local_player)
				    (put_image (- (view_x2) 20) (+ (view_y1) 5) fly_image)))
		   (SNEAKY_POWER
		    (if (local_player)
			(put_image (- (view_x2) 20) (+ (view_y1) 5) sneaky_image))
				 (sneaky_draw used_special_power (player_number)))
		   (SHLAMP_POWER (player_draw (bottom_draw (player_number)))
		    (if (local_player)
			(put_image (- (view_x2) 20) (+ (view_y1) 5) shlamp_image)))
	  ))))*/

(defun frabs_bottom_draw()
  (if (eq special_power SHLAMP_POWER)
      (progn
        (setq special_power NO_POWER)
        (bottom_draw)
        (setq special_power SHLAMP_POWER))
      (bottom_draw)))

(defun restart_player ()
  (setq special_power 0)
  (setq has_compass 0)
  (if (and (local_player) (not (and (eq r_ramp 0)
				    (eq g_ramp 0)
				    (eq b_ramp 0))))
      (progn
	(setq r_ramp 0)
	(setq g_ramp 0)
	(setq b_ramp 0)
	(tint_palette 0 0 0)))

  (if (eq (total_players) 1)     ;; is this a single player game?
      (request_level_load  (if (eq has_saved_this_level 0)
			       (progn
				 (set_hp 100)
				 (level_name))
			     (concatenate 'string "save" (digstr has_saved_this_level 4) ".spe")))
    (reset_player)

    ))



(defun start_cache (type)
  `((,DARNEL) nil))

(def_char START
  (funs (ai_fun   do_nothing)
	(get_cache_list_fun start_cache)
	(draw_fun dev_draw))
  (range 0 0)
  (states "art/misc.spe" (stopped "start_image")))


(defun cop_cache (type)
  `(() (,bright_tint)))

(defun p_compass_draw (player)
  (if player
      (with_object player
		   (if (or (not (eq special_power SNEAKY_POWER)) (local_player))
		       (let ((spot (game_to_mouse (x) (y))))
			 (draw_rect (- (first spot) 1)
				    (- (second spot) 1)
				    (+ (first spot) 1)
				    (+ (second spot) 1)
				    (aref player_text_color (player_number)))))
		   (p_compass_draw (next_focus player)))))


(defun compass_draw ()
  (if (and (local_player) (eq (mod (game_tick) 2) 0))
      (if (eq has_compass 1)
	  (p_compass_draw (first_focus))
	(let ((spot (game_to_mouse (x) (y))))
	  (draw_rect (- (first spot) 1)
		     (- (second spot) 1)
		     (+ (first spot) 1)
		     (+ (second spot) 1)
		     (aref player_text_color (player_number)))))))


(def_char DARNEL
  (vars in_climbing_area
	disable_top_draw
	just_hit
	ship_pan_x
	special_power
	used_special_power
	last1_x last1_y
	last2_x last2_y
	has_saved_this_level
	r_ramp g_ramp b_ramp
	is_teleporting
	just_fired
	has_compass
	)
  (range 50 50)
  (abilities (walk_top_speed    3)
	     (jump_yvel       -15)
	     (run_top_speed     9)
	     (jump_top_speed   10)
	     (jump_xvel         9)
	     (stop_accel        9)
	     (start_accel       8)
	     (start_hp        100)
	     (hamper_xrange    80)
	     (push_xrange       9))

  (flags     (hurtable          T)
	     (unlistable        T))

  (funs (move_fun           cop_mover)
	(damage_fun         bottom_damage)
	(draw_fun           frabs_bottom_draw)
	(map_draw_fun       compass_draw)
	(get_cache_list_fun cop_cache)
	(user_fun           cop_ufun))

  (states "art/cop.spe"
          (stopped            (seq "stopped" 1 6))
	  (running            (seq "4wlk" 1 10))

	  (fast_running       (seq "4fst" 1 10))
	  (fly_running        (seq "4fly" 1 10))

	  (fast_stopped        (seq "bot2" 7 12))
	  (fly_stopped       (seq "bot2" 1 6))

	  (dead               "dead")

	  (start_run_jump     "jump_up")
	  (run_jump           "jump_up")
	  (run_jump_fall      "jump_down")
	  (end_run_jump       (seq "4jmp" 3 5))

	  (fly_start_run_jump     "4flj0002.pcx")
	  (fly_run_jump           "4flj0002.pcx")
	  (fly_run_jump_fall      "4flj0003.pcx")
	  (fly_end_run_jump       (seq "4flj" 4 6))

	  (fast_start_run_jump     "4fjp0002.pcx")
	  (fast_run_jump           "4fjp0002.pcx")
	  (fast_run_jump_fall      "4fjp0003.pcx")
	  (fast_end_run_jump       (seq "4fjp" 4 6))


	  (flinch_up           (rep "4flh0002.pcx" 4))
	  (flinch_down         (rep "4flh0003.pcx" 4))

	  (climbing             (seq "4lad" 1 10))
	  (climb_off            (seq "4off" 1 8))
	  (climb_on            (seq "4off" 8 1))
	  ))


(defun clone_ai ()
  (if (and (< (state_time) 200) (not (eq (state) dead)))
      (progn
	(select (direction)
		(1 (if (blocked_right (move 1 0 0))
		       (set_direction -1)
		     nil))
		(-1 (if (blocked_left (move -1 0 0))
			(set_direction 1)
		      nil)))
	    (if (or (> (state_time) 185) (eq (state) dieing))
		(set_fade_count (+ (fade_count) 1))
	      nil)
	    T)
	nil))




(defun top_draw_state (state)

  (or (eq state stopped) (eq state running)
			(eq state run_jump) (eq state run_jump_fall)
			(eq state end_run_jump)))

/*(defun top_draw ()
  (if (> (total_objects) 0)
      (let ((other  (get_object 0)))
	(if (or (with_object other (morphing))
		(eq (with_object other disable_top_draw) 1)
		(not (top_draw_state (with_object other (state)))))
	    nil
	  (progn
	    (if (eq (with_object other special_power) SNEAKY_POWER)
		(sneaky_draw (with_object other used_special_power)
			     (with_object other (player_number)))
	      (let ((nowx (x))
		    (nowy (y)))
		(set_x (with_object other (if (> (direction) 0) (x) (+ (x) 2))))
		(set_y (- (- (with_object other (y)) -29) (with_object other (picture_height))))
		(player_draw  (with_object other (player_number)))
		(set_x nowx)
		(set_y nowy))
	      ))))))
*/

(defun ammo_type ()
  (select (otype)
	  (GRENADE_TOP  2)
	  (MGUN_TOP     10)
	  (FIREBOMB_TOP 5)
	  (ROCKET_TOP   3)
	  (PGUN_TOP     4)
	  (LSABER_TOP   5)
	  (DFIRS_TOP    6)
	  ))

(defun ammo_delay ()
  0)


(defun player_angle_suggestion ()
  (atan2 (- (y) (player_pointer_y) 16)
	 (- (player_pointer_x) (x))))


(defun player_fire_weapon (type target)
  (let ((angle (with_obj0 (player_angle_suggestion))))

    (let ((firex (+ (x) (* (cos angle) 17) (xvel)))
	  (firey (+ (- (y) (* (sin angle) 16) 20) (yvel))))
      (if (can_see (x) (- (y) 16) firex firey nil)
	  (progn
	    (fire_object  (get_object 0) type firex firey angle target)
	    T)
	nil))))

/* (defun top_ai ()
  (if (> (total_objects) 0)
      (let ((myself (get_object 0)))

	(set_state rotate)
	(let ((angle (with_object myself
					    (if (> (direction) 0)
						(player_angle_suggestion)
					      (if (> (player_angle_suggestion) 180)
						  (- (player_angle_suggestion) 180)
						(+ 180 (player_angle_suggestion)))))))
	  (setq point_angle angle)
	  (set_frame_angle 0 359 angle))
	(if (not (eq fire_delay1 0))
	    (setq fire_delay1 (- fire_delay1 1)))
	(if (eq (with_object myself (weapon_to_type (current_weapon_type))) (otype))
	    (select (aistate)
		    (2			; start fire up
		     (progn
		       (set_state rotate_fire)
		       (set_frame_angle 0 359 (with_object myself
					    (if (> (direction) 0)
						(player_angle_suggestion)
					      (if (> (player_angle_suggestion) 180)
						  (- (player_angle_suggestion) 180)
					      (+ 180 (player_angle_suggestion))))))
		       ;; (set_state weapon_fire)
;;		       (set_fire_delay1 3)

;;			    (let ((otype (otype)))
;;			      (with_object myself (add_ammo otype -1)))
;;			    (with_object (add_object (ammo_type) (x) (- (y) 16) 1)
;;					 (user_fun myself))
			  (set_aistate 3)))
		    (1			; special power
		     (progn (set_state weapon_fire_up)
			    (let ((otype (otype)))
			      (with_object myself (add_ammo weapon_type -1)))
			    (with_object (add_object (ammo_type) (x) (- (y) 20) 2)
					 (user_fun myself))
			    (set_aistate 3)))
		    (3 (if (eq fire_delay1 0) ;; (user_fun 'RESET_FIRE_OK nil)
			   (set_aistate 0)
			 (progn
			   (user_fun 'CONTINUE_FIRE nil)
			   (setq fire_delay1 (- fire_delay1 1)))
			 )))
	  (set_otype (with_object myself (weapon_to_type (current_weapon_type)))))))
  (move 0 0 0)
  T)

;(defun top_damage (amount from hitx hity push_xvel push_yvel)  ; transfer damage to lower half
;  (with_obj0 (damage_fun amount from hitx hity push_xvel push_yvel)))


(defun laser_ufun (signal value)
  (select signal
	  ('FIRE (if (eq (aistate) 0)  ;;  not already firing
		     (if (> value 0)   ;; have ammo
			 (progn
			   (setq fire_delay1 3)
			   (set_aistate 2)
			   (if (player_fire_weapon (ammo_type) nil)
			       -1
			     0))
		       (progn
			 (setq fire_delay1 7)
			 (set_aistate 2)
			 (player_fire_weapon (ammo_type) nil)

			 0))
		   0))
	  ('RESET_FIRE_OK (>= (state_time) fire_delay1))))

(defun top_ufun (signal value)
  (select signal
	  ('FIRE (if (and (> value 0) (eq (aistate) 0))  ;; have ammo and not already firing
		     (progn
		       (setq fire_delay1 12)
		       (set_aistate 2)
		       (if (player_fire_weapon (ammo_type) nil)
			   -1
			 0))
		   0))
	  ('RESET_FIRE_OK (>= (state_time) fire_delay1))))



(defun plaser_ufun (signal value)
  (select signal
	  ('FIRE (if (and (> value 0) (eq (aistate) 0))  ;; have ammo and not already firing
		     (progn
		       (setq fire_delay1 2)
		       (set_aistate 2)
		       (if (player_fire_weapon (ammo_type) nil)
			   -1 0))
		   0))

	  ('RESET_FIRE_OK (>= (state_time) fire_delay1))))



(defun player_rocket_ufun (signal value)
  (select signal
	  ('FIRE (if (and (> value 0) (eq (aistate) 0))  ;; have ammo and not already firing
		     (progn
		       (setq fire_delay1 12)
		       (set_aistate 2)
		       (if (player_fire_weapon (ammo_type)
					   (with_obj0 (find_object_in_area
									(- (x) 160) (- (y) 160)
									(+ (x) 160) (+ (y) 160)
									bad_guy_list)))
			   -1 0))
		   0))
	  ('RESET_FIRE_OK (>= (state_time) fire_delay1)))) */




(defun top_cache (type)
  (list
   (select type
	   (MGUN_TOP      (list SHOTGUN_BULLET))
	   (GRENADE_TOP   (list GRENADE))
	   (ROCKET_TOP    (list ROCKET))
	   (FIREBOMB_TOP  (list FIREBOMB))
	   (PGUN_TOP      (list PLASMAGUN_BULLET))
	   (LIGHT_SABER   (list LSABER_BULLET))
	   (DFRIS_TOP     (list DFRIS_BULLET))
   nil)))


(defun make_top_char (symbol base ufun dfun)
  (eval (list 'def_char symbol
	      `(funs (ai_fun    top_ai)
		     (get_cache_list_fun top_cache)
		     (draw_fun  ,dfun)
		     (user_fun  ,ufun))
	      '(flags (add_front  T)
		      (is_weapon  T)
		      (unlistable T))
	      '(vars point_angle fire_delay1 just_fired)
	      `(states "art/coptop.spe"
		       (stopped        (seq ,base 1 24))))))



(make_top_char 'MGUN_TOP     "4gma" 'laser_ufun         'top_draw)
(make_top_char 'GRENADE_TOP  "4gre" 'top_ufun           'top_draw)
(make_top_char 'ROCKET_TOP   "4gro" 'player_rocket_ufun 'top_draw)
(make_top_char 'FIREBOMB_TOP "4gfi" 'top_ufun           'top_draw)




(defun restart_ai ()
  (if (eq (total_players) 1)       ;; only allow saving in single player games
      (select (aistate)
	      (0 (next_picture)
		 (if (and (touching_bg) (with_object (bg) (pressing_action_key)))
		     (set_aistate 2)))
	      (1 (next_picture);; wait for save (actived state)
		 (if (and (touching_bg) (with_object (bg) (pressing_action_key)))
		     (set_aistate 2)))
	      (2 (set_state running)
		 (set_aistate 3))
	      (3 (set_aistate 4))
	      (4
	       (let ((spot (get_save_slot)))
		 (set_state stopped)
		 (set_aistate 1)
		 (if (not (eq spot 0));; did they escape ?
		     (progn
		       (show_help (concatenate 'string Station (num2str (xvel)) secured))
		       (with_object (bg)
				    (progn
				      (let ((old_hp (hp)))
					(if (not (eq difficulty 'extreme))
					    (set_hp 100));; save the player with 100 health, unless on extreme
					(play_sound SAVE_SND 127 (x) (y))
					(setq has_saved_this_level spot)
					(save_game (concatenate 'string "save" (digstr spot 4) ".spe"))
					(set_hp old_hp)
					))))))

	       )))
  T)


(def_char RESTART_POSITION
  (funs (ai_fun restart_ai)
	(reload_fun lower_reload))
  (fields ("xvel"  restart_station))
  (states "art/misc.spe"
	  (stopped (app (rep "console" 3) (rep "console2" 3)))
	  (running (rep "console_on" 2))))

(defun next_level_ai ()
  (if (and (touching_bg) (with_object (bg) (pressing_action_key)))
      (if (eq (aistate) end_level)
	  (request_end_game)
	(progn
	  (show_stats)
	  (request_level_load (concatenate 'string "levels/level" (digstr (aistate) 2) ".spe")))))
  T)


(def_char NEXT_LEVEL
  (funs (ai_fun next_level_ai))
  (flags (can_block T))
  (fields ("aistate" next_level))
  (states "art/misc.spe"
	  (stopped "end_port2")))

(defun next_level_top_ai ()
  (shift_rand_table 80)
  (let ((oldy (y)))
    (try_move 0 100)
    (setq floor_yoff (- (y) oldy))
    (set_y oldy))
  T)

(def_char NEXT_LEVEL_TOP
  (funs (ai_fun next_level_top_ai))
  (vars floor_yoff)
  (draw_range 50 100)
  (fields ("aistate" next_level))
  (states "art/misc.spe"
	  (stopped "end_port1")))

(defun tele_beam_ai ()
  (next_picture)
  (if (> (direction) 0)
      (if (eq (fade_count) 12)
	  (progn
	    (play_sound APPEAR_SND 100 (x) (y))
	    (set_direction -1))
	(set_fade_count (+ (fade_count) 1)))
    (if (eq (fade_count) 5)
	(progn
	  (play_sound APPEAR_SND 100 (x) (y))
	  (set_direction 1))
      (set_fade_count (- (fade_count) 1)))))


(def_char TELE_BEAM
  (funs (ai_fun tele_beam_ai))
  (states "art/chars/teleport.spe" (stopped (seq "beam" 1 5))))

(def_char END_OF_S
  (funs (ai_fun do_nothing))
  (states "art/misc.spe" (stopped "eos")))


(make_top_char 'PGUN_TOP     "4gza" 'plaser_ufun        'top_draw)
(make_top_char 'LIGHT_SABER  "4gch" 'lsaber_ufun        'top_draw)
(make_top_char 'DFRIS_TOP    "4gbo" 'top_ufun           'top_draw)
(setq sell_screens '(("art/fore/endgame.spe" . "credit")))


(setq end_level 22)

