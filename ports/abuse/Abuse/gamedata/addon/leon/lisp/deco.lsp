(defun antbody_ai ()
  (if (< (hp) 16 ) (progn (next_picture) (set_hp (+ (hp) 1) ) ) nil )
  (if (eq0 (aistate)) 	  (progn
	    (try_move 0 10)
	    (if (eq (second (see_dist (x) (y) (x) (+ (y) 1))) (y))  ; if we are on the floor, don't check falling anymore
		(set_aistate 1))))
  T
)


(def_char ANTBODY
  (funs (ai_fun antbody_ai)
        (draw_fun   ant_draw))
  (flags (unlistable T)(add_front T)) ;; This class is obsolete, just keeping it here for compatibility
  (states "art/ant.spe"  (stopped (seq "adib" 1 16))))

(def_char DECO_ANTBODY
  (funs (ai_fun antbody_ai)
        (draw_fun   ant_draw))
  (flags (add_front T))
  (states "art/ant.spe"  (stopped (seq "adib" 1 16))))

(def_char DECO_ANTBODY2
  (funs (ai_fun do_nothing)
        (draw_fun   ant_draw))
  (states "addon/leon/lnant.spe"  (stopped "asit0001.pcx")))

(def_char DECO_ANTBODY3
  (funs (ai_fun do_nothing)
        (draw_fun   ant_draw))
  (states "art/ant.spe"  (stopped (seq "adib" 6 16))))


(def_char DECO_ANTHANG
  (funs (ai_fun sit_ai)
        (draw_fun   ant_draw))
  (states "art/ant.spe"  (stopped (seq "hang" 1 4))))

(defun sit_ai ()
  (select (aistate)
    (0 (set_hp (+ 20 (random 20) ) )
       (set_aistate 1)
    )
    (1 (set_hp (- (hp) 1) )
       (if (eq (hp) 0)
         (progn
           (set_aistate 0)
           (next_picture)
         )
       )
    )
  )
  T
)

(def_char DECO_ANTSIT
  (funs (ai_fun sit_ai)
        (draw_fun   ant_draw))
  (states "addon/leon/lnant.spe"  (stopped (seq "asit" 1 2))))