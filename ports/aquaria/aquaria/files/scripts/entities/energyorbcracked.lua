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
-- ENERGY ORB CRACKED
-- ================================================================================================

v.charge = 0
v.delay = 1
v.chargeTimer = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupEntity(me, "EnergyOrbCracked", -1)

	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setWeight(me, 200)
	entity_setCollideRadius(me, 32)
	entity_setName(me, "EnergyOrb")
	
	entity_setMaxSpeed(me, 450)
	
	entity_setEntityType(me, ET_ENEMY)	
	
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
end

function update(me, dt)
	
	entity_handleShotCollisions(me)
	entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_CHARGED) then
		v.chargeTimer = v.chargeTimer - dt
		if v.chargeTimer < 0 then
			entity_setState(me, STATE_IDLE)
			spawnParticleEffect("EnergyOrbUnCharge", entity_x(me), entity_y(me))
		end
	end
	if not entity_isState(me, STATE_CHARGED) then		
		v.delay = v.delay - dt
		if v.delay < 0 then
			v.delay = 0.5
			v.charge = v.charge - 1
			if v.charge < 0 then
				v.charge = 0
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setTexture(me, "EnergyOrbCracked")
	elseif entity_isState(me, STATE_CHARGED) then
		v.chargeTimer = 1
		entity_setTexture(me, "EnergyOrbCracked-Charged")
		--msg("CHARGED")
	elseif entity_isState(me, STATE_INHOLDER) then
		entity_setWeight(me, 0)
		entity_clearVel(me)
	end
end

function exitState(me)
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)	
	if not entity_isState(me, STATE_CHARGED) then
		if damageType == DT_AVATAR_ENERGYBLAST then
			--v.charge = v.charge + dmg
		elseif damageType == DT_AVATAR_SHOCK then
			v.charge = v.charge + 10
		end
		if v.charge >= 10 then
			playSfx("EnergyOrbCharge")
			spawnParticleEffect("EnergyOrbCharge", entity_x(me), entity_y(me))
			entity_setState(me, STATE_CHARGED)
			v.charge = 0
		end
	end
	return false
end

function activate(me)
end
