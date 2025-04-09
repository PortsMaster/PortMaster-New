;; Copyright 1999 Profound Corp,  All Rights reserved
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

(load "addon/twist/lisp/english.lsp")
(load "lisp/common.lsp")
(load "lisp/userfuns.lsp")
(load "addon/twist/lisp/userfuns.lsp")
(load "addon/twist/lisp/options.lsp")
(load "addon/twist/lisp/startup.lsp")
(load "lisp/input.lsp")

(load "lisp/sfx.lsp")
(load "addon/twist/lisp/sfx.lsp")
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
(load "addon/twist/lisp/objects.lsp")

(setq bad_guy_list (list DARNEL RAIDER REDANT BLADES JUGGERMAN MAN_LEGSANT MAN_LEGSJUG MAN_LEGSFLY MAN_BODYTRACK MAN_BODYSPRAY WALK_ROB WALK_ROBHEAD ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT))
(setq object_destroyable_list (list BLOCK MAN_LEGSANT MAN_LEGSJUG MAN_LEGSFLY WALK_ROB WALK_ROBHEAD ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT))

(gc)              ;; garbage collection perm space
(tmp-space)       ;; execute game code in tmp space which is not GC'ed

(create_players DARNEL)
