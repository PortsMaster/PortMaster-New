;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights


(def_char MAN_LEGSANT
  (vars need_to_dodge
	no_see_time
	hide_flag)
  (fields
	  ("hide_flag"    ant_hide)
	  ("fade_count"   ai_fade)
	  ("aitype"       ai_type)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))
  (range 250 20)
  (draw_range 40 40)
  (funs (ai_fun     ant_ai)
	(draw_fun   man_draw)
	(constructor ant_cons)
	(type_change_fun ant_ct)
	(get_cache_list_fun ant_cache)
	(damage_fun ant_damage))

  (abilities (run_top_speed   7)
	     (start_hp       100)
	     (stop_acel      20)
	     (start_acel     20)
	     (jump_yvel      -4)
	     (jump_xvel      20)
	     (push_xrange     1)
	     (jump_top_speed 20))

  (flags (hurtable  T)
	 (force_health T))

  (states "art/cop.spe"
	  (hanging	(seq "stopped" 1 6))

	  (fall_start	"jump_down")
	  (falling	"jump_down")

	  (stopped	(seq "stopped" 1 6))
	  (running	(seq "4wlk" 1 10))
	  (landing	(seq "4jmp" 3 5))
	  (pounce_wait	"4jmp0004.pcx")
	  (turn_around	(seq "stopped" 1 6))

	  (run_jump		"jump_up")
	  (run_jump_fall	"jump_up")
	  (start_run_jump	"jump_up")
	  (fire_wait		(seq "stopped" 1 6))

	  (ceil_fire	"4flj0002.pcx")
	  (top_walk 	(seq "4flj" 2 3))
	  (flinch_up	(rep "jump_up" 2))
	  (flinch_down	(rep "jump_down" 2))
	  (blown_back_dead	"jump_up")
	  (jump_up		"jump_up")
	  (hiding		"dead")
	  (dead			"dead")
	  (weapon_fire		(seq "stopped" 1 6))))


(def_char MAN_LEGSJUG
  (range 200 0)
  (funs (ai_fun     jug_ai)
	(draw_fun   man_draw)
	(constructor jug_cons)
	(get_cache_list_fun explo_damage_cache)
	(damage_fun explo_damage))
  (flags (hurtable T))
  (abilities (start_hp   100)
	     (push_xrange 1))
  (vars throw_xvel throw_yvel stationary)
  (fields ("hp"            ai_health)
	  ("aitype"        jug_throw_spd)
	  ("throw_xvel"    jug_throw_xv)
	  ("throw_yvel"    jug_throw_yv)
	  ("stationary"    jug_stat)
	  ("aistate"       ai_state))

  (states "addon/twist/art/legs.spe"
	  (stopped	(seq "stopped" 1 6))
	  (running	(seq "4wlk" 1 10))
	  (weapon_fire	(seq "stopped" 1 6))
	  (dieing	"dead")))


(def_char MAN_LEGSFLY
  (funs (ai_fun flyer_ai)
	(draw_fun   man_draw)
	(damage_fun  flyer_damage)
	(constructor flyer_cons))

  (flags (hurtable T))
  (abilities (start_hp 100))
  (vars fire_delay burst_delay burst_total burst_wait burst_left
	max_xvel   max_yvel    smoke_time fire_time)
  (fields ("fire_delay"  who_fdelay)
	  ("burst_delay" who_bdelay)
	  ("burst_total" who_btotal)
	  ("max_xvel"    who_mxv)
	  ("max_yvel"    who_myv)
	  ("hp"          ai_health)
	  ("aitype"      ai_type)
	  ("aistate"     ai_state))

  (range 200 200)
  (states "art/cop.spe"
	  (running	"4flj0002.pcx")
	  (stopped	"4flj0003.pcx")
	  (flinch_up	'("4flj0004.pcx" "4flj0004.pcx" "4flj0005.pcx" "4flj0005.pcx"))
	  (turn_around	"4flj0003.pcx")))


(def_char MAN_BODYTRACK
  (vars
	fire_delay
	fire_delay_left
        track_speed
	burst_total
	burst_total_left
	continue_time
	continue_time_left
	track_start_angle
	track_end_angle
	angle)

  (funs (ai_fun      mantrack_ai)
	(constructor track_cons)
	(draw_fun    man_draw)
	(damage_fun   guner_damage))

  (flags (can_block  T)
	 (hurtable   T))

  (abilities (start_hp 100))

  (fields ("hp"                ai_health)
	  ("aitype"            ai_type)
	  ("track_speed"       d_track_speed)
	  ("fire_delay"        track_fspeed)
	  ("burst_total"       track_burst)
	  ("continue_time"     track_cont)
	  ("track_start_angle" track_sangle)
	  ("track_end_angle"   track_eangle)
	  ("angle"             track_cangle))

  (states "art/coptop.spe"
	  (stopped  "4gbf0001.pcx")
	  (opening  '("4gbf0001.pcx" "4gbf0002.pcx"))
	  (shuting  '("4gbf0002.pcx" "4gbf0001.pcx"))
	  (spinning (seq "4gbf" 1 24))
	  (firing   (seq "4gbf" 1 24))))


(def_char MAN_BODYSPRAY
  (funs (ai_fun       manspray_ai)
	(damage_fun   guner_damage)
	(draw_fun     man_draw)
	(constructor spray_gun_cons))

  (flags (can_block  T)
	 (hurtable   T))
  (abilities (start_hp 100)
	     )
  (vars spray.fire_delay
	spray.bullet_speed
	spray.start_angle
	spray.end_angle
	spray.angle_speed
	spray.angle)

  (fields ("hp"                 ai_health)
	  ("aitype"             ai_type)
	  ("spray.fire_delay"   spray_delay)
	  ("spray.start_angle"  spray_start)
	  ("spray.end_angle"    spray_end)
	  ("spray.angle_speed"  spray_speed)
	  ("spray.angle"        spray_cangle))

  (states "art/coptop.spe"
	  (stopped           "4gbf0001.pcx")
	  (spray.aim         (seq "4gbf" 1 24))
	  (spray.appear      '("4gbf0001.pcx" "4gbf0002.pcx"))
	  (spray.disappear   '("4gbf0002.pcx" "4gbf0001.pcx"))
	  ))


(def_char LAVA_COLOR
  (funs (ai_fun lava_ai)
	(draw_fun gun_draw))
  (states  "art/chars/lava.spe"
	   (stopped (seq "lava" 1 15))))


(def_char LAVA_SPLASH
  (funs (ai_fun fire_ai)
	(draw_fun   gun_draw))
  (states  "addon/twist/art/lavap.spe"
	   (stopped '("part-2" "part-3" "part-4" "part-5" "part-6"
		      "part-7" "part-8" "part-9" "part-10" "part-11"
		      "part-12" "part-13" "part-14" "part-15" "part-16"))))


(def_char FIRE
  (funs (ai_fun fire_ai)
	(draw_fun   gun_draw))
  (states  "addon/twist/art/fire.spe"
	   (stopped (seq "f" 1 33))))


(def_char OBJ_FORCE
  (funs (ai_fun forceobj_ai)
	(constructor forceobj_cons)
	(draw_fun dev_draw))
  (fields ("xacel"	"x force")
	  ("yacel"	"y force"))
  (states "addon/twist/art/obj.spe"
	  (stopped "force")))


(def_char OBJ_CHEAT
  (range 100 100)
  (funs (ai_fun      csensor_ai)
	(draw_fun dev_draw))
  (fields ("xvel"	"x dist")
	  ("aistate"	"state"))
  (states "addon/twist/art/obj.spe"
	  (stopped "cheat")))


(def_explo 'EXPFIRE "addon/twist/art/fire.spe"    "f"         33)


(def_char SENSOR_MUSIC
  (range 100 100)
  (funs (ai_fun      msensor_ai)
	(draw_fun    music_sensor_draw)
	(constructor msensor_cons))
  (fields ("xvel"      "x dist")
	  ("yvel"       "y dist")
	  ("aitype"     "next song"))
  (states "addon/twist/art/obj.spe"
	  (stopped "music")))


(def_char SENSOR_GRAVITY
  (range 100 100)
  (funs (ai_fun      gsensor_ai)
	(draw_fun    gravity_sensor_draw)
	(constructor gsensor_cons))
  (fields ("xvel"	"x dist")
	  ("yvel"	"y dist")
	  ("xacel"	"x gravity")
	  ("yacel"	"y gravity"))
  (states "addon/twist/art/obj.spe"
	  (stopped "gravity")))


(def_char SENSOR_HEALTH
  (range 100 100)
  (funs (ai_fun      hsensor_ai)
	(draw_fun    health_sensor_draw)
	(constructor hsensor_cons))
  (fields ("xvel"	"x dist")
	  ("yvel"	"y dist")
	  ("aitype"	"0=player,1=player+enemy,2=explo")
	  ("xacel"	"subtract health"))
  (states "addon/twist/art/obj.spe"
	  (stopped "health")))


(def_char SENSOR_LEVEL
  (range 100 100)
  (funs (ai_fun      lsensor_ai)
	(draw_fun    level_sensor_draw)
	(constructor lsensor_cons))
  (fields ("xvel"	"x dist")
	  ("yvel"	"y dist")
	  ("xacel"	"next level")
	  ("yacel"	"level section")
	  ("aistate"	"end of game? 0=n,1=y")
	  ("aitype"	"show stats? 0=n,1=y"))
  (states "addon/twist/art/obj.spe"
	  (stopped "level")))


(def_char SENSOR_TELEPORT
  (range 100 100)
  (funs (ai_fun      telesensor_ai)
	(draw_fun    teleport_sensor_draw)
	(constructor telesensor_cons))
  (fields ("xvel"	"x dist")
	  ("yvel"	"y dist")
	  ("aitype"	"require action key? 0=n,1=y"))
  (states "addon/twist/art/obj.spe"
	  (stopped "teleport")
	  (running "teleport")))


(def_char WALK_ROBHEAD
  (funs (ai_fun flyer_ai)
	(damage_fun  flyer_damage)
	(constructor flyer_cons))

  (flags (hurtable T))
  (abilities (start_hp 40))
  (vars fire_delay burst_delay burst_total burst_wait burst_left
	max_xvel   max_yvel    smoke_time fire_time)
  (fields ("fire_delay"  who_fdelay)
	  ("burst_delay" who_bdelay)
	  ("burst_total" who_btotal)
	  ("max_xvel"    who_mxv)
	  ("max_yvel"    who_myv)
	  ("hp"          ai_health)
	  ("aitype"      ai_type)
	  ("aistate"     ai_state))

  (range 200 200)
  (states "addon/twist/art/robs.spe"
	  (running	"wflyer")
	  (stopped	"wflyer")
	  (flinch_up	'("wfflinch" "wfflinch" "wfflinch"))
	  (turn_around	"wflyer")))


(def_char WALK_ROB
  (funs (ai_fun wrob_ai)
	(constructor wrob_cons)
	(damage_fun  guner_damage))
  (abilities (run_top_speed 12)
	     (start_hp 60))
  (flags (hurtable T))
  (range 300 100)
  (vars fire_delay burst_delay burst_total burst_wait burst_left
	max_xvel   max_yvel    smoke_time fire_time)
  (fields ("fire_delay"   wrob_fdelay)
	  ("burst_delay"  wrob_bdelay)
	  ("burst_total"  wrob_btotal)
	  ("max_xvel"     wrob_mxv)
	  ("max_yvel"     wrob_myv)
	  ("hp"           ai_health)
	  ("aistate"      ai_state))

  (states "art/rob2.spe"
	  (stopped "wwlk0001.pcx")
	  (running (seq "wwlk" 1 10))
	  (start_run_jump "wstart_jump")
	  (flinch_up      "wflinch")
	  (run_jump       "wwlk0009.pcx")
	  ))

