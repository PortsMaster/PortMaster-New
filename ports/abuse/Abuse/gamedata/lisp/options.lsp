;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights


(setq true T)
(setq false nil)



; this determines if the player will automatically change to
; a new weapon when he/she first picks it up.  If you don't
; want this option change the "true" to "false"

(setq change_on_pickup true)




; this determines weither you start on the trainer level
; (levels/level00.spe).  If you change "false" to "true"
; the game will start on level 1 (levels/level01.spe)
; instead

(setq skip_trainer_level false)




; this determines if you will switch to a more powerful, or
; less powerful weapon when you run out of ammo on the current
; weapon.  This option does not do anything if you have the laser
; rifle and you run out of ammo.  This option will not switch to
; the firebomb either.  If this option is set to false then
; the player will switch to the laser rifle when out of ammo.

(setq switch_to_powerful true)




; this option determines weither the right mouse button can selected
; a weapon.  The default is false
; CTRL & INS keys work the best and sometimes the right mouse button
; will get in the way while flying.

(setq mouse_can_switch false)




; this option allows the game to exit a idle game after 1 minute
; and go into a demo

; (demo_break_enable)


