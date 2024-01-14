;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(defun twistsfxdir (filename) (concatenate 'string "addon/twist/sfx/" filename))

(def_sound 'DEATH_RAY_SND      (twistsfxdir "dray.wav"))