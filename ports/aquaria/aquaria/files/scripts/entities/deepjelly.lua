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
-- JELLY SMALL
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.glow = 0
v.bulb = 0
v.revertTimer = 0
v.baseSpeed = 300
v.excitedSpeed = 700
v.runSpeed = 800
v.useMaxSpeed = 0
v.pushed = false
v.shell = 0
v.soundDelay = 0
v.sx = 0
v.sy = 0
v.sz = 0.8
v.transition = false

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

local function doIdleScale(me)
	entity_scale(me, 0.75*v.sz, 1*v.sz)
	entity_scale(me, 1*v.sz, 0.75*v.sz, 1.5, -1, 1, 1)
end

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	16,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	v.useMaxSpeed = v.baseSpeed
	entity_setEntityType(me, ET_ENEMY)
	
	entity_initSkeletal(me, "DeepJelly")
	
	v.l = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.l, 2, 2)
	
	
	--entity_scale(me, 0.6, 0.6)

	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 75)
	
	entity_initStrands(me, 5, 60, 8, 5, 0.8, 0.8, 1)
	
	v.glow = entity_getBoneByName(me, "Glow")
	v.bulb = entity_getBoneByName(me, "Bulb")
	v.shell = entity_getBoneByName(me, "Shell")
	
	doIdleScale(me)
	v.soundDelay = math.random(3)
	v.sx, v.sy = entity_getScale(me)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function songNote(me, note)
	if getForm()~=FORM_NORMAL then
		return
	end
	
	--[[
	v.sx, v.sy = entity_getScale(me)
	entity_scale(me, v.sx, v.sy)
	v.sx = v.sx*1.1
	v.sy = v.sy*1.1
	if v.sx > 1.0 then
		v.sx = 1.0
	end
	if v.sy > 1.0 then
		v.sy = 1.0
	end
	entity_scale(me, v.sx, v.sy, 0.2, 1, -1)
	]]--

	--[[
	entity_setWidth(me, 128)
	entity_setHeight(me, 128)
	entity_setWidth(me, 512, 0.5, 1, -1)
	entity_setHeight(me, 512, 0.5, 1, -1)
	]]--
	
	bone_scale(v.shell, 1,1)
	bone_scale(v.shell, 1.1, 1.1, 0.1, 1, -1)
	
	entity_setMaxSpeed(me, v.excitedSpeed)
	v.revertTimer = 3
	local transTime = 0.5
	local r,g,b = getNoteColor(note)
	bone_setColor(v.bulb, r,g,b, transTime)
	r = (r+1.0)/2.0
	g = (g+1.0)/2.0
	b = (b+1.0)/2.0
	bone_setColor(v.shell, r,g,b, transTime)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) and not v.transition and not entity_isScaling(me) then
		entity_scale(me, 0.75*v.sz, 1*v.sz, 0.2)
		v.transition = true
	end
	if v.transition then
		if not entity_isScaling(me) then
			doIdleScale(me)
			v.transition = false
		end
	end

	entity_findTarget(me, 1024)
	if not entity_hasTarget(me) then
		--entity_doCollisionAvoidance(me, dt, 4, 0.1)		
	end
	
	if v.revertTimer > 0 then
		v.soundDelay = v.soundDelay - dt
		if v.soundDelay < 0 then
			entity_sound(me, "JellyBlup", 1400+math.random(200))
			v.soundDelay = 4 + math.random(2000)/1000.0
		end
		v.revertTimer = v.revertTimer - dt
		if v.revertTimer < 0 then
			v.useMaxSpeed = v.baseSpeed
			entity_setMaxSpeed(me, v.baseSpeed)
			bone_setColor(v.shell, 1, 1, 1, 1)
		end
	end
	if entity_hasTarget(me) then
		if entity_isUnderWater(entity_getTarget(me)) then
			if getForm()==FORM_NORMAL then
					-- do something
				if entity_isTargetInRange(me, 1000) then
					if not entity_isTargetInRange(me, 64) then				
					entity_moveTowardsTarget(me, dt, 250)
					end
				end
			else
				if entity_isTargetInRange(me, 512) then		
					--entity_setMaxSpeed(me, 600)
					entity_setMaxSpeed(me, v.runSpeed)
					v.useMaxSpeed = v.runSpeed
					v.revertTimer = 0.1
					entity_moveTowardsTarget(me, dt, -250)
				end
			end		
		end
		
		--if not entity_isTargetInRange(me, 150) then
			
		--end
	end
	
	entity_doCollisionAvoidance(me, dt, 3, 1.0)
	entity_doEntityAvoidance(me, dt, 64, 0.2)
	entity_doSpellAvoidance(me, dt, 200, 0.8)
	
	entity_updateCurrents(me, dt*5)
	
	entity_rotateToVel(me, 0.1)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	quad_setPosition(v.l, entity_getPosition(me))
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.useMaxSpeed = v.baseSpeed
		entity_setMaxSpeed(me, v.baseSpeed)
		entity_animate(me, "idle", LOOP_INF)
		
		local x = math.random(2000)-1000
		local y = math.random(2000)-1000
		entity_addVel(me,x,y)
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.l, 2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_setHealth(me, 0)
	end
	return true
end

function dieNormal(me)
	if chance(20) then
		spawnIngredient("JellyOil", entity_x(me), entity_y(me))
	end
end

function exitState(me)
end
