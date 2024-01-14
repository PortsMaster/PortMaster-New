;; Copyright 1995 Crack dot Com,  All Rights reserved
;; See licensing information for more details on usage rights

;; all messages that need translation here
;; Latest version of this file is "V-E"  (version E=1.46)


(select section
	('game_section

	 /********** New for Version E (1.51)   **************/
	 (setq level_name         "Nom du niveau")
	 (setq FILENAME           "NOM DU FICHIER")
	 (setq CHAT               "CONVERSER")
	 (setq resync             "En train de synchroniser, veuillez attendre...")
	 (setq slack              "D‚connecter gens oisifs")
	 (setq hold!              "Attendez !")
	 (setq waiting            "Chargement des donn‚es...")
	 (setq Error              "Erreur")
	 (setq locating           "Essaie de localiser serveur %s, veuillez attendre\n")
	 (setq unable_locate      "Impossible … trouver")
	 (setq located            "Serveur trouv‚ ! En train de charger les donn‚es....\n")
	 (setq no_prot            "Pas de protocoles r‚seau install‚s\n")
	 (setq Installed          "Install‚ ")
	 (setq Not_Installed      "Pas install‚ ")
	 (setq calc_crc           "R‚seau : Contr“le CRC des fichiers")
	 (setq edit_saved         "Changements sauvegard‚s")
	 (setq saveas_name        "Enregistrer sous")
	 (setq l_light            "LumiŠre")
	 (setq l_fg               "PP")
	 (setq l_bg               "AP")
	 (setq New?               "Nouveau ?")
	 (setq l_EDIT             "Editer")

	 /********** New for Version D (1.46)   **************/

	 (setq ant_hide           "Cach‚ (1=vrai,0=faux)")
	 (setq ant_total          "Total")
	 (setq ant_type           "Type (0..7)")
	 (setq obj_frames         "Images jusqu'… l'arriv‚e")
	 (setq obj_frame          "Image actuelle")
	 (setq respawn_reg        "Images … r‚g‚n‚rer")
	 (setq conc_flash         "Eclair[1=on]")
	 (setq bomb_blink         "Clignotement")
	 (setq lightin_speed      "Vitesse ‚clair 0..9")
	 (setq gate_delay_time    "Temps d‚lai")
	 (setq gate_pulse_speed   "Vitesse pulsation")
	 (setq pusher_speed       "Pouss‚e de vitesse")
	 (setq spring_yvel        "R‚gler yvel … ?")
	 (setq train_msg_num      "M‚ssage numero")
	 (setq obj_holder_xoff    "x d‚cal‚")
	 (setq obj_holder_yoff    "y d‚cal‚ ")
	 (setq obj_holder_del     "Effacez-le (1=oui)")
	 (setq spray_delay        "D‚lai")
	 (setq spray_start        "D‚but angle")
	 (setq spray_end          "Fin angle")
	 (setq spray_speed        "Vitesse angle")
	 (setq spray_cangle       "Angle actuel")
	 (setq d_track_speed      "Vitesse ")
	 (setq track_fspeed       "Vitesse de tir")
	 (setq track_burst        "D‚gƒts de l'explosion ")
	 (setq track_cont         "Continuer d‚lai")
	 (setq track_sangle       "D‚but angle")
	 (setq track_eangle       "Fin angle")
	 (setq track_cangle       "Angle actuel")
	 (setq jug_throw_spd      "Vitesse pour lancer (0..255)")
	 (setq jug_throw_xv       "Lancer xvel")
	 (setq jug_throw_yv       "Lancer yvel")
	 (setq jug_stat           "Immobile ? (1=oui,0=non)")
	 (setq rob_noturn         "Pas de demi-tour (1=on)")
	 (setq rob_hide           "D‚but cach‚ (1=cach‚,0=visible)")
	 (setq who_fdelay         "D‚lai du tir")
	 (setq who_bdelay         "D‚lai de l'explosion")
	 (setq who_btotal         " D‚gƒts de l'explosion ")
	 (setq who_mxv            "Max xvel")
	 (setq who_myv            "Max yvel")
	 (setq wrob_fdelay        "D‚lai du tir")
	 (setq wrob_bdelay        "D‚lai de l'explosion")
	 (setq wrob_btotal        "D‚gƒts de l'explosion" )
	 (setq wrob_mxv           "Max xvel")
	 (setq wrob_myv           "Max Yvel")
	 (setq dimmer_step_amount "Nombre de marches")
	 (setq dimmer_steps       "Marches sombres")
	 (setq dimmer_dist        "Activer distance")
	 (setq dimmer_dedist      "D‚sactiver distance")
	 (setq dimmer_silent      "Mode silencieux (1=oui,0=non)")
	 (setq restart_station    "Num‚ro station")
	 (setq next_level         "Prochain niveau")
	 (setq plat_speed         "Vitesse")
	 (setq plat_2speed        "DeuxiŠme vitesse")
	 (setq plat_pos           "Pos actuelle (0..vitesse)")
	 (setq plat_wait          "Temps max d'attente")
	 (setq amb_num            "Num‚ro d'effet sonore (0-15)")
	 (setq amb_vol            "Volume (0-127)")
	 (setq amb_rep            "D‚lai r‚p‚t‚ (0=pas de r‚p‚tition)")
	 (setq amb_rand           "D‚lai al‚atoire (0=aucun)")
	 (setq switch_reset       "Temps de rer‚glage")
	 (setq sens_onxd          "(on) x dist")
	 (setq sens_onyd          "(on) y dist")
	 (setq sens_offxd         "(off) x dist")
	 (setq sens_offyd         "(off) y dist")
	 (setq sens_reset         "(off) Temps de rer‚glage")
	 (setq sens_unoff         "Ind‚sactivable (1=oui)")
	 (setq sens_cs            "Etat actuel")
	 (setq tp_amb             "R‚glage ambiance")



	 (setq ai_xvel            "Xvel      ")
	 (setq ai_yvel            "Yvel      ")
	 (setq ai_xacel           "Xacel     ")
	 (setq ai_yacel           "Yacel     ")
	 (setq ai_stime           "Temps ST  ")
	 (setq ai_gravity         "Gravit‚   ")
	 (setq ai_health          "Sant‚     ")
	 (setq ai_morph           "P Morph   ")
	 (setq ai_type            "Type IA   ")
	 (setq ai_state           "Etat IA   ")
	 (setq ai_fade            "Fondu 0-15")

	 (setq a_ambient          "Ambiant     ")
	 (setq a_aspeed           "Vitesse ambiante")
	 (setq a_view_xoff        "Vue xoff    ")
	 (setq a_view_yoff        "Vue yoff    ")
	 (setq a_view_xspd        "Vue vitesse x ")
	 (setq a_view_yspd        "Vue vitesse y ")
	 (setq saved_game         "Jeu sauvegard‚ savegame.spe")
	 (setq saved_level        "Niveau sauvegard‚ '%s'..\n")
	 (setq _scroll            "D‚filer")    ; as in left-right, up-down
	 (setq ap_width           "Largeur ")
	 (setq ap_height          "Hauteur")
	 (setq ap_name            "Nom")
	 (setq ap_pal             "Ajouter palette")
	 (setq mouse_at           "Position la souris %d, %d\n")


	 (setq l_links            "Liens")
	 (setq l_light            "LumiŠre")
	 (setq l_char             "Pers")
	 (setq l_back             "Retour")
	 (setq l_bound            "Li‚")
	 (setq l_fore             "Avant")


	 (setq SHOW?              "AFFICHER ?")
	 (setq back_loss (concatenate 'string "Ce taux de d‚filement diminue la taille de la care d'arriŠre
plan \n"
				      "Des dalles risquent d'ˆtre perdues, ˆtes-vous s–r(e) de vouloir le faire ?\n"))
	 (setq WARNING            "AVERTISSEMENT")
	 (setq x_mul              "X mul")    ; X multiple
	 (setq y_mul              "Y mul")
	 (setq x_div              "X div")    ; X divisor
	 (setq y_div              "Y div")

	 /*********** New for Version 1.45 ***********************/



	 (setq file_top           "Fichier")
	 (setq edit_top           "Editer")
	 (setq window_top         "Fenˆtres")
	 (setq menu1_load         "Lancer niveau")
	 (setq menu1_save         "Sauvegarder niveau (S)")
	 (setq menu1_saveas       "Enregistrer sous")
	 (setq menu1_savegame     "Sauvegarder jeu")
	 (setq menu1_new          "Nouveau niveau")
	 (setq menu1_resize       "Taille de la carte")
	 (setq menu1_suspend      "D‚couple toutes les fonctions")
	 (setq menu1_toggle       "Activer/d‚sactiver mode jeu  (TAB)")
	 (setq menu1_savepal      "Sauvegarder palettes         ")
	 (setq menu1_startc       "D‚but de l'ant‚m‚moire   ")
	 (setq menu1_endc         "Fin de l'ant‚m‚moire     ")
	 (setq menu1_quit         "Sortir      (Alt-X)")

	 (setq menu2_light        "Activer/d‚sactiver ‚clairage")
	 (setq menu2_scroll       "R‚gler vitesse de d‚filement")
	 (setq menu2_center       "Centrer vue sur joueur          (c)")
	 (setq menu2_addpal       "Ajouter palette")
	 (setq menu2_delay        "Activer/d‚sactiver d‚lais       (D)")
	 (setq menu2_god          "Invuln‚rable")
	 (setq menu2_clear        "Activer/d‚sactiver armes        (Maj-Z)")
	 (setq menu2_mscroll      "D‚filement de la carte avec la souris")
	 (setq menu2_lock         "Verrouiller fenˆtres palettes")
	 (setq menu2_raise        "Elever toutes les dalles")
	 (setq menu2_names        "Activer/d‚sactiver noms d'objets")
	 (setq menu2_map          "Activer/d‚sactiver carte        (?)")
	 (setq menu2_view         "Activer/d‚sactiver changement de vue")
	 (setq menu2_light        "Activer/d‚sactiver ‚clairage ambiant")
	 (setq menu2_fps          "Afficher nombre d'objets")

	 (setq menu3_fore         "Premier plan     (f)")
	 (setq menu3_back         "ArriŠre-plan     (b)")
	 (setq menu3_layers       "Afficher options (L)")
	 (setq menu3_light        "Eclairage        (l)")
	 (setq menu3_pal          "Palettes         (p)")
	 (setq menu3_objs         "Objets           (o)")
	 (setq menu3_console      "Console          (!)")
	 (setq menu3_toolbar      "Barre d'outils   (q)")
	 (setq menu3_prof         "Profil           (P)")
	 (setq menu3_save         "Sauvegarder positions")




	 (setq level_size "Taille du niveau")
                           ; 012345678901234567 (please keep same allignment of Name level & total)
	 (setq score_header "Nom          Total du niveau")   ; V-E
	 (setq space_cont "Appuyez sur la BARRE D'ESPACE pour continuer")        ; V-E
	 (setq no_saved "Pas de jeu sauvegard‚")

	 (setq lvl_2   "Petit") ; V-C added
	 (setq lvl_4   "Moyen") ; V-C added
	 (setq lvl_8   "Vaste") ; V-C added

	 (setq status  "Statut..")    ; V-A added
	 (setq Station "Secteur #")   ; V-A added
	 (setq secured " Termin‚ !")   ; V-A added
	 (setq loading "En train de charger %s")  ; V-A added

         (setq gamma_msg "S‚lectionnez la couleur la plus sombre visible\nsur l'‚cran, puis cliquez sur la case … cocher")


(setq telep_msg "Appuyez sur la flŠche bas pour vous t‚l‚porter")

         (defun get_train_msg (message_num)
           (select message_num
                   (0 "Pointez le canon avec la souris, tirez avec le bouton gauche")
                   (1 "R‚cup‚rez des munitions pour augmenter votre cadence de tir")
                   (2 "Appuyez sur la flŠche bas pour activer l'interrupteur")
                   (3 "Appuyez sur la flŠche bas pour sauvegarder le jeu")
                   (4 "Appuyez sur la flŠche bas pour activer la plate-forme")
                   (5 "Appuyez sur bouton droit, maintenez pour utiliser un pouvoir")
                   (6 "Utilisez les touches CTRL ou INSER pour s‚lectionner les armes")
                   (7 "Appuyez sur la flŠche haut pour monter aux ‚chelles")
                   (8 "Appuyez sur la flŠche bas pour activer !")
                   (9 "Tirez sur les parois destructibles pour les d‚molir")
                   (10 "Tirez sur l'interrupteur sph‚rique pour l'activer")
                   (11 "Appuyez sur la flŠche bas pour vous t‚l‚porter")
                   ))
	 (setq not_there       "Ce jeu s'est arrˆt‚")
	 (setq max_error       "Nombre max. de joueurs doit ˆtre sup‚rieur ou ‚gal au nombre min. de joueurs") ; V-C changed


	 ;(setq min_error       "Nombre min. de joueurs doit ˆtre entre 1 et 8\nNombre min. de joueurs doit ˆtre inf‚rieur ou ‚gal au nombre max. de joueurs")  ; V-A changed, V-B deleted

	 (setq port_error      "Num‚ro du jeu doit ˆtre entre 1 et 9")       ; V-A changed
	 (setq kill_error      "Le quota de morts doit ˆtre entre 1 et 99")      ; V-A changed
	 (setq name_error      "CaractŠres non valides")         ; V-B changed
	 (setq game_error      "CaractŠres non valides pour le nom du jeu")         ; V-B added
	 (setq input_error     "Erreur de donn‚es")
	 (setq ok_button       "OK")
	 (setq cancel_button   "ANNULER")
	 (setq kills_to_win    "Quota de morts requis pour changer de niveau")
	 (setq max_play        "Nombre max. de joueurs")
	 (setq min_play        "\nNombre min. de joueurs")          ; V-B (added \n)
	 (setq use_port        "Num‚ro du jeu")
	 (setq your_name       "Votre nom")

(setq max_players     "Le serveur a d‚j… atteint le nombre maximal de joueurs, ressayez plus tard\n")
         (setq net_not_reg     "D‚sol‚, vous ne pouvez pas jouer au jeu sur le r‚seau avec une version d‚mo\n")
         (setq min_wait        "Veillez attendre pour %d participant(s) !")
         (setq lev_complete    "Niveau termin‚ !")
         (setq no_low_mem         (concatenate 'string "Gestionnaire de m‚moire : Pas assez de m‚moire disponible\n"
                                           "  Suggestions...\n"
                                           "    - cr‚ez une disquette de d‚marrage (consultez le manuel)\n"
                                           "    - enlevez les programmes r‚sidant en m‚moire et les gestionnaires qui ne sont pas n‚cessaires pour ABUSE\n"
                                           "    - ajoutez de la m‚moire … votre systŠme\n"))
         (setq no_mem    (concatenate 'string "Gestionnaire de m‚moire : D‚sol‚, vous n'avez pas assez de m‚moire disponible pour\n"
                                           "  Suggestions...\n"
                                           "    - cr‚ez une disquette de d‚marrage (consultez le manuel)\n"
                                           "    - enlevez les programmes r‚sidant en m‚moire et les gestionnaires qui ne sont pas n‚cessaires pour ABUSE\n"
                                           "    - ajoutez de la m‚moire … votre systŠme\n"))

         ; this is not used right now...
         ;(setq server_not_reg  (concatenate 'string "D‚sol‚, le serveur affiche la version d‚mo d'Abuse,\n"
         ;                                           "pour ‚viter des problŠmes de compatibilit‚, veuillez utiliser l'option -share\n"))

         (setq server_port     "Port du serveur")
         (setq server_name     "Nom du jeu")              ; V-B
         (setq Networking      "Jeu sur r‚seau")
         (setq server          "Commencer nouveau jeu")
         (setq client          "Participer au jeu en cours ?")
         (setq single_play     " Un seul joueur ")
(setq single_play     "    Sortir du jeu sur r‚seau    ")  ; V-A
         (setq cancel_net      "      Annuler        ")

         (setq ic_return       "Retourner au jeu")
         (setq ic_quit         "Sortir du jeu")
         (setq ic_volume       "Contr“le du volume")
         (setq ic_gamma        "Luminosit‚")
         (setq ic_easy         "Difficult‚ : Mauviette")
         (setq ic_medium       "Difficult‚ : Pas de problŠme")
         (setq ic_hard         "Difficult‚ : C'est pas gagn‚")
         (setq ic_extreme      "Difficult‚ : Cauchemar")  ; don't make any strings longer than this!
         (setq ic_load         "Charger jeu sauvegard‚")
         (setq ic_start        "D‚marrer nouveau jeu")
         (setq ic_sell         "G‚n‚rique")
         (setq ic_networking   "Jeu sur r‚seau")
         (setq no_file         "Fichier introuvable '%s'")
         (setq SFXv            "Son")
         (setq MUSICv          "Volume")

         (setq to_be_continued "A suivre.....")
         (setq no_edit         "Cette version du jeu est d‚pourvue de l'‚diteur")
         (setq no_hirez        "La haute r‚solution n'est disponible qu'avec le mode ‚diter (-edit)")
         (setq no2             "Ne peut pas utiliser -2 avec -edit")
         (setq no_pals         "Aucune palette d‚finie")
         (setq unchop1         "ussage : unchop xsize ysize\n")
         (setq size1           "ussage : taille largeur hauteur\n")
         (setq name_now        "Le niveau actuel est '%s'\n")
         (setq esave           "Editer sauvegarde : ‚criture de edit.lsp\n")
         (setq nd_player       "Impossible d'effacer joueur !\n")
         (setq d_nosel         "Pas d'objet ou de lumiŠre s‚lectionn‚s … effacer.")
         (setq forward?        "Avancer quel objet ?")
         (setq back?           "Reculer quel objet ?")
         (setq aitype?         "Type IA pour qui ?")
         (setq prof_off        "Cache d‚sactiv‚")
         (setq prof?           "Cache n'est pas actif !")
         (setq sure?           "Etes-vous s–r ?")
         (setq width_          "Largeur")
         (setq height_         "Hauteur")
         (setq suspend_on      "Les objets li‚s ne seront pas ex‚cut‚s")
         (setq suspend_off     "Interrompre mode off")
         (setq quit_title      "Sortir ?")
         (setq YES             "OUI")
         (setq NO              "NON")
         (setq seqs_off        "S‚quences photos off\n")
         (setq seqs_on         "S‚quences photos on (1 toutes les 5 sec)\n")
         (setq ms_on           "D‚filement permis\n")
         (setq ms_off          "D‚filement non-permis\n")
         (setq pal_lock        "Les palettes sont verrouill‚es")
         (setq pal_unlock      "Les palettes sont d‚verrouill‚es")
         (setq vs_dis          "Changement de vue d‚sactiv‚")
         (setq vs_en           "Changement de vue activ‚")
         (setq fg_r            "Toutes les dalles du premier plan seront ‚lev‚es")
         (setq fg_l            "Toutes les dalles du premier plan seront abaiss‚es")
         (setq no_clone        "Impossible de cloner joueur !\n")
         (setq no_edit.lsp     "Impossible d'ouvrir edit.lsp pour ‚crire")
         (setq missing_sym     "Manque symbole pour langage !")
         (setq delay_off       "D‚lai off")
         (setq delay_on        "D‚lai on")
         (setq too_big         "Valeur trop grande, utilisez des chiffres plus petits !")
         (setq LOAD            "CHARGER")   ; don't let this get too long
         (setq SAVE            "SAUVEGARDER")   ; don't let this get too long

         (setq net_not_reg
               (concatenate 'string "Vou disposez de la version COMMERCIALE D'ABUSE mais pas le serveur.\n"
                            "Demandez … l'op‚rateur du serveur de lancer l'option -share ou une meilleure option,\n"
                            "Achetez ABUSE, les jeux sur le r‚seau sont plus amusants parce que vous pouvez voler,\n"
                            "devenez invisible et disposez de plus d'armes pour vous sortir d'affaire\n"))

         (setq server_not_reg
               (concatenate 'string
                            "Sur ce serveur, la version commerciale d'Abuse n'est pas disponible mais\n"
                            "vous y jouez (merci !).  Pour qu'il n'y ait pas de conflit entre les deux jeux\n"
                            "veuillez commencer avec l'option -share lorsque vous vous connectez … ce serveur\n"
                            "exemple : abuse -net qqpart.qqchose.net -share\n"))



	 (setq thank_you "Merci d'avoir jou‚ … Abuse !\n\n")     ; V-A

         (setq load_warn nil)
         (setq end_msg thank_you)

         (setq load_warn T)

         (setq plot_start
               (concatenate 'string
                            "Vous ˆtes Nick Vrenna. C'est l'ann‚e 2009.  A tort, vous avez ‚t‚ incarc‚r‚ "
                            "dans une prison souterraine de haute surveillance o— ont lieu des exp‚riences g‚n‚tiques "
			    " ill‚gales.\\n"
                            "Alan Blake, … la tˆte de la recherche scientifique, a isol‚ le gˆne qui provoque "
			    "violence et agression chez les humains. Cette s‚quence g‚n‚tique appel‚e "
                            '(#\") "Abuse" '(#\") " est extrˆmement infectieuse, elle engendre des transformations "
			    "horribles et provoque de monstrueux effets secondaires.  "
                            "Vous ˆtes la seule personne immunis‚e contre ces effets. \\n"
                            "Une ‚meute commence et dans ce d‚sordre, toutes les portes de "
			    "prison s'ouvrent. TrŠs vite, les gardes, ainsi que les d‚tenus "
                            "sont contamin‚s et transform‚s en une horde de mutants qui envahissent le "
                            "bƒtiment.\\n"
                            "Votre seule chance pour vous enfuir est de vous revˆtir d'une armure "
			    "de combat et d'aller … la Salle des commandes "
                            "qui se trouve au niveau le plus ‚loign‚ de la structure. Mais d'abord, vous devez "
			    "empˆcher l'approvisionnement d'eau qui a ‚t‚ infect‚ par Abuse de contaminer "
                            "le monde ext‚rieur. La libert‚ et le sort de l'humanit‚ sont maintenant entre vos mains. " ))

	 (setq plot_middle
               (concatenate 'string
                            "Vous avez surv‚cu la vague initiale de contamination, mais vous ˆtes "
			    "encore perdu au fin fond de la prison "
			    "Jusqu'ici, c'‚tait d'une facilit‚ suspecte. \\n"
			    "Si vous voulez vous ‚chapper, ne manquez pas de jouer … Abuse dans son int‚gralit‚. "))


         (setq plot_end
               (concatenate 'string
                            "F‚licitations ! Vous avez r‚ussi … survivre dans une situation incroyable et "
			    "vous ˆtes … la Salle de commandes.  "
                            "En appuyant sur l'interrupteur, vous avez d‚tourn‚ l'arriv‚e d'eau "
			    "et mis fin … la propagation d'Abuse ! "
			    "VOUS L'AVEZ ECHAPPE BELLE !"))
	 )
)



