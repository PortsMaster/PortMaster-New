;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


;; Ant
(def_char REDANT
  (vars in_climbing_area
	disable_top_draw
	just_hit
	ship_pan_x
	special_power
	used_special_power
	last1_x last1_y
	last2_x last2_y
	has_saved_this_level
	r_ramp g_ramp b_ramp
	is_teleporting
	just_fired
	has_compass
	)
  (range 50 50)
  (abilities (walk_top_speed    6)
	     (jump_yvel        -7)
	     (run_top_speed    15)
	     (jump_top_speed   30)
	     (jump_xvel        20)
	     (stop_accel        9)
	     (start_accel       8)
	     (start_hp        100)
	     (hamper_xrange    80)
	     (push_xrange       9))

  (flags     (hurtable          nil)
	     (unlistable        T))

  (funs (move_fun           cop_mover)
	(damage_fun         bottom_damage)
	(draw_fun           bottom_draw)
	(map_draw_fun       compass_draw)
	(get_cache_list_fun cop_cache)
	(user_fun           cop_ufun))

  (states "art/ant.spe"
          (stopped            "awlk0001.pcx")
	  (running            (seq "awlk" 1 10))

	  (fast_running       (seq "awlk" 1 10))
	  (fly_running        (seq "awlk" 1 10))

	  (fast_stopped       "awlk0001.pcx")
	  (fly_stopped        "awlk0001.pcx")

	  (dead               "hidden")

	  (start_run_jump     "acff0001.pcx")
	  (run_jump           "dive")
	  (run_jump_fall      "dive")
	  (end_run_jump       (seq "acff" 1 4))

	  (fly_start_run_jump     "acff0001.pcx")
	  (fly_run_jump           "dive")
	  (fly_run_jump_fall      "dive")
	  (fly_end_run_jump       (seq "acff" 1 4))

	  (fast_start_run_jump     "acff0001.pcx")
	  (fast_run_jump           "dive")
	  (fast_run_jump_fall      "dive")
	  (fast_end_run_jump       (seq "acff" 1 4))


	  (flinch_up           (rep "afh10001.pcx" 2))
	  (flinch_down         (rep "afh20001.pcx" 2))

	  (climbing             (seq "awlk" 1 10))
	  (climb_off            (seq "awlk" 1 8))
	  (climb_on             (seq "awlk" 8 1))
	  ))


;; Who
(def_char RAIDER
  (vars in_climbing_area
	disable_top_draw
	just_hit
	ship_pan_x
	special_power
	used_special_power
	last1_x last1_y
	last2_x last2_y
	has_saved_this_level
	r_ramp g_ramp b_ramp
	is_teleporting
	just_fired
	has_compass
	)
  (range 50 50)
  (abilities (walk_top_speed    9)
	     (jump_yvel       -25)
	     (run_top_speed    36)
	     (jump_top_speed   30)
	     (jump_xvel        27)
	     (stop_accel       27)
	     (start_accel      24)
	     (start_hp        100)
	     (hamper_xrange    80)
	     (push_xrange       9))

  (flags     (hurtable          T)
	     (unlistable        T))

  (funs (move_fun           cop_mover)
	(damage_fun         bottom_damage)
	(draw_fun           bottom_draw)
	(map_draw_fun       compass_draw)
	(get_cache_list_fun cop_cache)
	(user_fun           cop_ufun))

  (states "addon/twist/art/robs.spe"
          (stopped            (seq "wgo" 1 3))
	  (running            (seq "wgo" 1 3))

	  (fast_running       (seq "wgo" 1 3))
	  (fly_running        (seq "wgo" 1 3))

	  (fast_stopped       (seq "wgo" 1 3))
	  (fly_stopped        (seq "wgo" 1 3))

	  (dead               "flinch")

	  (start_run_jump     (seq "wgo" 1 3))
	  (run_jump           (seq "wgo" 1 3))
	  (run_jump_fall      (seq "wgo" 1 3))
	  (end_run_jump       (seq "wgo" 1 3))

	  (fly_start_run_jump     (seq "wgo" 1 3))
	  (fly_run_jump           (seq "wgo" 1 3))
	  (fly_run_jump_fall      (seq "wgo" 1 3))
	  (fly_end_run_jump       (seq "wgo" 1 3))

	  (fast_start_run_jump     (seq "wgo" 1 3))
	  (fast_run_jump           (seq "wgo" 1 3))
	  (fast_run_jump_fall      (seq "wgo" 1 3))
	  (fast_end_run_jump       (seq "wgo" 1 3))


	  (flinch_up           '("flinch" "flinch" "flinch"))
	  (flinch_down         '("flinch" "flinch" "flinch"))

	  (climbing             (seq "wtrn" 1 9))
	  (climb_off            (seq "wtrn" 1 8))
	  (climb_on             (seq "wtrn" 8 1))
	  ))


;; Rob1
(def_char BLADES
  (vars in_climbing_area
	disable_top_draw
	just_hit
	ship_pan_x
	special_power
	used_special_power
	last1_x last1_y
	last2_x last2_y
	has_saved_this_level
	r_ramp g_ramp b_ramp
	is_teleporting
	just_fired
	has_compass
	)
  (range 50 50)
  (abilities (walk_top_speed    3)
	     (jump_yvel         0)
	     (run_top_speed     6)
	     (jump_top_speed   40)
	     (jump_xvel        27)
	     (stop_accel        9)
	     (start_accel       8)
	     (start_hp        100)
	     (hamper_xrange    80)
	     (push_xrange       9))

  (flags     (hurtable          T)
	     (unlistable        T))

  (funs (move_fun           cop_mover)
	(damage_fun         bottom_damage)
	(draw_fun           bottom_draw)
	(map_draw_fun       compass_draw)
	(get_cache_list_fun cop_cache)
	(user_fun           cop_ufun))

  (states "addon/twist/art/robs.spe"
          (stopped            (seq "clen" 1 10))
	  (running            (seq "clen" 1 10))

	  (fast_running       (seq "clen" 1 10))
	  (fly_running        (seq "clen" 1 10))

	  (fast_stopped       (seq "clen" 1 10))
	  (fly_stopped        (seq "clen" 1 10))

	  (dead               (seq "clen" 1 10))

	  (start_run_jump     (seq "clen" 1 10))
	  (run_jump           (seq "clen" 1 10))
	  (run_jump_fall      (seq "clen" 1 10))
	  (end_run_jump       (seq "clen" 1 10))

	  (fly_start_run_jump     (seq "clen" 1 10))
	  (fly_run_jump           (seq "clen" 1 10))
	  (fly_run_jump_fall      (seq "clen" 1 10))
	  (fly_end_run_jump       (seq "clen" 1 10))

	  (fast_start_run_jump     (seq "clen" 1 10))
	  (fast_run_jump           (seq "clen" 1 10))
	  (fast_run_jump_fall      (seq "clen" 1 10))
	  (fast_end_run_jump       (seq "clen" 1 10))


	  (flinch_up           (seq "clen" 1 10))
	  (flinch_down         (seq "clen" 1 10))

	  (climbing             (seq "clen" 1 10))
	  (climb_off            (seq "clen" 1 8))
	  (climb_on             (seq "clen" 8 1))
	  ))


;; JUGGER
(def_char JUGGERMAN
  (vars in_climbing_area
	disable_top_draw
	just_hit
	ship_pan_x
	special_power
	used_special_power
	last1_x last1_y
	last2_x last2_y
	has_saved_this_level
	r_ramp g_ramp b_ramp
	is_teleporting
	just_fired
	has_compass
	)
  (range 50 50)
  (abilities (walk_top_speed    3)
	     (jump_yvel       -10)
	     (run_top_speed     2)
	     (jump_top_speed    3)
	     (jump_xvel         3)
	     (stop_accel        9)
	     (start_accel       8)
	     (start_hp        200)
	     (hamper_xrange    80)
	     (push_xrange       9))

  (flags     (hurtable          T)
	     (unlistable        T))

  (funs (move_fun           cop_mover)
	(damage_fun         bottom_damage)
	(draw_fun           bottom_draw)
	(map_draw_fun       compass_draw)
	(get_cache_list_fun cop_cache)
	(user_fun           cop_ufun))

  (states "art/jug.spe"
          (stopped            "robo0001.pcx")
	  (running            (seq "rwlk" 1 13))

	  (fast_running       (seq "rwlk" 1 13))
	  (fly_running        (seq "rwlk" 1 13))

	  (fast_stopped       "robo0001.pcx")
	  (fly_stopped        "robo0001.pcx")

	  (dead               "jugdie0001.pcx")

	  (start_run_jump     (seq "rwlk" 1 13))
	  (run_jump           (seq "rwlk" 1 13))
	  (run_jump_fall      (seq "rwlk" 1 13))
	  (end_run_jump       (seq "rwlk" 1 13))

	  (fly_start_run_jump     (seq "rwlk" 1 13))
	  (fly_run_jump           (seq "rwlk" 1 13))
	  (fly_run_jump_fall      (seq "rwlk" 1 13))
	  (fly_end_run_jump       (seq "rwlk" 1 13))

	  (fast_start_run_jump     (seq "rwlk" 1 13))
	  (fast_run_jump           (seq "rwlk" 1 13))
	  (fast_run_jump_fall      (seq "rwlk" 1 13))
	  (fast_end_run_jump       (seq "rwlk" 1 13))


	  (flinch_up           (seq "robo" 1 10))
	  (flinch_down         (seq "robo" 1 10))

	  (climbing             (seq "rwlk" 1 13))
	  (climb_off            (seq "rwlk" 1 8))
	  (climb_on             (seq "rwlk" 8 1))
	  ))

