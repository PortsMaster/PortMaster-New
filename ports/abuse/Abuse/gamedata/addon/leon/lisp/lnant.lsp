(setq ant_tints (make-array 14 :initial-contents (list
						(def_tint "art/tints/ant/green.spe")
						(def_tint "art/tints/ant/blue.spe")
						(def_tint "art/tints/ant/brown.spe")
						(def_tint "art/tints/ant/egg.spe")
						(def_tint "art/tints/ant/yellow.spe")
						(def_tint "art/tints/ant/mustard.spe")
						(def_tint "art/tints/ant/orange.spe")
						(def_tint "art/tints/ant/gray.spe")
						normal_tint
						normal_tint
						normal_tint
						(def_tint "addon/leon/gray.spe")
						(def_tint "addon/leon/gray.spe")
						(def_tint "addon/leon/gray.spe")
						)))

(defun crackN_ai ()
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
	       (with_object (add_object_after ANT (+ (x) (* (direction) 20)) (y))
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



(def_char ANT_CRACK_HIDDEN
  (funs (ai_fun crack_ai)
	(draw_fun dev_draw)
	(get_cache_list_fun ant_cache)
	(constructor crack_cons))
  (range 250 0)
  (vars create_total)
  (fields ("create_total"  ant_total)
	  ("aitype"        ant_type))
  (states "art/ant.spe"
	  (stopped (seq "aisw" 2 6))))

(def_char ANT_CRACK_NEW
  (funs (ai_fun crackN_ai)
	(draw_fun   ant_draw)
	(get_cache_list_fun ant_cache)
	(constructor crack_cons))
  (range 250 0)
  (vars create_total)
  (fields ("create_total"  ant_total)
	  ("aitype"        ant_type))
  (states "art/ant.spe"
	  (stopped (seq "aisw" 2 6))))




(defun anthole_ai ()
  (select (aistate)
    (0
      (if (and (activated) (< (total_objects) (+ (xvel) 1) ) )
        (go_state 2)
      )
    )
    (3
      (if (and (activated) (< (total_objects) (+ (xvel) 1) ) )
        (progn
          (if (eq (current_frame) 4)
            (set_current_frame 1)
          )
        (go_state 4)
        )
      )
    )
    (4
      (select (current_frame)
        (0 (next_picture))
        (1 (next_picture))
        (2 (next_picture))
        (3 (next_picture))
        (4 (go_state 2))
      )
    )

    (1
      (if (eq (state_time) (yvel))
        (select (otype) (ANTHOLE (go_state 0))
                        (ANTCRACK2 (go_state 3))
        )
      )
    )
    (2
      (if (eq (otype) ANTHOLE)
        (let ( ( newant (add_object_after ANT_ROOF (x) (y) ) ) ( type (aitype) ) )
          (with_object newant
            (progn
              (set_aitype type)
              (set_state run_jump)
              (set_aistate 1)
            )
          )
          (link_object newant)
        )
        (let ( ( newant (add_object_after ANT_ROOF (+ (x) (* (direction) 20)) (y) ) ) ( type (aitype) ) ( d (direction) ) )
          (with_object newant
            (progn
              (set_aitype type)
              (set_direction d)
              (set_xvel (* d 20))
              (set_state run_jump)
              (set_aistate 6)
            )
          )
          (link_object newant)
        )
      )
      (go_state 1)
    )
  )
  T
)

(def_char ANTHOLE
  (funs (ai_fun anthole_ai)
	(draw_fun   dev_draw)
	(get_cache_list_fun ant_cache))
  (range 250 0)
  (fields ("xvel"  "max ants")
          ("aitype"       ai_type)
          ("aistate"       "ai_state")
	  ("yvel"        "delay"))
  (states "art/ant.spe"
	  (stopped (seq "affc" 1 2))))

(defun crack2_cons ()
  (set_aistate 3))

(def_char ANTCRACK2
  (funs (ai_fun anthole_ai)
	(draw_fun   ant_draw)
	(get_cache_list_fun ant_cache)
        (constructor crack2_cons))
  (range 250 0)
  (fields ("xvel"  "max ants")
          ("aitype"       ai_type)
          ("aistate"       "ai_state")
	  ("yvel"        "delay"))
  (states "art/ant.spe"
	  (stopped (seq "aisw" 2 6))))

(defun make_new_ant_type ( name aifun drawfun damfun runspd shp pacel tacel jumpyvel jumpxvel )
  (eval `(def_char ,name
  (vars need_to_dodge
	no_see_time
	hide_flag
	xvar1
        xvar2
        xvar3
        aivar1
        aivar2)

  (fields
	  ("xvar1"    "class specific var1")
          ("xvar2"    "class specific var2")
          ("xvar3"    "class specific var3")
	  ("hide_flag"    ant_hide)
	  ("fade_count"   ai_fade)
	  ("aitype"       ai_type)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))
  (range 250 20)
  (draw_range 40 40)
  (funs (ai_fun     ,aifun)
	(draw_fun   ,drawfun)
	(constructor ant_cons)
	(type_change_fun ant_ct)
	(get_cache_list_fun ant_cache)
	(damage_fun ,damfun))

  (abilities (run_top_speed   runspd)
	     (start_hp       shp)
	     (stop_acel      pacel)
	     (start_acel     tacel)
	     (jump_yvel      jumpyvel)
	     (jump_xvel      jumpxvel)
	     (push_xrange     1)
	     (jump_top_speed (+ jumpyvel jumpxvel) ))

  (flags
	 (hurtable  T)
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
))




(setq ai_ammo (make-array 15 :initial-contents (list MBULLET_ICON5
						MBULLET_ICON5
						GRENADE_ICON2
						ROCKET_ICON2
						PLASMA_ICON20
						MBULLET_ICON5
						MBULLET_ICON5
						MBULLET_ICON5
						MBULLET_ICON5
						MBULLET_ICON20
						MBULLET_ICON20
						MBULLET_ICON20
						MBULLET_ICON20
						MBULLET_ICON20
						MBULLET_ICON20)))

(defun ant_Ndamage (amount from hitx hity push_xvel push_yvel)  ; Some piece of really ugly looking code

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
                  (if (or (eq (aitype) 2) (eq (aitype) 4) ) (set_aitype 0) nil )
                  (set_hp 0 )
		  (if (eq (random (select difficulty
					  ('easy 2)
					  ('medium 5)
					  ('hard   8)
					  ('extreme 20))) 0)
		      (if (eq (random 4) 0)
			  (add_object (aitype_to_ammo (+ (aitype) 1)) (x) (y)))
		    (add_object (aitype_to_ammo (aitype)) (x) (y)))
(if ( eq (get_dead_part from) flaming_part )
; Explosive weapon?
	  (if (eq (random 2) 0) (create_dead_parts ant_dead_parts (* (get_dead_part from) 3) (aitype))
	     (let ((d (direction))
		   (type (aitype)))
                  (with_object (add_object ANTBODY (x) (y))
                    (progn
			      (set_aitype type)
			      (set_direction d)
)))
)
; No?
	  (if (eq (random 5) 0) (create_dead_parts ant_dead_parts (* (get_dead_part from) 3) (aitype))
	     (let ((d (direction))
		   (type (aitype)))
                  (with_object (add_object DECO_ANTBODY (x) (y))
                    (progn
			      (set_aitype type)
			      (set_direction d)
)))
)

)




)
		  )))))



(defun pred_draw ()
  (if (edit_mode)
    (ant_draw)
  (draw_predator)))

(defun great_damage (amount from hitx hity push_xvel push_yvel)
  (if (and (eq (fade_count) 0) (not (eq (aistate) 15)) )
      (progn
      (play_sound APAIN_SND 127 (x) (y))
      (if (eq (random 3) 0)
	(damage_fun amount from hitx hity push_xvel push_yvel)
        (add_hp (* amount -1) ) )
      (if (eq (hp) 0)
	(progn
	  (if (> xvar1 0) (set_hp 100) nil)
	  (setq xvar1 (- xvar1 1))
	  (if (eq xvar1 -1)         ;; substract 1 life
		  	     (let ((d (direction))
		   (type (aitype)))
                  (with_object (add_object GRANTBODY (x) (y))
                    (progn
			      (set_aitype type)
			      (set_direction d)
)))
		(set_aistate 6)))))))         ;; Continue



(defun grantbody_ai ()
  (if (< (hp) 12) (play_sound (aref ASML_DEATH (random 2)) 127 (x) (y)) nil)
  (if (< (hp) 16) (play_sound (aref ALRG_DEATH (random 3)) 127 (x) (y)) nil)
  (if (< (hp) 9) (create_dead_parts ant_dead_parts (* normal_part 3) (aitype)) nil)
  (if (< (hp) 16 ) (progn (next_picture) (set_hp (+ (hp) 1) ) ) nil )
  (if (eq0 (aistate)) 	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))  ; if we are on the floor, don't check falling anymore
		(set_aistate 1))))
  T
)


(def_char GRANTBODY
  (funs (ai_fun grantbody_ai)
        (draw_fun   ant_draw))
  (flags (unlistable T) (add_front T))
  (states "art/ant.spe"  (stopped (seq "adib" 1 16))))

(defun grant_ai ()
  (if (eq (aistate) 6)
    (if (eq xvar2 1)
      (progn
        (if (eq (random 3) 0)
          (set_aistate 2)
          (set_aistate 8)
        )
        (ant_ai)
      )
      (ant_ai)
    )
    (ant_ai)
  )
)

(defun stat( aistat )
  (eq (aistate) aistat)
)

(defun tant_ai ()
  (if (stat 8)
    (progn
      (ant_ai)
      (set_direction (toward) )
      (if (and (stat 2) (not (eq (random 5) 0) ) )
        (set_aistate 8)
      )
    )
    (ant_ai)
  )
  (if (eq (hp) 0 ) nil T )
)

(defun tough_damage (amount from hitx hity push_xvel push_yvel)
  (if (not (eq (aistate) 15))
      (progn
      (if (eq (random 5) 0)
	(damage_fun amount from hitx hity push_xvel push_yvel)
        (add_hp (* amount -1) ) )
      (if (<= (hp) 0)
        (let ((d (direction))
	  (type (aitype)))
            (with_object (add_object ANTBODY (x) (y))
              (progn
		(set_aitype type)
		(set_direction d)
              )
            )
            (play_sound (aref ASML_DEATH (random 2)) 127 (x) (y))
            (create_dead_parts ant_dead_parts (* normal_part 3) type)
        )
      )
      )
  )
)

(make_new_ant_type 'ANT_PRED 'ant_ai 'pred_draw 'ant_damage 7 20 20 20 -4 20)
(make_new_ant_type 'ANT_JUMPER 'ant_ai 'ant_draw 'ant_Ndamage 7 20 20 20 -12 10)
(make_new_ant_type 'ANT 'ant_ai 'ant_draw 'ant_Ndamage 6 30 15 15 -6 18)
(make_new_ant_type 'ANT_GREATER2 'grant_ai 'ant_draw 'great_damage 12 100 30 30 -6 15)
	;; Xvar1 = Number of lives. Xvar2 = Can't jump?
	;; Used to be ANT_GREATER, but this class was removed when I added make_new_ant_type function.
(make_new_ant_type 'ANT_TOUGH 'tant_ai 'ant_draw 'tough_damage 9 200 10 10 -6 10)