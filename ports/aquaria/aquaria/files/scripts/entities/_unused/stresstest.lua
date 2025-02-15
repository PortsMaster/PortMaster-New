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

--DEFINE
--health 10
--dropChance 50 1

v.angle = 0
v.n = 0
v.beam = 0
v.delay = 0
function init(me)
	setupEntity(me)
	entity_setTexture(me, "missingImage")
	entity_setEntityType(me, ET_ENEMY)
	--entity_initSkeletal(me, "")	
	entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	--v.delay = -math.random(100)/100.0
	v.delay = 200
	v.angle = randAngle360()
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
--[[
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	]]--
	if isForm(FORM_BEAST) then
		entity_setActivationType(me, AT_CLICK)
	else
		entity_setActivationType(me, AT_NONE)
	end
	
	v.delay = v.delay + dt
	if v.delay > 10 then	
		--entity_say(me, "Where are you going?", SAY_QUEUE)
		--entity_say(me, "Hellooo?", SAY_QUEUE)
		--entity_say(me, "Are you listening to me?!?", SAY_QUEUE)
		--entity_say(me, "...", SAY_QUEUE)
		--entity_say(me, "Fine, then.", SAY_QUEUE)
		v.delay = 0
	end
	--[[
	v.delay = v.delay + dt
	if v.delay > 0.2 then
		v.delay = v.delay - 0.2
		if v.beam then
			beam_delete(v.beam)
			v.beam = 0
		end
		if v.beam == 0 then
			v.beam = createBeam("RotCore/Beam")
		end
		v.delay = 0
	end
	if v.beam ~= 0 then
		beam_setPosition(v.beam, entity_getPosition(me))
	end
	]]--

	--entity_moveTowardsAngle(me, v.angle, dt, 500)
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
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
	debugLog("activate")
	--entity_say(me, "Get it out!")
end

