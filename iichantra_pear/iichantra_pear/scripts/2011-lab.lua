require("iichantra-dialogues")

InitNewGame();

mapvar.tmp = {}

mapvar.char = {}
--mapvar.char.SOH = 2

CONFIG.backcolor_r = 67/255;
CONFIG.backcolor_g = 153/255;
CONFIG.backcolor_b = 153/255;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-lab.lua" );

GroupObjects( CreateEnvironment("snow", 74, 40), CreateEnvironment("snow", 1245, 98) )

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-2395, 1248, -9000, 1394)
CamMoveToPos( 671, -12 )
FadeOut( {0, 0, 0}, 0 )

function init_lab( visit )
	--stat.lab_visits = visit
	mapvar.lab_visits = visit
	if visit == 1 then
		dialogues.ny[2].lines["ROOT"].nextline = 1
		dialogues.ny[4].lines["ROOT"].nextline = 1
		dialogues.ny[6].lines[1].nextline = 2
		mapvar.tmp.dl = { dialogues.ny[2], dialogues.ny[3], dialogues.ny[4], dialogues.ny[5], dialogues.ny[6], dialogues.ny[7], dialogues.ny[8], dialogues.ny[9] }
		mapvar.tmp.dl[0] = dialogues.ny[1]
		mapvar.tmp.dl[-1] = "2011DIntro1"
	elseif visit == 2 then
		mapvar.tmp.spoke_to_guard = true
		mapvar.tmp.dl = { dialogues.ny[11], _, dialogues.ny[12], dialogues.ny[13], dialogues.ny[14], dialogues.ny[15], dialogues.ny[16], dialogues.ny[9] }
		mapvar.tmp.dl[0] = dialogues.ny[10]
		mapvar.tmp.dl[-1] = "2011DIntro5"
	elseif visit == 3 then
		mapvar.tmp.spoke_to_guard = true
		mapvar.tmp.dl = { dialogues.ny[24], _, dialogues.ny[25], dialogues.ny[26], dialogues.ny[27], dialogues.ny[28], dialogues.ny[29], dialogues.ny[9] }
		mapvar.tmp.dl[0] = dialogues.ny[30]
		mapvar.tmp.dl[-1] = "2011DIntro6"
	elseif visit == 4 then
		PlayBackMusic("music/iie_street.it")
		mapvar.tmp.spoke_to_guard = true
		mapvar.tmp.dl = { dialogues.ny[41], _, dialogues.ny[42], dialogues.ny[43], dialogues.ny[44], dialogues.ny[45], dialogues.ny[46], dialogues.ny[9] }
		mapvar.tmp.dl[0] = dialogues.ny[47]
		mapvar.tmp.dl[-1] = "2011DIntro7"
	end
end

function CreatePlatform( platform, coords, loop )
	local wpsize = 16
	local first = CreateWaypoint( coords[1][1], coords[1][2], wpsize, wpsize )
	local second = CreateWaypoint( coords[2][1], coords[2][2], wpsize, wpsize )
	SetNextWaypoint( first, second )
	local last = second
	local now = 0
	for i=3, #coords do
		now = CreateWaypoint( coords[i][1], coords[i][2], wpsize, wpsize )
		SetNextWaypoint( last, now )
		last = now
	end
	if loop then
		SetNextWaypoint( last, first )
	else
		for i=#coords-1,2,-1 do
			now = CreateWaypoint( coords[i][1], coords[i][2], wpsize, wpsize )
			SetNextWaypoint( last, now )
			last = now
		end
		SetNextWaypoint( last, first )
	end
	SetEnemyWaypoint( CreateEnemy(platform, coords[1][1], coords[1][2]), second )
end

CreatePlatform( "2011-fp", { {-922, 288}, {-922, 648} }, true )
CreatePlatform( "2011-fp", { {-1441, 698}, {-1441, 1038} }, true )
local en = CreateEnemy( "guard", -579, 656 )
SetObjAnim( en, "turn_left", false )
en = CreateEnemy( "guard", -1104, 1061 )
SetObjAnim( en, "turn_left", false )

local trigger = CreateItem("generic-death-area", -1049, 1396)
GroupObjects( trigger, CreateItem("generic-death-area", -795, 2000) )

if not mapvar.tmp then mapvar.tmp = {} end
mapvar.tmp.introed = false

----------------------------------------------------------------------------------------------
function intro( player )
	if mapvar.lab_visits < 4 then
		PlayBackMusic( "music/nsmpr_lab.it" )
	end

	SetObjPos( player.id, 1180, -17 )
	EnablePlayerControl( false )

	CamMoveToPos( 671, -12 )
		
	LetterBox( true )
	FadeIn( 2000 )

	for i=1,100 do
		CamMoveToPos( math.floor(671-i*300/100), -12 )
		Wait(1)
	end

	local label = CreateWidget(constants.wt_Label, "Label1", nil, CONFIG.scr_width-250, CONFIG.scr_height-50, 200, 10)
	WidgetSetBorder(label, false)
	WidgetSetCaptionColor(label, {162/255,208/255,92/255,1}, false)
	
	WidgetSetCaption(label, dictionary_string(mapvar.tmp.dl[-1]), true)
	WidgetUseTyper(label, true, 20, false)
	WidgetSetOnTyperEndedProc(label, function () AddTimerEvent(3000, function () DestroyWidget(label) end ) end)
	WidgetStartTyper(label);

	Wait( 4000 )
	

	SetDynObjVel( player.id, -2.25, 0 )
	SetDynObjAcc( player.id, -2.25, 0 )
	SetObjAnim( player.id, "walk", false )

	player = GetPlayer()
	while player.aabb.p.x > 371 do
		player = GetPlayer()
		Wait(1)
	end

	SetDynObjVel( player.id, 0, 0 )
	SetDynObjAcc( player.id, 0, 0 )

	Wait(500)

	mapvar.tmp.dl[0]:start()
end

function guard_entrance1()
	EnablePlayerControl( false )
	mapvar.tmp.dl[1]:start()	
end

function guard_entrance2()
	if not mapvar.tmp.spoke_to_guard then
		EnablePlayerControl( false )
		mapvar.tmp.dl[2]:start()	
	end
end

function guard_door1()
	EnablePlayerControl( false )
	mapvar.tmp.dl[3]:start()	
end

function guard_door2()
	EnablePlayerControl( false )
	mapvar.tmp.dl[4]:start()	
end

function guard_professor()
	EnablePlayerControl( false )
	mapvar.tmp.dl[5]:start()	
end

function guard_elsewhere()
	EnablePlayerControl( false )
	mapvar.tmp.dl[6]:start()	
end

function professor()
	EnablePlayerControl( false )
	mapvar.tmp.dl[7]:start()	
end

function bike()
	EnablePlayerControl( false )
	GUI:hide()
	dialogues.ny[58]:start()
end

function door_baka()
	if mapvar.lab_visits == 4 then
		Menu.showEndLevelMenu( "2011-btardis" )
	else
		SetObjAnim( CreateSprite( "2011labscreen", -658, 559 ), "fail", false )
		EnablePlayerControl( false )
		mapvar.tmp.dl[8]:start()
	end
end

function door1()
	SetObjAnim( CreateSprite( "2011labscreen", -2191, 555 ), "denied", false )
end

function show_effect_talk(id)
	--Log("show_effect_talk")
	local pl = GetPlayer()
	if id == pl.id then
		if ( mapvar.tmp.effect ) then hide_effect(id, 0, 0, 1, 0) end
		mapvar.tmp.effect = CreateEffect("dialogue", pl.aabb.p.x, pl.aabb.p.x-50, id, 1)
	end
end

function show_effect_walk(id)
	--Log("show_effect_walk")
	local pl = GetPlayer()
	if id == pl.id then
		if ( mapvar.tmp.effect ) then hide_effect(id, 0, 0, 1, 0) end
		mapvar.tmp.effect = CreateEffect("movement", pl.aabb.p.x, pl.aabb.p.x-50, id, 1)
	end
end

function hide_effect(id, x, y, old_material, new_material)
	--Log("hide_effect", id, " ", x," ", y," ", old_material," ", new_material)
	--[[
	if new_material == old_material then
		return
	end
	--]]
	local pl = GetPlayer()
	if id == pl.id and mapvar.tmp.effect then
		SetObjDead( mapvar.tmp.effect )
		mapvar.tmp.effect = nil
	end
end

function hold_it(id)
	if id == GetPlayer().id then
		if mapvar.tmp.to_tutorial then return end
		Resume( NewMapThread( function()
			EnablePlayerControl( false )
			SetDynObjAcc( id, 5, 0 )
			while GetPlayer().aabb.p.x < -2170 do
				Wait(1)
			end
			SetDynObjAcc( id, 0, 0 )
			SetDynObjVel( id, 0, 0 )
			SetObjAnim( id, "stop", false )
			push_pause(true)
			GUI:hide()
			dialogues.ny[54]:start()
		end ) )
	end
end

local env = CreateEnvironment("default_environment", 29, -73)
GroupObjects( env, CreateEnvironment( "default_environment", 77, 42 ) )
SetEnvironmentStats( env, { on_use = "guard_entrance1", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2 } )

env = CreateEnvironment("default_environment", -140, -9000)
GroupObjects( env, CreateEnvironment( "default_environment", -126, 9000 ) )
SetEnvironmentStats( env, { on_enter = "guard_entrance2" } )

env = CreateEnvironment("default_environment", -717, 590)
GroupObjects( env, CreateEnvironment( "default_environment", -686, 695 ) )
SetEnvironmentStats( env, { on_use = "guard_door1", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2  } )

env = CreateEnvironment("default_environment", -610, 591)
GroupObjects( env, CreateEnvironment( "default_environment", -571, 693 ) )
SetEnvironmentStats( env, { on_use = "guard_door2", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2  } )

env = CreateEnvironment("default_environment", -1601, 588)
GroupObjects( env, CreateEnvironment( "default_environment", -1571, 697 ) )
SetEnvironmentStats( env, { on_use = "guard_professor", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2  } )

env = CreateEnvironment("default_environment", -1139, 1013)
GroupObjects( env, CreateEnvironment( "default_environment", -1098, 1103 ) )
SetEnvironmentStats( env, { on_use = "guard_elsewhere", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2  } )

env = CreateEnvironment("default_environment", -2058, 604)
GroupObjects( env, CreateEnvironment( "default_environment", -1951, 698 ) )
SetEnvironmentStats( env, { on_use = "professor", on_enter = "show_effect_talk", on_leave = "hide_effect", material = 2  } )

env = CreateEnvironment("default_environment", -652, 588)
GroupObjects( env, CreateEnvironment( "default_environment", -651, 691 ) )
SetEnvironmentStats( env, { on_use = "door_baka", on_enter = "show_effect_walk", on_leave = "hide_effect", material = 2 } )

env = CreateEnvironment("default_environment", -2204, 590)
GroupObjects( env, CreateEnvironment( "default_environment", -2151, 696 ) )
SetEnvironmentStats( env, { on_use = "door1", on_enter = "show_effect_walk", on_leave = "hide_effect", material = 2 } )

env = CreateEnvironment("default_environment", -2385, 525)
GroupObjects( env, CreateEnvironment( "default_environment", -2297, 724 ) )
SetEnvironmentStats( env, { on_enter = "hold_it"} )

env = CreateEnvironment("default_environment", 1006, -22)
GroupObjects( env, CreateEnvironment( "default_environment", 1080, 15 ) )
SetEnvironmentStats( env, { on_use = "bike", on_enter = "show_effect_walk", on_leave = "hide_effect", material = 2 } )

----------------------------------------------------------------------------------------------
init_lab( (stat.lab_visits or 0) + 1 )

local LEVEL = {}

function LEVEL.MapScript(player)
	if not mapvar.tmp.introed and Loader.time > 1 then
		mapvar.tmp.introed = true
		GUI:hide()
		--push_pause(true)
		Menu.locked = {true}
		FadeOut( {0, 0, 0}, 0 )
		Resume( NewThread(intro), player )
	end
end

function LEVEL.placeSecrets()
end

function LEVEL.removeSecrets()
end

function LEVEL.cleanUp()
	Weather.clean_slave_weather_proc(LEVEL)
end

function LEVEL.SetLoader(l)
	LEVEL.missionStarter = l
	
	Weather.set_slave_weather_proc(LEVEL, LEVEL.register_weather, LEVEL.create_weather)
	Weather.check_weather()
end

function LEVEL.register_weather( id, weather_id )
	AddParticleArea( weather_id, {82, -9000, 9000, 42}, 30 )
	AddParticleArea( weather_id, {-37, -9000, 82, -199}, 30 )
	AddParticleArea( weather_id, {-76, -9000, -37, -199}, 30 )
	AddParticleArea( weather_id, {-120, -9000, -76, -162}, 30 )
	AddParticleArea( weather_id, {-166, -9000, -120, -113}, 30 )
	AddParticleArea( weather_id, {-217, -9000, -166, -71}, 30 )
	AddParticleArea( weather_id, {-265, -9000, -217, -69}, 30 )
	AddParticleArea( weather_id, {-225, -9000, -265, -64}, 30 )
	AddParticleArea( weather_id, {-274, -9000, -225, -25}, 30 )
	AddParticleArea( weather_id, {-9000, -9000, -274, -19}, 30 )
	AddParticleArea( weather_id, {-23, -97, 82, 42}, 30 )
end

function LEVEL.create_weather()
	CreateSprite("weather-snow", 94, 8)
end


LEVEL.name = "SECRET LAB"

return LEVEL
