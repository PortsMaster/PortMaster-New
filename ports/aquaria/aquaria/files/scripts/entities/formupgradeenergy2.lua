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

v.charge = 0
v.delay = 1

function init(me)
	setupEntity(me, "FormUpgrades/EnergyIdol")
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	
	entity_setCollideRadius(me, 50)
	
	entity_setMaxSpeed(me, 450)
	
	entity_setEntityType(me, ET_ENEMY)
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)

	
	if hasFormUpgrade(FORMUPGRADE_ENERGY2) then
		entity_setState(me, STATE_CHARGED)
	end
end

function hitSurface(me)
	entity_setWeight(me, 0)
	entity_clearVel(me)
end

function update(me, dt)
	entity_handleShotCollisions(me)

	entity_updateMovement(me, dt)
	entity_updateCurrents(me)
	
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
	if entity_isState(me, STATE_CHARGED) then
		entity_setAllDamageTargets(me, false)
		entity_setTexture(me, "FormUpgrades/EnergyIdol-Charged")
		--debugLog(msg("GET ENERGY FORM UPGRADE!"))
		learnFormUpgrade(FORMUPGRADE_ENERGY2)
	elseif entity_isState(me, STATE_INHOLDER) then
		entity_setWeight(me, 0)
		entity_clearVel(me)
	end
end

function exitState(me)
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
			setControlHint("Naija's Energy Form has been upgraded. Energy Blasts will deal more damage.", 0, 0, 0, 8)
			entity_setState(me, STATE_CHARGED)			
		end
	end
	return false
end

function activate(me)
end
