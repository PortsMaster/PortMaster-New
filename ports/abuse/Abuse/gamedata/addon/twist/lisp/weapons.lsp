;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(make_ammo_icon 'DRAY_ICON4 "/cam/tmp/murray/amms0008.pcx"      4)
(make_ammo_icon 'DRAY_ICON8 "/cam/tmp/murray/ammb0008.pcx"      8)

(defun ammo_type ()
  (select (otype)
	  (GRENADE_TOP  2)
	  (MGUN_TOP     10)
	  (FIREBOMB_TOP 5)
	  (ROCKET_TOP   3)
	  (PGUN_TOP     4)
	  (LSABER_TOP   5)
	  (DFIRS_TOP    6)
	  (DRAY_TOP     8)
	  ))

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
	   (DRAY_TOP      (list DEATH_RAY))
   nil)))


;; Introductory to the BFG7000 - The Death Ray
;; BFG - Big Fraggin Gun

;; I finally got the Death Ray to do something cool!
;; It will shoot rockets and if you keep holding,
;; it will shoot out a burst of energy.

;; Try changing the top_ufun to
;; player_rocket_ufun, laser_ufun or plaser_ufun

(make_top_char 'DRAY_TOP "4gbf" 'dray_ufun           'top_draw)

(defun dray_ufun () 0)

(defun get_dray_angle ()
  (let ((px (with_object (bg) (player_pointer_x)))
	(py (with_object (bg) (player_pointer_y))))
    (atan2 (- (y) py 4)
	   (- px (x)))))


(defun death_ray_ai ()
(next_picture)
(hurt_radius (x) (y) 30 20 (bg) 15)
(set_course (aistate) 6)
(if (not (eq (bmove (bg)) T))
	(progn
	(do_dray_explo 50 40)
	nil))
(add_object QUICK_EXP_LIGHT (x) (- (y) 10) 100)
(if (<= (state_time) 20) (bmove (bg)) (do_drl_explo 50 40)
  ))


(defun death_ray_draw () ;; Makes the bfg behaves like the bfg from quake2
	(draw)
  (let ((c1 (find_rgb 128 0 128))
	(c2 (find_rgb 70 59 67))
	(c3 (find_rgb 147 155 195)))
		(let ((target (with_object (me) (find_object_in_area
				      (- (x) 50) (- (y) 50)
				      (+ (x) 50) (+ (y) 50) object_destroyable_list))))
	(if target
	  (progn
    (draw_line (with_object target (- (x) 1)) (with_object target (-(y)(/(picture_height)2))) (-(x)1) (-(y)10) 239)
    (draw_line (with_object target (x)) (with_object target (-(y)(/(picture_height)2))) (x) (-(y)10) 187)
    (draw_line (with_object target (+ (x) 1)) (with_object target (-(y)(/(picture_height)2))) (+(x)1) (-(y)10) 239)
	(add_object EXPDRL (with_object target (-(+(x)10)(random 20))) (with_object target (- (+ (-(y)(/(picture_height)2)) 10) (random 20))) 1)
	(hurt_radius (with_object target (x)) (with_object target (y)) 1 2 (bg) 15)
	  )
	)
  ))
)

(defun death_ray_cons ()
(set_aistate (get_dray_angle)))

(defun death_ray_cache (type)
  (list (list EXPDRAY QUICK_EXP_LIGHT)
	(list DEATH_RAY_SND)))

(def_char DEATH_RAY
  (funs (ai_fun death_ray_ai)
	(constructor death_ray_cons)
	(draw_fun death_ray_draw)
	(get_cache_list_fun death_ray_cache))
  (range 10000 10000)
  (flags (unlistable T)(add_front T))
  (states "addon/twist/art/dray.spe" (stopped (seqbmp "dray" 1 4))))

(def_explo 'EXPDRAY "addon/twist/art/dray.spe"    "dexp"         6)
(def_explo 'EXPDRL "addon/twist/art/dray.spe"    "drl"         6)

(defun do_dray_explo (radius amount)
      (play_sound DEATH_RAY_SND 127 (x) (y))
      (add_object EXPDRAY (x) (- (y) 10) 0)
      (if (not (frame_panic))
	  (progn
	    (add_object EXP_LIGHT (x) (y) 100)))
      (hurt_radius (x) (y) radius amount (bg) 20)
      nil)

(defun do_drl_explo (radius amount)
      (play_sound DEATH_RAY_SND 127 (x) (y))
      (add_object EXPDRL (x) (- (y) 10) 0)
      (if (not (frame_panic))
	  (progn
	    (add_object EXP_LIGHT (x) (y) 100)))
      (hurt_radius (x) (y) radius amount (bg) 20)
      nil)

;; If the player dosent have the weapon, ammo dosen't add.
;; Give weapon when taking ammo if custom abuse levels are loaded.

(defun giver (type)
  (let ((amount (get_ability start_hp)))
    (with_object (bg)
		 (progn
		   (if (and (not (has_weapon type)) change_on_pickup)
		       (progn
			 (if (or (get_option "-f") (eq enableammoandweapons 1)) (give_weapon type))
			 (if (or (get_option "-f") (eq enableammoandweapons 1)) (set_current_weapon type))
			)
		     (if (or (get_option "-f") (eq enableammoandweapons 1)) (give_weapon type))
			)
		   (add_ammo type amount)))))

(defun giverweap (type)
  (let ((amount (get_ability start_hp)))
    (with_object (bg)
		 (progn
		   (if (and (not (has_weapon type)) change_on_pickup)
		       (progn
			 (give_weapon type)
			 (set_current_weapon type))
		     (give_weapon type))
		   (add_ammo type amount)))))


(defun weapon_icon_ai ()
  (if (eq0 (aistate))
      (if (activated)
	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))  ; if we are on the floor, don't check falling anymore
		(set_aistate 1))

	    (if (touching_bg)
		(progn
		  (play_sound AMMO_SND 127 (x) (y))
		  (select (otype)
			  (MBULLET_ICON5   (giver 0));; these numbers correspond to status bar position
			  (MBULLET_ICON20  (giver 0))
			  (GRENADE_ICON2   (giver 1))
			  (GRENADE_ICON10  (giver 1))

			  (ROCKET_ICON2    (giver 2))
			  (ROCKET_ICON5    (giver 2))

			  (FBOMB_ICON1     (giver 3))
			  (FBOMB_ICON5     (giver 3))

			  (PLASMA_ICON20   (giver 4))
			  (PLASMA_ICON50   (giver 4))

			  (LSABER_ICON50   (giver 5))
			  (LSABER_ICON100  (giver 5))

			  (DFRIS_ICON4     (giver 6))
			  (DFRIS_ICON10    (giver 6))

			  (DRAY_ICON4      (giver 7))
			  (DRAY_ICON8      (giver 7))

			  )

		  nil)
	      T))
	T)
    (if (touching_bg)
	(progn
	  (play_sound AMMO_SND 127 (x) (y))
	  (select (otype)
		  (MBULLET_ICON5   (giver 0));; these numbers correspond to status bar position
		  (MBULLET_ICON20  (giver 0))
		  (GRENADE_ICON2   (giver 1))
		  (GRENADE_ICON10  (giver 1))

		  (ROCKET_ICON2    (giver 2))
		  (ROCKET_ICON5    (giver 2))

		  (FBOMB_ICON1     (giver 3))
		  (FBOMB_ICON5     (giver 3))

		  (PLASMA_ICON20   (giver 4))
		  (PLASMA_ICON50   (giver 4))

		  (LSABER_ICON50   (giver 5))
		  (LSABER_ICON100  (giver 5))

		  (DFRIS_ICON4     (giver 6))
		  (DFRIS_ICON10    (giver 6))

	          (DRAY_ICON4      (giver 7))
		  (DRAY_ICON8      (giver 7))

		  )
	  nil)
      T)))



(defun weapon_iconweap_ai ()
  (if (eq0 (aistate))
      (if (activated)
	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))  ; if we are on the floor, don't check falling anymore
		(set_aistate 1))

	    (if (touching_bg)
		(progn
		  (play_sound AMMO_SND 127 (x) (y))
		  (select (otype)
			  (WEAP_MBULLET   (giverweap 0));; these numbers correspond to status bar position
			  (WEAP_GRENADE   (giverweap 1))
			  (WEAP_ROCKET    (giverweap 2))
			  (WEAP_FBOMB     (giverweap 3))
			  (WEAP_PLASMA    (giverweap 4))
			  (WEAP_LSABER    (giverweap 5))
			  (WEAP_DFRIS     (giverweap 6))
			  (WEAP_DRAY      (giverweap 7))
			  )
		  nil)
	      T))
	T)
    (if (touching_bg)
	(progn
	  (play_sound AMMO_SND 127 (x) (y))
	  (select (otype)
			  (WEAP_MBULLET   (giverweap 0));; these numbers correspond to status bar position
			  (WEAP_GRENADE   (giverweap 1))
			  (WEAP_ROCKET    (giverweap 2))
			  (WEAP_FBOMB     (giverweap 3))
			  (WEAP_PLASMA    (giverweap 4))
			  (WEAP_LSABER    (giverweap 5))
			  (WEAP_DFRIS     (giverweap 6))
			  (WEAP_DRAY      (giverweap 7))
		  )
	  nil)
      T)))


(defun ammo_cache (type)    ;; tells what other chars to load in with this character
  (list
   (select type
	   (GRENADE_ICON2    `(,GRENADE ,GRENADE_TOP))
	   (GRENADE_ICON10   `(,GRENADE ,GRENADE_TOP))
	   (MBULLET_ICON5    `(,SHOTGUN_BULLET ,MGUN_TOP))
	   (MBULLET_ICON20   `(,SHOTGUN_BULLET ,MGUN_TOP))
	   (ROCKET_ICON2     `(,ROCKET ,ROCKET_TOP))
	   (ROCKET_ICON5     `(,ROCKET ,ROCKET_TOP))
	   (FBOMB_ICON1      `(,FIREBOMB ,FIREBOMB_TOP))
	   (FBOMB_ICON5      `(,FIREBOMB ,FIREBOMB_TOP))

	   (PLASMA_ICON20    `(,PLASMAGUN_BULLET))
	   (PLASMA_ICON50    `(,PLASMAGUN_BULLET))

	   (LSABER_ICON50    `(,LSABER_BULLET ,PGUN_TOP))
	   (LSABER_ICON100   `(,LSABER_BULLET ,PGUN_TOP))

	   (DFRIS_ICON4      `(,DFRIS_BULLET ,DFRIS_TOP))
	   (DFRIS_ICON10     `(,DFRIS_BULLET ,DFRIS_TOP))

	   (DRAY_ICON4      `(,DEATH_RAY ,DRAY_TOP))
	   (DRAY_ICON8      `(,DEATH_RAY ,DRAY_TOP))
   nil)))


(defun ammoweap_cache (type)    ;; tells what other chars to load in with this character
  (list
   (select type
	   (WEAP_GRENADE    `(,GRENADE ,GRENADE_TOP))
	   (WEAP_MBULLET    `(,SHOTGUN_BULLET ,MGUN_TOP))
	   (WEAP_ROCKET     `(,ROCKET ,ROCKET_TOP))
	   (WEAP_FBOMB      `(,FIREBOMB ,FIREBOMB_TOP))
	   (WEAP_PLASMA    `(,PLASMAGUN_BULLET))
	   (WEAP_LSABER    `(,LSABER_BULLET ,PGUN_TOP))
	   (WEAP_DFRIS      `(,DFRIS_BULLET ,DFRIS_TOP))
	   (WEAP_DRAY      `(,DEATH_RAY ))
   nil)))

(defun make_ammo_icon (symbol icon_name increment)
  (eval (list 'def_char symbol
	      '(funs (ai_fun weapon_icon_ai)
		     (get_cache_list_fun ammo_cache)
		     (draw_fun on_draw))
	      '(range 5 5)
	      '(flags (add_front T))
	      `(abilities (start_hp ,increment))
	      `(states  "art/chars/ammo.spe" (stopped ,icon_name)))))

(defun make_ammoweap_icon (symbol icon_name increment)
  (eval (list 'def_char symbol
	      '(funs (ai_fun weapon_iconweap_ai)
		     (get_cache_list_fun ammoweap_cache)
		     (draw_fun on_draw))
	      '(range 5 5)
	      '(flags (add_front T))
	      `(abilities (start_hp ,increment))
	      `(states  "addon/twist/art/weapons.spe" (stopped ,icon_name)))))

(make_ammoweap_icon 'WEAP_GRENADE  "weap2"  2)
(make_ammoweap_icon 'WEAP_MBULLET  "weap1"  5)
(make_ammoweap_icon 'WEAP_FBOMB    "weap4"  1)
(make_ammoweap_icon 'WEAP_ROCKET   "weap3"  2)
(make_ammoweap_icon 'WEAP_PLASMA   "weap5"  20)
(make_ammoweap_icon 'WEAP_LSABER   "weap6"  50)
(make_ammoweap_icon 'WEAP_DFRIS    "weap7"  4)
(make_ammoweap_icon 'WEAP_DRAY     "weap8"  4)

