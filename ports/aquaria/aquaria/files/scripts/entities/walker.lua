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
-- W A L K E R   (alpha)
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.moveTimer = 0
v.n = 0

v.seen = false
v.sighTimer = 5

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"Walker/Body",					-- texture
	123,							-- health
	4,								-- manaballamount
	0,								-- exp
	0,								-- money
	480,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	3210							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setCullRadius(me, 2048)
	
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_initSkeletal(me, "Walker")
	v.bone_body = entity_getBoneByName(me, "Body")
	entity_generateCollisionMask(me)
	
	-- DARKEN BACK LEGS
	local backLeg1Bottom = entity_getBoneByName(me, "BackLeg1Bottom")
	local backLeg1Top = entity_getBoneByName(me, "BackLeg1Top")
	local BackLeg2Bottom = entity_getBoneByName(me, "BackLeg2Bottom")
	local backLeg2Top = entity_getBoneByName(me, "BackLeg2Top")
	local cl = 0.64
	bone_setColor(backLeg1Bottom, cl, cl, cl)
	bone_setColor(backLeg1Top, cl, cl, cl)
	bone_setColor(BackLeg2Bottom, cl, cl, cl)
	bone_setColor(backLeg2Top, cl, cl, cl)
	
	entity_scale(me, 1.23, 1.23)
	
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	--esetv(me, EV_WALLOUT, 23)
	--entity_clampToSurface(me)
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	
	v.n = getNaija()
	
	-- FLIP WITH A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
			--entity_switchSurfaceDirection(me)
		end
	end
end

function update(me, dt)
	-- NAIJA ATTACHING TO BODY
	local rideBone = entity_collideSkeletalVsCircle(me, v.n)
	if rideBone == v.bone_body and avatar_isBursting() and entity_setBoneLock(v.n, me, rideBone) then
	elseif rideBone ~=0 then
		local vecX, vecY = entity_getVectorToEntity(me, v.n, 1000)
		entity_addVel(v.n, vecX, vecY)
	end
	
	-- emote
	if entity_isEntityInRange(me, v.n, 512) then
		if not v.seen then
			if chance(50) then
				emote(EMOTE_NAIJAWOW)
			else
				emote(EMOTE_NAIJALAUGH)
			end
		end
		v.seen = true
		v.sighTimer = v.sighTimer - dt
		if v.sighTimer < 0 then
			emote(EMOTE_NAIJAGIGGLE)
			v.sighTimer = 8 + math.random(4)
		end
	end
		
	-- MOVEMENT
	--entity_rotateToSurfaceNormal(me, 0.54)	
	-- COLLISIONS
	entity_handleShotCollisionsSkeletal(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	playNoEffect()
	return false
end
