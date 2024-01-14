;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

(perm-space)
(setq net_dir "addon/deathmat/")
(defun net_file (x) (concatenate 'string net_dir x))
(load (net_file "dstartup.lsp"))
(load "lisp/options.lsp")

(load "lisp/input.lsp")
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

;; Artwork from fRaBs
(load "addon/claudio/claudio.lsp")
(load "addon/aliens/astartup.lsp")
(load "addon/newart/newart.lsp")
(load "addon/leon/4frabsdm.lsp")

(setq bad_guy_list (list DARNEL ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT))

(gc)              ;; garbage collection perm space
(tmp-space)       ;; execute game code in tmp space which is not GC'ed
(create_players DARNEL)


