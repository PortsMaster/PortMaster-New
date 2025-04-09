require("serialize")
Saver = require("saves")
require("gui-menu")
require("console")

Loader = {}
Loader.bind = {}
GUI = require("gui").create()

--dbg = require("debug_tools")

Loader.slaveKeyProcessors = {}
Loader.slaveKeyReleaseProcessors = {}
function Loader.start()
	GlobalSetKeyDownProc( Loader.keyProcessor )
	GlobalSetKeyReleaseProc( Loader.keyReleaseProcessor )
    Menu.showMainMenu()
	
	if not mapvar then mapvar = {} end
	mapvar.game_timer = 0
	Loader.game_timer_enabled = false
	
--[[
	Loader.game_timer_w = CreateWidget(constants.wt_Label, "", nil, 10, 40, 30, 10)
	WidgetSetZ(Loader.game_timer_w,1)
	WidgetSetVisible(Loader.game_timer_w, true)
	WidgetSetCaptionColor(Loader.game_timer_w, {1,1,1,1}, true)
	WidgetSetCaptionColor(Loader.game_timer_w, {1,1,1,1}, false)
	Resume(NewThread(function () while true do WidgetSetCaption(Loader.game_timer_w, tostring(mapvar.game_timer)); Wait(1); end end))
	
	Loader.timer_w = CreateWidget(constants.wt_Label, "", nil, 10, 50, 30, 10)
	WidgetSetZ(Loader.timer_w,1)
	WidgetSetVisible(Loader.timer_w, true)
	WidgetSetCaptionColor(Loader.timer_w, {1,1,1,1}, true)
	WidgetSetCaptionColor(Loader.timer_w, {1,1,1,1}, false)
	Resume(NewThread(function () while true do WidgetSetCaption(Loader.timer_w, tostring(Loader.time)); Wait(1); end end))
	
	Loader.active_w = CreateWidget(constants.wt_Label, "", nil, 10, 60, 30, 10)
	WidgetSetZ(Loader.active_w,1)
	WidgetSetVisible(Loader.active_w, true)
	WidgetSetCaptionColor(Loader.active_w, {1,1,1,1}, true)
	WidgetSetCaptionColor(Loader.active_w, {1,1,1,1}, false)
	Resume(NewThread(function () while true do WidgetSetCaption(Loader.active_w, tostring(mapvar and mapvar.active_char or "")); Wait(1); end end))
--]]
end

function Loader.gameInit()
    Loader.old_time = GetCurTime()
    Loader.dt = 0
    Loader.time = 0
    Log("Init time ", Loader.time, "  old time ", Loader.old_time)
    GUI:show()

    SetOnPlayerDeathProcessor(Loader.onPlayerDeath)    -- Функция, котрая будет вызываться при смерти игрока
    if CharacterSystem then
        SetOnChangePlayerProcessor(CharacterSystem);
    end

	--[[	
	Log("gameInit", serialize("mapvar ", mapvar ))
	Log("gameInit", serialize("stat", stat ))
	--]]
	Loader.loadPlrInfo()
	Loader.game_timer_enabled = true
	
	
	
end

function Loader.startGame(map_name, no_newstat)
	StopMapThreads()
	if Loader.level and Loader.level.cleanUp then Loader.level.cleanUp() end
	
	Loader.map_name = map_name
	if not no_newstat then
		stat = { lives = 3, score = 0, game_timer = 0 }
		mapvar = { lives = 3, score = 0, tmp = {}, game_timer = 0, }
	end
	mapvar.char = {}
	mapvar.char.SOH = 1
	mapvar.char.UNYL = 2
	local map_script = "scripts/"..map_name..".lua"
    Log('loading game:', map_script)
	local result, success = loadfile(map_script)
	if result then
		success, result = pcall(result)
	else	
		result = success
		success = nil
	end
	if success then
		Loader.level = result
		Loader.level.SetLoader(Loader)
		-- starting mission
		Loader.state = 'new'

		Loader.gameInit()
		if not Loader.missionThread then 
			Loader.missionThread = NewThread( Loader.mainLoop );
			Resume(Loader.missionThread);
		end
		return true
	else
		return false, "Failed to load map: "..result
	end
end

function Loader.restartGame()    
    --  hiding irrelevant widgets
    StopMapThreads()
    if Loader.level and Loader.level.cleanUp then Loader.level.cleanUp() end
	if GUI.game_over_widgets then GUI.game_over_widgets:show(false) end
    Menu:hide()

	--
	
    mapvar = {}
	stat.tmp = nil
	mapvar = shallow_copy(stat)
	mapvar.tmp = {}
	mapvar.char = {}
	mapvar.char.SOH = 1
	mapvar.char.UNYL = 2
    

    TogglePause();
    Menu.mn = false;
    mapvar.lives = stat.lives or 3;
        
    Loader.level = dofile("scripts/"..Loader.map_name..".lua")
    Loader.level.SetLoader(Loader)
    
    Loader.gameInit()
end

-- Вызывается для смены уровня на уровень new_level
function Loader.ChangeLevel(new_level)
	StopMapThreads()
    mapvar.threads = nil    --Старые нити не нужны.
    mapvar.secrets = nil    --Секреты с прошлой картой - тем более.
    mapvar.tmp = nil         -- Временное на то и временное.
	--stat = shallow_copy( mapvar )
	for k,v in pairs(mapvar) do stat[k] = v end
	Loader.savePlrInfo()
    
    Loader.map_name = new_level

    Loader.restartGame()
end

function Loader.exitGame()
    -- destroying all widgets
    StopMapThreads()
    StopBackMusic()
    GUI:hide()
    GUI.gc:destroy()
    GUI.widgetContainer:destroy()
    GUI.game_over_widgets:destroy()
    Menu.mn = false
    GUI:destroy()
    if not mapvar or  not mapvar.score then
        mapvar.score = 0;
        mapvar.lives = 3;
    end
    -- leaving mission
	if Loader.level and Loader.level.cleanUp then Loader.level.cleanUp() end
	Loader.level = nil
	Loader.state = ''    --idling mainLoop thread
    DestroyGame()        -- destroying level
    Menu.showMainMenu()
end


function Loader.savePlrInfo()
	if mapvar.char then
		local plr = { GetPlayer(1), GetPlayer(2) }
		if not stat then stat = {} end
		if not stat.plr then stat.plr = {} end
		--Log("savePlrInfo", serialize("plr", plr))
		for key, value in pairs(plr) do 
			if value and type(key)=="number" then
				--Log("key - ", key)
				
				local k
				for kk, kv in pairs(mapvar.char) do
					if kv == key then k = kk; break; end
				end
				
				if k then
					stat.plr[k] = {}
					stat.plr[k].altWeaponName = value.altWeaponName
					stat.plr[k].ammo = value.ammo
					stat.plr[k].health = value.health
					stat.plr[k].active = value.active
					stat.plr[k].altWeaponActive = value.altWeaponActive
				end
			end
		end
		--Log("savePlrInfo", serialize("stat.plr ", stat.plr ))
	end
end

function Loader.loadPlrInfo()
	if stat and stat.plr and mapvar.char then
		--Log("loadPlrInfo", serialize("stat.plr", stat.plr))
		--Log("loadPlrInfo", serialize("mapvar.char", mapvar.char))
		for key, value in pairs(stat.plr) do 
			if value and mapvar.char[key] then
				local k = mapvar.char[key]
				--Log("loadPlrInfo k  ", k, " = key ", key) 
				SetPlayerAltWeapon(k, value.altWeaponName or "")
				SetPlayerAmmo(k, value.ammo or 0)
				SetPlayerHealth(k, value.health or 100)
				if ( value.altWeaponActive ) then SwitchWeapon( k ) end
				stat.plr[key].altWeaponActive = value.altWeaponActive
			end
		end
	end
	mapvar.plr = nil
end

------------------------------- main script game loop  ---------------------------------------------------
function Loader.mainLoop()
    while true do
        if Loader.state == 'new' then
            Loader.state = 'game'
            Loader.gameOverShown = false
			Menu.goshown = false
            GUI:init()
        elseif Loader.state == 'game' then
            Loader.ingame()
        elseif Loader.state == 'game over' then
            Loader.showGameOver()
        end
        Wait(1)
    end
end

function Loader.keyProcessor( key )
	if key == keys["tilde"] and not Console.shown then
		Console.toggle()
	elseif key == keys.p then
		Log( string.format( "coord: %f %f", GetMousePos() ) )
	elseif Loader.state == 'game' and IsConfKey(key, config_keys.gui_nav_menu) and ( not Menu.locked or not Menu.locked[#Menu.locked] ) then
		Menu.mn = not Menu.mn
	        if Menu.mn then
		    push_pause( true )
	            Menu:show(3)
        	else
		    pop_pause()
        	    Menu:hide()
	        end		
	end
	for tkey, value in pairs(Loader.slaveKeyProcessors) do
		value( key )
	end
	if Loader.bind[key] then Loader.bind[key]() end
end

function Loader.keyReleaseProcessor(key)
	
	for tkey, value in pairs(Loader.slaveKeyReleaseProcessors) do
		value( key )
	end
end

function Loader.ingame()
	local player = GetPlayer()
    local hp = (player and player.health) and player.health or 0 
    if not Editor or not Editor.active then
	    Loader.level.MapScript(player)
    end
    Loader.omb = ButtonPressed(CONFIG.key_conf[1].gui_nav_menu)
    if Heartbeat and not Editor or not Editor.active then Heartbeat() end

	if dbg then dbg.process() end
	
    local t = GetCurTime()
	
    if not ( GamePaused() ) then
        Loader.dt = t - Loader.old_time
        Loader.time = Loader.time + Loader.dt
		if Loader.game_timer_enabled and GetPlayerControlState() then 
			mapvar.game_timer = mapvar.game_timer + Loader.dt
		end
    end
    Loader.old_time = t
end

-- Вызывается, когда игрок умер, в момент уничтожения объекта игрока, так что GetPlayer уже не отработает
-- old_plr_info - таблица с информацией об объекте игрока. num - его номер (1 или 2)
function Loader.onPlayerDeath(old_plr_info, num)
    mapvar.lives = mapvar.lives - 1
    mapvar.sync = 0
    if mapvar.lives > 0 then
        local plr_id = RevivePlayer(num, nil);
        SetCamAttachedObj(plr_id)
        -- Восстанавливаем игроку оружие и патроны
        SetPlayerAltWeapon(num, old_plr_info.altWeaponName)
        SetPlayerAmmo(num, old_plr_info.ammo)
        inv = num
        if ( old_plr_info.altWeaponActive ) then
            SwitchWeapon( num )
        end
    else
        Loader.state = 'game over'
    end
end

function Loader.showGameOver()
	if not Menu.goshown then
		Menu.goshown = true
		Menu.showGameOver()
		Menu:show(7)
	end
end


return Loader
