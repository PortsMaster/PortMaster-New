(defun rand_draw()
  (let ( (x (x) ) (y (y) ) )
    (set_x (- (+ x (random 16) ) 8) )
    (set_y (- (+ y 3 ) (random 3) ) )
    (draw)
    (set_x x)
    (set_y y)
  )
)

(defun rain_cons ()
  (set_fade_count 5)
)

(def_char RAIN
  (funs (ai_fun do_nothing)
        (constructor rain_cons)
        (draw_fun   rand_draw))
;;        (reload_fun lower_reload))
  (flags (add_front T) )
  (states "addon/leon/rain.spe"  (stopped (seq "rain" 1 4))))

(def_char STILLRAIN
  (funs (ai_fun do_nothing)
        (reload_fun lower_reload))
  (states "addon/leon/rain.spe"  (stopped (seq "rain" 1 4))))

(defun lightning_ai()
  (if (not (activated))
    (set_aistate 4)
  )

  (select (aistate)
    (0
      (set_yvel (+ 100 (random 500) ) )
      (set_yacel (random 3) )
      (set_aistate 6)
    )
    (4 (if (activated)
         (go_state 0)
       )
    )
    (6 (if (eq (state_time) (yvel) )
         (progn
           (add_object THUNDER (with_object (bg) (x)) (with_object (bg) (y)))
           (set_aistate 2)
         )
      )
    )
    (1 (if (eq (state_time) (yvel) )
         (set_aistate 2)
      )
    )
    (2 (set_yvel (+ 0 (random 2) ) )
       (set_xvel (get_light_value) )
       (set_light_value (+ (xvel) (+ 35 (random 15) ) ) )
;;       (with_object (bg) (make_view_solid (find_rgb 192 192 255)) )
       (set_aistate 3)
    )
    (3 ;; (with_object (bg) (make_view_solid (find_rgb 192 192 255)) )
       (set_light_value (+ (xvel) (+ 15 (random 13) ) ) )
       (if (eq (state_time) (yvel) )
         (if (eq (yacel) 0)
           (set_aistate 5)
           (progn
             (set_yacel (- (yacel) 1 ) )
             (set_light_value (xvel) )
             (set_yvel (+ 1 (random 2) ) )
             (set_aistate 1)
           )
         )
       )
    )
    (5
       (set_light_value (xvel) )
       (set_aistate 0)
    )
  )
 T
)

(def_char LIGHTNING
  (funs (ai_fun          lightning_ai)
	(draw_fun        dev_draw))
  (range 4000 4000)
  (states "art/misc.spe"
	  (stopped "latter")))

(setq THUNDER_SOUNDS (make-array 5 :initial-contents (list
			       (def_sound "addon/leon/sfx/thunder.wav")   ;; 0
			       (def_sound "addon/leon/sfx/thunder2.wav")   ;; 1
			       (def_sound "addon/leon/sfx/thunder3.wav")   ;; 2
			       (def_sound "addon/leon/sfx/thunder4.wav")  ;; 3
                               (def_sound "addon/leon/sfx/thunder5.wav")   ;; 4
			       )))

(defun thunder_ai()
  (if (eq (state_time) 20)
    (play_sound (aref THUNDER_SOUNDS (random 5) ) 127 (x) (y))
    T
  )
)

(def_char THUNDER
  (funs (ai_fun          thunder_ai)
	(draw_fun        dev_draw))
  (range 200 200)
  (flags (unlistable T))
  (states "art/misc.spe"
	  (stopped "latter")))

(setq RAIN_SOUNDS (make-array 4 :initial-contents (list
			       (def_sound "addon/leon/sfx/rain.wav")   ;; 0
			       (def_sound "addon/leon/sfx/rain2.wav")   ;; 1
			       (def_sound "addon/leon/sfx/rain3.wav")   ;; 2
			       (def_sound "addon/leon/sfx/rain4.wav")  ;; 3
			       )))

(defun rain_sound_ai ()
  (if (eq (aistate) 0)
    (progn
      (play_sound (aref RAIN_SOUNDS (random 4) ) 127 (x) (y))
      (set_aistate 28)
    )
    (set_aistate (- (aistate) 1) )
  )
)

(def_char RAIN_SND
  (funs (ai_fun          rain_sound_ai)
	(draw_fun        dev_draw))
  (range 200 200)
  (states "art/misc.spe"
	  (stopped "sfx_player")))

(defun raincolumn_ai()
  (if (eq (yvel) 20)
    nil
    (progn
      (if (eq (xvel) 2)
        (set_xvel 0)
        (set_xvel 2)
      )
      (set_yvel (+ (yvel) 1) )
      (set_y (+ (y) 30) )
      (let ( (xv (xvel) ) )
        (with_object (add_object RAIN (x) (y))
          (set_current_frame xv)
        )
      )
      (raincolumn_ai)
    )
  )
)

(def_char RAIN_COLUMN
  (funs (ai_fun          raincolumn_ai)
	(draw_fun        dev_draw))
  (range 40 4000)
  (states "art/misc.spe"
	  (stopped "marker")))