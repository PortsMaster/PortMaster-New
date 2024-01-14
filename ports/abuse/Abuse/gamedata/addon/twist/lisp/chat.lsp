(enable_chatting)

(defun chat_input (str)
  (if (and (> (length str) 0) (equal (elt str 0) #\/))
      (if (and (search "/nick " str) (> (length str) 6))
	  (chat_print (concatenate 'string "# " (player_name) " is known as "
				   (progn (set_player_name (substr 6 (- (length str) 1) str))
					  (player_name))))
	(if (search "/help" str)
	    (if (local_player)
		(chat_print "Commands : /nick name, /help, /quit, /break"))

	;; Start Of Cheat
	;;1
	(if (search "/quit" str)
	    (if (local_player)
		(progn (chat_print "Game Quit")(quit)))
	;;2
	(if (search "/break" str)
	    (if (local_player)
		(progn (chat_print "Game Break")(break)))
	;;3
	(if (search "/god" str)
	    (if (local_player)
		(if (eq godmode 0) (progn (setq godmode 1)(chat_print "God Mode On"))
				   (progn (setq godmode 0)(chat_print "God Mode Off"))))
	;;4
	(if (search "/notarget" str)
	    (if (local_player)
		(if (eq enemynotarget 0) (progn (setq enemynotarget 1)
						(chat_print "No Target On"))
					 (progn (setq enemynotarget 0)
						(chat_print "No Target Off"))))
	;;5
	(if (search "/noclip" str)
	    (if (local_player)
		(if (eq noclip 0) (progn (setq noclip 1)(chat_print "No Clipping On"))
				  (progn (setq noclip 0)(chat_print "No Clipping Off"))))
	;;6
	(if (search "/jump" str)
	    (if (local_player)
		(progn	(with_object (bg) (progn (set_x (player_pointer_x))
						 (set_y (player_pointer_y))))
			(chat_print (concatenate 'string "Player Jumped To Position"
				" X"(digstr (player_pointer_x) 3) " Y" (digstr (player_pointer_y) 3)"."))))
	;;7
	(if (search "/give all" str)
	    (if (local_player)
		(progn	(give_weapon 0)(give_weapon 1)(give_weapon 2)(give_weapon 3)
			(give_weapon 4)(give_weapon 5)(give_weapon 6)(give_weapon 7)
			(add_ammo 0 100)(add_ammo 1 100)(add_ammo 2 100)(add_ammo 3 100)
			(add_ammo 4 100)(add_ammo 5 100)(add_ammo 6 100)(add_ammo 7 100)
			(setq has_compass 1)
			(chat_print "Received All")))
	;;8
	(if (search "/give lasergun" str)
	    (if (local_player)
		(progn (give_weapon 0)(chat_print "Received Laser Gun")))
	;;9
	(if (search "/give grenadelauncher" str)
	    (if (local_player)
		(progn (give_weapon 1)(chat_print "Received Grenade Launcher")))
	;;10
	(if (search "/give rocketlauncher" str)
	    (if (local_player)
		(progn (give_weapon 2)(chat_print "Received Rocket Launcher")))
	;;11
	(if (search "/give firebomb" str)
	    (if (local_player)
		(progn (give_weapon 3)(chat_print "Received Firebomb")))
	;;12
	(if (search "/give plasmagun" str)
	    (if (local_player)
		(progn (give_weapon 4)(chat_print "Received Plasma Gun")))
	;;13
	(if (search "/give lightsabre" str)
	    (if (local_player)
		(progn (give_weapon 5)(chat_print "Received Light Sabre")))
	;;14
	(if (search "/give deathfrizbee" str)
	    (if (local_player)
		(progn (give_weapon 6)(chat_print "Received Death Frizbee")))
	;;15
	(if (search "/give deathray" str)
	    (if (local_player)
		(progn (give_weapon 7)(chat_print "Received Death Ray")))
	;;16
	(if (search "/give bullets" str)
	    (if (local_player)
		(progn (add_ammo 0 100)(chat_print "Received Bullets")))
	;;17
	(if (search "/give grenades" str)
	    (if (local_player)
		(progn (add_ammo 1 100)(chat_print "Received Grenades")))
	;;18
	(if (search "/give rockets" str)
	    (if (local_player)
		(progn (add_ammo 2 100)(chat_print "Received Rockets")))
	;;19
	(if (search "/give gasoline" str)
	    (if (local_player)
		(progn (add_ammo 3 100)(chat_print "Received Gasoline")))
	;;20
	(if (search "/give plasmacells" str)
	    (if (local_player)
		(progn (add_ammo 4 100)(chat_print "Received Plasma Cells")))
	;;21
	(if (search "/give sabrecharger" str)
	    (if (local_player)
		(progn (add_ammo 5 100)(chat_print "Received Sabre Charger")))
	;;22
	(if (search "/give frizbees" str)
	    (if (local_player)
		(progn (add_ammo 6 100)(chat_print "Reiceved Frizbees")))
	;;23
	(if (search "/give bfgcells" str)
	    (if (local_player)
		(progn (add_ammo 7 100)(chat_print "Received BFG Cells")))
	;;24
	(if (search "/give weapons" str)
	    (if (local_player)
		(progn (give_weapon 0)(give_weapon 1)
		       (give_weapon 2)(give_weapon 3)
		       (give_weapon 4)(give_weapon 5)
		       (give_weapon 6)(give_weapon 7)
		       (chat_print "Received All Weapons")))
	;;25
	(if (search "/give ammo" str)
	    (if (local_player)
		(progn (add_ammo 0 100)(add_ammo 1 100)
		       (add_ammo 2 100)(add_ammo 3 100)
		       (add_ammo 4 100)(add_ammo 5 100)
		       (add_ammo 6 100)(add_ammo 7 100)
		       (chat_print "Received All Ammo")))
	;;26
	(if (search "/give powernone" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(setq special_power NO_POWER)))(chat_print "Received Power None")))
	;;27
	(if (search "/give powerfast" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(setq special_power FAST_POWER)))(chat_print "Received Power Fast")))
	;;28
	(if (search "/give powerfly" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(setq special_power FLY_POWER)))(chat_print "Received Power Fly")))
	;;29
	(if (search "/give powersneaky" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(setq special_power SNEAKY_POWER)))(chat_print "Received Power Sneaky")))
	;;30
	(if (search "/give powerhealth" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(setq special_power HEALTH_POWER)))(chat_print "Received Power Health")))
	;;31
	(if (search "/give health" str)
	    (if (local_player)
		(progn (with_object(bg)(progn(set_hp 100)))(chat_print "Received 100% Health")))
	;;32
	(if (search "/give compass" str)
		(progn (setq has_compass 1)(chat_print "Received Compass"))
	;;33
	(if (search "/give ant" str)
	    (if (local_player)
		(progn	(add_object ANT_ROOF (with_object(bg)(x)) (with_object(bg)(-(y)10)) 1)
			(chat_print "You want an ANT, you get an ANT!")))
	;;34
	(if (search "/give death" str)
	    (if (local_player)
		(progn	(with_object (bg) (do_explo 100 400))
			(chat_print "You asked for it didn't you?")))
	;;35
	(if (search "/profound's deepest darkest secret" str)
	    (if (local_player)
		(chat_print "!I LOVE CHERRIE!"))
	;;36
	(if (or (search "/power overwhelming" str) (search "/there is no cow level" str))
	    (if (local_player)
		(chat_print "Listen dude, this ain't Starcraft."))
	;;37
	(if (or (search "/iddqd" str) (search "/idkfa" str) (search "/idclev" str))
	    (if (local_player)
		(chat_print "Sorry, wrong game. This is not Doom."))
	;;38
	(if (or (search "/profound" str) (search "/munir" str) (search "/about" str))
	    (if (local_player)
		(progn
		(chat_print "TWISTED MINDS addons for ABUSE")
		(chat_print "Munir Hussin")
		(chat_print "website: www.profound.8m.com")
		(chat_print "email: munir@profound.8m.com")))
	;;39
	(if (search "/tip" str)
	    (if (local_player)
		(progn
		(if (eq (mod (game_tick) 20) 0) (chat_print "Profound Corp ROCKS!")
		(if (eq (mod (game_tick) 20) 1) (chat_print "Beware of Ants...duh!")
		(if (eq (mod (game_tick) 20) 2) (chat_print "Jumping around makes enemies hard to target you.")
		(if (eq (mod (game_tick) 20) 3) (chat_print "Laser Gun fire faster when you have ammo.")
		(if (eq (mod (game_tick) 20) 4) (chat_print "Grenades travel in parabolic arc.")
		(if (eq (mod (game_tick) 20) 5) (chat_print "Rockets will track enemies.")
		(if (eq (mod (game_tick) 20) 6) (chat_print "Firebomb is affected by gravity.")
		(if (eq (mod (game_tick) 20) 7) (chat_print "Plasmagun has rapid firing.")
		(if (eq (mod (game_tick) 20) 8) (chat_print "Light Sabre beams at high rate.")
		(if (eq (mod (game_tick) 20) 9) (chat_print "Death Frizbee will try to follow mouse cursor.")
		(if (eq (mod (game_tick) 20) 10)(chat_print "Death Ray is one Big Fraggin Gun.")
		(if (eq (mod (game_tick) 20) 11)(chat_print "Munir Hussin is a good looking guy.")
		(if (eq (mod (game_tick) 20) 12)(chat_print "Change your underwear daily.")
		(if (eq (mod (game_tick) 20) 13)(chat_print "Ants are fearless but stupid.")
		(if (eq (mod (game_tick) 20) 14)(chat_print "Mario Rules!.")
		(if (eq (mod (game_tick) 20) 15)(chat_print "Sub-Zero is cool.")
		(if (eq (mod (game_tick) 20) 16)(chat_print "You can type in cheat codes here.")
		(if (eq (mod (game_tick) 20) 17)(chat_print "LISP is fun!.")
		(if (eq (mod (game_tick) 20) 18)(chat_print "Kids, don't shoot lasers at home.")
		(if (eq (mod (game_tick) 20) 19)(chat_print "Nick is a professional. Don't try imitating him.")
		))))) ))))) ))))) )))))
	    ))
	;;41
	(if (search "/save" str)
	    (if (local_player)
		(progn
		(chat_print "Request Save")(save_game (concatenate 'string "save" (digstr (get_save_slot) 4) ".spe"))))
	;;41
	(if (and (search "/map " str) (> (length str) 5))
	    (if (local_player)
		(progn
		(chat_print (concatenate 'string "Loading Level " (substr 5 (- (length str) 1) str)))
		(request_level_load (concatenate 'string "addon/twist/levels/" (substr 5 (- (length str) 1) str) ".lvl"))))

	;; End Of Cheat


	(if (local_player)
	    (chat_print (concatenate 'string "unknown command " str)))))

	;;the brackets below corresponds to the number of cheats
	;;10 per row
	))))))))))
	))))))))))
	))))))))))
	))))))))))
	)

    (chat_print (concatenate 'string "<" (player_name) "> " str))))
