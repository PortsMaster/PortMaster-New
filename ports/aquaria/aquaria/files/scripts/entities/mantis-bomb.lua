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

v.timer = 0

v.flashing = false

v.pulled = false

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "mantis/bomb")
	
	entity_setAllDamageTargets(me, false)
	
	entity_setCollideRadius(me, 64)
	
	entity_setState(me, STATE_IDLE)
	
	
	
	entity_scale(me, 3, 3)
	
	entity_setCanLeaveWater(me, true)
	
	entity_setProperty(me, EP_MOVABLE, true)
	
	entity_rotate(me, 360, 1, -1)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

local function explode(me)
	playSfx("mantis-bomb")
	entity_delete(me)
	shakeCamera(4, 1)
	
	local maxa = 3.14 * 2
	local a = 0
	while a < maxa do
		local s = createShot("mantisbomb", me)
		shot_setAimVector(s, math.sin(a), math.cos(a))
		a = a + (3.14*2)/16.0
	end
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	entity_checkSplash(me)
	
	if entity_isUnderWater(me) then
		entity_setWeight(me, 10)
		entity_setMaxSpeed(me, 400)
	else
		entity_setWeight(me, 400)
		entity_setMaxSpeed(me, 800)
	end
	
	v.timer = v.timer + dt
	if v.timer > 5 and not v.flashing then
		v.flashing = true
		entity_color(me, 1, 1, 1)
		entity_color(me, 1, 0.0, 0.0, 0.1, -1, 1)
		entity_offset(me, -10, 0)
		entity_offset(me, 10, 0, 0.05, -1, 1)
	end
	if v.timer > 10 then
		explode(me)
		return
	end
	
	if entity_isBeingPulled(me) then
		v.pulled = true
	end
	if not entity_isBeingPulled(me) and v.pulled then
		v.pulled = false
		local vx = entity_velx(me)
		local vy = entity_vely(me)
		
		entity_clearVel(me)
		entity_addVel(me, vx*0.25, vy*0.25)
		entity_addVel(me, 0, 50)
	end
	
	if not entity_isBeingPulled(me) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me, 3), 3, 1000, 0.5) then
			explode(me)
			return
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

function msg(me, msg)
	if msg == "exp" then
		explode(me)
	end
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

