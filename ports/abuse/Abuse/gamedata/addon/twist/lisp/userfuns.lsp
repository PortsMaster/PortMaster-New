;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(defun seqbmp (name first last)
  (if (<= first last)
      (forward-seqbmp name first last)
    (reverse-seqbmp name first last)))

(defun forward-seqbmp (name first last)
  (if (> first last)
      nil
    (cons (concatenate 'string name (digstr first 4) ".bmp")
	  (forward-seqbmp name (+ 1 first) last))))

(defun reverse-seqbmp (name last first)
  (if (< last first)
      nil
    (cons (concatenate 'string name (digstr last 4) ".bmp")
	  (reverse-seqbmp name (- last 1) first))))