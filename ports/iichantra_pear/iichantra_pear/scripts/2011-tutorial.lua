require("iichantra-dialogues")

InitNewGame();

mapvar.tmp = {}

CONFIG.backcolor_r = 67/255;
CONFIG.backcolor_g = 153/255;
CONFIG.backcolor_b = 153/255;
LoadConfig();

FadeOut({0,0,0}, 0)
PlayBackMusic("music/nsmpr_import.it")

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-tutorial.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-205, 810, -439, 319)

SetCamAttachedObj( GetPlayer().id )
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

function show_effect_use(id)
	local pl = GetPlayer()
	if id == pl.id then
		if ( mapvar.tmp.effect ) then hide_effect(id, 0, 0, 1, 0) end
		mapvar.tmp.effect = CreateEffect("use", pl.aabb.p.x, pl.aabb.p.x-50, id, 1)
	end
end

function show_effect_walk(id)
	local pl = GetPlayer()
	if id == pl.id then
		if ( mapvar.tmp.effect ) then hide_effect(id, 0, 0, 1, 0) end
		mapvar.tmp.effect = CreateEffect("movement", pl.aabb.p.x, pl.aabb.p.x-50, id, 1)
	end
end

function hide_effect(id, x, y, old_material, new_material)
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


function CreateDoor( coord )
	return { CreateSprite( "lab-door2", coord[1], coord[2] ), false }
end

function ToggleDoor( door )
	local dobj = GetObject( door[1] )
	if door[2] then
		if dobj.sprite.cur_anim == "open" then
			SetObjAnim( door[1], "close", false )
			Wait(1000)
			door[2] = false
		end
	else
		if dobj.sprite.cur_anim == "open-stay" then
			SetObjAnim( door[1], "open", false )
			Wait(1000)
			door[2] = true
		end
	end
end

function snowman_dead()
	mapvar.tmp.introed = true
	GUI:hide()
	EnablePlayerControl( false )
	dialogues.ny[49]:start()
end

mapvar.tmp.doors =
{
	CreateDoor { 110, -77 },
	CreateDoor { 333, -77 },
	CreateDoor { 554, -77 },
	CreateDoor { 779, -77 },
}

function keypad()
	ToggleDoor( mapvar.tmp.doors[4] )
	GUI:hide()
	EnablePlayerControl( false )
	dialogues.ny[53]:start()
end

local env = CreateEnvironment("default_environment", 734, -38)
GroupObjects( env, CreateEnvironment( "default_environment", 752, -22 ) )
SetEnvironmentStats( env, { on_use = "keypad", on_enter = "show_effect_use", on_leave = "hide_effect", material = 2  } )

----------------------------------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	if Loader.time > 1 and not mapvar.tmp.introed then
		FadeIn( 1000 )
		mapvar.tmp.introed = true
		GUI:hide()
		EnablePlayerControl( false )
		dialogues.ny[48]:start()
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
end

function LEVEL.register_weather( id, weather_id )
end

function LEVEL.create_weather()
end

function LEVEL.WeaponBonus()
	if not mapvar.tmp.got_weapon then
		mapvar.tmp.got_weapon = true
		GUI:hide()
		EnablePlayerControl( false )
		dialogues.ny[50]:start()
	else
		mapvar.tmp.got_weapon = true
		GUI:hide()
		EnablePlayerControl( false )
		dialogues.ny[51]:start()
	end
end

LEVEL.name = "TUTORIAL"

return LEVEL
