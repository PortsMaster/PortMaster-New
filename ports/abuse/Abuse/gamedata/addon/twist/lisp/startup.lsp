;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(setq keep_backup T)                  ;; determines if Save

(setq load_warn nil)

(if (local_load "addon/deathmat/username.lsp")
  (set_login username))

(if (local_load "addon/deathmat/gamename.lsp")
  (set_game_name gamename)
  (set_game_name "Munir's Game"))

(load "demo.lsp")

(local_load "gamma.lsp")              ;; load gamma correction values if they have been saved

(if (not (load "hardness.lsp"))       ;; load hardness, if no file set to hard
    (setf difficulty        'normal))
(setq load_warn T)

; *********** Defaults **************************

(setf sfx_directory     "sfx/")

;(load_big_font     "art/letters.spe" "letters")
(load_big_font     "art/fonts.spe" "screen11")
(load_small_font   "art/fonts.spe" "small_font")
(load_console_font "art/fonts.spe" "fnt5x7")
(load_color_filter "art/back/backgrnd.spe")
(load_palette      "addon/twist/art/palette.spe")
(setq normal_tint (def_tint "art/back/backgrnd.spe"))


(load_tiles "art/fore/foregrnd.spe"  ;; 0
	    "art/fore/techno.spe"    ;; 1-99
	    "art/fore/techno2.spe"   ;; 100-167
	    "art/fore/techno3.spe"   ;; 200-236
	    "art/fore/techno4.spe"   ;; 300-460
	    "art/fore/cave.spe"      ;; 500-634
	    "art/fore/alien.spe"    ;; 700-774
	    "art/fore/trees.spe"    ;; 800-931
	    "art/fore/endgame.spe"  ;; 950-1014
	    "art/fore/trees2.spe"   ;; 1100-1134

	    "art/back/backgrnd.spe"  ;; 0
	    "art/back/intro.spe"     ;; 5-37
	    "art/back/city.spe"      ;; 40-70
	    "art/back/cave.spe"      ;; 84-103
	    "art/back/tech.spe"      ;; 110-139
	    "art/back/alienb.spe"   ;; 150-179
	    "art/back/green2.spe"   ;; 200-268
	    "art/back/galien.spe"   ;; 300-320
	    )

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


(setf demos        '("levels/demo1.dat" "levels/demo3.dat" "levels/demo4.dat" "levels/demo5.dat"))

(if (not (get_option "-f"))
    (progn
      (if skip_trainer_level
	  (set_first_level "addon/twist/levels/l01s01.lvl")
	(set_first_level "addon/twist/levels/l01s01.lvl"))))

