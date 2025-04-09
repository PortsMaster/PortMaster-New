

;;;; load up the normal abuse startup file

;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights


(perm-space)

(setq load_warn nil)
(setq section 'game_section)
(if (not (load "lisp/english.lsp"))             ;; load language specific stuff
    (progn
      (print "Please make sure you unzipped the game with the -d option")
      (print "so that all directories get created properly.")
      (print "example : pkunzip -d abusXXXX.zip")
      (quit)))
(setq load_warn T)


(load "lisp/common.lsp")
(load "lisp/userfuns.lsp")
(load "lisp/options.lsp")
(load "lisp/startup.lsp")
(if (not (local_load "lisp/input.lsp"))   ; get local copy first
    (load "lisp/input.lsp"))

(load "lisp/sfx.lsp")
(load "lisp/gates.lsp")
(load "lisp/duong.lsp")
(load "lisp/ant.lsp")
(load "lisp/people.lsp")
(load "lisp/weapons.lsp")
(load "lisp/explo.lsp")
(load "lisp/platform.lsp")
(load "lisp/guns.lsp")
(load "lisp/jugger.lsp")
(load "lisp/flyer.lsp")
(load "lisp/teleport.lsp")
(load "lisp/general.lsp")
(load "lisp/powerup.lsp")
(load "lisp/doors.lsp")
(load "lisp/light.lsp")
(load "lisp/ladder.lsp")
(load "lisp/switch.lsp")




;;;; load up additional files
(load "addon/leon/lisp/njug.lsp")
(load "addon/leon/lisp/deco.lsp")
(load "addon/leon/lisp/text.lsp")
(load "addon/leon/lisp/nextlev3.lsp")
(load "addon/leon/lisp/lnant.lsp")
(load "addon/leon/lisp/lmisc.lsp")
(load "addon/leon/lisp/grenade.lsp")
(load "addon/leon/lisp/nguns.lsp")
(load "addon/leon/lisp/rain.lsp")
(load_tiles "addon/leon/lnewft.spe")
(load_tiles "addon/leon/lnewft2.spe")
(set_first_level "addon/leon/level00.spe")


(setq bad_guy_list (list DARNEL ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT
ANT ANT_JUMPER ANT_PRED ANT_GREATER2 NJUGGER))



(gc)              ;; garbage collection perm space
(tmp-space)       ;; execute game code in tmp space which is not GC'ed

(create_players DARNEL)
