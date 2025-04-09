(load "config/levelset.lsp")  ; created by server setup

(setq current_net_level 0)

(if (not (get_option "-f"))  ;; are they trying to override the first level?
    (set_first_level (nth current_net_level net_levels)))

(if (am_a_client)
    (progn
      (load "config/cur_lev.lsp")
      (set_first_level (nth current_net_level net_levels)))

  ;; save the level we are so joining clients know which one to load
  (open_file "config/cur_lev.lsp" "wb"
	     (print `(setq current_net_level ,current_net_level))))


;; this is a simple check to see if they player has an engine version
;; capable of playing the game.  All games should at least check for version 1.10
;; because all version before that are beta and have known bugs.

(if (< (+ (* (major_version) 100) (minor_version)) 120)    ; require at least version 1.20
    (progn
      (print "Your engine is out of date.  This game requires version 1.2")
      (quit)))

(setq section 'game_section)
(load "lisp/english.lsp")             ;; load language specific stuff

(setq load_warn nil)
(if (not (load "lisp/common.lsp"))
    (progn
      (print "\nPlease make sure you unzipped the game with the -d option")
      (print "so that all directories get created properly.")
      (print "example : pkunzip -d abusXXXX.zip")
      (quit)))
(setq load_warn T)

(setq load_warn nil)

(if (am_a_client)
    (if (not (load "addon/deathmat/version.lsp"))
	(progn
	  (print "\nThis server is playing an older version, please upgrade it")
	  (quit))
      (if (or (not (eq server_version_major (major_version)))
	      (not (eq server_version_minor (minor_version))))
	  (progn
	    (print "\nThis server is playing a different version, cannot continue")
	    (quit))))
  (open_file "addon/deathmat/version.lsp" "wb"
	     (print (list 'setq 'server_version_major (major_version) ))
	     (print (list 'setq 'server_version_minor (minor_version)))))


(if (not (am_a_client))
    (setq username "Myself"))

;(let ((input (nice_input "DEATHMATCH : Enter your name below" "Name" username)))
;  (open_file "config/username.lsp" "wb"
;	     (print (list 'setq 'username
;			  (concatenate 'string '(#\") input '(#\"))))))

(local_load "config/username.lsp")
(set_login username)


(setq load_warn T)

(if (not (am_a_client))   ;;  are we connecting to a server?
    (start_server))




(load "lisp/userfuns.lsp")

;; this function is called at the end of every screen update
;; for death match we use this to display a list of players in the
;; game and the kills for each player

(defun display_player (player text_x text_y)
  (if player
      (with_object player
	(put_string (get_main_font) text_x text_y
		    (concatenate 'string (digstr (kills) 2) " " (player_name)
						     (if (local_player)
							 " <<"
						       ""))
		    (aref player_text_color (player_number)))
	(display_player (next_focus player) text_x (+ text_y (font_height (get_main_font)))))))


(defun post_render ()
  (if (not (edit_mode))      ; don't try this in edit mode
      (score_draw)))

;      (display_player (first_focus)  (with_object (first_focus) (+ (view_x1) 4)) (with_object (first_focus) (view_y1))  )))

(load "lisp/chat.lsp")

(setq keep_backup T)                  ;; determines if Save
(setq load_warn nil)

(local_load "gamma.lsp")              ;; load gamma correction values if they have been saved

(if (not (load "hardness.lsp"))       ;; load hardness, if no file set to hard
    (setf difficulty        'hard))
(setq load_warn T)

; *********** Defaults **************************
(setf sfx_directory     "sfx/")

(load_big_font     "art/fonts.spe" "screen11")
(load_small_font   "art/fonts.spe" "small_font")
(load_console_font "art/fonts.spe" "fnt5x7")

(load_color_filter "art/back/backgrnd.spe")
(load_palette      "art/back/backgrnd.spe")
(setq normal_tint (def_tint "art/back/backgrnd.spe"))

(load_tiles "art/fore/foregrnd.spe"
	    "art/fore/techno.spe"
	    "art/fore/techno2.spe"
	    "art/fore/techno3.spe"
	    "art/fore/techno4.spe"
	    "art/fore/cave.spe"
	    "art/fore/alien.spe"
	    "art/fore/trees.spe"
	    "art/fore/endgame.spe"
	    "art/fore/trees2.spe"

	    "art/back/intro.spe"
	    "art/back/city.spe"
	    "art/back/tech.spe"
	    "art/back/cave.spe"
	    "art/back/backgrnd.spe"
	    "art/back/alienb.spe"
	    "art/back/green2.spe"
	    "art/back/galien.spe")

(defun end_game_ai ()
  (if (activated)
      (if (eq (aistate) 8)
          (if (not (next_picture))
              (request_end_game))
        (set_aistate (+ (aistate) 1))))
  T)

(def_char END_GAME
  (funs (ai_fun end_game_ai))
  (range 0 0)
  (states "art/fore/endgame.spe"
          (stopped (app (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)
                        (seq "pipe" 1 9)))))


(setf title_screen      '("art/title.spe" . "title_screen"))
(setf logo              '("art/title.spe" . "cdc_logo"))
;(setq help_screens '("art/help.spe" "sell1" "sell2" "sell4"))

