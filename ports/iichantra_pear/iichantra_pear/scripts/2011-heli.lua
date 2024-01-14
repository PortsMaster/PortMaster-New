InitNewGame();
require("layered_bar")

SetCamLag(0.9)

if not mapvar.tmp then
	mapvar.tmp = {}
end

StopBackMusic()

CONFIG.backcolor_r = 2/255;
CONFIG.backcolor_g = 0;
CONFIG.backcolor_b = 0;
LoadConfig();

local env = CreateEnvironment("snow", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-heli.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-270, 803, -9000, 65)

local limit = CreateSprite( "phys-empty", -280, -9000 )
GroupObjects( limit, CreateSprite( "phys-empty", -270, 9000 ) )
SetObjSolidToByte( limit, 1 )

limit = CreateSprite( "phys-empty", 803, -9000 )
GroupObjects( limit, CreateSprite( "phys-empty", 823, 9000 ) )
SetObjSolidToByte( limit, 1 )

local trigger = CreateItem("generic-trigger", 123, -255)
GroupObjects( trigger, CreateItem("generic-trigger", 225, 43) )
ObjectPushInt( trigger, 1 )

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

function heli()
	Menu.locked = false
	mapvar.tmp.bar = LayeredBar.create()
	local bar_colors = {}
	bar_colors[2] = { color = { 76/255, 82/255, 93/255, 1 } }
	bar_colors[1] = { color = {0,0,0,0} }
	mapvar.tmp.bar.pmin = 0
	mapvar.tmp.bar.pmax = 4
	mapvar.tmp.bar:init_default( bar_colors , "BOSS")
	mapvar.tmp.bar.lock_first = true		-- Первый слой будет фоновым

	wp = CreateWaypoint( 681, -214, 64, 64 )
	wp2 = CreateWaypoint( -172, -196, 64, 64 )
	wp3 = CreateWaypoint( 379, -366, 64, 64 )
	wp_getaway3 = CreateWaypoint( 379, -1942, 64, 64 )
	SetNextWaypoint( wp, wp2 )
	SetNextWaypoint( wp2, wp3 )
	SetNextWaypoint( wp3, wp )
	passengers = {}
	choppa = CreateEnemy("iicopter", 681, -214)
	SetEnemyWaypoint( choppa, wp )
	mapvar.tmp.iicopter_parts_destroyed = 0
	iicopter_destroyed_thread = function()
		SetEnemyWaypoint( choppa, wp_getaway3 )
		mapvar.tmp.iicopter_dest = true
		mapvar.tmp.bar:destroy()
		mapvar.tmp.bar = nil 
		Wait(10500)
		SetObjDead(choppa)
	end
	iicopter_destroyed = function() 
		Resume( NewMapThread( iicopter_destroyed_thread ) )
	end
end

function iicopter_doors(id)
	if passengers then
		for i=1, math.min(#passengers, 10) do
			ObjectPushInt( id, passengers[i] )
		end
	end
	passengers = {}
end

function iicopter_part_destroyed(id)
	mapvar.tmp.iicopter_parts_destroyed = ( mapvar.tmp.iicopter_parts_destroyed or 0 ) + 1
	mapvar.tmp.bar:setLayerVal(2, 4-mapvar.tmp.iicopter_parts_destroyed)
	if ( mapvar.tmp.iicopter_parts_destroyed >= 4 and iicopter_destroyed ) then
		iicopter_destroyed()
		mapvar.tmp.iicopter_parts_destroyed = 0
	end
end

function iicopter_part_created(id)
	if not iicopter_parts then iicopter_parts = {} end
	table.insert( iicopter_parts, id )
end

function iicopter_deactivate()
	for key, value in pairs(iicopter_parts) do
		SetObjAnim( value, "inactive", false )
	end
end

function boss()
	heli()
	PlayBackMusic("music/iie_boss.it")
	while not mapvar.tmp.iicopter_dest do
		Wait(3000)
		if mapvar.tmp.iicopter_dest then break end
		CreateEnemy( "btard-boss", -380, 0 )
		Wait(500)
		if mapvar.tmp.iicopter_dest then break end
		CreateEnemy( "btard-boss", 846, 0 )
		Wait(500)
		if mapvar.tmp.iicopter_dest then break end
		CreateEnemy( "btard-boss", -380, 0 )
		Wait(500)
		if mapvar.tmp.iicopter_dest then break end
		CreateEnemy( "btard-boss", 846, 0 )
		Wait(500)
		if mapvar.tmp.iicopter_dest then break end
		if difficulty > 1 then CreateEnemy( "superbtard-boss", -380, 0 )
		else CreateEnemy( "btard-ambush", -380, 0 ) end
		Wait(500)
		if mapvar.tmp.iicopter_dest then break end
		if difficulty >= 1 then CreateEnemy( "superbtard-boss", 846, 0 )
		else CreateEnemy( "btard-ambush", 846, 0 ) end
	end
	Wait(3000)
	Menu.showEndLevelMenu("2011-lab")
end

function map_trigger(id, trigger)
	if trigger == 1 then
		SetObjDead( id )
		Resume( NewMapThread( boss ) )
	end
end

----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
end

function LEVEL.placeSecrets()
end

function LEVEL.removeSecrets()
end

function LEVEL.cleanUp() 
	if mapvar.tmp and mapvar.tmp.bar then 
		mapvar.tmp.bar:destroy()
		mapvar.tmp.bar = nil 
	end 
end 

function LEVEL.SetLoader(l)
	LEVEL.missionStarter = l
end

LEVEL.name = "ALMOST ESCAPED"

return LEVEL
