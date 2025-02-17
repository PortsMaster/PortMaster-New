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
-- C E L L   G E N E R A T O R
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.delay = 1.0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	--entity_setAllDamageTargets(me, false)
	
	--entity_initSkeletal(me, "dark-full")
	--entity_setTexture(me, "missingimage")
	
	--entity_scale(me, 10, 10)
	
	entity_setTexture(me, "dark-full")

	--entity_generateCollisionMask(me)
	--entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setHealth(me, 3)
	entity_setDropChance(me, 20, 1)
	
	--entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, 4000)
end

function postInit(me)
	v.n = getNaija()
	--entity_setTarget(me, v.n)
end

function update(me, dt)

	if v.delay > 0 then
		v.delay = v.delay - dt
	else
		if not entity_hasTarget(me) then
			entity_findTarget(me, 400)
			local ent
			if entity_hasTarget(me) then
				if chance(80) then
					ent = createEntity("bloodcell-red", "", entity_x(me), entity_y(me))
				else
					ent = createEntity("bloodcell-white", "", entity_x(me), entity_y(me))
				end
				entity_rotate(ent, entity_getRotation(me))
				v.delay = math.random(3.0) + 3.0
			end
		else
			local ent
			if chance(80) then
				ent = createEntity("bloodcell-red", "", entity_x(me), entity_y(me))
			else
				ent = createEntity("bloodcell-white", "", entity_x(me), entity_y(me))
			end
			entity_scale(ent, 0, 0)
			entity_scale(ent, 1, 1, 0.3)
			
			entity_rotate(ent, entity_getRotation(me))
			v.delay = math.random(3.0) + 3.0
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
		
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	--debugLog("HIT")
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

