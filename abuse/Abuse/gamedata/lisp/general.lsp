;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun pusher_cons () (set_aistate 4))
(defun pusher_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (progn
	(next_picture)
	(if (touching_bg)
	    (let ((xamount
		   (if (> (direction) 0)
		       (aistate)
		     (- 0 (aistate)))))
	      (with_object (bg) (try_move xamount 0)))))) T)


(def_char PUSHER
  (range 5 5)
  (funs (ai_fun      pusher_ai)
;	(draw_fun    dev_draw)
	(constructor pusher_cons))
  (fields ("aistate" pusher_speed))
  (states "art/chars/push.spe"
	  (stopped (seq "push" 1 5))))

(defun spring_cons () (set_yvel -15))
(defun spring_ai ()
  (if (or (eq (total_objects) 0) (not (eq (with_object (get_object 0) (aistate)) 0)))
      (select (aistate)
	      (0
	       (if (touching_bg)
		   (let ((add_yvel (yvel)))
		     (play_sound SPRING_SOUND 127 (x) (y))
		     (with_object (bg)
			      (progn
				(set_yvel (+ (yvel) add_yvel))
				(if (eq (gravity) 0)
				    (progn
				      (set_state run_jump)
				      (set_gravity 1)))))
		 (set_state running)
		 (set_aistate 1))))
	  (1 (if (next_picture) nil
	       (progn
		 (set_aistate 0)
		 (set_state stopped))))))
  T)



(def_char SPRING
  (range 5 5)
  (funs (ai_fun      spring_ai)
	(constructor spring_cons))
  (fields ("yvel" spring_yvel))
  (states "art/misc.spe"
	  (stopped "spri0004.pcx")
	  (running (rep "spri0001.pcx" 4))))

(defun pr_draw ()
  (draw_predator)

  )


(defun train_ai ()
  (if (eq (aistate) 0)
      (if (activated)
	  (let ((my_type (aitype)))
	    (with_object (bg)
                         (if (local_player)
                             (progn
                               ;; XXX: Mac Abuse plays voice hint SFXs
                               ;(play_sound (aref voice_hints my_type))
                               ;(expire_cache_item (aref voice_hints my_type))
                               (show_help (get_train_msg my_type)))))
	    (set_aistate 1)
	    T)
	T)
    (if (eq (aistate) 100)
	nil
      (progn
	(if (with_object (bg) (local_player))
	    (show_help (get_train_msg (aitype))))
	(set_aistate (+ (aistate) 1))
	T))))


(def_char TRAIN_MSG
  (funs (ai_fun train_ai)
	(draw_fun dev_draw))
  (fields ("aitype" train_msg_num))
  (states "art/misc.spe"
	  (stopped "bubble")))

(defun sball_damage (amount from hitx hity push_xvel push_yvel)  ; transfer damage to lower half
  (if (eq (state) stopped)
      (progn
	(set_aistate 1)
	(set_state running))))


(def_char SWITCH_BALL
  (funs (damage_fun sball_damage)
	(ai_fun do_nothing))
  (flags (hurtable T))
  (states "art/misc.spe"
	  (stopped (seq "swit" 1 9))
	  (running (seq "swit" 10 18))))

(def_char POINTER
  (funs (ai_fun do_nothing))
  (states "art/misc.spe"
	  (stopped "pointer")))

(defun shifter_cons ()
  (set_xvel 300)
  (set_yvel 300)
  (set_xacel 0)
  (set_yacel -1))

(defun holder_ai ()
  (select (total_objects)
	  (2
	   (let ((newx (+ (with_object (get_object 1) (x)) (xvel)))
		 (newy (+ (with_object (get_object 1) (y)) (yvel))))
	     (with_obj0 (set_x newx) (set_y newy))
	     (set_x newx)
	     (set_y newy)
	     T))
	  (3
	   (if (with_object (get_object 2) (not (eq (aistate) 0)))
	       (let ((newx (+ (with_object (get_object 1) (x)) (xvel)))
		     (newy (+ (with_object (get_object 1) (y)) (yvel))))
		 (with_obj0 (set_x newx) (set_y newy))
		 (set_x newx)
		 (set_y newy)
		 T)
	     (if (eq (xacel) 1)
		 nil
	       T)))
	  (4 T)
	  (5 T)
	  (6 T)
	  (0 nil)
	  (1 nil)))


(def_char OBJ_HOLDER
  (funs (ai_fun holder_ai)
	(draw_fun dev_draw))
  (fields ("xvel"  obj_holder_xoff)
	  ("yvel"  obj_holder_xoff)
	  ("xacel" obj_holder_del))
  (states "art/misc.spe"
	  (stopped "o_hold")))
