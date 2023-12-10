;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(defun set_all_lives (first x)
  (if (eq first nil)
      nil
    (progn
      (set_lives first x)
      (set_all_lives (next_focus first) x))))


(defun select_place (x place)
  (- (/ x place) (* (/ x (* place 10)) 10)))

(defun dig2char (x)
  (code-char (+ x (char-code "0"))))

;; this creates a list of dpaint numbered antimation from a base name
;; i.e. (seq "hi" 2 5)  -> '("hi0002.pcx" "hi0003.pcx" "hi0004.pcx" "hi0005.pcx")
;; will take into acount reverse sequences
(defun seq (name first last)
  (if (<= first last)
      (forward-seq name first last)
    (reverse-seq name first last))
)
(defun forward-seq (name first last)
  (if (> first last)
      nil
    (cons (concatenate 'string name (digstr first 4) ".pcx")
	  (forward-seq name (+ 1 first) last))))
(defun reverse-seq (name last first)
  (if (< last first)
      nil
    (cons (concatenate 'string name (digstr last 4) ".pcx")
	  (reverse-seq name (- last 1) first))))

(defun rep (name count)
  (if (eq count 0)
      nil
    (cons name (rep name (- count 1)))))


;; appends something to the end of a list
(defun app (head tail) (if (null head) tail (cons (car head) (app (cdr head) tail))))


