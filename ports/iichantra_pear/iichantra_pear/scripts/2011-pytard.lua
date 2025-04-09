InitNewGame();
require("layered_bar")
require("iichantra-dialogues")

SetCamLag(0.9)
StopBackMusic()

mapvar.tmp = {}

CONFIG.backcolor_r = 2/255;
CONFIG.backcolor_g = 0;
CONFIG.backcolor_b = 0;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-pytard.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-345, 331, -352, 61)

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта


mapvar.tmp.boss = CreateEnemy( "2011-pytard", 13, 27 )
mapvar.tmp.bossfight = true
mapvar.tmp.boss_level = 1
mapvar.tmp.player_location = 1
mapvar.tmp.pytard_health = 1000

function pytard_hurt( id, damage )
	mapvar.tmp.pytard_health = mapvar.tmp.pytard_health - damage
end

function show_effect_walk(id)
	local pl = GetPlayer()
	if id == pl.id then
		if ( mapvar.tmp.effect ) then hide_effect(id, 0, 0, 1, 0) end
		mapvar.tmp.effect = CreateEffect("movement", pl.aabb.p.x, pl.aabb.p.x-50, id, 1)
	end
end

function hide_effect(id, x, y, old_material, new_material)
	local pl = GetPlayer()
	if id == pl.id and mapvar.tmp.effect then
		SetObjDead( mapvar.tmp.effect )
		mapvar.tmp.effect = nil
	end
end

function the_end()
	mapvar.tmp.bar:destroy()
	Menu.showEndLevelMenu("2011-lab")	
end

function end_boss_battle()
	mapvar.tmp.bar = LayeredBar.create()
	local bar_colors = {}
	bar_colors[2] = { color = { 128/255, 5/255, 5/255, 1 } }
	bar_colors[1] = { color = {0,0,0,0} }
	mapvar.tmp.bar.pmin = 0
	mapvar.tmp.bar.pmax = 1000
	mapvar.tmp.bar:init_default( bar_colors , "???")
	mapvar.tmp.bar.lock_first = true		-- Первый слой будет фоновым

	Wait( 50000*difficulty )
	CreateSprite( "open_door", -31, -94 )
	local env = CreateEnvironment("default_environment", -27, -93)
	GroupObjects( env, CreateEnvironment( "default_environment", 35, 41 ) )
	SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "the_end" } )
	GUI:hide()
	push_pause(true)
	dialogues.ny[40]:start()
end

----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	if Loader.time > 1 and not mapvar.tmp.introed then
		mapvar.tmp.introed = true
		GUI:hide()
		push_pause(true)
		dialogues.ny[39]:start()
	end
	mapvar.tmp.player_location = 3
	if player.aabb.p.y < -90 then
		mapvar.tmp.player_level = 2
		if player.aabb.p.x < -131 then
			mapvar.tmp.player_location = 1
		elseif player.aabb.p.x > 131 then
			mapvar.tmp.player_location = 2
		end
	else
		mapvar.tmp.player_level = 1
		if mapvar.tmp.transition then
			mapvar.tmp.transition = false
			SetDynObjVel( mapvar.tmp.boss, 0, 0 )
			SetDynObjAcc( mapvar.tmp.boss, 0, 0 )
			SetObjAnim( mapvar.tmp.boss, "move", false )
		end 
	end

	if mapvar.tmp.bossfight then
		local bs = GetObject( mapvar.tmp.boss )
		if bs.aabb.p.y < -90 then
			mapvar.tmp.boss_level = 2
		else
			mapvar.tmp.boss_level = 1
		end
		if math.abs( player.aabb.p.x - bs.aabb.p.x ) <= 64 then
			if mapvar.tmp.boss_level == mapvar.tmp.player_level then
				SetObjAnim( bs.id, "attack", false )
			elseif mapvar.tmp.player_location == 1 then
				SetObjAnim( bs.id, "move_left", false )
				mapvar.tmp.transition = true
			elseif mapvar.tmp.player_location == 2 then
				SetObjAnim( bs.id, "move_right", false )
				mapvar.tmp.transition = true
			end
		end
		if bs.aabb.p.x-bs.aabb.W <= -287 and mapvar.tmp.transition then
			mapvar.tmp.transition =  false
			SetObjPos( bs.id, -289, -148 )
			SetDynObjAcc( bs.id, 0, 0 )
			SetDynObjVel( bs.id, 0, 0 )
			SetObjSpriteMirrored( bs.id, true )
			SetObjAnim( bs.id, "attack", false )
		elseif bs.aabb.p.x+bs.aabb.W >= 290 and mapvar.tmp.transition then
			mapvar.tmp.transition =  false
			SetObjPos( bs.id, 277, -148 )
			SetDynObjAcc( bs.id, 0, 0 )
			SetDynObjVel( bs.id, 0, 0 )
			SetObjSpriteMirrored( bs.id, false )
			SetObjAnim( bs.id, "attack", false )
		end
	end
	if mapvar.tmp.bar then
		mapvar.tmp.bar:setLayerVal(2, mapvar.tmp.pytard_health)
	end
	if mapvar.tmp.pytard_health < 1000 then
		if mapvar.tmp.pytard_health < 300 then
			mapvar.tmp.pytard_health = mapvar.tmp.pytard_health + 10
		else
			mapvar.tmp.pytard_health = mapvar.tmp.pytard_health
		end
		if mapvar.tmp.pytard_health > 1000 then
			mapvar.tmp.pytard_health = 1000
		end
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

LEVEL.name = "UNPLEASANT ENCOUNTER"

return LEVEL
