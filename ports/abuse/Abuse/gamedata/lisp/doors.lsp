;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun general_door_ai (push?)
  (select (aistate)
	  (0 (if (> (total_objects) 0)             ; are we linked to a key?
		 (progn
		   (set_state blocking)              ; don't let play pass
		   (if push?
		       (push_char (+ (picture_width) 8) (picture_height)))
		   )
	       (if (touching_bg)                   ; found key, wait till touching to open
		   (progn (set_state running)      ; start opening animation
			  (play_sound SWISH 70 (x) (y))
			  (go_state 1))
		 nil)))
	  (1 (if (not (next_picture))              ; wait till open animation finishes
		 (progn
		   (set_state stopped)             ; set opened animation
		   (go_state 2))))

	  (2 (if (> (total_objects) 0)             ; wait till level editor links us to a key
		 (progn
		   (set_state blocking)
		   (go_state 0))
	       (next_picture))))
  T)

(defun sdoor_ai ()
  (general_sdoor_ai T))

(defun general_sdoor_ai (push?)
  (select (aistate)
	  (0 ;          closed, wait for signal
	   (if (> (total_objects) 0)
	       (if (not (eq (with_object (get_object 0) (aistate)) 0))
		   (progn (set_state running)
			  (play_sound SWISH 70 (x) (y))
			  (go_state 1))
		 (progn
		   (set_state stopped)
		   (if push?
		       (push_char (+ (picture_width) 8) (picture_height)))))))

	  (1 ;          opening
	   (if (next_picture) nil
	     (progn
	       (set_state blocking)
	       (set_aistate 2))))
	  (2 (if (> (total_objects) 0)
		 (if (eq (with_object (get_object 0) (aistate)) 0)
		   (progn (set_state walking)
			  (play_sound SWISH 70 (x) (y))
			  (go_state 3)))))
	  (3 ;         closing
	   (if (next_picture) nil
	     (progn
	       (set_state stopped)
	       (set_aistate 0))))
	  )


T)


(def_char SWITCH_DOOR
  (funs (ai_fun sdoor_ai)
	(reload_fun lower_reload))
  (flags (can_block T))
  (range 250 60)
  (draw_range 30 50)
  (abilities (push_xrange 1))
  (states "art/chars/door.spe"
	  (stopped "door0006.pcx")
	  (running (seq "door" 6 1))
	  (walking (seq "door" 1 6))
	  (blocking "door0001.pcx")))

(defun ff_push (who xamount)
  (if who
      (progn
	(let ((bgx (with_object who (x)) (x))
	      (bgy (with_object who (y)) (y)))
	  (if (and (>= bgy (y)) (<= bgy (+ end_y 20))
		   (< (abs (- bgx (x))) xamount))
	      (let ((amount (if (> bgx (x))
				(- xamount (- bgx (x)))
			      (- (- (x) bgx) xamount))))
		(with_object who (try_move amount 0)))))
	(ff_push (next_focus who) xamount))))


(defun ff_ai ()

  (shift_rand_table (random 80))
  (if (activated)
      (let ((nowx (x))
	    (nowy (y)))

	(if (eq (mod (game_tick) 4) 0)
	    (play_sound FF_SND 127 (x) (y)))
	(try_move 0 (+ (y) 200))    ;; find the floor
	(setq end_y (y))            ;; save the position
	(set_x nowx)
	(set_y nowy)
	(ff_push (first_focus) 35)))
  T)


(defun ff_draw ()
  (if (edit_mode) (draw))
  (if (activated)
      (progn
	(ascatter_line (x) (y) (x) end_y (find_rgb 151 139 151) (find_rgb 75 69 75)    3)
	(ascatter_line (x) (y) (x) end_y (find_rgb 139 147 191) (find_rgb 69 73 95)    2)
	(ascatter_line (x) (y) (x) end_y (find_rgb 39  55  71)  (find_rgb 19 27 35)    2)
	(ascatter_line (x) (y) (x) end_y (find_rgb 39  55  71)  (find_rgb 20 26 35)    2))))



(def_char FORCE_FIELD
  (funs (ai_fun ff_ai)
	(draw_fun ff_draw))
  (range 10 500)
  (vars end_y)
  (states "art/misc.spe"
	  (stopped "force_field")))


(defun hwall_ai ()
  (if (or (eq (hp) 0)
	  (and (eq (total_objects) 1)
	       (with_object (get_object 0) (not (eq (aistate) 0)))))
      (progn
	(add_object EXPLODE1 (+ (x) 15) (- (y) 7)   0)
	(play_sound HWALL_SND 127 (x) (y))
	(hurt_radius (+ (x) (* 15 (direction))) (- (y) 7) 50 60 (bg) 20)
	nil)
    T))

(defun big_wall_ai ()
  (if (or (eq (hp) 0)
	  (and (eq (total_objects) 1)
	       (with_object (get_object 0) (not (eq (aistate) 0)))))
      (progn
	(add_object EXPLODE1 (- (x) 15) (- (y) 7)   0)
	(add_object EXPLODE1 (+ (x) 15) (- (y) 22)  0)
	(add_object EXPLODE1 (+ (x) (random 5)) (+ (+ (random 5) (y)) -20)     0)
	(play_sound HWALL_SND 127 (x) (y))
	(hurt_radius (x) (- (y) 15) 110 120 (bg) 20)
	nil)
    T))


(defun hwall_damage (amount from hitx hity push_xvel push_yvel)
  (if (activated)
      (progn
	(damage_fun amount from hitx hity push_xvel push_yvel)
	(let ((max_hp (get_ability start_hp)))
	  (if (and (not (eq (hp) 0)) (not (> (hp) max_hp)))
	      (set_current_frame (/ (* (total_frames) (- max_hp (hp))) max_hp)))))))

(defun hwall_reload ()    ;; we changed this , make sure this is reflected in all of the levels
  (if (eq (hp) 60)
      (set_hp 25)))


(defun make_hidden_wall_char (name start end ai)
  (eval `(def_char ,name
	   (funs (ai_fun ,ai)
		 (reload_fun  hwall_reload)
		 (damage_fun hwall_damage))
	   (abilities (start_hp 25))
	   (draw_range 80 80)
	   (flags (can_block T)
		  (unactive_shield T)
		  (hurtable T))
	   (states "art/chars/sect.spe"
		   (stopped (seq "sect" ,start ,end))))))     ; damn lisp is cool




(make_hidden_wall_char 'HIDDEN_WALL1 1 3 'hwall_ai)
(make_hidden_wall_char 'HIDDEN_WALL2 4 6 'hwall_ai)
(make_hidden_wall_char 'HIDDEN_WALL3 7 9 'hwall_ai)
(make_hidden_wall_char 'HIDDEN_WALL4 10 12 'hwall_ai)
(make_hidden_wall_char 'HIDDEN_WALL5 13 15 'hwall_ai)

(make_hidden_wall_char 'HIDDEN_WALL_2x2 16 18 'big_wall_ai)
(make_hidden_wall_char 'HIDDEN_WALL_3WAL 19 21 'big_wall_ai)
(make_hidden_wall_char 'HIDDEN_WALL_3FLR 22 24 'big_wall_ai)
(make_hidden_wall_char 'HIDDEN_WALL_3TOP 25 27 'big_wall_ai)

(make_hidden_wall_char 'HIDDEN_WALL_AFLR 28 30 'big_wall_ai)

(make_hidden_wall_char 'HIDDEN_RAMP1 31 33 'hwall_ai)
(make_hidden_wall_char 'HIDDEN_RAMP2 34 36 'hwall_ai)





