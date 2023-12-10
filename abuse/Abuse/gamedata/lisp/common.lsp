;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

; draw function for characters only displayed during edit mode
; such as start, etc.
; (defun dev_draw () (if (edit_mode) (draw) nil))       -- compiled C function --

;; XXX: Mac Abuse reimplements this in C++
(defun middle_draw ()
  (let ((y (y)))
    (set_y (+ (y) (/ (picture_height) 2)))
    (draw)
    (set_y y)))

(defun push_char (xamount yamount)
  (let ((bgx (with_object (bg) (x)) (x))
	(bgy (with_object (bg) (y)) (y)))
    (if (and (<= bgy (y)) (< (disty) yamount) (< (distx) xamount))
	(let ((amount (if (> bgx (x))
			  (- xamount (- bgx (x)))
			(- (- (x) bgx) xamount))))
	  (with_object (bg) (try_move amount 0))))))



(defun do_nothing () (next_picture) T)

(defun lhold_ai ()
  (if (> (total_objects) 0)
      (progn
	(set_x (with_object (get_object 0) (x)))
	(set_y (with_object (get_object 0) (- (y) (/ (picture_height) 2) )))))
  (if (eq (total_lights) 1)
      (progn
	(set_light_x (get_light 0) (x))
	(set_light_y (get_light 0) (y)))
    nil)
  T)



(def_char LIGHTHOLD
  (funs  (ai_fun   lhold_ai)
	 (draw_fun dev_draw))
  (states "art/misc.spe"
	  (stopped           "lhold")))



(def_char OBJ_MOVER
  (funs (ai_fun       mover_ai)
	(constructor  mover_cons)
	(draw_fun     dev_draw))
  (range 300 40)
  (fields ("aitype" obj_frames)
	   ("aistate" obj_frame))
  (states "art/misc.spe" (stopped '("mover" "mover" ))))

/*    Compiled C
(defun mover_ai ()
  (if (eq (total_objects) 2)
      (let ((dest (get_object 0))
	    (mover (get_object 1)))
	(if (< (aistate) 2)		; transfer object to next mover
	    (progn
	      (with_object dest
			   (progn
			     (link_object mover)
			     (set_aistate (aitype))))
	      (remove_object mover))
	  (progn
	    (set_aistate (- (aistate) 1))
	    (let ((newx (- (with_object dest (x)) (/ (* (- (with_object dest (x)) (x)) (aistate)) (aitype))))
		  (newy (- (with_object dest (y)) (/ (* (- (with_object dest (y)) (y)) (aistate)) (aitype)))))
	      (with_object mover
			   (progn
			     (platform_push (- newx (x)) (- newy (y)))
			     (set_x newx)
			     (set_y newy)))))))
    nil)
  T)
*/

(defun mover_cons () (set_aitype 20))


/*  // compiled C
(defun respawn_ai ()
  (let ((x (total_objects)))
    (if (eq x 0)                           ; if not linked to anything return
	T
      (let ((last (get_object (- x 1))))   ; see if the last object has the same position as us
	(if (and (eq (with_object last (x)) (x)) (eq (with_object last (y)) (y)))
	    (if (eq (aistate) 1)
		(if (eq (with_object last (fade_count)) 0)
		    (set_aistate 1)
		  (with_object last (set_fade_count (- (with_object last (fade_count)) 1))))
	      T)                          ; if so then return
	  (if (eq (aistate) 1)
	      (set_aistate 0)
	    (if (> (state_time) (xvel))
		(let ((new (add_object (with_object (get_object (random x)) (otype)) (x) (y))))
		  (with_object new (set_fade_count 15))   ; make faded out so we can fade it in
		  (link_object new)
		  (set_aistate 1))
	      T))))))
  T)
*/


(defun respwan_cons () (set_xvel 50))


(def_char RESPAWN
  (funs (ai_fun      respawn_ai)
	(draw_fun    dev_draw)
	(constructor respwan_cons))
;  (flags (unlistable T))
  (fields ("xvel" respawn_reg))
  (range 100 100)
  (states "art/misc.spe"
	  (stopped           "respawn")))



(def_char MARKER
  (funs (ai_fun   do_nothing)
	(draw_fun dev_draw))
  (states "art/misc.spe" (stopped "marker")))

