;; Copyright 1999 Profound Corp,  All Rights reserved
;; See licensing information for more details on usage rights

(def_char OBJ_FORCE
  (funs (ai_fun forceobj_ai)
	(constructor forceobj_cons)
	(draw_fun dev_draw))
  (fields ("xacel"	"x force")
	  ("yacel"	"y force"))
  (states "addon/twist/art/obj.spe"
	  (stopped "force")))

(def_explo 'EXPFIRE "addon/twist/art/fire.spe"    "f"         33)

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


(def_char WALK_ROB2
  (funs (ai_fun wrob2_ai)
	(constructor wrob2_cons)
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

