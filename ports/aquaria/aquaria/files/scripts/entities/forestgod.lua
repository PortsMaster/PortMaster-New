-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

local STATE_EYESOPEN 		= 1000
local STATE_DIE			= 1001
local STATE_TENTACLES 	= 1002
local STATE_SEED 			= 1003
local STATE_DONE		= 1004
local STATE_FIRESEEDS	= 1005
local STATE_FIRESPIKY	= 1006
local STATE_SINGNOTE	= 1007
local STATE_VINES		= 1008
local STATE_RAGE		= 1009

v.curCurrent = 0
v.c1 = 0
v.c2 = 0

v.delay = -3
v.eyes = 0
v.bone_bg = 0
v.door = 0
v.noteTimer = 0

v.rageState = 0

v.config = 0

v.lastPlayerNote = 0


-- NOTE: forest goddess has two health bars

-- phase 1 health
v.maxHits = 50
v.hits = v.maxHits

-- phase 2 health
v.maxRageHits = 70
v.rageHits = v.maxRageHits

v.n = 0
v.stage = 0
v.seedDelay = 0
v.seedNode = 0
v.started = false
v.enter = 0

v.sungNote = -1

v.noteQuad = 0

v.vh1 = 0
v.vh2 = 0
v.vh3 = 0



v.shotOff = 0
v.rageShotMax = 1000
v.rageShotStart = -v.rageShotMax
v.rageShotPos = 0
v.rageShotAdd = 100
v.ba = 0

v.b1 = 0
v.b2 = 0
v.b3 = 0
v.b4 = 0

v.bd = 1

local function clearVines()
	playSfx("vineshrink")
	local e = getFirstEntity()
	while e ~= 0 do
		if eisv(e, EV_TYPEID, EVT_FORESTGODVINE) then
			entity_delete(e, 0.3)
		end
		e = getNextEntity()
	end
end

local function spawnVines(me, num)
	local v1, v2, v3
	if v.config == 0 then
		v1 = getNode("V1")
		v2 = getNode("V2")
		v3 = getNode("V3")
	elseif v.config == 1 then
		v1 = getNode("V4")
		v2 = getNode("V5")
		v3 = getNode("V1")
	elseif v.config == 2 then
		v1 = getNode("V2")
		v2 = getNode("V4")
		v3 = getNode("V1")
	end
	v.config = v.config + 1
	if v.config > 2 then
		v.config = 0
	end
	if num >= 1 then
		v.vh1 = createEntity("ForestGodVineHead", "", node_x(v1), node_y(v1))
	end
	if num >= 2 then
		v.vh2 = createEntity("ForestGodVineHead", "", node_x(v2), node_y(v2))
	end
	if num >= 3 then
		v.vh3 = createEntity("ForestGodVineHead", "", node_x(v3), node_y(v3))
	end
	playSfx("UberVineShrink")
end

function init(me)
	-- NOTE: HEALTH IS SET IN HITS AND MAXHITS
	setupBasicEntity(
	me,
	"",								-- texture
	99,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	128,							-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,						-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	6000,							-- updateCull -1: disabled, default: 4000
	-3
	)
	
	entity_setCull(me, false)
	entity_initSkeletal(me, "ForestGod")
	entity_generateCollisionMask(me)	
	
	entity_animate(me, "idle", LOOP_INF)
	
	entity_setDeathParticleEffect(me, "ForestGodExplode")
	
	
	
	v.eyes = entity_getBoneByName(me, "eyes")
	v.bone_bg = entity_getBoneByName(me, "bg")
	
	bone_alpha(v.eyes, 0)
	
	entity_setTargetPriority(me, 1)	
	entity_setTargetRange(me, 300)
	
	--entity_scale(me, 5.5, 5.5)
	entity_scale(me, 3.2, 3.2)
	
	entity_setState(me, STATE_IDLE)
	entity_setTarget(me, getNaija())
	
	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setAllDamageTargets(me, false)
	
	v.node_seed1 = entity_getNearestNode(me, "SEED1")
	v.node_seed2 = entity_getNearestNode(me, "SEED2")
	v.node_seed3 = entity_getNearestNode(me, "SEED3")
	v.node_seed4 = entity_getNearestNode(me, "SEED4")
	
	
	esetv(me, EV_ENTITYDIED, 1)
	
	loadSound("ForestGod-Awaken")
	
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
	
	local cc1 = getNode("cc1")
	local cc2 = getNode("cc2")
	
	v.c1 = getNearestNodeByType(node_x(cc1), node_y(cc1), PATH_CURRENT)
	v.c2 = getNearestNodeByType(node_x(cc2), node_y(cc2), PATH_CURRENT)
	
	node_setActive(v.c1, true)
	node_setActive(v.c2, false)
	
	v.curCurrent = 1
end

function entityDied(me, ent)
	if ent == v.vh1 then
		v.vh1 = 0
	end
	if ent == v.vh2 then
		v.vh2 = 0
	end
	if ent == v.vh3 then
		v.vh3 = 0
	end
end

function postInit(me)
	v.door = entity_getNearestEntity(me, "VineDoor")
	entity_setState(v.door, STATE_OPENED)
	v.enter = getNode("NAIJAENTER")
	if not isFlag(FLAG_BOSS_FOREST,0) then
		entity_setState(me, STATE_DONE)
		setMusicToPlay("")
	end
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	if entity_isFlag(me, 1) then
		setControlHint(getStringBank(40), 0, 0, 0, 10, "", SONG_NATUREFORM)
		entity_setFlag(me, 2)
	end
end

v.inCutScene = false
local function cutscene(me)
	v.n = getNaija()
	if not v.inCutScene then
		v.inCutScene = true
		pickupGem("Boss-PlantGoddess")
		setFlag(FLAG_BOSS_FOREST,1)
		local ent = getFirstEntity()
		while ent ~= 0 do
			--if entity_isName(ent, "UberVine")
			if entity_isName(ent, "SpikyBall")
			or entity_isName(ent, "SporeSeed") then
				entity_setDieTimer(ent, 0.2)
			end
			ent = getNextEntity()
		end
		watch(1)
		changeForm(FORM_NORMAL)
		--fadeOutMusic(4)
		entity_idle(v.n)
		entity_flipToEntity(v.n, me)
		local pn = getNode("NAIJADONE")
		entity_animate(v.n, "agony", LOOP_INF)
		watch(2)
		learnSong(SONG_NATUREFORM)
		entity_setPosition(v.n, node_x(pn), node_y(pn), 2, 0, 0, 1)
		watch(2)
		entity_setFlag(me, 1)
		loadMap("ForestVision")
		--[[
		showImage("Visions/Forest/00")
		watch(0.5)
		voice("Naija_Vision_Forest")
		watchForVoice()
		hideImage()
		
		watch(2)
		entity_idle(v.n)
		changeForm(FORM_NATURE)
		voice("Naija_Song_NatureForm")
		entity_idle(v.n)
		entity_setState(door, STATE_OPEN)
		--watchForVoice()
		-- show help text
		]]--
	end
end

function update(me, dt)

	if isNested() then
		return
	end
	
	if entity_isState(me, STATE_DIE) or entity_isState(me, STATE_DONE) then
		return
	end
	
	if v.noteTimer > 0 then
		--debugLog(string.format("noteTimer: %f", v.noteTimer))
		v.noteTimer = v.noteTimer - dt
		if v.noteTimer <= 0 then
			--debugLog(string.format("sungNote: %d, lastPlayerNote: %d", v.sungNote, v.lastPlayerNote))
			if v.sungNote == v.lastPlayerNote then
				entity_setState(me, STATE_EYESOPEN)
			end
		end
	end
	
	if v.started then
		overrideZoom(0.4, 1)
	end
	if not entity_isState(me, STATE_DIE) and not entity_isState(me, STATE_DONE) then
		entity_handleShotCollisions(me, dt)
		if entity_isEntityInRange(me, v.n, 128) then
			--entity_hurtTarget(me, 1)
			entity_setTarget(me, v.n)
			entity_pushTarget(me, 400)
		end
	end
	
	if entity_isState(me, STATE_SEED) then
		v.seedDelay = v.seedDelay + dt
		if v.seedDelay > 2 then
			local node = 0
			if v.seedNode == 0 then
				node = v.node_seed1
			elseif v.seedNode == 1 then
				node = v.node_seed2
			elseif v.seedNode == 2 then
				node = v.node_seed3
			elseif v.seedNode == 3 then
				node = v.node_seed4
			end
			createEntity("ForestGodSeed", "", node_x(node), node_y(node))
			v.seedNode = v.seedNode + 1
			if v.seedNode > 3 then
				v.seedNode = 0
			end
			v.seedDelay = 0
		end			
	end
	
	if isFlag(FLAG_BOSS_FOREST, 0) and node_isEntityIn(v.enter, v.n) then
		if not v.started then
			v.started = true
			entity_setState(v.door, STATE_CLOSE)
			playMusic("ForestGod")
		end
	else
		overrideZoom(0)
	end
	
	if entity_isState(me, STATE_TENTACLES) and not entity_isAnimating(me) then
		entity_setState(me, STATE_IDLE)
	end
	
	
	if entity_isState(me, STATE_RAGE) and v.started then
		v.delay = v.delay + dt
		
		if v.delay >= 18 and v.rageState ~= 0 then
			v.rageState = 0
			v.delay = 0
			
			clearVines()
			
			fade2(1,0,1,1,1)
			fade2(0,0.5,1,1,1)
			v.bd = -v.bd
			
		elseif v.delay >= 9 and v.rageState < 2 then
			v.rageState = 2
			
			spawnVines(me, 2)
		elseif v.delay >= 3 and v.rageState < 1 then
		

			v.rageState = 1
			
			v.fireDelay = 999
			
			v.rageShotPos = v.rageShotStart + v.shotOff
			v.shotOff = math.random(50)-100
		end
		if v.rageState == 1 then
			
			v.fireDelay = v.fireDelay + dt
			if v.fireDelay > 0.3 then
				v.fireDelay = 0
	
				
				local s = createShot("ForestGod2", me, 0, entity_x(me)+v.rageShotPos, entity_y(me)-520)
				shot_setAimVector(s, 0, 400)
				v.rageShotPos = v.rageShotPos + v.rageShotAdd
				if v.rageShotPos >= (v.rageShotMax+v.shotOff) then
					v.fireDelay = -1000
				end
			end
		end
		
		v.ba = v.ba + 3.14*0.4*dt*v.bd
		local off = 3.14/2
		local out = 200
		entity_setPosition(v.b1, entity_x(me) + out*math.sin(v.ba+off*0), entity_y(me) + out*math.cos(v.ba+off*0))
		entity_setPosition(v.b2, entity_x(me) + out*math.sin(v.ba+off*1), entity_y(me) + out*math.cos(v.ba+off*1))
		entity_setPosition(v.b3, entity_x(me) + out*math.sin(v.ba+off*2), entity_y(me) + out*math.cos(v.ba+off*2))
		--entity_setPosition(v.b4, entity_x(me) + out*math.sin(ba+off*3), entity_y(me) + out*math.cos(ba+off*3))
	end
	
	
	if entity_isState(me, STATE_IDLE) and v.started then
	
	--[[
		if isLeftMouse() then
			entity_setState(me, STATE_RAGE)
		end
	]]--
		
		v.delay = v.delay + dt
		if v.delay > 4 then
			--debugLog("delay > 0!!")
			v.delay = 0
			
			local t = 3
			local t2 = 10
			if v.hits/v.maxHits < 0.5 then
				t = 1.5
				t2 = 5
			end
			--entity_setState(me, STATE_SEED, 9)
			if v.stage == 0 then
				--entity_setState(me, STATE_FIRESEEDS, t)
				entity_setState(me, STATE_FIRESPIKY, t)
				
			--elseif v.stage == 1 then
				
			elseif v.stage == 1 then
				entity_setState(me, STATE_VINES, t2)
			elseif v.stage == 2 then
				entity_setState(me, STATE_SINGNOTE, t2)
			end
			--[[
			if v.stage == 0 then
				entity_setState(me, STATE_TENTACLES)
			elseif v.stage == 1 then
				entity_setState(me, STATE_EYESOPEN, 2)
			elseif v.stage == 2 then
				entity_setState(me, STATE_TENTACLES)
			elseif v.stage == 3 then
				entity_setState(me, STATE_SEED, 9)
			end
			]]--
			v.stage = v.stage + 1
			if v.stage > 2 then
				v.stage = 0
			end
		end
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_EYESOPEN) then
		playSfx("ForestGod-Awaken")
		
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
		bone_alpha(v.eyes, 1, 0.1)
		
		local shotSpd = 500
		local maxa = 3.14 * 2
		local a = 0
		while a < maxa do
			--entity_fireShot(me, 0, 0, math.sin(a)*shotSpd, math.cos(a)*shotSpd, 0, 500, "BlasterFire")
			local s = createShot("ForestGod", me, 0)
			shot_setAimVector(s, math.sin(a), math.cos(a))
			a = a + (3.14*2)/16.0
		end
		entity_setStateTime(me, 5.5)
		
		v.curCurrent = v.curCurrent + 1
		if v.curCurrent > 2 then
			v.curCurrent = 1
		end
		
		if v.curCurrent == 1 then
			node_setActive(v.c1, true)
			node_setActive(v.c2, false)
		elseif v.curCurrent == 2 then
			node_setActive(v.c1, false)
			node_setActive(v.c2, true)
		end
		
	elseif entity_isState(me, STATE_RAGE) then
		setSceneColor(1, 0.7, 0.7, 6)
		shakeCamera(10, 3)
		entity_color(me, 1, 0.5, 0.5, 3)
		v.delay = 0
		v.rageState = 0
		bone_alpha(v.eyes, 1, 0.1)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
		
		v.b1 = createEntity("spikyblocker", "", entity_x(me), entity_y(me))
		v.b2 = createEntity("spikyblocker", "", entity_x(me), entity_y(me))
		v.b3 = createEntity("spikyblocker", "", entity_x(me), entity_y(me))
		--v.b4 = createEntity("spikyblocker", "", entity_x(me), entity_y(me))
	elseif entity_isState(me, STATE_FIRESEEDS) then
		local shotSpd = 1000
		
		local a = 0 + math.random(314)/10.0
		local maxa = a + 3.14 * 2
		while a < maxa do
			local vx = math.sin(a)*shotSpd
			local vy = math.cos(a)*shotSpd
			local dx,dy = vector_setLength(vx, vy, 64)

			local s = createShot("SeedUberVineUnlimited", me, 0, entity_x(me)+dx, entity_y(me)+dy)
			shot_setAimVector(s, vx, vy)
			
			--local ent = createEntity("SporeSeed", "", entity_x(me)+dx, entity_y(me)+dy)
			--entity_setDieTimer(ent, 12)

			--entity_setState(ent, STATE_CHARGE2)
			--entity_addVel(ent, vx, vy)
			
			local perc = v.hits/v.maxHits
			--debugLog(string.format("perc: %f", perc))
			if perc < 0.25 then
				a = a + (3.14*2)/20.0
			elseif perc < 0.5 then
				a = a + (3.14*2)/12.0
			else
				a = a + (3.14*2)/6.0
			end
		end	
	elseif entity_isState(me, STATE_FIRESPIKY) then
		local shotSpd = 800
		
		local a = 0 + math.random(314)/10.0
		local maxa = a + 3.14 * 2
		while a < maxa do
			local vx = math.sin(a)*shotSpd
			local vy = math.cos(a)*shotSpd
			local dx,dy = vector_setLength(vx, vy, 128)
			
			local ent = createEntity("SpikyBall", "", entity_x(me)+dx, entity_y(me)+dy)
			
			entity_setBounceType(ent, BOUNCE_REAL)
			entity_setBounce(ent, 1)
			entity_setDieTimer(ent, 6.5)
			--entity_setLife(ent, 7)
			
			entity_setState(ent, STATE_CHARGE1)
			entity_addVel(ent, vx, vy)
			
			local perc = v.hits/v.maxHits
			if perc < 0.25 then
				a = a + (3.14*2)/8.0
			elseif perc < 0.75 then
				a = a + (3.14*2)/6.0
			else
				a = a + (3.14*2)/4.0
			end
		end			
	elseif entity_isState(me, STATE_IDLE) then
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)

		bone_alpha(v.eyes, 0, 0.2)
	elseif entity_isState(me, STATE_TENTACLES) then
		entity_animate(me, "tentacles")
	elseif entity_isState(me, STATE_SEED) then
		v.delay = 0.5
	elseif entity_isState(me, STATE_DIE) then		
		setSceneColor(0.7, 0.8, 1, 4)
		
		shakeCamera(2, 4)
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
		--debugLog("state die!!!")
		entity_setColor(me, 0.5, 0.5, 0.8, 4)
		--bone_setColor(v.eyes, 0.5, 0.5, 0.8, 4)
		bone_alpha(v.eyes, 1)
		bone_alpha(v.eyes, 0, 1)
		entity_setStateTime(me, 4)
		
		clearVines()
		
		if v.b1 ~= 0 then entity_delete(v.b1) end
		if v.b2 ~= 0 then entity_delete(v.b2) end
		if v.b3 ~= 0 then entity_delete(v.b3) end
		if v.b4 ~= 0 then entity_delete(v.b4) end
		
		fadeOutMusic(4)
		
	elseif entity_isState(me, STATE_SINGNOTE) then
		v.sungNote = math.random(8)-1
		entity_sound(me, string.format("Note%d", v.sungNote), 500, entity_getStateTime(me))
		v.noteQuad = createQuad(string.format("Song/NoteSymbol%d", v.sungNote), 6)
		quad_alpha(v.noteQuad, 0)
		quad_alpha(v.noteQuad, 0.8, 2)
		quad_scale(v.noteQuad, 3, 3, 2, 0, 0, 1)
		quad_setBlendType(v.noteQuad, BLEND_ADD)
		
		local r,g,b = getNoteColor(v.sungNote)
		quad_color(v.noteQuad, r*0.8 + 0.2, g*0.8+0.2, b*0.8+0.2)
		
		local x,y = entity_getPosition(me)
		quad_setPosition(v.noteQuad, x, y+130)
	elseif entity_isState(me, STATE_DONE) then
		
		entity_setColor(me, 0.5, 0.5, 0.8)
		--bone_setColor(v.eyes, 0.5, 0.5, 0.8)
		bone_alpha(v.eyes, 0)
		v.hits = 0
		
		node_setActive(v.c1, false)
		node_setActive(v.c2, false)
	elseif entity_isState(me, STATE_VINES) then
		local num = 1
		local perc = v.hits/v.maxHits
		if perc < 0.5 then
			num = 3
		elseif perc < 0.75 then
			num = 2
		end
		
		spawnVines(me, num)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if attacker == me then
		return false
	end
	
	if entity_isState(me, STATE_EYESOPEN) then		
		bone_damageFlash(v.bone_bg)
		bone_damageFlash(v.eyes)
		v.hits = v.hits - dmg
		--debugLog(string.format("hits: %d", v.hits))
		if v.hits <= 0 then
			--debugLog("setting state die...")
			--entity_setState(me, STATE_DIE)
			entity_setState(me, STATE_RAGE)
		else
			--entity_setState(me, STATE_IDLE)
		end
		--return true
	end
	if entity_isState(me, STATE_RAGE) then
		bone_damageFlash(v.bone_bg)
		bone_damageFlash(v.eyes)
		v.rageHits = v.rageHits - dmg
		if v.rageHits <= 0 then
			entity_setState(me, STATE_DIE)
		end
		
		
	end
	return false
end

function exitState(me, state)
	if entity_isState(me, STATE_EYESOPEN) then
		clearShots()
		entity_setState(me, STATE_IDLE)
		shakeCamera(2, 3)
	elseif entity_isState(me, STATE_SINGNOTE) then
		v.sungNote = -1
		entity_setState(me, STATE_IDLE)
		if v.noteQuad ~= 0 then
			quad_delete(v.noteQuad, 0.5)
			v.noteQuad = 0
		end
	elseif entity_isState(me, STATE_VINES) then
		entity_setState(v.vh1, STATE_OFF)
		entity_setState(v.vh2, STATE_OFF)
		entity_setState(v.vh3, STATE_OFF)
		v.vh1 = 0
		v.vh2 = 0
		v.vh3 = 0
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_SEED) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_FIRESEEDS) or entity_isState(me, STATE_FIRESPIKY) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_DIE) then
		overrideZoom(0)
		cutscene(me)
		entity_setState(me, STATE_DONE)
	end
end

function songNote(me, note)
	v.lastPlayerNote = note
	v.noteTimer = 0.5
end

function songNoteDone(me, note, t)
	v.noteTimer = 0
end
