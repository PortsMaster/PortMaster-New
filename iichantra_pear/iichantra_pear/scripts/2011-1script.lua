InitNewGame();

if not mapvar.tmp then
	mapvar.tmp = {}
end

mapvar.char = {}
mapvar.char.SOH = 1

SetCamLag(0.9)

CONFIG.backcolor_r = 67/255;
CONFIG.backcolor_g = 153/255;
CONFIG.backcolor_b = 153/255;
LoadConfig();

local env = CreateEnvironment("snow", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-1.lua" );


SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

SetCamUseBounds(true)
SetCamBounds(-18, 13929, -9000, 152)
mapvar.tmp.bounds = 1

function map_trigger( id, trigger )
	if trigger == 1 and mapvar.tmp.bounds ~= 1 then
		SetCamBounds(-18, 13929, -9000, 152)
		mapvar.tmp.bounds = 1	
	elseif trigger == 2 and mapvar.tmp.bounds ~= 2 then
		SetCamBounds(-18, 13929, -9000, 206)
		mapvar.tmp.bounds = 2
	elseif trigger == 3 then
		SetObjDead( id )
		Menu.showEndLevelMenu("2011-troll")
	end
end

local trigger = CreateItem("generic-trigger", 5277, -553)
GroupObjects( trigger, CreateItem("generic-trigger", 5395, -148) )
ObjectPushInt( trigger, 1 )
trigger = CreateItem("generic-trigger", 5692, -553)
GroupObjects( trigger, CreateItem("generic-trigger", 5895, -148) )
ObjectPushInt( trigger, 2 )
trigger = CreateItem("generic-trigger", 13835, -60)
GroupObjects( trigger, CreateItem("generic-trigger", 13900, 54) )
ObjectPushInt( trigger, 3 )

trigger = CreateItem("generic-death-area", -9000, 206)
GroupObjects( trigger, CreateItem("generic-death-area", 90000, 666) )

local limit = CreateSprite("phys-empty", -28, -1000 )
GroupObjects( limit, CreateSprite("phys-empty", -18, 1000 ) )
SetObjSolidToByte( limit, 1 )
mapvar.tmp.area_limits = limit
mapvar.tmp.introed = false

StopBackMusic()

FadeOut({0,0,0,1}, 0)
--13835 -60 1390 54
----------------------------------------------------------------------------------------------
local LEVEL = {}

function LEVEL.MapScript(player)
	local cx, cy = GetCamPos()
	cx = math.max(cx - CONFIG.scr_width/2, -18)
	if mapvar.tmp.bounds == 1 then
		SetCamBounds(cx, 13929, -9000, 152)
	else
		SetCamBounds(cx, 13929, -9000, 206)
	end
	SetObjPos( mapvar.tmp.area_limits, cx-5, 0 )
	SetPlayerRevivePoint(cx+32, -511)

	if not mapvar.tmp.introed and Loader.time > 1000 then
		mapvar.tmp.introed = true
		showStageName( 1, function() EnablePlayerControl( true ) FadeIn(1000) PlayBackMusic("music/iie_whbt.it") Menu.locked = false end )
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
end

function LEVEL.create_weather()
	Log(LEVEL.name, " create_weather")
	CreateSprite("weather-snow", 94, 8)
end


LEVEL.name = "FOREST"

return LEVEL
