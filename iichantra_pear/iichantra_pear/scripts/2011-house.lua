InitNewGame();
require( "iichantra-dialogues" )

SetCamLag(0.9)
StopBackMusic()

mapvar.tmp = {}

CONFIG.backcolor_r = 0;
CONFIG.backcolor_g = 0;
CONFIG.backcolor_b = 0;
LoadConfig();

local env = CreateEnvironment("default_environment", -9001, -9001)
SetDefaultEnvironment(env)
dofile( "levels/2011-house.lua" );

SetCamAttachedObj(GetPlayer().id);		-- Цепляем камеру к объекту
SetCamAttachedAxis(true, true);		-- Камера смещается только по оси X
SetCamFocusOnObjPos(constants.CamFocusBottomCenter);	-- Камера следит за серединой ниднего края объекта
-- При смене анимаций y-координата нижнего края не меняется, таким образом, камера не пляшет при, например, приседании
SetCamObjOffset(0, 60);	-- Задаем смещении камеры относительно объекта

SetCamUseBounds(false)
-- SetCamBounds(left, right, top, bottom)
--SetCamBounds(-270, 803, -9000, 65)

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
	local pl = GetPlayer()
	if id == pl.id and mapvar.tmp.effect then
		SetObjDead( mapvar.tmp.effect )
		mapvar.tmp.effect = nil
	end
end

function CreateBlock( coord )
	local bl = CreateSprite("phys-empty", coord[1], coord[2]-228)
	GroupObjects( bl, CreateSprite("phys-empty", coord[1]+10, coord[2]+113) )
	return { CreateSprite("2011-block", coord[1], coord[2]), bl, true, coord[1], coord[2] }
end

function ToggleBlock( block )
	block[3] = not block[3]
	if block[3] then
		SetObjAnim(block[1], "idle", false)
		local bl = CreateSprite("phys-empty", block[4], block[5]-228)
		GroupObjects( bl, CreateSprite("phys-empty", block[4]+10, block[5]+114) )
		block[2] = bl
	else
		SetObjAnim(block[1], "off", false)
		SetObjDead(block[2])
	end
end

function keycard()
	mapvar.tmp.got_key = true
	push_pause(true)
	GUI:hide()
	dialogues.ny[32]:start()
end

mapvar.tmp.blocks =
{
	CreateBlock{ 445, -364 },
	CreateBlock{ 326, -1142+76 },
	CreateBlock{ 1031, -1494+76 },
	CreateBlock{ 1157, -1495+76 },
	CreateBlock{ 1606, -88+76 },
	CreateBlock{ 1725, -791+76 },
	CreateBlock{ 1726, -1144+76 },
	CreateBlock{ 3906, -796+76 },
	CreateBlock{ 4650, -447+76 },
}

function enter_splash( id, x, y )
	CreateParticleSystem("pwater", x, y)
end

function exit_splash( id, x, y )
	CreateParticleSystem("pwater", x, y)
end

function BlockTrigger( coord, num )
	if type(num) == 'number' then num = "block"..num end
	local env = CreateEnvironment("default_environment", coord[1], coord[2])
	GroupObjects( env, CreateEnvironment( "default_environment", coord[1]+20, coord[2]+40 ) )
	SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = num } )
end

function fake_unyl_hurt()
	local fpl = GetObject( mapvar.tmp.fake_unyl )
	SetPlayerHealth( 2, fpl.health )
end

function fake_soh_hurt()
	local fpl = GetObject( mapvar.tmp.fake_soh )
	SetPlayerHealth( 1, fpl.health )
end

function fake_unyl_dead()
	SetPlayerHealth( 2, 80/difficulty )
	mapvar.lives = mapvar.lives - 1
	if mapvar.lives < 0 then
		SetObjDead( GetPlayer().id )
	end
end

function fake_soh_dead()
	SetPlayerHealth( 2, 120/difficulty )
	mapvar.lives = mapvar.lives - 1
	if mapvar.lives < 0 then
		SetObjDead( GetPlayer().id )
	end
end

function locked_door()
	push_pause(true)
	GUI:hide()
	if not mapvar.tmp.player_unyl then
		dialogues.ny["LOCKED_SOH"]:start()
	else
		dialogues.ny["LOCKED_UNYL"]:start()
	end
end

function CreateLockedDoor( coord )
	local env = CreateEnvironment("default_environment", coord[1], coord[2])
	GroupObjects( env, CreateEnvironment( "default_environment", coord[1]+10, coord[2]+20 ) )
	SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_use", on_leave = "hide_effect", on_use = "locked_door"} )
end

CreateLockedDoor { -43, -4 }
CreateLockedDoor { 145, -18 }
CreateLockedDoor { -41, -358 }
CreateLockedDoor { 986, -364 }
CreateLockedDoor { 986, -716 }
CreateLockedDoor { 986, -1064 }
CreateLockedDoor { -44, -1076 }
CreateLockedDoor { 2259, -1065 }
CreateLockedDoor { 1232, -707 }
CreateLockedDoor { 2255, -707 }
CreateLockedDoor { 1232, -9 }
CreateLockedDoor { 2257, -5 }

function final_door()
	local pl = GetPlayer()
	push_pause( true )
	GUI:hide()
	if math.abs( pl.aabb.p.x - mapvar.tmp.player_pos[1] ) > 100 or math.abs( pl.aabb.p.y - mapvar.tmp.player_pos[2] ) > 100 then
		dialogues.ny[36]:start()
		return
	end
	if not mapvar.tmp.got_key then
		if mapvar.tmp_player_unyl then
			dialogues.ny[37]:start()
		else
			dialogues.ny[35]:start()
		end
		return
	end
	dialogues.ny[38]:start()
end

local env = CreateEnvironment("default_environment", 5858, -365)
GroupObjects( env, CreateEnvironment( "default_environment", 58585+10, -365+20 ) )
SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "final_door"} )


function switch_character()
	local pl = GetPlayer()
	if not pl.onPlane or pl.health <= 0 then return end
	if mapvar.tmp.player_unyl then
		Loader.level.char = "SOH"
		mapvar.tmp.fake_unyl = CreateEnemy("unylchan", pl.aabb.p.x-pl.aabb.W, pl.aabb.p.y-pl.aabb.H )
		SetObjSpriteMirrored( mapvar.tmp.fake_unyl, pl.sprite.mirrored )
		SetCharHealth( mapvar.tmp.fake_unyl, pl.health )
		if mapvar.tmp.fake_soh then SetObjDead(mapvar.tmp.fake_soh) end
	else
		Loader.level.char = "UNYL"
		mapvar.tmp.fake_soh = CreateEnemy("sohchan", pl.aabb.p.x-pl.aabb.W, pl.aabb.p.y-pl.aabb.H )
		SetObjSpriteMirrored( mapvar.tmp.fake_soh, pl.sprite.mirrored )
		SetCharHealth( mapvar.tmp.fake_soh, pl.health )
		if mapvar.tmp.fake_unyl then SetObjDead(mapvar.tmp.fake_unyl) end
	end
	mapvar.tmp.player_unyl = not mapvar.tmp.player_unyl
	SetObjPos( pl.id, unpack(mapvar.tmp.player_pos) )
	SwitchCharacter(true)
	SetObjSpriteMirrored( GetPlayer().id, mapvar.tmp.player_facing )
	mapvar.tmp.player_pos = { pl.aabb.p.x, pl.aabb.p.y }
	mapvar.tmp.player_facing = pl.sprite.mirrored
	--RetargetChildren( pl.id )
end

function keyReleaseProcessor(key)
	if IsConfKey(key, config_keys.change_player) then
		switch_character()
	end
end

for i=1,#mapvar.tmp.blocks do
	_G["block"..i] = loadstring( "PlaySnd('switch.ogg', true) ToggleBlock( mapvar.tmp.blocks["..i.."] )")
end

function switch1()
	PlaySnd('switch.ogg', true)
	if mapvar.tmp.blocks[4][3] then
		ToggleBlock(mapvar.tmp.blocks[4])
	end
	ToggleBlock(mapvar.tmp.blocks[8])
	ToggleBlock(mapvar.tmp.blocks[9])
end

BlockTrigger( {2052, -35}, 1 )
BlockTrigger( {2052, -739}, 2 )
BlockTrigger( {1543, -1444}, 3 )
BlockTrigger( {780, -386}, 5 )
BlockTrigger( {523, -1089}, 6 )
BlockTrigger( {966, -1441}, 7 )
BlockTrigger( {2525, -392}, "switch1" )
ToggleBlock( mapvar.tmp.blocks[8] )
BlockTrigger( {5720, -392}, 8 )

function DoorTo( coord1, coord2, num )
	_G["door"..num.."from"] = loadstring("SetObjPos( GetPlayer().id,"..coord2[1]..","..coord2[2]..")")
	_G["door"..num.."to"] = loadstring("SetObjPos( GetPlayer().id,"..coord1[1]..","..coord1[2]..")")
	local env = CreateEnvironment("default_environment", coord1[1], coord1[2])
	GroupObjects( env, CreateEnvironment( "default_environment", coord1[1]+10, coord1[2]+20 ) )
	SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "door"..num.."from" } )
	env = CreateEnvironment("default_environment", coord2[1], coord2[2])
	GroupObjects( env, CreateEnvironment( "default_environment", coord2[1]+10, coord2[2]+20 ) )
	SetEnvironmentStats( env, { material = 2, on_enter = "show_effect_walk", on_leave = "hide_effect", on_use = "door"..num.."to" } )
end

local env = CreateEnvironment("dirty_water", 3054, 19)
GroupObjects( env, CreateEnvironment( "dirty_water", 4100, 52 ) )

DoorTo( {1104, -1427}, {3106, -388}, 1 )
DoorTo( {406, -1083}, {2733, -1411}, 2 )
DoorTo( {406, -727}, {3649, -1091}, 3 )
DoorTo( {406, -370}, {3195, -1412}, 4 )
DoorTo( {406, -22}, {2720, -1067}, 5 )
DoorTo( {1673, -1084}, {3640, -1401}, 6 )
DoorTo( {1673, -728}, {3193, -1091}, 7 )
DoorTo( {1673, -374}, {4080, -1412}, 8 )
DoorTo( {1673, -22}, {4080, -1098}, 9 )

mapvar.tmp.player_pos = {2188, 21}
mapvar.tmp.player_facing = true
mapvar.tmp.player_unyl = false

function randomize_house()
	local key_locations = { {2663, -1370}, {2653, -1022}, {3134, -1370}, {3134, -1070}, {3565, -1383}, {3572, -1056}, {4028, -1358}, {4028, -1042} }
	local key = math.random(1, #key_locations)
	local card = CreateItem( "keycard", key_locations[key][1], key_locations[key][2] )
	SetObjAnim( card, "idle-yellow", false )
	local life = math.random(1, #key_locations)
	while key == life do
		life = math.random(1, #key_locations)
	end
	CreateItem( "bonus-life", key_locations[life][1], key_locations[life][2] )
	for i=1,#key_locations do
		if i ~= key and i ~= life then
			CreateSpawner( "btard-ambush-spawned", key_locations[i][1], key_locations[i][2], 1, constants.dirAny, 1, 64, 320 )
		end
	end
end

randomize_house()

function intro()
	Wait(100)
	SetObjPos( GetPlayer().id, -844, -13 )
	FadeIn( 2000 )
	Wait( 2000 )
	dialogues.ny[33]:start()
	while not mapvar.tmp.dl1 do
		Wait(1)
	end
	SetCamAttachedObj( GetPlayer().id )
	SetDynObjAcc( GetPlayer().id, -4, 0 )
	Wait( 500 )
	FadeOut( {0,0,0}, 1000 )
	Wait( 1000 )
	SetObjPos( GetPlayer().id, -19, -19 )
	FadeIn( 1000 )
	SetObjSpriteMirrored( GetPlayer().id, false )
	Wait(500)
	push_pause(true)
	dialogues.ny[34]:start()
end


----------------------------------------------------------------------

local LEVEL = {}

function LEVEL.MapScript(player)
	Menu.locked = false
	if Loader.time > 1 and not mapvar.tmp.introed then
		mapvar.tmp.introed = true
		GUI:hide()
		EnablePlayerControl( false )
		FadeOut( {0,0,0}, 0 )
		LetterBox(true)
		showStageName( 3, function() PlayBackMusic("music/nsmpr_choice.it") GUI:hide() Resume( NewMapThread( intro ) ) end )
	end
	BlockPlayerChange()
	if player and player.onPlane then
		SetPlayerRevivePoint( player.aabb.p.x-player.aabb.W, player.aabb.p.y-player.aabb.H-15 )
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
	if not Loader.slaveKeyReleaseProcessors then Loader.slaveKeyReleaseProcessors = {} end
	table.insert(Loader.slaveKeyReleaseProcessors, keyReleaseProcessor)
	LEVEL.keyReleaseProcessorId = #Loader.slaveKeyReleaseProcessors
end

LEVEL.name = "HAUNTED HOUSE"

return LEVEL
