require("iichantra-dialogues")

SetCamLag(0)
StopBackMusic()

InitNewGame();

if not mapvar.tmp then
	mapvar.tmp = {}
end

mapvar.char = {}

CONFIG.backcolor_r = 67/255;
CONFIG.backcolor_g = 153/255;
CONFIG.backcolor_b = 153/255;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-cinematics.lua" );

GroupObjects( CreateEnvironment("snow", 74, 40), CreateEnvironment("snow", 1245, 98) )

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-2395, 1248, -9000, 1394)
CamMoveToPos( 671, -12 )
FadeOut( {0, 0, 0}, 0 )

function intro()
	Loader.game_timer_enabled = false
	LetterBox( true )
	PlayBackMusic( "music/nsmpr_import.it" )
	local fp = CreateSprite( "characters/sohchan-cinematic", 650, 4 )
	CamMoveToPos( 668, 0.5 )
	SetCamBounds(-2395, 1248, -9000, 113)
	FadeIn(2000)
	Wait(2000)
	dialogues.ny[17]:start()
	while not mapvar.tmp.dl1 do
		Wait(1)
	end
	local com = CreateEnemy( "btard-com-cinematic", 115, 0 )
	Wait(100)
	SetObjAnim( com, "move", false )
	local ocom = GetObject( com )
	while ocom.aabb.p.x < 590 do
		Wait(1)
		ocom = GetObject( com )
	end
	SetObjAnim( com, "attack", false )
	Wait( 400 )
	SetObjAnim( fp, "knockout", false )
	Wait( 1000 )
	FadeOut( {0, 0, 0}, 1000 )
	Wait( 1000 )
	CamMoveToPos( -1953, 650 )
	SetCamBounds(-2395, -1711, -9000, 1394)	
	local label = CreateWidget(constants.wt_Label, "Label1", nil, CONFIG.scr_width/2-100, CONFIG.scr_height/2-5, 200, 10)
	WidgetSetBorder(label, false)
	WidgetSetCaptionColor(label, {162/255,208/255,92/255,1}, false)
	WidgetSetCaption(label, dictionary_string("2011D162"), true)
	WidgetUseTyper(label, true, 20, false)
	WidgetSetOnTyperEndedProc(label, function () AddTimerEvent(3000, function () DestroyWidget(label) end ) end)
	WidgetStartTyper(label);
	Wait(3000)
	FadeIn(1000)
	PlayBackMusic( "music/nsmpr_lab.it" )
	Wait(1500)
	dialogues.ny[18]:start()
end

----------------------------------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	if not mapvar.tmp.introed and Loader.time > 1 then
		mapvar.tmp.introed = true
		GUI:hide()
		--push_pause(true)
		Menu.locked = true
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
