/******************************************************************************************
*                                                                                         *
* New characters and tiles by                                                             *
* Claudio Bolzoni, version 1.5,    claudio.bolzoni@mbox300.swipnet.se                     *
*                                                                                         *
* NOTE: This and all other files by Claudio Bolzoni contained in the archive              *
* claudio(1.5).zip  can be used and modified freely for non-commercial purposes,          *
* but credits must be given to the author.                                                *
* If you intend to distribute any file, however, contact Claudio Bolzoni.                 *
* If you want to use work done by other people than Claudio Bolzoni, contact the author   *
* of that work (credits are given to those authors in this file).                         *
*                                                                                         *
*                                                                                         *
*                                                                                         *
******************************************************************************************/



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; SOUNDS                                                                                ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(def_sound 'DROIDMOV_SND    (sfxdir "Apain01.wav"))
(def_sound 'TREX1_SND    "addon/claudio/trex1.wav")
(def_sound 'STOMP_SND    (sfxdir "poof06.wav"))
(def_sound 'TREX2_SND    "addon/claudio/trex2.wav")
(def_sound 'TREX3_SND    (sfxdir "Adie03.wav"))
(def_sound 'FIRE_SND    "addon/claudio/fire.wav")
(def_sound 'SWISH_SND    "addon/claudio/spaceo.wav")
(def_sound 'SEWER1_SND    "addon/claudio/sewers.wav")
(def_sound 'GLASS1_SND    "addon/claudio/glass1.wav")
(def_sound 'UNHEALTH_UP_SND    "addon/claudio/unhealth.wav")
(def_sound 'WFALL_SND    "addon/claudio/wfall.wav")
(def_sound 'DRILL_SND    "addon/claudio/drill.wav")
(def_sound 'SKULL_SND    "addon/claudio/skull.wav")
(def_sound 'ASHIP_SND    "addon/claudio/aship.wav")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 1: droid - jugger version                                                        ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun droidjug_ai ()
  (if (<= (hp) 0);;*
      (if (eq (state) dieing)
	  (next_picture)
	  (set_state dieing)
      )
       (if (activated);; **
	     (progn       ;; ***
	       (set_targetable T)
	       (push_char 35 40)
	       (select (aistate)

		    (0 ;; prepare to walk toward player
		       (if (eq stationary 0)
		         (progn
			      (set_state running)
			      (go_state 1)
                     )
		         (if (> (state_time) (aitype))
			      (progn
			         (set_state weapon_fire)
			         (set_aistate 2)
                         )
                     )
                   )
                 );;end aistate 0

		  (1 ;; walk toward player
		   (if (eq stationary 0)
		     (progn
			 (set_direction (toward))
		       (let (
                         (curx (x));; save position in case we fall off a cliff
			       (cury (y))
                        )
		       (if (next_picture)
			    (if (eq (current_frame) 8)
				  (play_sound DROIDMOV_SND 127 (x) (y))
                      )
			    (progn
			       (play_sound DROIDMOV_SND 127 (x) (y))
			       (set_state weapon_fire)
			       (set_aistate 2)
                      )
                   )
		       (if (can_see (x) (y) (x) (+ (y) 5) nil)
			   (progn
				 (set_x curx)
				 (set_y cury)
				 (try_move 0 10)
                     )
                   )
                 )
                )
		    (if (> (state_time) (aitype))
			 (progn
			   (set_state weapon_fire)
			   (set_aistate 2)
                   )
                 )
               )
              );; end aistate 1

		  (2 ;; start fire
		   (if (> (state_time) 3)
		       (let (
                        (myself (me))
			      (xspeed (* throw_xvel (direction)))
			      (yspeed throw_yvel)
                         )
			 (with_object
                        (add_object GRENADE (+ (x) (* (direction) 16)) (- (y) 24) 1)
				(progn
			        (user_fun myself)
				  (set_xvel xspeed)
				  (set_yvel yspeed)
                        )
                   )
			 (go_state 3)
               )
		   (next_picture)
               )
             );; end aistate 2

             (3 ;; wait for fire animation
		   (if (next_picture) nil (set_aistate 0))
              );; end aistate 3
           );; end select
	  T);; end *** progn
      (progn (set_targetable nil)
	T)
);; end ** if
);; end * if
);; end droidjug_ai ()

(defun jug_cons ()
  (setq throw_xvel 13)
  (setq throw_yvel -10)
  (set_aitype 10))

(defun explo_damage_cache (type)
  (list (list EXPLODE6) nil))

(def_char DROID_JUGGER
  (range 200 0)
  (funs (ai_fun     droidjug_ai)
	(constructor jug_cons)
	(get_cache_list_fun explo_damage_cache)
	(damage_fun explo_damage))
  (flags (hurtable T)(unactive_shield T))
  (abilities (start_hp    50)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        jug_throw_spd)
	  ("throw_xvel"    jug_throw_xv)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "addon/claudio/droid.spe"
	  (stopped "ds0002.pcx")
	  (running (seq "d" 1 4))
	  (weapon_fire (seq "df" 1 10))
	  (dieing (seq "dd" 1 8))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 2: droid - walking version                                                       ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
  ;;(set_hp 70)
  (setq burst_total 5)
);; end wrob_cons

(defun droid_ai ()
  (if (<= (hp) 0) ;; *

      (if (eq (state) dieing)
	  (next_picture)
	  (set_state dieing)
       )

       (if (activated)         ;; **
          (progn                  ;;***
	       (set_targetable T)
	       (push_char 35 40)
             (select (aistate)
	          (0;; walk toward player
	            (if (or  (> (distx) 120) (or (<(disty) -5)(>(disty) 20)) (not (eq (direction) (toward))))
		         (progn
	                  (if (eq (mod (state_time) 6) 0)        ;; play sound every 6 ticks
	                    (play_sound DROIDMOV_SND 127 (x) (y))
                        )
		            (move (toward) 0 0)
		            (next_picture)
                     )
		         (progn
		            (set_state stopped)
		            (set_aistate 1)
                     )
                  )
                 );; end aistate 0

	          (1;; stop and fire
	             (burst_fire  (+ (x) (* (direction) 16)) (- (y) 22)
			    (if (> (direction) 0)
				(mod (- 375 (/ (* burst_left 30) burst_total)) 360)
			      (+ 165 (/ (* burst_left 30) burst_total))
                       )
                    )
	              (if (not (eq fire_time 0))
		            (set_aistate 0)
                    )
                );; end aistate 1
             );; end select

	       (if (<= (hp) 0)                        ;; are we dead, if so blow up
	           (progn
		        (add_object EXPLODE6 (+ (x) 5) (- (y) 10)     0)
		        (add_object EXPLODE6 (+ (x) -5) (- (y) 15)    2)  ;; wait 2 frames before appearing
		        (add_object EXPLODE6 (+ (x) 10) (- (y) 2)     1)
		        (add_object EXPLODE6 (+ (x) -10) (- (y) 20)   3)
		        (add_object EXPLODE6 (+ (x) 20) (- (y) 27)    4)
		        (add_object EXPLODE6 (+ (x) -25) (- (y) 30)   2)
		        (add_object EXPLODE6 (+ (x) 20) (- (y) 5)     4)
		        (add_object EXPLODE6 (+ (x) -3) (- (y) 1)     5)
		        (set_aistate 0)
                  )
             )

      T);; end of *** progn
    T);; end of ** if activated
  );; end of * if
);; end of ai

(def_char DROID

  (funs (ai_fun droid_ai)
	  (constructor wrob_cons)
	  (get_cache_list_fun explo_damage_cache)
        (damage_fun explo_damage)
  );; end funs

  (abilities (run_top_speed 8)
             (start_hp 70)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 300 100)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
  );; end vars

  (fields ("fire_delay"   wrob_fdelay)
	  ("burst_delay"  wrob_bdelay)
	  ("burst_total"  wrob_btotal)
	  ("max_xvel"     wrob_mxv)
	  ("max_yvel"     wrob_myv)
	  ("hp"           ai_health)
	  ("aitype"       ai_type)
	  ("aistate"      ai_state)
  );; end fields

  (states "addon/claudio/droid.spe"
	  (stopped "ds0001.pcx")
	  (running (seq "d" 1 10))
	  (start_run_jump "d0001.pcx")
	  (flinch_up      "ds0002.pcx")
	  (run_jump       "d0003.pcx")
	  (dieing (seq "dd" 1 8))
  );; end states

);; end def_char DROID

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 3: Tyrannosaurus Rex                                                              ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun trex_ai ()
  (if (<= (hp) 0) ;; *

      (if (eq (state) dieing)
        (progn
	     (next_picture)
	     (play_sound TREX3_SND 127 (x) (y))
        )
	  (set_state dieing)

       )

       (if (activated)         ;; **
          (progn                  ;;***
	       (set_targetable T)
             (if (and (touching_bg) (eq (mod (state_time) 20) 0))
                (do_damage 10 (bg)))
             (select (aistate)
	          (0;; walk toward player
                     (if  (or (< (disty) -5) (> (disty) 5) (< (distx) -10) (> (distx) 10) (not (eq (direction) (toward))) )
                       (progn
	                  (if (eq (mod (state_time) 6) 0) ;; play sound every 6 ticks
	                    (play_sound JSTOMP_SND 60 (x) (y))
                        )
	                  (if (eq (mod (state_time) 235) 0)        ;; play sound every 235 ticks
	                    (play_sound TREX1_SND 127 (x) (y))
                        )
		              (move (toward) 0 0)
		              (next_picture)
                       )
		         ;; (progn
		            (set_aistate 1)
                   ;;   )
                     )
                 );; end aistate 0

	          (1;; stop and eat
                    (if  (or (< (disty) -5) (> (disty) 5) (< (distx) -10) (> (distx) 10) (not (eq (direction) (toward))) )
                       (set_aistate 0)
                       (progn
                          (set_state eating)
                          (if (eq (mod (state_time) 66) 0)     ;; play sound every 66 ticks
	                      (play_sound TREX2_SND  127 (x) (y))
                          )
                        )
                      )
                    (with_object (bg)
                      (if (< (hp)0)
	                    (set_state stopped)
                      )
                     )
                );; end aistate 1
             );; end select
      T);; end of *** progn
    T);; end of ** if activated
  );; end of * if
);; end of ai

(def_char T_REX

  (funs (ai_fun trex_ai)
	;;  (constructor wrob_cons)
	;;  (get_cache_list_fun explo_damage_cache)
      ;;  (damage_fun explo_damage)
  );; end funs

  (abilities (run_top_speed 8)
             (start_hp 70)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 300 100)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
  );; end vars

  (fields
	  ("hp"           ai_health)
	  ("aistate"      ai_state)
  );; end fields

  (states "addon/claudio/trex1.spe"
	  (stopped "stand")
	  (running (seq "w" 1 10))
	  (start_run_jump "jumpflitch")
	  (flinch_up      "jumpflitch")
	  (run_jump       "jumpflitch")
        (blocking (seq "w" 1 5)"jumpflitch")
        (eating  (seq "e" 2 10))
	  (dieing (seq "d" 1 5))
  );; end states

);; end def_char T_REX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 4: Big walking robot                                                             ;;
;;                                                                                       ;;
;; this char comes in three versions which can be shifted between by                     ;;
;; activating/deactivating code sections in wrob_ai and in the char                      ;;
;; definition (def_char WALK_ROB), by putting and removing ";;" before code lines        ;;
;; --- version 1: exploding and disappearing when dead                                   ;;
;; --- version 2: burned debris left when dead (not blocking)                            ;;
;; --- version 2: as in version 2, but the debris are will block the player              ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun wrob_ai ()
  (if (<= (hp) 0) ;; *

       nil   ;; inactivate this "nil" and activate the following if-section when using versions 2 and 3

    ;; if (eq (state) dieing)
    ;;   (next_picture)
    ;;   (set_aistate 0)
    ;; )

       (if (activated)         ;; **
          (progn                  ;;***
	       (set_targetable T)
	       (push_char 35 40)
             (select (aistate)
	          (0;; walk toward player
	            (if (or  (> (distx) 120) (or (<(disty) -5)(>(disty) 20)) (not (eq (direction) (toward))))
		         (progn
	                  (if (eq (mod (state_time) 6) 0)        ;; play sound every 6 ticks
	                    (play_sound STOMP_SND 127 (x) (y))
                        )
		            (move (toward) 0 0)
		            (next_picture)
                     )
		         (progn
		            (set_state stopped)
		            (set_aistate 1)
                     )
                  )
                 );; end aistate 0

	          (1;; stop and fire
	             (burst_fire  (+ (x) (* (direction) 16)) (- (y) 22)
			    (if (> (direction) 0)
				(mod (- 375 (/ (* burst_left 30) burst_total)) 360)
			      (+ 165 (/ (* burst_left 30) burst_total))
                       )
                    )
	              (if (not (eq fire_time 0))
		            (set_aistate 0)
                    )
                );; end aistate 1
                (2 ;; dead robot
                   (set_state dieing)
                   (set_aistate 0)
                );; end aistate 2
             );; end select

	       (if (<= (hp) 0)                        ;; are we dead, if so blow up
	           (progn
		        (add_object EXPLODE6 (+ (x) 5) (- (y) 10)     0)
		        (add_object EXPLODE6 (+ (x) -5) (- (y) 15)    2)  ;; wait 2 frames before appearing
		        (add_object EXPLODE6 (+ (x) 10) (- (y) 2)     1)
		        (add_object EXPLODE6 (+ (x) -10) (- (y) 20)   3)
		        (add_object EXPLODE6 (+ (x) 20) (- (y) 27)    4)
		        (add_object EXPLODE6 (+ (x) -25) (- (y) 30)   2)
		        (add_object EXPLODE6 (+ (x) 20) (- (y) 5)     4)
		        (add_object EXPLODE6 (+ (x) -3) (- (y) 1)     5)
		        (set_aistate 0)
                  )
             )

      T);; end of *** progn
    T);; end of ** if activated
  );; end of * if
);; end of ai

(def_char WALK_ROB

  (funs (ai_fun wrob_ai)
	  (constructor wrob_cons)
	  (get_cache_list_fun explo_damage_cache)
        (damage_fun explo_damage)
  );; end funs

  (abilities (run_top_speed 6)
             (start_hp 70)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 300 100)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
   );; end vars

  (fields ("fire_delay"   wrob_fdelay)
	  ("burst_delay"  wrob_bdelay)
	  ("burst_total"  wrob_btotal)
	  ("max_xvel"     wrob_mxv)
	  ("max_yvel"     wrob_myv)
	  ("hp"           ai_health)
        ("aitype"       ai_type)
	  ("aistate"      ai_state)

  );; end fields

  (states "addon/claudio/rob2.spe"
	  (stopped "wwlk0001.pcx")
	  (running (seq "wwlk" 1 10))
	  (start_run_jump "wstart_jump")
	  (flinch_up      "wflinch")
        ;;(flinch_up      "wwflinch")  ;;<--- use this line instead of the one above when using version 2
	  (run_jump       "wwlk0009.pcx")
        (dieing         "wflinch")
        ;;(dieing      "wwflinch")  ;;<--- use this line instead of the one above when using version 2
  );; end states

);; end def_char WALK_ROB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 5 and 6: Space doors                                                                   ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun other_sdoor_opening ()
  (if (eq (total_objects) 0)
      nil
    (with_object (get_object 0)
		 (if (eq (otype) SPACE_DOOR)
		     (if (eq is_opening 0)
			 (if (and (< (distx) 50) (< (disty) 40))
			     T
			   nil)
		       T)
		   nil))))

(defun open_spacedoor ()

  (setq is_opening 1)
  (if (eq (current_frame) 4)
      (setq is_opening 0)
    (progn
      (if (eq (current_frame) 0)
	  (play_sound SWISH 70 (x) (y)))
      (next_picture))))

(defun close_spacedoor ()
  (setq is_opening 0)
  (if (eq (current_frame) 0)
      nil
    (progn
      (if (eq (current_frame) 4)
	  (play_sound SWISH 70 (x) (y)))
      (set_current_frame (- (current_frame) 1)))))

(defun tpdspace_ai ()     ;; teleporting door ai
  (if (or (and (< (distx) 50) (< (disty) 40))
	  (other_sdoor_opening))
      (open_spacedoor)
    (close_spacedoor))

  (let ((player (bg)))
    (if (has_object player)
	(if (not (with_object player (pressing_action_key)))
	    (remove_object player))
      (if (and (< (distx) 20) (< (disty) 30) (with_object player (pressing_action_key))
	       (> (total_objects) 0))
	  (let ((otherx (with_object (get_object 0) (x)))
		(othery (with_object (get_object 0) (y))))
	    (with_object (get_object 0) (link_object player))
	    (with_object player (progn
				  (set_x otherx)
				  (set_y othery)))))))
T)

(def_char SPACE_DOOR_WIDE
  (range 0 0)
  (vars is_opening)
  (funs (ai_fun      tpdspace_ai)
	(constructor tp_door_cons)
	(reload_fun lower_reload)
	(draw_fun   tp_door_draw))
  (fields ("xvel"   tp_amb))
  (states "addon/claudio/spaced.spe" (stopped (seq "vv" 1 6))))

(def_char SPACE_DOOR
  (funs (ai_fun sdoor_ai)
	(reload_fun lower_reload))
  (flags (can_block T))
  (range 250 60)
  (draw_range 30 50)
  (abilities (push_xrange 1))
  (states "addon/claudio/spaced.spe"
	  (stopped "sp0001.pcx")
	  (running (seq "sp" 1 6))
	  (walking (seq "sp" 6 1))
	  (blocking "sp0006.pcx")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 7, 8 and 9: Smart platforms                                                      ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun make_my_smart_plat (symbol off_frame on_frame snap_yoffset)
  (eval (list 'def_char symbol
	      '(flags (can_block T))
	      `(abilities (start_accel ,snap_yoffset))
	      `(fields ("xacel" ,plat_speed)
		       ("yacel" ,plat_2speed)
		       ("xvel"  ,plat_pos)
		       ("yvel"  ,plat_wait))
	      '(funs (ai_fun      platform_ai)
		     (constructor platform_cons))
	      '(range 50 500)
	      '(draw_range 30 60)
	      `(states "addon/claudio/nplatfor.spe"
		       (stopped   ,off_frame)
		       (running   (list ,off_frame ,on_frame) )))))

(make_my_smart_plat 'SMART_PLAT_ELEV "ele_off" "ele_on" 22)
(make_my_smart_plat 'SMART_PLAT_MEDIUM   "med_off" "med_on" 22)
(make_my_smart_plat 'SMART_PLAT_ELEV_SPACE   "ele1_off" "ele1_on" 26)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 10: Burning fire                                                                 ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun fire_ai ()
  (if (and (touching_bg) (eq (mod (state_time) 20) 0))
      (do_damage 20 (bg)))
  (select (aistate)
	  (0

            (if (eq (random 100) 0)
		 (progn
		   (play_sound FIRE_SND 127 (x) (y))
		   (set_aistate 1)))
	     (next_picture))
	  (1

           (next_picture)
	     (if (eq (state_time) 5)
		 (progn
		   (hurt_radius (x) (y) 20 20 nil 10)
		   (set_aistate 0)))))
  T)


(def_char FIRE_C
  (funs (ai_fun fire_ai))
  (states  "addon/claudio/fire.spe"
	   (stopped (seq "f" 1 33))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 11-15 Space objects                                                              ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def_char COMP_PANELS
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/mypanels.spe" (stopped (seq "c" 1 10))))


(def_char COMP_SCREEN1
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/mypanels.spe" (stopped (seq "p" 1 18))))

(def_char COMP_SCREEN2
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/mypanels.spe" (stopped (seq "s" 1 4))))

(def_char COMP_SCREEN3
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/mypanels.spe" (stopped "p0001.pcx")))

(def_char COMP_CONSOLE1
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/mypanels.spe" (stopped (seq "t" 1 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 16-21: Water objects                                                             ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun sewer_ai ()

  (select (aistate)
	  (0

            (if (eq (random 100) 0)
		 (progn
		   (play_sound SEWER1_SND 127 (x) (y))
		   (set_aistate 1)))
	     (next_picture))
	  (1

           (next_picture)
	     (if (eq (state_time) 5)
		 (progn
		   (set_aistate 0)))))
  T)

(defun deepw_cons ()
	(set_fade_count 5))

(defun deepw_ai ()
  (if (and (touching_bg) (eq (mod (state_time) 20) 0))
      (do_damage 2 (bg)))
  (select (aistate)
	  (0

            (if (eq (random 100) 0)
		 (progn
		   (play_sound SEWER1_SND 127 (x) (y))
		   (set_aistate 1)))
	     (next_picture))
	  (1

           (next_picture)
	     (if (eq (state_time) 5)
		 (progn
		   (hurt_radius (x) (y) 20 20 nil 10)
		   (set_aistate 0)))))
  T)

(defun wfall_ai ()
  (select (aistate)
	  (0

            (if (eq (random 100) 0)
		 (progn
		   (play_sound WFALL_SND 127 (x) (y))
		   (set_aistate 1)))
	     (next_picture))
	  (1

           (next_picture)
	     (if (eq (state_time) 5)
		 (progn
		   (hurt_radius (x) (y) 20 20 nil 10)
		   (set_aistate 0)))))
  T)

(def_char WATER_DEEP1
  (funs (ai_fun deepw_ai)
	(constructor deepw_cons)
  )
  (states  "addon/claudio/deepw1.spe"
	   (stopped (seq "w" 1 5))))

(def_char WATER_DEEP2
  (funs (ai_fun deepw_ai)
	(constructor deepw_cons)
  )
  (states  "addon/claudio/deepw1.spe"
	   (stopped (seq "wc" 1 5))))

(def_char WATER_SURF1
  (funs (ai_fun deepw_ai)
	(constructor deepw_cons)
  )
  (states  "addon/claudio/deepw1.spe"
	   (stopped (seq "ws" 1 5))))

(def_char WATER_SURF2
  (funs (ai_fun deepw_ai)
	(constructor deepw_cons)
  )
  (states  "addon/claudio/deepw1.spe"
	   (stopped (seq "wcs" 1 5))))

(def_char WATER_FALL1 ;; This char must be used together with the foretiles contained in extiles.spe, see watert.spe for examples
  (funs (ai_fun wfall_ai))
  (states  "addon/claudio/deepw2.spe"
	   (stopped (seq "dw" 1 5))))

(def_char SEWER_FALL_THIN ;; original art by Mike Moss
  (funs (ai_fun   sewer_ai))
  (states "addon/claudio/watem.spe" (stopped (seq "sf" 1 4))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 22, 23 and 24: Lamps: big, small and exploding                                   ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun exlamp_ai ()
  (if (<= (hp) 0)
      (if (eq (state) dieing)
	  (next_picture)
	(progn
	  (play_sound GLASS1_SND 127 (x) (y))
	  (set_state dieing)
	  T))
    T))


(def_char LAMP_EX1

  (funs (ai_fun  exlamp_ai))
  (flags (can_block T)
	 (hurtable  T))
  (abilities (start_hp 30))
  (states "addon/claudio/lamp.spe"
	  (stopped       "l0001.pcx")
	  (dieing        (seq "l" 1 10))))


(defun slamp_ai ()
(if (activated)
 (set_state running)
 (set_state stopped)
)
)


(def_char LAMP_BIG
  (funs (ai_fun   slamp_ai))
  (states "addon/claudio/lamp.spe"
     (stopped "l0002.pcx")
     (running "l0001.pcx")
  )
)


(def_char LAMP_SMALL ;; original art by Craig Redinger
  (funs (ai_fun   slamp_ai))
  (states "addon/craig/craig.spe"
     (stopped "lamp_off")
     (running "lamp_on")
   )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 25 and 26: materia (health) and anti-materia (unhealth)                          ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun antihp_up ()
	(next_picture)

	(if (and (touching_bg) (with_object (bg) (give_player_health -20)))
	   (progn
	     (play_sound UNHEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))


(def_char SPACE_HEALTH
  (funs (ai_fun hp_up))
  (flags (add_front T))
  (range 0 0)
  (states "addon/claudio/spaceh.spe" (stopped (seq "h" 1 2) )))

(def_char SPACE_UNHEALTH
  (funs (ai_fun antihp_up))
  (flags (add_front T))
  (range 0 0)
  (states "addon/claudio/spaceh.spe" (stopped (seq "h" 1 2) )))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHARS 27 and 28: Space switch and Lava burst                                          ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(def_char SPACE_SWITCH
  (funs (ai_fun switcher_ai)
	(reload_fun lower_reload))
  (range 0 0)
  (states "addon/claudio/sswitch.spe"
	  (stopped '("ssw0001" "ssw0002"))
	  (running '("ssw0003"  "ssw0004"))))

(def_char LAVA_BURST
  (funs (ai_fun   do_nothing))
  (states "addon/claudio/lava2.spe" (stopped (seq "p" 1 15))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 29 and 30: Ant boss v.2 and Super ant  - not working yet                         ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(load "addon/claudio/antextra.lsp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 31: Death Umbrella                                                               ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(defun dumbrel_ai ()

  (if (not (eq smoke_time 0))
      (progn
	(setq smoke_time (- smoke_time 1))
	(if (eq (mod smoke_time 2) 0)
	    (add_object SMALL_DARK_CLOUD (x) (y)))))

  (if (eq (aistate) 0)
      (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
	  (if (next_picture) T
	    (progn
	      (set_targetable T)
	      (set_state running)
	      (set_aistate 1)))
	(progn
	  (set_targetable nil)
	  (set_state stopped)
	  T))
    (if (eq (hp) 0)
	(progn
        (play_sound GRENADE_SND 127 (x) (y))
	  (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
	  (add_object EXPLODE1 (- (x) (random 10)) (+ (- (y) (random 10)) -20)     2)
	  (add_object EXPLODE1 (x) (+ (- (y) (random 20)) -20)                     4)
	  nil)
      (progn
	(if (eq (mod (state_time) 5) 0)
	    (play_sound DRILL_SND 127 (x) (y)))
	(if (> (with_object (bg) (x)) (x))
	    (progn
	      (set_xvel (+ (xvel) 1))
	      (if (> (xvel) max_xvel) (set_xvel max_xvel))
	      (if (eq (direction) -1)
		  (progn
		    (set_direction 1)
		    (set_state turn_around))))
	  (if (< (with_object (bg) (x)) (x))
	      (progn
		(set_xvel (- (xvel) 1))
		(if (< (xvel) (- 0 max_xvel)) (set_xvel (- 0 max_xvel)))
		(if (eq (direction) 1)
		    (progn
		      (set_direction -1)
		      (set_state turn_around))))))
	(if (> (with_object (bg) (- (y) 70)) (y))
	    (if (> (yvel) max_yvel)
		(set_yvel (- (yvel) 1))
	      (set_yvel (+ (yvel) 1)))

	  (if (< (with_object (bg) (- (y) 50)) (y))
	      (if (< (yvel) (- 0 max_yvel))
		  (set_yvel (+ (yvel) 1))
		(set_yvel (- (yvel) 1)))))

	(if (eq (random 5) 0)
	    (set_xvel (+ (xvel) 1))
	  (if (eq (random 5) 0)
	      (set_xvel (- (xvel) 1))))
	(if (eq (random 5) 0)
	    (set_yvel (+ (yvel) 1))
	  (if (eq (random 5) 0)
	      (set_yvel (- (yvel) 1))))

	(if (next_picture) T (set_state running))

	(bounce_move '(set_xvel (/ (xvel) 2)) '(set_xvel (/ (xvel) 2))
		     '(set_yvel (/ (yvel) 2)) '(set_yvel (/ (yvel) 2)) nil)

	(if (> fire_time 0)              ;; if we need to wait till next burst
	    (progn
	      (setq fire_time (- fire_time 1))
	      (if (eq fire_time 0)
		  (progn
		    (setq burst_left burst_total)
		    (setq burst_wait 0))))
	  (if (eq burst_wait 0)
	      (if (and (< (distx) 150) (eq (direction) (facing)))
		  (let ((firex (+ (x) (* (direction) 10)) )
			(firey (y))
			(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 4))))
			(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))
		    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
			(progn
			  (let ((angle (atan2 (- firey playery)
					      (- playerx firex))))
			    (if (or (eq burst_left 1) (eq burst_left 0))
				(setq fire_time fire_delay)
			      (setq burst_left (- burst_left 1)))
			    (setq burst_wait burst_delay)
			    (fire_object (me) (aitype) firex firey angle (bg))
			    )))))
	    (setq burst_wait (- burst_wait 1))))
	T))))

(defun dumbrel_damage (amount from hitx hity push_xvel push_yvel)
  (if (and from (with_object from (and (> (total_objects) 0)
				       (with_object (get_object 0)
						    (or (eq (otype) FLYER)
							(eq (otype) GREEN_FLYER))
							))))
      nil
    (if (eq (state) stopped) nil
      (progn
	(setq smoke_time 30)
	(set_yvel (- (yvel) 14))
	(set_state flinch_up)
	(damage_fun amount from hitx hity push_xvel push_yvel)
	(if (and(< (hp) 100)(>(hp) 85))
	      (set_aitype 1)
      )
	(if (and(< (hp) 85)(>(hp) 70))
	      (set_aitype 9)
      )
	(if (and(< (hp) 70)(>(hp) 45))
	      (set_aitype 4)
      )
	(if (and(< (hp) 45) (>(hp)20))
	      (set_aitype 3)
      )
	(if (and(< (hp) 20)(>(hp)0))
	      (set_aitype 5)
      )
))))

(defun dumbrel_cons ()
  (setq fire_delay 20)
  (setq burst_delay 5)
  (setq max_xvel 2)
  (setq max_yvel 1)
  (set_aitype 0)
  (setq burst_total 2))

(def_char DEATH_UMBRELLA

  (funs (ai_fun dumbrel_ai)
	  (constructor dumbrel_cons)
	  (get_cache_list_fun explo_damage_cache)
        (damage_fun dumbrel_damage)
  );; end funs

  (abilities (start_hp 100)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 300 100)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
   );; end vars

  (states "addon/claudio/umbrel3.spe"
	  (stopped "u0001.pcx")
	  (running (seq "u" 1 4))
        ;;(dieing  (seq "u" 7 12))
  );; end states

);; end def_char


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 32: Ant Ship                                                                     ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun antship_ai ()

  (if (not (eq smoke_time 0))
      (progn
	  (setq smoke_time (- smoke_time 1))
	  (if (eq (mod smoke_time 2) 0)
	    (add_object SMALL_DARK_CLOUD (x) (y))
        )
      )
  )

  (if (eq (aistate) 0)

      (if  (or  (eq (total_objects) 0)  (not(eq (with_object(get_object 0)(aistate))0)))
	  (if (next_picture) T
	    (progn
	      (set_targetable T)
	      (set_state running)
	      (set_aistate 1)
          )
        )
	  (progn
	    (set_targetable nil)
	    (set_state stopped)
	  T)
      )

      (if (<= (hp) 0)

         (progn

          (if (eq (state) dieing)
	      (next_picture)

              (progn
                (set_state dieing)
                (play_sound GRENADE_SND 127 (x) (y))
	          (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
	          (add_object EXPLODE1 (- (x) (random 10)) (+ (- (y) (random 10)) -20)     2)
	          (add_object EXPLODE0 (x) (+ (- (y) (random 20)) -20)                     6)
              )

          )
        )
        (progn
	    (if (eq (mod (state_time) 5) 0)
	      (play_sound ASHIP_SND 127 (x) (y))
          )
	    (if (> (with_object (bg) (x)) (x))
	    (progn
	      (set_xvel (+ (xvel) 1))
	      (if (> (xvel) max_xvel)
               (set_xvel max_xvel)
            )
	      (if (eq (direction) -1)
		  (progn
		    (set_direction 1)
		    (set_state turn_around)
               )
             )
           )
	     (if (< (with_object (bg) (x)) (x))
	        (progn
	      	(set_xvel (- (xvel) 1))
	      	(if (< (xvel) (- 0 max_xvel))
                   (set_xvel (- 0 max_xvel))
                  )
	      	(if (eq (direction) 1)
		         (progn
		           (set_direction -1)
		           (set_state turn_around)
                     )
                  )
               )
           )
        )

	(if (> (with_object (bg) (- (y) 70)) (y))
	    (if (> (yvel) max_yvel)
		(set_yvel (- (yvel) 1))
	      (set_yvel (+ (yvel) 1))
          )
	    (if (< (with_object (bg) (- (y) 50)) (y))
	      (if (< (yvel) (- 0 max_yvel))
		  (set_yvel (+ (yvel) 1))
		  (set_yvel (- (yvel) 1))
            )
          )
       )

	(if (eq (random 5) 0)
	    (set_xvel (+ (xvel) 1))
	    (if (eq (random 5) 0)
	      (set_xvel (- (xvel) 1))))
	(if (eq (random 5) 0)
	    (set_yvel (+ (yvel) 1))
	  (if (eq (random 5) 0)
	      (set_yvel (- (yvel) 1))))

	(if (next_picture) T (set_state running))

	(bounce_move '(set_xvel (/ (xvel) 8)) '(set_xvel (/ (xvel) 8))
		     '(set_yvel (/ (yvel) 8)) '(set_yvel (/ (yvel) 8)) nil)

	(if (> fire_time 0)
	    (progn
	      (setq fire_time (- fire_time 1))
	      (if (eq fire_time 0)
		  (progn
		    (setq burst_left burst_total)
		    (setq burst_wait 0))))
	  (if (eq burst_wait 0)
	      (if (and (< (distx) 150) (eq (direction) (facing)))
		  (let ((firex (+ (x) (* (direction) 10)) )
			(firey (y))
			(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 4))))
			(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))
		    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
			(progn
			  (let ((angle (atan2 (- firey playery)
					      (- playerx firex))))
			    (if (or (eq burst_left 1) (eq burst_left 0))
				(setq fire_time fire_delay)
			      (setq burst_left (- burst_left 1)))
			    (setq burst_wait burst_delay)
			    (fire_object (me) (aitype) firex firey angle (bg))
			    )))))
	    (setq burst_wait (- burst_wait 1))))
	T)))

);; end ai

(defun antship_damage (amount from hitx hity push_xvel push_yvel)
  (if (and from (with_object from (and (> (total_objects) 0)
				       (with_object (get_object 0)
						    (or (eq (otype) FLYER)
							(eq (otype) GREEN_FLYER))
							))))
      nil
    (if (eq (state) stopped) nil
      (progn
	(setq smoke_time 30)
	(set_yvel (- (yvel) 1))
	(set_state flinch_up)
	(damage_fun amount from hitx hity push_xvel push_yvel)
	(if (and(< (hp) 300)(>(hp) 250))
	      (set_aitype 1)
      )
	(if (and(< (hp) 250)(>(hp) 200))
	      (set_aitype 9)
      )
	(if (and(< (hp) 200)(>(hp) 150))
	      (set_aitype 4)
      )
	(if (and(< (hp) 150) (>(hp)100))
	      (set_aitype 6)
      )
	(if (and(< (hp) 100) (>(hp)50))
	      (set_aitype 3)
      )
	(if (and(< (hp) 50)(>(hp)0))
	      (set_aitype 5)
      )
))))

(defun antship_cons ()
  (setq fire_delay 30)
  (setq burst_delay 8)
  (setq max_xvel 2)
  (setq max_yvel 1)
  (set_aitype 0)
  (setq burst_total 3))


(def_char ANT_SHIP  ;; original art by Steven Chan, schan@eecs.berkeley.edu


  (funs (ai_fun antship_ai)
	  (constructor antship_cons)
	  (get_cache_list_fun explo_damage_cache)
        (damage_fun antship_damage)
  );; end funs

  (abilities (start_hp 300)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 400 200)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
   );; end vars

  (states "addon/claudio/antship.spe"
	  (stopped "s0001.pcx")
	  (running (seq "s" 2 6))
        (flinch_up (seq "s" 1 6))
        (dieing  (seq "s" 7 12))
  );; end states

);; end def_char


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; CHAR 33: Death Skull                                                                  ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun dskull_ai ()
  (if (not (eq smoke_time 0))
      (progn
	(setq smoke_time (- smoke_time 1))
	(if (eq (mod smoke_time 2) 0)
	 (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
      )
       )
 )

  (if (eq (aistate) 0)
      (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
	  (if (next_picture) T
	    (progn
	      (set_targetable T)
	      (set_state running)
	      (set_aistate 1)))
	(progn
	  (set_targetable nil)
	  (set_state stopped)
	  T))
    (if (eq (hp) 0)
	(progn
        (play_sound GRENADE_SND 127 (x) (y))
	  (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
	  (add_object EXPLODE1 (- (x) (random 10)) (+ (- (y) (random 10)) -20)     2)
	  (add_object EXPLODE1 (x) (+ (- (y) (random 20)) -20)                     4)
	  nil)
      (progn
	(if (eq (mod (state_time) 10) 0)
	    (play_sound SKULL_SND 127 (x) (y)))
	(if (> (with_object (bg) (x)) (x))
	    (progn
	      (set_xvel (+ (xvel) 1))
	      (if (> (xvel) max_xvel) (set_xvel max_xvel))
	      (if (eq (direction) -1)
		  (progn
		    (set_direction 1)
		    (set_state turn_around))))
	  (if (< (with_object (bg) (x)) (x))
	      (progn
		(set_xvel (- (xvel) 1))
		(if (< (xvel) (- 0 max_xvel)) (set_xvel (- 0 max_xvel)))
		(if (eq (direction) 1)
		    (progn
		      (set_direction -1)
		      (set_state turn_around))))))
	(if (> (with_object (bg) (- (y) 70)) (y))
	    (if (> (yvel) max_yvel)
		(set_yvel (- (yvel) 1))
	      (set_yvel (+ (yvel) 1)))

	  (if (< (with_object (bg) (- (y) 50)) (y))
	      (if (< (yvel) (- 0 max_yvel))
		  (set_yvel (+ (yvel) 1))
		(set_yvel (- (yvel) 1)))))

	(if (eq (random 5) 0)
	    (set_xvel (+ (xvel) 1))
	  (if (eq (random 5) 0)
	      (set_xvel (- (xvel) 1))))
	(if (eq (random 5) 0)
	    (set_yvel (+ (yvel) 1))
	  (if (eq (random 5) 0)
	      (set_yvel (- (yvel) 1))))

	(if (next_picture) T (set_state running))

	(bounce_move '(set_xvel (/ (xvel) 2)) '(set_xvel (/ (xvel) 2))
		     '(set_yvel (/ (yvel) 2)) '(set_yvel (/ (yvel) 2)) nil)

	(if (> fire_time 0)
	    (progn
	      (setq fire_time (- fire_time 1))
	      (if (eq fire_time 0)
		  (progn
		    (setq burst_left burst_total)
		    (setq burst_wait 0))))
	  (if (eq burst_wait 0)
	      (if (and (< (distx) 150) (eq (direction) (facing)))
		  (let ((firex (+ (x) (* (direction) 10)) )
			(firey (y))
			(playerx (+ (with_object (bg) (x)) (with_object (bg) (* (xvel) 4))))
			(playery (+ (- (with_object (bg) (y)) 15) (with_object (bg) (* (yvel) 2)))))
		    (if (and (can_see (x) (y) firex firey nil) (can_see firex firey playerx playery nil))
			(progn
			  (let ((angle (atan2 (- firey playery)
					      (- playerx firex))))
			    (if (or (eq burst_left 1) (eq burst_left 0))
				(setq fire_time fire_delay)
			      (setq burst_left (- burst_left 1)))
			    (setq burst_wait burst_delay)
			    (fire_object (me) (aitype) firex firey angle (bg))
			    )))))
	    (setq burst_wait (- burst_wait 1))))
	T))))


(defun dskull_damage (amount from hitx hity push_xvel push_yvel)
  (if (and from (with_object from (and (> (total_objects) 0)
				       (with_object (get_object 0)
						    (or (eq (otype) FLYER)
							(eq (otype) GREEN_FLYER))
							))))
      nil
    (if (eq (state) stopped) nil
      (progn
	(setq smoke_time 30)
	(set_yvel (- (yvel) 14))
	(set_state flinch_up)
	(damage_fun amount from hitx hity push_xvel push_yvel)
	(if (and(< (hp) 100)(>(hp) 50))
	      (set_aitype 9)
      )
	(if (and(< (hp) 50)(>(hp)0))
	      (set_aitype 5)
      )

))))

(defun dskull_cons ()
  (setq fire_delay 20)
  (setq burst_delay 5)
  (setq max_xvel 2)
  (setq max_yvel 1)
  (set_aitype 9)
  (setq burst_total 2))


(def_char DEATH_SKULL
  (funs (ai_fun dskull_ai)
	  (constructor dskull_cons)
	  (get_cache_list_fun explo_damage_cache)
        (damage_fun dskull_damage)
  );; end funs

  (abilities (start_hp 100)
  );; end abilities

  (flags (hurtable T)
         (can_block T)
         (unactive_shield T)
  );; end flags

  (range 300 100)

  (vars fire_delay
        burst_delay
        burst_total
        burst_wait
        burst_left
	  max_xvel
        max_yvel
        smoke_time
        fire_time
   );; end vars

  (states "addon/claudio/skull.spe"
	  (stopped "s0001.pcx")
	  (running '("s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx"
                   "s0002.pcx" "s0002.pcx" "s0002.pcx" "s0002.pcx" "s0002.pcx" "s0002.pcx" "s0002.pcx" "s0002.pcx"
                   "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx" "s0001.pcx"
                   "s0024.pcx" "s0024.pcx" "s0024.pcx" "s0024.pcx" "s0024.pcx" "s0024.pcx" "s0024.pcx" "s0024.pcx"))
        (flinch_up  (seq "s" 2 18))
        (turn_around (seq "s" 1 24))

  );; end states

);; end def_char

(def_explo 'EXPLODE0 "addon/claudio/bigexp.spe" "fire"           7)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; TILES   (foreground and background tiles)                                             ;;
;;                                                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load_tiles
          "addon/claudio/pal81.spe"    ;; space foretiles 1, numbered from 8100,  palette space1
	    "addon/claudio/pal82.spe"    ;; space foretiles 2, numbered from 8200,  palette space2
	    ;; "addon/claudio/pal83.spe" ;; space foretiles 3, numbered from 8300,  palette space3
	    "addon/claudio/pal90.spe"    ;; stars backtiles 1, numbered from 9000,
	    "addon/claudio/pal2.spe"     ;; sewers backtiles,  numbered from 2000,
	    "addon/claudio/pal21.spe"    ;; stars backtiles 2, numbered from 2100,
	    "addon/claudio/pal5.spe"     ;; corallo backtiles, numbered from 5000,
	    "addon/claudio/extiles.spe"  ;; extra foretiles,   numbered from 10000, palette extra1
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                                       ;;
;; Characters and Tiles by other people                                                  ;;
;;                                                                                       ;;
;; WARNING: this section assumes that you have the following files:                      ;;
;; - aliens.spe,                                                                         ;;
;; - albtiles.spe,                                                                       ;;
;; - alftiles.spe by Mike Moss to be put in the folder Abuse\addon\mike                  ;;
;; - craig.spe  by Craig to be put in the folder Abuse\addon\craig                       ;;
;; - justin.spe by Justin Cassidy to be put in the folder Abuse\addon\justin             ;;
;;                                                                                       ;;
;; Contact these authors if you want to get more infor about their work.                 ;;
;; Otherwise, deactivate                                                                 ;;
;; the following section as indicated below in order to use the characters               ;;
;; and tiles by Claudio Bolzoni only.                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;  /*THIS IS LINE "A": DELETE THE ";;" AT THE BEGINNING OF THIS LINE AND OF LINE "B" BELOW TO DEACTIVATE THE FOLLOWING SECTION


/******************************************************************************************
* Characters and Tiles                                                                    *
* By Michael Moss,  mad666mike@aol.com                                                   *                          *
******************************************************************************************/

(def_char SEWER_GRIND
  (funs (ai_fun  sewer_ai))
  (states "addon/mike/aliens.spe" (stopped (seq "wgrl" 1 3))))

(def_char SEWER_FALL
  (funs (ai_fun   sewer_ai))
  (states "addon/mike/aliens.spe" (stopped (seq "wfal" 1 4))))

(load_tiles "addon/mike/albtiles.spe"
            "addon/mike/alftiles.spe"
)


/******************************************************************************************
* Characters and Tiles                                                                    *
* By Craig Redinger,  car188@psu.edu                                                      *
******************************************************************************************/

(load_tiles "addon/craig/craig.spe")

(def_char LAMP
  (funs (ai_fun   do_nothing))
  (states "addon/craig/craig.spe" (stopped "lamp")))

(def_char WIRES
  (funs (ai_fun   do_nothing))
  (states "addon/craig/craig.spe" (stopped "wires")))

(def_char PIPES1
  (funs (ai_fun   do_nothing))
  (states "addon/craig/craig.spe" (stopped "pipes1")))

(def_char PIPES2
  (funs (ai_fun   do_nothing))
  (states "addon/craig/craig.spe" (stopped "pipes2")))

(def_char DRIP_WATER
  (funs (ai_fun   do_nothing))
  (states "addon/craig/craig.spe" (stopped (seq "drip" 1 5))))


/******************************************************************************************
* Characters and Tiles                                                                    *
* By Justin Cassidy, julie@corecom.net                                                    *
******************************************************************************************/

(def_char ICE_WATER
  (funs (ai_fun   do_nothing))
  (states "addon/justin/justin.spe" (stopped "water_object")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;  */THIS IS LINE "B": DELETE THE ";;" AT THE BEGINNING OF THIS LINE AND OF LINE "A" ABOVE TO DEACTIVATE THIS SECTION


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

