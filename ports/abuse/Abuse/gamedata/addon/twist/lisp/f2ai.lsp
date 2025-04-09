(defun forceobj_ai ()
  (if (<= (total_objects) 0)
      nil
     (progn
	(let ((xfrc (xacel))
	      (yfrc (yacel)))
	(try_move xfrc yfrc))
	  T)))


(defun forceobj_cons ()
  (set_xacel 0)
  (set_yacel 10))


(defun do_fire_explo (radius amount)
      (play_sound GRENADE_SND 127 (x) (y))
      (add_object EXPFIRE (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
      (if (not (frame_panic))
	  (progn
	    (add_object EXPFIRE (- (x) (random 10)) (+ (- (y) (random 10)) -20) 2)
	    (add_object EXP_LIGHT (x) (y) 100)))         ; add cool light if not too slow
      (hurt_radius (x) (y) radius amount (if (> (total_objects) 0)
					     (get_object 0)
					   nil) 20)
      nil)


(defun do_light_explo (radius amount)
      (play_sound GRENADE_SND 127 (x) (y))
;;      (add_object EXPFIRE (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
      (if (not (frame_panic))
	  (progn
;;	    (add_object EXPFIRE (- (x) (random 10)) (+ (- (y) (random 10)) -20) 2)
	    (add_object EXP_LIGHT (x) (y) 100)))         ; add cool light if not too slow
      (hurt_radius (x) (y) radius amount (if (> (total_objects) 0)
					     (get_object 0)
					   nil) 20)
      nil)


(defun msensor_ai ()
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	   (progn
		(stop_song)
		(select (aitype)
		   (0  (play_song "music/intro.hmi"))
		   (1  (play_song "music/abuse01.hmi"))
		   (2  (play_song "music/abuse02.hmi"))
		   (3  (play_song "music/abuse03.hmi"))
		   (4  (play_song "music/abuse04.hmi"))
		   (5  (play_song "music/abuse06.hmi"))
		   (6  (play_song "music/abuse08.hmi"))
		   (7  (play_song "music/abuse09.hmi"))
		   (8  (play_song "music/abuse11.hmi"))
		   (9  (play_song "music/abuse13.hmi"))
		   (10 (play_song "music/abuse15.hmi"))
		   (11 (play_song "music/abuse17.hmi")))
		nil)
	   T))

(defun msensor_cons ()
  (set_xvel 50)
  (set_yvel 50)
  (set_xacel 0)
  (set_yacel 0)
  (add_hp -10))


(defun music_sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 0 0 255)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))
    nil))


(defun gsensor_ai ()
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	   (progn
		(let ((xgvty (xacel))
		      (ygvty (yacel)))
			(with_object (bg) (try_move xgvty ygvty))))
		T)
	   T)


(defun gsensor_cons ()
  (set_xvel 50)
  (set_yvel 50)
  (set_xacel 0)
  (set_yacel -15))


(defun gravity_sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 255 255 0)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))
    nil))


(defun hsensor_ai ()
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	   (progn
		(select (aitype)
		   (0	(let ((phlth (xacel))) (if (eq (mod (state_time) 10) 0) (do_damage phlth (bg)))))
		   (1	(let ((phlth (xacel)) (hlthrad (/ (xvel) 2))) (hurt_radius (x) (y) hlthrad phlth nil 10)))
		   (2	(let ((phlth (xacel)) (hlthrad (/ (xvel) 2))) (do_explo hlthrad phlth)))
			)
		T)
	   T))


(defun hsensor_cons ()
  (set_xvel 50)
  (set_yvel 50)
  (set_aitype 0)
  (set_aistate 0)
  (set_xacel 10)
  (set_yacel 0))


(defun health_sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 255 0 255)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))
    nil))


(defun lsensor_ai ()
      (if (and (< (distx) (xvel)) (< (disty) (yvel)))
	   (progn
		(if (eq (aistate) 1) (request_end_game))
		(if (eq (aitype) 1) (show_stats))
		(request_level_load (concatenate 'string "addon/twist/levels/l" (digstr (xacel) 2) "s" (digstr (yacel) 2) ".lvl"))
	   )
		T)
	   T)


(defun lsensor_cons ()
  (set_xvel 50)
  (set_yvel 50)
  (set_xacel 1)
  (set_yacel 1)
  (set_aistate 0)
  (set_aitype 1))


(defun level_sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 255 128 0)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))
    nil))


;; Cheats
;;
;; Add Health:	Vitalize
;; All Weapons:	Arms
;; Full Ammo:	Reload
;; Power Fast:	Steroids
;; Power Fly:	Lift
;; Power Sneaky:Mirage
;; Power Health:Elixir
;; Power Light:	Visor
;; End Game:	Outcome
;; To use cheat, type cheat code.
;; Note: if you press any direction keys, you'll have to retype the whole thing.

(defun csensor_ai ()
(progn (set_x (with_object (bg) (x))) (set_y (with_object (bg) (y))))

(if (local_key_pressed up-key) (set_aistate 0))
(if (local_key_pressed down-key) (set_aistate 0))
(if (local_key_pressed left-key) (set_aistate 0))
(if (local_key_pressed right-key) (set_aistate 0))
(if (local_key_pressed weapon-left-key) (set_aistate 0))
(if (local_key_pressed weapon-right-key) (set_aistate 0))

      (if (eq (fourth (mouse_stat)) 1)
	   (progn
		(select (aistate)
		;; First Letter
		   (0	(if (local_key_pressed key-v) (set_aistate 1))
			(if (local_key_pressed key-a) (set_aistate 10))
			(if (local_key_pressed key-r) (set_aistate 13))
			(if (local_key_pressed key-s) (set_aistate 18))
			(if (local_key_pressed key-l) (set_aistate 25))
			(if (local_key_pressed key-m) (set_aistate 28))
			(if (local_key_pressed key-e) (set_aistate 33))
			(if (local_key_pressed key-o) (set_aistate 38)))
		;; Vitalize
		   (1	(if (local_key_pressed key-i) (set_aistate 2)))
		   (2	(if (local_key_pressed key-t) (set_aistate 3))
			(if (local_key_pressed key-s) (set_aistate 8)))
		   (3	(if (local_key_pressed key-a) (set_aistate 4)))
		   (4	(if (local_key_pressed key-l) (set_aistate 5)))
		   (5	(if (local_key_pressed key-i) (set_aistate 6)))
		   (6	(if (local_key_pressed key-z) (set_aistate 44)))
		   (7	(if (local_key_pressed key-e) (set_aistate 44)))
		;; Visor
		   (8	(if (local_key_pressed key-o) (set_aistate 45)))
		   (9	(if (local_key_pressed key-r) (set_aistate 45)))
		;; Arms
		   (10	(if (local_key_pressed key-r) (set_aistate 11)))
		   (11	(if (local_key_pressed key-m) (set_aistate 46)))
		   (12	(if (local_key_pressed key-s) (set_aistate 46)))
		;; Reload
		   (13	(if (local_key_pressed key-e) (set_aistate 14)))
		   (14	(if (local_key_pressed key-l) (set_aistate 15)))
		   (15	(if (local_key_pressed key-o) (set_aistate 16)))
		   (16	(if (local_key_pressed key-a) (set_aistate 47)))
		   (17	(if (local_key_pressed key-d) (set_aistate 47)))
		;; Steroids
		   (18	(if (local_key_pressed key-t) (set_aistate 19)))
		   (19	(if (local_key_pressed key-e) (set_aistate 20)))
		   (20	(if (local_key_pressed key-r) (set_aistate 21)))
		   (21	(if (local_key_pressed key-o) (set_aistate 22)))
		   (22	(if (local_key_pressed key-i) (set_aistate 23)))
		   (23	(if (local_key_pressed key-d) (set_aistate 48)))
		   (24	(if (local_key_pressed key-s) (set_aistate 48)))
		;; Lift
		   (25	(if (local_key_pressed key-i) (set_aistate 26)))
		   (26	(if (local_key_pressed key-f) (set_aistate 49)))
		   (27	(if (local_key_pressed key-t) (set_aistate 49)))
		;; Mirage
		   (28	(if (local_key_pressed key-i) (set_aistate 29)))
		   (29	(if (local_key_pressed key-r) (set_aistate 30)))
		   (30	(if (local_key_pressed key-a) (set_aistate 31)))
		   (31	(if (local_key_pressed key-g) (set_aistate 50)))
		   (32	(if (local_key_pressed key-e) (set_aistate 50)))
		;; Elixir
		   (33	(if (local_key_pressed key-l) (set_aistate 34)))
		   (34	(if (local_key_pressed key-i) (set_aistate 35)))
		   (35	(if (local_key_pressed key-x) (set_aistate 36)))
		   (36	(if (local_key_pressed key-i) (set_aistate 51)))
		   (37	(if (local_key_pressed key-r) (set_aistate 51)))
		;; Outcome
		   (38	(if (local_key_pressed key-u) (set_aistate 39)))
		   (39	(if (local_key_pressed key-t) (set_aistate 40)))
		   (40	(if (local_key_pressed key-c) (set_aistate 41)))
		   (41	(if (local_key_pressed key-o) (set_aistate 42)))
		   (42	(if (local_key_pressed key-m) (set_aistate 52)))
		   (43	(if (local_key_pressed key-e) (set_aistate 52)))

	;; Last Word
		;; Vitalize Activation
		   (44	(if (local_key_pressed key-e) (progn (with_object (bg) (give_player_health 20)) (set_aistate 0))))
		;; Visor Activation
		   (45	(if (local_key_pressed key-r) (progn (with_object (bg) (progn (setq special_power HEALTH_POWER))) (set_aistate 0))))
		;; Arms Activation
		   (46	(if (local_key_pressed key-s) (progn (with_object (bg) (progn (give_weapon 0)(give_weapon 1)(give_weapon 2)(give_weapon 3)(give_weapon 4)(give_weapon 5)(give_weapon 6)(give_weapon 7))) (set_aistate 0))))
		;; Reload Activation
		   (47	(if (local_key_pressed key-d) (progn (with_object (bg) (progn (add_ammo 0 999)(add_ammo 1 999)(add_ammo 2 999)(add_ammo 3 999)(add_ammo 4 999)(add_ammo 5 999)(add_ammo 6 999)(add_ammo 7 999))) (set_aistate 0))))
		;; Steroids Activation
		   (48	(if (local_key_pressed key-s) (progn (with_object (bg) (progn (setq special_power FAST_POWER))) (set_aistate 0))))
		;; Lift Activation
		   (49	(if (local_key_pressed key-t) (progn (with_object (bg) (progn (setq special_power FLY_POWER))) (set_aistate 0))))
		;; Mirage Activation
		   (50	(if (local_key_pressed key-e) (progn (with_object (bg) (progn (setq special_power SNEAKY_POWER))) (set_aistate 0))))
		;; Elixir Activation
		   (51	(if (local_key_pressed key-r) (progn (with_object (bg) (progn (setq special_power HEALTH_POWER))) (set_aistate 0))))
		;; Outcome Activation
		   (52	(if (local_key_pressed key-e) (progn (stop_song) (play_song "music/victory.hmi")(play_sound END_LEV_SND 127 (x) (y))(request_end_game))))
		) T) T))


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
	(with_object (add_object WALK_ROBHEAD (x) (- (y) 24) 1)
      nil)
    (progn
	(try_move 0 10)
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


(defun telesensor_ai ()
  (if (> (total_objects) 0)
      (select (aistate)
	      (0 ;; wait for player to activate
	       (if (and (< (distx) (xvel)) (< (disty) (yvel)))
		   (progn
		(if (eq (aitype) 0)
			 (progn
			   (link_object (bg))
			   (set_state running)
			   (set_aistate 1))

		     (if (with_object (bg) (pressing_action_key))
			 (progn
			   (link_object (bg))
			   (set_state running)
			   (set_aistate 1))
			 )))) )
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


(defun telesensor_cons ()
  (set_xvel 50)
  (set_yvel 50))


(defun teleport_sensor_draw ()
  (if (edit_mode)
      (progn
	(draw)
	(let ((x1 (- (x) (xvel)))
	      (y1 (- (y) (yvel)))
	      (x2 (+ (x) (xvel)))
	      (y2 (+ (y) (yvel)))
	      (c  (find_rgb 128 255 0)))
	  (draw_line x1 y1 x2 y1 c)
	  (draw_line x2 y1 x2 y2 c)
	  (draw_line x2 y2 x1 y2 c)
	  (draw_line x1 y2 x1 y1 c)))
    nil))
