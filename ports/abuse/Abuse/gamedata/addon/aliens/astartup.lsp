;; Copyright 1997 Mike Moss (tfirestorm@aol.com),  All Rights reserved
;; See readme for more details on usage rights
;; blah blah yackety smackety
;;
;; Must be installed to abuse/addon/aliens/
;;
;; For full incorporation into Abuse see the readme
;;
;; Make a level and distribute it
;; All new objects are accessible through the level editor

(load "addon/aliens/alichars.lsp")
(load "addon/aliens/objects.lsp")
(load "addon/aliens/powerups.lsp")
(load "addon/aliens/sfx.lsp")
(load "addon/aliens/tiles.lsp")

;; Coming soon
(load "addon/aliens/death.lsp")
(if (not (load "addon/aliens/queen.lsp"))
   (def_char ALI_QUE
	(flags (unlistable T))
	(funs (ai_fun   do_nothing))
	(states "addon/aliens/aliens.spe"
		(stopped "awdi0001.pcx"))))

