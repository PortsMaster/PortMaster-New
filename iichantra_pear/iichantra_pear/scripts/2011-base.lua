InitNewGame();

SetCamLag(0)

require("iichantra-dialogues")

if not mapvar.tmp then
	mapvar.tmp = {}
end
mapvar.char = {}
mapvar.char.SOH = 2
StopBackMusic()

CONFIG.backcolor_r = 55/255;
CONFIG.backcolor_g = 59/255;
CONFIG.backcolor_b = 70/255;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-base.lua" );

SetCamUseBounds(true)
-- SetCamBounds(left, right, top, bottom)
SetCamBounds(-7014, 867, -887, 676)

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

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

function die_die_die(id)
	for key, value in pairs(mapvar.tmp.crate_pool[1]) do
		if id == value then
			table.insert( mapvar.tmp.crate_pool[2], id )
			table.remove( mapvar.tmp.crate_pool[1], key )
			return
		end
	end
	SetObjDead(id)
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

mapvar.tmp.doors =
{
	CreateDoor { -73+15, -147+64 },
	CreateDoor { -53, -566 },
	CreateDoor { -56, -806 },
	CreateDoor { -1804, -804 },
	CreateDoor { -1803, -564 },
	CreateDoor { -1803, -82 },
}

function doors_right()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", 71, -284 ) , "good", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[1] )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[2] )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[3] )	
end

function door_r3()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", -108, -47 ) , "good", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[1] )
end

function door_r1()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", -109, -776 ) , "good", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[3] )
end

function door_l1()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", -1769, -534 ) , "bad", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[4] )
end

function door_l2()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", -1770, -763 ) , "bad", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[5] )
end

function door_l3()
	PlaySnd( "button.ogg", false )
	SetObjAnim( CreateSprite("2011basescreen", -1899, -766 ) , "good", false )
	Resume( NewMapThread( ToggleDoor ), mapvar.tmp.doors[6] )
end

function gun_get()
	local pl = GetPlayer()
	--local new_pl = CreatePlayer("sohchan", 0, 0)
	
	SwitchCharacter(true)
	local num = GetPlayerNum()
	
	SetPlayerHealth(num, pl.health)
	AddBonusAmmo(pl.id, pl.ammo)
	SetPlayerAmmo(num, pl.ammo)
	SetObjDead( pl.id )
end
	
function wp_btards_left( id )
	if not (id == GetPlayer().id) then
		return
	end
	local vert = { -736, -504, -255, -6.5 }
	local y
	local wp1, wp2, wp3
	for i=1,2*difficulty do
		y = vert[math.random(1,4)]
		wp1, wp2, wp3 = CreateWaypoint( -1702, y, 64, 64 ), CreateWaypoint( -1183, y, 64, 64 ), CreateWaypoint( -950, 263, 64, 64, function(id) DamageObject(id, 9000) end )
		SetNextWaypoint( wp1, wp2 )
		SetNextWaypoint( wp2, wp3 )
		SetEnemyWaypoint( CreateEnemy("btard_wp", -1183, y), wp1 )
	end
end

function wp_btards_right( id )
	if not (id == GetPlayer().id) then
		return
	end
	local vert = { -736, -504, -255, -6.5 }
	local y
	local wp1, wp2, wp3
	for i=1,2*difficulty do
		y = vert[math.random(1,4)]
		wp1, wp2, wp3 = CreateWaypoint( -146, y, 64, 64 ), CreateWaypoint( -710, y, 64, 64 ), CreateWaypoint( -950, 263, 64, 64, function(id) DamageObject(id, 9000) end )
		SetNextWaypoint( wp1, wp2 )
		SetNextWaypoint( wp2, wp3 )
		SetEnemyWaypoint( CreateEnemy("btard_wp", -710, y), wp1 )
	end
end

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

-----------------------------------------------------------------------------
-- Двери, за которыми можно прятаться

mapvar.tmp.doors_wc = { {-198, -77}, {-198, -558}, {-199, -799}, {-1738, -798}, {-1737, -559}, {-1735, -76}, {-4050, 81}, {-4304, 81}, {-4818, 81}, {-5073, 81} }

local env2
for key, value in pairs( mapvar.tmp.doors_wc ) do
	env2 = CreateEnvironment("default_environment", value[1]+20, value[2] + 20)
	GroupObjects( env2, CreateEnvironment( "default_environment", value[1]+40, value[2]+60 ) )
	SetEnvironmentStats( env2, { material = 3, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "door_wc" } )
end

mapvar.tmp.doors_normal = { {-658, -319}, {-1305, -320}, {-3022, 146}, {-4560, 84} }

local env2
for key, value in pairs( mapvar.tmp.doors_normal ) do
	env2 = CreateEnvironment("default_environment", value[1]+20, value[2] + 20)
	GroupObjects( env2, CreateEnvironment( "default_environment", value[1]+40, value[2]+60 ) )
	SetEnvironmentStats( env2, { material = 3, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "door_normal" } )
end

local exit_door = nil

function get_door_on_use_func(door_arr, door_name)
	return function ()
		if mapvar.tmp.block_door then return end
		local door_area
		local pl = GetPlayer()
		for key, value in pairs( door_arr ) do
			if not door_area or 
					  (math.abs(pl.aabb.p.x - value[1]) + math.abs(pl.aabb.p.y - value[2]) < 
					   math.abs(pl.aabb.p.x - door_area[1]) + math.abs(pl.aabb.p.y - door_area[2])) then
				door_area = value
			end
		end
		EnablePlayerControl( false )
		SetObjAnim( CreateSprite( "2011basedoors", door_area[1], door_area[2] ), door_name, false )
		SetObjInvisible( pl.id, true )
		mapvar.tmp.pl_shadow = GetDynObjShadow(pl.id)
		SetDynObjShadow(pl.id, nil)
		hide_effect( pl.id, 0, 0, 1, -1 )
		mapvar.tmp.doorcoord = door_area
		
		-- Выйти из двери можно только через некотрое время. Нужно хоть какое-то время, чтобы героиня не входила сразу же после выхода
		AddTimerEvent(600, function ()
					--Log("can exit")
					exit_door = function()
						show_effect_walk( GetPlayer().id )
						SetObjAnim( CreateSprite( "2011basedoors", mapvar.tmp.doorcoord[1], mapvar.tmp.doorcoord[2] ), door_name, false )
						SetObjInvisible( GetPlayer().id, false )
						SetDynObjShadow(pl.id, mapvar.tmp.pl_shadow)
						EnablePlayerControl( true )
						exit_door = nil
						mapvar.tmp.block_door = true
						-- Войти можно будет только черех некоторое время.
						-- Нужно хоть какое-то время, чтобы героиня не выходила сразу же после входа
						AddTimerEvent(600, function () mapvar.tmp.block_door = false; end)
					end
				end )
	end
	
end

door_wc = get_door_on_use_func(mapvar.tmp.doors_wc, "wc")
door_normal = get_door_on_use_func(mapvar.tmp.doors_normal, "normal")

function door_final()
	Resume( NewMapThread( function()
		GUI:hide()
		LetterBox(true)
		EnablePlayerControl( false )
		SetObjAnim( CreateSprite( "2011basedoors", -5795, -458 ), "normal", false )
		local pl = GetPlayer()
		SetObjInvisible( pl.id, true )
		SetDynObjShadow(pl.id, nil)
		Wait( 1000 )
		AttachCamToObjSlowly(CreateItem("ex", -5144, 161), 0, 60, 2000, false, nil)
		Wait( 2500 )
		AttachCamToObjSlowly(mapvar.tmp.slp, 0, 60, 2000, false, nil)
		Wait( 2000 )
		SetObjAnim(mapvar.tmp.slp, "wake", false)
		Wait( 500 )
		FadeOut( {0,0,0}, 2000 )
		Wait( 2000 )
		LetterBox(false)
		Menu.showEndLevelMenu("2011-heli")
	end ))
end

function tp()
	SetObjPos( GetPlayer().id, GetMousePos() )
end

function death_to_player( id )
	if GetPlayer().id == id then
		SetPlayerRevivePoint(-2206, 35)
		DamageObject( id, 9000 )
	end
end

------------------------------------------------------------------------------

CreatePlatform( "2011-fp2", { {-947, 191}, {-947, -673} }, true )
CreatePlatform( "2011-fp2", { {-2209, -54}, {-2209, -1052} }, true )
CreatePlatform( "2011-fp2", { {-5955, 315}, {-5955, 91} }, true )
CreatePlatform( "2011-fp2", { {-5535, 91}, {-5535, -120} }, true )
CreatePlatform( "2011-fp2", { {-5955, -120}, {-5955, -339} }, true )

local env = CreateEnvironment("default_environment", -2367, 519)
GroupObjects( env, CreateEnvironment( "default_environment", -1778, 585 ) )
SetEnvironmentStats( env, { gravity_bonus_x = -1 } )

env = CreateEnvironment("default_environment", -3462, 519)
GroupObjects( env, CreateEnvironment( "default_environment", -2711, 585 ) )
SetEnvironmentStats( env, { gravity_bonus_x = -1 } )

env = CreateEnvironment("default_environment", -6330, 525)
GroupObjects( env, CreateEnvironment( "default_environment", -5130, 585 ) )
SetEnvironmentStats( env, { gravity_bonus_x = -1 } )

env = CreateEnvironment("default_environment", -5168, -300)
GroupObjects( env, CreateEnvironment( "default_environment", -3701, -263 ) )
SetEnvironmentStats( env, { gravity_bonus_x = -1 } )

env = CreateEnvironment("default_environment", -7316, 668)
GroupObjects( env, CreateEnvironment( "default_environment", -6258, 900 ) )
SetEnvironmentStats( env, { on_enter = "die_die_die" } )

env = CreateEnvironment("default_environment", -106, -45)
GroupObjects( env, CreateEnvironment( "default_environment", -91, -28 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "door_r3" } )

env = CreateEnvironment("default_environment", 70, -280)
GroupObjects( env, CreateEnvironment( "default_environment", 88, -264 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "doors_right" } )

env = CreateEnvironment("default_environment", -106, -774)
GroupObjects( env, CreateEnvironment( "default_environment", -89, -758 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "door_r1" } )

env = CreateEnvironment("default_environment", -1897, -763)
GroupObjects( env, CreateEnvironment( "default_environment", -1880, -745 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "door_l3" } )

env = CreateEnvironment("default_environment", -1770, -760)
GroupObjects( env, CreateEnvironment( "default_environment", -1749, -743 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "door_l2" } )

env = CreateEnvironment("default_environment", -1768, -530)
GroupObjects( env, CreateEnvironment( "default_environment", -1747, -512 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "door_l1" } )

env = CreateEnvironment("default_environment", -1621, -886)
GroupObjects( env, CreateEnvironment( "default_environment", -1567, 54 ) )
SetEnvironmentStats( env, { on_enter = "wp_btards_left" } )

env = CreateEnvironment("default_environment", -313, -888)
GroupObjects( env, CreateEnvironment( "default_environment", -254, 46 ) )
SetEnvironmentStats( env, { on_enter = "wp_btards_right" } )

env = CreateEnvironment("default_environment", -1672, 79)
GroupObjects( env, CreateEnvironment( "default_environment", -1539, 300 ) )
SetEnvironmentStats( env, { on_enter = "hold_it" } )

env = CreateEnvironment("default_environment", -5782, -447)
GroupObjects( env, CreateEnvironment( "default_environment", -5757, -380 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "door_final" } )

env = CreateEnvironment("default_environment", -2015, -730)
GroupObjects( env, CreateEnvironment( "default_environment", -2368, -653 ) )
SetEnvironmentStats( env, { on_enter = "death_to_player" } )

mapvar.tmp.crate_pool = { {}, {} }

function keycard()
	push_pause(true)
	GUI:hide()
	dialogues.ny[23]:start()
end

function hold_it(id)
	if id == GetPlayer().id then
		if mapvar.tmp.got_weapons then return end
		Resume( NewMapThread( function()
			EnablePlayerControl( false )
			SetDynObjAcc( id, 5, 0 )
			while GetPlayer().aabb.p.x < -1300 do
				Wait(1)
			end
			SetDynObjAcc( id, 0, 0 )
			SetDynObjVel( id, 0, 0 )
			SetObjAnim( id, "stop", false )
			push_pause(true)
			GUI:hide()
			dialogues.ny[22]:start()
		end ) )
	end
end

Resume( NewMapThread(
	function()
		while true do
			Wait( 2500 )
			if not mapvar.tmp.crate_pool[2][1] then
				table.insert(mapvar.tmp.crate_pool[1], CreateEnemy("crate", -3830, -977 ))
			else
				SetObjPos( mapvar.tmp.crate_pool[2][1], -3830+32, -977+32 )
				table.insert(mapvar.tmp.crate_pool[1], mapvar.tmp.crate_pool[2][1] )
				table.remove(mapvar.tmp.crate_pool[2], 1)
			end
		end
	end
) )

function CreateTurret( coord, delay )
	ObjectPushInt( CreateEnemy( "topturret", coord[1], coord[2] ), delay )
end


local function keyReleaseProcessor(key)
	if exit_door and IsConfKey(key, config_keys.player_use) then
		exit_door()
	end
end

function intro()
	LetterBox( true )
	Loader.game_timer_enabled = false
	mapvar.tmp.com = CreateEnemy( "btard-com-cinematic", -331, -27 )
	mapvar.tmp.btd = CreateEnemy( "btard-cinematic", -281, -27 )
	mapvar.tmp.slp = CreateEnemy( "slowpoke-cinematic", -160, -27 )
	SetCamAttachedObj( mapvar.tmp.com )
	FadeIn( 2000 )
	Wait(100)
	SetObjAnim(mapvar.tmp.com, "idle", false)
	SetObjAnim(mapvar.tmp.slp, "idle", false)
	SetObjAnim(mapvar.tmp.btd, "turn", false)
	Wait(1900)
	Resume( NewMapThread( dialogues.ny[20].start ), dialogues.ny[19] ) 
	while not mapvar.tmp.dl2 do
		Wait(1)
	end

	--CamMoveToPos(80, -203)
	
	EnablePlayerControl( false )
	local ex = CreateEnemy( "ex", -697, -233 )
	SetObjAnim( ex, "right", false )
	local exo = GetObject(ex)
	while exo.aabb.p.x < 80 do
		Wait(1)
		exo = GetObject(ex)
	end
	doors_right()
	SetObjAnim( ex, "left", false )
	Wait(100)
	AttachCamToObjSlowly(GetPlayer().id, 0, 60, 3000, false, nil)
	Wait(3100)
	dialogues.ny[20]:start()
	while not mapvar.tmp.dl1 do
		Wait(1)
	end
	AttachCamToObjSlowly(CreateItem("gun", -1926, -16), 0, 60, 4000, false, nil)
	SetObjAnim( CreateItem("keycard", -1908, 26), "idle-red", false )
	Wait(4100)
	AttachCamToObjSlowly(GetPlayer().id, 0, 60, 4000, false, nil)
	Wait(4300)
	SetCamLag(0.9)
	dialogues.ny[21]:start()
	while not mapvar.tmp.dl3 do
		Wait(1)
	end
	EnablePlayerControl( true )
	Loader.game_timer_enabled = true
	LetterBox( false )
	Menu.locked = false
	GUI:show()
	SetObjDead( exo.id )
	SetObjDead( mapvar.tmp.btd )
	SetObjDead( mapvar.tmp.com )
	SetObjDead( mapvar.tmp.cf )

	CreateTurret( {-1959, 265}, 0 )
	CreateTurret( {-2017, 265}, 500 )
	CreateTurret( {-2082, 265}, 1000 )
	CreateTurret( {-2145, 265}, 1500 )
	CreateTurret( {-2210, 265}, 2000 )

	CreateTurret( {-2137, 83}, 0 )
	CreateTurret( {-2077, 83}, 500 )
	CreateTurret( {-2007, 83}, 1000 )

	CreateTurret( {-3928, -641}, 0 )
	CreateTurret( {-3975, -641}, 1000 )
	CreateTurret( {-4026, -641}, 0 )
	CreateTurret( {-4081, -641}, 1000 )
	CreateTurret( {-4138, -641}, 0 )
	CreateTurret( {-4202, -641}, 1000 )
	CreateTurret( {-4266, -641}, 0 )

	local tx = -4400
	for i=1,4 do
		CreateTurret( {tx, -641}, 0 )
		tx = tx - 40
		CreateTurret( {tx, -641}, 1000 )
		tx = tx - 40
		CreateTurret( {tx, -641}, 2000 )
		tx = tx - 40
		CreateTurret( {tx, -641}, 1000 )
		tx = tx - 40
		CreateTurret( {tx, -641}, 0 )
		tx = tx - 40
	end
	PlayBackMusic("music/iie_escape.it")
end

FadeOut( {0, 0, 0}, 0 )
----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	if not mapvar.tmp.introed and Loader.time > 1 then
		mapvar.tmp.introed = true
		GUI:hide()
		--push_pause(true)
		Menu.locked = {true}
		showStageName( 2, function() GUI:hide() Resume( NewThread(intro), player ) end )
	end
	if player and player.onPlane then
		SetPlayerRevivePoint( player.aabb.p.x-player.aabb.W, player.aabb.p.y-player.aabb.H )
	end
end

function LEVEL.placeSecrets()
end

function LEVEL.removeSecrets()
end

function LEVEL.cleanUp()
	table.remove( Loader.slaveKeyReleaseProcessors, LEVEL.keyReleaseProcessorId )
end 

function LEVEL.SetLoader(l)
	LEVEL.missionStarter = l
	
	table.insert(Loader.slaveKeyReleaseProcessors, keyReleaseProcessor)
	LEVEL.keyReleaseProcessorId = #Loader.slaveKeyProcessors
end

LEVEL.name = "CAPTURED"

return LEVEL
