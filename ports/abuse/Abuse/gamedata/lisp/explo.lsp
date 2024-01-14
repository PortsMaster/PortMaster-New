;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun explo_light ()
  (select (aistate)
	  (0 (progn (link_light (add_light 0 (x) (y) 1 (aitype) 0 0))
		    (go_state 1)))
	  (1 (if (> (state_time) 3)
		 (let ((l (get_light 0)))
		   (delete_light l)
		   nil)

	       T))))

(defun do_small_explo (radius amount)
  (add_object EXPLODE3 (+ (x) (random 5)) (+ (y) (random 5)) 0)
  (add_object EXPLODE2 (+ (x) (random 5)) (+ (y) (random 5)) 2)
  (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 1)
  (add_object EXPLODE3 (- (x) (random 5)) (- (y) (random 5)) 2)
  (hurt_radius (x) (y) radius amount (if (> (total_objects) 0)
					 (get_object 0)
				       nil) 20)
  nil)

(defun do_explo (radius amount)
      (play_sound GRENADE_SND 127 (x) (y))
      (add_object EXPLODE1 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
      (if (not (frame_panic))
	  (progn
	    (add_object EXPLODE1 (- (x) (random 10)) (+ (- (y) (random 10)) -20) 2)
	    (add_object EXP_LIGHT (x) (y) 100)))         ; add cool light if not too slow
      (hurt_radius (x) (y) radius amount (if (> (total_objects) 0)
					     (get_object 0)
					   nil) 20)
      nil)



(defun do_white_explo (radius amount)
      (play_sound GRENADE_SND 127 (x) (y))
      (add_object EXPLODE8 (+ (x) (random 10)) (+ (+ (random 10) (y)) -20)     0)
      (if (not (frame_panic))
	  (add_object EXP_LIGHT (x) (y) 100))        ; add cool light if not too slow
      (hurt_radius (x) (y) radius amount (if (> (total_objects) 0)
					     (get_object 0)
					   nil) 20)
      nil)



(def_char EXP_LIGHT
  (funs (ai_fun   explo_light)
	(draw_fun dev_draw))
  (flags (unlistable T))
  (range 10000 10000)
  (states "art/misc.spe"
	  (stopped           "lhold")))

;; XXX: Mac Abuse reimplements this in C++
(defun exp_ai ()
  (if (eq (aitype) 0) (next_picture)
    (progn (set_aitype (- (aitype) 1))
	   T)))

;; XXX: Mac Abuse reimplements this in C++
(defun exp_draw ()
  (if (eq (aitype) 0)
      (middle_draw)))

(defun def_explo (symbol file seq_name last_frame)
  (eval (list 'def_char symbol
	      '(funs (ai_fun   exp_ai)
		     (draw_fun exp_draw))
	      '(range 10000 10000)
	      '(flags (add_front T)
		      (unlistable T))
	      `(states file (stopped (quote ,(seq seq_name 1 last_frame)))))))


(def_explo 'EXPLODE1 "art/exp1.spe"    "fire"         7)

(def_explo 'EXPLODE2 "art/blowups.spe" "b1"           7)
(def_explo 'EXPLODE3 "art/blowups.spe" "b2"           7)
(def_explo 'EXPLODE4 "art/blowups.spe" "b3"           7)
(def_explo 'EXPLODE5 "art/blowups.spe" "b4"           5)
(def_explo 'EXPLODE6 "art/exp1.spe"    "small_fire"   7)
(def_explo 'EXPLODE7 "art/exp1.spe"    "small_wite"   8)
(def_explo 'EXPLODE8 "art/exp1.spe"    "wite"         8)

(def_explo 'CLOUD "art/cloud.spe" "cloud"             5)
(def_explo 'SMALL_DARK_CLOUD "art/cloud.spe" "smo2"   5)
(def_explo 'SMALL_LIGHT_CLOUD "art/cloud.spe" "smo1"  5)









