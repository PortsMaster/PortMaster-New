InitNewGame();
require("layered_bar")
require("iichantra-dialogues")

SetCamLag(0.9)

if not mapvar.tmp then
	mapvar.tmp = {}
end

mapvar.char = {}
mapvar.char.SOH = 1


StopBackMusic()

CONFIG.backcolor_r = 2/255;
CONFIG.backcolor_g = 0;
CONFIG.backcolor_b = 0;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-troll.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-293, 982, -228, 246)

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

mapvar.tmp.troll_deaths = 0

function troll_hurt(id)
	local health = assert(GetCharHealth(id))
	mapvar.tmp.bar:setLayerVal(health, 3-mapvar.tmp.troll_deaths)
end

function troll_death(id)
	mapvar.tmp.bar:setLayerVal(0, 3-mapvar.tmp.troll_deaths)
	mapvar.tmp.troll_deaths = mapvar.tmp.troll_deaths + 1
	SetObjAnim( mapvar.tmp.boss[2], "stage2", false )
	if mapvar.tmp.troll_deaths == 2 then
		mapvar.tmp.bossfight = false
		SetObjAnim( id, "final_death", false )
		CreateItem( "keycard", 936, 44 )
		SetObjDead( mapvar.tmp.boss[2] )
		mapvar.tmp.bar:destroy()
		mapvar.tmp.bar = nil
	else
		SetObjSpriteColor( id, {1.0, 0.8, 0.8, 1.0} )
	end
end

function map_trigger( id, trigger )
	Menu.locked = false
	if trigger == 1 then
		PlayBackMusic("music/iie_boss.it")
		SetObjDead( id )
		mapvar.tmp.boss = { CreateEnemy("troll", 882, -50), CreateEnemy("troll-hand", 812, -50) }
		mapvar.tmp.bossfight = true
		Resume( NewMapThread( 
			function()
				while mapvar.tmp.bossfight do
					local obj = GetObject( mapvar.tmp.boss[2] )
					if obj and obj.aabb.p.y < 28 then
						SetObjPos( obj.id, obj.aabb.p.x, 28 )
					end
					Wait(1)
				end
			end) )
		Resume( NewMapThread( 
			function()
				while mapvar.tmp.bossfight do
					CreateEnemy( "cancer", 1005.000000, 40.000000 )
					Wait(12000/difficulty)
				end
			end) )
		mapvar.tmp.bar = LayeredBar.create()
		local bar_colors = {}
		bar_colors[3] = { color = { 0.5, 0, 1, 1 } }
		bar_colors[2] = { color = { 0.5, 0, 0.75, 1 } }
		bar_colors[1] = { color = {0,0,0,0} }
		mapvar.tmp.bar.pmin = 0
		mapvar.tmp.bar.pmax = assert(GetCharHealth(mapvar.tmp.boss[1]))
		mapvar.tmp.bar:init_default( bar_colors , "CAVE TROLL")
		mapvar.tmp.bar.lock_first = true		-- Первый слой будет фоновым
	end
end

function die_die_die( id )
	SetObjDead(id)
end

function stop_right_there_criminal_scum( id )
	if not mapvar.tmp.bossfight then
		return
	end
	if id == GetPlayer().id then
		DamageObject( id, 20 )
		SetDynObjVel( id, -40, -5 )
	end
end

function keycard()
	EnablePlayerControl( false )
	GUI:hide()
	dialogues.ny[31]:start()
end

local trigger = CreateItem("generic-trigger", 412, -1000)
GroupObjects( trigger, CreateItem("generic-trigger", 512, 1000) )
ObjectPushInt( trigger, 1 )

local limit = CreateSprite("phys-empty", -303, -1000 )
GroupObjects( limit, CreateSprite("phys-empty", -293, 1000 ) )
SetObjSolidToByte( limit, 1 )
mapvar.tmp.area_limits = limit

env = CreateEnvironment("default_environment", -320, -9000)
GroupObjects( env, CreateEnvironment("default_environment", -303, 9000) )
SetEnvironmentStats( env, { on_enter = "die_die_die" } )

env = CreateEnvironment("default_environment", 898, -34)
GroupObjects( env, CreateEnvironment("default_environment", 977, 145) )
SetEnvironmentStats( env, { on_enter = "stop_right_there_criminal_scum" } )

----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	local cx, cy = GetCamPos()
	cx = math.max(cx - CONFIG.scr_width/2, -293)
	SetCamBounds(cx, 982, -228, 246)
	SetObjPos( mapvar.tmp.area_limits, cx-5, 0 )
	SetPlayerRevivePoint(cx+32, -100)
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

LEVEL.name = "TROLL'S CAVE"

return LEVEL
