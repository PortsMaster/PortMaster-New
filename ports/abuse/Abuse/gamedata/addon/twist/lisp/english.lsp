;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights

(setq true T)
(setq false nil)

	 (setq ic_sell         "Help")
         (setq ic_quit         "Quit Twisted Minds")
	 (setq ic_easy         "Difficulty : Sane")
	 (setq ic_medium       "Difficulty : Wild")
	 (setq ic_hard         "Difficulty : Madness")
	 (setq ic_extreme      "Difficulty : Insanity!")

	 (defun get_train_msg (message_num)
	   (select message_num
                   ;   0123456789012345678901234567890123456789012345678901234567890123456789
		   ;  "--------------------------------------------------------------------"  ; V-A
		   ; Please keep all strings below shorter than the above line.               ; V-A
		   (0 "Aim gun with mouse, fire with left mouse button")
		   (1 "Collect ammo to increase firing speed")
                   (2 "Press the down arrow to activate objects. This is a switch.")
		   (3 "This console saves the state of the game, press down")
		   (4 "Press down to activate platform")
		   (5 "Hold down the right mouse button to use special powers")
		   (6 "Use the CTRL & INS keys to select weapons")
		   (7 "Press the up arrow to climb ladders")
		   (8 "Press the down arrow to start!")
		   (9 "Shoot hidden walls to destroy them")
		   (10 "Shoot switch ball to activate")
		   (11 "Press down to teleport")
		   ))

         (setq plot_start
               (concatenate 'string
                            " Nick Vrenna has pulled the switch and diverted the water supply. The spread "
                            "of Abuse may be over. He has gotten himself into the deepest underground prision "
                            "levels and battled against the mutants to save the outside world.\\n"
                            " As he leaves the Control Room, a mutant leaped onto him and slashed his wrist. "
                            "He gave the mutant a lethal blow in the head. He took a look at his wrist. There was "
                            "blood all over and he knew that he himself was infected with Abuse. Only time could tell "
                            "how long he could maintain his sanity... \\n"
                            " Alan Blake has to pay for all this madness. Nick has battled to saved the outside world. "
                            "Now, it is a torturing mind-struggle of pure insanity as he tries to save himself...\\n"
                            "- Twisted Minds\\n"
                            "Munir Hussin\\n"
                            "Profound Corp "))
         (setq plot_middle
               (concatenate 'string
                            "You have survived the initial outbreak, but you are still lost deep "
                            "within the prison. So far it's been suspiciously easy. \\n"
			    "If you want to break out - the real ABUSE lies ahead. "))
         (setq plot_end
               (concatenate 'string
                            "You've survived impossible odds and made it to the Control Room.  "
                            "By pulling the switch, you have diverted the water supply and stopped the spread of Abuse!\\n "
                            "CONGRATULATIONS!  YOU'RE HOWLING!!!"))