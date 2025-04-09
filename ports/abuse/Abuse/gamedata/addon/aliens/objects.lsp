;; In places Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights
;;
;; Mostly Copyright 1997 Mike Moss (tfirestorm@aol.com),  All Rights reserved
;; See readme for more details on usage rights

;; Code

(setq ani_reg 0)

(defun anim_ai ()
    (if (eq ani_reg 24)
	(set_current_frame 0))
    (if (eq (mod ani_reg 2) 0)
	(next_picture))
T)

(defun water_cons ()
   (set_fade_count 6))

(defun lower_draw ()
   (lower)
   (draw))

(defun lower_drop_draw ()
   (lower)
   (try_move 0 20)
   (draw))

(defun hang_ai () T)

;; Animated Scenery

(def_char WATER
  (vars ani_tick)
  (flags (add_front T))
  (funs (ai_fun anim_ai)
	(constructor water_cons))
  (flags (add_front T))
  (states "addon/aliens/aliens.spe"
	(stopped (seq "wtr" 1 4))))

(def_char WGRILL
  (vars ani_tick)
  (funs (ai_fun anim_ai)
	(draw_fun   lower_draw))
  (states "addon/aliens/aliens.spe"
	(stopped (seq "wgrl" 1 3))))

(def_char WFALL
  (vars ani_tick)
  (funs (ai_fun anim_ai)
	(draw_fun   lower_draw))
  (states "addon/aliens/aliens.spe"
	(stopped (seq "wfal" 1 4))))

(def_char WFALL2
  (vars ani_tick)
  (funs (ai_fun anim_ai)
	(draw_fun   lower_draw))
  (states "addon/aliens/aliens.spe"
	(stopped (seq "wfl2" 1 4))))

;; Still Scenery

(def_char RUNG_B
  (funs (draw_fun   lower_drop_draw))
	(states "addon/aliens/aliens.spe"
	 (stopped "rungs.pcx")))

(def_char RUNG_F
  (funs (ai_fun   hang_ai))
  (flags (add_front T))
	(states "addon/aliens/aliens.spe"
	 (stopped "rungs.pcx")))
