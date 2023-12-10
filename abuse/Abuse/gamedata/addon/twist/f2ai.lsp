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
		(request_level_load (concatenate 'string "levels/level" (digstr (xacel) 2)".spe"))
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


(defun wrob2_cons ()
  (setq fire_delay 4)
  (setq burst_delay 1)
  (setq max_xvel 10)
  (setq max_yvel 5)
  (set_aitype 0)
  (setq burst_total 5))


(defun wrob2_ai ()
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
