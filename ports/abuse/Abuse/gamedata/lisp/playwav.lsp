;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;; you can use this to hear various sound effects
;; example : abuse -lsf lisp/playwav.lsp sfx/grenad01.wav"

(defun playwav (arg_on)
  (if (>= arg_on (argc))
      nil
    (progn
      (print (concatenate 'string "Playing " (argv arg_on)
	                          ", type c <ENTER> to continue"))
      (play_sound (def_sound (argv arg_on)))
      (break)
      (playwav (+ arg_on 1)))))

(playwav 3)  ;; start on paramter 3 (skip -lsf play)

(quit)
