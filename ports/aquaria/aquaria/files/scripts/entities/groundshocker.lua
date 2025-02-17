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
-- G R O U N D   S H O C K E R
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.shellOn = true
v.pullTime = 1.11

v.attackTime = 0.7

v.mT = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.moveTimer = 3.2 + (math.random(432) * 0.01)
	v.shotTimer = 2.1 + (math.random(210) * 0.01)

	setupBasicEntity(
	me,
	"GroundShocker/Core",			-- texture
	7,								-- health
	1,								-- manaballamount
	0,								-- exp
	0,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 12)
	
	entity_initSkeletal(me, "GroundShocker")
	v.bone_core = entity_getBoneByName(me, "Core")
	v.bone_shell = entity_getBoneByName(me, "Shell")
	entity_generateCollisionMask(me)
	
	entity_setAllDamageTargets(me, false)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setProperty(me, EP_MOVABLE, true)
	esetv(me, EV_WALLOUT, 2)
	esetvf(me, EV_CLAMPTRANSF, 0.2)
	entity_clampToSurface(me)
	
	bone_setSegs(v.bone_core)
	
	loadSound("groundshocker-attack")
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	
	-- RANDOMLY FLIP HORIZONTALLY
	if chance(50) then 
		entity_fh(me)
		entity_switchSurfaceDirection(me)
	end
end

function update(me, dt)
	entity_findTarget(me, 690)		-- Active range
	
	v.attackTime = v.attackTime - dt
	if v.attackTime <= 0 then v.attackTime = 0 end
	
	-- MOVE ALONG SURFACE
	if v.attackTime <= 0 then
		if eisv(me, EV_CLAMPING, 0) then
				
			entity_moveAlongSurface(me, dt, 32)
			
			v.moveTimer = v.moveTimer - dt
			if v.moveTimer <= 0 then 
				v.moveTimer = 3.2 + (math.random(432) * 0.01)
				
				if chance(78) then entity_switchSurfaceDirection(me) end
			end
		end
	end
	entity_rotateToSurfaceNormal(me, 0.34)
	
	-- SHOOT FOOLS
	v.shotTimer = v.shotTimer - dt
	if v.shotTimer <= 0 then
		v.shotTimer = 2.1 + (math.random(210) * 0.01)
		
		v.attackTime = 0.7
		
		local meX, meY = bone_getWorldPosition(v.bone_core)
		local nX, nY = entity_getNormal(me)
		nX, nY = vector_setLength(nX, nY, 16)
		spawnParticleEffect("GroundShockerShock", entity_x(me), entity_y(me))
		createEntity("GroundShockerAttackL", "", entity_x(me) + nX, entity_y(me) + nY)
		createEntity("GroundShockerAttackR", "", entity_x(me) + nX, entity_y(me) + nY)

		entity_sound(me, "groundshocker-attack")
	end
	
	if v.shellOn == true then
		-- PULL OFF SHELL
		if entity_isBeingPulled(me) then
			if v.pullTime > 0 then
				v.pullTime = v.pullTime - dt
			else
				v.shellOn = false
				bone_alpha(v.bone_shell, 0, 0.1)
				entity_setProperty(me, EP_MOVABLE, false)
				entity_setAllDamageTargets(me, true)
				
				local meX, meY = bone_getWorldPosition(v.bone_core)
				local nX, nY = entity_getNormal(me)
				nX, nY = vector_setLength(nX, nY, 256)
				local ent_shell = createEntity("GroundShockerShell", "", entity_x(me) + nX/4, entity_y(me) + nY/4)
				entity_rotateToVec(ent_shell, nX, nY)
				entity_moveTowards(ent_shell, entity_x(getNaija()), entity_y(getNaija()), 1, 1234)
			end
		else
			v.pullTime = 1.11
		end
		
		entity_handleShotCollisionsSkeletal(me)
		
		local bone = entity_collideSkeletalVsCircle(me, getNaija())
		if bone ~= 0 then
			local nX, nY = entity_getPosition(getNaija())
			local bX, bY = bone_getWorldPosition(bone)
			nX = nX - bX
			nY = nY - bY
			nX, nY = vector_setLength(nX, nY, 600)
			entity_addVel(getNaija(), nX, nY)
		end
	else
		entity_handleShotCollisions(me)
		entity_touchAvatarDamage(me, 42, 0.21, 321)
	end
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		bone_setSegs(v.bone_core, 4, 4, 0.6, 0.6, -0.022, 0, 4.8, 1)
		v.moveTimer = v.mT + (math.random(432) * 0.01)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if v.shellOn == true then
		return false
	else
		return true
	end
end

function hitSurface(me)
end

function dieNormal(me)
	if chance(75) then
		spawnIngredient("SpicyMeat", entity_x(me), entity_y(me))
	end
end

