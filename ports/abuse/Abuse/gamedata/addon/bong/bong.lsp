;;;; Copyright 1995 Crack dot Com,  All Rights reserved
;;;; See licensing information for more details on usage rights

;;;; to play this game, go to the abuse root directory and type :
;;;; abuse -a bong
;;;; -a tells abuse to use an alternate Lisp Startup File from addon/bong/bong.lsp

;;;; Notes :
;;;;   This "game" was written by Jonathan Clark as a demonstration of the
;;;; capabilities of the abuse engine.  It is not meant to be a complete game
;;;; and is released strictly for purpose of study only.  Any part of this file
;;;; may be used by others and distributed in any form, but it uses some of the
;;;; lisp, sound effects, and artwork from Abuse (TM) which may only distributed
;;;; as a complete package with no files missing or changed.

;;;; ***** Emacs plug *********
;;;; If you don't already have emacs, get it!  It's free.
;;;; Firstly it makes editing lisp 100% easier because it matches braces.
;;;; Secondly if you load the hi-lighting .el file you can read this file much
;;;; easier because all comments, strings, etc will be different colors.
;;;; I don't know the exact site where to find it, but if you telnet to
;;;; archie.unl.edu or look it up on a web search server you are sure to find it.
;;;; You might be interest to know emacs is also very customizable using a language
;;;; called lisp :-)

;;;; Please do not ask me for docs on how to code with the abuse engine, there are
;;;; none at this time and there won't be any until networked abuse is available.
;;;; ALL games written with the abuse engine are network ready with no additional
;;;; work including this one, but there are some issues that need addressing
;;;; that cannot be fully discussed until the net code is finished.  When these
;;;; docs are written they will be available at http://www.crack.com   Estimated
;;;; date for these docs is sometime late Oct. 1995

(perm-space)   ; define all functions and global variable in "perm space" which
               ; is a space which will be garbage collected when it fills up.
               ; The down side to garbage collection is that it is a little slow
               ; and users of very slow machines will notice a very small pause
               ; from time to time, though writers of games may ignore this issue and
               ; always stay in "perm space"
               ;
               ; "tmp space" on the other hand, is not garbage collected, but rather
               ; at the end of executing an object's function will be completely
               ; thrown away it's important not to do a setq on a global variable
               ; (not local and not a member of the object) because the memory the
               ; item resides in will be lost after the function finishes.. see the
               ; add_score function in this file.


;; this is a simple check to see if they player has an engine version
;; capable of playing the game.  All games should at least check for version 1.0
;; because all version before that are beta and have known bugs.
(if (< (+ (* (major_version) 100) (minor_version)) 100)    ; require at least version 1.0
    (progn
      (print "Your engine is out of date.  This game requires version 1.0")
      (quit)))


(if (not (am_a_client))   ;; become a server if we are not a client
    (progn
      (set_game_name "Bong")
      (start_server)
      (set_net_min_players 1)
      ))


(setq pong_dir "addon/bong/")  ; in case we change the location of these files later
                               ; this is always a very good idea to do because the user of
                               ; this program may/may not be able to install into this directory
(setq pong_art (concatenate 'string pong_dir "bong.spe"))  ; all artwork is in this file

(setq load_warn nil)            ; don't show a waringing if these files aren't there
(setq section 'game_section)
(load "lisp/english.lsp")       ; need this for various translated messages (english only pong for now!)
(load "gamma.lsp")              ; gamma correction values (if saved)
(setq load_warn T)

(load "lisp/common.lsp")        ; grab the definition of abuse's light holder & obj mover
(load "lisp/userfuns.lsp")      ; load seq defun
(load "lisp/input.lsp")         ; get input mapping stuff from abuse


;; these are a few things that the engine requires you to load...
(load_big_font     "art/letters.spe" "letters")
(load_small_font   "art/letters.spe" "small_font")
(load_console_font "art/consfnt.spe" "fnt5x7")
(load_color_filter "art/back/backgrnd.spe")
(load_palette      "art/back/backgrnd.spe")
(load_tiles pong_art)  ; load all foreground & background type images from pong.spe

;; this is the image that will be displayed when the game starts
;; this needs to be in the form (X . Y) where X is the filename and
;; Y is the name of the image
(setq title_screen      (cons pong_art "title_screen"))

;; define a few sound effects to be used (these are all from abuse)
(def_sound 'METAL  "sfx/lasrmis2.wav")
(def_sound 'BHIT   "sfx/delobj01.wav")
(def_sound 'BLOWUP "sfx/ball01.wav")
(def_sound 'BUTTON_PRESS_SND "sfx/button02.wav")  ; used by menu system

;; use these images to draw the score
(setq nums (make-array 10 :initial-contents (list (def_image pong_art "0")
						  (def_image pong_art "1")
						  (def_image pong_art "2")
						  (def_image pong_art "3")
						  (def_image pong_art "4")
						  (def_image pong_art "5")
						  (def_image pong_art "6")
						  (def_image pong_art "7")
						  (def_image pong_art "8")
						  (def_image pong_art "9"))))
(setq score 0)

(defun show_score (x y digs_left score)
  (if (not (eq digs_left 0))       ; end recursion
      (let ((this-digit (/ score digs_left)))
	(put_image x y (aref nums this-digit))
	(show_score (+ x (image_width (aref nums this-digit))) y
		    (/ digs_left 10) (- score (* digs_left this-digit))))))

(defun paddle_draw ()
  (draw)                          ; normal draw function
  (show_score (- (view_x2) 80) (view_y1) 1000000 score))

(defun add_score (amount)
  (perm-space)     ; we are modifing a global var, so we need swith to perm space
  (setq score (+ score amount))
  (tmp-space))     ; switch back to tmp space which is not garbage collected


(defun destroyable_tile (x) (> x 1))

(defun blow_up_tile (tilex tiley)
  (let ((gamex (+ (* tilex 16) 8))
	(gamey   (+ (* tiley 7) 7)))
    (add_score 200)
    (add_object EXPLOSION gamex gamey)
    (destroy_tile tilex tiley)))

(defun destroy_tile (tilex tiley)
  (let ((gamex (+ (* tilex 16) 8))
	(gamey   (+ (* tiley 7) 7))
	(type (fg_tile tilex tiley)))
    (add_score 100)
    (set_fg_tile tilex tiley 0)            ; clear the tile and start animation
    (if (eq type 6)                        ; dinamite tile?
	(progn
	  (blow_up_tile tilex tiley)
	  (if (and (> tilex 0))
	      (blow_up_tile (- tilex 1) tiley))
	  (if (and (> tiley 0))
	      (blow_up_tile tilex (- tiley 1)))
	  (blow_up_tile tilex (+ tiley 1))
	  (blow_up_tile (+ tilex 1) tiley)))

    (with_object (bg) (add_hp 10))           ; give player points

    (add_object TILE_BLOW_UP gamex gamey)
    (if (eq (random 10) 0)
	(add_object PILL1 gamex gamey)
      (if (eq (random 30) 0)
	  (add_object PILL2 gamex gamey)))))


(defun check_collide (status)    ;; returns T if we hit something
  (if (not (eq status T))                                  ; did we hit anything?
      (if (eq (car (cdr status)) 'object)                  ; did we hit an object?
	  (let ((object (car (cdr (cdr status)))))
	    (if (eq (with_object object (otype)) PADDLE)   ; did we hit the paddle?
		(if (<= (aistate) 180)
		    (progn
		      (set_aistate (+ (aistate) (- (with_object object (x)) (x))))
		      (if (> 20 (aistate)) (set_aistate 20)
			(if (< 160 (aistate)) (set_aistate 160)))
		      T)
		  nil)
	      nil)
	    nil)
	(if (eq (car (cdr status)) 'tile)                   ; did we hit a tile?
	    (let ((tilex (car (cdr (cdr status))))
		  (tiley (car (cdr (cdr (cdr status))))))
	      (let ((type (fg_tile tilex tiley)))
	      (if (destroyable_tile type)                   ; can we destroy the tile?
		  (progn
		    (destroy_tile tilex tiley)
		    (if (eq type 6)
			(play_sound BLOWUP 100)
		      (play_sound BHIT)))
		(play_sound METAL 60)))
	      T)
	  nil))
    nil))


(defun move_ball ()  ;; returns status of move
  (let ((status (float_tick)))
    (if (not (eq status T))   ; T means we did not hit anything
	(let ((block_flags (car status)))
	  (if (or (blocked_left block_flags) (blocked_right block_flags)) ; bounce left/right
	      (if (<= (aistate) 180)
		  (set_aistate (- 180 (aistate)))
		(set_aistate (+ 180 (- 360 (aistate))))))
	  (if (or (blocked_up block_flags) (blocked_down block_flags))    ; bounce up/down
	      (progn
		(if (<= (aistate) 180)
		    (set_aistate (mod (+ (- 180 (aistate)) 180) 360))
		  (set_aistate (- 360 (aistate))))
		))
	  (if (not (eq block_flags 0))       ; move the ball one tick, because we just bounced
	      (progn
		(set_course (aistate) 7)
		(float_tick)))))
    status))


(defun ball_ai ()
  (set_course (aistate) 7)
  (select (aitype)
	  (0  ; normal play, bounce around and stuff..
	   (check_collide (move_ball))
	   (if (> (y) 240)  ; check to see if we are dead
	       (progn
		 (if (> score 500)
		     (add_score -500))
		 (if (find_closest BALL)  ; don't regenerate if other balls exsist
		     nil
		   (progn
		     (set_aistate 90)        ; reset ball to 90 degree angle
		     (set_fade_count 15)
		     (set_aitype 1)
		     T)))
	     T))

	   (1 ; ball is dead - go to paddle and fade in
	    (set_x (with_object (bg) (x)))
	    (set_y (- (with_object (bg) (y)) 14))
	    (set_fade_count (- (fade_count) 1))
	    (if (eq (fade_count) 0)
		(set_aitype 0))
	    T)))


(def_char BALL
  (funs (ai_fun ball_ai))
  (flags (hurt_all  T))
  (range 100 100)                 ; make sure ball doesn't stop when off screen
  (states pong_art (stopped "ball")))

(defun paddle_mover (xm ym but)     ; passed in player input, should return "block" status
                                    ; a "move" function is called from the "ai" function
                                    ; by (move x y b), however in this case there is no ai fun, so
                                    ; we can return 0 for block status sinse it is ignored
  (set_gravity 0)
  (set_shift_down (me) 80)
  (set_shift_right (me) (- 0 (x)))   ; adjust screen shift so it doesn't scroll
  (if (> fire_delay 0)
      (setq fire_delay (- fire_delay 1))
    (if (> shooting_time 0)
	(progn
	  (add_object MISSLE (x) (- (y) 20))
	  (setq fire_delay 5)
	  (setq shooting_time (- shooting_time 1)))))

  (if (or (and (< xm 0) (> (x) 20)) (and (> xm 0) (< (x) 300)))
      (mover xm 0 0)
    0))


(def_char PADDLE
  (vars shooting_time fire_delay)
  (funs (move_fun paddle_mover)    ; move fun get's passed the player input and responsible for calling ai_fun
	(draw_fun paddle_draw))
  (abilities (walk_top_speed 8)
	     (start_accel 8))
  (flags (can_block T))
  (states pong_art (stopped  "big_paddle")))

(defun do_nothing () T)

(def_char START
  (funs (draw_fun dev_draw)   ; dev draw is a compiled fun
	(ai_fun do_nothing))  ; always return T, therefore it never "dies"
  (states pong_art (stopped "start")))


(def_char TILE_BLOW_UP
  (funs (ai_fun block_ai))
  (states pong_art (stopped (seq "block_die" 1 9))))

(defun pill1_ai ()
  (set_y (+ (y) 3))
  (next_picture)
  (if (touching_bg)  ; are we touching the paddle
      (progn
	(add_score 1000)
	(with_object (add_object BALL (x) (y) 1) (progn (set_fade_count 15) (set_aistate 80)))
	nil)
    (> 240 (y))))

(defun pill2_ai ()
  (set_y (+ (y) 3))
  (next_picture)
  (if (touching_bg)  ; are we touching the paddle?
      (progn
	(add_score 300)
	(with_object (bg) (setq shooting_time 20))   ; give 'em a 20 ticks of fire power
	nil)
    (> 240 (y))))


(def_char PILL1  ; the extra ball pill
  (funs (ai_fun pill1_ai))
  (states pong_art (stopped (seq "pill" 1 24))))

(def_char PILL2  ; the extra ball pill
  (funs (ai_fun pill2_ai))
  (states pong_art (stopped (seq "pill2" 1 24))))

(defun missle_ai ()
  (set_course 90 10)
  (not (check_collide (move_ball))))


(def_char MISSLE
  (funs (ai_fun missle_ai))
  (states pong_art  (stopped "missle")))

(defun block_ai () (next_picture))

(def_char EXPLOSION
  (funs (ai_fun block_ai))
  (states pong_art (stopped (seq "exp" 1 10))))


(setq current_level 1)
(defun get_level_name (num)
  (concatenate 'string pong_dir "pong" (digstr num 2) ".lvl"))

(create_players PADDLE)
(set_first_level (get_level_name current_level))
(gc)    ; garbage collect
(tmp-space)

