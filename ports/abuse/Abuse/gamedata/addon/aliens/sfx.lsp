;; In places Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights
;;
;; Mostly Copyright 1997 Mike Moss (tfirestorm@aol.com),  All Rights reserved
;; See readme for more details on usage rights

(defun aldir (filename) (concatenate 'string "addon/aliens/" filename))

;; alien slash/bite noise
(def_sound 'ALSLASH_SND		(aldir "aslash01.wav"))

;; alien screaming
(def_sound 'ALSCREAM_SND	(aldir "alien01.wav"))

;; alien pain sound
(def_sound 'ALPAIN_SND		(aldir "ahit01.wav"))

;; alien pain sound
(def_sound 'ALTAUNT_SND		(aldir "altaunt.wav"))

;; alien death
(setq AL_DEATH (make-array 4 :initial-contents
			     (list	(def_sound (aldir "adie01.wav"))
					(def_sound (aldir "adie02.wav"))
					(def_sound (aldir "adie03.wav"))
					(def_sound (aldir "adie05.wav")))))

;; egg hatching noise
(def_sound 'EGGH_SND		(aldir "egghatch.wav"))

;; fh jar breaking noise
(def_sound 'JBRK_SND		(aldir "jarbreak.wav"))
