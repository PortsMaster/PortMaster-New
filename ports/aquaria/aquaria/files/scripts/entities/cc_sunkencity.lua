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

v.n = 0

v.node_start		= 0
v.node_climbdown	= 0
v.node_runaway		= 0
v.node_inhole		= 0
v.node_gf			= 0
v.node_bullies		= 0
v.node_mom			= 0
v.node_gotogf		= 0
v.node_insectcheck	= 0
v.node_anima		= 0
v.node_bosswait		= 0
v.node_girldoor		= 0

v.girldoor			= 0

v.bone_flowers = 0

v.mom = 0
v.gf = 0
v.clay = 0

v.leadDelay = 0

v.following			= 0
v.spawnedInsects	= false

local STATE_CREATE		= 1000

v.inAbyss = false

v.glow = 0

v.waitForSceneDelay = 0

v.abyssEndNode = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "CC")
	entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 0.6, 0.6)
	
	
	--[[
	entity_setBlendType(me, BLEND_ADD)
	entity_alpha(me, 0.5)
	entity_alpha(me, 1, 1, -1, 1, 1)
	]]--
	
	
	entity_setState(me, STATE_IDLE)
		
	v.node_start = getNode("START")
	v.node_climbdown = getNode("CLIMBDOWN")
	v.node_runaway = getNode("RUNAWAY")
	v.node_inhole = getNode("INHOLE")
	v.node_gf = getNode("GF")
	v.node_bullies = getNode("BULLIES")
	v.node_anima = getNode("ANIMA")
	v.node_gotogf = getNode("GOTOGF")
	v.node_insectcheck = getNode("INSECTCHECK")
	v.node_mom = getNode("MOM")
	
	v.node_bosswait = getNode("BOSSWAIT")
	
	--[[
	local node_girldoor = getNode("GIRLDOOR")
	v.girldoor = node_getNearestEntity(node_girldoor)
	entity_setState(v.girldoor, STATE_OPEN, -1, 1)
	]]--
	
	
	entity_setBeautyFlip(me, false)
	entity_fh(me)
	
	entity_setCullRadius(me, 256)
	
	v.abyssEndNode = getNode("CCTONGUE")
end

local function updateLocation(me)
	debugLog("updateLocation")
	local f = getFlag(FLAG_SUNKENCITY_PUZZLE)
	if isMapName("BoilerRoom") then
		--debugLog("IN BOILER ROOM")
		if f < SUNKENCITY_BOSSWAIT then
			--debugLog("setting position 0, 0")
			entity_setPosition(me, 0, 0)
		elseif f == SUNKENCITY_BOSSWAIT then
			--debugLog("setting position to bosswait")
			entity_setPosition(me, node_getPosition(v.node_bosswait))
		elseif f >= SUNKENCITY_BOSSDONE then
			entity_setPosition(me, 0, 0)
		end
		entity_animate(me, "cry", -1)
	elseif isMapName("Abyss01") then
		if f==SUNKENCITY_BOSSDONE then
			
			if v.glow == 0 then
				v.glow = createQuad("Naija/LightFormGlow", 13)
				quad_scale(v.glow, 12, 12)
			end
			
			--e = entity_getNearestEntity(me, "FinalTongue")
			--entity_setState(e, STATE_OPEN)
			
			local nd = getNode("CCLEADSTART")
			entity_setPosition(me, node_x(nd), node_y(nd))
			
			entity_animate(me, "float", -1)
			
			entity_flipToEntity(me, v.n)
			entity_flipToEntity(v.n, me)
			
			v.leadDelay = 4
			
			v.abyssEndNode = getNode("CCTONGUE")
				
			v.inAbyss = true
			
			v.waitForSceneDelay = 3
		else
			entity_alpha(me, 0)
			entity_setPosition(me, 0, 0)
		end
	elseif isMapName("SunkenCity01") then
		if f==SUNKENCITY_START then
			entity_animate(me, "draw", -1)
			entity_setPosition(me, node_getPosition(v.node_start))
		elseif f==SUNKENCITY_CLIMBDOWN then
			entity_setPosition(me, node_getPosition(v.node_climbdown))
			entity_fhTo(me, true)
			entity_animate(me, "readyToClimb", LOOP_INF)
		elseif f==SUNKENCITY_RUNAWAY then
			entity_setPosition(me, node_getPosition(v.node_runaway))
			entity_animate(me, "cry", -1)
		elseif f==SUNKENCITY_INHOLE then
			entity_setPosition(me, node_getPosition(v.node_inhole))
			entity_animate(me, "cry", -1)		
		elseif f==SUNKENCITY_GF then
			--debugLog("setting gf to state done")
			--entity_setState(gf, STATE_DONE)
			entity_setPosition(me, node_getPosition(v.node_gf))
			entity_animate(me, "cry", -1)
			entity_fh(me)
		elseif f==SUNKENCITY_BULLIES then
			entity_setPosition(me, node_getPosition(v.node_bullies))
			entity_animate(me, "cry", -1)
		elseif f==SUNKENCITY_ANIMA then
			entity_setPosition(me, node_getPosition(v.node_anima))
			entity_animate(me, "cry", -1)
		elseif f == SUNKENCITY_BOSSWAIT then
			entity_setPosition(me, 0, 0)
		end
		
		if f >= SUNKENCITY_INHOLE then
			if v.mom == 0 then
				v.mom = createEntity("CC_Mother", "", node_x(v.node_mom), node_y(v.node_mom))
				entity_fh(v.mom)
			end
		end
		if f >= SUNKENCITY_GF then
			if v.mom ~= 0 then
				entity_setState(v.mom, STATE_SING)
			end
		end
		if f>=SUNKENCITY_BOSSWAIT then
			local door = node_getNearestEntity(v.node_anima, "EnergyDoor")
			if not entity_isState(door, STATE_OPENED) then
				entity_setState(door, STATE_OPENED)
			end
			if f == SUNKENCITY_BOSSDONE then
				debugLog("BOSS DONE!")
				entity_setState(me, STATE_FOLLOW, -1, 1)
			else
				entity_alpha(me, 0.1)
				entity_setPosition(me, 0, 0)
			end
		end
	else
		if f == SUNKENCITY_BOSSDONE then
			debugLog("BOSS DONE!")
			entity_setState(me, STATE_FOLLOW, -1, 1)
		else
			entity_setPosition(me, 0, 0)
		end
	end
end

function postInit(me)
	v.n = getNaija()
	v.gf = getEntity("CC_GF")
	
	updateLocation(me)	
end

-- Both exist. Different spelling. Yay for consistency.
-- Keeping them both, should ensure behavior as it used to be, just without warnings. -- FG
v.incutscene = false
v.inCutScene = false

local function cutsceneintro(me, node)
	v.incutscene = true
	entity_idle(v.n)
	entity_flipToEntity(v.n, me)
	watch(1)
	if node ~= 0 then
		cam_toNode(node)
		watch(1)
	end
end

local function cutsceneextro(me)
	cam_toEntity(v.n)
	v.incutscene = false
end

local function cutscene1(me)
	cutsceneintro(me, v.node_start)

	cam_toEntity(me)
	overrideZoom(1, 3)
	watch(3)
	
	entity_fh(me)
	--watch(0.5)
	entity_followPath(me, v.node_start)
	entity_animate(me, "runLow", -1)
	
	--overrideZoom(0.6, 2)
	
	watch(1)
	cam_toEntity(getNaija())
	
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_CLIMBDOWN)
	updateLocation(me)
	
	overrideZoom(0)
	
	cutsceneextro(me)
end

local function cutscene2(me)
	cutsceneintro(me, v.node_climbdown)
	
	entity_followPath(me, v.node_climbdown, SPEED_SLOW)
	entity_animate(me, "climbDown", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_RUNAWAY)
	updateLocation(me)
	
	cutsceneextro(me)
end

local function cutscene3(me)
	cutsceneintro(me, v.node_runaway)
	
	entity_followPath(me, v.node_runaway)
	entity_animate(me, "runLow", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_INHOLE)
	voiceOnce("Naija_CreatorChildDarkness")
	updateLocation(me)
	
	cutsceneextro(me)
end

-- reunited with mom
local function cutscene4(me)
	cutsceneintro(me, v.node_mom)
	
	entity_setState(v.mom, STATE_SING)
	
	debugLog("learn anima")
	learnSong(SONG_ANIMA)
	
	watch(2)
	
	entity_setPosition(me, node_x(v.node_gotogf), node_y(v.node_gotogf), 1, 0, 0, 1)
	
	while entity_isInterpolating(me) do watch(FRAME_TIME) end
	
	entity_followPath(me, v.node_gotogf)
	entity_animate(me, "runLow", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end	
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_GF)
	updateLocation(me)
	
	cutsceneextro(me)
end

local function cutscene5(me)
	entity_setState(v.gf, STATE_DONE)
	
	cutsceneintro(me, v.node_gf)
	
	--msg("THEY BREAK UP!!!")
	watch(1)
	
	local land = entity_getNearestNode(me, "CCGFLAND")
	
	entity_setPosition(v.gf, node_x(land), node_y(land), 1)
	watch(entity_animate(v.gf, "land"))
	local bone_flowers = entity_getBoneByName(v.gf, "Flowers")
	bone_alpha(bone_flowers, 0, 1)
	watch(1)
	entity_animate(v.gf, "idle", -1)
	watch(0.1)
	watch(entity_animate(v.gf, "reach"))
	
	entity_followPath(me, v.node_gf)
	entity_animate(me, "runLow", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BULLIES)
	updateLocation(me)
	
	cutsceneextro(me)
end

local function cutscene6(me)
	cutsceneintro(me, getNode("KIDSCAM"))
	
	watch(1)
	local e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "CC_Kid") then
			entity_setState(e, STATE_TRANSFORM)
		end
		e = getNextEntity()
	end
	
	watch(3)
	while node_getNumEntitiesIn(v.node_insectcheck, "Scavenger") < 1 do
		watch(1)
	end
	watch(2.5)
	--while entity_isFollowingPath(me) do watch(FRAME_TIME) end

	updateLocation(me)
	
	cutsceneextro(me)
end

local function cutscene7(me)
	entity_setState(v.gf, STATE_DONE)
	
	cutsceneintro(me, v.node_bullies)
	
	watch(1)
	
	entity_followPath(me, v.node_bullies)
	entity_animate(me, "runLow", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end	
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_ANIMA)
	updateLocation(me)
	
	cutsceneextro(me)
end

local function cutscene8(me)
	cutsceneintro(me, v.node_anima)
	watch(1)
	
	local door = entity_getNearestEntity(me, "EnergyDoor")
	if door ~= 0 then
		entity_setState(door, STATE_OPEN)
	end
	
	watch(3)
	
	entity_followPath(me, v.node_anima)
	entity_animate(me, "runLow", -1)
	
	while entity_isFollowingPath(me) do watch(FRAME_TIME) end
	
	setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BOSSWAIT)
	updateLocation(me)
	
	cutsceneextro(me)
end

function update(me, dt)
	if v.incutscene then return end
	
	if entity_isState(me, STATE_FOLLOW) then
		local xoff = 64
		local yoff = 64
		if entity_isfh(v.n) then
			xoff = -xoff
		end
		entity_flipToEntity(me, v.n)
		entity_setPosition(me, entity_x(v.n)+xoff, entity_y(v.n)+yoff, 0.8)
		return
	end
	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_START) then
		--start = getNode("start")
		if node_isEntityIn(v.node_start, v.n) then
			cutscene1(me)
		end
	end
	
	if entity_isEntityInRange(me, v.n, 256) then
		--if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_START) then
			--cutscene1(me)
		--else
		if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_CLIMBDOWN) then
			cutscene2(me)
		elseif isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_RUNAWAY) then
			cutscene3(me)
		end
		if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BULLIES) and not v.spawnedInsects then
			v.spawnedInsects = true
			cutscene6(me)
		end		
	end
	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BULLIES) and v.spawnedInsects then
		local num = node_getNumEntitiesIn(v.node_insectcheck, "Scavenger")
		if num <= 0 then
			cutscene7(me)
		end
	end
	

	if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_GF) then
		if entity_isEntityInRange(me, v.gf, 200) then
			cutscene5(me)
		end
	end
	
	if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_INHOLE) then
		if v.following == 0 then
			if entity_isEntityInRange(me, v.n, 100) and getForm() == FORM_SUN then
				v.following = 1
				entity_animate(me, "float", -1)			
			end
		else
			if not entity_isEntityInRange(me, v.n, 128) then
				local vx, vy = entity_getVectorToEntity(me, v.n)
				vx, vy = vector_setLength(vx, vy, 200*dt)
				entity_addVel(me, vx, vy)
				entity_doCollisionAvoidance(me, dt, 2, 1)
				
				entity_flipToEntity(me, v.n)
			else
				entity_doFriction(me, dt, 400)
			end
			entity_updateMovement(me, dt)
			if node_isEntityIn(v.node_mom, me) then
				cutscene4(me)
			else
				if not entity_isEntityInRange(me, v.n, 450) then
					entity_clearVel(me)
					updateLocation(me)
					v.following = 0
				end
			end
		end
	end
	
	if entity_isState(me, STATE_CREATE) then
		entity_setPosition(v.clay, entity_x(me)+32, entity_y(me))
		entity_clearVel(v.clay)
	else
		local f = getFlag(FLAG_SUNKENCITY_PUZZLE)
		if f >= SUNKENCITY_BOSSWAIT and f < SUNKENCITY_CLAYDONE then
			v.clay = entity_getNearestEntity(me, "Clay")
			if v.clay ~= 0 and entity_isEntityInRange(me, v.clay, 128) then
				entity_setProperty(v.clay, EP_MOVABLE, false)
				entity_clearVel(v.clay)
				entity_setPosition(v.clay, entity_x(me)+32, entity_y(me), 1)
				entity_setState(me, STATE_CREATE)
				setFlag(FLAG_SUNKENCITY_PUZZLE, f+1)
				debugLog(string.format("flag is now %d", getFlag(FLAG_SUNKENCITY_PUZZLE)))
			end
			
		end
	end
	
	if v.glow ~= 0 then
		quad_setPosition(v.glow, entity_getPosition(me))
	end
	
	--[[
	if v.leadDelay > 0 then
		if entity_isEntityInRange(me, v.n, 512) then
			v.leadDelay = v.leadDelay - dt
			if v.leadDelay < 0 then
				v.leadDelay = 0
				
				entity_swimToNode(me, v.abyssEndNode)
			end
		end
	end
	]]--
	
	if v.inAbyss then
	--[[
		if entity_isEntityInRange(me, v.n, 512) then
			e = entity_getNearestEntity(me, "FinalTongue")
			entity_setPosition(me, node_x(v.nd), node_y(v.nd))
			v.inAbyss = false
		end
	]]--
	--[[
		if entity_isFollowingPath(me) and not entity_isEntityInRange(me, v.n, 1024) then
			entity_stopFollowingPath(me)
			entity_rotate(me, 0, 1, 0, 0, 1)
			--leadDelay = 1
		end
		]]--
		
		if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_BOSSDONE) then
			--debugLog("bossdone")
			v.n = getNaija()
			entity_flipToEntity(me, v.n)
			v.waitForSceneDelay = v.waitForSceneDelay - dt
			if v.waitForSceneDelay < 0 and not v.inCutScene then
				v.inCutScene = true
				
				local e = entity_getNearestEntity(me, "finaltongue")
				
				cam_toEntity(me)
				entity_idle(v.n)
				entity_flipToEntity(v.n, me)
				watch(2)
				entity_idle(v.n)
				emote(EMOTE_NAIJAUGH)
				
				entity_alpha(me, 0, 2)
				fade2(1, 1, 1, 1, 1)
				watch(1)
				
				entity_setPosition(me, node_x(v.abyssEndNode), node_y(v.abyssEndNode))
				entity_flipToEntity(me, e)
				watch(1)
				fade2(0, 1, 1, 1, 1)
				watch(1)
				entity_alpha(me, 1, 2)
				watch(2)
				
				entity_setState(e, STATE_OPEN)
				cam_toNode(getNode("TongueCam"))
				watch(4)
				cam_toEntity(me)
				watch(1)
				
				fade2(1, 1, 1, 1, 1)
				watch(1)
				
				cam_toEntity(v.n)
				
				watch(1)
				
				fade2(0, 1, 1, 1, 1)
				watch(1)
				
				setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_FINALTONGUE)
				
				v.inCutScene = false
			end
		end
		
		
		
		--[[
		if not entity_isFollowingPath(me) then
			entity_flipToEntity(me, v.n)
			if node_isEntityIn(v.abyssEndNode, me) then
				
				if entity_isEntityInRange(me, v.n, 512) then
					local e = entity_getNearestEntity(me, "finaltongue")
					if e ~= 0 then
						entity_setState(e, STATE_OPEN)
					end
				end
			end
		end
		]]--
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		--entity_animate(me, "float", -1)
	elseif entity_isState(me, STATE_CREATE) then
		entity_animate(me, "create", -1)
		entity_setStateTime(me, 4)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_setPosition(me, entity_x(v.n), entity_y(v.n))
		entity_animate(me, "float", -1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CREATE) then
		entity_animate(me, "idle", -1)
		entity_delete(v.clay, 0.5)
		if isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_CLAY3) then
			setFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_CLAYDONE)
			entity_alpha(me, 0, 2)
			entity_setPosition(me, 0, 0, 10)
		end
		local statue = entity_getNearestEntity(me, "ClayStatue")
		if statue ~= 0 then
			entity_msg(statue, "p")
		end
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
	if song == SONG_ANIMA and isFlag(FLAG_SUNKENCITY_PUZZLE, SUNKENCITY_ANIMA) then
		cutscene8(me)
	end
end

function activate(me)
end

