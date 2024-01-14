(setq GREN_SND (make-array 2 :initial-contents
			     (list (def_sound "addon/leon/sfx/gren5.wav")
				   (def_sound "addon/leon/sfx/gren6.wav"))))

(defun grenade_ai ()
  (if (eq (hp) 6)
    (set_yvel (- (yvel) 7) )
  )
  (set_yacel 3)
  (if (eq (yvel) 0 )
    (set_yvel (+ (yvel) 1) )
    nil
  )
  (let ( (xv (xvel)) (yv (yvel)) (tk (tick)) )
    (if (and (eq tk 1) (< xv 0) )
      (progn
        (set_xvel (- 0 xv) )
        (play_sound (aref GREN_SND (random 2)) 127 (x) (y))
      )
      nil
    )
    (if (and (eq tk 2) (> xv 0) )
      (progn
        (set_xvel (- 0 xv) )
        (play_sound (aref GREN_SND (random 2)) 127 (x) (y))
      )
      nil
    )
    (if (and (eq tk 4) (< yv 0) )
      (progn
        (set_yvel (* (/ yv 7) -5) )
        (set_xvel (* (/ xv 7) 5) )
        (play_sound (aref GREN_SND (random 2)) 127 (x) (y))
      )
      nil
    )
    (if (and (eq tk 8) (> yv 0) )
      (progn
        (set_yvel (- 0 yv) )
        (set_xvel (* (/ xv 7) 5) )
        (if (eq (yvel) 0 )
          (set_xvel 0)
          nil )
        (set_gravity 1)
        (play_sound (aref GREN_SND (random 2)) 127 (x) (y))
      )
      nil
    )
  )
  (if (or (> (yvel) 0) (< (yvel) 0) (> (xvel) 0) (< (xvel) 0) )
    (next_picture)
    nil
  )
  (if (> (total_objects) 0)
    (let ( (mex (x)) (mey (y)) )
      (if (with_object (get_object 0) (find_object_in_area 	(- mex 7)
  								(- mey 7)
								(+ mex 7)
								(+ mey 7) bad_guy_list))

        (set_hp 31)
        nil
      )
    )
  )
  (if (> (hp) 30)
    (progn
      (do_explo 40 36)
      nil
    )
    (progn
      (add_hp 1)
      T
    )
  )
)