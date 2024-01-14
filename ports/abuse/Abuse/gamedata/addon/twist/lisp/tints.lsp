;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(setq man_tints (make-array 11 :initial-contents (list
						 normal_tint
						 (def_tint "art/tints/cop/pinkish.spe")
						 (def_tint "art/tints/cop/olive.spe")
						 (def_tint "art/tints/cop/purple.spe")
						 (def_tint "art/tints/cop/darkblue.spe")
						 (def_tint "art/tints/cop/fire.spe")
						 (def_tint "art/tints/cop/land.spe")
						 (def_tint "art/tints/cop/blue.spe")
						 normal_tint
						 normal_tint
						 normal_tint
						 )))

(defun man_draw ()
  (if (eq 0 (aitype))
      (draw)
    (draw_tint (aref man_tints (aitype)))))

