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
v.cantPickupTimer = 3

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setTexture(me, "gui/wok")
	
	entity_initEmitter(me, 0, "upgrade-wok-glow")
	entity_startEmitter(me, 0)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setWeight(me, 200)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	if not isFlag(FLAG_UPGRADE_WOK, 0) then
		entity_delete(me)
	end
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	if v.cantPickupTimer > 0 then
		v.cantPickupTimer = v.cantPickupTimer - dt
		if v.cantPickupTimer < 0 then
			v.cantPickupTimer = 0
		end
	else
		if isFlag(FLAG_UPGRADE_WOK, 0) then
			if entity_isEntityInRange(me, getNaija(), 64) then
				setFlag(FLAG_UPGRADE_WOK, 1)
				playSfx("memory-found")
				spawnParticleEffect("Collect", entity_x(me), entity_y(me))
				entity_stopEmitter(me, 0)
				entity_alpha(me, 0, 0.5)
				
				setControlHint(getStringBank(26), 0, 0, 0, 8, "gui/icon-food")
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	end
end

function exitState(me)
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
end

function activate(me)
end

