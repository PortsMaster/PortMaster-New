;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;; Bobby,  samples should be 8 bit mono playing 11025 Hz

(defun sfxdir (filename) (concatenate 'string "sfx/" filename))

;; steel ball bounce
(def_sound 'SBALL_SND      (sfxdir "ball01.wav"))

;; flying sound
(def_sound 'FLY_SND        (sfxdir "fly03.wav"))

;; speed sound
(def_sound 'SPEED_SND      (sfxdir "speed02.wav"))

(setq LOW_HEALTH_SND SPEED_SND)

;; laser hitting somehting it can't kill
(def_sound 'LPING_SND      (sfxdir "lasrmis2.wav"))

;; light saber - should be short
(def_sound 'LSABER_SND     (sfxdir "plasma02.wav"))

;; when you save at a console
(def_sound 'SAVE_SND       (sfxdir "save05.wav"))

;; end level
(def_sound 'END_LEV_SND    (sfxdir "endlvl02.wav"))

;; plasma weapon
(def_sound 'PLASMA_SND     (sfxdir "plasma03.wav"))

;; spring
(def_sound 'SPRING_SOUND   (sfxdir "spring03.wav"))

;; health up sound
(def_sound 'HEALTH_UP_SND  (sfxdir "health01.wav"))

;; door sliding up
(def_sound 'DOOR_UP        (sfxdir "doorup01.wav"))

;; door sliding up
(def_sound 'DOOR_DOWN      (sfxdir "doorup02.wav"))

;; bomb count-down tick
(def_sound 'TICK_SND       (sfxdir "timerfst.wav"))

(setq PLAYER_PAIN (make-array 4 :initial-contents
			      (list (def_sound (sfxdir "plpain01.wav"))
				    (def_sound (sfxdir "plpain02.wav"))
				    (def_sound (sfxdir "plpain04.wav"))
				    (def_sound (sfxdir "plpain10.wav")))))

(setq PLAYER_DEATH (make-array 4 :initial-contents
			     (list (def_sound (sfxdir "pldeth02.wav"))
				   (def_sound (sfxdir "pldeth04.wav"))
				   (def_sound (sfxdir "pldeth05.wav"))
				   (def_sound (sfxdir "pldeth07.wav")))))


;; jugger stomp
(def_sound 'JSTOMP_SND    (sfxdir "blkfoot4.wav"))

;; hiding wall disappear sound
(def_sound 'HWALL_SND     (sfxdir "blkfoot4.wav"))

;; firebomb sound
(def_sound 'FIREBOMB_SND  (sfxdir "firebmb1.wav"))


;; force field
(def_sound 'FF_SND        (sfxdir "force01.wav"))

;; flying robot sound
(def_sound 'FLYER_SND     (sfxdir "robot02.wav"))

;; cleaner sound
(def_sound 'CLEANER_SND   (sfxdir "cleaner.wav"))

;; shotgun/laser taking from the lava sample
(def_sound 'ZAP_SND       (sfxdir "zap2.wav"))

;; rocket launch sound
(def_sound 'ROCKET_LAUNCH_SND (sfxdir "rocket02.wav"))

;; platform de-acel
(def_sound 'PLAT_D_SND     (sfxdir "eledec01.wav"))

;; platform acel
(def_sound 'PLAT_A_SND     (sfxdir "eleacc01.wav"))


;; machine gun hitting the floor, sounds 1 & 2, played randomly
(def_sound    'MG_HIT_SND1 (sfxdir "mghit01.wav"))
(def_sound    'MG_HIT_SND2 (sfxdir "mghit02.wav"))

;; enemy mounted gun firing
(def_sound 'MGUN_SND       (sfxdir "ammo02.wav"))

;; planet explode sound
(def_sound 'P_EXPLODE_SND  (sfxdir "poof06.wav"))

;; space ship zipping by
(def_sound 'SHIP_ZIP_SND   (sfxdir "zap3.wav"))

;; grenade explosion
(def_sound 'GRENADE_SND    (sfxdir "grenad01.wav"))

;; opening door
(def_sound 'SWISH          (sfxdir "swish01.wav"))

;; sound of player going through a teleporter, not grinding
(def_sound 'TELEPORTER_SND (sfxdir "telept01.wav"))

;; blowing something up
(def_sound 'BLOWN_UP       (sfxdir "grenad01.wav"))

;; get a "treasure"/ammo noise
(def_sound 'AMMO_SND       (sfxdir "ammo01.wav"))

;; lava shooting up sound
(def_sound 'LAVA_SND       (sfxdir "lava01.wav"))

;; sound of a switch being flipped
(def_sound 'SWITCH_SND     (sfxdir "switch01.wav"))

;; sound of grenade being thrown
(def_sound 'GRENADE_THROW  (sfxdir "throw01.wav"))

;; electricity shooting up from the ground
(def_sound 'ELECTRIC_SND   (sfxdir "elect02.wav"))

;; rocket being fired
(def_sound 'ROCKET_SND     (sfxdir "rocket02.wav"))

;; alien landing on the ground
(def_sound 'ALAND_SND      (sfxdir "aland01.wav"))

;; alien slash/bite noise
(def_sound 'ASLASH_SND     (sfxdir "aslash01.wav"))

;; light fading on
(def_sound 'FADEON_SND     (sfxdir "fadeon01.wav"))

;; block crumbling
(def_sound 'CRUMBLE_SND    (sfxdir "crmble01.wav"))

;; aliean screaming
(def_sound 'ASCREAM_SND    (sfxdir "alien01.wav"))

;; alien pain sound
(def_sound 'APAIN_SND      (sfxdir "ahit01.wav"))

;; small alien death
(setq ASML_DEATH (make-array 2 :initial-contents
			     (list (def_sound (sfxdir "adie05.wav"))
				   (def_sound (sfxdir "poof05.wav")))))

;; large alien death
(setq ALRG_DEATH (make-array 3 :initial-contents
			     (list (def_sound (sfxdir "adie02.wav"))
				   (def_sound (sfxdir "adie03.wav"))
				   (def_sound (sfxdir "poof05.wav")))))



(setq APPEAR_SND (def_sound (sfxdir "amb16.wav")))    ;; 14
(setq TAUNT_SND (def_sound (sfxdir "amb07.wav")))     ;; 15
(setq SPACE_SND (def_sound (sfxdir "ambcave1.wav")))  ;; 3
(setq SCARE_SND (def_sound (sfxdir "amb10.wav")))     ;; 16

(setq A_SCREAMS (make-array 3 :initial-contents (list
						 (def_sound (sfxdir "scream02.wav"))  ;; 8
						 (def_sound (sfxdir "scream03.wav"))  ;; 9
						 (def_sound (sfxdir "scream08.wav")))))  ;; 10


;; out side of game sounds

(setq BUTTON_PRESS_SND (def_sound (sfxdir "button02.wav")))
(setq LOGO_SND (def_sound (sfxdir "logo09.wav")))
(setq DEL_OBJECT_SND (def_sound (sfxdir "delobj01.wav")))
(setq LINK_OBJECT_SND (def_sound (sfxdir "link01.wav")))


(setq AMB_SOUNDS (make-array 17 :initial-contents (list
			       (def_sound (sfxdir "ambtech1.wav"))   ;; 0
			       (def_sound (sfxdir "ambtech2.wav"))  ;; 1
			       (def_sound (sfxdir "ambtech3.wav"))  ;; 2
			       SPACE_SND                            ;; 3
			       (def_sound (sfxdir "ambcave2.wav"))  ;; 4
			       (def_sound (sfxdir "ambcave3.wav"))  ;; 5
			       (def_sound (sfxdir "ambcave4.wav"))  ;; 6
			       (def_sound (sfxdir "ambfrst2.wav"))  ;; 7
			       (aref A_SCREAMS 0)                   ;; 8
			       (aref A_SCREAMS 1)                   ;; 9
			       (aref A_SCREAMS 2)                   ;; 10
			       (def_sound (sfxdir "adie03.wav"))    ;; 11
			       (def_sound (sfxdir "amb11.wav"))     ;; 12
			       (def_sound (sfxdir "amb13.wav"))     ;; 13
			       APPEAR_SND                           ;; 14
			       TAUNT_SND                            ;; 15
			       SCARE_SND                            ;; 16
			       )))

;; XXX: Mac Abuse uses voice hint SFXs
;(setq voice_hints
;  (make-array 12 :initial-contents
;    (list
;      (def_sound "sfx/voice/aimsave.wav")
;      (def_sound "sfx/voice/ammosave.wav")
;      (def_sound "sfx/voice/switch_1.wav")
;      (def_sound "sfx/voice/savesave.wav")
;      (def_sound "sfx/voice/platfo_1.wav")
;      (def_sound "sfx/voice/poweru_1.wav")
;      (def_sound "sfx/voice/weapon_1.wav")
;      (def_sound "sfx/voice/ladder_1.wav")
;      (def_sound "sfx/voice/starts_1.wav")
;      (def_sound "sfx/voice/wallss_1.wav")
;      (def_sound "sfx/voice/switch_2.wav")
;      (def_sound "sfx/voice/telepo_1.wav"))))


(defun amb_sound_ct ()
  (if (> (aitype) 16)
      (set_aitype 0)
    (play_sound (aref AMB_SOUNDS (aitype)))))

(defun amb_sound_ai ()
  (if (activated)
      (if (eq (aistate) 0)
	  (progn
	    (play_sound (aref AMB_SOUNDS (aitype)) (yvel) (x) (y))
	    (set_aistate (+ (xvel) (random (+ 1 (xacel)))))
	    (> (xvel) 0))
	(progn
	  (set_aistate (- (aistate) 1))
	  T))
    (progn
      (set_aistate 0)
      T)))


(defun ambs_cons ()
  (set_xvel 100)  ;; delay time to 100
  (set_yvel 127)) ;; set volume default to 127

(def_char AMBIENT_SOUND
  (funs (ai_fun          amb_sound_ai)
	(draw_fun        dev_draw)
	(constructor     ambs_cons)
	(type_change_fun amb_sound_ct))
  (range 500 500)
  (fields ("aitype" amb_num)
	  ("yvel"   amb_vol)
	  ("xvel"   amb_rep)
	  ("xacel"  amb_rand))
  (states "art/misc.spe"
	  (stopped "sfx_player")))

(setq song_list '("music/abuse01.hmi" "music/abuse02.hmi"))
(setq current_song song_list)

(defun next_song ()
  (if current_song
      (progn
	(play_song (car current_song))
	(break)
	(setq current_song (cdr current_song))
	(if (not current_song)
	    (setq current_song song_list))
	(break)
	)))


(defun level_loaded (name)
  (trace)
  (if (search "levels/level" name)  ; is this one of the regular levels?
      (progn
	(stop_song)                 ; stop playing the old song
	(select (substr 12 13 name)
		("00" (play_song "music/abuse01.hmi"))
		("01" (play_song "music/abuse02.hmi"))
		("02" (play_song "music/abuse04.hmi"))
		("03" (play_song "music/abuse07.hmi"))
		("04" (play_song "music/abuse08.hmi"))
		("05" (play_song "music/abuse10.hmi"))
		("06" (play_song "music/indst1.hmi"))
		("07" (play_song "music/indst2.hmi"))
		("08" (play_song "music/indst3.hmi"))
		("09" (play_song "music/indst4.hmi"))
		("10" (play_song "music/indst5.hmi"))
		("11" (play_song "music/abuse07.hmi"))
		("12" (play_song "music/abuse08.hmi"))
		("13" (play_song "music/abuse10.hmi"))
		("14" (play_song "music/indst1.hmi"))
		("15" (play_song "music/indst2.hmi"))
		("16" (play_song "music/indst3.hmi"))
		("17" (play_song "music/indst4.hmi"))
		("18" (play_song "music/indst5.hmi")))))
  (untrace)
  (break))



