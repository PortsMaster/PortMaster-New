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

-- ================================================================================================
-- Merman / Thin
-- ================================================================================================

v.honeyPower = 0

v.swimTime = 0
v.swimTimer = v.swimTime - v.swimTime/4
v.dirTimer = 0
v.dir = 0

v.gvel = false

v.forcedHug = false

v.incut = false

v.seen = false
v.inVeil01 = false

v.bone_helmet = 0
v.bone_head = 0
v.bone_fish1 = 0
v.bone_fish2 = 0
v.bone_hand = 0
v.bone_arm = 0
v.bone_weaponGlow = 0
v.bone_leftHand = 0

v.bone_llarm = 0
v.bone_ularm = 0

v.switchGiggle = false

v.pathDelay = 0

v.naijaOut = -25
v.hugOut = 0
v.curNote = -1

v.followDelay = 0

v.chaseTime = 0
v.expressionTimer = 0

local STATE_HANG 			= 1000
local STATE_SWIM 			= 1001
local STATE_BURST 		= 1002
local STATE_CHASED 		= 1003
local STATE_RUNTOCAVE 	= 1004
local STATE_BEFOREMEET 	= 1005
local STATE_FADEOUT		= 1006
local STATE_FOLLOWING 	= 1007
local STATE_CORNERED	= 1008
local STATE_CHASEFOOD	= 1009
local STATE_EAT			= 1010
local STATE_PATH		= 1011

v.naijaLastHealth = 0
v.nearEnemyTimer = 0
v.nearNaijaTimer = 0
v.headDelay = 1

v.flipDelay = 0

v.n = 0

v.zapDelay = 0.1

v.breathTimer = 0

v.ing = 0

local function distFlipTo(me, ent)
	if math.abs(entity_x(me)-entity_x(ent)) > 32 then
		entity_flipToEntity(me, ent)
	end
end

local function setNaijaHugPosition(me)
	entity_setPosition(v.n, entity_x(me)+v.hugOut, entity_y(me))
	local fh = entity_isfh(me)
	if fh then
		fh = false
	else
		fh = true
	end
	entity_setRidingData(me, entity_x(me)+v.hugOut, entity_y(me), 0, fh)
end

local function flipHug(me)
	debugLog("flipHug")
	if v.hugOut < 0 then
		v.hugOut = -v.naijaOut
	else
		v.hugOut = v.naijaOut
	end
	setNaijaHugPosition(me)
	entity_flipToEntity(me, v.n)
	entity_flipToEntity(v.n, me)
end

local function endHug(me)
	if entity_getRiding(v.n) == me then
		entity_setRiding(v.n, 0)
		entity_idle(v.n)
	end
	if entity_isState(me, STATE_HUG) then
		if not isForm(FORM_DUAL) then
			entity_setState(me, STATE_IDLE)
		end
	end
end

function activate(me)
	--debugLog("Li: activate")
	if entity_isState(me, STATE_HUG) then
		endHug(me)
	else
	
		if isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102) then
			--debugLog("setting li to follow")
			fade(1, 1)
			entity_idle(v.n)
			watch(1)
			if not v.switchGiggle then
				emote(EMOTE_NAIJAGIGGLE)
				v.switchGiggle = true
			end
			watch(0.3)
			playSfx("changeclothes2")
			setFlag(FLAG_LI, 100)
			entity_setActivationType(me, AT_NONE)
			entity_setState(me, STATE_IDLE)
			bone_alpha(v.bone_helmet, 0, 0.5)
			watch(0.5)
			fade(0,1)
			watch(1)
			setLi(me)
		end
	end
end

local function expression(me, ep, t)
	v.expressionTimer = t
	bone_showFrame(v.bone_head, ep)
	--[[
	if ep == "" then
		bone_setTexture(v.bone_head, "Li/Head")
	else
		ep = string.format("%s%s", "Li/Head-", ep)
		bone_setTexture(v.bone_head, ep)
	end
	]]--
end

function init(me)

--[[
	if isFlag(FLAG_LI, 0) or isFlag(FLAG_LI, 1) then
		debugLog("SETTING BEFOREMEET")
		entity_setState(me, STATE_BEFOREMEET)
	elseif isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102) then
		entity_setState(me, STATE_BEFOREMEET)
	else
		--debugLog(string.format("Got head: %d", v.bone_head))
		bone_alpha(v.bone_helmet, 0, 0.1)
		entity_setState(me, STATE_IDLE)
	end	
]]--
	
	setupBasicEntity(me, 
	"",								-- texture
	32,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	28,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Li")
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_scale(me, 0.5, 0.5)

	v.bone_helmet = entity_getBoneByName(me, "Helmet")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_fish1 = entity_getBoneByName(me, "Fish1")
	v.bone_fish2 = entity_getBoneByName(me, "Fish2")
	v.bone_hand = entity_getBoneByName(me, "RightArm")
	v.bone_arm = entity_getBoneByName(me, "RightArm2")
	v.bone_weaponGlow = entity_getBoneByName(me, "WeaponGlow")
	bone_setBlendType(v.bone_weaponGlow, BLEND_ADD)
	bone_alpha(v.bone_fish1)
	bone_alpha(v.bone_fish2)
	
	v.bone_llarm = entity_getBoneByName(me, "LLArm")
	v.bone_ularm = entity_getBoneByName(me, "ULArm")
	v.bone_leftHand = entity_getBoneByName(me, "LeftArm")

	
	entity_setEntityType(me, ET_NEUTRAL)

	--entity_setSpiritFreeze(me, false)
	
	entity_setBeautyFlip(me, false)
	entity_setDamageTarget(me, DT_AVATAR_LANCEATTACH, false)
	entity_setDamageTarget(me, DT_AVATAR_LANCE, false)
	
	esetv(me, EV_ENTITYDIED, 1)
	
	
	v.inVeil01 = isMapName("veil01")

	
	--entity_setRenderPass(me, 1)

end

function entityDied(me, ent)
	if v.ing ~= 0 and ent == v.ing then
		entity_setState(me, STATE_IDLE)
		v.ing = 0
	end
end

local function pathCheck(me, dt)
	-- messes up on small passages etc
	--[[
	if v.pathDelay > 0 then
		v.pathDelay = v.pathDelay - dt
	end
	if v.pathDelay <= 0 then
		v.pathDelay = 3
		entity_setState(me, STATE_PATH)
		return true
	end
	]]--
	return false
end

local function refreshWeaponGlow(me)
	local t = 0.5
	local f = 3
	if isFlag(FLAG_LICOMBAT, 1) then
		bone_alpha(v.bone_weaponGlow, 1, 0.5)
		bone_setColor(v.bone_weaponGlow, 1, 0.5, 0.5, t)
	else
		bone_alpha(v.bone_weaponGlow, 0.5, 0.5)
		bone_setColor(v.bone_weaponGlow, 0.5, 0.5, 1, t)
	end
	--[[
	bone_scale(v.bone_weaponGlow, v.bwgsz, v.bwgsz)
	bone_scale(v.bone_weaponGlow, v.bwgsz*f, v.bwgsz*f, t*0.75, 1, 1)		
	]]--
end
		

function postInit(me)
	v.n = getNaija()
	v.naijaLastHealth = entity_getHealth(v.n)
	v.bwgsz = bone_getScale(v.bone_weaponGlow)
	refreshWeaponGlow(me)
	
	if isFlag(FLAG_LI, 0) or isFlag(FLAG_LI, 1) then
		--debugLog("SETTING BEFOREMEET")
		entity_setState(me, STATE_BEFOREMEET, -1, true)
	elseif isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102) then
		entity_setState(me, STATE_BEFOREMEET, -1, true)
	elseif isFlag(FLAG_LI, 200) then
		bone_alpha(v.bone_helmet, 0, 0.1)
		-- overridable, do nothing
	else
		bone_alpha(v.bone_helmet, 0, 0.1)
		entity_setState(me, STATE_IDLE, -1, true)
	end		
	
	
	if isMapName("licave") then
		entity_moveToBack(me)
	end
end

local function zap(me)
	--debugLog("Zap!")
	--local attackRange = 256
	local attackRange = 800
	local chaseRange = 300
	local attacked = false

	local fx, fy = bone_getWorldPosition(v.bone_hand)
	local ent = getFirstEntity()
	while ent ~= 0 do
		if entity_isValidTarget(ent) then
			if entity_isDamageTarget(ent, DT_AVATAR_LIZAP, true) then
				--entity_setTarget(me, ent)
				if entity_isEntityInRange(me, ent, chaseRange) and not entity_isEntityInRange(me, ent, attackRange) then
					--entity_moveTowardsTarget(me, 1, 300)
					--entity_setMaxSpeedLerp(me, 1.1, 0.5)
					--entity_flipToEntity(me, ent)
				elseif entity_isEntityInRange(me, ent, attackRange) and not entity_isDead(ent) then
					-- zap this one					
					--entity_damage(ent, me, 1.0, DT_AVATAR_LIZAP)
					entity_animate(me, "fire", 0, LAYER_UPPERBODY)
					local s = createShot("Li", me, ent, fx, fy)
					endHug(me)
					
					local ax, ay = bone_getWorldPosition(v.bone_arm)
					local dx = entity_x(ent) - ax
					local dy = entity_y(ent) - ay
					shot_setAimVector(s, dx, dy)
					
					--softFlipTo(me, ent)
					
					--entity_setMaxSpeedLerp(me, 1, 0.5)
					attacked = true					
					break
				end
			end			
		end
		ent = getNextEntity()
	end	
	entity_setTarget(me, getNaija())
	--[[
	if attacked then
		spawnParticleEffect("LiZap", fx, fy)
	end
	]]--
end

local function cutscene(me)
	setCutscene(1,1)
	fadeOutMusic(4)
	--watch(2)
	--changeForm(FORM_NORMAL)
	
	setBeacon(BEACON_LI, false)
	
	toggleInput(0)
	overrideZoom(0.8, 5)
	entity_animate(me, "helmetFlyOff", 0, 3)
	entity_idle(v.n)
	
	voiceInterupt("NAIJA_LIBINDSONG1")
	
	
	watch(3)
	
	bone_alpha(v.bone_helmet, 0, 0.5)
	
	local node = entity_getNearestNode(me, "NAIJALI")
	entity_swimToNode(v.n, node)	
	
	entity_animate(me, "choke", LOOP_INF)
	
	expression(me, EXPRESSION_HURT, 99)
	
	entity_watchForPath(v.n)
	
	entity_flipToEntity(me, v.n)
	entity_flipToEntity(v.n, me)
	
	watchForVoice()


	
	
	watch(2)
	
	voice("NAIJA_LIBINDSONG2")
	-- naija floats forwards, kisses
	entity_setPosition(v.n, entity_x(me)-30, entity_y(me), 1, 0, 0, 1)	
	entity_animate(v.n, "kissLi")
	cam_toNode(getNode("KISSCAM"))
	watch(1)
	expression(me, EXPRESSION_NORMAL, 99)
	entity_animate(me, "getKissed")
	entity_setPosition(v.n, entity_x(me)-23, entity_y(me), 1, 0, 0, 1)
	watch(1)
	--[[
	entity_animate(v.n, "getKissed", LOOP_INF)
	while entity_isAnimating(v.n) do
		watch(FRAME_TIME)
	end
	]]--
	--[[
	entity_offset(v.n, 0, 8, 2, -1, 1)
	entity_offset(me, 0, 8, 2, -1, 1)
	]]--
	setNaijaHeadTexture("blink")
	expression(me, EXPRESSION_SURPRISE, 2)
	entity_animate(v.n, "kissLiLoop", LOOP_INF)
	entity_animate(me, "kissLiLoop", LOOP_INF)
	--entity_animate(v.n, "getKissedLoop", LOOP_INF)
	
	watchForVoice()
	
	-- music
	playMusic("Moment")

	-- particle effects start
	local kissNode = entity_getNearestNode(me, "KISSPRT")
	spawnParticleEffect("Kiss", node_x(kissNode), node_y(kissNode))
	
	watch(3)
	
	voice("NAIJA_LIBINDSONG3")
	
	watch(3)
	
	watchForVoice()
	watch(3)
	
	voice("NAIJA_LIBINDSONG4")
	watchForVoice()
	
	watch(2)
	-- drift apart

	voice("NAIJA_LIBINDSONG5")
	watch(3)
	--entity_addVel(me, 200, 0)
	entity_setPosition(me, entity_x(me)+200, entity_y(me), 10, 0, 0, 1)
	entity_setPosition(v.n, entity_x(v.n)-250, entity_y(v.n), 10, 0, 0, 1)
	
	entity_animate(v.n, "kissFloat")
	entity_animate(me, "kissFloat")
	
	--entity_addVel(v.n, -200, 0)
	--watchForVoice()
	
	--watch()
	watch(1)
	
	
	
	voice("NAIJA_LIBINDSONG6")
	
	watch(1)
	
	--watchForVoice()
	
	fade(1, 5)
	watch(3)
	
	fadeOutMusic(8)
	watch(8)
	
	watch(1)
	
	entity_offset(v.n)
	entity_offset(me)
	
	cam_toEntity(v.n)
	-- cutscene 2 goes here
	
	-- warp li outta here
	entity_setPosition(me, 0, 0)
	
	-- warp naija to sleep position
	setNaijaHeadTexture("")
	local sleepNode = getNode("NAIJAWAKE")
	entity_setPosition(v.n, node_x(sleepNode), node_y(sleepNode))
	entity_animate(v.n, "sleep", -1)
	node = getNode("PUPPETLI")
	entity_setPosition(me, node_x(node), node_y(node))
	entity_flipToEntity(v.n, me)	
	entity_flipToEntity(me, v.n)
	
	entity_animate(me, "idle", -1)
	
	-- skip that interp
	watch(0.5)
	
	fade(0, 5)
	watch(6)
	voice("Naija_NaijaAwakes1")
	entity_animate(v.n, "slowWakeUp")
	while entity_isAnimating(v.n) do
		watch(FRAME_TIME)
	end
	entity_animate(v.n, "idle", -1)
	
	watchForVoice()
	watch(1)
	
	node = getNode("NAIJAGETUP")
	entity_setPosition(v.n, node_x(node), node_y(node), -500, 0, 0, 1)
	
	entity_stopAllAnimations(me)
	entity_swimToNode(me, getNode("LISAYHI"))
	entity_animate(me, "swim", -1)
	voice("Naija_NaijaAwakes2")
	watch(2)
	entity_flipToEntity(me, v.n)
	cam_toEntity(me)
	entity_flipToEntity(me, v.n)
	watchForVoice()
	entity_flipToEntity(me, v.n)
	watch(1)
	voice("Naija_NaijaAwakes3")
	watch(1)
	cam_toEntity(v.n)
	watch(3)
	entity_animate(v.n, "ashamed", -1, LAYER_UPPERBODY)
	watchForVoice()
	entity_swimToNode(me, getNode("LIGETFISH"))
	
	entity_watchForPath(me)
	
	bone_alpha(v.bone_fish1, 1)
	bone_alpha(v.bone_fish2, 1)

	entity_swimToNode(me, getNode("LISAYHI"))
	voice("Naija_NaijaAwakes4")
	watchForVoice()	
	entity_animate(me, "holdFish", -1, LAYER_UPPERBODY)
	expression(me, EXPRESSION_HAPPY, 5)
	entity_stopAllAnimations(v.n)
	entity_idle(v.n)
	cam_toEntity(me)
	watch(2)
	
	fade(1, 1.5)
	watch(1.5)
	
	--bone_alpha(v.bone_fish1)
	bone_alpha(v.bone_fish2)
	local n_fish2 = entity_getBoneByName(v.n, "Fish2")
	bone_alpha(n_fish2, 1)

	
	cam_toEntity(v.n)
	entity_stopAllAnimations(v.n)
	entity_idle(v.n)
	entity_stopAllAnimations(me)
	
	esetv(v.n, EV_LOOKAT, 0)
	
	local naijaSit = getNode("NAIJASIT")
	local liSit = getNode("LISIT")
	entity_setPosition(v.n, node_x(naijaSit), node_y(naijaSit))
	entity_setPosition(me, node_x(liSit), node_y(liSit))
	entity_animate(me, "sitAndEat", -1)
	entity_animate(v.n, "sitAndEat", -1)
	
	cam_toNode(getNode("EATCAM"))
	watch(1)
	
	fade(0, 1.5)
	watch(1.5)	
	
	voice("Naija_NaijaAwakes5")
	watchForVoice()
	
	fade(1, 3)
	watch(3)
	
	bone_alpha(v.bone_fish1)
	bone_alpha(n_fish2)
	
	cam_toEntity(v.n)
	
	
	entity_idle(v.n)
	-- and then:
	
	playMusic("LiCave")
	watch(1)
	
	voice("Naija_NaijaAwakes6")
	setFlag(FLAG_LI, 100)
	entity_setState(me, STATE_IDLE)
	-- get to end nodes
	
	esetv(v.n, EV_LOOKAT, 1)
	
	-- end test
	fade(0, 1)
	watch(1)
	toggleInput(1)
	
	overrideZoom(0)
	
	setCutscene(0)
	
	learnSong(SONG_LI)
	
	setControlHint(getStringBank(42), 0, 0, 0, 10, "", SONG_LI)
	
	setLi(me)
end

function shiftWorlds(me, old, new)
	if hasLi() then
	--[[
		if new == WT_SPIRIT then
			entity_alpha(me, 0.1)
		else
			entity_alpha(me, 1)
		end
		x,y = entity_getPosition(v.n)
		entity_setPosition(me, x+1, y+1)
		]]--
	end

	-- resuming the hug after spirit return is not easily possible,
	-- as the game has additional code that repositions Li then.
	-- so we just end the hug; this allows moving in spirit form. -- FG
	if entity_isState(me, STATE_HUG) then
		endHug(me)
	end
end

function song(me, song)
	--debugLog("Li: Sung song!")
	if entity_isState(me, STATE_HUG) then
		if song == SONG_SHIELD then
			flipHug(me)
		end
		if song == SONG_LI then
			entity_setState(me, STATE_IDLE)
		end
	end
	
	if entity_isState(me, STATE_CORNERED) then
		--debugLog("i'm cornered and you sun a song")
		if song == SONG_BIND then
			--debugLog("it was bind")
			--debugLog(string.format("FLAG_LI: %d", getFlag(FLAG_LI)))
			if isFlag(FLAG_LI, 1) then			
				--debugLog("calling cutscene")
				cutscene(me)
			end
		end
	else
		if song == SONG_ENERGYFORM then
			v.nearNaijaTimer = 0
			expression(me, EXPRESSION_SURPRISE, 1.5)
			entity_flipToEntity(me, v.n)
			--entity_moveTowardsTarget(me, 1, -1000)
		elseif song == SONG_BEASTFORM then
			v.nearNaijaTimer = 0
			expression(me, EXPRESSION_ANGRY, 4)
			entity_flipToEntity(me, v.n)
		elseif song == SONG_NATUREFORM then
			v.nearNaijaTimer = 2
			expression(me, EXPRESSION_HAPPY, 3)
			entity_flipToEntity(me, v.n)		
		end
	end
end

local function softFlipTo(me, ent)
	if v.flipDelay < 0 then
		entity_flipToEntity(me, ent)
		v.flipDelay = 1
	end
end

function update(me, dt)
	if isForm(FORM_DUAL) then return end
	if v.incut then return end
	if entity_isState(me, STATE_WAIT) then return end
	if entity_isState(me, STATE_TRAPPEDINCREATOR) then return end
	if entity_isState(me, STATE_OPEN) then return end
	if entity_isState(me, STATE_CLOSE) then return end
	
	if entity_isState(me, STATE_PUPPET) then return end
	
	
	if not hasLi() and not v.seen then
		if v.inVeil01 then
			if entity_isEntityInRange(me, v.n, 600) then
				v.seen = true
				musicVolume(0.1, 0.5)
				entity_idle(v.n)
				entity_flipToEntity(v.n, me)
				--playSfx("naijachildgiggle")
				cam_toEntity(me)
				setGameSpeed(0.5, 1)
				--playSfx("heartbeat")
				wait(1.5)
				playSfx("heartbeat")
				wait(0.75)
				playSfx("heartbeat")
				wait(0.5)
				--playSfx("heartbeat")
				setGameSpeed(1, 1)
				cam_toEntity(v.n)
				musicVolume(1, 1)
				
			end
		end
	end
	
	--debugLog(string.format("liupdate state: %d", entity_getState(me)))
	
	local liPower = getLiPower()
	if liPower > 0 then
		debugLog("liPower!")
		entity_setColor(me, 0.6, 0.7, 1.0, 0.1)
	else
		entity_setColor(me, 1,1,1,0.1)
	end
	
	if entity_isState(me, STATE_CARRIED) then
		bone_alpha(v.bone_helmet, 0)
		--entity_setPosition(me, entity_x(v.n)+24, entity_y(v.n))
		return
	end
	--entity_touchAvatarDamage(me, 32, 1, 1200)
	--entity_handleShotCollisions(me)
	
	if v.bone_head ~= 0 then
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_head))
	end
	entity_updateCurrents(me, dt)
	
	local spdf = 1
	if liPower > 0 then
		spdf = 8
	end
	
	v.flipDelay = v.flipDelay - dt*spdf
	if v.flipDelay < 0 then
		v.flipDelay = 0
	end
	--if isFlag(FLAG_LI, 100) then
	if hasLi() and not entity_isState(me, STATE_CHASEFOOD) then
		if v.headDelay > 0 then
			v.headDelay = v.headDelay - dt
		else
			v.ent = entity_getNearestEntity(me)
			if eisv(v.ent, EV_TYPEID, EVT_PET) then
				v.ent = v.n
			end
			if v.ent ~= 0 and entity_isEntityInRange(me, v.ent, 256) then
				if not entity_isState(me, STATE_HUG) then
					if entity_getEntityType(v.ent) == ET_INGREDIENT then
						if ing_hasIET(v.ent, IET_LI) then
							
							-- move toward
							expression(me, EXPRESSION_HAPPY, 2)
							--entity_moveTowards(me, entity_x(v.ent), entity_y(v.ent), dt, 500)
							entity_setTarget(me, v.ent)
							--entity_updateMovement(me, dt)
							if not entity_isState(me, STATE_CHASEFOOD) and v.ent ~= 0 then
								v.ing = v.ent
								entity_setState(me, STATE_CHASEFOOD)
							end
						end
					elseif entity_getEntityType(v.ent) == ET_ENEMY and entity_isEntityInRange(me, v.ent, 128) then
						if eisv(v.ent, EV_TYPEID, EVT_PET) then
							v.ent = 0
						else
							v.nearEnemyTimer = v.nearEnemyTimer + dt*2
							v.nearNaijaTimer = v.nearNaijaTimer - dt
							if v.nearEnemyTimer > 10 then
								expression(me, EXPRESSION_ANGRY, 2)
								v.nearEnemyTimer = 10
							else
								expression(me, EXPRESSION_SURPRISE, 1)
							end
							entity_setNaijaReaction(me, "")
						end
					elseif entity_getEntityType(v.ent) == ET_AVATAR and entity_isEntityInRange(me, v.ent, 128) then
						--softFlipTo(me, v.ent)
						distFlipTo(me, v.ent)
						if entity_getHealth(v.ent) > 2 and isForm(FORM_NORMAL) and not avatar_isSinging() then
							v.nearNaijaTimer = v.nearNaijaTimer + dt*2
							if v.nearNaijaTimer > 4 then
								expression(me, EXPRESSION_HAPPY, 1)
							end
							if v.nearNaijaTimer > 5 then
								entity_setNaijaReaction(me, "smile")
							end
							if v.nearNaijaTimer > 14 then
								v.nearNaijaTimer = 0+math.random(2)
								entity_setNaijaReaction(me, "")
							end
							
							if avatar_getStillTimer() > 4 and not avatar_isOnWall() and v.nearNaijaTimer > 8 then
								if not isInputEnabled() or avatar_isSinging() then 
									v.nearNaijaTimer = 0
								else
									if entity_getRiding(getNaija()) == 0 then
										entity_setState(me, STATE_HUG)
									end
								end
							end
						end
					end
				end

				
				
				
				--entity_stopAllAnimations(me)
			else
				v.ent = 0
			end
			if v.ent ~= 0 then
				bone_setAnimated(v.bone_head, ANIM_POS)
				bone_lookAtEntity(v.bone_head, v.ent, 0.3, -10, 30, -90)
			else
				bone_setAnimated(v.bone_head, ANIM_ALL)
				entity_setNaijaReaction(me, "")
			end
		end
		v.nearEnemyTimer = v.nearEnemyTimer - dt
		if v.nearEnemyTimer < 0 then v.nearEnemyTimer = 0 end
		v.nearNaijaTimer = v.nearNaijaTimer - dt
		if v.nearNaijaTimer < 0 then v.nearNaijaTimer = 0 end
		
		if entity_getHealth(v.n) > v.naijaLastHealth then
			expression(me, EXPRESSION_HAPPY, 2)
		end
		v.naijaLastHealth = entity_getHealth(v.n)
		if entity_getHealth(v.n) < 1 then
			expression(me, EXPRESSION_HURT, 2)
		end
		if isFlag(FLAG_LICOMBAT, 1) and not entity_isState(me, STATE_PUPPET) then
			if v.zapDelay > 0 then
				v.zapDelay = v.zapDelay - dt
				if v.zapDelay < 0 then
					zap(me)
					v.zapDelay = 1.2
					--v.zapDelay = 0.001
				end
			end
		end
	end
	
	
	if v.expressionTimer > 0 then
		v.expressionTimer	= v.expressionTimer - dt
		if v.expressionTimer < 0 then
			v.expressionTimer = 0
			expression(me, EXPRESSION_NORMAL, 0)
		end
	end	
	if entity_isState(me, STATE_IDLE) then
		entity_setTarget(me, v.n)
		v.followDelay = v.followDelay - dt
		if v.followDelay < 0 then
			v.followDelay = 0
		end
		if entity_isEntityInRange(me, v.n, 1024) and not entity_isEntityInRange(me, v.n, 256) and not avatar_isOnWall() and entity_isUnderWater(v.n) then
			if v.followDelay <= 0 then
				entity_setState(me, STATE_FOLLOWING)
			end
		end 
		entity_doSpellAvoidance(me, dt, 128, 0.1)
		--entity_doEntityAvoidance(me, dt, 64, 0.5)
		if entity_isEntityInRange(me, v.n, 20) then
			entity_moveTowardsTarget(me, dt, -150)
		end
	elseif entity_isState(me, STATE_PATH) then
		--debugLog("updating state path")
		if entity_isFollowingPath(me) then
			if entity_isEntityInRange(me, v.n, 300) then
				entity_stopFollowingPath(me)
				entity_moveTowardsTarget(me, 1, 500)
				entity_setState(me, STATE_FOLLOWING)
			end
			
			--entity_setState(me, STATE_FOLLOWING)
		else
			entity_moveTowardsTarget(me, 1, 500)
			entity_setState(me, STATE_FOLLOWING)
		end
	elseif entity_isState(me, STATE_FOLLOWING) then		
		--debugLog("updating following")
		local amt = 800
		--not avatar_isOnWall() and 
		
		entity_doCollisionAvoidance(me, dt, 4, 1, 100, 1, true)
	
		entity_setTarget(me, v.n)
		if entity_isUnderWater(v.n) then
			if entity_isEntityInRange(me, v.n, 180) then
				entity_setMaxSpeedLerp(me, 0.2, 1)
			else
				entity_setMaxSpeedLerp(me, 1, 0.2)
			end
			
			if entity_isEntityInRange(me, v.n, 180) then
				entity_doFriction(me, dt, 200)
				if ((math.abs(entity_velx(v.n)) < 10 and math.abs(entity_vely(v.n)) < 10) or avatar_isOnWall()) then
					entity_setState(me, STATE_IDLE)
				end
			elseif entity_isEntityInRange(me, v.n, 250) then
				--entity_moveAroundTarget(me, dt, amt*0.8)
				entity_moveTowardsTarget(me, dt, amt)
			elseif entity_isEntityInRange(me, v.n, 512) then
				entity_moveTowardsTarget(me, dt, amt*2)
			elseif not entity_isEntityInRange(me, v.n, 1024) then
				if entity_isUnderWater(v.n) and not avatar_isOnWall() then
					if not pathCheck(me, dt) then
						entity_moveTowardsTarget(me, dt, amt)
					end
				else
					entity_moveTowardsTarget(me, dt, amt)
				end
			else
				entity_moveTowardsTarget(me, dt, amt)
			end
		else
			entity_setState(me, STATE_IDLE)
		end
		-- hmm?
		--entity_doSpellAvoidance(me, dt, 128, 0.2)
		
		
		--entity_doCollisionAvoidance(me, dt, 8, 0.05)

		if entity_doCollisionAvoidance(me, dt, 5, 0.1) then
			--entity_moveTowardsTarget(me, dt, 250)
		end
		--[[
		if entity_doCollisionAvoidance(me, dt, 1, 1) then
			entity_moveTowardsTarget(me, dt, 200)
		end
		]]--
		
		if math.abs(entity_velx(me)) < 1 and math.abs(entity_vely(me)) < 1 then
			--debugLog("get unstuck")
			entity_setMaxSpeedLerp(me, 1)
			entity_moveTowardsTarget(me, 1, 500)
		end
		--debugLog(string.format("li v(%d, %d)", entity_velx(me), entity_vely(me)))
	elseif entity_isState(me, STATE_CHASEFOOD) then
		if v.ing == 0 then
			entity_setState(me, STATE_IDLE)
		else
			local amt = 500

			entity_moveTowards(me, entity_x(v.ing), entity_y(v.ing), dt, amt)

			--entity_doSpellAvoidance(me, dt, 128, 0.2))
			entity_doCollisionAvoidance(me, dt, 3, 0.1)
			if v.ing ~= 0 and entity_isEntityInRange(me, v.ing, 32) then
				-- do yum type things
				entity_delete(v.ent)
				v.ent = 0
				v.ing = 0
				entity_setState(me, STATE_EAT)
				expression(me, EXPRESSION_HAPPY, 2)
				
				--debugLog("setting li power!")
				setLiPower(1, 30)
			end
		end

	elseif entity_isState(me, STATE_BEFOREMEET) then
		--debugLog("updating before meet")
		v.dirTimer = v.dirTimer + dt
		if v.dirTimer > 3 then
			v.dirTimer = 0
			if v.dir > 0 then
				v.dir = 0
			else
				v.dir = 1
			end
		end
		local spd = 300
		if v.dir > 0 then
			spd = -spd
		end
		entity_addVel(me, spd, 0)
		entity_doEntityAvoidance(me, dt, 256, 0.1)
		entity_doCollisionAvoidance(me, dt, 6, 0.5)
		
		if getFlag(FLAG_LI) < 100 then
			if entity_isEntityInRange(me, getNaija(), 150) then
				entity_setState(me, STATE_CHASED)
			end
		end

		--debugLog(string.format("vel: %d", entity_velx(me)))
	elseif entity_isState(me, STATE_CHASED) then
		v.chaseTime = v.chaseTime + dt
		-- 10
		if v.chaseTime > 1 then
			entity_setState(me, STATE_RUNTOCAVE)
		end
		entity_moveTowardsTarget(me, dt, -500)
		entity_doCollisionAvoidance(me, dt, 6, 0.5)
	elseif entity_isState(me, STATE_RUNTOCAVE) then
		local liin = getNode("LI_IN")
		if not entity_isEntityInRange(me, getNaija(), 1000) and not node_isEntityIn(liin, me) then
			entity_stopFollowingPath(me)
			entity_setState(me, STATE_BEFOREMEET)
		else
			if not entity_isFollowingPath(me) then
				if isFlag(FLAG_LI, 0) then
					entity_setState(me, STATE_FADEOUT)
				elseif isFlag(FLAG_LI, 1) then
					entity_setState(me, STATE_CORNERED)
				end
			end
		end
	elseif entity_isState(me, STATE_HUG) then
		--debugLog("state hug")
		entity_setMaxSpeedLerp(me, 2)
		expression(me, EXPRESSION_HAPPY, 0.5)
		if entity_getRiding(v.n) == me then
			entity_animate(v.n, "hugLi", 0, 3)
			if v.curNote ~= -1 then
				local vx, vy = getNoteVector(v.curNote, 400*dt)
				entity_addVel(me, vx, vy)
			end
			entity_doCollisionAvoidance(me, dt, 5, 0.1)
			entity_doCollisionAvoidance(me, dt, 1, 1)
			entity_doFriction(me, dt, 100)
			entity_updateMovement(me, dt)
			
			setNaijaHugPosition(me)
			
			entity_updateLocalWarpAreas(me, true)
			
			bone_setRenderPass(v.bone_llarm, 3)
			bone_setRenderPass(v.bone_ularm, 3)
			bone_setRenderPass(v.bone_leftHand, 3)
			
			if not v.forcedHug then
				if not isForm(FORM_NORMAL) or not isInputEnabled() or entity_isFollowingPath(v.n) or avatar_getStillTimer() < 1 or v.honeyPower ~= entity_getHealthPerc(v.n) then
					endHug(me)
				end
			end
			
			
			
			--[[
			ent = entity_getNearestEntity(me, "", 400, ET_ENEMY)
			if ent ~= 0 then
				expression(me, EXPRESSION_ANGRY, 1)
				entity_setState(me, STATE_IDLE)
				entity_flipToEntity(me, ent)
				entity_flipToEntity(v.n, ent)
			end
			]]--
		else
			--debugLog("naija is not riding")
			entity_setRiding(v.n, me)
		end
		--entity_setPosition(v.n, )
		

	end
	
	if not entity_isState(me, STATE_FADEOUT) and not entity_isState(me, STATE_HUG) and not entity_isState(me, STATE_PATH) then
		if (math.abs(entity_velx(me))) > 10 then
			entity_flipToVel(me)
		end
		if not entity_isState(me, STATE_IDLE) then
			entity_rotateToVel(me, 0.1)
		end
		if math.abs(entity_velx(me)) > 20 or math.abs(entity_vely(me)) > 20 then
			entity_doFriction(me, dt, 150)
			v.gvel = true
		else
			if v.gvel then
				entity_clearVel(me)
				v.gvel = false
			else
				entity_doFriction(me, dt, 40)
			end
		end
		entity_updateMovement(me, dt)
	end
	
	if not entity_isUnderWater(me) then
		local w = getWaterLevel()
		if math.abs(w - entity_y(me)) <= 40 then
			entity_setPosition(me, entity_x(me), w+40)
			entity_clearVel(me)
		else
			if entity_isUnderWater(v.n) then
				entity_setPosition(me, entity_x(v.n), entity_y(v.n))
			end
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me, state)
	--debugLog(string.format(%s%d, "li state: ", entity_getState(me)))
	local timer = 0
	if entity_isState(me, STATE_IDLE) then
		debugLog("idle")
		entity_rotate(me,0,0.5)
		entity_setMaxSpeed(me, 200)
		entity_animate(me, "idle", LOOP_INF)
		if v.n ~= 0 then
			entity_flipToEntity(me, v.n)
		end
		if not(isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102)) and getFlag(FLAG_LI) >= 100 then
			if v.bone_helmet ~= 0 then
				--debugLog("setting helmet alpha to 0")
				bone_alpha(v.bone_helmet, 0)
			end
		end
	elseif entity_isState(me, STATE_CARRIED) then
		entity_rotate(me, 0)
		--entity_rotate(me, 360, 5, -1)
		--entity_stopAllAnimations(me)
		if entity_isfh(me) then entity_fh(me) end
		bone_setAnimated(v.bone_head, ANIM_ALL)
		--entity_animate(me, "trappedInCreator", -1)
	elseif entity_getState(me)==STATE_BEFOREMEET then
		--debugLog("beforemeet")
		v.chaseTime = v.chaseTime - 3
		entity_rotate(me,0,0.5)
		entity_setMaxSpeed(me, 200)
		entity_animate(me, "idle", LOOP_INF)
		
		if isFlag(FLAG_LI, 101) or isFlag(FLAG_LI, 102) then
			bone_alpha(v.bone_helmet, 1)
			entity_setActivationType(me, AT_CLICK)
		end
	elseif entity_isState(me, STATE_CHASED) then
		--debugLog("chased")
		entity_setMaxSpeed(me, 500)
		entity_setTarget(me, getNaija())
	elseif entity_isState(me, STATE_FOLLOWING) then
		--debugLog("following")
		v.followDelay = 0.2
		entity_animate(me, "swim", LOOP_INF)
		entity_setMaxSpeed(me, 600)
		
		entity_setMaxSpeedLerp(me, 1, 0.1)
	elseif entity_isState(me, STATE_CHASEFOOD) then
		--debugLog("chase food")
		entity_animate(me, "swim", LOOP_INF)
		entity_setMaxSpeed(me, 650)
	elseif entity_isState(me, STATE_EAT) then
		--debugLog("eat")
		entity_animate(me, "eat", LOOP_INF)
		entity_rotate(me,0,0.5)
		entity_setMaxSpeed(me, 200)
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_RUNTOCAVE) then
		--debugLog("runtocave")
		entity_setMaxSpeed(me, 700)
		local node = getNode("LICAVE")
		if node ~= 0 then
			entity_swimToNode(me, node, SPEED_LITOCAVE)
			if not entity_isFollowingPath(me) then
				entity_setState(me, STATE_CHASED)
			end
		end
	elseif entity_getState(me)==STATE_SWIM then
		--debugLog("swim")
		entity_animate(me, "swim", LOOP_INF)
	elseif entity_isState(me, STATE_FADEOUT) then
		--debugLog("fadeout")
		--debugLog("setting flag to 1")
		setFlag(FLAG_LI, 1)
		entity_alpha(me, 0, 1)
		-- Make sure we don't see the head through the fading helmet.
		bone_showFrame(v.bone_head, -1)
	elseif entity_getState(me)==STATE_BURST then
		debugLog("burst")
		entity_animate(me, "burst")
		--entity_doSpellAvoidance(me, 1, 256, 1.0)
		entity_doEntityAvoidance(me, 1, 256, 1.0)
		entity_doCollisionAvoidance(me, 1, 256, 1.0)
	elseif entity_isState(me, STATE_CORNERED) then
		debugLog("cornered")
		voice("NAIJA_TRAPPEDLI")
		entity_flipToEntity(me, getNaija())
		--entity_setActivation(me, AT_CLICK, 64, 512)
	elseif entity_isState(me, STATE_WAIT) then
		debugLog("wait")
	elseif entity_isState(me, STATE_HUG) then
		v.incut = true
		debugLog("HUG!")
		
		entity_flipToEntity(me, v.n)
		entity_flipToEntity(v.n, me)
		
		v.nearNaijaTimer = 0
		v.hugOut = v.naijaOut
		if entity_isfh(me) then
			v.hugOut = -v.hugOut
		end
		
		entity_setNaijaReaction(me, "")
		-- FIXME: There's no "shock" expression; what was intended?  --achurch
		--expression(me, shock, 1) -- removed for now to prevent warnings in strict mode --fg
		
		entity_clearVel(me)
		entity_clearVel(v.n)
		
		entity_idle(v.n)
		entity_setPosition(v.n, entity_x(me)+v.hugOut, entity_y(me), 1, 0, 0, 1)
		watch(1)
		
		v.honeyPower = entity_getHealthPerc(v.n)
	
		entity_setRiding(v.n, me)
		
		entity_flipToEntity(me, v.n)
		entity_flipToEntity(v.n, me)
		
		entity_setNaijaReaction(me, "smile")
		
		entity_animate(me, "hugNaija")
		
		entity_offset(me, 0, 0, 0)
		entity_offset(v.n, 0, 0, 0)
		
		entity_offset(me, 0, 10, 1, -1, 1, 1)
		entity_offset(v.n, 0, 10, 1, -1, 1, 1)
		
		entity_setActivationType(me, AT_CLICK)
		
		if not v.forcedHug then
			if chance(75) then
				if chance(50) then
					emote(EMOTE_NAIJAGIGGLE)
				else
					emote(EMOTE_NAIJASIGH)
				end
			end
		end
		v.incut = false
	elseif entity_isState(me, STATE_PATH) then
		debugLog("enter state path")
		entity_swimToPosition(me, entity_x(v.n), entity_y(v.n), SPEED_NORMAL)
	elseif entity_isState(me, STATE_TRAPPEDINCREATOR) then
		entity_rotate(me, 0)
		--entity_rotate(me, 360, 5, -1)
		entity_stopAllAnimations(me)
		if entity_isfh(me) then entity_fh(me) end
		bone_setAnimated(v.bone_head, ANIM_ALL)
		entity_animate(me, "trappedInCreator", -1)
		--[[
		entity_offset(me, 0)
		entity_offset(me, 0, 30, 1, 0, 0, 1)
		]]--
	elseif entity_isState(me, STATE_OPEN) then
		entity_rotate(me, 0)
		--entity_rotate(me, 360, 5, -1)
		entity_stopAllAnimations(me)
		if entity_isfh(me) then entity_fh(me) end
		bone_setAnimated(v.bone_head, ANIM_ALL)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CLOSE) then
		-- when getting sucked into the creator
		entity_rotate(me, 0)
		entity_stopAllAnimations(me)
		if entity_isfh(me) then entity_fh(me) end
		bone_setAnimated(v.bone_head, ANIM_ALL)
		entity_animate(me, "suckedin", -1)
	elseif entity_isState(me, STATE_PUPPET) then
		entity_idle(me, "idle", -1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_BURST) then
		entity_setState(me, STATE_SWIM)
	elseif entity_isState(me, STATE_HUG) then
		entity_setMaxSpeedLerp(me, 1, 0.5)
		debugLog("hug off")
		entity_offset(me, 0, 0, 0)
		entity_offset(v.n, 0, 0, 0)
		
		bone_setRenderPass(v.bone_llarm, 1)
		bone_setRenderPass(v.bone_ularm, 1)
		bone_setRenderPass(v.bone_leftHand, 1)
		
		endHug(me)
		
		entity_setActivationType(me, AT_NONE)
	elseif entity_isState(me, STATE_EAT) then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function msg(me, msg, val)
	-- switch to and from combat mode
	if msg == "c" then
		refreshWeaponGlow(me)
		entity_animate(me, "switchCombat", 0, LAYER_UPPERBODY)
	elseif msg == "forcehug" then
		v.forcedHug = true
		entity_setState(me, STATE_HUG, -1, 1)
	elseif msg == "endhug" then
		v.forcedHug = false
		endHug(me)
	elseif msg == "expression" then
		expression(me, val, 2)
	end
end

function songNote(me, note)
	v.curNote = note
end

function songNoteDone(me, note, len)
	v.curNote = -1
end
