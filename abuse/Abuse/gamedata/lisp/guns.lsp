;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights


(setq gun_tints (make-array 11 :initial-contents (list
						  normal_tint
						  (def_tint "art/tints/guns/orange.spe") ; orange
						  (def_tint "art/tints/guns/green.spe")  ; grenade
						  (def_tint "art/tints/guns/redish.spe") ; rocket
						  (def_tint "art/tints/guns/blue.spe")   ; plasma
						  normal_tint
						  normal_tint
						  normal_tint
						  normal_tint
						  normal_tint
						  normal_tint)))


(setq ai_ammo (make-array 9 :initial-contents (list MBULLET_ICON5
						MBULLET_ICON5
						GRENADE_ICON2
						ROCKET_ICON2
						PLASMA_ICON20
						MBULLET_ICON5
						MBULLET_ICON5
						MBULLET_ICON5
						MBULLET_ICON5)))

(defun aitype_to_ammo (aitype)
  (aref ai_ammo aitype))



(defun fire_object (creator type x y angle target)
  (select type

	  (0 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 6)
					(setq sgb_speed 15)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)
					(setq sgb_bright_color (find_rgb 255 255 200))
					(setq sgb_medium_color (find_rgb 150 150 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  (1 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 40)
					(setq sgb_speed 6)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)

					(setq sgb_bright_color (find_rgb 255 128 64))
					(setq sgb_medium_color (find_rgb 255 0 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))
	  (2 (with_object (add_object GRENADE x y)
			  (progn
			    (play_sound GRENADE_THROW 127 x y)
			    (set_course angle 20)
			    (if creator
				(progn
				  (link_object creator)
				  (set_xvel (+ (xvel) (with_object creator (xvel))))
				  (set_yvel (+ (yvel) (with_object creator (yvel))))
				  ))

			    (set_frame_angle 0 359 angle)
			    )))
	  (3 (with_object (add_object ROCKET x y)
			  (progn
			    (play_sound ROCKET_LAUNCH_SND 127 x y)
			    (set_aistate angle)
			    (if creator	(link_object creator))

			    (if (and target   ;; don't link if not in line of site
				     (can_see (x) (y)
					      (with_object target (x))
					      (with_object target (y)) nil))
					      (link_object target))

			    (set_frame_angle 0 359 angle)
			    (setq speed 5)
			    (if (and creator (with_object creator (isa_player)))
				(setq max_speed 14)
			      (setq max_speed 10))
			    (set_y (+ (y) (/ (picture_height) 2)))  ;; move down to match frame/pos
			    )))

	  (4 (with_object (add_object PLASMAGUN_BULLET x y)
				      (progn
					(play_sound PLASMA_SND 127 (x) (y))
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(if creator
					      (link_object creator))
					(set_course angle 200)
					(let ((old_x (x))
					      (old_y (y))
					      (bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))
					  (if (not (eq bx T))
					      (if (eq bx nil)
						  (add_object EXPLODE5 (- (x) (random 5))
							      (- (y) (random 5)) 0)
						(progn
						  (add_object EXPLODE3 (- (x) (random 5))
							      (- (y) (random 5)) 0)
						  (do_damage 10 bx (* (cos sgb_angle) 20)
							     (* (sin sgb_angle) 10)))))
					  (setq sgb_lastx (x))
					  (setq sgb_lasty (y))
					  (set_x old_x)
					  (set_y old_y))
					)))


	  (5 (with_object (add_object FIREBOMB x y)
			  (progn
			    (play_sound FIREBOMB_SND 127 (x) (y))
			    (set_course angle 20)
			    (if creator
				(progn
				  (link_object creator)
				  (set_yvel (+ (yvel) (with_object creator (yvel))))
				  )))))

	  (6 (with_object (add_object DFRIS_BULLET x y)
				      (progn
					(play_sound ROCKET_LAUNCH_SND 127 x y)
					(set_course angle 25)
					(set_aistate angle)
					(if creator
					      (link_object creator))
					(dfris_ai)
					)))

	  (7 (with_object (add_object LSABER_BULLET x y)
				      (progn
					(play_sound LSABER_SND 127 (x) (y))
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(if creator
					      (link_object creator))
					(set_course angle 45)
					(let ((bx (bmove (if (> (total_objects) 0) (get_object 0) nil))))
					  (if (not (eq bx T))
					      (if (not (eq bx nil))
						  (do_damage 30 bx (* (cos sgb_angle) 20)
							     (* (sin sgb_angle) 10)))))
					)))


	  (9 (with_object (add_object STRAIT_ROCKET x y)
				      (progn
					(play_sound MGUN_SND 127 (x) (y))
					(if creator
					      (link_object creator))
					(set_aistate angle)
					(set_frame_angle 0 359 angle)
					(play_sound GRENADE_THROW 127 (x) (y)))))

	  (10 (with_object (add_object SHOTGUN_BULLET x y)
				      (progn
					(play_sound ZAP_SND 127 (x) (y))
					(setq sgb_lifetime 6)
					(setq sgb_speed 15)
					(setq sgb_lastx (x))
					(setq sgb_lasty (y))
					(setq sgb_angle angle)
					(setq sgb_bright_color (find_rgb 255 0 0))
					(setq sgb_medium_color (find_rgb 150 0 0))
					(if creator
					    (progn
					      (setq sgb_speed (+ sgb_speed (/ (xvel) 2)))
					      (link_object creator)))
					(sgun_ai)
					)))

	  )
)


(defun spray_fire ()
  (fire_object (me) (aitype)
	       (+ (x) (* (cos spray.angle) 20))
	       (- (- (y) 21) (* (sin spray.angle) 22))
	       spray.angle
	       (bg)))


(defun spray_gun_ai ()
  (if (<= (hp) 0)
      nil
    (if (and (< (distx) 450) (< (disty) 400))
	(progn
	  (select (aistate)
		  (0;; look at sensor
		   (if (activated)
		       (if (eq (state) stopped)
			   (progn
			     (set_targetable T)
			     (set_state spray.appear)
			     (go_state 1))
			 (go_state 3))
		     (progn
		       (set_targetable nil)
		       (set_state stopped))))


		  (1;; unfold
		   (if (next_picture) T
		     (progn (set_aistate 3)
			    (set_state spray.aim)
			    (setq spray.angle spray.start_angle)
			    (set_frame_angle 0 359 spray.angle)
			    )))

		  (2;; fold up
		   (if (next_picture) T
		     (progn (set_state stopped)
			    (set_aistate 0))))


		  (3;; swivel down
		   (if (> (state_time) spray.fire_delay)
		       (progn
			 (set_aistate 3);; reset state time
			 (setq spray.angle (- spray.angle spray.angle_speed))
			 (if (<= spray.angle spray.start_angle)
			     (progn
			       (setq spray.angle spray.start_angle)
			       (set_aistate 4)))
			 (set_frame_angle 0 359 spray.angle)
			 (spray_fire))))

		  (4;; swivel up
		   (if (> (state_time) spray.fire_delay)
		       (progn
			 (set_aistate 4);; reset state time
			 (setq spray.angle (+ spray.angle spray.angle_speed))
			 (if (>= spray.angle spray.end_angle)
			     (progn
			       (setq spray.angle spray.end_angle)
			       (set_aistate 0)))
			 (set_frame_angle 0 359 spray.angle)

			 (spray_fire)))))
	  T)
      (progn
	(set_state stopped)
	T))))




    (defun spray_gun_cons ()
      (setq spray.bullet_speed 20)
      (setq spray.angle_speed  10)
      (setq spray.start_angle  270)
      (setq spray.end_angle    350)
      (setq spray.fire_delay 4))

(def_char SPRAY_GUN
  (funs (ai_fun       spray_gun_ai)
	(damage_fun   guner_damage)
	(draw_fun     gun_draw)
	(constructor spray_gun_cons))

  (flags (can_block  T)
	 (hurtable   T))
  (abilities (start_hp 20)
	     )
  (vars spray.fire_delay
	spray.bullet_speed
	spray.start_angle
	spray.end_angle
	spray.angle_speed
	spray.angle)

  (fields ("hp"                 ai_health)
	  ("aitype"             ai_type)
	  ("spray.fire_delay"   spray_delay)
	  ("spray.start_angle"  spray_start)
	  ("spray.end_angle"    spray_end)
	  ("spray.angle_speed"  spray_speed)
	  ("spray.angle"        spray_cangle))

  (states "art/gun2.spe"
	  (stopped           "stopped")
	  (spray.aim         (seq "cspn" 1 24))
	  (spray.appear      '("csht0001.pcx" "csht0002.pcx"))
	  (spray.disappear   '("csht0002.pcx" "csht0001.pcx"))
	  ))

;; XXX: Mac Abuse reimplements this in C++
(defun gun_draw ()
  (draw_tint (aref gun_tints (aitype))))


(def_char TRACK_GUN
  (vars
	fire_delay            ; how long between each shot
	fire_delay_left
        track_speed           ; how fast the gun can chage it's angle

	burst_total           ; how many shots to fire with fire_delay in between each
	burst_total_left
	continue_time         ; how much time to wait before continue tracking
	continue_time_left
	track_start_angle     ; min angle gun will track
	track_end_angle       ; max
	angle)


  (funs (ai_fun      track_ai)
	(constructor track_cons)
	(draw_fun    gun_draw)
	(damage_fun   guner_damage))

  (flags (can_block  T)
	 (hurtable   T))

  (abilities (start_hp 20))

  (fields ("hp"                ai_health)
	  ("aitype"            ai_type)
	  ("track_speed"       d_track_speed)
	  ("fire_delay"        track_fspeed)
	  ("burst_total"       track_burst)
	  ("continue_time"     track_cont)
	  ("track_start_angle" track_sangle)
	  ("track_end_angle"   track_eangle)
	  ("angle"             track_cangle))

  (states "art/gun2.spe"
	  (stopped  "stopped")
	  (opening  '("csht0001.pcx" "csht0002.pcx"))
	  (shuting  '("csht0002.pcx" "csht0001.pcx"))
	  (spinning (seq "cspn" 1 24))
	  (firing   (seq "cfr1" 1 24))))

(defun track_cons ()
  (setq angle 270)
  (setq track_speed 1)
  (setq fire_delay  5)
  (setq burst_total 3)
  (setq continue_time 8)
  (setq track_start_angle 180)
  (setq track_end_angle   359))

(defun track_fire ()
  (fire_object (me) (aitype)
	       (+ (x) (* (cos angle) 18))
	       (- (- (y) 15) (* (sin angle) 15))
	       (mod (+ angle (- 2 (random 5))) 360)
	       (bg))
  (if (or (eq burst_total_left 0) (eq burst_total_left 1))
      (setq continue_time_left continue_time)
    (progn
      (setq burst_total_left (- burst_total_left 1))
      (setq fire_delay_left fire_delay)))


  (set_state firing)
  (set_frame_angle 0 359 angle))

(defun track_set_angle (new_angle)
  (if (> track_start_angle track_end_angle)
      (if (and (>= new_angle track_end_angle) (<= new_angle track_start_angle))
	  (setq angle new_angle))
    (if (and (<= new_angle track_end_angle) (>= new_angle track_start_angle))
	(setq angle new_angle))))

(defun track_ai ()
  (if (eq (hp) 0)                                                  ;; are we dead?
      nil
    (if (activated)                                   ;; see if we should be on
	(if (eq (state) stopped)
	    (progn
	      (set_targetable T)
	      (set_state opening)
	      T)
	  (if (and (eq (state) opening) (next_picture))
	      T
	    (progn
	      (set_state spinning)
	      (set_frame_angle 0 359 angle)

	      (if (eq continue_time_left 0);; do we need to wait?
		  (if (eq fire_delay_left 0)
		      ;; get the angle to the player
		      (let ((pangle (atan2 (- (- (y) (with_object (bg) (y))) -8)
					   (- (with_object (bg) (x)) (x) ))))
			(let ((clock_dist (if (< pangle angle);; calculate clockwise angle distance
					      (- angle pangle)
					    (+ angle (- 360 pangle)))))
			  (let ((closest_dist (if (> clock_dist 180)
						  (- 360 clock_dist)
						clock_dist)))
			    (let ((angle_add (if (>= closest_dist track_speed)
						 track_speed
					       closest_dist)))
			      (if (> clock_dist 180);; should we steer clowck wise or counter?
				  (track_set_angle (mod (+ angle angle_add) 360))
				(track_set_angle (mod (+ (- angle angle_add) 360) 360)))
			      (if (< angle_add 5);; pretty close to target, FIRE!
				  (track_fire))))))
		    (setq fire_delay_left (- fire_delay_left 1)))
		(progn
		  (setq continue_time_left (- continue_time_left 1))
		  (if (eq continue_time_left 0)
		      (setq burst_total_left burst_total))))
	      T)))
      (progn
	(set_targetable nil)
	(set_state stopped)
	T))))





