;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


;; Note for /Messiah\
;; append this to the final set of lines relating to the loading part:
;; (load "addon/twist/lisp/dray.lsp")

;; make sure you add all the objects that the deathray's light beam will have effect on.
;; the objects are simply the bad_guy_list... BUT, remove DARNEL from the list.

(setq object_destroyable_list (list DARNEL ANT_ROOF TRACK_GUN SPRAY_GUN JUGGER ROB1 WHO ROCKET FLYER GREEN_FLYER BOSS_ANT DROID_JUGGER DROID DEATH_SKULL DEATH_UMBRELLA ANT_SHIP WALK_ROB T_REX FACE_HUGGER ALIEN_DRONE ALIEN_WARRIOR))


;; this will allow the player to pick up both ammo and weapons.
(setq enableammoandweapons 1)

(load "addon/twist/lisp/userfuns.lsp")
(load "addon/twist/lisp/sfx.lsp")
(load "addon/twist/lisp/weapons.lsp")
(load "addon/twist/lisp/light.lsp")
;; this is the cheat stuff
(load "addon/twist/lisp/chat.lsp")

;; if you want to load any other stuff from twisted minds, simply add the link below


;; this is the palette used for the death ray. the normal palette
;; dont have any purple and a pink deathray dosent look good.
(load_palette      "addon/twist/art/palette.spe")
