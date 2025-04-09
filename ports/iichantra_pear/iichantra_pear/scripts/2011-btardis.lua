InitNewGame();
require("layered_bar")
require("iichantra-dialogues")

SetCamLag(0.9)
StopBackMusic()

mapvar.tmp = {}

CONFIG.backcolor_r = 0;
CONFIG.backcolor_g = 0;
CONFIG.backcolor_b = 0;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-btardis.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-216, 570, -9000, 92)

FadeIn(0)

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта


function wp_cm( id, waypoint )
	if waypoint == mapvar.tmp.cm_wp[1] then
		SetObjAnim( id, "stop", false )
		SetDynObjVel( id, -5, 0 )
		return mapvar.tmp.cm_wp[2]
	else
		SetObjAnim( id, "stop", false )
		SetDynObjVel( id, 5, 0 )
		return mapvar.tmp.cm_wp[1]
	end
end

mapvar.tmp.cm_wp = { CreateWaypoint( -42, -51, 32, 32, wp_cm ), CreateWaypoint( 425, -51, 32, 32, wp_cm ) }
mapvar.tmp.bs_wp = { CreateWaypoint( -42, -302, 32, 32 ), CreateWaypoint( 425, -302, 32, 32 ) }
SetNextWaypoint( mapvar.tmp.bs_wp[1], mapvar.tmp.bs_wp[2] )
SetNextWaypoint( mapvar.tmp.bs_wp[2], mapvar.tmp.bs_wp[1] )

function map_trigger( id, trigger )
end

function start_boss()
	mapvar.tmp.boss = { CreateEnemy( "2011-cmaniac", 417, -59 ), CreateEnemy( "2011-btardis", 296, 11 ) }
	SetEnemyWaypoint( mapvar.tmp.boss[1], mapvar.tmp.cm_wp[1] )
	SetEnemyWaypoint( mapvar.tmp.boss[2], mapvar.tmp.bs_wp[1] )
end

function cm_hurt(id)
	local health = assert(GetCharHealth(id))
	mapvar.tmp.bar:setLayerVal(health, 2)
end

function cm_move()
	if math.random(1,10) > 5 then
		SetDynObjGravity( mapvar.tmp.boss[1], 0, 0.4 )
		SetDynObjVel( mapvar.tmp.boss[1], 0, -6 )
	end
	SetObjAnim( mapvar.tmp.boss[1], "move", false )
end

start_boss()

function cm_jump_area( id )
	if id == mapvar.tmp.boss[1] then
		SetDynObjGravity( mapvar.tmp.boss[1], 0, 0.8 )
		local obj = GetObject( id )
		SetDynObjVel( id, obj.vel.x, -10 )
	end
end

local env = CreateEnvironment("default_environment", 9, -13)
GroupObjects( env, CreateEnvironment( "default_environment", 58, 40 ) )
SetEnvironmentStats( env, { on_enter = "cm_jump_area" } )

env = CreateEnvironment("default_environment", 384, -13)
GroupObjects( env, CreateEnvironment( "default_environment", 391, 35 ) )
SetEnvironmentStats( env, { on_enter = "cm_jump_area" } )

function cm_dead()
	Resume( NewThread( function() 
		push_pause( true )
		mapvar.tmp.bar:destroy()
		GUI:hide()
		FadeOut({1,1,1}, 1000)
		Wait(1000)
		--[[
		mapvar.tmp.rib1 = CreateRibbonObj( "pearalax1", 0.5, 0.5, 0, 0, -0.95, false )
		mapvar.tmp.rib2 = CreateRibbonObj( "pearalax2", 0.75, 0.75, 0, 0, -1, false )
		mapvar.tmp.rib_x = 0;
		Resume( NewMapThread( function()
			while true do
				mapvar.tmp.rib_x = mapvar.tmp.rib_x-5;
				SetObjPos(mapvar.tmp.rib1, mapvar.tmp.rib_x*2, 0)
				SetObjPos(mapvar.tmp.rib2, mapvar.tmp.rib_x, 0)
				Wait(1)
			end
		end ))
		--]]
		dialogues.ny[56]:start()
	end ) )
end

function btardis_dead(id)
	Resume( NewThread( function( id )
		local obj = GetObject( id )
		push_pause( true )
		mapvar.tmp.bar:destroy()
		GUI:hide()
		dialogues.ny[57]:start()
		while not mapvar.tmp.dl1 do
			Wait(1)
		end
		pop_pause()
		for j=1,3 do
			for i=1,8 do
				SetObjAnim(
				CreateSprite("../projectiles/explosion-safe", obj.aabb.p.x-obj.aabb.W+math.random(0, 2*obj.aabb.W), 
											    obj.aabb.p.y-obj.aabb.H+math.random(0, 2*obj.aabb.H) ),
				"die", false)
			end
			Wait(100)
		end
		Wait( 5000 )
		StopBackMusic()
		local w = CreateWidget( constants.wt_Picture, "lolending", nil, 0, 0, 640, 480 )
		WidgetSetSprite( w, "end-widget" )
		PlaySnd( "music/iie_win_jingle.it", false )
		push_pause()
		Wait( 10000 )
		DestroyWidget(w)
		mapvar.score = mapvar.score + difficulty*500000
		varchange( "score", difficulty*500000 )
		FadeOut({0,0,0}, 0)
		Menu.showGameOver()
		Menu:show(7)
	end ), id )
end

function btardis_hurt(id)
	local health = assert(GetCharHealth(id))
	mapvar.tmp.bar:setLayerVal(health, 2)
end

GroupObjects( CreateItem("generic-death-area", -498, 221), CreateItem("generic-death-area", 995, 500) )

----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	if not mapvar.tmp.introed and Loader.time > 1 then
		mapvar.tmp.introed = true
		GUI:hide()
		EnablePlayerControl( false )
		dialogues.ny[55]:start()
	end
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

LEVEL.name = "FINAL CONFRONTATION"

return LEVEL
