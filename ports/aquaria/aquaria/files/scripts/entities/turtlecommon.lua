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
-- TURTLE
-- ================================================================================================

v.hasShell = true
v.pullTime = 1
v.escapeTimer = 0
v.escaping = false
v.isShell = false
v.dir = -1
v.bone_shell = 0
v.bone_body = 0
v.goDelay = 10

 
function v.commonInit(me, shell)
	v.hasShell = shell
	
	local layer = 1
	if not shell then
		layer = 0
	end
	setupBasicEntity(
	me,
	"",					-- texture
	3,								-- health
	1,								-- manaballamount
	1,								-- exp
	0,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	layer
	)
	
	entity_initSkeletal(me, "Turtle")

	entity_setCollideRadius(me, 32)
	
	entity_setMaxSpeed(me, 300)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setDropChance(me, 100, 5)
	
	v.bone_shell = entity_getBoneByName(me, "Shell")
	v.bone_body = entity_getBoneByName(me, "Body")
	
	
	if v.hasShell then
		--entity_setColor(me, 0, 1, 0)
		entity_setProperty(me, EP_MOVABLE, true)
	else
		bone_alpha(v.bone_shell, 0, 0.1)
		entity_setMaxSpeed(me, 600)
		--entity_setColor(me, 1, 1, 1)
	end	
	entity_animate(me, "idle", LOOP_INF)
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_addRandomVel(me, 1000)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	
	
	if v.isShell then
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
		entity_setDamageTarget(me, DT_AVATAR_PET, false)
	end

	--[[
	if v.hasShell or v.isShell then
		entity_touchAvatarDamage(me, 32, 1, 1200)
	else
		entity_touchAvatarDamage(me, 32, 0, 1200)
	end
	]]--
	if not v.isShell then
		
		entity_rotateToVel(me, 0.1)
		
		if v.goDelay > 0 and not entity_isBeingPulled(me) then
			v.goDelay = v.goDelay - dt
			if v.goDelay < 0 then
				entity_addRandomVel(me, 1000)
				v.goDelay = 2 + math.random(5)
			end
		end
	else
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	end
	if v.hasShell then
		entity_touchAvatarDamage(me, 32, 1, 1200)
		if entity_isBeingPulled(me) then
			entity_setMaxSpeedLerp(me, 0.2, 0.5)
			v.pullTime = v.pullTime - dt
			local x, y = entity_getVectorToEntity(getNaija(), me)
			if v.pullTime < 0 then
				v.hasShell = false
				v.isShell = true
				
				avatar_setPullTarget(0)
				--entity_setProperty(me, EP_MOVABLE, false)
				
				bone_alpha(v.bone_body, 0, 0.1)
				entity_setWeight(me, 300)
				--debugLog("**** PULLED off SHELL!")
				entity_createEntity(me, "TurtleNoShell")
				
				--[[
				entity_setProperty(me, EP_MOVABLE, true)
				entity_setProperty(me, EP_BLOCKER, true)
				avatar_setPullTarget(0)
				]]--
				
				entity_setMaxSpeedLerp(me, 1, 0.2)
				
				playSfx("popshell")
				
			end
			if not vector_isLength2DIn(x, y, 300) and not v.escaping then
				

			end
			if v.hasShell then				
				if x ~= 0 or y ~= 0 then
					--[[
					x, y = vector_setLength(x, y, 1000*dt)
					entity_addVel(getNaija(), x, y)
					]]--
					--entity_addVel(me, -5000*dt, 0)
					--[[
					ex, ey = vector_setLength(x, y, -10000*dt)
					entity_clearVel(me)
					entity_addVel(me, ex, ey)
					]]--
					v.escapeTimer = v.escapeTimer + dt
					if v.escapeTimer < 3 then
						entity_addVel(me, v.dir*5000*dt, 0)
					--[[
						if x ~= 0 then						
							ex,ey = vector_setLength(x, 0, -5000*dt)
							v.escaping = true
							entity_addVel(me, ex, ey)
							--entity_addVel(getNaija(), x, y)
						end
						]]--
					elseif v.escapeTimer > 6 then
						v.escaping = false
						v.escapeTimer = 0
						if v.dir < 0 then
							v.dir = 1
						else
							v.dir = -1
						end
					end
				end
			end
		else
			entity_setMaxSpeedLerp(me, 1, 0.5)
		end
	end
	
	if not v.isShell then
		entity_doEntityAvoidance(me, dt, 32, 1.0)
		entity_doCollisionAvoidance(me, dt, 6, 1.0)
	end
	entity_updateMovement(me, dt)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)
	if v.hasShell or v.isShell then
		playSfx("noeffect")
		return false
	end
	return true
end

function activate(me)
end


function dieNormal(me)
	if not v.isShell and not v.hasShell then
		spawnIngredient("TurtleMeat", entity_x(me), entity_y(me))
	end
end
