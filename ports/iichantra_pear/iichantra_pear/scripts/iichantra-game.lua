last_heartbeat_time = 0

function Heartbeat()
	if (GetCurTime() or 0) - last_heartbeat_time < 1000 then return end
	if (GamePaused()) then return end
	last_heartbeat_time = (GetCurTime() or 0)

	if not GetPlayer() then return end
	-- if not mapvar.sync then 
		-- mapvar.sync = 0
	-- end
	-- SOH >0, Unyl < 0
	-- ds = 0.2
	-- local plnum = GetPlayerNum()
	-- if  plnum == 2 then
		-- ds = -0.2
	-- end
--Halloween: no need for sync
	-- ds = 0
	-- if mapvar.weapon and mapvar.weapon[mapvar.active_char or "CIRNO"] == "bonus_sync" then
		-- ds = 0
	-- end
	-- if (ds*mapvar.sync < 0) or (mapvar.sync == 0 and ds<0) then
		-- ds = ds * (difficulty or 1)
	-- else
		-- ds = ds / (difficulty or 1)
	-- end
	-- mapvar.sync = mapvar.sync + ds
	-- if mapvar.sync > 30 then mapvar.sync = 30 end
	-- if mapvar.sync < -30 then mapvar.sync = -30 end
	
	-- local char = {}
	-- char[1] = GetPlayer(1)
	-- char[2] = GetPlayer(2)

	-- if mapvar.sync > 17 or mapvar.sync < -17 then
		-- PlaySnd( "sync-siren.ogg", true )
	-- end
	-- if mapvar.sync < -20 and plnum == 2 then
		-- DamageObject(char[2].id, 5*math.floor(mapvar.sync/(-10))*(difficulty or 1))
	-- end
	-- if mapvar.sync > 20 and plnum == 1 then
		-- DamageObject(char[1].id, 5*math.floor(mapvar.sync/10)*(difficulty or 1))
	-- end

	
	local char = GetPlayer(mapvar.char[mapvar.active_char] or 10)
	if char and mapvar.weapon then
	-- for i=1,2 do
		if mapvar.weapon[mapvar.active_char] == "bonus_ammo" then
			AddBonusAmmo(char.id, 30)
		elseif mapvar.weapon[mapvar.active_char] == "bonus_health" then
			AddBonusHealth(char.id, 20)
		end
	end
end

function StabilizeSync( id, ammount )
	local bonus = -1
	if mapvar.sync < 0 then
		bonus = 1
	end
	mapvar.sync = mapvar.sync + bonus*math.min(math.abs(mapvar.sync), ammount)
end

function CharacterSystem( old_id, new_id )
	
	local char1 = GetPlayer(1).id
	local char2 = GetPlayer(2).id
	local diff = ((difficulty or 1)-1)/5+1;

	if new_id == char2 then
		--changing to Unyl-chan	
		k = ( 30 + mapvar.sync ) / 30
		mapvars = { jump_vel = 10+1.5*k, walk_acc=2.25+k/2, max_health=120/(difficulty or 1), max_x_vel = (2.25+k/2) }
		ReplacePrimaryWeapon(old_id, "sfg9000")
		if mapvar.sync > 20 and secrets then
			for key, value in pairs(secrets) do
				SetObjAnim(value, "secret", false)
			end
			if Loader and Loader.level and Loader.level.placeSecrets then
				Loader.level.placeSecrets()
			end
		end
	else
		k = ( 30 - mapvar.sync ) / 30	
		mapvars = { jump_vel = 10, walk_acc=2.25, max_health=(120+80*k)/(difficulty or 1), max_x_vel = 2.25 }
		if mapvar.sync < -20 then
			ReplacePrimaryWeapon(new_id, "rapid")
		end
		if secrets then
			for key, value in pairs(secrets) do
				SetObjAnim(value, "normal", false)
			end
			if Loader and Loader.level and Loader.level.removeSecrets then
				Loader.level.removeSecrets()
			end
		end
	end
	--Log(serialize("mapvars", mapvars))

	if not mapvar.bonuses then mapvar.bonuses = {} end
	if not mapvar.weapon then mapvar.weapon = {} end
	do	-- определение active_char
		local active_num = iff( new_id == char1, 1, 2 )
		local active_char = "CIRNO"
		for kk, kv in pairs(mapvar.char) do
			if kv == active_num then active_char = kk; break; end
		end
		mapvar.active_char = active_char
		
		if Loader.level.char then 
			mapvar.active_char = Loader.level.char
		end
	end

	mapvar.bonuses[0] = mapvar.bonuses[mapvar.active_char]
	mapvar.weapon[0] = mapvar.weapon[mapvar.active_char]
	

	SetPlayerStats(new_id, mapvars)
end

function varchange( varname, change )
	if varname == "score" then
		if not mapvar.next_life then mapvar.next_life = 5000 end
		if mapvar.score >= mapvar.next_life then
			mapvar.lives = mapvar.lives + 1
			mapvar.next_life = mapvar.next_life * 2
		end
		mapvar.score = math.min( mapvar.score, 10000-(mapvar.score_part_two or 10000)+change, ((mapvar.score_part_three or 0)/(-2))+change )
		mapvar.score_part_two = 10000 - mapvar.score
		mapvar.score_part_three = -2*mapvar.score
	end
end

function BonusCombo( first, second, what1, what2 )
	return ( (what1 == first) and (what2 == second) ) or ( (what1 == second) and (what2 == first) )
end

function RemoveDoubleBonus( player_name, bonus_type, char1_id, char2_id )
	Wait(10000)
	if bonus_type == "bonus_speed" then
		-- Тут все равно обоим чарам меняется скорость, так что не нужны заморочки с определением активного чара
		local char1 = GetPlayer(1)
		local char2 = GetPlayer(2)
		if (char1 and char1.id == char1_id) then AddBonusSpeed(char1.id, -3) end
		if (char2 and char2.id == char2_id) then AddBonusSpeed(char2.id, -3) end
	elseif bonus_type == "bonus_invul" then
		local num = mapvar.char[player_name]
		if num == 1 or num == 2 then 
			SetObjInvincible(GetPlayer(num).id, false)
		end
	end
	mapvar.weapon[player_name] = nil
	if player_name == mapvar.active_char then mapvar.weapon[0] = nil end
end

function WeaponSystem( id, weapon )

	if Loader and Loader.level and Loader.level.WeaponBonus then
		Loader.level.WeaponBonus( id, weapon )
	end
	
	local char1 = (GetPlayer(1) or { id = -1 })
	local char2 = (GetPlayer(2) or { id = -1 })
	
	do	-- определение active_char
		local active_num = iff( id == char1.id, 1, 2 )
		local active_char = "CIRNO"
		for kk, kv in pairs(mapvar.char) do
			if kv == active_num then active_char = kk; break; end
		end
		mapvar.active_char = active_char
		
		if Loader.level.char then 
			mapvar.active_char = Loader.level.char
		end
	end
	
	if not mapvar.bonuses then mapvar.bonuses = {} end
	

	if not mapvar.bonuses[mapvar.active_char ] then mapvar.bonuses[mapvar.active_char ] = {} end

	local bt = mapvar.bonuses[mapvar.active_char ]
	if #bt == 2 then
		table.remove(bt, 1)
	end
	if not mapvar.weapon then mapvar.weapon = {} end
	table.insert( bt, weapon )
	if mapvar.active_char and #bt == 2 then
		--circle
		if BonusCombo("circle", "triangle", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "flamer"
			mapvar.weapon[0] = "flamer"
			return "flamer"
		end
		if BonusCombo("circle", "square", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "grenade"
			mapvar.weapon[0] = "grenade"
			return "grenade"
		end
		if BonusCombo("circle", "diamond", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "overcharged"
			mapvar.weapon[0] = "overcharged"
			return "overcharged"
		end
		if BonusCombo("circle", "line", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bouncy"
			mapvar.weapon[0] = "bouncy"
			return "bouncy"
		end

		--square (not enix)
		if BonusCombo("square", "triangle", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "rocketlauncher"
			mapvar.weapon[0] = "rocketlauncher"
			return "rocketlauncher"
		end
		if BonusCombo("square", "diamond", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "fragmentation"
			mapvar.weapon[0] = "fragmentation"
			return "fragmentation"
		end
		if BonusCombo("square", "line", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "twinshot"
			mapvar.weapon[0] = "twinshot"
			return "twinshot"
		end

		--triangle
		if BonusCombo("triangle", "line", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "wave"
			mapvar.weapon[0] = "wave"
			return "wave_weapon"
		end
		if BonusCombo("triangle", "diamond", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "spread"
			mapvar.weapon[0] = "spread"
			return "spread"
		end

		--line
		if BonusCombo("line", "diamond", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "mikuru_beam"
			mapvar.weapon[0] = "mikuru_beam"
			return "mikuru_beam"
		end

		--check out mah doubles
		if BonusCombo("circle", "circle", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bonus_sync"
			mapvar.weapon[0] = "bonus_sync"
			mapvar.sync = 0
			mapvar.bonuses[mapvar.active_char ] = {}
			Resume(NewThread(RemoveDoubleBonus), mapvar.active_char , "bonus_sync")
		end
		if BonusCombo("square", "square", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bonus_ammo"
			mapvar.weapon[0] = "bonus_ammo"
			mapvar.bonuses[mapvar.active_char ] = {}
			mapvar.bonus_thread = NewThread(RemoveDoubleBonus)
			Resume(NewThread(RemoveDoubleBonus), mapvar.active_char , "bonus_ammo")
		end
		if BonusCombo("triangle", "triangle", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bonus_speed"
			mapvar.weapon[0] = "bonus_speed"
			AddBonusSpeed(char1.id, 3)
			AddBonusSpeed(char2.id, 3)
			mapvar.bonuses[mapvar.active_char ] = {}
			mapvar.bonus_thread = NewThread(RemoveDoubleBonus)
			Resume(NewThread(RemoveDoubleBonus), mapvar.active_char , "bonus_speed", char1.id, char2.id)
		end
		if BonusCombo("diamond", "diamond", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bonus_invul"
			mapvar.weapon[0] = "bonus_invul"
			SetObjInvincible(id, true)
			mapvar.bonuses[mapvar.active_char ] = {}
			mapvar.bonus_thread = NewThread(RemoveDoubleBonus)
			Resume(NewThread(RemoveDoubleBonus), mapvar.active_char , "bonus_invul")
		end
		if BonusCombo("line", "line", bt[1], bt[2]) then
			mapvar.weapon[mapvar.active_char ] = "bonus_health"
			mapvar.weapon[0] = "bonus_health"
			mapvar.bonuses[mapvar.active_char ] = {}
			mapvar.bonus_thread = NewThread(RemoveDoubleBonus)
			Resume(NewThread(RemoveDoubleBonus), mapvar.active_char , "bonus_health")
		end

	end
	return nil
end

SetOnChangePlayerProcessor(CharacterSystem);

