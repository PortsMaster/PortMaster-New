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

local STATE_INACTIVE = 1000
local STATE_BURSTRIGHT		= 1001
local STATE_BURSTLEFT		= 1002
local STATE_BURSTLEFTPREP	= 1003
local STATE_BURSTRIGHTPREP	= 1004

v.level = 0
v.burstDelay = 2
v.lastDir = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Skeeter")	
	
	--entity_setEntityLayer(me, 1)
	--entity_setAllDamageTargets(me, true)
	
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setCanLeaveWater(me, true)
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_setInternalOffset(me, 0, -16)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.level = entity_y(me)
end

function update(me, dt)
	if entity_isState(me, STATE_INACTIVE) then
		if math.abs(getWaterLevel()-v.level) < 50 then
			entity_setState(me, STATE_IDLE)
		end
	else
		entity_updateMovement(me, dt)
		
		entity_handleShotCollisions(me)
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 800)

		entity_setPosition(me, entity_x(me), v.level)
		
		if entity_isState(me, STATE_BURSTRIGHT) then
			entity_addVel(me, 1000*dt, 0)
		elseif entity_isState(me, STATE_BURSTLEFT) then
			entity_addVel(me, -1000*dt, 0)
		elseif entity_isState(me, STATE_IDLE) then
			entity_doSpellAvoidance(me, dt, 64, 0.5)
			entity_doFriction(me, dt, 300)
			entity_doEntityAvoidance(me, dt, 32, 0.5)
			
			v.burstDelay = v.burstDelay - dt
			if v.burstDelay < 0 then
				v.burstDelay = 0.5 + math.random(200)/200.0
				if v.lastDir == 0 then
					entity_setState(me, STATE_BURSTLEFTPREP)
					v.lastDir = 1
				else
					entity_setState(me, STATE_BURSTRIGHTPREP)
					v.lastDir = 0
				end
			end
		end
		
		
		if math.abs(getWaterLevel()-v.level) > 50 then
			entity_setState(me, STATE_INACTIVE)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		if entity_isfh(me) then
			entity_fh(me)
		end
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_BURSTLEFTPREP) then
		entity_clearVel(me)
		entity_setStateTime(me, entity_animate(me, "burstLeftPrep"))
	elseif entity_isState(me, STATE_BURSTRIGHTPREP) then
		entity_clearVel(me)
		entity_fh(me)
		entity_setStateTime(me, entity_animate(me, "burstLeftPrep"))
	elseif entity_isState(me, STATE_BURSTLEFT) or entity_isState(me, STATE_BURSTRIGHT) then
		entity_setStateTime(me, 4 + math.random(3))
		entity_setMaxSpeedLerp(me, 4, 1.0)
		entity_animate(me, "burstLeft", -1)
	elseif entity_isState(me, STATE_INACTIVE) then
		entity_alpha(me, 0, 0.2)
	elseif entity_isState(me, STATE_DEAD) then
		entity_sound(me, "MetalExplode", math.random(100)+1100)
		spawnParticleEffect("SkeeterDie", entity_getPosition(me))
	end
end

function exitState(me)
	if entity_isState(me, STATE_INACTIVE) then
		entity_alpha(me, 1, 0.2)
	elseif entity_isState(me, STATE_BURSTLEFTPREP) then
		entity_setState(me, STATE_BURSTLEFT)
	elseif entity_isState(me, STATE_BURSTRIGHTPREP) then
		entity_setState(me, STATE_BURSTRIGHT)
	elseif entity_isState(me, STATE_BURSTRIGHT) or entity_isState(me, STATE_BURSTLEFT) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
	if entity_isState(me, STATE_BURSTLEFT) or entity_isState(me, STATE_BURSTRIGHT) then
		if key == 1 or key == 2 then
			entity_sound(me, "Splish", math.random(500)+1000)
		end
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_BURSTRIGHT) or entity_isState(me, STATE_BURSTLEFT) then
		entity_setState(me, STATE_IDLE)
	end
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

