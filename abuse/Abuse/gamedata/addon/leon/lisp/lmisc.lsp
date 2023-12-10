(defun lava2_ai ()
  (if (eq (random 75) 0) (play_sound LAVA_SND 24 (x) (y)) )
  (select (aistate)
	  (0
             (if (eq (state_time) dam_spd)
		 (progn
		   (set_aistate 1)))
	     (next_picture))
	  (1 (next_picture)
	     (if (eq (state_time) dam_spd)
		 (progn
		   (hurt_radius (+ (x) 15) (y) 30 dam nil 4)
		   (set_aistate 0)))))
  T)

(defun lava2_cons ()
  (setq dam_spd 5)
  (setq dam 10))

(def_char LAVA2
  (funs (ai_fun lava2_ai)
        (constructor lava2_cons))
  (vars dam_spd dam )
  (fields  ("dam_spd" wrob_bdelay)
           ("dam" wrob_btotal))
  (states  "art/chars/lava.spe"
	   (stopped (seq "lava" 1 15))))

(defun Lrestart_ai ()
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
					(if (eq difficulty 'easy)
					    (set_hp 100));; save the player with 100 health, if on easy
					(play_sound SAVE_SND 127 (x) (y))
					(setq has_saved_this_level spot)
					(save_game (concatenate 'string "save" (digstr spot 4) ".spe"))
					(set_hp old_hp)
					))))))

	       )))
  T)


(def_char LRESTART_POSITION
  (funs (ai_fun Lrestart_ai)
	(reload_fun lower_reload))
  (fields ("xvel"  restart_station))
  (states "art/misc.spe"
	  (stopped (app (rep "console" 3) (rep "console2" 3)))
	  (running (rep "console_on" 2))))

(def_char HIDDEN_BACK_METAL
	   (funs (ai_fun hwall_ai)
		 (reload_fun  hwall_reload)
		 (damage_fun hwall_damage))
	   (abilities (start_hp 25))
	   (draw_range 80 80)
	   (flags (can_block nil)
		  (unactive_shield nil)
		  (hurtable nil))
	   (states "addon/leon/lmisc.spe"
		   (stopped "Metal.pcx")))

(def_char HIDDEN_BACK_METALBIG
	   (funs (ai_fun big_wall_ai)
		 (reload_fun  hwall_reload)
		 (damage_fun hwall_damage))
	   (abilities (start_hp 25))
	   (draw_range 80 80)
	   (flags (can_block nil)
		  (unactive_shield nil)
		  (hurtable nil))
	   (states "addon/leon/lmisc.spe"
		   (stopped "Metalbig.pcx")))


(defun Med_ai ()
  (if (eq0 (aistate)) 	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))
		(set_aistate 1))))
	(if (and (touching_bg) (with_object (bg) (give_player_health 20)))
	   (progn
	     (play_sound HEALTH_UP_SND 127 (x) (y))
	     nil)
	  T))

(def_char MEDKIT
  (funs (ai_fun Med_ai))
  (flags (add_front T))
  (range 0 0)
  (states "addon/leon/lmisc.spe" (stopped "medkit.pcx" )))

(defun none_ai ()
  (next_picture)
  (if (touching_bg)
      (progn (with_object (bg)
			  (progn
			    (setq special_power NO_POWER)
			    (make_view_solid (find_rgb 0 0 0))))
	     nil) T))



(def_char POWER_NONE
  (funs (ai_fun none_ai)(draw_fun   dev_draw))
  (flags (add_front T))
  (range 20 20)
  (states "art/misc.spe" (stopped "fast" )))

(defun sensbeam_ai ()

  (shift_rand_table (random 80))
  (if (activated)
      (let ((nowx (x))
	    (nowy (y)))

	(if (eq (mod (game_tick) 4) 0)
	    (play_sound FF_SND 127 (x) (y)))
	(try_move 0 (+ (y) 200))    ;; find the floor
	(setq end_y (y))            ;; save the position
	(set_x nowx)
	(set_y nowy)))
  T)


(defun sensbeam_draw ()
  (if (edit_mode) (draw))
  (if (activated)
  (ascatter_line (x) (y) (x) end_y (find_rgb 255 0 0) (find_rgb 128 0 0)    1)))



(def_char SENSORBEAM
  (funs (ai_fun sensbeam_ai)
	(draw_fun sensbeam_draw))
  (range 10 500)
  (vars end_y)
  (states "art/misc.spe"
	  (stopped "force_field")))


(defun swtele_ai ()     ;; teleporting door ai
  (if (activated)
  (let ((player (bg)))
;;    (if (has_object player)
      (if (> (total_objects) 1)
	  (let ((otherx (+ (with_object (get_object 1) (x)) (- (with_object player (x) ) (x) ) ) )
		(othery (+ (with_object (get_object 1) (y)) (- (with_object player (y) ) (y) ) ) ))
	    (with_object player (progn
				  (set_x otherx)
				  (set_y othery)
                                  (bottom_draw)
;;				  (with_object (get_object 0)
;;                                    (progn
;;                                      (set_x otherx)
;;				      (set_y othery)
;;                                      (top_ai)
;;				      (top_draw)
;;                                    )
;;                                  )
;;				  (with_object (get_object 0) (top_draw) )
))))))
T)

(def_char SWITCH_TELEPORTER
  (funs (ai_fun swtele_ai)
	(draw_fun dev_draw))
  (range 10 500)
  (vars end_y)
  (states "art/misc.spe"
	  (stopped "switch_mover")))

(setq AMB_SOUNDS2 (make-array 3 :initial-contents (list
			       (def_sound "addon/leon/sfx/ambship1.wav")   ;; 0
			       (def_sound "addon/leon/sfx/ambship2.wav")   ;; 1
                               (def_sound "addon/leon/sfx/thunder.wav")   ;; 4
			       )))

(defun amb_sound_ct2 ()
  (if (> (aitype) 4)
      (set_aitype 0)
    (play_sound (aref AMB_SOUNDS2 (aitype)))))

(defun amb_sound_ai2 ()
  (if (activated)
      (if (eq (aistate) 0)
	  (progn
	    (play_sound (aref AMB_SOUNDS2 (aitype)) (yvel) (x) (y))
	    (set_aistate (+ (xvel) (random (+ 1 (xacel)))))
	    (> (xvel) 0))
	(progn
	  (set_aistate (- (aistate) 1))
	  T))
    (progn
      (set_aistate 0)
      T)))


(defun ambs_cons2 ()
  (set_xvel 10)  ;; delay time to 10
  (set_yvel 127)) ;; set volume default to 127

(def_char AMBIENT_SOUND2
  (funs (ai_fun          amb_sound_ai2)
	(draw_fun        dev_draw)
	(constructor     ambs_cons2)
	(type_change_fun amb_sound_ct2))
  (range 500 500)
  (fields ("aitype" amb_num)
	  ("yvel"   amb_vol)
	  ("xvel"   amb_rep)
	  ("xacel"  amb_rand))
  (states "art/misc.spe"
	  (stopped "sfx_player")))
